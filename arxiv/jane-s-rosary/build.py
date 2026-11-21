# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Make the LaTeX version of the paper *Jane's infinite rosary* for arXiv.

usage: build.py POST_DIR OUT_DIR

Reads POST_DIR/index.md (the source of the web page) and writes, in
OUT_DIR, `paper.tex` and its figures, ready for `pdflatex`.  The web page
stays the only source of the text: this program adapts what is specific to
the web (figures that link to interactive pages, the history kept in the
front matter) and stops with an error if a passage it expects to adapt is
no longer there.

Needs `pandoc` and `rsvg-convert` on the PATH.
"""

import pathlib
import re
import shutil
import subprocess
import sys

TITLE = "Jane's infinite rosary: shortest paths and the reluctant walk on the infinite sidewalk"
AUTHOR = "Frédéric Ruget"
ABSTRACT = """\
Jane tells the beads of an infinite rosary: from bead $n$ she moves up or
down by $\\lceil n/2 \\rceil$ beads. This is Jane Street's puzzle
\\emph{Traversing the Infinite Sidewalk}. We describe the shortest ways to
each bead and compute their length in logarithmic time. We then study the
reluctant recitation, in which Jane moves down whenever the bead below has
not been told yet, and up otherwise. We prove that it never gets stuck,
that it tells every bead exactly once, as conjectured in an earlier
version of this paper, that Jane moves up with frequency $\\log 2/\\log 3$, and that
bead $m$ is told after at most polynomially many moves. Along the way the
beads congruent to $1$ modulo $3$ are shown to carry a tree in which every
node has infinitely many children. The main results have been formalized
and checked in the Lean proof assistant.

