# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Part II of the paper, the reluctant recitation: checks by computation.

usage: python check_reluctant.py [--moves T]     (default 300000; about 5 s)

Every line printed must end with "ok".

Checked:
- the first beads of the recitation, as quoted in the paper;
- Theorem 2 on the first T moves: Jane is never stuck, never tells a bead
  twice, and never leaves a gap in an up-chain (when a white bead w is
  told, w lambda has been told);
- Lemma 4 (binary prefixes) for all beads below 5000;
- Lemma 5 (phases), both parts, for all beads below 20000;
- Theorem 5 (1) on the first T moves:
  |u(t) log2 3 - t - log2 rho(t)| <= (3/2)(1 + ln t);
- the fact behind Lemma 9: for a denominator q of a convergent of
  alpha = log2(3/2), any q consecutive multiples of alpha leave no gap of
  length 2/q on the circle (checked for the first 8 denominators).

The long run behind the numerical table of the paper is walk.c.
"""

import argparse
import math
import sys

from rosary import down, is_black, lam, reluctant_recitation, up


def report(name: str, passed: bool) -> bool:
    print(f"{name}: {'ok' if passed else 'FAILED'}")
    return passed


def down_chain(n: int) -> set[int]:
    chain = {n}
    while n > 1:
        n = down(n)
        chain.add(n)
    return chain


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--moves", type=int, default=300000, metavar="T")
    moves = parser.parse_args().moves
    results = []

    # reluctant_recitation raises an error if Jane is stuck or repeats a bead.
    beads = reluctant_recitation(moves)
    results.append(
        report(
            "rho(0..13) = 1, 2, 3, 5, 8, 4, 6, 9, 14, 7, 11, 17, 26, 13",
            beads[:14] == [1, 2, 3, 5, 8, 4, 6, 9, 14, 7, 11, 17, 26, 13],
        )
    )
    results.append(report(f"Theorem 2: defined and injective on {moves} moves", True))

    told: set[int] = set()
    no_gap = True
    ups = 0
    worst = 0.0
    log2_3 = math.log2(3)
    for t, bead in enumerate(beads):
        if t and bead > beads[t - 1]:
            ups += 1
        told.add(bead)
        if not is_black(bead) and lam(bead) not in told:
            no_gap = False
        if t:
            deviation = abs(ups * log2_3 - t - math.log2(bead))
            worst = max(worst, deviation / (1.5 * (1 + math.log(t))))
    results.append(report("Theorem 2: no gap in an up-chain", no_gap))
    results.append(
        report(
            "Theorem 5 (1): largest deviation / bound = "
            f"{worst:.3f} <= 1 on {moves} moves",
            worst <= 1,
        )
    )

    prefixes = True
    for n in range(1, 5000):
        # The beads whose binary expansion is a prefix of that of n.
        expected = {n >> k for k in range(n.bit_length())}
        if down_chain(n) != expected:
            prefixes = False
    results.append(
        report("Lemma 4: down-chains are binary prefixes, n < 5000", prefixes)
    )

    alpha = math.log2(3 / 2)
    phases = True
    for n in range(1, 20000):
        epsilon = math.log2(up(n)) - math.log2(n) - alpha
        if not -1e-12 <= epsilon < 1 / (2 * n):
            phases = False
        m, k = n, 0
        while m > 1:
            m, k = down(m), k + 1
            epsilon = math.log2(n) - k - math.log2(m)
            if not -1e-12 <= epsilon < 3 / (2 * m):
                phases = False
    results.append(report("Lemma 5: phases, both parts, n < 20000", phases))

    # Denominators of the convergents of alpha.
    denominators = []
    x, previous, current = alpha, 1, 0
    for _ in range(9):
        digit = math.floor(x)
        previous, current = current, digit * current + previous
        denominators.append(current)
        x = 1 / (x - digit)
    gaps = True
    for q in denominators[1:]:
        points = sorted((j * alpha) % 1 for j in range(q))
        largest = max(
            [b - a for a, b in zip(points, points[1:])] + [1 - points[-1] + points[0]]
        )
        if largest >= 2 / q:
            gaps = False
    results.append(
        report(
            f"Lemma 9: q consecutive points leave no gap of 2/q, q in {denominators[1:]}",
            gaps,
        )
    )
    return 0 if all(results) else 1


if __name__ == "__main__":
    sys.exit(main())
