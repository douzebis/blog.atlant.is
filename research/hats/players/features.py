# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Three players: how far do simple features of the stacks go?

usage: features.py [T [SECONDS [SEED]]]      (5 hats, 20 seconds by default)

A symmetric table s[u][v] is restricted to depend on the two stacks seen
only through a *feature* of each (for instance its lowest black hat):
s[u][v] = F(feature(u), feature(v)), with F symmetric.  For each family of
features below, a short annealing looks for the best F, and the program
prints the wins it reaches.  Comparing with the best table known without
restriction (results/) tells which features carry the strategy.

The wins are counted with numpy over all the triples of stacks at once.
"""

import math
import random
import sys
import time

import numpy as np


def hat(u: int, p: int) -> int:
    return u >> p & 1


def lowest(u: int, t: int, color: int) -> int:
    """The lowest position of that color, or t if there is none."""
    return next((p for p in range(t) if hat(u, p) == color), t)


def carter_rule(t: int, u: int) -> int:
    """Where the Carter strategy for two players points (the rule of the
    article, Section 5)."""
    if hat(u, 0):
        p = lowest(u, t, 0)
        return p if p < t and p % 2 == 1 else 0
    q = lowest(u, t, 1)
    if q == t:
        return 0
    if q % 2 == 0:
        return q
    return q + 1 if q + 1 < t and hat(u, q + 1) else 0


def features(t: int) -> dict[str, list[object]]:
    """For each family: the feature of every stack."""
    stacks = range(2**t)
    return {
        "lowest black": [lowest(u, t, 1) for u in stacks],
        "lowest black, lowest white": [
            (lowest(u, t, 1), lowest(u, t, 0)) for u in stacks
        ],
        "two lowest hats": [u % 4 for u in stacks],
        "three lowest hats": [u % 8 for u in stacks],
        "four lowest hats": [u % 16 for u in stacks],
        "lowest black, and the hat above it": [
            (lowest(u, t, 1), hat(u, lowest(u, t, 1) + 1)) for u in stacks
        ],
        "lowest black, number of black hats": [
            (lowest(u, t, 1), u.bit_count()) for u in stacks
        ],
        "two lowest black hats": [
            (lowest(u, t, 1), lowest(u & (u - 1), t, 1)) for u in stacks
        ],
        "lowest black, and the two hats above it": [
            (lowest(u, t, 1), hat(u, lowest(u, t, 1) + 1), hat(u, lowest(u, t, 1) + 2))
            for u in stacks
        ],
        "lowest white, and the hat above it": [
            (lowest(u, t, 0), hat(u, lowest(u, t, 0) + 1)) for u in stacks
        ],
        "lowest black, the hat above it, lowest white": [
            (lowest(u, t, 1), hat(u, lowest(u, t, 1) + 1), lowest(u, t, 0))
            for u in stacks
        ],
        "the choice of the two-player Carter rule": [carter_rule(t, u) for u in stacks],
        "the Carter choice, and the lowest black": [
            (carter_rule(t, u), lowest(u, t, 1)) for u in stacks
        ],
        "the Carter choice, lowest black, hat above it": [
            (carter_rule(t, u), lowest(u, t, 1), hat(u, lowest(u, t, 1) + 1))
            for u in stacks
        ],
    }


class Scorer:
    """Counts the wins of a symmetric table, all triples at once."""

    def __init__(self, t: int) -> None:
        size = 2**t
        self.size = size
        # black[x][p]: the hat of stack x at position p
        self.black = np.array(
            [[hat(x, p) for p in range(t)] for x in range(size)], dtype=np.int64
        )

    def wins(self, s: np.ndarray) -> int:
        size = self.size
        idx = np.arange(size)
        # w1[a][b][c] = hat of a at s[b][c], and so on
        w1 = self.black[idx[:, None, None], s[None, :, :]]
        w2 = self.black[idx[None, :, None], s[:, None, :]]
        w3 = self.black[idx[None, None, :], s[:, :, None]]
        return int((w1 & w2 & w3).sum())


def best_in_family(
    t: int, feature: list[object], scorer: Scorer, seconds: float, rng: random.Random
) -> tuple[int, int]:
    """Annealing over the functions F of two features.  Returns the best
    wins and the number of classes of pairs of features."""
    size = 2**t
    values = sorted(set(feature), key=repr)
    index = {f: i for i, f in enumerate(values)}
    fu = np.array([index[f] for f in feature])
    k = len(values)
    choice = np.zeros((k, k), dtype=np.int64)
    for i in range(k):
        for j in range(i, k):
            choice[i][j] = choice[j][i] = rng.randrange(t)
    current = scorer.wins(choice[fu[:, None], fu[None, :]])
    best = current
    begin = time.monotonic()
    hot, cold = 0.004 * 8**t, 0.0002 * 8**t
    while (elapsed := time.monotonic() - begin) < seconds:
        temperature = hot * (cold / hot) ** (elapsed / seconds)
        i, j = rng.randrange(k), rng.randrange(k)
        old = int(choice[i][j])
        new = (old + 1 + rng.randrange(t - 1)) % t
        choice[i][j] = choice[j][i] = new
        w = scorer.wins(choice[fu[:, None], fu[None, :]])
        if w >= current or rng.random() < math.exp((w - current) / temperature):
            current = w
            best = max(best, w)
        else:
            choice[i][j] = choice[j][i] = old
    assert size == len(feature)
    return best, k * (k + 1) // 2


def main() -> int:
    t = int(sys.argv[1]) if len(sys.argv) > 1 else 5
    seconds = float(sys.argv[2]) if len(sys.argv) > 2 else 20
    rng = random.Random(int(sys.argv[3]) if len(sys.argv) > 3 else 1)
    scorer = Scorer(t)
    print(f"{t} hats, {8**t} triples, {seconds:g} s per family")
    for name, feature in features(t).items():
        wins, classes = best_in_family(t, feature, scorer, seconds, rng)
        print(f"{wins:7d} wins  {classes:5d} classes  {name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
