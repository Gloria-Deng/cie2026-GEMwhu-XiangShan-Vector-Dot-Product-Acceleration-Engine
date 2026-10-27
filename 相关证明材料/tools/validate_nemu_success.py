#!/usr/bin/env python3





from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--library', type=Path, required=True)
    parser.add_argument('--programs', type=Path, default=ROOT / 'programs')
    parser.add_argument('--out', type=Path, default=ROOT / 'results/reproduced/programs_nemu')
    parser.add_argument('--cc', default=os.environ.get('CC', 'gcc'))
    args = parser.parse_args()
    output = args.out.resolve()
    if ROOT not in output.parents:
        parser.error('--out must be a directory inside the supplied program directory')
    output.mkdir(parents=True, exist_ok=True)
    library = args.library.resolve()
    programs = args.programs.resolve()
    if not library.is_file():
        parser.error('NEMU library does not exist: ' + str(library))
    build = ROOT / 'build/instruction_cosim'
    if not (build / 'cosim_layout.h').is_file():
        parser.error('Run tools/run_nemu_success.py first to create cosim_layout.h')
    env = os.environ.copy()
    if os.name == 'nt':
        env['PATH'] += ';' + str(Path(args.cc).resolve().parent)
    msys = os.name == 'nt' and '/usr/bin/' in args.cc.replace('\\', '/')

    def host_arg(value):
        value = value.as_posix() if isinstance(value, Path) else str(value)
        if msys:
            value = re.sub(r'^(-I)?([A-Za-z]):/',
                           lambda match: (match[1] or '') + '/' + match[2].lower() + '/', value)
        return value

    original = ROOT / 'nemu/cosim/run_image.c'
    source = original.read_text(encoding='utf-8')
    anchor = '  if (init2) init2(OFF_END); else init0();\n'
    if source.count(anchor) != 1:
        raise SystemExit('Cannot locate the image-runner initialization call exactly once')



    addition = (
        '  void (*set_ramsize)(size_t)=dlsym(h,"difftest_set_ramsize");\n'
        '  if (!set_ramsize) return 3;\n'
        '  set_ramsize((size_t)128 * 1024 * 1024);\n')
    generated = build / 'run_image_success.c'
    generated.write_text(source.replace(anchor, addition + anchor), encoding='utf-8')
    exe = build / ('run_image_success.exe' if os.name == 'nt' else 'run_image_success')
    command = [args.cc, '-O2', '-I' + build.as_posix(), '-o', exe, generated]
    if os.name != 'nt':
        command += ['-ldl']
    compile_result = subprocess.run([str(command[0])] + [host_arg(part) for part in command[1:]],
                                    cwd=ROOT, env=env, capture_output=True,
                                    text=True, errors='replace', timeout=120)
    (output / 'compile.txt').write_text(compile_result.stdout + compile_result.stderr, encoding='utf-8')
    if compile_result.returncode:
        raise SystemExit('Image runner did not compile; see ' + str(output / 'compile.txt'))

    manifest_path = programs / 'manifest.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    supplied = manifest['programs']
    if len(supplied) != 32 or len({row['name'] for row in supplied}) != 32:
        raise SystemExit('The supplied program list must contain 32 different programs')
    results = []
    for row in supplied:
        name = row['name']
        if not re.fullmatch(r'[A-Za-z0-9_-]+', name):
            raise SystemExit('Invalid program name: ' + str(name))
        image = (programs / row['image']).resolve()
        if programs not in image.parents or not image.is_file():
            raise SystemExit('Invalid program image: ' + str(image))
        if digest(image) != row['image_sha256']:
            raise SystemExit('Program image differs from the supplied list: ' + name)
        symbols = row['symbols']
        expected = symbols['OK']
        end = 0
        if row['kind'] == 'benchmark':
            expected = symbols['LANDING']
            end = expected + row['landing_bytes']
        command = [exe, library, image, hex(expected), hex(symbols['BAD']), hex(end)]
        result = subprocess.run([str(command[0])] + [host_arg(part) for part in command[1:]], cwd=ROOT, env=env,
                                capture_output=True, text=True, errors='replace', timeout=120)
        text = result.stdout + result.stderr
        path = output / (name + '.txt')
        path.write_text(text, encoding='utf-8')
        passed = result.returncode == 0 and bool(re.search(r'^IMAGE PASS pc=0x[0-9a-f]+ instructions=\d+$',
                                                          result.stdout, re.M))
        print(name + (' PASS' if passed else ' FAILED'), flush=True)
        results.append({'name': name, 'passed': passed, 'return_code': result.returncode,
                        'file': path.relative_to(ROOT).as_posix(), 'content_id': digest(path),
                        'image_content_id': digest(image)})
    good = all(row['passed'] for row in results)
    report = {'passed': good, 'program_count': len(results), 'guest_memory_mib': 128,
              'scope': 'NEMU functional execution of 32 supplied programs',
              'library_content_id': digest(library),
              'program_list_content_id': digest(manifest_path),
              'original_runner_content_id': digest(original),
              'generated_runner_content_id': digest(generated), 'programs': results}
    (output / 'summary.txt').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n',
                                       encoding='utf-8')
    print('NEMU_PROGRAMS_PASS 32/32' if good else 'NEMU_PROGRAMS_FAILED', flush=True)
    return 0 if good else 1


if __name__ == '__main__':
    raise SystemExit(main())
