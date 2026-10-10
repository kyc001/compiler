#!/usr/bin/env python3
"""Remove only known rebuildable directories; retain PDFs and report evidence."""

from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[2]
TARGETS = ("build", "lab0/build", "lab0/scripts/__pycache__", "tests/__pycache__")


def main():
    for relative in TARGETS:
        target = ROOT / relative
        if target.is_symlink() or not target.resolve().is_relative_to(ROOT):
            raise RuntimeError(f"Refusing to clean outside the project: {target}")
        if target.exists():
            if not target.is_dir():
                raise RuntimeError(f"Expected a generated directory: {target}")
            shutil.rmtree(target)
            print(f"Removed {relative}/")
    print("Kept sources, local course materials, lab0/report/evidence/ and lab0/output/pdf/.")


if __name__ == "__main__":
    main()
