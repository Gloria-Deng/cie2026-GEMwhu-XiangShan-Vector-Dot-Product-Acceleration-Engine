import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import csv
from datetime import datetime, timezone
import hashlib
import os
from pathlib import Path
import re
import statistics
import subprocess
import time

import benchmark

ROOT = Path(__file__).resolve().parent
CASES = ((3, 5, 13), (16, 16, 16), (32, 32, 32))
GRID = 8


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_rows(path):
    with path.open(encoding='utf-8-sig', newline='') as stream:
        return list(csv.DictReader(stream))


def generate(args):
    args.out.mkdir(parents=True, exist_ok=False)
    header = (ROOT / 'include/vdot_gemm.h').read_text(encoding='utf-8')
    implementation = (ROOT / 'src/vdot_gemm.c').read_text(encoding='utf-8')
    implementation = implementation.replace('#include "vdot_gemm.h"', header)
    rows = []
    for m, n, k in CASES:
        a = [((i * 17 + 11) % 256) - 128 for i in range(m * k)]
        b = [((i * 13 + 97) % 256) - 128 for i in range(k * n)]
        expected = [sum(a[i*k+q] * b[q*n+j] for q in range(k)) for i in range(m) for j in range(n)]
        values = lambda data: '{' + ','.join(map(str, data)) + '}'
        for method in (0, 1):
            for scope in ('compute', 'pack_compute'):
                name = f'api_{m}x{n}x{k}_method{method}_{scope}'
                source = '#define VDOT_GEMM_ASM 1\n' + implementation + f'''
enum {{ M={m}, N={n}, K={k}, STRIDE=(K+7)&~7 }};
static const int8_t a[M*K] = {values(a)};
static const int8_t b[K*N] = {values(b)};
static const int32_t expected[M*N] = {values(expected)};
static int8_t packed[N*STRIDE];
static int32_t c[M*N];
extern char LANDING_BASE[];
__attribute__((noinline,used)) void BAD(void) {{ for (;;) __asm__ volatile(""); }}
static inline uint64_t ticks(void) {{ uint64_t v; __asm__ volatile("fence rw,rw\\n\\trdcycle %0\\n\\tfence rw,rw" : "=r"(v) : : "memory"); return v; }}
void run(void) {{
    {"if (vdot_gemm_pack_b(b,N,K,packed,sizeof packed)) BAD();" if scope == 'compute' else ''}
    uint64_t start = ticks();
    {"if (vdot_gemm_pack_b(b,N,K,packed,sizeof packed)) BAD();" if scope == 'pack_compute' else ''}
    int status = vdot_gemm_packed(a,packed,c,M,N,K,(enum vdot_gemm_method){method});
    uint64_t delta = ticks() - start;
    if (status || delta >= 65536ULL*8) BAD();
    for (size_t i=0; i<M*N; i++) if (c[i] != expected[i]) BAD();
    void (*finish)(void) = (void *)(LANDING_BASE + ((delta/8)*4));
    finish();
}}
'''
                path = args.out / (name + '.c')
                path.write_text(source, encoding='utf-8')
                rows.append(dict(name=name, M=m, N=n, K=k, impl=method, packed=1,
                                 scope=scope, source=path.name, content=digest(path),
                                 api_content=digest(ROOT / 'src/vdot_gemm.c'),
                                 header_content=digest(ROOT / 'include/vdot_gemm.h'),
                                 cycle_grid=GRID, max_cycles=250000 if m == 32 else 100000))
    benchmark.write_rows(args.out / 'programs.csv', rows)
    benchmark.build(argparse.Namespace(programs=args.out, prefix=args.prefix))
    for row in read_rows(args.out / 'compiled.csv'):
        text = benchmark.command([benchmark.tool(args.prefix, 'objdump'), '-d', args.out / (row['name'] + '.elf')])
        (args.out / (row['name'] + '.asm')).write_text(text, encoding='utf-8')
        if not re.search(r'\b(?:b38cad57|b38ca257)\b', text) or 'rdcycle' not in text or 'vmv.x.s' not in text:
            raise ValueError('required instructions missing: ' + row['name'])
    print('API_PROGRAMS_PASS count=' + str(len(rows)))


def functional(args):
    rows = read_rows(args.programs / 'compiled.csv')
    benchmark.validate_programs(args.programs, rows)
    args.out.mkdir(parents=True, exist_ok=False)
    results = []
    env = os.environ.copy()
    if os.name == 'nt':
        env['PATH'] = 'E:/msys64/usr/bin;E:/msys64/ucrt64/bin;' + env.get('PATH', '')
    def argument(path):
        value = path.resolve().as_posix()
        return re.sub(r'^([A-Za-z]):/', lambda match: '/' + match[1].lower() + '/', value) if os.name == 'nt' else value
    for row in rows:
        base = int(row['LANDING_BASE'], 0)
        argv = [str(args.runner.resolve()), argument(args.library), argument(args.programs / (row['name'] + '.bin')),
                hex(base), row['BAD'], hex(base + 65536*4)]
        result = subprocess.run(argv, capture_output=True, text=True, errors='replace', timeout=120, env=env)
        output = result.stdout + result.stderr
        (args.out / (row['name'] + '.txt')).write_text(output, encoding='utf-8')
        valid = result.returncode == 0 and 'IMAGE PASS' in output
        results.append(dict(name=row['name'], status='PASS' if valid else 'FAIL'))
        benchmark.write_rows(args.out / 'checks.csv', results)
        if not valid:
            raise ValueError('API functional execution failed: ' + row['name'])
    print('API_FUNCTIONAL_PASS count=' + str(len(results)))


