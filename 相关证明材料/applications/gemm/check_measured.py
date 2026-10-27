import argparse
import csv
from datetime import datetime, timedelta, timezone
import hashlib
import re
import statistics
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CASES = ((3,5,13),(16,16,16),(32,32,32))
SCOPES = ('compute','pack_compute')


def read_rows(path):
    with path.open(encoding='utf-8-sig',newline='') as stream:
        return list(csv.DictReader(stream))


def write_rows(path, rows):
    with path.open('w',encoding='utf-8',newline='') as stream:
        writer = csv.DictWriter(stream,fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate_programs(package):
    compiled = read_rows(package/'programs/compiled.csv')
    expected = {(m,n,k,method,scope) for m,n,k in CASES for method in (0,1) for scope in SCOPES}
    keys = [(int(row['M']),int(row['N']),int(row['K']),int(row['impl']),row['scope']) for row in compiled]
    require(len(compiled)==12 and len(set(keys))==12 and set(keys)==expected,'program coverage is incomplete')
    inputs = {row['path']:row['content'] for row in read_rows(package/'task/inputs.csv')}
    source_files = ('api_benchmark.py','benchmark.py','src/vdot_gemm.c','include/vdot_gemm.h','baremetal/start.S','baremetal/landing.S','baremetal/link_landing.ld')
    source_rows = []
    for relative in source_files:
        archived = package/'implementation'/relative
        expected_content = inputs['applications/gemm/'+relative]
        require(digest(archived)==expected_content,'recorded implementation does not match the execution inputs: '+relative)
        current = ROOT/relative
        require(digest(current)==expected_content,'current implementation differs from the measured implementation: '+relative)
        source_rows.append(dict(source=relative,recorded_input='MATCH',current_file='MATCH'))
    header = (package/'implementation/include/vdot_gemm.h').read_text(encoding='utf-8')
    code = (package/'implementation/src/vdot_gemm.c').read_text(encoding='utf-8').replace('#include "vdot_gemm.h"',header)
    prefix = '#define VDOT_GEMM_ASM 1\n'+code
    for row in compiled:
        name = row['name']
        m,n,k,method,scope = int(row['M']),int(row['N']),int(row['K']),int(row['impl']),row['scope']
        require(name==f'api_{m}x{n}x{k}_method{method}_{scope}','program name and parameters differ: '+name)
        require(int(row['cycle_grid'])==8 and int(row['packed'])==1,'unexpected program timing or layout: '+name)
        require(int(row['max_cycles'])==(250000 if m==32 else 100000),'unexpected execution limit: '+name)
        source = package/'programs'/row['source']
        content = digest(source)
        require(content==row['content']==inputs['api_programs/'+row['source']],'measured C source content differs: '+name)
        require(row['api_content']==inputs['applications/gemm/src/vdot_gemm.c'] and row['header_content']==inputs['applications/gemm/include/vdot_gemm.h'],'program was generated from another interface version: '+name)
        text = source.read_text(encoding='utf-8')
        require(text.startswith(prefix),'embedded interface differs from the archived implementation: '+name)
        arrays = {}
        for variable,kind,extent in [('a','int8_t',r'M\*K'),('b','int8_t',r'K\*N'),('expected','int32_t',r'M\*N')]:
            match = re.search(r'static const '+kind+' '+variable+r'\['+extent+r'\] = \{([^{}]+)\};',text)
            require(match is not None,'constant input or expected output is missing: '+name)
            arrays[variable] = [int(value) for value in match.group(1).split(',')]
        require(len(arrays['a'])==m*k and len(arrays['b'])==k*n and len(arrays['expected'])==m*n,'input or expected output dimensions differ: '+name)
        expected_output = [sum(arrays['a'][i*k+q]*arrays['b'][q*n+j] for q in range(k)) for i in range(m) for j in range(n)]
        require(expected_output==arrays['expected'],'saved expected outputs differ from independent computation: '+name)
        wrapper = text.rsplit('void run(void) {',1)[-1]
        pack = wrapper.find('if (vdot_gemm_pack_b(b,N,K,packed,sizeof packed)) BAD();')
        start = wrapper.find('uint64_t start = ticks();')
        call = wrapper.find(f'vdot_gemm_packed(a,packed,c,M,N,K,(enum vdot_gemm_method){method})')
        end = wrapper.find('uint64_t delta = ticks() - start;')
        correct = wrapper.find('for (size_t i=0; i<M*N; i++) if (c[i] != expected[i]) BAD();')
        require(min(pack,start,call,end,correct)>=0 and call<end<correct,'timing or complete output check is missing: '+name)
        require((pack<start<call if scope=='compute' else start<pack<call),'B preparation is in the wrong timing interval: '+name)
        require('delta >= 65536ULL*8' in wrapper and '((delta/8)*4)' in wrapper,'program timing resolution differs: '+name)
        for key in ('image_content','elf_content'):
            require(bool(re.fullmatch('[0-9a-f]{64}',row[key])),'missing compiled program identity: '+name)
    return compiled,source_rows


def validate_runs(rows, compiled):
    by_name = {row['name']:row for row in compiled}
    expected = {(name,repeat) for name in by_name for repeat in range(3)}
    actual = [(row['name'],int(row['repeat'])) for row in rows]
    require(len(rows)==36 and len(set(actual))==36 and set(actual)==expected,'36 executions with three distinct repeats per program are required')
    require({int(row['submission_order']) for row in rows}==set(range(36)),'submission sequence is incomplete or duplicated')
    ordered = sorted(rows,key=lambda row:int(row['submission_order']))
    names = list(by_name)
    require([row['name'] for row in ordered]==names+list(reversed(names))+names,'forward/reverse submission sequence differs')
    for row in rows:
        program = by_name[row['name']]
        for key in ('M','N','K','scope','max_cycles'):
            require(row[key]==program[key],'execution parameters differ from the compiled program: '+row['name'])
        require(int(row['method'])==int(program['impl']),'method label differs from the compiled program: '+row['name'])
        require(row['status']=='PASS' and int(row['exit_code'])==0,'an execution did not succeed: '+row['name'])
        require(row['image_content']==program['image_content'],'execution used a different image: '+row['name'])
        require(row['direction']==('reverse' if int(row['repeat'])==1 else 'forward'),'submission direction differs: '+row['name'])
        require(row['output']==row['name']+'_r'+row['repeat']+'.txt','original output name differs: '+row['name'])
        require(bool(re.fullmatch('[0-9a-f]{64}',row['output_content'])),'missing original output identity: '+row['name'])
        require(0<float(row['seconds'])<=7201,'unexpected execution duration: '+row['name'])
        require(datetime.fromisoformat(row['started_utc']).utcoffset()==timedelta(0),'execution timestamp is not UTC')
        value,grid,pc,base = int(row['cycles_lower']),int(row['cycle_grid']),int(row['terminal_pc'],0),int(program['LANDING_BASE'],0)
        require(grid==8 and value>=0 and value%grid==0,'unexpected timing resolution: '+row['name'])
        require(base<=pc<base+65536*4 and (pc-base)%4==0 and ((pc-base)//4)*grid==value,'terminal position and cycle value differ: '+row['name'])
    groups = {}
    for row in rows:
        key = (int(row['M']),int(row['N']),int(row['K']),int(row['method']),row['scope'])
        groups.setdefault(key,[]).append(int(row['cycles_lower']))
    return [dict(M=m,N=n,K=k,method=method,scope=scope,status='PASS',successful=3,expected=3,
                 minimum=min(groups[(m,n,k,method,scope)]),median=statistics.median(groups[(m,n,k,method,scope)]),
                 maximum=max(groups[(m,n,k,method,scope)]),cycle_grid=8)
            for m,n,k in CASES for method in (0,1) for scope in SCOPES]


def compare_summary(recorded, calculated):
    expected = {(row['M'],row['N'],row['K'],row['method'],row['scope']):row for row in calculated}
    seen = set()
    for row in recorded:
        key = (int(row['M']),int(row['N']),int(row['K']),int(row['method']),row['scope'])
        require(key in expected and key not in seen,'summary contains an unknown or duplicate group')
        seen.add(key)
        for name in ('successful','expected','minimum','median','maximum','cycle_grid'):
            require(float(row[name])==expected[key][name],'summary value differs: '+str(key)+' '+name)
        require(row['status']==expected[key]['status'],'summary status differs: '+str(key))
    require(seen==set(expected),'summary is incomplete')


def method_comparison(summary):
    values = {(r['M'],r['N'],r['K'],r['method'],r['scope']):r['median'] for r in summary}
    rows = []
    for m,n,k in CASES:
        for scope in SCOPES:
            direct,four = (values[(m,n,k,method,scope)] for method in (0,1))
            rows.append(dict(M=m,N=n,K=k,scope=scope,direct_cycles=direct,four_column_cycles=four,
                             direct_over_four=f'{direct/four:.12f}',four_cycle_change_percent=f'{(four/direct-1)*100:.12f}',
                             four_cycle_reduction_percent=f'{(1-four/direct)*100:.12f}',
                             ratio_minimum=f'{direct/(four+7):.12f}',ratio_maximum=f'{(direct+7)/four:.12f}',cycle_grid=8))
    return rows


def verify_remote_review(package, rows):
    review = read_rows(package/'task/completion_checks.csv')
    by_name = {row['check']:row for row in review}
    needed = {'source_files_match_execution_inputs':98,'api_programs_and_repetitions_complete':36,'api_all_groups_have_three_passes':12}
    for row in rows:
        stem = Path(row['output']).stem
        needed['api_output_'+stem] = 1
        needed['api_result_'+stem] = 1
    for name,count in needed.items():
        require(name in by_name and by_name[name]['status']=='PASS' and int(by_name[name]['count'])==count,'remote completed-file review is missing or failed: '+name)
    tasks = {row['task']:row['exit_code'] for row in read_rows(package/'task/task_status.csv')}
    require(tasks.get('api')=='0','recorded API task did not complete successfully')
    functional = read_rows(package/'task/functional_checks.csv')
    require(len(functional)==12 and all(row['status']=='PASS' for row in functional) and {row['name'] for row in functional}=={row['name'] for row in rows},'recorded functional executions are incomplete')
    state = next((line.split('|') for line in (package/'task/status.txt').read_text(encoding='utf-8').splitlines() if line.startswith('3772882|')),None)
    require(state and state[1]=='COMPLETED' and state[-1]=='0:0' and state[5]=='16','recorded scheduler state is not completed successfully on 16 CPUs')
    local = timezone(timedelta(hours=8))
    began = datetime.fromisoformat(state[2]).replace(tzinfo=local)
    ended = datetime.fromisoformat(state[3]).replace(tzinfo=local)
    for row in rows:
        started = datetime.fromisoformat(row['started_utc'])
        require(began<=started and started+timedelta(seconds=float(row['seconds']))<=ended,'execution timestamp lies outside the completed job')
    return len(needed)


def check(package, out):
    records = []
    origins = read_rows(package/'origin_files.csv')
    for item in origins:
        path = package/item['path']
        require(path.stat().st_size==int(item['bytes']) and digest(path)==item['content'],'recorded file changed: '+item['path'])
    records.append(dict(check='recorded_local_files',status='PASS',detail=f'files={len(origins)}'))
    compiled,source_rows = validate_programs(package)
    write_rows(out/'source_correspondence.csv',source_rows)
    records.append(dict(check='measured_source_correspondence',status='PASS',detail='current_interface=exact recorded_programs=12'))
    rows = read_rows(package/'measurements.csv')
    summary = validate_runs(rows,compiled)
    compare_summary(read_rows(package/'summary.csv'),summary)
    write_rows(out/'summary.csv',summary)
    comparison = method_comparison(summary)
    write_rows(out/'method_comparison.csv',comparison)
    recorded_comparison = package/'method_comparison.csv'
    if recorded_comparison.is_file():
        require(read_rows(recorded_comparison)==[{key:str(value) for key,value in row.items()} for row in comparison],'recorded method comparison differs from recomputation')
    records.append(dict(check='measurements_recomputed',status='PASS',detail='programs=12 executions=36 repeats=3 groups=12 grid=8'))
    remote_count = verify_remote_review(package,rows)
    records.append(dict(check='remote_completion_record',status='PASS',detail=f'checks={remote_count}; original_outputs_read_locally=0'))
    report = ['# 通用矩阵接口测量复算', '', '任务3772882已完成。当前通用接口与执行时保存的源码逐字节一致。12个程序、每个三次，共36次成功记录；本地复算12组统计全部与取回结果一致。', '', '每个周期读数代表从该整数到其加7的区间。以下比值仅比较直接取回和四列方法，不比较标准RVV。原始执行文本仍在超算目录；本地读取取回的逐次结果、程序清单及在超算完成的核对记录，没有直接读取那些原始文本。', '', '| M×N×K | 范围 | 直接取回周期 | 四列周期 | 直接÷四列 | 四列周期变化 |', '| --- | --- | ---: | ---: | ---: | ---: |']
    for row in comparison:
        label = '仅计算' if row['scope']=='compute' else '含B整理'
        report.append(f"| {row['M']}×{row['N']}×{row['K']} | {label} | {row['direct_cycles']} | {row['four_column_cycles']} | {float(row['direct_over_four']):.6f} | {float(row['four_cycle_change_percent']):+.4f}% |")
    report += ['', '三个重复按正序、倒序、正序安排提交，最多16个进程并发；提交次序不代表实际串行执行次序。两种计时区间分别独立执行，不能将周期差当成准确的B整理成本。', '']
    (out/'report.md').write_text('\n'.join(report),encoding='utf-8')
    write_rows(out/'checks.csv',records)
    return records


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--package',type=Path,default=ROOT/'measured_20261026')
    args = parser.parse_args()
    args.out.mkdir(parents=True,exist_ok=False)
    try:
        records = check(args.package,args.out)
    except Exception as error:
        write_rows(args.out/'checks.csv',[dict(check='measured_gemm',status='FAIL',detail=str(error))])
        print(str(error),file=sys.stderr)
        return 1
    print('MEASURED_GEMM_PASS programs=12 executions=36 groups=12 original_outputs_read_locally=0')
    for row in records:
        print(row['check'],row['status'],row['detail'])
    return 0


if __name__=='__main__':
    raise SystemExit(main())
