# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Check the numbers that a paper types by hand.

usage: check_numbers.py CONTENT_DIR

Every index.md whose front matter says `math: true` is checked, except the
earlier versions of a paper (content/versions), which are kept as they were.

The statements, the figures, the sections and the parts of a paper carry
numbers that are written in its source, not counted by a program, because
they are quoted outside the paper and must not move silently.  This check
makes sure that they are consistent:

- the statements of each kind ("**Theorem 3.**", "**Lemma 1 (name).**")
  are numbered 1, 2, 3, ... in the order of the text, and the conjectures
  and questions together are lettered A, B, C, ...;
- the figures ("![Figure 4](...)") are numbered 1, 2, 3, ... in the order
  of the text, and each is followed by a caption that starts with
  "> Figure 4:";
- the numbered sections ("### 4. Title") are numbered 1, 2, 3, ..., and the
  parts ("## Part II. Title") I, II, III, ...;
- every "Figure n", "Section n" and "Part N" in the text names a figure, a
  section or a part that exists.

References to statements are checked by link_statements.py, which makes
them links.  Formulas, code and the front matter are not read.
"""

import pathlib
import re
import sys

KINDS = ("Theorem", "Lemma", "Proposition", "Corollary", "Fact")
LETTERED = ("Conjecture", "Question")
ROMAN = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

SKIPPED = re.compile(
    "|".join(
        [
            r"\A---\n.*?\n---\n",  # front matter
            r"^```.*?^```[^\n]*$",  # code block
            r"\$\$.*?\$\$",  # displayed formula
            r"\$[^$\n]*(?:\n[^$\n]+)?\$",  # formula in the text
            r"`[^`\n]*`",  # code in the text
            r"\]\([^)]*\)",  # the address of a link
        ]
    ),
    re.S | re.M,
)
SEPARATOR = r"(?:,\s+|\s+and\s+|,\s+and\s+|\s+to\s+)"


def consecutive(found: list[str], expected: list[str], what: str) -> list[str]:
    """Errors if `found` is not the start of `expected`."""
    errors = []
    for position, name in enumerate(found):
        wanted = expected[position] if position < len(expected) else "nothing"
        if name != wanted:
            errors.append(f"{what} {name} found where {what} {wanted} was expected")
            break
    return errors


def check(text: str) -> list[str]:
    errors: list[str] = []
    prose = SKIPPED.sub(lambda match: "\n" * match.group(0).count("\n"), text)

    # Statements, by kind.
    for kind in KINDS:
        numbers = re.findall(rf"^\*\*{kind} ([0-9]+)(?:\.| \()", prose, re.M)
        errors += consecutive(
            numbers, [str(n) for n in range(1, len(numbers) + 1)], kind
        )
    letters = re.findall(
        rf"^\*\*(?:{'|'.join(LETTERED)}) ([A-Z])(?:\.| \()", prose, re.M
    )
    errors += consecutive(
        letters,
        [chr(ord("A") + n) for n in range(len(letters))],
        "conjecture or question",
    )

    # Figures and their captions.
    lines = text.split("\n")
    figures: list[str] = []
    for index, line in enumerate(lines):
        match = re.match(r"^\[?!\[Figure ([0-9]+)\]", line)
        if match is None:
            continue
        number = match.group(1)
        figures.append(number)
        after = index + 1
        while after < len(lines) and lines[after] == "":
            after += 1
        if after == len(lines) or not lines[after].startswith(f"> Figure {number}:"):
            errors.append(f"Figure {number} is not followed by its caption")
    errors += consecutive(
        figures, [str(n) for n in range(1, len(figures) + 1)], "Figure"
    )

    # Sections and parts.
    sections = re.findall(r"^#{2,4} ([0-9]+)\. ", prose, re.M)
    errors += consecutive(
        sections, [str(n) for n in range(1, len(sections) + 1)], "Section"
    )
    parts = re.findall(r"^## Part ([IVX]+)\. ", prose, re.M)
    errors += consecutive(parts, ROMAN[: len(parts)], "Part")

    # References.
    # "Part 3" with a figure is a part of a statement, not of the paper.
    for word, numeral, known in (
        ("Figure", "[0-9]+", figures),
        ("Section", "[0-9]+", sections),
        ("Part", "[IVX]+", parts),
    ):
        pattern = re.compile(
            rf"\b{word}s?\s+({numeral})\b((?:{SEPARATOR}{numeral}\b)*)"
        )
        for match in pattern.finditer(prose):
            if prose[: match.start()].endswith("![") and word == "Figure":
                continue
            for name in [match.group(1)] + re.findall(numeral, match.group(2)):
                if name not in known:
                    errors.append(f"a reference to {word} {name}, which does not exist")
    return errors


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    content = pathlib.Path(sys.argv[1])
    checked = 0
    failed = 0
    for path in sorted(content.rglob("*.md")):
        if "versions" in path.relative_to(content).parts:
            continue
        text = path.read_text()
        front = re.match(r"---\n(.*?)\n---\n", text, re.S)
        if front is None or not re.search(r"^math:\s*true\s*$", front.group(1), re.M):
            continue
        checked += 1
        errors = check(text)
        for error in errors:
            print(f"numbers: {path}: {error}", file=sys.stderr)
        failed += len(errors)
    print(f"check_numbers: {checked} posts, {failed} errors")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
