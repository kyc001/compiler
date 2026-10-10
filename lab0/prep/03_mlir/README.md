# MLIR and AscendNPU IR exploration

`vecadd.mlir` is an original generic MLIR exercise for four float elements.
The preparation runner executes:

1. `scf / arith / memref` IR verification.
2. `convert-scf-to-cf`, exposing explicit CFG branches.
3. MemRef, Arith, Func and CF conversion to the LLVM dialect.
4. LLVM IR translation, verification and native compilation.
5. `check_vecadd.c`, checking every output element through the generated C interface.

Expected native results: baseline `1.5 4.5 7.5 10.5`; signed and in-place
`-1 -2 0 -0.125`. All 12 elements are checked, with a nonzero exit on mismatch.
The memref C descriptor contains allocated/aligned pointers, offset, size and stride.
The static identity-layout type requires offset 0, size 4, stride 1; the presence
of descriptor fields does not permit arbitrary layouts. In-place output exactly
aliases the first input; partially overlapping buffers are outside this test.

`ascend_vecadd.mlir` is attributed reference code from the official example:
https://ascendnpu-ir.gitcode.com/zh_cn/sources/introduction/quick_start/examples_zh.html

This reference uses HIVM GM/UB address spaces and HACC device-entry attributes.
It cannot be compiled with the upstream `mlir-opt-15`, which does not register
these custom dialects. BishengIR/CANN execution has not been performed here.
With a configured BishengIR/CANN environment, the documented compilation is:

```sh
bishengir-compile lab0/prep/03_mlir/ascend_vecadd.mlir -enable-hivm-compile -o kernel.o
```

The official host program then registers `kernel.o`, launches the kernel through
CANN and copies the result from device to host. Hardware execution is separate
from IR lowering. Inspect `bishengir-opt --help` for the installed version's
pass names; the classroom slide snippets are explanatory illustrations.

The 2026-10-10 review also checked the official architecture page:
https://ascendnpu-ir.gitcode.com/zh_cn/sources/introduction/architecture_zh.html
The report traces the two loads -> vector addition -> store dependency and
distinguishes the 96-byte logical UB payload from actual memory planning.
The official host example prints expected/actual values but its comparison loop
does not fail on a numeric mismatch; future device validation must add that check.
Actual upstream rejection and local tool availability are retained in
`lab0/report/evidence/ascend-probe.json`.

