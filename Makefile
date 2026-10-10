.PHONY: all compiler test prep report
all: compiler
compiler:
	cmake -S . -B build/compiler -DCMAKE_BUILD_TYPE=Debug
	cmake --build build/compiler --parallel
test: compiler
	ctest --test-dir build/compiler --output-on-failure
prep:
	python3 scripts/run_preparation.py
report:
	mkdir -p build/report output/pdf
	xelatex -interaction=nonstopmode -halt-on-error -output-directory=build/report report/preparation.tex
	xelatex -interaction=nonstopmode -halt-on-error -output-directory=build/report report/preparation.tex
	cp build/report/preparation.pdf output/pdf/preparation.pdf


