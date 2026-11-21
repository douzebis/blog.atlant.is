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


class CheckFrozen(unittest.TestCase):
    def run_frozen(
        self, root: pathlib.Path, *more: str
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [
                sys.executable,
                str(TOOLS / "check_frozen.py"),
                str(root / "record"),
                "--root",
                str(root),
                *more,
            ],
            capture_output=True,
            text=True,
            check=False,
        )

    def test_frozen_version_lifecycle(self) -> None:
        with tempfile.TemporaryDirectory() as name:
            root = pathlib.Path(name)
            version = root / "content" / "versions" / "paper" / "2026-01-01"
            (version / "images").mkdir(parents=True)
            (version / "index.md").write_text("text\n")
            (version / "images" / "a.png").write_bytes(b"picture")

            # Only a version can be frozen.
            result = self.run_frozen(root, "--freeze", "content/versions/nothing")
            self.assertEqual(result.returncode, 1)
            self.assertIn("not a version", result.stderr)

            # A version that is not in the record is an error.
            result = self.run_frozen(root)
            self.assertEqual(result.returncode, 1)
            self.assertIn("not in the record", result.stderr)

            name_in_record = "content/versions/paper/2026-01-01"
            result = self.run_frozen(root, "--freeze", name_in_record)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(self.run_frozen(root).returncode, 0)

            # Freezing twice is refused.
            self.assertEqual(
                self.run_frozen(root, "--freeze", name_in_record).returncode, 1
            )

            # A changed text, a changed picture, a new file, a renamed file.
            (version / "index.md").write_text("other text\n")
            self.assertIn("modified", self.run_frozen(root).stderr)
            (version / "index.md").write_text("text\n")
            self.assertEqual(self.run_frozen(root).returncode, 0)
            (version / "images" / "a.png").write_bytes(b"other picture")
            self.assertIn("modified", self.run_frozen(root).stderr)
            (version / "images" / "a.png").write_bytes(b"picture")
            (version / "new.txt").write_text("")
            self.assertIn("modified", self.run_frozen(root).stderr)
            (version / "new.txt").unlink()
            (version / "images" / "a.png").rename(version / "images" / "b.png")
            self.assertIn("modified", self.run_frozen(root).stderr)
            (version / "images" / "b.png").rename(version / "images" / "a.png")
            self.assertEqual(self.run_frozen(root).returncode, 0)

            # A recorded version that disappeared.
            (version / "index.md").unlink()
            (version / "images" / "a.png").unlink()
            (version / "images").rmdir()
            version.rmdir()
            self.assertIn("missing", self.run_frozen(root).stderr)


PAPER = """---
title: t
---

Some text.

**Theorem 1.** For all $n$:

1. first claim;
2. second claim,
   $$x = y.$$

In words: a comment that is not part of the statement.

*Proof.* Clear. $\\Box$

**Lemma 2 (name).** A single
paragraph.

**Conjecture A (thing).** Maybe.
"""


class FigureNumbering(unittest.TestCase):
    """The live figures number the beads from 0 unless asked otherwise: the
    earlier versions of the rosary paper link to them without a parameter
    (docs/specs/0003-rosary-beads-counted-from-1.md)."""

    def test_default_is_zero(self) -> None:
        source = (REPO / "figures" / "jane-s-rosary" / "janestreet.js").read_text()
        self.assertIn(
            "const FIRST = new URLSearchParams(window.location.search)"
            ".get('first') == '1' ? 1 : 0",
            source,
        )

    def test_earlier_versions_do_not_ask_for_it(self) -> None:
        for version in (REPO / "content" / "versions").glob("*/*/index.md"):
            self.assertNotIn("first=1", version.read_text(), version)


