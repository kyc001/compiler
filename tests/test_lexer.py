import csv
import io
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

BINARY = Path(sys.argv.pop(1)).resolve()


class LexerTests(unittest.TestCase):
    def scan(self, source):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "case.sy"
            path.write_bytes(source.encode("utf-8"))
            result = subprocess.run([BINARY, "--tokens", path], capture_output=True,
                                    text=True, timeout=10)
        rows = list(csv.reader(io.StringIO(result.stdout), delimiter="\t"))
        return result, rows

    def test_keywords_and_names(self):
        result, rows = self.scan("const int integer = 1; float _f; void f() {return;}")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(rows[0], ["1:1", "keyword", "const"])
        self.assertEqual(rows[2], ["1:11", "identifier", "integer"])
        self.assertEqual(rows[-1][1], "eof")

    def test_integer_bases_and_minimum_magnitude(self):
        result, rows = self.scan("0 077 0xAf 0X10 -2147483648")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([(row[1], row[2]) for row in rows[:-1]],
                         [("integer", "0"), ("integer", "077"), ("integer", "0xAf"),
                          ("integer", "0X10"), ("operator", "-"), ("integer", "2147483648")])

    def test_float_forms(self):
        result, rows = self.scan("1. .5 2e3 3.5e-2 0x1.fp+2 0XAp-1 0x.8P0 1.e+2")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([row[1] for row in rows[:-1]], ["floating"] * 8)

    def test_plus_plus_is_two_unary_operators(self):
        result, rows = self.scan("++a --b != <= >= == && || !")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([row[2] for row in rows[:3]], ["+", "+", "a"])
        self.assertEqual([row[2] for row in rows[3:6]], ["-", "-", "b"])
        self.assertEqual([row[2] for row in rows[6:-1]], ["!=", "<=", ">=", "==", "&&", "||", "!"])

    def test_comments_and_locations(self):
        result, rows = self.scan("// ignored\r\n/* a\n b */ int x; // eof")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(rows[0], ["3:7", "keyword", "int"])
        self.assertEqual(rows[1], ["3:11", "identifier", "x"])

    def test_all_punctuation(self):
        result, rows = self.scan("(){}[],;")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([row[1] for row in rows[:-1]], ["punctuation"] * 8)

    def test_malformed_numbers(self):
        for literal in ["09", "0x", "1e+", "0x1.2", "0x1p", "123abc", "1..2", "1.0f"]:
            with self.subTest(literal=literal):
                result, _ = self.scan(literal)
                self.assertEqual(result.returncode, 1)
                self.assertIn(":1:1: malformed numeric literal", result.stderr)

    def test_unterminated_comment(self):
        result, _ = self.scan("\n  /* never closed")
        self.assertEqual(result.returncode, 1)
        self.assertIn(":2:3: unterminated block comment", result.stderr)

    def test_illegal_character(self):
        for source in ["&", "|", "@", "\0", "int 中文;"]:
            with self.subTest(source=source):
                result, _ = self.scan(source)
                self.assertEqual(result.returncode, 1)
                self.assertIn("unexpected character", result.stderr)

    def test_empty_input(self):
        result, rows = self.scan("")
        self.assertEqual(result.returncode, 0)
        self.assertEqual(rows, [["1:1", "eof", ""]])

    def test_real_program(self):
        root = Path(__file__).resolve().parents[1]
        result, rows = self.scan((root / "prep/02_equivalence/features.sy").read_text())
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("continue", [row[2] for row in rows])
        self.assertIn("&&", [row[2] for row in rows])

    def test_missing_file(self):
        result = subprocess.run([BINARY, "--tokens", "/nonexistent/compiler.sy"],
                                capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 1)
        self.assertIn("cannot open input file", result.stderr)


if __name__ == "__main__":
    unittest.main()

