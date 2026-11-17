# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Regression tests for the build checks.

Run by the site build (site.nix) and by hand:
    MATHJAX_MODULES=vendor/node_modules python3 -m unittest tools/test_checks.py

The MathJax tests are skipped when MATHJAX_MODULES is not set.
"""

import os
import pathlib
import subprocess
import sys
import tempfile
import unittest

TOOLS = pathlib.Path(__file__).resolve().parent
REPO = TOOLS.parent
BASE = "https://example.org/blog/"

PAGE = """<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>t</title>
<link rel="stylesheet" href="/blog/css/main.css">{head}</head>
<body><h1 id="top">t</h1>{body}</body></html>
"""


def build(root: pathlib.Path, head: str = "", body: str = "", css: str = "") -> None:
    (root / "css").mkdir(parents=True)
    (root / "css" / "main.css").write_text(css)
    (root / "index.html").write_text(PAGE.format(head=head, body=body))


def check_site(root: pathlib.Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(TOOLS / "check_site.py"), "--base-url", BASE, str(root)],
        capture_output=True,
        text=True,
        check=False,
    )


class CheckSite(unittest.TestCase):
    def run_site(self, **parts: str) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as name:
            root = pathlib.Path(name)
            build(root, **parts)
            return check_site(root)

    def test_clean_site_passes(self) -> None:
        result = self.run_site(
            body='<a href="/blog/#top">up</a> <a href="https://other.example/">out</a>'
        )
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_same_host_outside_the_site_is_not_checked(self) -> None:
        result = self.run_site(body='<a href="https://example.org/elsewhere/">x</a>')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_broken_link_fails(self) -> None:
        result = self.run_site(body='<a href="/blog/missing/">x</a>')
        self.assertEqual(result.returncode, 1)
        self.assertIn("points at nothing", result.stderr)

    def test_missing_image_fails(self) -> None:
        result = self.run_site(body='<img src="images/missing.png" alt="">')
        self.assertEqual(result.returncode, 1)
        self.assertIn("points at nothing", result.stderr)

    def test_unknown_fragment_fails(self) -> None:
        result = self.run_site(body='<a href="#nowhere">x</a>')
        self.assertEqual(result.returncode, 1)
        self.assertIn("fragment", result.stderr)

    def test_script_from_another_host_fails(self) -> None:
        result = self.run_site(
            head='<script src="https://cdn.example.net/lib.js"></script>'
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("another host", result.stderr)

    def test_protocol_relative_script_fails(self) -> None:
        result = self.run_site(head='<script src="//cdn.example.net/lib.js"></script>')
        self.assertEqual(result.returncode, 1)
        self.assertIn("another host", result.stderr)

    def test_image_from_another_host_fails(self) -> None:
        result = self.run_site(body='<img src="https://img.example.net/a.png" alt="">')
        self.assertEqual(result.returncode, 1)
        self.assertIn("another host", result.stderr)

    def test_style_sheet_from_another_host_fails(self) -> None:
        result = self.run_site(
            head='<link rel="stylesheet" href="https://fonts.example.net/f.css">'
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("another host", result.stderr)

    def test_font_from_another_host_in_css_fails(self) -> None:
        result = self.run_site(
            css='@font-face { src: url("https://fonts.example.net/f.woff2"); }'
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("another host", result.stderr)

    def test_css_import_from_another_host_fails(self) -> None:
        result = self.run_site(css='@import "https://fonts.example.net/f.css";')
        self.assertEqual(result.returncode, 1)
        self.assertIn("another host", result.stderr)


MATH_PAGE = """<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>t</title>
<script id="mathjax-config">window.MathJax = {{}};</script></head>
<body><p>{body}</p></body></html>
"""


@unittest.skipUnless(os.environ.get("MATHJAX_MODULES"), "MATHJAX_MODULES not set")
class CheckMath(unittest.TestCase):
    def run_math(self, body: str) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as name:
            root = pathlib.Path(name)
            (root / "index.html").write_text(MATH_PAGE.format(body=body))
            return subprocess.run(
                [
                    "node",
                    str(TOOLS / "check_math.cjs"),
                    os.environ["MATHJAX_MODULES"],
                    str(REPO / "data" / "mathjax.json"),
                    str(root),
                ],
                capture_output=True,
                text=True,
                check=False,
            )

    def test_good_formulas_pass(self) -> None:
        result = self.run_math(
            r"$x^2$ and $$\begin{equation}a=b\label{e}\end{equation}$$ see"
            r" $\eqref{e}$, &ldquo;quoted&rdquo; and $\boldsymbol{s}$"
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("4 formulas", result.stdout)

    def test_page_without_mathjax_is_skipped(self) -> None:
        with tempfile.TemporaryDirectory() as name:
            root = pathlib.Path(name)
            (root / "index.html").write_text("<html><body>$\\frac{1}$</body></html>")
            result = subprocess.run(
                [
                    "node",
                    str(TOOLS / "check_math.cjs"),
                    os.environ["MATHJAX_MODULES"],
                    str(REPO / "data" / "mathjax.json"),
                    str(root),
                ],
                capture_output=True,
                text=True,
                check=False,
            )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("0 pages", result.stdout)

    def test_malformed_formula_fails(self) -> None:
        result = self.run_math(r"$\frac{1}$")
        self.assertEqual(result.returncode, 1)
        self.assertIn("Missing argument", result.stderr)

    def test_unknown_command_fails(self) -> None:
        result = self.run_math(r"$\notacommand x$")
        self.assertEqual(result.returncode, 1)
        self.assertIn("notacommand", result.stderr)

    def test_undefined_reference_fails(self) -> None:
        result = self.run_math(r"$\eqref{nowhere}$")
        self.assertEqual(result.returncode, 1)
        self.assertIn("undefined label", result.stderr)

    def test_formula_broken_by_markup_fails(self) -> None:
        # What the Markdown processor leaves when it takes "<D<< a @>" for a
        # tag: the display is cut in two and MathJax sees no formula.
        result = self.run_math(
            r"$$ \begin{CD} 3n @</p><p>\lambda>> a \end{CD} $$ and $x$"
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("outside any formula", result.stderr)

    def test_dollars_in_code_are_ignored(self) -> None:
        result = self.run_math(r"<code>$$ \begin{x}</code> and $x$")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_require_fails(self) -> None:
        result = self.run_math(r"$\require{cancel} x$")
        self.assertEqual(result.returncode, 1)
        self.assertIn("require", result.stderr)


if __name__ == "__main__":
    unittest.main()
