import argparse
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description="Build the four current measurement and waveform figures.")
    parser.add_argument("--out", type=Path, default=Path(__file__).resolve().parent / "figures")
    args = parser.parse_args()
    import build_current_figures as current
    current.OUT = args.out.resolve()
    current.OUT.mkdir(parents=True, exist_ok=True)
    current.main()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