class CompareStatements(unittest.TestCase):
    def compare(self, old: str, new: str) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as name:
            root = pathlib.Path(name)
            (root / "old.md").write_text(old)
            (root / "new.md").write_text(new)
            return subprocess.run(
                [
                    sys.executable,
                    str(TOOLS / "compare_statements.py"),
                    str(root / "old.md"),
                    str(root / "new.md"),
                ],
                capture_output=True,
                text=True,
                check=False,
            )

    def test_same_statements(self) -> None:
        result = self.compare(PAPER, PAPER)
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertIn("3 statements before, 3 after, 0 differences", result.stdout)

    def test_presentation_changes_do_not_count(self) -> None:
        new = PAPER.replace("Some text.", "Another opening.\n\n## A heading")
        new = new.replace("In words: a comment", "In other words: a remark")
        new = new.replace("*Proof.* Clear.", "*Proof.* By a longer argument.")
        new = new.replace("A single\nparagraph.", "A single paragraph.")
        result = self.compare(PAPER, new)
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_reworded_statement_is_reported(self) -> None:
        result = self.compare(
            PAPER, PAPER.replace("second claim", "second claim, weaker")
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("reworded: Theorem 1", result.stdout)

    def test_changed_formula_in_statement_is_reported(self) -> None:
        result = self.compare(PAPER, PAPER.replace("$$x = y.$$", "$$x = z.$$"))
        self.assertEqual(result.returncode, 1)
        self.assertIn("reworded: Theorem 1", result.stdout)

    def test_removed_and_added_statements_are_reported(self) -> None:
        new = PAPER.replace("**Lemma 2 (name).** A single\nparagraph.\n\n", "")
        new += "\n**Question B (other).** Why?\n"
        result = self.compare(PAPER, new)
        self.assertEqual(result.returncode, 1)
        self.assertIn("removed: Lemma 2", result.stdout)
        self.assertIn("added: Question B", result.stdout)

    def test_links_to_statements_do_not_count(self) -> None:
        new = PAPER.replace(
            "**Lemma 2 (name).** A single",
            "**Lemma 2 (name).** By [Theorem 1](#theorem-1), a single",
        )
        old = PAPER.replace(
            "**Lemma 2 (name).** A single",
            "**Lemma 2 (name).** By Theorem 1, a single",
        )
        result = self.compare(old, new)
        self.assertEqual(result.returncode, 0, result.stdout)


LINKED = """---
title: "Theorem 9 in the front matter"
---

## 1. About Theorem 1

**Theorem 1.** A claim.

*Proof of Theorem 1.* By Lemma 2 and by Theorem
1 itself, see $\\text{Lemma 2}$ and `Lemma 2`. $\\quad\\Box$

**Lemma 2 (name).** Another claim, used in Theorems 1 and 3 and in
Conjectures A to C. (It was "Lemma 7" once.)

**Theorem 3.** A third.

**Conjecture A (first).** One.

**Conjecture C (third).** Three.
"""


class LinkStatements(unittest.TestCase):
    def run_tool(
        self, text: str, *options: str
    ) -> tuple[subprocess.CompletedProcess[str], str]:
        with tempfile.TemporaryDirectory() as name:
            post = pathlib.Path(name) / "index.md"
            post.write_text(text)
            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOLS / "link_statements.py"),
                    str(post),
                    *options,
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            return result, post.read_text()

    def test_references_become_links(self) -> None:
        result, text = self.run_tool(LINKED)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("By [Lemma 2](#lemma-2) and by [Theorem\n1](#theorem-1)", text)
        self.assertIn("[Theorems 1](#theorem-1) and [3](#theorem-3)", text)
        self.assertIn("[Conjectures A](#conjecture-A) to [C](#conjecture-C)", text)

    def test_heads_formulas_code_and_quotes_are_left_alone(self) -> None:
        _, text = self.run_tool(LINKED)
        for kept in (
            'title: "Theorem 9 in the front matter"',
            "## 1. About Theorem 1",
            "**Theorem 1.** A claim.",
            "*Proof of Theorem 1.*",
            "$\\text{Lemma 2}$ and `Lemma 2`",
            '"Lemma 7"',
        ):
            self.assertIn(kept, text)

    def test_running_twice_changes_nothing(self) -> None:
        _, once = self.run_tool(LINKED)
        result, twice = self.run_tool(once)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(once, twice)

    def test_check_reports_references_that_are_not_links(self) -> None:
        result, text = self.run_tool(LINKED, "--check")
        self.assertEqual(result.returncode, 1)
        self.assertEqual(text, LINKED)
        _, linked = self.run_tool(LINKED)
        result, _ = self.run_tool(linked, "--check")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_reference_to_a_missing_statement_fails(self) -> None:
        result, text = self.run_tool(LINKED + "\nSee Lemma 5.\n")
        self.assertEqual(result.returncode, 1)
        self.assertIn("no statement for #lemma-5", result.stderr)

    def test_the_rosary_paper_is_linked(self) -> None:
        post = REPO / "content/posts/2022-12-02-jane-s-infinite-rosary/index.md"
        result = subprocess.run(
            [sys.executable, str(TOOLS / "link_statements.py"), str(post), "--check"],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)


NUMBERED = """---
title: "t"
math: true
---

## Part I. First

### 1. One

**Theorem 1.** A claim, see Figure 1 and Section 2, in Part I.

![Figure 1](images/figure-01.png)

> Figure 1: a picture.

### 2. Two

**Lemma 1 (name).** Another, by parts 1 and 2 of the theorem. Part 2 is easy.

**Conjecture A (first).** One. $\\text{Figure 9}$ is not a reference.

**Question B.** Two?

![Figure 2](images/figure-02.png)

> Figure 2: another picture.
"""


