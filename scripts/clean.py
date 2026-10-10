#!/usr/bin/env python3
"""Remove only known rebuildable directories; retain PDFs and report evidence."""

from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]
TARGETS = ("build", "scripts/__pycache__", "tests/__pycache__")


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
    print("Kept sources, course materials, report/evidence/ and output/pdf/.")


if __name__ == "__main__":
    main()
