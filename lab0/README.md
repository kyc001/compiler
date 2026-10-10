# Lab 0：编译器环境预备

本目录只组织本次“了解你的编译器”预备实验及其报告，不属于编译器大作业主线实现。主线源码、测试和设计文档仍位于仓库根目录的 compiler/、tests/ 和 docs/。

## 内容

- prep/：编译流程、等价编程和 MLIR 实验输入。
- scripts/：实验执行、报告构建和清理实现。
- runtime/：实验所需的课程运行库归档。
- report/：报告源文件、精简实验依据和复核记录。
- output/pdf/preparation.pdf：已生成并随仓库提交的报告。
- build/：完整日志、可执行文件和可重建的报告中间产物，不提交。

原始课件与 LaTeX 模板保留在仓库外层 materials/ 下，仅本地保存；复现这些实验不需要它们。实验运行库归档已包含在仓库，因此新克隆不需要再从课程平台手工补文件。

## 环境要求

已验证环境为 Ubuntu 22.04 / WSL2：

- GCC/G++ 12.3、CMake、GNU Make、Python 3.10 或更新版本。
- Clang、LLVM 和 MLIR 15.0.7 命令行工具：clang-15、llvm-as-15、opt-15、llc-15、mlir-opt-15、mlir-translate-15。
- RISC-V 交叉编译工具：riscv64-unknown-elf-gcc、riscv64-unknown-elf-ar、riscv64-unknown-elf-readelf；课程工具链版本为 GCC 10.2。
- qemu-riscv64 用户态模拟器（已验证版本 6.2）。
- GNU binutils 中的 readelf、nm、objdump 和 size。
- Tectonic 0.16.9，用于重建报告 PDF。

上述命令需在 PATH 中。RISC-V 工具也可通过 RISCV_TOOLCHAIN 指定工具链根目录（其中包含 bin/），或安装在 ~/.local/opt/riscv/<version>/bin/。Tectonic 可通过 TECTONIC 环境变量指定。

Ubuntu 系统包可安装通用基础依赖：

    sudo apt update
    sudo apt install build-essential cmake make python3 git binutils qemu-user

LLVM/MLIR 15、课程提供的 RISC-V 工具链和 Tectonic 的安装来源因课程环境而异；安装后运行下面的 doctor 命令检查实际 PATH。不要把本机工具链或编译产物复制进仓库。

## 从克隆到复现

    git clone https://github.com/kyc001/compiler.git
    cd compiler
    bash lab0/build.sh doctor
    bash lab0/build.sh reproduce

reproduce 依次运行主线词法测试、预备实验和报告构建。也可以从仓库根目录分别运行：

    make test
    make prep
    make report

lab0/build.sh compiler、test、prep、report 和 clean 可单独执行。Tectonic 首次构建可能需要下载 TeX 宏包；成功构建会检查 PDF 非空、缺字、溢出和未解析引用，并更新 report/evidence/report-build.json 中的源文件与 PDF 哈希。

## 结果与清理

- 精简、可审阅的实验依据保存在 report/evidence/。
- 完整命令日志和中间文件生成在 build/。
- 最终 PDF 保存在 output/pdf/preparation.pdf，并由 Git 跟踪。
- make clean 删除根目录与 lab0/ 下可重建的 build/ 和缓存，不删除源码、实验依据或 PDF。

报告采用课程提供的南开大学模板，主文件为 report/preparation.tex。成员分工和提交复核事项见 report/review.md；两位成员仍需共同核对实际贡献，并按课程要求分别提交 PDF 和完成分组备案。
