#!/usr/bin/env python3
"""Build and verify the preparation experiments using the supplied runtime."""

import hashlib
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import tarfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "build" / "prep"
COMMANDS = []


def run(args, *, stdin=None, capture=None, timeout=60, expected_returncode=0):
    args = [str(arg) for arg in args]
    if "/" not in args[0]:
        args[0] = require(args[0])
    result = subprocess.run(args, cwd=ROOT, input=stdin, text=True,
                            capture_output=True, timeout=timeout)
    COMMANDS.append({"command": shlex.join(args), "returncode": result.returncode,
                     "stdout": result.stdout, "stderr": result.stderr})
    if capture is not None:
        Path(capture).write_text(result.stdout, encoding="utf-8")
    if result.returncode != expected_returncode:
        raise RuntimeError(f"{shlex.join(args)}\n{result.stderr}")
    return result


def require(name):
    resolved = shutil.which(name)
    if not resolved:
        candidates = []
        if os.environ.get("RISCV_TOOLCHAIN"):
            candidates.append(Path(os.environ["RISCV_TOOLCHAIN"]) / "bin" / name)
        candidates.extend(sorted((Path.home() / ".local/opt/riscv").glob(f"*/bin/{name}")))
        resolved = next((str(path) for path in candidates if path.is_file() and os.access(path, os.X_OK)), None)
    if not resolved:
        raise RuntimeError(f"Missing tool: {name}; see README.md")
    return resolved


def extract_runtime():
    destination = OUT / "course_runtime"
    destination.mkdir(parents=True, exist_ok=True)
    names = ["lib/sylib.h", "lib/sylib.c", "lib/libsysy_x86.a",
             "lib/libsysy_riscv.a", "lib/libsysy_aarch.a"]
    with tarfile.open(ROOT / "lib.tar.gz", "r:gz") as archive:
        for name in names:
            member = archive.getmember(name)
            if not member.isfile():
                raise RuntimeError(f"Runtime member is not a regular file: {name}")
            path = destination / name
            path.parent.mkdir(parents=True, exist_ok=True)
            with archive.extractfile(member) as source:
                path.write_bytes(source.read())
    return destination / "lib"


def pipeline(clang, opt):
    out = OUT / "pipeline"
    out.mkdir(exist_ok=True)
    src = ROOT / "prep/01_pipeline/factorial.c"
    run(["gcc", "-E", src, "-o", out / "factorial.i"])
    run(["gcc", "-E", "-DFIRST_FACTOR=3", src, "-o", out / "factorial_macro3.i"])
    run(["gcc", "-S", "-O0", "-g", out / "factorial.i", "-o", out / "factorial_O0.s"])
    run(["gcc", "-S", "-O2", "-g", src, "-o", out / "factorial_O2.s"])
    run(["gcc", "-c", out / "factorial_O0.s", "-o", out / "factorial.o"])
    run(["gcc", out / "factorial.o", "-o", out / "factorial"])
    run(["gcc", "-DFIRST_FACTOR=3", src, "-o", out / "factorial_macro3"])
    run(["gcc", "-static", out / "factorial.o", "-o", out / "factorial_static"])
    run(["gcc", "-O0", f"-fdump-tree-original={out / 'factorial.original'}",
         f"-fdump-tree-gimple={out / 'factorial.gimple'}", "-c", src,
         "-o", out / "factorial_dump.o"])
    tokens = run([clang, "-fsyntax-only", "-Xclang", "-dump-tokens", src])
    (out / "factorial.tokens.txt").write_text(tokens.stderr, encoding="utf-8")
    run([clang, "-fsyntax-only", "-Xclang", "-ast-dump", src],
        capture=out / "factorial.ast.txt")
    diagnostic = run([clang, "-fsyntax-only", ROOT / "prep/01_pipeline/semantic_error.c"],
                     expected_returncode=1)
    if "undeclared identifier" not in diagnostic.stderr:
        raise RuntimeError("Expected an undeclared-identifier diagnostic")
    (out / "semantic_diagnostic.txt").write_text(diagnostic.stderr, encoding="utf-8")
    run([clang, "-S", "-emit-llvm", "-O0", "-Xclang", "-disable-O0-optnone",
         src, "-o", out / "factorial.raw.ll"])
    run([opt, "-S", "-passes=mem2reg", out / "factorial.raw.ll", "-o", out / "factorial.ssa.ll"])
    for name, args in {
        "object_headers.txt": ["readelf", "-h", out / "factorial.o"],
        "object_symbols.txt": ["nm", "-u", out / "factorial.o"],
        "object_relocations.txt": ["readelf", "-r", out / "factorial.o"],
        "object_disassembly.txt": ["objdump", "-dr", out / "factorial.o"],
        "executable_disassembly.txt": ["objdump", "-d", out / "factorial"],
        "executable_headers.txt": ["readelf", "-h", "-l", out / "factorial"],
        "static_headers.txt": ["readelf", "-h", "-l", out / "factorial_static"],
    }.items():
        run(args, capture=out / name)
    for binary, expected in [("factorial", "120\n"), ("factorial_static", "120\n"),
                             ("factorial_macro3", "60\n")]:
        actual = run([out / binary], stdin="5\n")
        if actual.stdout != expected:
            raise RuntimeError(f"Unexpected pipeline result: {binary}: {actual.stdout!r}")
    raw = (out / "factorial.raw.ll").read_text()
    ssa = (out / "factorial.ssa.ll").read_text()
    return {"default_input5": "120", "macro3_input5": "60",
            "raw_allocas": raw.count("alloca "), "ssa_allocas": ssa.count("alloca "),
            "ssa_phis": ssa.count(" phi ")}


