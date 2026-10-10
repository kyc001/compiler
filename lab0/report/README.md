# 预备实验报告

- preparation.tex：唯一报告主文件，继续在现有 LaTeX 编辑器中维护。
- assets/NKU.png：报告封面使用的校徽图像。
- evidence/results.json：实验状态、工具版本、运行库与源码哈希、命令及输入输出。
- evidence/observations.txt：报告引用的编译阶段和 MLIR 关键转储。
- evidence/report-build.json：报告构建结果及源文件、PDF 哈希。
- evidence/ascend-probe.json：Ascend 方言工具链探测和诊断。
- review.md：评分要求核对及提交前待办。
- 最终 PDF：lab0/output/pdf/preparation.pdf，由 Tectonic 构建并纳入版本控制。

## 构建

从仓库根目录运行 bash lab0/build.sh report，或运行 make report。构建使用 Tectonic，首次运行可能需要下载宏包。报告源文件和图片随仓库提供；不需要原始模板压缩包参与构建。

构建会检查 PDF 是否非空，以及缺字、内容溢出和未解析引用。通过后才更新最终 PDF 和 evidence/report-build.json。原生 Linux Tectonic、PATH 中的 Windows tectonic.exe 均可使用，也可通过 TECTONIC 指定可执行文件。

在 Overleaf 使用时，将 preparation.tex 和 assets/ 放在同一项目，选择 XeLaTeX 并将 preparation.tex 设为主文件。

## 实验依据

从仓库根目录运行 make prep，成功后自动刷新 evidence/。完整命令输出、可执行文件和中间产物位于 lab0/build/prep/；make clean 删除这些可重建文件，但保留精简 evidence 和 PDF。失败时 lab0/build/prep/manifest.json 保留失败诊断；此时 evidence/ 仍代表上一次成功运行，可用时间戳和源码哈希判断其是否匹配当前输入。

报告登记的分工为：柯云超（2413575）负责总体方案、等价程序核心实现、SSA／MLIR 分析及自动化验证；郑奕杰（2412677）负责编译流程基础实验、基础与边界用例检查、结果及资料整理。提交前两位成员应核对分工与实际贡献，并按课程要求分别提交相同 PDF、完成分组备案。
