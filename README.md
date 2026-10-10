# compiler

SysY2022 课程编译器项目，目标架构为 RISC-V64（RV64GC / LP64D）。
GitHub 仓库名为 compiler，本地项目根目录为 compile，根目录下的 compiler/ 专门存放编译器源码。

## 当前状态

- 预备实验：编译各阶段、宏修改、O0/O2、调试选项、静态链接及 mem2reg 对照；85 次功能／边界检查通过。
- 等价编程：三组手写 SysY、LLVM IR 与 RISC-V 汇编，34 个用例乘 5 条执行路径，共 170 次比对通过；补充负数除余、浮点四则、递归与局部数组读写。
- MLIR：完成通用 VecAdd 的逐层降低、LLVM IR 验证及本机执行，三组检查共 12 个元素通过；AscendNPU 部分为课件和官方文档调研。
- 编译器：C++17 词法分析器通过 12 项测试，目前仅提供 Token 输出。
- 报告：采用用户提供的南开大学 LaTeX 模板，已填写柯云超（2413575）、郑奕杰（2412677）；柯云超负责总体设计、核心实现及技术分析，郑奕杰负责编译流程基础实验、用例检查和资料整理。

语法分析、语义检查、SSA 生成、优化和编译器自身的 RISC-V 后端尚待实现；预备实验的成功不代表完整编译器已完成。

## 目录约定

| 目录 | 职责 | 是否保留／提交 |
| --- | --- | --- |
| compiler/include、compiler/src | 编译器头文件与实现 | 保留源码 |
| tests | 编译器回归测试 | 保留源码 |
| prep/01_pipeline | 阶乘编译流程与语义错误样例 | 保留源码 |
| prep/02_equivalence | 三组 SysY、手写 IR／汇编与独立预期用例 | 保留源码 |
| prep/03_mlir | 通用 MLIR、验证驱动与带来源的 Ascend 参考代码 | 保留源码 |
| scripts | 实验、Tectonic 报告构建和清理入口 | 保留源码 |
| docs | 词法规格等设计文档 | 保留文档 |
| report | 报告主文件、模板校徽及精简实验依据 | 保留并版本管理 |
| materials/course | 原始课件、作业要求、语言规范 | 本地保留，原始文件忽略 |
| materials/templates | 用户提供的 LaTeX 模板压缩包 | 本地保留，原始文件忽略 |
| runtime | 课程运行库压缩包及使用说明 | 压缩包本地保留并忽略 |
| output/pdf | 最终报告 preparation.pdf | 保留交付文件，Git 忽略 |
| build | 二进制、中间文件、缓存与完整日志 | 可重建，make clean 删除 |

## 复现

在 Ubuntu／WSL 的项目根目录运行：

```sh
make prep
make test
./build/compiler/sysyc --tokens prep/02_equivalence/features.sy
make report
make clean
```

预备实验需要课程平台提供的 runtime/lib.tar.gz。脚本从中提取运行库；宿主链接 libsysy_x86.a，
RISC-V 从原始 sylib.c 重建兼容 GCC 10 的库。标准错误的计时信息与标准输出分开记录。
原始课件和模板不作为自动构建输入，下载仓库后只需补充运行库即可复现实验。

实验成功时自动保存 report/evidence/results.json 和 observations.txt，记录工具版本、源码哈希、
命令、输入输出以及关键阶段转储。完整日志在 build/prep/manifest.json；清理后仍保留精简依据。

make report 使用 Tectonic 生成 output/pdf/preparation.pdf。脚本同时支持 Linux Tectonic 和
WSL 中已加入 PATH 的 Windows tectonic.exe；可设置 TECTONIC 指定可执行文件路径。
首次编译可能下载宏包。模板字体优先使用 Noto CJK，Windows 下可回退到宋体；
构建会检查缺字、内容溢出和未解析引用，检查通过后才更新最终 PDF。
编辑时继续修改 report/preparation.tex；报告说明见 report/README.md。
按评分要求的核对结果见 report/review.md。make report 会自动更新报告构建记录与源文件、PDF 哈希。

make clean 仅删除 build/ 和脚本／测试缓存，保留最终 PDF、实验依据、源码与原始资料。
新产生的中间文件应写入 build/，不要放在项目根目录或 compiler/ 源码目录中。

## 实验环境

已验证：Ubuntu 22.04、GCC 12.3、Clang/LLVM/MLIR 15.0.7、课程 RISC-V GCC 10.2、
QEMU user 6.2、CMake、Python 3.10 及以上、Tectonic 0.16.9。
RISC-V 链接采用 -static -mcmodel=medany -Wl,--no-relax,-Ttext=0x90000000。
交叉工具可通过 PATH 或 RISCV_TOOLCHAIN=/path/to/toolchain 指定，
脚本也会搜索 ~/.local/opt/riscv/*/bin/；运行需要 qemu-riscv64 用户模式工具。

## 后续开发与提交

后续依次实现语法分析／AST、作用域与类型检查、SSA／mem2reg、自有 RISC-V 后端，然后扩充语法及优化测试。
课程文法补充明确：++a 是两个单目加号，! 可出现在一般表达式，putf 不要求实现，数组形参后续维度必须是常量。
详见 docs/lexical-spec.md 与 prep/03_mlir/README.md。

两位成员共同核对报告与分工后，各自在小雅平台提交相同 PDF，并按课程要求完成小组备案。
