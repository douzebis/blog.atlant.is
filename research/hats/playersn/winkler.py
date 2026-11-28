# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""A starting table for many.c: the lowest black hats, combined by a group.

usage: winkler.py N T [xor|add] > TABLE

Each player looks, for every other player, at the position of the lowest
black hat among the T hats (position 0 if there is none), combines these
positions, and points at the position that makes the combination of all
the N players the neutral element: with "xor" (T a power of two) the
positions are combined bit by bit, as in Buhler et al. for 5 to 8
players on 4 hats; with "add" they are added modulo T (Winkler).
"""

import itertools
import math
import sys


def main() -> int:
    n, t = int(sys.argv[1]), int(sys.argv[2])
    how = sys.argv[3] if len(sys.argv) > 3 else "xor"
    stacks = range(2**t)

    def lowest(a: int) -> int:
        return next((p for p in range(t) if a >> p & 1), 0)

    seen = list(itertools.combinations_with_replacement(stacks, n - 1))
    seen.sort(key=lambda a: sum(math.comb(a[i] + i, i + 1) for i in range(n - 1)))
    digits = []
    for a in seen:
        if how == "xor":
            total = 0
            for x in a:
                total ^= lowest(x)
            digits.append(total)
        else:
            digits.append(-sum(lowest(x) for x in a) % t)
    print(n, t)
    print("".join(str(d) for d in digits))
    return 0


if __name__ == "__main__":
    sys.exit(main())
