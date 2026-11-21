# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Turn the references to the statements of a paper into links.

usage: link_statements.py POST.md [--check]

A reference such as "Theorem 3", "Lemmas 4 and 5" or "Conjecture A" becomes
a link to the place where the statement is given: `[Theorem 3](#theorem-3)`.
The page template gives every statement the matching identifier (see
layouts/_partials/statement-anchors.html), and the LaTeX version gives it
the matching label.

Left alone: the front matter, headings, the head of a statement
("**Theorem 3.**"), the head of a proof ("*Proof of Theorem 6.*"),
formulas, code, and whatever is already a link.  Running the tool twice
changes nothing.

With --check nothing is written: the exit status is 1 if a reference is
not a link yet, or if a link names a statement that the paper does not
have.
"""

import argparse
import pathlib
import re
import sys

KINDS = {
    "Theorem": "Theorems",
    "Lemma": "Lemmas",
    "Corollary": "Corollaries",
    "Proposition": "Propositions",
    "Fact": "Facts",
    "Conjecture": "Conjectures",
    "Question": "Questions",
}
SINGULAR = {plural: singular for singular, plural in KINDS.items()}
NUMBER = r"(?:[0-9]+|[A-Z])"
HEAD = re.compile(rf"^\*\*((?:{'|'.join(KINDS)}) {NUMBER})(?: \([^)]*\))?\.\*\*", re.M)

# What is never touched, in the order in which it is looked for.
PROTECTED = re.compile(
    "|".join(
        [
            r"\A---\n.*?\n---\n",  # front matter
            r"^```.*?^```[^\n]*$",  # code block
            r"^#{1,6} [^\n]*$",  # heading
            rf"^\*\*(?:{'|'.join(KINDS)}) [^*\n]*\*\*",  # head of a statement
            r"^\*Proof[^*\n]*\*",  # head of a proof
            r"\$\$.*?\$\$",  # displayed formula
            r"\$[^$\n]*(?:\n[^$\n]+)?\$",  # formula in the text
            r"`[^`\n]*`",  # code in the text
            r"!?\[[^\]]*\]\([^)]*\)",  # link or picture
            r"<[^>\n]*>",  # HTML tag
            r'"[^"\n]*"',  # quoted words, such as the old name of a statement
        ]
    ),
    re.S | re.M,
)

REFERENCE = re.compile(
    rf"\b({'|'.join(KINDS)}|{'|'.join(SINGULAR)})(\s+)({NUMBER})\b"
    rf"((?:(?:,\s+|\s+and\s+|,\s+and\s+|\s+to\s+){NUMBER}\b)*)"
)
FOLLOWING = re.compile(rf"(,\s+and\s+|,\s+|\s+and\s+|\s+to\s+)({NUMBER})\b")
LINK = re.compile(r"\]\(#([a-z]+-(?:[0-9]+|[A-Z]))\)")


def anchor(kind: str, number: str) -> str:
    return f"{kind.lower()}-{number}"


def link_text(text: str) -> tuple[str, int]:
    """The text with its references linked, and how many were linked."""
    count = 0

    def link(match: re.Match[str]) -> str:
        nonlocal count
        word, space, number, rest = match.groups()
        kind = SINGULAR.get(word, word)
        if word in KINDS and rest:
            # "Theorem 3 and 4" is not how a list is written: only the first
            # number belongs to the reference.
            return link_one(word, space, number, kind) + rest
        out = link_one(word, space, number, kind)
        for separator, other in FOLLOWING.findall(rest):
            count += 1
            out += f"{separator}[{other}](#{anchor(kind, other)})"
        return out

    def link_one(word: str, space: str, number: str, kind: str) -> str:
        nonlocal count
        count += 1
        return f"[{word}{space}{number}](#{anchor(kind, number)})"

    out: list[str] = []
    position = 0
    for protected in PROTECTED.finditer(text):
        out.append(REFERENCE.sub(link, text[position : protected.start()]))
        out.append(protected.group(0))
        position = protected.end()
    out.append(REFERENCE.sub(link, text[position:]))
    return "".join(out), count


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("post", type=pathlib.Path)
    parser.add_argument("--check", action="store_true")
    arguments = parser.parse_args()

    text = arguments.post.read_text()
    linked, count = link_text(text)
    known = {anchor(*head.split(" ")) for head in HEAD.findall(text)}
    unknown = sorted(set(LINK.findall(linked)) - known)
    for name in unknown:
        print(f"link_statements: no statement for #{name}", file=sys.stderr)

    if arguments.check:
        if count:
            print(f"link_statements: {count} references are not links", file=sys.stderr)
        print(f"link_statements: {len(known)} statements, {count} to link")
        return 1 if count or unknown else 0
    if unknown:
        return 1
    arguments.post.write_text(linked)
    print(f"link_statements: {len(known)} statements, {count} references linked")
    return 0


if __name__ == "__main__":
    sys.exit(main())
