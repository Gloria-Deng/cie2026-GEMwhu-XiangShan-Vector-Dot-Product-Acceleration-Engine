#!/usr/bin/env python3

from __future__ import annotations
import argparse
import csv
import importlib.util
import json
import os
from pathlib import Path
import sys
import tarfile
import tempfile
from types import SimpleNamespace

sys.dont_write_bytecode=True
from runtime_common import ROOT,digest,load,new_output,recorded_file,matches_historical_source,historical_source_changes
from analyze_vadd_fst import Timeline,analyze,extract,write_csv,plot,vcd,require
from check_vadd_fst_failures import check_failures

ORIGINAL_RECORDS={'summary.json': '4f029a48cec00e3d1fef9da749a94cdecf779d24b98c39bf8637fe4a72af2581', 'build_manifest.json': '78295573143703d108e885cbe87d587c858443058a70d19d4184e73a10638cd1', 'program_manifest.json': 'c6d62134c6f46a0bdcbb3868c9a8d68ab2098eb014bbd518350b87b3d83863a5'}

ARCHIVE_ID='bb0df6d85d154390dfa895c41bdc276fe568bfb201a0e3a0548d105191eb0030'

def csv_rows(path):
    with Path(path).open(encoding='utf-8-sig',newline='') as f:return list(csv.DictReader(f))

def compare_csv(path,rows,out):
    target=out/path.name;write_csv(target,rows)
    require(csv_rows(path)==csv_rows(target),'formal table differs: '+path.name)

def inside(root,rel):
    path=(root/rel.replace('\\','/')).resolve()
    require(path==root or root in path.parents,'reference leaves project: '+rel)
    return path

def unpack_original(archive,out):
    require(digest(archive)==ARCHIVE_ID,'original attachment content differs')
    target=out/'attachment';target.mkdir()
    with tarfile.open(archive,'r:gz') as tf:
        for m in tf.getmembers():
            inside(target,m.name)
            require(m.isfile() or m.isdir(),'unsupported attachment member: '+m.name)
        tf.extractall(target)
    return target/'vdot-evidence/validation'


def check_cluster(validation):
    sys.path.insert(0,str(ROOT/'cluster'))
    from run_suite import classify
    summary=load(validation/'summary.json');pm=load(validation/'program_manifest.json')
    require(summary['all_ok'] and len(summary['runs'])==64,'full-core summary must have 64 successes')
    require(len(summary['inputs'])==19,'full-core registered input count changed')
    for rel,want in summary['inputs'].items():require(matches_historical_source(inside(ROOT,rel),want),'full-core input differs: '+rel)
    require(digest(validation/'build_manifest.json')==summary['build_manifest_sha256'],'build registration differs')
    for name in ('summary.json','build_manifest.json','program_manifest.json'):
        require(digest(validation/name)==ORIGINAL_RECORDS[name],'formal cluster registration differs: '+name)
    programs={r['name']:r for r in pm['programs']}
    for row in pm['programs']:

        image=ROOT/'programs'/row['image']
        require(digest(image)==row['image_sha256'],'executed image differs: '+row['image'])
    for row in summary['runs']:
        p=recorded_file(inside(validation,row['log']),row['log_sha256'])
        actual=classify(p.read_text(encoding='utf8',errors='replace'),0,programs[row['name']])
        require(actual['ok'] and row['ok'],'full-core execution rejected: '+row['name'])
        for k in ('pc','cycles_lower','uncertainty_cycles'):
            if k in actual:require(actual[k]==row[k],'full-core parsed value differs: '+row['name']+' '+k)
    wave=summary['wave']
    require(digest(recorded_file(validation/wave['file'],wave['sha256']))==wave['sha256'],'registered FST differs')
    require(digest(recorded_file(validation/wave['log'],wave['log_sha256']))==wave['log_sha256'],'wave recording output differs')
    return dict(inputs=19,programs=len(programs),executions=64)

def check_current():
    captures=('fixed_wrapper','instruction_cosim','programs_nemu','patch_export')
    for name in captures:
        data=load(ROOT/'results/current'/(name+'.json'))
        require(data.get('all_ok') and data.get('inputs'),'current result is not successful: '+name)
        for rel,want in data['inputs'].items():
            require(matches_historical_source(inside(ROOT,rel),want),'supplied recording input differs: '+name+' '+rel)
        for row in list(data.get('logs',{}).values())+data.get('programs',[]):
            rel=row.get('log',row.get('path'));want=row.get('log_sha256',row.get('sha256'))
            if rel and want:require(digest(inside(ROOT,rel))==want,'current result content differs: '+rel)
    return dict(captures=len(captures),scope='supplied_recordings',current_code_verified=False)


