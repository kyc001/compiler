// Reference code from the official AscendNPU IR VecAdd example:
// https://ascendnpu-ir.gitcode.com/zh_cn/sources/introduction/quick_start/examples_zh.html
// Huawei documentation, accessed 2026-10-09. Requires BishengIR/CANN.
// This reference has NOT been compiled or executed in the current environment.
module {
  func.func @add(%arg0: memref<16xi16, #hivm.address_space<gm>>,
                 %arg1: memref<16xi16, #hivm.address_space<gm>>,
                 %arg2: memref<16xi16, #hivm.address_space<gm>>)
      attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>} {
    %a = memref.alloc() : memref<16xi16, #hivm.address_space<ub>>
    hivm.hir.load ins(%arg0 : memref<16xi16, #hivm.address_space<gm>>)
      outs(%a : memref<16xi16, #hivm.address_space<ub>>)
    %b = memref.alloc() : memref<16xi16, #hivm.address_space<ub>>
    hivm.hir.load ins(%arg1 : memref<16xi16, #hivm.address_space<gm>>)
      outs(%b : memref<16xi16, #hivm.address_space<ub>>)
    %c = memref.alloc() : memref<16xi16, #hivm.address_space<ub>>
    hivm.hir.vadd ins(%a, %b : memref<16xi16, #hivm.address_space<ub>>,
                              memref<16xi16, #hivm.address_space<ub>>)
      outs(%c : memref<16xi16, #hivm.address_space<ub>>)
    hivm.hir.store ins(%c : memref<16xi16, #hivm.address_space<ub>>)
      outs(%arg2 : memref<16xi16, #hivm.address_space<gm>>)
    return
  }
}