def equivalence(clang, llvm_as, opt, llc, runtime, stem="features", case_file="cases.json"):
    out = OUT / "equivalence" / stem
    out.mkdir(parents=True, exist_ok=True)
    src = ROOT / "prep/02_equivalence"
    header = runtime / "sylib.h"
    native_lib = runtime / "libsysy_x86.a"
    rvcc = require("riscv64-unknown-elf-gcc")
    rvar = require("riscv64-unknown-elf-ar")
    rvflags = ["-march=rv64gc", "-mabi=lp64d", "-mcmodel=medany"]
    linkflags = ["-static", "-Wl,--no-relax,-Ttext=0x90000000"]

    # Rebuild the unchanged course source for compatibility with the installed GCC 10.
    run([rvcc, *rvflags, "-fcommon", "-c", runtime / "sylib.c", "-o", out / "sylib_rv64.o"])
    rvlib = out / "libsysy_riscv_compat.a"
    run([rvar, "rcs", rvlib, out / "sylib_rv64.o"])
    run([llvm_as, src / f"{stem}.ll", "-o", out / "features.bc"])
    run([opt, "-passes=verify", "-disable-output", out / "features.bc"])
    run([clang, "-x", "c", "-fcommon", "-include", header, "-c", src / f"{stem}.sy",
         "-o", out / "reference.o"])
    run([clang, "-no-pie", out / "reference.o", native_lib, "-o", out / "source_native"])
    run([clang, "-no-pie", src / f"{stem}.ll", native_lib, "-o", out / "ir_native"])
    run([rvcc, *rvflags, *linkflags, src / f"{stem}_rv64.s", rvlib, "-o", out / "asm_rv64"])
    run([rvcc, *rvflags, "-x", "c", "-fcommon", "-include", header, "-c", src / f"{stem}.sy",
         "-o", out / "source_rv64.o"])
    run([rvcc, *rvflags, *linkflags, out / "source_rv64.o", rvlib, "-o", out / "source_rv64"])
    run([llc, "-mtriple=riscv64-unknown-elf", "-mattr=+m,+a,+f,+d,+c",
         "-target-abi=lp64d", "-code-model=medium", src / f"{stem}.ll",
         "-o", out / "ir_generated_rv64.s"])
    run([rvcc, *rvflags, *linkflags, out / "ir_generated_rv64.s", rvlib,
         "-o", out / "ir_rv64"])
    run(["riscv64-unknown-elf-readelf", "-h", "-A", out / "asm_rv64"],
        capture=out / "asm_rv64_headers.txt")
    cases = json.loads((src / case_file).read_text())
    results = []
    for binary in ["source_native", "ir_native", "asm_rv64", "source_rv64", "ir_rv64"]:
        command = [out / binary]
        if binary.endswith("rv64"):
            command.insert(0, require("qemu-riscv64"))
        for case in cases:
            result = run(command, stdin=case["input"], timeout=10)
            passed = result.stdout == case["output"]
            results.append({"suite": stem, "binary": binary, "input": case["input"],
                            "expected": case["output"], "actual": result.stdout,
                            "stderr": result.stderr, "passed": passed})
            if not passed:
                raise RuntimeError(f"Mismatch in {binary}, input {case['input']!r}: {result.stdout!r}")
    return results


