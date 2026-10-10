# MLIR and AscendNPU IR exploration

`vecadd.mlir` is an original generic MLIR exercise for four float elements.
The preparation runner executes:

1. `scf / arith / memref` IR verification.
2. `convert-scf-to-cf`, exposing explicit CFG branches.
3. MemRef, Arith, Func and CF conversion to the LLVM dialect.
4. LLVM IR translation, verification and native compilation.
5. `check_vecadd.c`, checking every output element through the generated C interface.

Expected native result: `1.5 4.5 7.5 10.5`.
The memref C descriptor contains allocated/aligned pointers, offset, size and stride.

`ascend_vecadd.mlir` is attributed reference code from the official example:
https://ascendnpu-ir.gitcode.com/zh_cn/sources/introduction/quick_start/examples_zh.html

This reference uses HIVM GM/UB address spaces and HACC device-entry attributes.
It cannot be compiled with the upstream `mlir-opt-15`, which does not register
these custom dialects. BishengIR/CANN execution has not been performed here.
With a configured BishengIR/CANN environment, the documented compilation is:

```sh
bishengir-compile prep/03_mlir/ascend_vecadd.mlir -enable-hivm-compile -o kernel.o
```

The official host program then registers `kernel.o`, launches the kernel through
CANN and copies the result from device to host. Hardware execution is separate
from IR lowering. Inspect `bishengir-opt --help` for the installed version's
pass names; the classroom slide snippets are explanatory illustrations.

