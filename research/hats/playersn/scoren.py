# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""The game of hats with N players: a plain scorer for symmetric tables.

usage: scoren.py [--brute] < TABLE

Reads a table in the format of many.c (a line "N T", a line of digits:
the position to point at for each multiset of N - 1 stacks seen, in the
order of many.c) and counts its wins, independently of that program:

- by default, over the multisets of N stacks, each with the number of
  ways to deal it to the players;
- with --brute, over all the 2^(N T) placements one by one (small cases).

Prints the wins and the limit of the win rates when the table is reset by
itself again and again, (W - 1) / ((P-1)^N + N (P-1)^(N-1) - (N+1)) with
P = 2^T (`tendsto_rateN`, `limitN_eq` in formal/hats/Hats/PlayersLimit.lean).
"""

import itertools
import math
import sys
from fractions import Fraction


def load(text: str) -> tuple[int, int, dict[tuple[int, ...], int]]:
    fields = text.split()
    n, t, digits = int(fields[0]), int(fields[1]), fields[2]
    stacks = range(2**t)
    seen = list(itertools.combinations_with_replacement(stacks, n - 1))
    # the order of many.c: by sum of C(a_i + i, i + 1), a_0 <= a_1 <= ...
    seen.sort(key=lambda a: sum(math.comb(a[i] + i, i + 1) for i in range(n - 1)))
    assert len(digits) == len(seen), "not a table for these numbers"
    table = {a: int(d) for a, d in zip(seen, digits)}
    assert all(0 <= p < t for p in table.values()), "not proper"
    return n, t, table


def wins_of(n: int, c: tuple[int, ...], table: dict[tuple[int, ...], int]) -> bool:
    for i in range(n):
        others = tuple(sorted(c[:i] + c[i + 1 :]))
        if not c[i] >> table[others] & 1:
            return False
    return True


def main() -> int:
    brute = "--brute" in sys.argv[1:]
    n, t, table = load(sys.stdin.read())
    stacks = range(2**t)
    wins = 0
    if brute:
        for c in itertools.product(stacks, repeat=n):
            wins += wins_of(n, c, table)
    else:
        for c in itertools.combinations_with_replacement(stacks, n):
            if wins_of(n, c, table):
                ways = math.factorial(n)
                for v in set(c):
                    ways //= math.factorial(c.count(v))
                wins += ways
    p1 = 2**t - 1
    bound = Fraction(wins - 1, p1**n + n * p1 ** (n - 1) - (n + 1))
    print(
        f"{n} players, {t} hats: {wins} wins out of {2 ** (n * t)};"
        f" limit of the resets: {bound} = {float(bound):.6f}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
