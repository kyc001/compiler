# Course runtime

The original runtime is supplied in `../lib.tar.gz`. The preparation runner
extracts the supplied files into `build/prep/course_runtime/lib`, without
modifying them, and links the supplied `libsysy_x86.a` for native runs.
For RISC-V, it rebuilds the supplied `sylib.c` with the installed GCC 10:
the supplied archive has newer ISA extension attributes which GCC 10 cannot read.
The archive and its sources remain the authority for the runtime interface.

The provided header defines timing globals; C reference compilation therefore
uses `-fcommon`. Timing diagnostics on stderr are recorded separately from
the program's stdout. No replacement runtime is used.

