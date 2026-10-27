#!/usr/bin/env python3

import argparse
import json
from pathlib import Path

NAME = 'build_configuration.json'
OPT_FAST = '-O2 -fno-tree-slp-vectorize'


def positive(value):
    if not value.isdecimal() or int(value) < 1:
        raise argparse.ArgumentTypeError('compile jobs must be a positive integer')
    return str(int(value))


def unknown_configuration():
    return {name: None for name in ('config', 'cores', 'JVM_XMX', 'compile_jobs',
                                    'nemu_compile_jobs', 'emu_compile_jobs',
                                    'trace', 'opt_fast')} | {'compile_steps': []}


def load_configuration(run):
    path = Path(run) / NAME
    if not path.is_file():
        return unknown_configuration()
    data = json.loads(path.read_text(encoding='utf-8'))
    if not isinstance(data, dict) or not isinstance(data.get('compile_steps'), list):
        raise ValueError('invalid saved build configuration: ' + str(path))
    required = unknown_configuration().keys()
    if not required <= data.keys():
        raise ValueError('incomplete saved build configuration: ' + str(path))
    return data


def save_configuration(run, data):
    path = Path(run) / NAME
    path.write_text(json.dumps(data, indent=2) + '\n', encoding='utf-8')


def record_full(run, java_heap, jobs, nemu_jobs):
    path = Path(run) / NAME
    if path.exists():
        raise ValueError('build configuration already exists: ' + str(path))
    jobs, nemu_jobs = positive(str(jobs)), positive(str(nemu_jobs))
    if not java_heap or java_heap.isspace():
        raise ValueError('Java heap must be specified')
    data = {'config': 'KunminghuV2Config', 'cores': 1, 'JVM_XMX': java_heap,
            'compile_jobs': jobs, 'nemu_compile_jobs': nemu_jobs,
            'emu_compile_jobs': jobs, 'trace': 'fst', 'opt_fast': OPT_FAST,
            'compile_steps': [{'kind': 'full', 'JVM_XMX': java_heap,
                               'compile_jobs': jobs, 'nemu_compile_jobs': nemu_jobs,
                               'emu_compile_jobs': jobs}]}
    save_configuration(run, data)
    return data


def record_resume(run, jobs):
    jobs = positive(str(jobs))
    data = load_configuration(run)
    data['emu_compile_jobs'] = jobs
    data['opt_fast'] = OPT_FAST
    data['compile_steps'].append({'kind': 'resume', 'emu_compile_jobs': jobs,
                                  'opt_fast': OPT_FAST, 'opt_slow': '-O0'})
    save_configuration(run, data)
    return data


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--run-root', type=Path, required=True)
    modes = parser.add_subparsers(dest='mode', required=True)
    full = modes.add_parser('full')
    full.add_argument('--java-heap', required=True)
    full.add_argument('--jobs', required=True, type=positive)
    full.add_argument('--nemu-jobs', required=True, type=positive)
    resume = modes.add_parser('resume')
    resume.add_argument('--jobs', required=True, type=positive)
    args = parser.parse_args()
    if args.mode == 'full':
        record_full(args.run_root, args.java_heap, args.jobs, args.nemu_jobs)
    else:
        record_resume(args.run_root, args.jobs)


if __name__ == '__main__':
    main()
