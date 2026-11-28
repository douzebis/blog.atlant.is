# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Three players: the reset of a table by another, and what it is worth.

usage: compose.py N TABLE K [UPPER]     the table on N + K hats, on standard output
       compose.py --bound T TABLE       the limit of the table reset by itself

The reset of Buhler et al. for three players: a player who sees a stack
that is all white on its N lowest hats, or two stacks that are all black
on their N lowest hats, plays the table UPPER on the K hats above; any
other player plays TABLE on the N lowest hats.  Without UPPER, K is 1 and
the players who go up point at the one hat above.

The result has 8^K (W - 1) + (3 2^N + 2) W' wins, where W and W' are the
wins of TABLE and UPPER (`wins3_reset` in formal/hats/Hats/Three.lean),
and a table on T hats with W wins, reset by itself again and again, has
win rates that tend to (W - 1) / (8^T - 3 2^T - 2) (`tendsto_rate3` in
formal/hats/Hats/ThreeLimit.lean).
"""

import sys
from fractions import Fraction

import score


def compose(n: int, s: score.Table, k: int, m: score.Table) -> score.Table:
    low = 2**n
    size = 2 ** (n + k)
    black = low - 1
    out = [[0] * size for _ in range(size)]
    for u in range(size):
        for v in range(size):
            lu, lv = u % low, v % low
            if lu == 0 or lv == 0 or (lu == black and lv == black):
                out[u][v] = n + m[u >> n][v >> n]
            else:
                out[u][v] = s[lu][lv]
    return out


def bound(t: int, wins: int) -> Fraction:
    return Fraction(wins - 1, 8**t - 3 * 2**t - 2)


def read(path: str) -> score.Table:
    with open(path, encoding="utf-8") as text:
        return score.read_table(text.read())


def main() -> int:
    if sys.argv[1] == "--bound":
        t = int(sys.argv[2])
        s = read(sys.argv[3])
        assert len(s) == 2**t and all(len(row) == 2**t for row in s), (
            "not a table on T hats"
        )
        assert all(0 <= p < t for row in s for p in row), "not proper"
        wins = score.wins_symmetric(t, s)
        value = bound(t, wins)
        print(
            f"{wins} wins out of {8**t}; limit of the resets: {value} = {float(value):.6f}"
        )
        return 0
    n, k = int(sys.argv[1]), int(sys.argv[3])
    upper = read(sys.argv[4]) if len(sys.argv) > 4 else [[0, 0], [0, 0]]
    sys.stdout.write(score.write_table(compose(n, read(sys.argv[2]), k, upper)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
