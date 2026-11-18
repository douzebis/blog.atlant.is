# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Part III of the paper, the onyx rosary: checks by computation.

usage: python check_onyx.py     (about 2 s)

Every line printed must end with "ok".

Checked:
- Proposition 2: pi(n) <= (8n + 1)/9 < n for every onyx 2 <= n < 20000,
  with equality at n = 10;
- the examples of the paper: the canonical recitations to beads 4 and 10,
  the covers quoted, the addresses tau(1), ..., tau(11) and iota(39) = 4;
- Lemma 6 (parity) and Lemma 7 (parity changes) for all beads below 20000;
- the computation behind Lemma 8: for a >= 3, the beads a U^i and
  (a + 1) U^i stay neighbors for exactly 1 + v2(a + 1) values of i, and
  the example of the chains of 22 and 256;
- the first 24 values of Jane's foraging sequence, as quoted.
"""

import sys

from rosary import (
    black_bead,
    down,
    foraging_sequence,
    is_black,
    lam,
    mu,
    nu,
    onyx_predecessor,
    reluctant_recitation,
    seed_and_lambex,
    up,
)


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
    predecessor = [0, 0] + [onyx_predecessor(n) for n in range(2, limit)]
    results.append(
        report(
            "Proposition 2: pi(n) <= (8n + 1)/9 < n for 2 <= n < 20000, pi(10) = 9",
            all(
                9 * predecessor[n] <= 8 * n + 1 and predecessor[n] < n
                for n in range(2, limit)
            )
            and predecessor[10] == 9,
        )
    )

    def canonical_recitation(n: int) -> list[int]:
        beads = [n]
        while n > 1:
            if is_black(n):
                n = max(mu(n), nu(n), key=lambda bead: seed_and_lambex(bead)[1])
            else:
                n = lam(n)
            beads.append(n)
        return beads[::-1]

    results.append(
        report(
            "examples: C(4), C(10), the candidates above beads 4 and 10",
            canonical_recitation(4) == [1, 2, 3, 5, 8, 4]
            and canonical_recitation(10) == [1, 2, 3, 5, 8, 4, 6, 9, 14, 21, 10]
            and [black_bead(k) for k in (1, 2, 3, 4)] == [1, 4, 7, 10]
            and seed_and_lambex(8) == (1, 4)
            and seed_and_lambex(9) == (4, 2)
            and seed_and_lambex(20)[0] == 13
            and seed_and_lambex(21)[0] == 4
            and predecessor[4] == 2
            and predecessor[2] == 1
            and reluctant_recitation(9)[-2:] == [14, 7],
        )
    )

    covers: dict[int, list[int]] = {}
    for n in range(2, limit):
        covers.setdefault(predecessor[n], []).append(n)
    results.append(
        report(
            "the covers quoted for onyxes 1, 2 and 5",
            covers[1][:6] == [2, 5, 11, 16, 24, 53]
            and covers[2][:5] == [3, 4, 6, 41, 92]
            and covers[5][:4] == [8, 12, 26, 39],
        )
    )

    def canonical(n: int) -> tuple[int, ...]:
        indices = []
        while n > 1:
            indices.append(covers[predecessor[n]].index(n) + 1)
            n = predecessor[n]
        return tuple(reversed(indices))

    results.append(
        report(
            "tau(1..11) as in the table of the paper",
            [canonical(n) for n in range(1, 12)]
            == [
                (),
                (1,),
                (1, 1),
                (1, 2),
                (2,),
                (1, 3),
                (1, 1, 1),
                (2, 1),
                (2, 1, 1),
                (2, 1, 1, 1),
                (3,),
            ],
        )
    )
    results.append(
        report(
            "iota(39) = 4, s_1(3) = 11, s_2(3) = 6",
            covers[predecessor[39]].index(39) == 3
            and covers[1][2] == 11
            and covers[2][2] == 6,
        )
    )

    results.append(
        report(
            "Lemma 6: nUD is black if and only if n and nU have different parities",
            all(is_black(down(up(n))) == (n % 2 != up(n) % 2) for n in range(1, limit)),
        )
    )
    parity_runs = True
    for n in range(1, limit):
        run, bead = 1, n
        while up(bead) % 2 == n % 2:
            bead = up(bead)
            run += 1
        # The run of equal parities starting at n has length v2(n) for an
        # even n and v2(n + 1) for an odd n.
        if run != two_adic_valuation(n if n % 2 == 0 else n + 1):
            parity_runs = False
    results.append(report("Lemma 7: parity runs along up-chains", parity_runs))

    neighbors = True
    for a in range(3, 3000):
        x, y, count = a, a + 1, 0
        while y - x == 1:
            x, y = up(x), up(y)
            count += 1
        if count != 1 + two_adic_valuation(a + 1):
            neighbors = False
    results.append(
        report("Lemma 8: neighbors for exactly 1 + v2(a + 1) steps", neighbors)
    )

    chain_22 = set()
    bead = 22
    while bead < 10**4:
        chain_22.add(bead)
        bead = up(bead)
    company = []
    bead = 256
    while bead < 10**4:
        if bead - 1 in chain_22:
            company.append(bead)
        bead = up(bead)
    results.append(
        report(
            "Lemma 8, example: the chains of 22 and 256 are neighbors 9 times",
            company == [2 ** (8 - i) * 3**i for i in range(9)],
        )
    )

    foraging = foraging_sequence(200)
    quoted = [1, 2, 3, 5, 4, 14, 5, 8, 6, 1, 11, 41, 31, 5, 12, 9]
    quoted += [7, 17, 13, 10, 2, 6, 21, 16]
    results.append(
        report(
            "foraging sequence: the 24 values quoted in the paper",
            foraging[:24] == quoted,
        )
    )
    return 0 if all(results) else 1


if __name__ == "__main__":
    sys.exit(main())
