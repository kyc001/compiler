#include "lexer.hpp"

#include <cctype>
#include <regex>
#include <string_view>
#include <unordered_set>
#include <utility>

namespace sysy {
namespace {
bool letter(char ch) {
    return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_';
}
bool digit(char ch) { return ch >= '0' && ch <= '9'; }

const std::unordered_set<std::string> keywords = {
    "const", "int", "float", "void", "if", "else", "while", "break", "continue", "return"
};
const std::regex float_pattern(
    R"((0[xX]([0-9a-fA-F]+\.[0-9a-fA-F]*|\.[0-9a-fA-F]+|[0-9a-fA-F]+)[pP][+-]?[0-9]+)|(([0-9]+\.[0-9]*|\.[0-9]+)([eE][+-]?[0-9]+)?|[0-9]+[eE][+-]?[0-9]+))");
const std::regex integer_pattern(R"(0[xX][0-9a-fA-F]+|0[0-7]*|[1-9][0-9]*)");
}

LexError::LexError(std::size_t at_line, std::size_t at_column, const std::string& message)
    : std::runtime_error(message), line(at_line), column(at_column) {}

Lexer::Lexer(std::string source) : source_(std::move(source)) {}

char Lexer::peek(std::size_t ahead) const {
    return ahead < source_.size() - offset_ ? source_[offset_ + ahead] : '\0';
}

void Lexer::advance() {
    if (offset_ == source_.size()) return;
    if (source_[offset_++] == '\n') {
        ++line_;
        column_ = 1;
    } else {
        ++column_;
    }
}

void Lexer::skip_trivia() {
    for (;;) {
        while (std::isspace(static_cast<unsigned char>(peek()))) advance();
        if (peek() == '/' && peek(1) == '/') {
            while (offset_ < source_.size() && peek() != '\n') advance();
        } else if (peek() == '/' && peek(1) == '*') {
            const auto start_line = line_;
            const auto start_column = column_;
            advance();
            advance();
            while (offset_ < source_.size() && !(peek() == '*' && peek(1) == '/')) advance();
            if (offset_ == source_.size()) {
                throw LexError(start_line, start_column, "unterminated block comment");
            }
            advance();
            advance();
        } else {
            return;
        }
    }
}

Token Lexer::next() {
    skip_trivia();
    const auto start = offset_;
    const auto start_line = line_;
    const auto start_column = column_;
    std::string kind;
    if (offset_ == source_.size()) return {"eof", "", line_, column_};
    if (letter(peek())) {
        do { advance(); } while (letter(peek()) || digit(peek()));
        kind = keywords.count(source_.substr(start, offset_ - start)) ? "keyword" : "identifier";
    } else if (digit(peek()) || (peek() == '.' && digit(peek(1)))) {
        std::match_results<std::string::const_iterator> match;
        const auto begin = source_.cbegin() + static_cast<std::ptrdiff_t>(offset_);
        std::size_t length = 0;
        if (std::regex_search(begin, source_.cend(), match, float_pattern,
                              std::regex_constants::match_continuous)) {
            length = static_cast<std::size_t>(match.length());
            kind = "floating";
        }
        if (std::regex_search(begin, source_.cend(), match, integer_pattern,
                              std::regex_constants::match_continuous) &&
            static_cast<std::size_t>(match.length()) > length) {
            length = static_cast<std::size_t>(match.length());
            kind = "integer";
        }
        for (std::size_t i = 0; i < length; ++i) advance();
        if (!length || letter(peek()) || digit(peek()) || peek() == '.') {
            throw LexError(start_line, start_column, "malformed numeric literal");
        }
    } else {
        const std::string pair = source_.substr(offset_, 2);
        if (pair == "<=" || pair == ">=" || pair == "==" || pair == "!=" ||
            pair == "&&" || pair == "||") {
            advance();
            advance();
            kind = "operator";
        } else if (std::string_view("+-*/%=<>!").find(peek()) != std::string_view::npos) {
            advance();
            kind = "operator";
        } else if (std::string_view("(){}[],;").find(peek()) != std::string_view::npos) {
            advance();
            kind = "punctuation";
        } else {
            throw LexError(start_line, start_column, "unexpected character");
        }
    }
    return {kind, source_.substr(start, offset_ - start), start_line, start_column};
}

std::vector<Token> Lexer::scan() {
    std::vector<Token> tokens;
    do {
        tokens.push_back(next());
    } while (tokens.back().kind != "eof");
    return tokens;
}

}

