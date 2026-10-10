# Course runtime

The course-supplied archive is kept at lab0/runtime/lib.tar.gz so a fresh clone
contains the input required by the preparation runner.

The runner extracts the files into lab0/build/prep/course_runtime/lib without
modifying them, and links the supplied libsysy_x86.a for native runs. For
RISC-V, it rebuilds the supplied sylib.c with the course GCC 10 toolchain
because the prebuilt archive has newer ISA attributes.

The header defines timing globals, so C reference compilation uses -fcommon.
Timing diagnostics on stderr are recorded separately from program stdout.
No replacement runtime is used.
