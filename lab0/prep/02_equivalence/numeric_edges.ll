; Independently written IR for numeric_edges.sy, restricted to its input domain.
declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)
declare void @putfloat(float)

define i32 @sumdown(i32 %n) {
entry:
  %zero = icmp eq i32 %n, 0
  br i1 %zero, label %base, label %recurse
base:
  ret i32 0
recurse:
  %previous = sub i32 %n, 1
  %partial = call i32 @sumdown(i32 %previous)
  %result = add i32 %n, %partial
  ret i32 %result
}

define void @update(ptr %values, i32 %delta) {
entry:
  %p1 = getelementptr i32, ptr %values, i64 1
  %p2 = getelementptr i32, ptr %values, i64 2
  %v1 = load i32, ptr %p1, align 4
  %next1 = add i32 %v1, %delta
  store i32 %next1, ptr %p1, align 4
  %v2 = load i32, ptr %p2, align 4
  %v0 = load i32, ptr %values, align 4
  %sum = add i32 %v2, %v0
  %next2 = sub i32 %sum, %next1
  store i32 %next2, ptr %p2, align 4
  ret void
}

define float @calculate(float %x) {
entry:
  %negative = fneg float %x
  %half = fdiv float %negative, 2.000000e+00
  %shifted = fsub float %half, 2.500000e-01
  %plus = fadd float %shifted, 1.000000e+00
  %twice = fmul float %plus, 2.000000e+00
  %result = fdiv float %twice, 4.000000e+00
  ret float %result
}

define i32 @main() {
entry:
  %n = call i32 @getint()
  %d = call i32 @getint()
  %low = icmp slt i32 %n, -12
  %high = icmp sgt i32 %n, 12
  %bad.n = or i1 %low, %high
  %zero = icmp eq i32 %d, 0
  %low.d = icmp slt i32 %d, -3
  %high.d = icmp sgt i32 %d, 3
  %bad.d.range = or i1 %low.d, %high.d
  %bad.d = or i1 %zero, %bad.d.range
  %bad = or i1 %bad.n, %bad.d
  br i1 %bad, label %invalid, label %valid
invalid:
  call void @putint(i32 -1)
  call void @putch(i32 10)
  ret i32 0
valid:
  %values = alloca [3 x i32], align 4
  %p1 = getelementptr [3 x i32], ptr %values, i64 0, i64 1
  %p2 = getelementptr [3 x i32], ptr %values, i64 0, i64 2
  store i32 %n, ptr %values, align 4
  store i32 0, ptr %p1, align 4
  store i32 0, ptr %p2, align 4
  call void @update(ptr %values, i32 %d)
  %is.negative = icmp slt i32 %n, 0
  %negated = sub i32 0, %n
  %magnitude = select i1 %is.negative, i32 %negated, i32 %n
  %x = sitofp i32 %n to float
  %y = call float @calculate(float %x)
  %truncated = fptosi float %y to i32
  %negative = fcmp olt float %y, 0.000000e+00
  %sign = zext i1 %negative to i32
  %quotient = sdiv i32 %n, %d
  %remainder = srem i32 %n, %d
  call void @putint(i32 %quotient)
  call void @putch(i32 32)
  call void @putint(i32 %remainder)
  call void @putch(i32 32)
  call void @putfloat(float %y)
  call void @putch(i32 32)
  call void @putint(i32 %truncated)
  call void @putch(i32 32)
  call void @putint(i32 %sign)
  call void @putch(i32 32)
  %recursive = call i32 @sumdown(i32 %magnitude)
  call void @putint(i32 %recursive)
  call void @putch(i32 32)
  %v0 = load i32, ptr %values, align 4
  %v1 = load i32, ptr %p1, align 4
  %v2 = load i32, ptr %p2, align 4
  %twice1 = mul i32 %v1, 2
  %triple2 = mul i32 %v2, 3
  %s01 = add i32 %v0, %twice1
  %total = add i32 %s01, %triple2
  call void @putint(i32 %total)
  call void @putch(i32 10)
  ret i32 0
}
