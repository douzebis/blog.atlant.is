# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""The game of hats with four players: a plain scorer, and the bound.

usage: score4.py T < TABLE

Counts the wins of a symmetric table on T hats (the format and the game
are those of four.c), slowly and plainly, checks that the table is proper
and symmetric, and prints the limit of the win rates when the table is
reset by itself again and again in the way of Buhler et al.
(arXiv:1407.4711v8, appendix): (W - 1) / ((2^T - 1)^4 + 4 (2^T - 1)^3 - 5).
The formula is proved for any number of players in
formal/hats/Hats/PlayersLimit.lean (`tendsto_rateN`, `limitN_eq`).
"""

import itertools
import sys
from fractions import Fraction


def main() -> int:
    t = int(sys.argv[1])
    size = 2**t
    rows = sys.stdin.read().split()
    assert len(rows) == size * size and all(len(r) == size for r in rows), "not a table"
    s = [
        [[int(c) for c in rows[u * size + v]] for v in range(size)] for u in range(size)
    ]
    stacks = range(size)
    assert all(0 <= s[u][v][w] < t for u in stacks for v in stacks for w in stacks), (
        "not proper"
    )
    assert all(
        s[u][v][w] == s[v][u][w] == s[u][w][v]
        for u in stacks
        for v in stacks
        for w in stacks
    ), "not symmetric"
    wins = sum(
        (a >> s[b][c][d] & 1)
        & (b >> s[a][c][d] & 1)
        & (c >> s[a][b][d] & 1)
        & (d >> s[a][b][c] & 1)
        for a, b, c, d in itertools.product(stacks, repeat=4)
    )
    bound = Fraction(wins - 1, (size - 1) ** 4 + 4 * (size - 1) ** 3 - 5)
    print(
        f"{wins} wins out of {16**t}; limit of the resets: {bound} = {float(bound):.6f}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