def execute(args):
    if args.repeat < 3 or not 1 <= args.workers <= 16 or args.seconds_limit <= 0:
        raise ValueError('invalid resource limits')
    rows = read_rows(args.programs / 'compiled.csv')
    benchmark.validate_programs(args.programs, rows)
    args.out.mkdir(parents=True, exist_ok=False)
    benchmark.write_rows(args.out / 'executables.csv',
                         [dict(role=role, path=str(path), content=digest(path)) for role, path in (('emu', args.emu), ('NEMU', args.library))])
    jobs = list(enumerate(benchmark.execution_order(rows, args.repeat)))

    def one(job):
        order, (repeat, direction, row) = job
        benchmark.validate_programs(args.programs, [row])
        path = args.out / (row['name'] + f'_r{repeat}.txt')
        began = time.monotonic()
        started = datetime.now(timezone.utc).isoformat()
        argv = [str(args.emu), '-i', str(args.programs / (row['name'] + '.bin')),
                '--diff=' + str(args.library), '--ram-size=256MB', '--no-squash', '-s', '1', '-C', row['max_cycles']]
        code = -1
        try:
            with path.open('w', encoding='utf-8') as output:
                process = subprocess.run(argv, stdout=output, stderr=subprocess.STDOUT, timeout=args.seconds_limit)
            code = process.returncode
        except (OSError, subprocess.TimeoutExpired) as error:
            with path.open('a', encoding='utf-8') as output:
                output.write('\n' + str(error))
        base = int(row['LANDING_BASE'], 0)
        valid, pc = benchmark.valid_execution(path.read_text(encoding='utf-8', errors='replace'), code, base)
        result = dict(name=row['name'], M=row['M'], N=row['N'], K=row['K'], method=row['impl'], scope=row['scope'],
                      repeat=repeat, direction=direction, submission_order=order, started_utc=started,
                      seconds=round(time.monotonic()-began, 3), status='PASS' if valid else 'FAIL',
                      cycles_lower=((pc-base)//4)*GRID if valid else '', cycle_grid=GRID,
                      terminal_pc=hex(pc) if pc >= 0 else '', max_cycles=row['max_cycles'], output=path.name,
                      output_content=digest(path), image_content=row['image_content'], exit_code=code)
        print(row['name'], repeat, result['status'], flush=True)
        return result

    results = []
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        pending = [pool.submit(one, job) for job in jobs]
        for future in as_completed(pending):
            results.append(future.result())
            results.sort(key=lambda row: row['submission_order'])
            temporary = args.out / 'measurements.partial.csv'
            benchmark.write_rows(temporary, results)
            temporary.replace(args.out / 'measurements.csv')
    analyze(args.out, args.out / 'analysis', args.repeat)
    if not all(row['status'] == 'PASS' for row in results):
        raise ValueError('API measurement failed; no automatic retry')


def analyze(results, out, repeat):
    rows = read_rows(results / 'measurements.csv')
    out.mkdir(parents=True, exist_ok=False)
    summary = []
    for m, n, k in CASES:
        for method in (0, 1):
            for scope in ('compute', 'pack_compute'):
                selected = [r for r in rows if (int(r['M']), int(r['N']), int(r['K']), int(r['method']), r['scope']) == (m,n,k,method,scope)]
                complete = (len(selected) == repeat and {int(r['repeat']) for r in selected} == set(range(repeat))
                            and all(r['status'] == 'PASS' for r in selected))
                values = [int(r['cycles_lower']) for r in selected if r['status'] == 'PASS']
                summary.append(dict(M=m,N=n,K=k,method=method,scope=scope,status='PASS' if complete else 'INCOMPLETE',
                                    successful=len(values),expected=repeat,minimum=min(values) if complete else '',
                                    median=statistics.median(values) if complete else '',maximum=max(values) if complete else '',cycle_grid=GRID))
    benchmark.write_rows(out / 'summary.csv', summary)
    text = ['# 通用矩阵接口实际周期', '', '计时单位为8周期，读数是对应区间下界。compute在计时前整理B；pack_compute包括整理B。两者均包含接口检查、计算及写出C，计时边界的内存顺序控制也计入；不包含输入生成、逐元素结果检查、启动及结束等待。每项独立启动，不能将两种范围相减当成准确的数据整理成本。', '', '| M×N×K | 方法 | 范围 | 完成次数 | 周期中位数 | 状态 |', '| --- | --- | --- | ---: | ---: | --- |']
    for row in summary:
        text.append('| {M}×{N}×{K} | {method} | {scope} | {successful} | {median} | {status} |'.format(**row))
    (out / 'report.md').write_text('\n'.join(text)+'\n', encoding='utf-8')
    print('API_ANALYSIS_COMPLETE', out)


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_subparsers(dest='mode', required=True)
    gen = modes.add_parser('generate')
    gen.add_argument('--out', type=Path, required=True)
    gen.add_argument('--prefix', default='riscv64-unknown-elf-')
    for mode in ('functional', 'execute'):
        command = modes.add_parser(mode)
        command.add_argument('--programs', type=Path, required=True)
        command.add_argument('--library', type=Path, required=True)
        command.add_argument('--out', type=Path, required=True)
        if mode == 'functional':
            command.add_argument('--runner', type=Path, required=True)
        else:
            command.add_argument('--emu', type=Path, required=True)
            command.add_argument('--repeat', type=int, default=3)
            command.add_argument('--workers', type=int, default=16)
            command.add_argument('--seconds-limit', type=float, default=7200)
    analysis = modes.add_parser('analyze')
    analysis.add_argument('--results', type=Path, required=True)
    analysis.add_argument('--out', type=Path, required=True)
    analysis.add_argument('--repeat', type=int, default=3)
    args = parser.parse_args()
    if args.mode == 'analyze':
        analyze(args.results, args.out, args.repeat)
    else:
        globals()[args.mode](args)


if __name__ == '__main__':
    main()
