# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Two players, hats that are black with probability p: chains of substitutions.

usage: biased.py              the table of the bounds, and the checks
       biased.py P            the best chain found for one value of p

Each hat is black with probability p (and q = 1 - p).  The value of a
strategy is the probability that both players point at a black hat.

Published lower bounds on the best value V(p): the strategies S1 to S4 of
Buhler et al. (arXiv:1407.4711v8, Section 2.2) and the bound U3 of
arXiv:2508.01737 (its formula is taken from a summary of that paper and
was not read in the original).

1. Substitution (Theorem 6 of the article) with a biased coin.  Put a
   strategy s on n hats in the place of the bottom hat of a strategy m on
   k + 1 hats.  The value grows by

     -p^(2n) + q^(2n) A_WW + (p q)^n (A_WB + A_BW) + p^(2n) A_BB
       - 2 p^n (1 - a) p q (q^(n-1) - p^(n-1))

   where A_cc' is the value of m among the pairs of stacks with bottom
   hats of colors c and c', the weight of the two bottom hats left out,
   and a is the probability that m stays on the bottom hat when it sees a
   black one.  `check_formula` compares this with direct counts.

2. A chain starts from one hat and substitutes again and again; its value
   is p^2 plus the sum of the gains.  `best_chain` finds the best chain
   over a set of strategies m, by going down from many hats to one.

3. The simplest good chain: play the strategy C_3 on the three lowest
   hats; if the three hats seen are all white, play it on the next three,
   and so on (white resets).  Its value is W(p) / (1 - q^6), with
   W(p) = 3p^2 - 6p^3 + 8p^4 - 6p^5 + 2p^6 the value of C_3.  For p up to
   about 0.43 this is above S1 to S4 and U3.  `check_nine_hats` counts
   exactly the first three blocks, on nine hats, for p = 3/10: already
   above the published bounds.

4. The exchange of the colors.  A player points at a black hat with
   probability p whatever the strategy, so both point at a white hat with
   probability 1 - 2p + (the value).  Hence the dual of a strategy has
   the value W(p) + 1 - 2p at the probability 1 - p, and
   V(1 - p) = V(p) + 1 - 2p: the loss p - V(p) is the same at p and at
   1 - p.  The black resets of the dual of C_3 do for p above 1/2 what
   the white resets do below, and S3 is the dual of S1.
