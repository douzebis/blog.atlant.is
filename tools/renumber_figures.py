# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Renumber the figures of a paper.

usage: renumber_figures.py POST_DIR OLD=NEW [OLD=NEW ...] [--capture-list LIST.tsv]

POST_DIR holds the paper (index.md) and its pictures (images/figure-NN.*,
with a -dark twin).  Each OLD=NEW gives a figure its new number, for
instance "6=5 7=6" after Figure 5 was removed.  The tool changes, all at
once:

- every "Figure n" of the text, of the captions and of the picture names
  inside index.md;
- the names of the picture files;
- the first column of the capture list, if one is given.

It then prints the files outside POST_DIR that mention a figure by number
or by file name, for these are to be looked at by hand (programs that draw
or check the figures, notes).  A number may be given a number that another
figure has, as long as that one moves too: nothing is ever overwritten.
"""

import argparse
import pathlib
import re
import subprocess
import sys


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("post_dir", type=pathlib.Path)
    parser.add_argument("pairs", nargs="+", metavar="OLD=NEW")
    parser.add_argument("--capture-list", type=pathlib.Path)
    arguments = parser.parse_args()

    mapping: dict[int, int] = {}
    for pair in arguments.pairs:
        old, new = pair.split("=")
        mapping[int(old)] = int(new)
    post = arguments.post_dir / "index.md"
    text = post.read_text()
    present = {int(n) for n in re.findall(r"!\[Figure ([0-9]+)\]", text)}
    unknown = sorted(set(mapping) - present)
    if unknown:
        print(f"renumber_figures: no Figure {unknown[0]} in {post}", file=sys.stderr)
        return 1
    after = [mapping.get(n, n) for n in sorted(present)]
    if len(set(after)) != len(after):
        print(
            "renumber_figures: two figures would get the same number", file=sys.stderr
        )
        return 1

    def renumber(match: re.Match[str]) -> str:
        number = int(match.group(2))
        return f"{match.group(1)}{mapping.get(number, number)}"

    def renumber_file(match: re.Match[str]) -> str:
        number = int(match.group(1))
        return f"figure-{mapping.get(number, number):02d}"

    changed = re.sub(r"\b(Figures?\s+)([0-9]+)\b", renumber, text)
    # The other numbers of a list: "Figures 6 and 7", "Figures 8 to 10".
    changed = re.sub(
        r"(\bFigures\s+[0-9]+(?:,\s+[0-9]+)*(?:,?\s+and\s+|\s+to\s+))([0-9]+)\b",
        renumber,
        changed,
    )
    changed = re.sub(r"\bfigure-([0-9]{2})(?=[-.])", renumber_file, changed)
    post.write_text(changed)

    # The pictures, through temporary names so that nothing is overwritten.
    images = arguments.post_dir / "images"
    moves = []
    for picture in sorted(images.glob("figure-[0-9][0-9]*")):
        number = int(picture.name[7:9])
        if number in mapping:
            moves.append((picture, f"figure-{mapping[number]:02d}{picture.name[9:]}"))
    for picture, _ in moves:
        picture.rename(picture.with_name("renumbering-" + picture.name))
    for picture, name in moves:
        picture.with_name("renumbering-" + picture.name).rename(picture.with_name(name))

    if arguments.capture_list:
        rows = []
        for row in arguments.capture_list.read_text().split("\n"):
            number, tab, rest = row.partition("\t")
            if tab and number.isdigit():
                number = str(mapping.get(int(number), int(number)))
            rows.append(number + tab + rest)
        arguments.capture_list.write_text("\n".join(rows))

    print(
        f"renumber_figures: {len(mapping)} figures renumbered, {len(moves)} files renamed"
    )
    try:
        listing = subprocess.run(
            ["git", "grep", "-l", "-E", r"Figure [0-9]+|figure-[0-9]{2}", "--", "."],
            capture_output=True,
            text=True,
            check=False,
        ).stdout.split("\n")
    except FileNotFoundError:
        # No git here: the files outside the paper are not listed.
        listing = []
    inside = arguments.post_dir.as_posix().rstrip("/") + "/"
    outside = [name for name in listing if name and not name.startswith(inside)]
    if outside:
        print("to look at by hand, outside the paper:")
        for name in outside:
            print(f"  {name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