**MSC 2020:** 11B83 (primary); 11J82, 11K06, 68V20 (secondary).
**Keywords:** integer sequences, permutation of the integers,
powers of 3/2, irrational rotation, irrationality exponent, formal proof,
Lean.
"""

PAGE = (
    "https://douzebis.github.io/blog.atlant.is/posts/2022-12-02-jane-s-infinite-rosary/"
)

# Passages of the web page that are reworded for the paper: (web, paper).
REWORDINGS = [
    (
        "reached from bead $1$. The fun starts with two finer questions.",
        "reached from bead $1$. This paper is about two finer questions.",
    ),
    (
        "**And what is still open.** Plenty; Section 12 has seven questions. A\nfavorite: in the",
        "**What is still open.** Section 12 has seven questions. For instance: in the",
    ),
    (
        "is the easiest to state and the most teasing: is a certain",
        "is the easiest to state and the most intriguing: is a certain",
    ),
    (
        "kept with the sources of this site, in",
        "kept with the sources of this paper, in",
    ),
    (
        "nothing but the numbers (see the history) |",
        "nothing but the numbers (see the versions at the end) |",
    ),
]

# Section titles that are reworded for the paper: web title -> paper title.
# The links inside the text keep pointing to the web title's identifier.
TITLES = {
    "1. Prelude: names": "1. Notation and names",
    "4. Interlude: more names": "4. More names: chains, seeds and lambdexes",
    "9. Interlude: for a few names more": "9. Names for the onyx rosary",
}

# The quotations placed under some headings of the web page.  The paper
# keeps one of them.
EPIGRAPHS = 6
KEPT_EPIGRAPH = "Bartleby"

TEASER = (
    "![](images/reluctant-jane-1024x422.png)\n\n"
    "> Reluctant Jane at work (a detail of Figure 8).\n\n"
)

HEADER = r"""
\usepackage{amscd}
\usepackage{amsthm}
\usepackage{float}
\usepackage{tikz}
% The marks that give the color of a bead in a diagram.  The web page
% defines the same four commands for MathJax (data/mathjax.json).
\newcommand{\blackmark}{\tikz[baseline=-0.6ex]\fill[black!60] (0,0) circle (0.62ex);}
\newcommand{\whitemark}{\tikz[baseline=-0.6ex]\draw[black!55, fill=black!6, line width=0.3pt] (0,0) circle (0.62ex);}
\newcommand{\blackbead}[1]{\underset{\textstyle\blackmark}{#1}}
\newcommand{\whitebead}[1]{\underset{\textstyle\whitemark}{#1}}
\floatplacement{figure}{htbp}
\renewcommand{\arraystretch}{1.15}
% Statements keep the numbers of the web page: the label is given by hand.
\newcommand{\stmtname}{}
\theoremstyle{plain}
\newtheorem*{stmtplain}{\stmtname}
\theoremstyle{definition}
\newtheorem*{stmtupright}{\stmtname}
\newenvironment{named}[1]{\renewcommand{\stmtname}{#1}\begin{stmtplain}}{\end{stmtplain}}
\newenvironment{namedupright}[1]{\renewcommand{\stmtname}{#1}\begin{stmtupright}}{\end{stmtupright}}
% Sections without a number that still appear in the table of contents.
\newcommand{\unnumbered}[1]{\section*{#1}\addcontentsline{toc}{section}{#1}}
\newcommand{\unnumberedpart}[1]{\part*{#1}\addcontentsline{toc}{part}{#1}}
"""

STATEMENT = re.compile(
    r"^\*\*((?:Theorem|Lemma|Corollary|Proposition|Fact|Conjecture|Question) [0-9A-Z]+)"
    r"(?: \(([^)]*)\))?\.\*\* ?"
)
CONTINUES = re.compile(r"^(\d+\.|[-*] |\$\$| )")
BOX = "$\\quad\\Box$"


def raw(latex: str) -> str:
    return f"`{latex}`{{=latex}}"


def anchor(title: str) -> str:
    """The identifier that the web page gives to a heading."""
    kept = re.sub(r"[^a-z0-9 -]", "", title.lower())
    return kept.replace(" ", "-")


def adapt_headings(body: str) -> str:
    """Parts, numbered sections and unnumbered ones, as LaTeX makes them."""
    out: list[str] = []
    expected = 1
    fenced = False
    seen_titles: set[str] = set()
    for line in body.split("\n"):
        if line.startswith("```"):
            fenced = not fenced
        heading = None if fenced else re.match(r"^(#{2,4}) (.*)$", line)
        if heading is None:
            out.append(line)
            continue
        level, title = len(heading.group(1)), heading.group(2)
        if re.search(r"[*`\[]", title):
            fail(f"a heading with markup: {title!r}")
        label = f"\\label{{{anchor(title)}}}"
        if title in TITLES:
            seen_titles.add(title)
            title = TITLES[title]
        part = re.match(r"^Part [IVX]+\. (.*)$", title)
        numbered = re.match(r"^(\d+)\. (.*)$", title)
        if level == 2 and part:
            latex = f"\\part{{{part.group(1)}}}{label}"
        elif level == 2 and title == "Coda":
            latex = f"\\unnumberedpart{{{title}}}{label}"
        elif level == 3 and numbered:
            if int(numbered.group(1)) != expected:
                fail(f"section {numbered.group(1)} where {expected} was expected")
            expected += 1
            latex = f"\\section{{{numbered.group(2)}}}{label}"
        elif level in (2, 3):
            latex = f"\\unnumbered{{{title}}}{label}"
        else:
            latex = f"\\subsection*{{{title}}}{label}"
        out += ["```{=latex}", latex, "```"]
    if seen_titles != set(TITLES):
        fail(f"section titles to reword not found: {sorted(set(TITLES) - seen_titles)}")
    return "\n".join(out)


def drop_epigraphs(body: str) -> str:
    """Remove the quotations that follow a heading, except one.  To be
    called when the captions of the figures, the only other quotations of
    the page, have been turned into figures."""
    blocks = re.split(r"\n{2,}", body)
    out: list[str] = []
    found = 0
    for block in blocks:
        if block.startswith(">"):
            found += 1
            if KEPT_EPIGRAPH not in block:
                continue
        out.append(block)
    if found != EPIGRAPHS:
        fail(f"{found} quotations found where {EPIGRAPHS} were expected")
    return "\n\n".join(out)


def adapt_statements(body: str) -> str:
    """Theorems, lemmas and the like as theorem environments."""
    lines = body.split("\n")
    out: list[str] = []
    inside = False
    in_display = False
    previous_blank = True

    def close() -> None:
        nonlocal inside
        if inside:
            while out and out[-1] == "":
                out.pop()
            out.extend(["", "```{=latex}", "\\end{" + environment + "}", "```", ""])
            inside = False

    environment = "named"
    for line in lines:
        start = STATEMENT.match(line) if previous_blank and not in_display else None
        if start:
            close()
            name, title = start.group(1), start.group(2)
            environment = (
                "namedupright"
                if name.split()[0] in ("Conjecture", "Question")
                else "named"
            )
            head = f"\\begin{{{environment}}}{{{name}}}" + (
                f"[{title}]" if title else ""
            )
            out.append(raw(head) + " " + line[start.end() :])
            inside = True
        elif (
            inside
            and previous_blank
            and not in_display
            and not CONTINUES.match(line)
            and line.strip()
        ):
            close()
            out.append(line)
        else:
            out.append(line)
        if line.count("$$") % 2 == 1:
            in_display = not in_display
        previous_blank = line.strip() == ""
    close()
    return "\n".join(out)


def adapt_proofs(body: str) -> str:
    """Proofs as proof environments, with the square at their end."""
    lines = body.split("\n")
    out: list[str] = []
    open_proofs = 0
    pending_end = False
    for line in lines:
        if pending_end and line.strip() == "":
            out.extend(["", "```{=latex}", "\\end{proof}", "```"])
            pending_end = False
        start = re.match(r"^\*Proof( of [^*]*)?\.\* ?", line)
        if start:
            if open_proofs:
                fail("a proof starts inside another one")
            open_proofs = 1
            option = f"[Proof{start.group(1)}]" if start.group(1) else ""
            line = raw("\\begin{proof}" + option) + " " + line[start.end() :]
        if BOX in line:
            if not open_proofs:
                fail("the end of a proof without its start")
            # Inside a list item the square is placed by hand and the proof
            # is closed after the list; in a paragraph the proof ends there.
            in_list = line.startswith(" ")
            mark = raw("\\qedhere") if in_list else raw("\\end{proof}")
            line = line.replace(" " + BOX, mark).replace(BOX, mark)
            open_proofs = 0
            pending_end = in_list
        out.append(line)
    if open_proofs or pending_end:
        fail("a proof is not closed")
    return "\n".join(out)


def fail(message: str) -> None:
    print(f"build.py: {message}", file=sys.stderr)
    sys.exit(1)


def split_front_matter(text: str) -> tuple[str, str]:
    match = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if match is None:
        fail("no front matter")
        raise AssertionError
    return match.group(1), text[match.end() :]


def history(front: str) -> list[tuple[str, str]]:
    """The (date, text) entries of the history kept in the front matter."""
    entries = re.findall(r'- date: "([^"]+)"\n\s+text: "((?:[^"\\]|\\.)*)"', front)
    if not entries:
        fail("no history in the front matter")
    return entries


def caption_text(lines: list[str], number: int) -> str:
    text = " ".join(line[1:].strip() for line in lines)
    prefix = f"Figure {number}: "
    if not text.startswith(prefix):
        fail(f"the caption of figure {number} does not start with {prefix!r}")
    text = text[len(prefix) :]
    text = re.sub(r"\s*\(\[live version\]\([^)]*\)\)", "", text)
    text = re.sub(r"\s*Click the picture[^.]*(?=\.)", "", text)
    text = re.sub(r"\.\.$", ".", text.strip())
    return text[0].upper() + text[1:]


def adapt_figures(body: str, images: set[str]) -> str:
    """Replace each picture and its caption (a quotation below it) by a
    figure with that caption."""
    lines = body.split("\n")
    out: list[str] = []
    expected = 1
    i = 0
    image = re.compile(r"^\[?!\[Figure (\d+)\]\(images/([^)]+)\)")
    while i < len(lines):
        match = image.match(lines[i])
        if match is None:
            out.append(lines[i])
            i += 1
            continue
        number, name = int(match.group(1)), match.group(2)
        if number != expected:
            fail(f"figure {number} found where figure {expected} was expected")
        expected += 1
        i += 1
        while i < len(lines) and lines[i] == "":
            i += 1
        quoted = []
        while i < len(lines) and lines[i].startswith(">"):
            quoted.append(lines[i])
            i += 1
        if not quoted:
            fail(f"figure {number} has no caption")
        images.add(name)
        target = name[:-4] + ".pdf" if name.endswith(".svg") else name
        out.append(
            f"![{caption_text(quoted, number)}]({target}){{#fig-{number} width=100%}}"
        )
        out.append("")
    return "\n".join(out)


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__)
        return 2
    post, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)
    front, body = split_front_matter((post / "index.md").read_text())

    if body.count(TEASER) != 1:
        fail("the opening picture is not where it was")
    body = body.replace(TEASER, "")
    for web, paper in REWORDINGS:
        if body.count(web) != 1:
            fail(f"passage to reword not found exactly once: {web!r}")
        body = body.replace(web, paper)
    opening = "Jane owns a special rosary."
    still_open = "**What is still open.**"
    if body.count(opening) != 1 or body.count(still_open) != 1:
        fail("the opening is not where it was")
    related = (
        post.parent.parent.parent / "arxiv" / "jane-s-rosary" / "related.md"
    ).read_text()
    body = body.replace(opening, "## Introduction\n\n" + opening)
    body = body.replace(still_open, related + still_open)
    images: set[str] = set()
    body = adapt_figures(body, images)
    body = drop_epigraphs(body)
    body = adapt_statements(body)
    body = adapt_proofs(body)
    for leftover in ("history above", "live version", "this site", "Click the picture"):
        if leftover in body:
            fail(f"web-only wording left in the text: {leftover!r}")

    versions = "\n".join(
        f"- *{date}.* " + text.replace("log₂ 3", "$\\log_2 3$")
        for date, text in history(front)
    )
    body += (
        "\n## Versions of this paper\n\n"
        "This paper is also a web page, with interactive versions of its figures, "
        f"at <{PAGE}>; its "
        "sources, the programs and the Lean files are at "
        "<https://github.com/douzebis/blog.atlant.is>. The earlier versions are kept "
        "there and can be compared.\n\n" + versions + "\n"
    )
    declaration = (
        post.parent.parent.parent / "arxiv" / "jane-s-rosary" / "declaration.md"
    )
    body += "\n" + declaration.read_text()
    body = adapt_headings(body)

    for name in sorted(images):
        source = post / "images" / name
        if name.endswith(".svg"):
            subprocess.run(
                [
                    "rsvg-convert",
                    "-f",
                    "pdf",
                    "-o",
                    str(out / (name[:-4] + ".pdf")),
                    str(source),
                ],
                check=True,
            )
        else:
            shutil.copy(source, out / name)

    (out / "body.md").write_text(body)
    (out / "header.tex").write_text(HEADER)
    (out / "meta.yaml").write_text(
        f'title: "{TITLE}"\nauthor: "{AUTHOR}"\n'
        "abstract: |\n" + "".join(f"  {line}\n" for line in ABSTRACT.splitlines())
    )
    subprocess.run(
        [
            "pandoc",
            "--from=markdown+smart+gfm_auto_identifiers-fancy_lists-example_lists",
            "--to=latex",
            "--standalone",
            "--shift-heading-level-by=-1",
            "--no-highlight",
            "--metadata-file=meta.yaml",
            "--number-sections",
            "--toc",
            "--toc-depth=1",
            "--include-in-header=header.tex",
            "--variable=documentclass:article",
            "--variable=classoption:11pt",
            "--variable=geometry:margin=1in",
            "--variable=colorlinks:true",
            "--variable=linkcolor:black",
            "--variable=urlcolor:blue",
            "--fail-if-warnings",
            "--output=paper.tex",
            "body.md",
        ],
        cwd=out,
        check=True,
    )
    tex = (out / "paper.tex").read_text()
    labels = set(re.findall(r"\\label\{([^}]*)\}", tex))
    for target in sorted(set(re.findall(r"\\hyperref\[([^\]]*)\]", tex))):
        if target not in labels:
            fail(f"a link inside the paper has no target: {target}")
    for scratch in ("body.md", "header.tex", "meta.yaml"):
        (out / scratch).unlink()
    print(f"build.py: wrote {out}/paper.tex and {len(images)} figures")
    return 0


if __name__ == "__main__":
    sys.exit(main())
