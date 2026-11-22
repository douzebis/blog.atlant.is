# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Part II of the paper, the reluctant recitation: checks by computation.

usage: python check_reluctant.py [--moves T]     (default 300000; about 5 s)

Every line printed must end with "ok".

Checked:
- the first beads of the recitation and the examples of Part II, as quoted
  in the paper;
- Theorem 2 on the first T moves: Jane is never stuck, never tells a bead
  twice, and never leaves a gap in an up-chain (when a white bead w is
  told, w lambda has been told);
- Lemma 4 (binary prefixes) for all beads below 5000;
- Lemma 5 (phases), both parts, for all beads below 20000;
- Theorem 5 (1) on the first T moves:
  |u(t) log2 3 - t - log2 rho(t)| <= (3/2)(1 + ln t);
- the trivial bound F(t) <= t + 2 on the frontier, and the remark of the
  coda on the 3x+1 map;
- the fact behind Lemma 9: for a denominator q of a convergent of
  alpha = log2(3/2), any q consecutive multiples of alpha leave no gap of
  length 2/q on the circle (checked for the first 8 denominators);
- the table that follows Lemma 9: for four lengths w, the J that the lemma
  gives with Rhin's exponent, and the smallest J such that J consecutive
  multiples of alpha meet every arc of length w.

The long run behind the numerical table of the paper is walk.c.
"""

import argparse
import math
import sys

from draw_figures import PHASE_STARTS, phase_stretch
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
    cone_of_4 = [n for n in range(1, 20) if 4 in down_chain(n)]
    results.append(
        report(
            "examples: rho(5) = 4, rho(12) = 26, the cone of bead 4, the phase of 8",
            beads[5] == 4
            and beads[12] == 26
            and cone_of_4 == [4, 8, 9, 16, 17, 18, 19]
            and math.log2(8) % 1 == 0,
        )
    )

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

    frontier, seen, trivial = 1, set(), True
    for t, bead in enumerate(beads[:20000]):
        seen.add(bead)
        while frontier in seen:
            frontier += 1
        if frontier > t + 2:
            trivial = False
    results.append(report("Section 11: F(t) <= t + 2 on 20000 moves", trivial))
    results.append(
        report(
            "coda: the 3x+1 map is up from odd beads and down from even beads",
            all(
                up(n) == (3 * n + 1) // 2 if n % 2 else down(n) == n // 2
                for n in range(1, 10**5)
            ),
        )
    )
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

    # "Which exponent?": the two constants drawn from Rhin's explicit bound.
    results.append(
        report(
            "Which exponent: 2^-13.3 / ln 2 > 10^-4 and 56 6^26.6 10^8 < 3 10^30",
            2**-13.3 / math.log(2) > 1e-4
            and 56 * 6**26.6 * 1e8 < 3e30
            and math.log2(3) - 0.415 > 1,
        )
    )

    # The numbers in the caption of Figure 10: the smallest bead of each
    # stretch, and how far Jane's phase gets from the exact rotation.
    walk = reluctant_recitation(max(PHASE_STARTS) + 400)
    figure = []
    for start in PHASE_STARTS:
        exact, real, lowest = phase_stretch(walk, start)
        blur = max(abs((b - a + 0.5) % 1 - 0.5) for a, b in zip(exact, real))
        figure.append((start, lowest, round(blur, 4)))
    results.append(
        report(
            "Figure 10: lowest bead and largest blur of the three stretches",
            figure == [(0, 1, 0.433), (300, 135, 0.0216), (3000, 1290, 0.0011)],
        )
    )

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

    # The table that follows Lemma 9.  J consecutive points of an orbit meet
    # every arc of length w if and only if they leave no gap longer than w,
    # and every orbit is a turn of the multiples of alpha.
    table = []
    for w in (math.log2(5 / 4), 0.1, 0.01, 0.001):
        bound = (2 / w) ** 13.3 / 1e-4
        points = [0.0]
        while True:
            points.sort()
            largest = max(
                [b - a for a, b in zip(points, points[1:])]
                + [1 - points[-1] + points[0]]
            )
            if largest <= w:
                break
            points.append((len(points) * alpha) % 1)
        table.append((f"{bound:.1e}", len(points)))
    results.append(
        report(
            f"Lemma 9: the J of the lemma and the smallest J, {table}",
            table
            == [("3.6e+14", 5), ("2.0e+21", 12), ("4.0e+34", 253), ("8.0e+47", 6291)],
        )
    )
    return 0 if all(results) else 1


if __name__ == "__main__":
    sys.exit(main())
