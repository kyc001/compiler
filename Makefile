.PHONY: all compiler test prep report clean
all: compiler
compiler:
	cmake -S . -B build/compiler -DCMAKE_BUILD_TYPE=Debug
	cmake --build build/compiler --parallel
test: compiler
	ctest --test-dir build/compiler --output-on-failure
prep:
	python3 lab0/scripts/run_preparation.py
report:
	python3 lab0/scripts/build_report.py
clean:
	python3 lab0/scripts/clean.py