"""

import itertools
import random
import sys
from fractions import Fraction
from typing import TypeVar

import best_classes as bc
import check_article as ca

# every function below works in floats (to search) or in fractions (to
# state a value exactly), and gives back the kind of number it was given
N = TypeVar("N", float, Fraction)


def weights(n: int, p: N) -> list[N]:
    return [p ** t.bit_count() * (1 - p) ** (n - t.bit_count()) for t in range(2**n)]


def value(n: int, s: ca.Strategy, p: N) -> N:
    w = weights(n, p)
    black = [[t for t in range(2**n) if t >> j & 1] for j in range(n)]
    total = p * 0
    for u in range(2**n):
        for t in black[s[u]]:
            if u >> s[t] & 1:
                total += w[u] * w[t]
    return total


def profile(k: int, m: ca.Strategy, p: N) -> tuple[N, N, N, N]:
    """A_WW, A_WB + A_BW, A_BB and a, for a strategy m on k + 1 hats."""
    w = weights(k, p)
    zero = p * 0
    a = [[zero, zero], [zero, zero]]
    for x in range(2**k):
        for c in (0, 1):
            t = x << 1 | c
            for y in range(2**k):
                for e in (0, 1):
                    u = y << 1 | e
                    if t >> m[u] & 1 and u >> m[t] & 1:
                        a[c][e] += w[x] * w[y]
    stays = zero
    for x in range(2**k):
        if m[x << 1 | 1] == 0:
            stays += w[x]
    return a[0][0], a[0][1] + a[1][0], a[1][1], stays


def gain(prof: tuple[N, N, N, N], n: int, p: N) -> N:
    q = 1 - p
    ww, wb, bb, a = prof
    return (
        -(p ** (2 * n))
        + q ** (2 * n) * ww
        + (p * q) ** n * wb
        + p ** (2 * n) * bb
        - 2 * p**n * (1 - a) * p * q * (q ** (n - 1) - p ** (n - 1))
    )


def check_formula() -> float:
    rng = random.Random(4)
    worst = 0.0
    for p in (0.3, 0.5, 0.8):
        for k, n in ((1, 1), (1, 2), (2, 2), (2, 3), (3, 2), (1, 3)):
            for _ in range(5):
                m = [rng.randrange(k + 1) for _ in range(2 ** (k + 1))]
                s = [rng.randrange(n) for _ in range(2**n)]
                direct = value(n + k, ca.substitute(k, m, n, s), p) - value(n, s, p)
                worst = max(worst, abs(direct - gain(profile(k, m, p), n, p)))
    return worst


def candidates() -> dict[int, list[ca.Strategy]]:
    """Strategies to substitute into: all those on two and three hats, and
    on four hats the three resets of the one-hat strategy by one strategy
    of each class on three hats."""
    two = [list(m) for m in itertools.product(range(2), repeat=4)]
    three = [list(m) for m in itertools.product(range(3), repeat=8)]
    classes = sorted({bc.canonical(3, m) for m in three})
    four = [
        reset(1, 3, ca.ONE, list(b))
        for b in classes
        for reset in (ca.white_reset, ca.black_reset, ca.double_reset)
    ]
    return {1: two, 2: three, 3: four}


def best_chain(
    p: float, cands: dict[int, list[ca.Strategy]], top: int = 120
) -> tuple[float, list[tuple[int, str]]]:
    """The best value of a chain, and its first steps (hats before the
    step, strategy substituted into)."""
    best: dict[tuple[int, int], tuple[float, int]] = {}
    for k, strategies in cands.items():
        profiles = [profile(k, m, p) for m in strategies]
        for n in range(1, top + 1):
            gains = [gain(prof, n, p) for prof in profiles]
            j = max(range(len(gains)), key=gains.__getitem__)
            best[k, n] = gains[j], j
    rest = [0.0] * (top + 5)
    step: dict[int, tuple[int, int] | None] = {}
    for n in range(top, 0, -1):
        rest[n], step[n] = 0.0, None
        for k in cands:
            total = best[k, n][0] + rest[n + k]
            if total > rest[n]:
                rest[n], step[n] = total, (k, best[k, n][1])
    path = []
    n = 1
    while n <= top and (choice := step[n]) is not None:
        path.append((n, ca.word(cands[choice[0]][choice[1]])))
        n += choice[0]
    return p * p + rest[1], path


def s1(p: N) -> N:
    return (
        p
        * (1 + p + p**2 + 3 * p**3 - 3 * p**4 + p**5)
        / ((1 + p) * (2 - p) * (1 + p**2))
    )


def s3(p: N) -> N:
    return (
        p
        * (1 + 5 * p - 10 * p**2 + 10 * p**3 - 5 * p**4 + p**5)
        / ((2 - 2 * p + p**2) * (1 + p) * (2 - p))
    )


def u3(p: N) -> N:
    top = (
        5 * p - 20 * p**2 + 51 * p**3 - 82 * p**4 + 85 * p**5
        - 52 * p**6 + 10 * p**7 + 10 * p**8 - 7 * p**9
    )  # fmt: skip
    bottom = (
        10 - 45 * p + 120 * p**2 - 210 * p**3 + 250 * p**4
        - 200 * p**5 + 100 * p**6 - 25 * p**7
    )  # fmt: skip
    return top / bottom


def white_resets(p: N) -> N:
    """The value of C_3 played on the first block of three hats seen that
    is not all white."""
    w = 3 * p**2 - 6 * p**3 + 8 * p**4 - 6 * p**5 + 2 * p**6
    return w / (1 - (1 - p) ** 6)


def check_nine_hats() -> bool:
    p = Fraction(3, 10)
    c3 = ca.carter(3)
    nine = ca.white_reset(6, 3, ca.white_reset(3, 3, c3, c3), c3)
    exact = value(9, nine, p)
    q = 1 - p
    assert value(3, c3, p) == 3 * p**2 - 6 * p**3 + 8 * p**4 - 6 * p**5 + 2 * p**6
    assert exact == value(3, c3, p) * (1 + q**6 + q**12)
    print(
        f"nine hats, p = 3/10: exactly {exact} = {float(exact):.6f};"
        f" S1 {float(s1(p)):.6f}, U3 {float(u3(p)):.6f}"
    )
    return exact > max(s1(p), u3(p))


def main() -> int:
    cands = candidates()
    if len(sys.argv) > 1:
        p = float(sys.argv[1])
        total, path = best_chain(p, cands)
        print(f"p = {p}: {total:.6f}; steps {path[:6]}")
        return 0
    gap = check_formula()
    print(f"the formula for the gain against direct counts: largest gap {gap:.1e}")
    ok = gap < 1e-12 and check_nine_hats()
    for i in range(1, 20):
        p = Fraction(i, 20)
        known = [s1(p), s3(p)] + ([u3(p)] if 2 * p < 1 else [])
        published = max(known)
        simple = white_resets(p) if 2 * p <= 1 else white_resets(1 - p) + 2 * p - 1
        chain, _ = best_chain(float(p), cands)
        print(
            f"p = {p}: published {published} = {float(published):.6f};"
            f" resets of C_3 {simple} = {float(simple):.6f}, that is {simple - published}"
            f" more; best chain {chain:.6f}"
        )
    print("biased.py:", "all checks pass" if ok else "A CHECK FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
