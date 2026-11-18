# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""The renumbering of the beads changed no mathematics: checks.

usage: python check_renumbering.py     (about 10 s)

Until 2026-11-18 the paper numbered the beads from 0 (black beads 0, 3, 6,
...; onyx bead k was the black bead 3k).  It now numbers them from 1 (black
beads 1, 4, 7, ...; onyx k is the black bead 3k - 2).  This program keeps
the earlier definitions, in the class Previous below, exactly as they were
in rosary.py, and checks that every function of today's rosary.py is the
earlier one with every bead and every onyx increased by one.  Heights,
lambexes and numbers of moves are not shifted.

Every line printed must end with "ok".  See
docs/specs/0003-rosary-beads-counted-from-1.md.
"""

import collections
import sys

import rosary


class Previous:
    """rosary.py as it was when the beads were numbered from 0."""

    @staticmethod
    def up(n: int) -> int:
        """The bead reached from n by an up move: n + L(n) = floor(3n/2) + 1."""
        return (3 * n) // 2 + 1

    @staticmethod
    def down(n: int) -> int:
        """The bead reached from n > 0 by a down move: n - L(n) = ceil(n/2) - 1."""
        return (n + 1) // 2 - 1

    @staticmethod
    def lam(n: int) -> int:
        """For a white bead n, the bead from which an up move leads to n."""
        return (2 * n) // 3

    @staticmethod
    def mu(n: int) -> int:
        """The odd bead from which a down move leads to n."""
        return 2 * n + 1

    @staticmethod
    def nu(n: int) -> int:
        """The even bead from which a down move leads to n."""
        return 2 * n + 2

    @staticmethod
    def is_black(n: int) -> bool:
        return n % 3 == 0

    @staticmethod
    def seed_and_lambex(n: int) -> tuple[int, int]:
        """The black bead from which n is reached by up moves only, and the
        number of those up moves."""
        lambex = 0
        while not Previous.is_black(n):
            n = Previous.lam(n)
            lambex += 1
        return n, lambex

    @staticmethod
    def height(n: int) -> int:
        """The height of bead n by the logarithmic algorithm of the paper
        (Lemma 2 and Theorem 1)."""
        h = 0
        while n:
            if n % 3:  # white bead: one up move from Previous.lam(n)
                n = Previous.lam(n)
                h += 1
            else:  # black bead 3m: n becomes a_1 = 4m
                n = (4 * n + 2) // 3
                h += 2  # one down move and one up move
                while n % 3 == 1:  # a_i and b_i are both white
                    n = Previous.lam(n)
                    h += 1
                if n % 3 == 0:  # a_i is black: nu wins, continue from b_i
                    n += 1
        return h

    @staticmethod
    def heights_by_exploration(largest: int) -> dict[int, int]:
        """Lengths of shortest recitations that stay among the beads 0..largest,
        found by breadth-first exploration from bead 0.

        These are upper bounds for the heights (a shortest recitation might
        leave the range).  They do not rely on any result of the paper.
        """
        found = {0: 0}
        queue = collections.deque([0])
        while queue:
            bead = queue.popleft()
            for other in (
                (Previous.up(bead),)
                if bead == 0
                else (Previous.up(bead), Previous.down(bead))
            ):
                if other <= largest and other not in found:
                    found[other] = found[bead] + 1
                    queue.append(other)
        return found

    @staticmethod
    def reluctant_recitation(moves: int) -> list[int]:
        """The beads rho(0), ..., rho(moves) of Jane's reluctant recitation."""
        told = {0}
        bead = 0
        beads = [0]
        for _ in range(moves):
            below = Previous.down(bead) if bead else 0
            bead = below if bead and below not in told else Previous.up(bead)
            if bead in told:
                raise RuntimeError(
                    f"the recitation is stuck after {len(beads) - 1} moves"
                )
            told.add(bead)
            beads.append(bead)
        return beads

    @staticmethod
    def onyx_predecessor(n: int) -> int:
        """For an onyx bead n > 0 (the black bead 3n), the onyx bead of the seed
        of the winner among (3n)mu and (3n)nu (Theorem 1)."""
        seed_mu, lambex_mu = Previous.seed_and_lambex(Previous.mu(3 * n))
        seed_nu, lambex_nu = Previous.seed_and_lambex(Previous.nu(3 * n))
        return (seed_mu if lambex_mu > lambex_nu else seed_nu) // 3


def report(name: str, passed: bool) -> bool:
    print(f"{name}: {'ok' if passed else 'FAILED'}")
    return passed


def main() -> int:
    beads = 200000
    results = [
        report(
            f"up, lambda, mu, nu and the colors, for the {beads} first beads",
            all(
                rosary.up(n + 1) == Previous.up(n) + 1
                and rosary.mu(n + 1) == Previous.mu(n) + 1
                and rosary.nu(n + 1) == Previous.nu(n) + 1
                and rosary.is_black(n + 1) == Previous.is_black(n)
                and (Previous.is_black(n) or rosary.lam(n + 1) == Previous.lam(n) + 1)
                for n in range(beads)
            ),
        ),
        report(
            "down and the label",
            all(
                rosary.down(n + 1) == Previous.down(n) + 1
                and rosary.label(n + 1) == Previous.up(n) - n
                for n in range(1, beads)
            ),
        ),
        report(
            "seed and lambex",
            all(
                rosary.seed_and_lambex(n + 1)
                == (Previous.seed_and_lambex(n)[0] + 1, Previous.seed_and_lambex(n)[1])
                for n in range(beads)
            ),
        ),
        report(
            "black bead number k and its onyx",
            all(
                rosary.black_bead(k + 1) == 3 * k + 1
                and rosary.onyx(3 * k + 1) == k + 1
                for k in range(beads)
            ),
        ),
        report(
            "height by the logarithmic algorithm",
            all(rosary.height(n + 1) == Previous.height(n) for n in range(beads)),
        ),
    ]
    now = rosary.heights_by_exploration(beads)
    before = Previous.heights_by_exploration(beads - 1)
    results.append(
        report(
            "height by exploration",
            len(now) == len(before)
            and all(now[n + 1] == height for n, height in before.items()),
        )
    )
    results.append(
        report(
            "reluctant recitation, 300000 moves",
            [bead - 1 for bead in rosary.reluctant_recitation(300000)]
            == Previous.reluctant_recitation(300000),
        )
    )
    results.append(
        report(
            "onyx predecessor",
            all(
                rosary.onyx_predecessor(k + 1) == Previous.onyx_predecessor(k) + 1
                for k in range(1, 60000)
            ),
        )
    )
    foraging = [0]
    for bead in Previous.reluctant_recitation(20000):
        k = Previous.seed_and_lambex(bead)[0] // 3
        if k != foraging[-1]:
            foraging.append(k)
    results.append(
        report(
            "foraging sequence, 20000 moves",
            [k - 1 for k in rosary.foraging_sequence(20000)] == foraging,
        )
    )
    return 0 if all(results) else 1


if __name__ == "__main__":
    sys.exit(main())
