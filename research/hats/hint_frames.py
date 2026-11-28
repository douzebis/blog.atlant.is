# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""The best sortings of the hint game of dimension 4, read as games on five hats.

usage: hint_frames.py [ORBITS]

ORBITS is the list of the best sortings, one for each orbit, as written by
`hint-search/hint4 --orbits` (default: its saved result for 171/16).

In the hint game (see hint_carter.py) Alice may point at any of the 16
points; in the game on five hats she has five hats, which are the values
of her affine function at five independent points (a *frame*).  A sorting
is a game on five hats when some frame holds one of Alice's best points
for every stack of Bob.  The program counts such frames for each orbit
and, for the sortings with five blocks, reads them as one strategy used
by both players and names its class among the best strategies on five
hats.
"""

import collections
import itertools
import pathlib
import sys

import best_classes as bc
import check_article as ca

POINTS = 16


def value(a: int, b: int, x: int) -> int:
    return ((a & x).bit_count() + b) & 1


def independent(frame: tuple[int, ...]) -> bool:
    span = {0}
    for point in frame[1:]:
        v = point ^ frame[0]
        if v in span:
            return False
        span |= {s ^ v for s in span}
    return True


def main() -> int:
    here = pathlib.Path(__file__).parent
    path = (
        sys.argv[1]
        if len(sys.argv) > 1
        else here / "hint-search/results/171-16-orbits.txt"
    )
    labels = [(a, b) for a in range(1, POINTS) for b in (0, 1)]
    frames = [f for f in itertools.combinations(range(POINTS), 5) if independent(f)]
    with open(
        here / "best-search/results/best5-crushed.txt", encoding="utf-8"
    ) as lines:
        best5 = [
            ca.strategy(x.strip()) for x in lines if x.strip() and not x.startswith("#")
        ]
    best_classes = {bc.canonical(5, s) for s in best5}
    carter = bc.canonical(5, ca.carter(5))
    twisted = {
        bc.canonical(5, ca.twisted_double_shift(3, ca.carter(3))),
        bc.canonical(
            5, ca.dual(5, ca.twisted_double_shift(3, ca.dual(3, ca.carter(3))))
        ),
    }
    with open(path, encoding="utf-8") as lines:
        orbits = [
            [int(x) for x in line.split(":")[1].split()]
            for line in lines
            if ":" in line
        ]
    for number, block in enumerate(orbits):
        blocks = max(block) + 1
        best_points = []
        total = 0
        for u in range(2**blocks):
            scores = [
                sum(value(a, b, x) for (a, b), k in zip(labels, block) if u >> k & 1)
                for x in range(POINTS)
            ]
            total += max(scores)
            best_points.append({x for x in range(POINTS) if scores[x] == max(scores)})
        good = [f for f in frames if all(points & set(f) for points in best_points)]
        readings: collections.Counter[str] = collections.Counter()
        if blocks == 5:
            for frame in good:
                bob = {
                    sum(value(a, b, frame[i]) << i for i in range(5)): k
                    for (a, b), k in zip(labels, block)
                }
                for pi in itertools.permutations(range(5)):
                    s = [0] + [pi[bob[t]] for t in range(1, 31)] + [0]
                    if all(
                        frame[s[sum((u >> k & 1) << pi[k] for k in range(5))]]
                        in best_points[u]
                        for u in range(1, 31)
                    ):
                        c = bc.canonical(5, s)
                        name = (
                            "the Carter class"
                            if c == carter
                            else "a twisted class"
                            if c in twisted
                            else "another best class"
                            if c in best_classes
                            else "not a best strategy"
                        )
                        readings[name] += 1
        print(
            f"orbit {number}: {blocks} blocks, {total}/2^{blocks};"
            f" frames with a best point for every stack of Bob: {len(good)};"
            f" as one strategy on five hats: {dict(readings)}"
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
