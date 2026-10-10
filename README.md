# compiler

SysY2022 课程编译器大作业，目标架构为 RISC-V64（RV64GC / LP64D）。

## 项目范围

- 大作业主线位于 compiler/、tests/ 和 docs/。当前已实现 C++17 词法分析器及 Token 输出；语法分析、语义检查、SSA、优化和自有 RISC-V 后端仍待开发。
- 本次环境预备实验独立放在 lab0/，包含实验输入、运行库、报告、依据、PDF 和复现入口。它用于熟悉工具链，不代表大作业主线已完成。

## 目录结构

| 路径 | 职责 |
| --- | --- |
| compiler/ | 编译器主线源码 |
| tests/ | 编译器回归测试 |
| docs/ | 词法规格等主线文档 |
| lab0/prep/ | 本次预备实验输入 |
| lab0/scripts/ | 预备实验、报告构建和清理脚本 |
| lab0/report/ | 报告源文件及可追溯实验依据 |
| lab0/runtime/ | 实验使用的课程运行库 |
| lab0/output/pdf/ | 已生成并纳入版本控制的报告 PDF |
| build/、lab0/build/ | 可重建的编译产物与完整日志 |

原始课件与模板保留在本地 materials/，不作为复现输入。

## 编译与测试

需要 CMake、GNU Make、C++17 编译器和 Python 3。

    make compiler
    make test
    ./build/compiler/sysyc --tokens path/to/file.sy

## 环境预备实验

复现环境要求和命令见 lab0/README.md。检查工具链并运行全套实验：

    bash lab0/build.sh doctor
    bash lab0/build.sh reproduce

根 Makefile 也保留 make prep、make report 和 make clean 入口。实验与报告的详细说明见 lab0/README.md。

大作业后续按课程要求扩展语法分析／AST、作用域与类型检查、SSA／mem2reg、优化及自有 RISC-V 后端。文法注意事项见 docs/lexical-spec.md.
