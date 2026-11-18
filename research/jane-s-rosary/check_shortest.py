# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Part I of the paper, shortest recitations: checks by computation.

usage: python check_shortest.py [--beads N]     (default 60000; about 10 s)

Heights are computed in two independent ways: by exploration of the beads
up to 40 N (rosary.heights_by_exploration, which uses no result of the
paper and gives upper bounds) and by the logarithmic algorithm
(rosary.height, which is Lemma 2 and Theorem 1 turned into a program).
Every line printed must end with "ok".

Checked for all beads below N unless said otherwise:
- the two computations of the height agree;
- Lemma 2: h(w) = h(w lambda) + 1 for a white bead w;
- Corollary 1: h(b) = 1 + min(h(b mu), h(b nu)) for a black bead b > 1;
- Theorem 1, parts 2 to 5, for every black bead 3k - 2 < N with k >= 2;
- the remark after the definition of seeds: for such a black bead b,
  sigma(b - 1) <= 2k - 2 and sigma(b + 1) <= 2k - 1;
- Proposition 1 (the three bounds on the height) and the remark after it,
  for all beads from 2 to 10^6, with the logarithmic algorithm;
- the examples of Part I (bead 8, its neighbor 9, the black bead 4).
"""

import argparse
import math
import sys

from rosary import (
    black_bead,
    down,
    height,
    heights_by_exploration,
    is_black,
    lam,
    mu,
    nu,
    seed_and_lambex,
    up,
)


def report(name: str, passed: bool) -> bool:
    print(f"{name}: {'ok' if passed else 'FAILED'}")
    return passed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--beads", type=int, default=60000, metavar="N")
    beads = parser.parse_args().beads
    explored = heights_by_exploration(40 * beads)
    results = []

    results.append(
        report(
            f"height: exploration and logarithmic algorithm agree for n < {beads}",
            all(explored[n] == height(n) for n in range(1, beads)),
        )
    )
    results.append(
        report(
            "Lemma 2: h(w) = h(w lambda) + 1 for white w",
            all(
                explored[w] == explored[lam(w)] + 1
                for w in range(2, beads)
                if not is_black(w)
            ),
        )
    )
    results.append(
        report(
            "Corollary 1: h(b) = 1 + min(h(b mu), h(b nu)) for black b > 1",
            all(
                explored[b] == 1 + min(explored[mu(b)], explored[nu(b)])
                for b in range(4, beads, 3)
            ),
        )
    )

    lambexes = closed_form = seeds = neighbors = winner = True
    remark = True
    for k in range(2, beads // 3):
        b = black_bead(k)
        seed_mu, lambex_mu = seed_and_lambex(mu(b))
        seed_nu, lambex_nu = seed_and_lambex(nu(b))
        # 2k - 1 = 3^e q with q not divisible by 3.
        e, q = 0, 2 * k - 1
        while q % 3 == 0:
            q //= 3
            e += 1
        # b_{e+1} = 2^(e+1) q; mu wins when it is black.
        mu_wins = is_black(2 ** (e + 1) * q)
        if lambex_mu == lambex_nu or seed_mu == seed_nu:
            lambexes = False
        if mu_wins != (lambex_mu > lambex_nu) or min(lambex_mu, lambex_nu) != e + 1:
            closed_form = False
        if (lambex_mu > lambex_nu) != (seed_mu < seed_nu):
            seeds = False
        if explored[b] < explored[b - 1] or explored[b] < explored[b + 1]:
            neighbors = False
        seed, lambex = (
            (seed_mu, lambex_mu) if lambex_mu > lambex_nu else (seed_nu, lambex_nu)
        )
        if explored[b] != explored[seed] + lambex + 1:
            winner = False
        if (
            seed_and_lambex(b - 1)[0] > 2 * k - 2
            or seed_and_lambex(b + 1)[0] > 2 * k - 1
        ):
            remark = False
    results += [
        report("Theorem 1 (2): the winner is read off 2k - 1 = 3^e q", closed_form),
        report("Theorem 1 (3): different lambexes and seeds", lambexes),
        report("Theorem 1 (3): larger lambex if and only if smaller seed", seeds),
        report("Theorem 1 (4): h(b) >= h(b - 1) and h(b) >= h(b + 1)", neighbors),
        report("Theorem 1 (5): h(b) = h(seed of winner) + its lambex + 1", winner),
        report("Remark: sigma(b - 1) <= 2k - 2 and sigma(b + 1) <= 2k - 1", remark),
    ]

    # Fact 1, the six diagrams in the proof of Lemma 1, the two candidates
    # drawn after Corollary 1, and the three cases of Proposition 1.
    fact = all(
        up(2 * j - 1) == 3 * j - 1
        and up(2 * j) == 3 * j
        and down(mu(j)) == j
        and down(nu(j)) == j
        and mu(j) % 2 == 0
        for j in range(1, beads)
    )
    diagrams = True
    for k in range(beads // 12):
        w = 3 * k + 2
        tall = [
            (mu(mu(w)), 12 * k + 8, 8 * k + 5, 4 * k + 2),
            (nu(mu(w)), 12 * k + 9, 8 * k + 6, 4 * k + 3),
        ]
        if not (
            lam(w) == 2 * k + 1
            and nu(w) == 6 * k + 5
            and not is_black(nu(w))
            and lam(nu(w)) == 4 * k + 3
            and down(4 * k + 3) == lam(w)
            and mu(w) == 6 * k + 4
            and is_black(mu(w))
            and all(
                top == bead
                and lam(top) == left
                and down(left) == middle
                and down(middle) == lam(w)
                for top, bead, left, middle in tall
            )
        ):
            diagrams = False
        if k == 0:
            continue
        w = 3 * k
        tall = [
            (mu(nu(w)), 12 * k + 2, 8 * k + 1, 4 * k),
            (nu(nu(w)), 12 * k + 3, 8 * k + 2, 4 * k + 1),
        ]
        if not (
            lam(w) == 2 * k
            and mu(w) == 6 * k
            and not is_black(mu(w))
            and lam(mu(w)) == 4 * k
            and down(4 * k) == lam(w)
            and nu(w) == 6 * k + 1
            and is_black(nu(w))
            and all(
                top == bead
                and lam(top) == left
                and down(left) == middle
                and down(middle) == lam(w)
                for top, bead, left, middle in tall
            )
        ):
            diagrams = False
    candidates = all(
        mu(black_bead(k)) == 6 * k - 4
        and lam(6 * k - 4) == 4 * k - 3
        and nu(black_bead(k)) == 6 * k - 3
        and lam(6 * k - 3) == 4 * k - 2
        for k in range(1, beads)
    )
    cases = True
    for n in range(2, beads):
        if not is_black(n):
            m = lam(n)
            reached = up(m)
        elif n % 9 != 1:
            m = (8 * n) // 9
            reached = down(up(up(m)))
            if m != lam(lam(mu(n))):
                cases = False
        else:
            m = -((-8 * n) // 9)
            reached = down(up(up(m)))
            if m != lam(lam(nu(n))):
                cases = False
        if reached != n or m >= n or 9 * (m - 7) > 8 * (n - 7):
            cases = False
    results += [
        report("Fact 1: the images of U, and mu, nu above a bead", fact),
        report("Lemma 1: the six diagrams of the proof", diagrams),
        report("after Corollary 1: the two candidates above a black bead", candidates),
        report("Proposition 1: the three cases of the proof", cases),
    ]

    # The chains of Theorem 1 and of its proof.
    chains = True
    for k in range(2, 3000):
        b = black_bead(k)
        e, q = 0, 2 * k - 1
        while q % 3 == 0:
            q //= 3
            e += 1
        upper_a, upper_b = mu(b), nu(b)
        lower_c, lower_d = b - 1, b + 1
        for i in range(e + 2):
            b_i = 2**i * 3 ** (e + 1 - i) * q
            if (upper_a, upper_b) != (b_i - 1, b_i):
                chains = False
            if i >= 1 and (lower_c, lower_d) != (down(upper_a), down(upper_b)):
                chains = False
            if i <= e:
                if is_black(upper_a) or is_black(upper_b):
                    chains = False
                if is_black(lower_c) or is_black(lower_d):
                    chains = False
                upper_a, upper_b = lam(upper_a), lam(upper_b)
                lower_c, lower_d = lam(lower_c), lam(lower_d)
        blacks = [is_black(x) for x in (upper_a, upper_b, lower_c, lower_d)]
        if blacks not in ([False, True, True, False], [True, False, False, True]):
            chains = False
        if (lower_c == 1) != (k == 2):
            chains = False
    results.append(
        report("Theorem 1: the chains a_i, b_i, c_i, d_i and their colors", chains)
    )

    million = 10**6
    heights = [0] + [height(n) for n in range(1, million + 1)]
    beads_checked = range(2, million + 1)
    log98 = math.log(9 / 8)
    log32 = math.log(3 / 2)
    results += [
        report(
            "Proposition 1: h(n) >= log_{3/2}((n + 1)/2) for 2 <= n <= 10^6",
            all(
                heights[n] >= math.log((n + 1) / 2) / log32 - 1e-9
                for n in beads_checked
            ),
        ),
        report(
            "Proposition 1: h(n) <= (4n - 1)/3 for 2 <= n <= 10^6, "
            "with equality exactly at 4 and 7",
            all(3 * heights[n] <= 4 * n - 1 for n in beads_checked)
            and [n for n in beads_checked if 3 * heights[n] == 4 * n - 1] == [4, 7],
        ),
        report(
            "Proposition 1: h(n) <= 12 + 3 ln n / ln(9/8) for 2 <= n <= 10^6",
            all(heights[n] <= 12 + 3 * math.log(n) / log98 for n in beads_checked),
        ),
        report(
            "after Proposition 1: h(n) <= 1 + 3 ln n / ln(9/8) for 2 <= n <= 10^6",
            all(heights[n] <= 1 + 3 * math.log(n) / log98 for n in beads_checked),
        ),
        report(
            "h(1), h(2), ... = 0, 1, 2, 5, 3, 6, 9, 4, 7, 10, 10",
            heights[1:12] == [0, 1, 2, 5, 3, 6, 9, 4, 7, 10, 10],
        ),
        report(
            "examples: bead 8 (label, moves, seed, lambex) and its neighbor 9",
            up(8) == 12
            and down(8) == 4
            and lam(8) == 5
            and (mu(8), nu(8)) == (16, 17)
            and seed_and_lambex(8) == (1, 4)
            and seed_and_lambex(9) == (4, 2)
            and heights[8] == 4
            and heights[4] == 5,
        ),
    ]
    return 0 if all(results) else 1


if __name__ == "__main__":
    sys.exit(main())
