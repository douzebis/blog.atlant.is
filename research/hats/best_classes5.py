# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""The best strategies on five hats, in classes: built, hereditary, primitive.

usage: best_classes5.py [FILE]

FILE (best-search/results/best5-crushed.txt by default) lists the crushed strategies
on five hats with 358 hits, as best_all prints them.  The program sorts
them into classes of equivalent strategies (best_classes.py), says which
classes are built with resets and shifts, and which hold a hereditary
strategy, one whose cuts to fewer hats are all best (cuts.py).

Found on 2026-11-27 (ten minutes, most of them for the built classes):
1,014 crushed strategies; 27 classes, 15 when a strategy and its dual are
put together; 9 classes are built, and they are the 9 hereditary ones; the
18 others are primitive, their cuts to four hats having at most 88 hits.
"""

import collections
import pathlib
import sys

import best_classes as bc
import check_article as ca
import cuts

N = 5


def main() -> int:
    here = pathlib.Path(__file__).resolve().parent
    default = here / "best-search" / "results" / "best5-crushed.txt"
    path = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else default
    strategies = [ca.strategy(line.strip()) for line in path.read_text().split()]
    assert all(ca.hits(N, s) == cuts.BEST[N] for s in strategies)
    classes = sorted({bc.canonical(N, s) for s in strategies})
    colors = {min(c, bc.canonical(N, ca.dual(N, list(c)))) for c in classes}
    print(
        f"{len(strategies)} crushed strategies, {len(classes)} classes, "
        f"{len(colors)} up to the colors"
    )
    built = bc.built(N)[N]
    summary: collections.Counter[tuple[bool, tuple[int, ...]]] = collections.Counter()
    for c in classes:
        top, _ = cuts.best_cuts(N, list(c))
        summary[(c in built, top)] += 1
        print(
            "".join(str(p) for p in c),
            "built" if c in built else "not built",
            "best cuts",
            top,
        )
    for (is_built, top), count in sorted(summary.items()):
        print(
            f"{count} classes {'built' if is_built else 'not built'} with best cuts {top}"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
