# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Score the candidate strategies of candidates/ and keep the log.

usage: candidates.py [BINARY]

Each file candidates/NNNN-name.txt is a program of the small language
(src/lang.rs).  Its text is given to `players eval` on its standard
input, never to a shell or to Python.  The scores go to
candidates/log.tsv, one line per candidate: number, name, author, parent,
and the wins on 2 to 6 hats (or the reason why it was refused).

The author and the parent of a candidate are read from candidates/meta.tsv
(number, author, parent, note), which is written by hand.
"""

import pathlib
import subprocess
import sys

HATS = (2, 3, 4, 5, 6)


def main() -> int:
    here = pathlib.Path(__file__).resolve().parent
    binary = (
        pathlib.Path(sys.argv[1])
        if len(sys.argv) > 1
        else here / "target/release/players"
    )
    folder = here / "candidates"
    meta = {}
    for line in (folder / "meta.tsv").read_text().splitlines()[1:]:
        number, author, parent, note = line.split("\t")
        meta[number] = (author, parent, note)
    lines = ["number\tname\tauthor\tparent\t" + "\t".join(f"{t} hats" for t in HATS)]
    for path in sorted(folder.glob("[0-9]*.txt")):
        number, name = path.stem.split("-", 1)
        author, parent, _ = meta.get(number, ("?", "?", ""))
        result = subprocess.run(
            [str(binary), "eval", *(str(t) for t in HATS)],
            input=path.read_text(),
            capture_output=True,
            text=True,
            timeout=600,
        )
        scores = []
        for out in result.stdout.splitlines():
            if out.startswith("refused"):
                scores.append(out)
            else:
                scores.append(out.split(": ")[1].split(" wins")[0])
        lines.append("\t".join([number, name, author, parent, *scores]))
        print(lines[-1])
    (folder / "log.tsv").write_text("\n".join(lines) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