def mlir():
    tool = require("mlir-opt-15")
    translate = require("mlir-translate-15")
    out = OUT / "mlir"
    out.mkdir(exist_ok=True)
    src = ROOT / "prep/03_mlir/vecadd.mlir"
    run([tool, src, "-o", out / "01_structured.mlir"])
    run([tool, out / "01_structured.mlir", "--convert-scf-to-cf", "-o", out / "02_cfg.mlir"])
    run([tool, out / "02_cfg.mlir", "--convert-memref-to-llvm", "--convert-arith-to-llvm",
         "--convert-func-to-llvm", "--convert-cf-to-llvm", "--reconcile-unrealized-casts",
         "-o", out / "03_llvm_dialect.mlir"])
    run([translate, "--mlir-to-llvmir", out / "03_llvm_dialect.mlir", "-o", out / "04_vecadd.ll"])
    run([require("opt-15"), "-passes=verify", "-disable-output", out / "04_vecadd.ll"])
    run([require("clang-15"), out / "04_vecadd.ll", ROOT / "prep/03_mlir/check_vecadd.c",
         "-o", out / "vecadd_native"])
    result = run([out / "vecadd_native"])
    return {"kind": "generic_mlir", "ascend_toolchain_executed": False,
            "native_result": result.stdout.strip(),
            "stages": ["scf/arith/memref", "cf/arith/memref", "llvm dialect", "LLVM IR"]}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    manifest_path = OUT / "manifest.json"
    manifest_path.unlink(missing_ok=True)
    manifest = {"status": "running", "commands": COMMANDS}
    try:
        tools = {name: require(name) for name in
                 ["gcc", "clang-15", "llvm-as-15", "opt-15", "llc-15",
                  "qemu-riscv64", "riscv64-unknown-elf-gcc", "mlir-opt-15"]}
        manifest["tools"] = {name: run([path, "--version"]).stdout.splitlines()[0]
                             for name, path in tools.items()}
        manifest["runtime_archive_sha256"] = hashlib.sha256((ROOT / "lib.tar.gz").read_bytes()).hexdigest()
        runtime = extract_runtime()
        manifest["pipeline"] = pipeline(tools["clang-15"], tools["opt-15"])
        manifest["equivalence"] = equivalence(tools["clang-15"], tools["llvm-as-15"],
                                               tools["opt-15"], tools["llc-15"], runtime)
        manifest["equivalence"].extend(equivalence(tools["clang-15"], tools["llvm-as-15"],
            tools["opt-15"], tools["llc-15"], runtime, "arrays_float", "arrays_float_cases.json"))
        manifest["mlir"] = mlir()
        manifest["status"] = "passed"
        print(f"PASS: {len(manifest['equivalence'])} equivalence checks, pipeline, MLIR lowering")
        print(f"Evidence: {manifest_path.relative_to(ROOT)}")
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        manifest["status"] = "failed"
        manifest["error"] = str(error)
        print(error, file=sys.stderr)
        return 1
    finally:
        manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())

