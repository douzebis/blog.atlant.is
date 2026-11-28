# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""The hint game as equations to satisfy, and its inconsistent lines.

usage: hint_lines.py

In the hint game of dimension d (see hint_carter.py) Bob sorts the labels
(a, b) into blocks, and each block is kept by the toss of a fair coin.
When the two labels of a have different blocks, call a *active* if exactly
one of them is kept, and let T(a) = 1 when the kept one is (a, 0).  Alice
then wants a point x with a.x = T(a) for as many active a as she can, and

    value = 3/8 - E|U| / (2 (2^d - 1))

where U is the set of active a that her best point leaves unsatisfied.

A *line* is a triple a, b, a + b.  A line whose three points are active
with T(a) + T(b) + T(a + b) = 1 is inconsistent: any x leaves one of its
points unsatisfied.  So |U| is at least the least number of points that
meet every inconsistent line.  Send each a to the pair of blocks of its
two labels, an edge of the graph on the blocks.  A line is never
inconsistent when its three edges make a triangle; otherwise it is
inconsistent with probability 1/16 (three edges, no cycle), 1/8 (two of
them equal) or 1/4 (the three equal).

The program prints, for the best sortings of dimension 4 (the 11 orbits
of hint-search/results) and for the sortings that the Carter strategies
define in dimensions 2 to 7: the kinds of lines, E|U|, and for dimension 4
the expected least number of points that meet every inconsistent line.
"""

import collections
import itertools
import pathlib
import sys
from fractions import Fraction

import check_article as ca

Sorting = dict[int, tuple[int, int]]  # a -> the blocks of (a, 0) and (a, 1)


def dot(a: int, x: int) -> int:
    return (a & x).bit_count() & 1


def lines(size: int) -> list[tuple[int, int, int]]:
    return [
        (a, b, a ^ b) for a in range(1, size) for b in range(a + 1, size) if a ^ b > b
    ]


def kinds(size: int, blocks: Sorting) -> dict[str, int]:
    count: collections.Counter[str] = collections.Counter()
    for line in lines(size):
        edges = [frozenset(blocks[a]) for a in line]
        if any(len(e) == 1 for e in edges):
            count["a point with its two labels in one block"] += 1
        elif len(set(edges)) == 3:
            triangle = len(frozenset().union(*edges)) == 3
            count["triangle" if triangle else "three edges, no cycle"] += 1
        else:
            count[
                "two equal edges" if len(set(edges)) == 2 else "three equal edges"
            ] += 1
    return dict(count)


def unsatisfied(
    size: int, blocks: Sorting, nblocks: int, meet: bool
) -> tuple[Fraction, Fraction]:
    """E|U|, and (if `meet`) the expected least number of points that meet
    every inconsistent line."""
    all_lines = lines(size)
    total = least = 0
    for u in range(2**nblocks):
        target = {
            a: u >> k0 & 1
            for a, (k0, k1) in blocks.items()
            if (u >> k0 & 1) != (u >> k1 & 1)
        }
        best = max(sum(dot(a, x) == t for a, t in target.items()) for x in range(size))
        total += len(target) - best
        if meet:
            bad = [
                set(line)
                for line in all_lines
                if all(a in target for a in line)
                and sum(target[a] for a in line) % 2 == 1
            ]
            if bad:
                least += next(
                    r
                    for r in range(1, len(target) + 1)
                    if any(
                        all(line & set(c) for line in bad)
                        for c in itertools.combinations(target, r)
                    )
                )
    return Fraction(total, 2**nblocks), Fraction(least, 2**nblocks)


def carter_sorting(d: int) -> Sorting:
    n = d + 1
    bob = ca.carter(n)

    def stack(a: int, b: int) -> int:
        return b | sum((dot(a, 1 << (i - 1)) ^ b) << i for i in range(1, n))

    return {a: (bob[stack(a, 0)], bob[stack(a, 1)]) for a in range(1, 2**d)}


def main() -> int:
    here = pathlib.Path(__file__).parent
    with open(here / "hint-search/results/171-16-orbits.txt", encoding="utf-8") as text:
        orbits = [
            [int(x) for x in line.split(":")[1].split()] for line in text if ":" in line
        ]
    for number, block in enumerate(orbits):
        blocks = {a: (block[2 * (a - 1)], block[2 * (a - 1) + 1]) for a in range(1, 16)}
        u, least = unsatisfied(16, blocks, max(block) + 1, True)
        print(
            f"orbit {number}: {kinds(16, blocks)}; E|U| = {u}; to meet the lines: {least}"
        )
    for d in range(2, 8):
        size = 2**d
        blocks = carter_sorting(d)
        line = f"Carter, d = {d}: {kinds(size, blocks)}"
        if d <= 6:
            u, _ = unsatisfied(size, blocks, d + 1, False)
            line += f"; E|U| = {u} = {float(u):.4f}, and 2^d / 20 = {size / 20}"
        print(line)
    return 0


if __name__ == "__main__":
    sys.exit(main())
