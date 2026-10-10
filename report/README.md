# 预备实验报告

- preparation.tex：唯一报告主文件；在当前 LaTeX 编辑器中继续编辑。
- assets/NKU.png：用户提供模板中的原始校徽。
- evidence/results.json：最近一次成功实验的时间、工具版本、命令、输入输出及源码哈希。
- evidence/observations.txt：报告使用的编译阶段与 MLIR 输出。
- evidence/report-build.json：make report 自动生成的编译检查记录及源文件、PDF 哈希，可据此识别旧成稿。
- evidence/ascend-probe.json：本机专用工具链探测与上游 MLIR 拒绝未注册 HIVM 方言的实际诊断。
- review.md：作业逐项核对、复验结果和仍需成员完成的提交事项。
- 最终 PDF：output/pdf/preparation.pdf（由 make report 生成）。

本报告采用 materials/templates/LaTeX模板.zip，模板出处及改动见该目录 README。
为便于维护，使用现代 ctexset 表达模板原有章节格式，参考文献放在主文件末尾。
模板中的无关伪代码和示例参考文献不引入报告。

## 编译

在项目根目录运行 make report，按用户要求使用 Tectonic，并自动重跑以解析目录和交叉引用。
优先使用模板中的 Noto CJK 字体，Windows 下可回退到宋体，其余环境使用 Fandol；
首次构建可能需要由 Tectonic 下载 TeX 宏包与字体。
脚本兼容原生 Tectonic 和 WSL 调用 Windows tectonic.exe，也可通过 TECTONIC 环境变量指定路径。
构建会检查缺字、溢出和未解析引用，发现这些问题时不覆盖最终 PDF。
在 Overleaf 使用时，将 preparation.tex 和 assets/ 上传至同一项目，
选择 XeLaTeX，并将 preparation.tex 设为主文件。

成员：柯云超（2413575）、郑奕杰（2412677）。
柯云超负责总体方案、等价程序核心实现、SSA／MLIR 分析及自动化验证；
郑奕杰负责编译流程基础实验、基础与边界用例检查、结果及资料整理。
提交前两位成员共同核对报告，并分别在小雅平台提交相同 PDF；分组备案按课程要求完成。

## 结果保存

make prep 成功后自动更新 evidence/。完整 stdout/stderr、二进制和中间文件位于
build/prep/；make clean 可删除这些可重建文件，保留 PDF、源码、原始课件和精简依据。
若实验失败，build/prep/manifest.json 保存失败诊断；保留的 evidence 仍代表上一次成功运行，
其时间和源码 SHA-256 可用于判断是否对应当前代码。

当前三组等价程序共 34 个输入、170 次执行比对；编译流程 85 次检查，另有宏变体检查；
通用 MLIR 的基本、正负混合和原地写回三组输入共验证 12 个元素。
