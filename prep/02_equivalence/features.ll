; Independently written LLVM IR for features.sy; no target-specific data layout.
@limit = constant i32 12, align 4
@calls = global i32 0, align 4
declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)

define i32 @bump() {
entry:
  %old = load i32, ptr @calls, align 4
  %next = add i32 %old, 1
  store i32 %next, ptr @calls, align 4
  ret i32 1
}

define i32 @factorial(i32 %n) {
entry:
  br label %loop
loop:
  %i = phi i32 [ 1, %entry ], [ %next.i, %body ]
  %result = phi i32 [ 1, %entry ], [ %product, %body ]
  %more = icmp sle i32 %i, %n
  br i1 %more, label %body, label %exit
body:
  %product = mul i32 %result, %i
  %next.i = add i32 %i, 1
  br label %loop
exit:
  ret i32 %result
}

define i32 @arithmetic(i32 %n) {
entry:
  %negative = sub i32 0, %n
  %triple = mul i32 %n, 3
  %numerator = add i32 %triple, %negative
  %quotient = sdiv i32 %numerator, 2
  %remainder = srem i32 %n, 3
  %result = add i32 %quotient, %remainder
  ret i32 %result
}

define i32 @control(i32 %n) {
entry:
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %next.i, %skip ], [ %next.i, %accumulate ]
  %total = phi i32 [ 0, %entry ], [ %total, %skip ], [ %sum, %accumulate ]
  %more = icmp slt i32 %i, %n
  br i1 %more, label %body, label %exit
body:
  %next.i = add i32 %i, 1
  %is.three = icmp eq i32 %next.i, 3
  br i1 %is.three, label %skip, label %break.check
skip:
  br label %loop
break.check:
  %stop = icmp sge i32 %next.i, 9
  br i1 %stop, label %exit, label %accumulate
accumulate:
  %sum = add i32 %total, %next.i
  br label %loop
exit:
  ret i32 %total
}

define i32 @scope(i32 %n) {
entry:
  %inner.n = add i32 %n, 7
  %result = add i32 %inner.n, %n
  ret i32 %result
}

define i32 @logic(i32 %n) {
entry:
  store i32 0, ptr @calls, align 4
  %positive = icmp sgt i32 %n, 0
  br i1 %positive, label %positive.call, label %zero.check
positive.call:
  %left.call = call i32 @bump()
  %left.true = icmp ne i32 %left.call, 0
  br i1 %left.true, label %first.true, label %zero.check
zero.check:
  br label %zero.call
zero.call:
  %right.call = call i32 @bump()
  %right.true = icmp ne i32 %right.call, 0
  br i1 %right.true, label %first.true, label %first.end
first.true:
  %before.ten = load i32, ptr @calls, align 4
  %after.ten = add i32 %before.ten, 10
  store i32 %after.ten, ptr @calls, align 4
  br label %first.end
first.end:
  %negative = icmp slt i32 %n, 0
  %not.negative = xor i1 %negative, true
  br i1 %not.negative, label %second.check, label %second.end
second.check:
  %nonnegative = icmp sge i32 %n, 0
  br i1 %nonnegative, label %second.true, label %second.call
second.call:
  %extra.call = call i32 @bump()
  %extra.true = icmp ne i32 %extra.call, 0
  br i1 %extra.true, label %second.true, label %second.end
second.true:
  %before.hundred = load i32, ptr @calls, align 4
  %after.hundred = add i32 %before.hundred, 100
  store i32 %after.hundred, ptr @calls, align 4
  br label %second.end
second.end:
  %result = load i32, ptr @calls, align 4
  ret i32 %result
}

define i32 @main() {
entry:
  %n = call i32 @getint()
  %negative = icmp slt i32 %n, 0
  br i1 %negative, label %invalid, label %upper.check
upper.check:
  %upper = load i32, ptr @limit, align 4
  %too.large = icmp sgt i32 %n, %upper
  br i1 %too.large, label %invalid, label %valid
invalid:
  call void @putint(i32 -1)
  call void @putch(i32 10)
  ret i32 0
valid:
  %fact = call i32 @factorial(i32 %n)
  call void @putint(i32 %fact)
  call void @putch(i32 32)
  %arith = call i32 @arithmetic(i32 %n)
  call void @putint(i32 %arith)
  call void @putch(i32 32)
  %flow = call i32 @control(i32 %n)
  call void @putint(i32 %flow)
  call void @putch(i32 32)
  %shadow = call i32 @scope(i32 %n)
  call void @putint(i32 %shadow)
  call void @putch(i32 32)
  %short.circuit = call i32 @logic(i32 %n)
  call void @putint(i32 %short.circuit)
  call void @putch(i32 10)
  ret i32 0
}

