#include "lexer.hpp"

#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <utility>

int main(int argc, char** argv) {
    if (argc == 2 && std::string(argv[1]) == "--help") {
        std::cout << "Usage: sysyc --tokens source.sy\n"
                     "Stage 1: lexical analysis only; parser and code generation are pending.\n";
        return 0;
    }
    if (argc != 3 || std::string(argv[1]) != "--tokens") {
        std::cerr << "Usage: sysyc --tokens source.sy\n";
        return 2;
    }
    std::ifstream input(argv[2], std::ios::binary);
    if (!input) {
        std::cerr << argv[2] << ": cannot open input file\n";
        return 1;
    }
    std::string source((std::istreambuf_iterator<char>(input)), std::istreambuf_iterator<char>());
    if (input.bad()) {
        std::cerr << argv[2] << ": cannot read input file\n";
        return 1;
    }
    try {
        sysy::Lexer lexer(std::move(source));
        for (const auto& token : lexer.scan()) {
            std::cout << token.line << ':' << token.column << '\t'
                      << token.kind << '\t' << token.text << '\n';
        }
    } catch (const sysy::LexError& error) {
        std::cerr << argv[2] << ':' << error.line << ':' << error.column
                  << ": " << error.what() << '\n';
        return 1;
    }
    return 0;
}

