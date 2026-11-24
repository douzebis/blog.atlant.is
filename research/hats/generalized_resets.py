# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Generalized resets on blocks of m hats (docs/papers/hats/open-questions.md, 4).

usage: generalized_resets.py

A scheme is a set Z of stacks of m hats and a proper strategy a on the
other stacks of m hats.  The strategy on infinite stacks that it defines
looks at the m lowest hats: outside Z it plays a; in Z it skips them and
starts again on the hats above.  Its win rate x satisfies

    x = (A + c) / 4^m + (|Z|^2 / 4^m) x

where A counts the pairs of stacks outside Z on which a wins, and c the
pairs (t, u) with t in Z, u outside Z and t black where a points for u,
each such pair being won half of the time and counted for both players.

For m = 1, 2, 3 every scheme is tried and the best win rate is printed,
with the schemes that reach it.
"""

import itertools
from fractions import Fraction


def best(m: int) -> tuple[Fraction, list[tuple[tuple[int, ...], tuple[int, ...]]], int]:
    """Best win rate over all schemes on m hats, the schemes that reach it, their number."""
    stacks = 2**m
    top = Fraction(0)
    winners: list[tuple[tuple[int, ...], tuple[int, ...]]] = []
    tried = 0
    for mask in range(2**stacks - 1):  # Z is not everything; it may be empty
        inside = [t for t in range(stacks) if mask >> t & 1]
        outside = [t for t in range(stacks) if not mask >> t & 1]
        black_in_z = [sum(t >> p & 1 for t in inside) for p in range(m)]
        for choice in itertools.product(range(m), repeat=len(outside)):
            tried += 1
            a = dict(zip(outside, choice, strict=True))
            wins = sum(
                (t >> a[u] & 1) * (u >> a[t] & 1) for t in outside for u in outside
            )
            half = sum(black_in_z[a[u]] for u in outside)
            rate = Fraction(wins + half, 4**m - len(inside) ** 2)
            if rate > top:
                top, winners = rate, []
            if rate == top:
                winners.append((tuple(inside), choice))
    return top, winners, tried


def main() -> None:
    for m in (1, 2, 3):
        top, winners, tried = best(m)
        print(
            f"m = {m}: {tried} schemes, best win rate {top}, reached by {len(winners)}"
        )
        for inside, choice in winners:
            print(f"    Z = {inside}, a on the other stacks = {choice}")


if __name__ == "__main__":
    main()
