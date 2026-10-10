#!/usr/bin/env bash
set -euo pipefail

LAB0_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$LAB0_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

usage() {
  cat <<'EOF'
Usage: bash lab0/build.sh <command>

Commands:
  doctor      Check the complete reproduction toolchain and tracked inputs
  compiler    Build the mainline compiler
  test        Build the compiler and run its regression tests
  prep        Run the lab0 experiments and refresh retained evidence
  report      Compile the lab0 report with Tectonic
  reproduce   Run tests, experiments, and report build in sequence
  clean       Remove rebuildable compiler and lab0 artifacts
EOF
}

require_command() {
  local label="$1"
  shift
  local candidate
  for candidate in "$@"; do
    if command -v "$candidate" >/dev/null 2>&1; then
      printf '  OK  %-24s %s\n' "$label" "$(command -v "$candidate")"
      return 0
    fi
  done
  printf '  MISSING  %s (tried: %s)\n' "$label" "$*" >&2
  return 1
}

resolve_riscv_tool() {
  local name="$1"
  local candidate
  if command -v "$name" >/dev/null 2>&1; then
    command -v "$name"
    return 0
  fi
  if [[ -n "${RISCV_TOOLCHAIN:-}" && -x "$RISCV_TOOLCHAIN/bin/$name" ]]; then
    printf '%s\n' "$RISCV_TOOLCHAIN/bin/$name"
    return 0
  fi
  for candidate in "$HOME"/.local/opt/riscv/*/bin/"$name"; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

require_riscv_tool() {
  local name="$1"
  local resolved
  if resolved="$(resolve_riscv_tool "$name")"; then
    printf '  OK  %-24s %s\n' "$name" "$resolved"
  else
    printf '  MISSING  %s (PATH, RISCV_TOOLCHAIN/bin, or ~/.local/opt/riscv/*/bin)\n' "$name" >&2
    return 1
  fi
}

require_tectonic() {
  local tool="${TECTONIC:-}"
  if [[ -z "$tool" ]]; then
    require_command 'Tectonic' tectonic tectonic.exe
  elif command -v "$tool" >/dev/null 2>&1; then
    printf '  OK  %-24s %s\n' Tectonic "$(command -v "$tool")"
  elif [[ -x "$tool" ]]; then
    printf '  OK  %-24s %s\n' Tectonic "$tool"
  else
    printf '  MISSING  Tectonic (install it, add it to PATH, or set TECTONIC)\n' >&2
    return 1
  fi
}

check_environment() {
  local failed=0
  printf 'Checking the lab0 reproduction environment...\n'
  require_command 'C compiler' gcc || failed=1
  require_command 'C++ compiler' g++ c++ || failed=1
  require_command 'CMake' cmake || failed=1
  require_command 'Make' make || failed=1
  require_command 'Python' python3 || failed=1
  require_command 'Clang 15' clang-15 || failed=1
  require_command 'LLVM assembler 15' llvm-as-15 || failed=1
  require_command 'LLVM optimizer 15' opt-15 || failed=1
  require_command 'LLVM code generator 15' llc-15 || failed=1
  require_command 'MLIR optimizer 15' mlir-opt-15 || failed=1
  require_command 'MLIR translator 15' mlir-translate-15 || failed=1
  require_command 'RISC-V QEMU' qemu-riscv64 || failed=1
  require_command 'readelf' readelf || failed=1
  require_command 'nm' nm || failed=1
  require_command 'objdump' objdump || failed=1
  require_command 'size' size || failed=1
  require_riscv_tool riscv64-unknown-elf-gcc || failed=1
  require_riscv_tool riscv64-unknown-elf-ar || failed=1
  require_riscv_tool riscv64-unknown-elf-readelf || failed=1
  require_tectonic || failed=1
  for input in lab0/runtime/lib.tar.gz lab0/report/preparation.tex lab0/report/assets/NKU.png; do
    if [[ -f "$input" ]]; then
      printf '  OK  %-24s %s\n' "$input" "$input"
    else
      printf '  MISSING  %s\n' "$input" >&2
      failed=1
    fi
  done
  if (( failed != 0 )); then
    printf '\nInstall the missing dependencies listed in lab0/README.md, then rerun doctor.\n' >&2
    return 1
  fi
  printf 'Environment check passed.\n'
}

command_name="${1:-help}"
case "$command_name" in
  help|-h|--help) usage ;;
  doctor) check_environment ;;
  compiler) make compiler ;;
  test) make test ;;
  prep) make prep ;;
  report) make report ;;
  reproduce)
    check_environment
    make test
    make prep
    make report
    ;;
  clean) make clean ;;
  *)
    printf 'Unknown command: %s\n\n' "$command_name" >&2
    usage >&2
    exit 2
    ;;
esac