def check_wave(args,out,validation):
    base=ROOT/'results/vadd_wave_stage1';meta=load(base/'selected_signals.json')
    require(len(meta)==260,'signal selection must contain 260 entries')
    image=args.image or ROOT/'gen/cluster_programs/vadd_full_register.bin'
    require(digest(image)==digest(ROOT/'programs/vadd_full_register.bin'),'analysis image differs from executed program')
    if args.tables_only:
        rows=csv_rows(base/'extract_all.csv');info=None
    else:
        fst=args.fst or recorded_file(validation/'vadd.fst',load(validation/'summary.json')['wave']['sha256'])
        lib=args.library or ROOT/'tools/fsttool'/('fstapi.dll' if os.name=='nt' else 'libfstapi.so')
        require(lib.is_file(),'missing FST reader: '+str(lib)+'; see tools/fsttool/build_fstapi.md')
        rows,info=extract(SimpleNamespace(library=lib,fst=fst,scratch=args.scratch,out=out),meta)
        def norm(rs):return [(int(r['time']),int(r['handle']),r['name'],r['value']) for r in rs]
        require(norm(rows)==norm(csv_rows(base/'extract_all.csv')),'raw FST extraction differs from formal table')
        require(info==load(base/'fst_info.json'),'FST file information differs')
    require(len(rows)==81378,'extracted change count differs')
    tl=Timeline(rows,meta);summary,events,elements=analyze(tl,image,meta)
    compare_csv(base/'vadd_all11_summary.csv',summary,out)
    compare_csv(base/'vadd_exec1_events.csv',events,out)
    compare_csv(base/'element_checks.csv',elements,out)
    calibration=csv_rows(base/'cycle_calibration.csv')
    for r in calibration:
        for key in ('top_timer','processor_cycle','clock','top_reset','core_reset'):
            signal={'top_timer':'timer','processor_cycle':'cycleCnt','top_reset':'reset'}.get(key,key)
            require(int(r[key])==tl.v(signal,int(r['fst_time'])),'formal cycle conversion differs')
    for name,item in load(base/'source_manifest.json').items():
        require(digest(base/'source_reference'/name)==item['content_id'],'explanation source differs: '+name)
    failures=check_failures(rows,meta,image)
    plot(tl,summary,out);vcd(tl,meta,summary,out)
    return dict(mode='extracted_tables_only' if args.tables_only else 'original_fst_read',
                signals=len(meta),changes=len(rows),executions=len(summary),bytes_checked=len(elements),
                invalid_inputs=failures,first_execution=summary[0],fst_info=info)

def main():
    ap=argparse.ArgumentParser(description='Verify the supplied processor results and original waveform.')
    ap.add_argument('--out',type=Path,help='new external directory; default: system temporary directory')
    ap.add_argument('--cluster-evidence',type=Path)
    ap.add_argument('--attachment',type=Path)
    ap.add_argument('--fst',type=Path)
    ap.add_argument('--library',type=Path)
    ap.add_argument('--image',type=Path)
    ap.add_argument('--scratch',type=Path,help='ASCII parent for temporary FST copy')
    ap.add_argument('--tables-only',action='store_true',help='does NOT read original FST and cannot produce LOCAL_DELIVERY_PASS')
    ap.add_argument('--forbid-read-root',type=Path,action='append',default=[],help='fail if this process tries to read an old workspace')
    args=ap.parse_args()
    try:out=new_output(args.out) if args.out else Path(tempfile.mkdtemp(prefix='vdot_delivery_'))
    except (ValueError,OSError) as exc:ap.error(str(exc))
    print('output:',out,flush=True)
    report=dict(ok=False,scope='competition_programs',current_code_verified=False,original_fst_read=False,checks={},failures=[])
    forbidden=[p.resolve() for p in args.forbid_read_root]
    denied=[]
    def audit(event,values):
        if event not in ('open','os.listdir','os.scandir') or not values:return
        raw=values[0]
        if not isinstance(raw,(str,bytes,os.PathLike)):return
        p=Path(os.fsdecode(raw)).resolve()
        if any(p==base or base in p.parents for base in forbidden):
            denied.append(str(p));raise PermissionError('read from forbidden workspace: '+str(p))
    if forbidden:sys.addaudithook(audit)
    report['forbidden_read_roots']=[str(p) for p in forbidden]
    try:
        for module in (('matplotlib','PIL') if args.tables_only else ('cffi','matplotlib','PIL')):
            require(importlib.util.find_spec(module) is not None,'missing Python dependency: '+module+'; install requirements-local-check.txt')
        if not args.tables_only:
            lib=args.library or ROOT/'tools/fsttool'/('fstapi.dll' if os.name=='nt' else 'libfstapi.so')
            require(lib.is_file(),'missing FST reader: '+str(lib)+'; see tools/fsttool/build_fstapi.md')
            if args.fst:require(args.fst.is_file(),'missing original FST: '+str(args.fst))
        validation=args.cluster_evidence
        if validation is None:
            validation=unpack_original(args.attachment,out) if args.attachment else ROOT/'results/cluster/20261019'
        report['checks']['cluster']=check_cluster(validation.resolve());print('64 full-core executions PASS',flush=True)
        report['checks']['current']=check_current();print('supplied functional recordings PASS; current code has not been verified by this command',flush=True)
        report['checks']['wave']=check_wave(args,out,validation.resolve())
        report['original_fst_read']=not args.tables_only
        report['ok']=True
    except (Exception,SystemExit) as exc:
        report['failures'].append(str(exc));print('FAIL:',exc,file=sys.stderr,flush=True)
    finally:
        report['denied_reads']=denied
        report['historical_source_changes']=historical_source_changes()
    (out/'result.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
    success='MATERIALS_CHECK_PASS'
    status=success if report['ok'] and report['original_fst_read'] else ('TABLES_ONLY_PASS' if report['ok'] else 'LOCAL_DELIVERY_FAIL')
    print(status,flush=True)
    return 0 if report['ok'] else 1

if __name__=='__main__':raise SystemExit(main())
