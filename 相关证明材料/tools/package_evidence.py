#!/usr/bin/env python3

from __future__ import annotations

import argparse
import gzip
import hashlib
import io
import tarfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def normalized(info: tarfile.TarInfo) -> tarfile.TarInfo:

    info.uid = 0
    info.gid = 0
    info.uname = ""
    info.gname = ""
    info.mtime = 0
    return info


def build_archive(source: Path, output: Path) -> tuple[int, int, str]:
    required = [
        source / "validation" / "summary.json",
        source / "validation" / "build_manifest.json",
        source / "validation" / "program_manifest.json",
        source / "validation" / "vadd.fst",
    ]
    missing = [str(path) for path in required if not path.is_file()]
    if missing:
        raise SystemExit("missing evidence inputs: " + ", ".join(missing))

    output.parent.mkdir(parents=True, exist_ok=True)
    if output.exists():
        output.unlink()

    files = sorted(path for path in source.rglob("*") if path.is_file())


    with output.open("wb") as raw:
        with gzip.GzipFile(fileobj=raw, mode="wb", filename="", mtime=0) as gz:
            with tarfile.open(fileobj=gz, mode="w", format=tarfile.PAX_FORMAT) as archive:
                for path in files:
                    arcname = Path("vdot-evidence") / path.relative_to(source)
                    info = normalized(archive.gettarinfo(str(path), arcname=str(arcname)))
                    with path.open("rb") as handle:
                        archive.addfile(info, handle)

    total_bytes = sum(path.stat().st_size for path in files)
    return len(files), total_bytes, sha256(output)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--source",
        type=Path,
        default=ROOT / "results/cluster/20261019/vdot-evidence",
        help="evidence directory containing validation/ and build_logs/",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT.parent / "vdot-evidence.tar.gz",
        help="archive path; keep it outside the Git submission tree",
    )
    args = parser.parse_args()
    count, payload_bytes, digest = build_archive(args.source, args.output)
    print(f"archive={args.output}")
    print(f"files={count}")
    print(f"payload_bytes={payload_bytes}")
    print(f"archive_bytes={args.output.stat().st_size}")
    print(f"sha256={digest}")
    print("validation_layout=validation/{summary.json,build_manifest.json,program_manifest.json,*.log,vadd.fst}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
