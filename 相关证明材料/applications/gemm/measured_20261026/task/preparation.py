import argparse
import csv
import hashlib
import os
from pathlib import Path
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('mode', choices=['prepare'])
    parser.add_argument('--task-root', type=Path, required=True)
    args = parser.parse_args()
    root = args.task_root.resolve()
    source = Path('/project/chensiyuan/vdot/run_20261016_m/NEMU')
    library = source / 'build/riscv64-nemu-interpreter-so'
    allocated = len(os.sched_getaffinity(0))
    if allocated != 16:
        raise ValueError(f'expected 16 allocated CPUs, got {allocated}')
    (root / 'resources.txt').write_text(
        f'allocated_cpus={allocated}\n' + Path('/proc/meminfo').read_text() + '\n' +
        subprocess.check_output(['df', '-h', str(root)], text=True), encoding='utf-8')

    def run(name, command):
        with (root / (name + '.txt')).open('w', encoding='utf-8') as stream:
            subprocess.run([sys.executable, '-B', *map(str, command)], cwd=root,
                           stdout=stream, stderr=subprocess.STDOUT, check=True)
        print(name, 'PASS', flush=True)

    run('reference_build', ['experiments/throughput/build_reference.py', '--nemu-source', source, '--out', root / 'reference_runner'])
    runner = root / 'reference_runner/reference_runner'
    run('throughput_build', ['experiments/throughput/study.py', 'generate', '--out', root / 'throughput_programs'])
    run('throughput_functional', ['experiments/throughput/study.py', 'functional', '--programs', root / 'throughput_programs',
                                 '--runner', runner, '--library', library, '--out', root / 'throughput_functional'])
    run('api_build', ['applications/gemm/api_benchmark.py', 'generate', '--out', root / 'api_programs'])
    run('api_functional', ['applications/gemm/api_benchmark.py', 'functional', '--programs', root / 'api_programs',
                          '--runner', runner, '--library', library, '--out', root / 'api_functional'])
    files = [path for path in root.rglob('*') if path.is_file() and path.suffix in ('.py', '.c', '.h', '.S', '.ld', '.sbatch')]
    with (root / 'inputs.csv').open('w', newline='', encoding='utf-8') as stream:
        writer = csv.writer(stream)
        writer.writerow(['path', 'content'])
        writer.writerows((str(path.relative_to(root)), hashlib.sha256(path.read_bytes()).hexdigest()) for path in sorted(files))
    print('PREPARATION_COMPLETE programs=84 expected_measurements=252', flush=True)


if __name__ == '__main__':
    main()
