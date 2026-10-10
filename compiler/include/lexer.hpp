#pragma once

#include <cstddef>
#include <stdexcept>
#include <string>
#include <vector>

namespace sysy {

struct Token {
    std::string kind;
    std::string text;
    std::size_t line;
    std::size_t column;
};

class LexError : public std::runtime_error {
public:
    LexError(std::size_t line, std::size_t column, const std::string& message);
    std::size_t line;
    std::size_t column;
};

class Lexer {
public:
    explicit Lexer(std::string source);
    std::vector<Token> scan();

private:
    std::string source_;
    std::size_t offset_ = 0;
    std::size_t line_ = 1;
    std::size_t column_ = 1;
    char peek(std::size_t ahead = 0) const;
    void advance();
    void skip_trivia();
    Token next();
};

}

