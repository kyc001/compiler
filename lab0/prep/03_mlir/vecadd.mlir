// Generic MLIR exercise; this is not an AscendNPU dialect program.
module {
  func.func @vecadd(%a: memref<4xf32>, %b: memref<4xf32>, %out: memref<4xf32>) attributes { llvm.emit_c_interface } {
    %c0 = arith.constant 0 : index
    %c4 = arith.constant 4 : index
    %c1 = arith.constant 1 : index
    scf.for %i = %c0 to %c4 step %c1 {
      %x = memref.load %a[%i] : memref<4xf32>
      %y = memref.load %b[%i] : memref<4xf32>
      %sum = arith.addf %x, %y : f32
      memref.store %sum, %out[%i] : memref<4xf32>
    }
    return
  }
}
