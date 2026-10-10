; Independently written IR: multidimensional arrays and int/float conversions.
@weights = global [2 x [2 x float]] [
  [2 x float] [float 1.500000e+00, float 2.000000e+00],
  [2 x float] [float 3.250000e+00, float 4.000000e+00]
], align 4

declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)
declare void @putfloat(float)

define float @row_sum(ptr %values, i32 %row) {
entry:
  %index = sext i32 %row to i64
  %left.ptr = getelementptr [2 x float], ptr %values, i64 %index, i64 0
  %right.ptr = getelementptr [2 x float], ptr %values, i64 %index, i64 1
  %left = load float, ptr %left.ptr, align 4
  %right = load float, ptr %right.ptr, align 4
  %sum = fadd float %left, %right
  ret float %sum
}

define i32 @main() {
entry:
  %row = call i32 @getint()
  %negative = icmp slt i32 %row, 0
  br i1 %negative, label %invalid, label %upper.check
upper.check:
  %large = icmp sge i32 %row, 2
  br i1 %large, label %invalid, label %valid
invalid:
  call void @putint(i32 -1)
  call void @putch(i32 10)
  ret i32 0
valid:
  %sum = call float @row_sum(ptr @weights, i32 %row)
  %truncated = fptosi float %sum to i32
  %row.float = sitofp i32 %row to float
  %result = fadd float %sum, %row.float
  call void @putfloat(float %result)
  call void @putch(i32 32)
  call void @putint(i32 %truncated)
  call void @putch(i32 10)
  ret i32 0
}

