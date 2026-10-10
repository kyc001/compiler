cmake_minimum_required(VERSION 3.16)
project(compiler LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
add_executable(sysyc compiler/src/main.cpp compiler/src/lexer.cpp)
target_include_directories(sysyc PRIVATE compiler/include)
target_compile_options(sysyc PRIVATE -Wall -Wextra -Wpedantic -Wconversion -Wshadow)
enable_testing()
find_package(Python3 REQUIRED COMPONENTS Interpreter)
add_test(NAME lexer COMMAND ${Python3_EXECUTABLE}
    ${CMAKE_CURRENT_SOURCE_DIR}/tests/test_lexer.py $<TARGET_FILE:sysyc>)

