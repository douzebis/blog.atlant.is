# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""The game of hats with three players: the reference scorer.

usage: score.py T < table          the wins of a table read on standard input
       score.py --check            the checks of this file

Three players, each with a stack of T hats (a number below 2^T, the
bottom hat is the units digit, black is 1).  Each sees the two other
stacks and points at a position of their own stack; they win when the
three hats pointed at are black.  A strategy is a table s[u][v]: the
position to point at for the player who sees the stacks u and v.  In a
*symmetric* strategy the three players use the same table and
s[u][v] = s[v][u].

The wins of three tables (s1, s2, s3), one per player, are the triples
(a, b, c) of stacks with a black at s1[b][c], b black at s2[a][c] and c
black at s3[a][b]: out of 8^T.

This file is slow and plain on purpose: the Rust programs of this
directory are checked against it.

A table is written as 2^T lines of 2^T digits: line u, column v.
"""

import itertools
import sys

Table = list[list[int]]


def hat(t: int, p: int) -> int:
    return t >> p & 1


def wins(t: int, s1: Table, s2: Table, s3: Table) -> int:
    stacks = range(2**t)
    return sum(
        hat(a, s1[b][c]) & hat(b, s2[a][c]) & hat(c, s3[a][b])
        for a in stacks
        for b in stacks
        for c in stacks
    )


def wins_symmetric(t: int, s: Table) -> int:
    return wins(t, s, s, s)


def read_table(text: str) -> Table:
    return [[int(c) for c in line] for line in text.split()]


def write_table(s: Table) -> str:
    return "\n".join("".join(str(p) for p in row) for row in s) + "\n"


def lowest_black(t: int, u: int) -> int | None:
    return next((p for p in range(t) if hat(u, p)), None)


def winkler(t: int) -> Table:
    """Point at the sum, modulo T, of the lowest black hats of the two
    stacks seen (position 0 when one of them has none)."""
    size = 2**t
    table = [[0] * size for _ in range(size)]
    for u in range(size):
        for v in range(size):
            a, b = lowest_black(t, u), lowest_black(t, v)
            if a is not None and b is not None:
                table[u][v] = (a + b) % t
    return table


def best_symmetric(t: int) -> tuple[int, int]:
    """The best wins of a symmetric table on T hats, by trying them all,
    and the number of tables that reach it.  For T at most 2."""
    size = 2**t
    pairs = [(u, v) for u in range(size) for v in range(u, size)]
    best, count = -1, 0
    for choice in itertools.product(range(t), repeat=len(pairs)):
        table = [[0] * size for _ in range(size)]
        for (u, v), p in zip(pairs, choice):
            table[u][v] = table[v][u] = p
        w = wins_symmetric(t, table)
        if w > best:
            best, count = w, 0
        count += w == best
    return best, count


def check() -> int:
    failures = 0

    def expect(name: str, got: object, wanted: object) -> None:
        nonlocal failures
        ok = got == wanted
        failures += not ok
        print(
            f"{'ok' if ok else 'FAILED'}: {name}: {got}"
            + ("" if ok else f", expected {wanted}")
        )

    # always the bottom hat: the three bottom hats are black
    for t in (1, 2, 3):
        size = 2**t
        expect(
            f"same hat, {t} hats", wins_symmetric(t, [[0] * size] * size), 8 ** (t - 1)
        )
    # the next values were first computed by this file (2026-11-27); they
    # are kept so that a change of the scorer shows, and the Rust scorer
    # must find them too
    expect("Winkler's sum, 2 hats", wins_symmetric(2, winkler(2)), 14)
    expect("Winkler's sum, 3 hats", wins_symmetric(3, winkler(3)), 95)
    expect("best symmetric table, 1 hat", best_symmetric(1), (1, 1))
    expect("best symmetric table, 2 hats", best_symmetric(2), (14, 128))
    return failures


def main() -> int:
    if sys.argv[1:] == ["--check"]:
        return 1 if check() else 0
    t = int(sys.argv[1])
    table = read_table(sys.stdin.read())
    print(wins_symmetric(t, table))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
