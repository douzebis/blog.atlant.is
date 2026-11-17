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
- Corollary 1: h(b) = 1 + min(h(b mu), h(b nu)) for a black bead b > 0;
- Theorem 1, parts 2 to 5, for every black bead 3n < N;
- the remark after the definition of seeds: sigma(3n-1) <= 2n-1 and
  sigma(3n+1) <= 2n;
- Proposition 1 (the three bounds on the height), for all beads below
  10^6, with the logarithmic algorithm.
"""

import argparse
import math
import sys

from rosary import (
    height,
    heights_by_exploration,
    is_black,
    lam,
    mu,
    nu,
    seed_and_lambex,
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
            all(explored[n] == height(n) for n in range(beads)),
        )
    )
    results.append(
        report(
            "Lemma 2: h(w) = h(w lambda) + 1 for white w",
            all(
                explored[w] == explored[lam(w)] + 1
                for w in range(1, beads)
                if not is_black(w)
            ),
        )
    )
    results.append(
        report(
            "Corollary 1: h(b) = 1 + min(h(b mu), h(b nu)) for black b > 0",
            all(
                explored[b] == 1 + min(explored[mu(b)], explored[nu(b)])
                for b in range(3, beads, 3)
            ),
        )
    )

    lambexes = closed_form = seeds = neighbors = winner = True
    remark = True
    for n in range(1, beads // 3):
        b = 3 * n
        seed_mu, lambex_mu = seed_and_lambex(mu(b))
        seed_nu, lambex_nu = seed_and_lambex(nu(b))
        # 2n + 1 = 3^e q with q not divisible by 3.
        e, q = 0, 2 * n + 1
        while q % 3 == 0:
            q //= 3
            e += 1
        mu_wins = (pow(2, e + 1, 3) * q) % 3 == 1
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
        if seed_and_lambex(b - 1)[0] > 2 * n - 1 or seed_and_lambex(b + 1)[0] > 2 * n:
            remark = False
    results += [
        report("Theorem 1 (2): the winner is read off 2n + 1 = 3^e q", closed_form),
        report("Theorem 1 (3): different lambexes and seeds", lambexes),
        report("Theorem 1 (3): larger lambex if and only if smaller seed", seeds),
        report("Theorem 1 (4): h(3n) >= h(3n - 1) and h(3n) >= h(3n + 1)", neighbors),
        report("Theorem 1 (5): h(3n) = h(seed of winner) + its lambex + 1", winner),
        report("Remark: sigma(3n - 1) <= 2n - 1 and sigma(3n + 1) <= 2n", remark),
    ]

    million = 10**6
    heights = [height(n) for n in range(million)]
    log98 = math.log(9 / 8)
    log32 = math.log(3 / 2)
    results += [
        report(
            "Proposition 1: h(n) >= log_{3/2}((n + 2)/2) for 1 <= n < 10^6",
            all(
                heights[n] >= math.log((n + 2) / 2) / log32 - 1e-9
                for n in range(1, million)
            ),
        ),
        report(
            "Proposition 1: h(n) <= 1 + 4n/3 for 1 <= n < 10^6",
            all(heights[n] <= 1 + 4 * n / 3 for n in range(1, million)),
        ),
        report(
            "Proposition 1: h(n) <= 12 + 3 ln n / ln(9/8) for 1 <= n < 10^6",
            all(heights[n] <= 12 + 3 * math.log(n) / log98 for n in range(1, million)),
        ),
    ]
    return 0 if all(results) else 1


if __name__ == "__main__":
    sys.exit(main())
