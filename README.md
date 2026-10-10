# compiler

SysY2022 课程编译器项目，目标架构为 RISC-V64（RV64GC / LP64D）。
本地项目目录保持 `compile`，仓库名称使用 `compiler`。

## 当前进度

- 已完成预备工作的 GCC 编译流程实验，保存预处理、Token、AST、GIMPLE、LLVM IR、汇编、目标文件、重定位和链接结果。
- 已独立编写两组 SysY / LLVM IR / RISC-V 汇编程序，覆盖整数、短路求值、循环、作用域、数组、浮点数和类型转换。
- 19 个输入用例在 5 条执行路径上共完成 95 次比对，全部通过。
- 已完成通用 MLIR VecAdd 逐层 lowering，并运行转换得到的 LLVM IR 程序。
- 已阅读课程 AscendNPU-IR 课件和官方 VecAdd 文档，保存带来源的参考代码；本机没有执行 BishengIR / CANN 工具链。
- 已实现 C++17 词法分析器，通过 12 项测试。
- 预备工作报告源文件位于 `report/preparation.tex`。姓名、学号和真实分工需要小组成员补全。

**当前 `sysyc` 仅支持输出 Token。语法分析、语义检查、SSA 生成、优化和编译器自身的 RISC-V 后端尚未实现。**
预备实验调用 GCC/LLVM 验证手写程序，不代表已经实现大作业的编译器。

## 使用

在 Ubuntu / WSL 终端运行：

```sh
cd ~/project/compile
make prep
make test
./build/compiler/sysyc --tokens prep/02_equivalence/features.sy
make report
```

生成目录：

| 路径 | 内容 |
| --- | --- |
| `build/prep/manifest.json` | 工具版本、每条命令、标准输出、标准错误、预期结果和比对结果 |
| `build/prep/pipeline/` | 各编译阶段的可读输出与二进制产物 |
| `build/prep/equivalence/` | 两组程序的参考实现、IR、汇编执行文件 |
| `build/prep/mlir/` | 各层 MLIR、最终 LLVM IR 和执行文件 |
| `build/compiler/sysyc` | 当前词法分析器命令行程序 |
| `output/pdf/preparation.pdf` | 报告 PDF |

运行预备实验前，先从课程平台取得 `lib.tar.gz` 并放在项目根目录。课件和运行库压缩包作为本地课程资料保存，不随公开仓库分发。
脚本从课程提供的 `lib.tar.gz` 提取运行库，不改动原始课件或运行库源码。
原始 RISC-V 静态库的 ISA 属性与本机 GCC 10 不兼容，因此依照讲义从课程 `sylib.c` 重建兼容库。
`stderr` 的运行库计时信息单独记录，程序输出以 `stdout` 为准。

## 环境

已验证：Ubuntu 22.04、GCC 12.3、Clang/LLVM/MLIR 15.0.7、课程 RISC-V GCC 10.2、QEMU user 6.2、CMake、Python 3、XeLaTeX 和 Noto CJK 字体。
RISC-V 链接使用 `-static -mcmodel=medany -Wl,--no-relax,-Ttext=0x90000000`。

RISC-V 工具可通过 `PATH` 或 `RISCV_TOOLCHAIN=/path/to/toolchain` 指定。
脚本也会查找 `~/.local/opt/riscv/*/bin/` 中已有的课程工具。
QEMU 用户模式运行单个程序；已有的 `qemu-system-riscv64` 不能替代 `qemu-riscv64`。

本次补充安装了 `qemu-user`、`mlir-15-tools`、RISC-V Linux binutils 和交叉库；保留原有 `gcc-multilib`、`g++-multilib`。
实际预备实验的 RISC-V 路径使用原有课程 `riscv64-unknown-elf-gcc`。

## 后续顺序

1. 基于课程文法补充实现语法分析和 AST，覆盖 `int/float/bool` 表达式、就近匹配的 `else`、数组初始化和函数定义。
2. 实现作用域、符号表、类型检查、常量表达式求值及运行库函数声明。
3. 生成中间代码，验证短路控制流和 SSA，再实现完整 `mem2reg`。
4. 自行实现 RISC-V 目标代码生成、调用约定、栈帧和运行库链接。
5. 完成基础测试后增加进阶语法和优化；“张量类型”的额外语法需向助教确认。

## 参考与提交

课程资料保存在项目根目录。文法补充明确：`++a` 是两个单目加号；`!` 可出现在一般表达式；`putf` 不要求实现；数组形参后续维度必须是常量。
词法规格见 `docs/lexical-spec.md`，MLIR 实验说明见 `prep/03_mlir/README.md`。
引用的官方 Ascend 示例在源码头部注明来源；编译器和等价实验代码均未复制公开参赛编译器。
提交前补全报告中的真实成员信息和分工，两个人分别在小雅平台提交同一 PDF，并完成小组备案。