class CheckNumbers(unittest.TestCase):
    def run_check(self, text: str) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as name:
            post = pathlib.Path(name) / "posts" / "paper"
            post.mkdir(parents=True)
            (post / "index.md").write_text(text)
            return subprocess.run(
                [sys.executable, str(TOOLS / "check_numbers.py"), name],
                capture_output=True,
                text=True,
                check=False,
            )

    def test_consistent_numbers_pass(self) -> None:
        result = self.run_check(NUMBERED)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("1 posts, 0 errors", result.stdout)

    def test_gap_in_the_figures_fails(self) -> None:
        text = NUMBERED.replace("![Figure 2]", "![Figure 3]").replace(
            "> Figure 2:", "> Figure 3:"
        )
        result = self.run_check(text)
        self.assertEqual(result.returncode, 1)
        self.assertIn("Figure 3 found where Figure 2 was expected", result.stderr)

    def test_figure_without_caption_fails(self) -> None:
        result = self.run_check(NUMBERED.replace("> Figure 2: another", "> Another"))
        self.assertEqual(result.returncode, 1)
        self.assertIn("Figure 2 is not followed by its caption", result.stderr)

    def test_repeated_statement_number_fails(self) -> None:
        result = self.run_check(NUMBERED + "\n**Theorem 1.** Again.\n")
        self.assertEqual(result.returncode, 1)
        self.assertIn("Theorem 1 found where Theorem 2 was expected", result.stderr)

    def test_skipped_letter_fails(self) -> None:
        result = self.run_check(NUMBERED.replace("**Question B.**", "**Question C.**"))
        self.assertEqual(result.returncode, 1)
        self.assertIn("C found where", result.stderr)

    def test_skipped_section_fails(self) -> None:
        result = self.run_check(NUMBERED.replace("### 2. Two", "### 3. Two"))
        self.assertEqual(result.returncode, 1)
        self.assertIn("Section 3 found where Section 2 was expected", result.stderr)

    def test_reference_to_a_missing_figure_or_section_fails(self) -> None:
        result = self.run_check(NUMBERED + "\nSee Figures 1 and 5, and Section 7.\n")
        self.assertEqual(result.returncode, 1)
        self.assertIn("a reference to Figure 5", result.stderr)
        self.assertIn("a reference to Section 7", result.stderr)

    def test_reference_to_a_missing_part_fails(self) -> None:
        result = self.run_check(NUMBERED + "\nSee Part II.\n")
        self.assertEqual(result.returncode, 1)
        self.assertIn("a reference to Part II", result.stderr)

    def test_the_papers_of_the_site_pass(self) -> None:
        result = subprocess.run(
            [sys.executable, str(TOOLS / "check_numbers.py"), str(REPO / "content")],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)


class RenumberFigures(unittest.TestCase):
    def test_figures_files_and_list_are_renumbered(self) -> None:
        with tempfile.TemporaryDirectory() as name:
            post = pathlib.Path(name) / "paper"
            (post / "images").mkdir(parents=True)
            text = (
                "See Figure 2, Figures 2 and 3, and Figure\n10.\n\n"
                "![Figure 2](images/figure-02.png)\n\n> Figure 2: two.\n\n"
                "![Figure 3](images/figure-03.svg)\n\n> Figure 3: three.\n\n"
                "![Figure 10](images/figure-10.png)\n\n> Figure 10: ten.\n"
            )
            (post / "index.md").write_text(text)
            for picture in (
                "figure-02.png",
                "figure-02-dark.png",
                "figure-03.svg",
                "figure-10.png",
            ):
                (post / "images" / picture).write_text(picture)
            capture = pathlib.Path(name) / "list.tsv"
            capture.write_text("2\ta\t2\n10\tb\t2")
            result = subprocess.run(
                [
                    sys.executable,
                    str(TOOLS / "renumber_figures.py"),
                    str(post),
                    "2=1",
                    "3=2",
                    "10=3",
                    "--capture-list",
                    str(capture),
                ],
                capture_output=True,
                text=True,
                check=False,
                cwd=name,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            changed = (post / "index.md").read_text()
            self.assertIn("See Figure 1, Figures 1 and 2, and Figure\n3.", changed)
            self.assertIn("![Figure 3](images/figure-03.png)", changed)
            self.assertIn("> Figure 2: three.", changed)
            names = sorted(p.name for p in (post / "images").iterdir())
            self.assertEqual(
                names,
                [
                    "figure-01-dark.png",
                    "figure-01.png",
                    "figure-02.svg",
                    "figure-03.png",
                ],
            )
            self.assertEqual(
                (post / "images" / "figure-03.png").read_text(), "figure-10.png"
            )
            self.assertEqual(capture.read_text(), "1\ta\t2\n3\tb\t2")

    def test_unknown_figure_is_refused(self) -> None:
        with tempfile.TemporaryDirectory() as name:
            post = pathlib.Path(name) / "paper"
            (post / "images").mkdir(parents=True)
            (post / "index.md").write_text("![Figure 1](images/figure-01.png)\n")
            result = subprocess.run(
                [sys.executable, str(TOOLS / "renumber_figures.py"), str(post), "4=2"],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(result.returncode, 1)
            self.assertIn("no Figure 4", result.stderr)


if __name__ == "__main__":
    unittest.main()
