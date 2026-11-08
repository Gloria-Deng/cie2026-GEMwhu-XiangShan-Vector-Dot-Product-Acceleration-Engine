#!/usr/bin/env python3
"""Download the completed experiment with a complete file-content comparison."""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
from pathlib import Path, PurePosixPath
import shlex
import tarfile
import time

import paramiko

REMOTE_CODE = r'''
from pathlib import Path
import hashlib,json,sys,tarfile
root=Path(sys.argv[1]).resolve()
names=['dot_measurements','gemm_measurements','optimized_programs','gemm_programs','hello',
       'materials/results/vdot_wave_20261106_231147_4127407','current_source_check',
       'recovery_source_check','dot_functional','gemm_functional','wave_functional','tasks']
names += [p.name for p in root.iterdir() if p.is_file() and p.suffix in ('.txt','.csv')
          and not p.name.startswith('completed_export_')]
names += ['current_build/'+p.name for p in (root/'current_build').iterdir()
          if p.is_file() and p.suffix in ('.json','.txt','.log')]
files=[]
for name in names:
 p=root/name
 if not p.exists(): raise SystemExit('missing requested data: '+name)
 files.extend([p] if p.is_file() else sorted(x for x in p.rglob('*') if x.is_file()))
files=sorted(set(files))
if any(p.is_symlink() or root not in p.resolve().parents for p in files):
 raise SystemExit('unexpected symbolic link or path')
archive=root/'completed_export_20261104.tar.gz'
manifest=root/'completed_export_20261104_files.csv'
import csv
with manifest.open('w',newline='') as f:
 w=csv.writer(f);w.writerow(['path','bytes','content_digest'])
 for p in files:
  h=hashlib.sha256()
  with p.open('rb') as src:
   for chunk in iter(lambda:src.read(1024*1024),b''):h.update(chunk)
  w.writerow([p.relative_to(root).as_posix(),p.stat().st_size,h.hexdigest()])
with tarfile.open(archive,'w:gz',compresslevel=1) as tar:
 for p in files:tar.add(p,arcname=p.relative_to(root).as_posix(),recursive=False)
 tar.add(manifest,arcname=manifest.name,recursive=False)
h=hashlib.sha256()
with archive.open('rb') as src:
 for chunk in iter(lambda:src.read(1024*1024),b''):h.update(chunk)
print(json.dumps(dict(archive=str(archive),bytes=archive.stat().st_size,
      content_digest=h.hexdigest(),files=len(files),manifest=manifest.name)))
'''


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--host', required=True)
    parser.add_argument('--user', required=True)
    parser.add_argument('--key', required=True, type=Path)
    parser.add_argument('--known-hosts', required=True, type=Path)
    parser.add_argument('--remote', required=True)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    client = paramiko.SSHClient()
    client.load_host_keys(str(args.known_hosts))
    client.connect(args.host, username=args.user, key_filename=str(args.key),
                   look_for_keys=False, allow_agent=False, timeout=20)
    try:
        print('PREPARING_COMPLETED_FILES', flush=True)
        stdin, stdout, stderr = client.exec_command('python3 - ' + shlex.quote(args.remote), timeout=900)
        stdin.write(REMOTE_CODE)
        stdin.channel.shutdown_write()
        raw = stdout.read().decode()
        error = stderr.read().decode()
        if stdout.channel.recv_exit_status():
            raise RuntimeError(error or raw)
        info = json.loads(raw)
        (args.out / 'transfer_info.txt').write_text(raw + '\n', encoding='utf-8')
        archive = args.out / 'completed_export.tar.gz'
        last = [0.0]
        def progress(done, total):
            now = time.monotonic()
            if now - last[0] >= 20 or done == total:
                print(f'DOWNLOADING {done}/{total}', flush=True)
                last[0] = now
        with client.open_sftp() as sftp:
            sftp.get(info['archive'], str(archive), callback=progress)
        if archive.stat().st_size != info['bytes'] or digest(archive) != info['content_digest']:
            raise ValueError('downloaded archive content differs')
        destination = args.out / 'remote'
        destination.mkdir(exist_ok=True)
        with tarfile.open(archive) as tar:
            for member in tar.getmembers():
                name = PurePosixPath(member.name)
                if name.is_absolute() or '..' in name.parts or not member.isfile():
                    raise ValueError('unsupported archive entry: ' + member.name)
            tar.extractall(destination, filter='data')
        with (destination / info['manifest']).open(newline='') as stream:
            rows = list(csv.DictReader(stream))
        for row in rows:
            path = destination / row['path']
            if path.stat().st_size != int(row['bytes']) or digest(path) != row['content_digest']:
                raise ValueError('downloaded file differs: ' + row['path'])
        (args.out / 'download_check.txt').write_text(
            f'DOWNLOAD_PASS files={len(rows)} archive_bytes={info["bytes"]}\n', encoding='utf-8')
        print(f'DOWNLOAD_PASS files={len(rows)} archive_bytes={info["bytes"]}', flush=True)
    finally:
        client.close()


if __name__ == '__main__':
    main()
