# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Part III of the paper, the onyx rosary: checks by computation.

usage: python check_onyx.py     (about 2 s)

Every line printed must end with "ok".

Checked:
- Proposition 2: pi(n) <= 8n/9 for every onyx bead 0 < n < 20000;
- the examples of the paper: the canonical onyx mapping C(0), ..., C(10)
  and iota(38) = 3;
- Lemma 6 (parity) and Lemma 7 (parity changes) for all beads below 20000;
- the computation behind Lemma 8: for a >= 2, the beads a U^i and
  (a + 1) U^i stay neighbors for exactly 1 + v2(a + 2) values of i;
- the first 24 values of Jane's foraging sequence, as quoted.
"""

import sys

from rosary import down, onyx_predecessor, reluctant_recitation, seed_and_lambex, up


def report(name: str, passed: bool) -> bool:
    print(f"{name}: {'ok' if passed else 'FAILED'}")
    return passed


def two_adic_valuation(n: int) -> int:
    valuation = 0
    while n % 2 == 0:
        n //= 2
        valuation += 1
    return valuation


def main() -> int:
    results = []
    limit = 20000
    predecessor = [0] + [onyx_predecessor(n) for n in range(1, limit)]
    results.append(
        report(
            "Proposition 2: pi(n) <= 8n/9 for 0 < n < 20000",
            all(9 * predecessor[n] <= 8 * n for n in range(1, limit)),
        )
    )

    covers: dict[int, list[int]] = {}
    for n in range(1, limit):
        covers.setdefault(predecessor[n], []).append(n)

    def canonical(n: int) -> tuple[int, ...]:
        indices = []
        while n:
            indices.append(covers[predecessor[n]].index(n))
            n = predecessor[n]
        return tuple(reversed(indices))

    results.append(
        report(
            "C(0..10) as in the table of the paper",
            [canonical(n) for n in range(11)]
            == [
                (),
                (0,),
                (0, 0),
                (0, 1),
                (1,),
                (0, 2),
                (0, 0, 0),
                (1, 0),
                (1, 0, 0),
                (1, 0, 0, 0),
                (2,),
            ],
        )
    )
    results.append(report("iota(38) = 3", covers[predecessor[38]].index(38) == 3))

    results.append(
        report(
            "Lemma 6: 3 | nUD if and only if n and nU have different parities",
            all((down(up(n)) % 3 == 0) == (n % 2 != up(n) % 2) for n in range(limit)),
        )
    )
    parity_runs = True
    for n in range(limit):
        run, bead = 1, n
        while up(bead) % 2 == n % 2:
            bead = up(bead)
            run += 1
        # The run of equal parities starting at n has length v2(n + 2) for an
        # even n and v2(n + 1) for an odd n.
        if run != two_adic_valuation(n + 2 if n % 2 == 0 else n + 1):
            parity_runs = False
    results.append(report("Lemma 7: parity runs along up-chains", parity_runs))

    neighbors = True
    for a in range(2, 3000):
        x, y, count = a, a + 1, 0
        while y - x == 1:
            x, y = up(x), up(y)
            count += 1
        if count != 1 + two_adic_valuation(a + 2):
            neighbors = False
    results.append(
        report("Lemma 8: neighbors for exactly 1 + v2(a + 2) steps", neighbors)
    )

    foraging = [0]
    for bead in reluctant_recitation(200):
        onyx = seed_and_lambex(bead)[0] // 3
        if onyx != foraging[-1]:
            foraging.append(onyx)
    quoted = [
        0,
        1,
        2,
        4,
        3,
        13,
        4,
        7,
        5,
        0,
        10,
        40,
        30,
        4,
        11,
        8,
        6,
        16,
        12,
        9,
        1,
        5,
        20,
        15,
    ]
    results.append(
        report(
            "foraging sequence: the 24 values quoted in the paper",
            foraging[:24] == quoted,
        )
    )
    return 0 if all(results) else 1


if __name__ == "__main__":
    sys.exit(main())
