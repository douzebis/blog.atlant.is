# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Compare the statements of two versions of a paper.

usage: compare_statements.py OLD.md NEW.md

A statement is a paragraph that starts with a bold "Theorem", "Lemma",
"Corollary", "Proposition", "Fact", "Conjecture" or "Question", together
with the list items and displayed formulas that follow it directly.  Text
after that (comments, proofs) is not part of the statement.  Statements
are matched by their label ("Theorem 3", "Lemma 1").  The report lists the
statements that were removed, added or reworded, with both wordings for the
last; white space and line breaks do not count.

The exit status is 0 when the statements are the same, 1 otherwise.  A
presentation overhaul is expected to end with status 0, or with every
reported difference explained in the paper's history.
"""

import argparse
import pathlib
import re
import sys

KINDS = "Theorem|Lemma|Corollary|Proposition|Fact|Conjecture|Question"
START = re.compile(rf"^\*\*((?:{KINDS})(?: [0-9A-Z]+)?)\b[^*]*\*\*")
# After a blank line, a statement goes on with a list item, a displayed
# formula or an indented line, and with nothing else.
CONTINUES = re.compile(r"^(\d+\.|[-*] |\$\$| )")


def statements(text: str) -> dict[str, str]:
    """The statements of a paper, by label, with white space normalized."""
    body = re.sub(r"\A---\n.*?\n---\n", "", text, flags=re.S)
    found: dict[str, str] = {}
    label = None
    lines: list[str] = []
    in_display = False

    def close() -> None:
        nonlocal label, lines
        if label is not None:
            found[label] = " ".join(" ".join(lines).split())
        label, lines = None, []

    previous_blank = True
    for line in body.split("\n"):
        start = START.match(line) if previous_blank and not in_display else None
        if start:
            close()
            label = start.group(1)
            lines = [line]
        elif label is not None:
            if previous_blank and not in_display and not CONTINUES.match(line):
                if line.strip():
                    close()
            else:
                lines.append(line)
        if label is not None and line.count("$$") % 2 == 1:
            in_display = not in_display
        if label is None:
            in_display = False
        previous_blank = line.strip() == ""
    close()
    return found


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("old", help="the earlier version (Markdown)")
    parser.add_argument("new", help="the later version (Markdown)")
    args = parser.parse_args()
    old = statements(pathlib.Path(args.old).read_text())
    new = statements(pathlib.Path(args.new).read_text())

    differences = 0
    for label in old:
        if label not in new:
            differences += 1
            print(f"removed: {label}")
    for label in new:
        if label not in old:
            differences += 1
            print(f"added: {label}")
    for label in old:
        if label in new and old[label] != new[label]:
            differences += 1
            print(f"reworded: {label}\n  old: {old[label]}\n  new: {new[label]}")
    print(
        f"compare_statements: {len(old)} statements before, {len(new)} after, "
        f"{differences} differences"
    )
    return 1 if differences else 0


if __name__ == "__main__":
    sys.exit(main())
