# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Jane's rosary: the moves and the notions of the paper, as plain functions.

Names follow the paper ("Jane's infinite rosary"): beads are the natural
numbers, every third bead (0, 3, 6, ...) is black, the others are white.
The check_*.py programs of this directory import this module.
"""

import collections


def up(n: int) -> int:
    """The bead reached from n by an up move: n + L(n) = floor(3n/2) + 1."""
    return (3 * n) // 2 + 1


def down(n: int) -> int:
    """The bead reached from n > 0 by a down move: n - L(n) = ceil(n/2) - 1."""
    return (n + 1) // 2 - 1


def lam(n: int) -> int:
    """For a white bead n, the bead from which an up move leads to n."""
    return (2 * n) // 3


def mu(n: int) -> int:
    """The odd bead from which a down move leads to n."""
    return 2 * n + 1


def nu(n: int) -> int:
    """The even bead from which a down move leads to n."""
    return 2 * n + 2


def is_black(n: int) -> bool:
    return n % 3 == 0


def seed_and_lambex(n: int) -> tuple[int, int]:
    """The black bead from which n is reached by up moves only, and the
    number of those up moves."""
    lambex = 0
    while not is_black(n):
        n = lam(n)
        lambex += 1
    return n, lambex


def height(n: int) -> int:
    """The height of bead n by the logarithmic algorithm of the paper
    (Lemma 2 and Theorem 1)."""
    h = 0
    while n:
        if n % 3:  # white bead: one up move from lam(n)
            n = lam(n)
            h += 1
        else:  # black bead 3m: n becomes a_1 = 4m
            n = (4 * n + 2) // 3
            h += 2  # one down move and one up move
            while n % 3 == 1:  # a_i and b_i are both white
                n = lam(n)
                h += 1
            if n % 3 == 0:  # a_i is black: nu wins, continue from b_i
                n += 1
    return h


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
        for other in (up(bead),) if bead == 0 else (up(bead), down(bead)):
            if other <= largest and other not in found:
                found[other] = found[bead] + 1
                queue.append(other)
    return found


def reluctant_recitation(moves: int) -> list[int]:
    """The beads rho(0), ..., rho(moves) of Jane's reluctant recitation."""
    told = {0}
    bead = 0
    beads = [0]
    for _ in range(moves):
        below = down(bead) if bead else 0
        bead = below if bead and below not in told else up(bead)
        if bead in told:
            raise RuntimeError(f"the recitation is stuck after {len(beads) - 1} moves")
        told.add(bead)
        beads.append(bead)
    return beads


def onyx_predecessor(n: int) -> int:
    """For an onyx bead n > 0 (the black bead 3n), the onyx bead of the seed
    of the winner among (3n)mu and (3n)nu (Theorem 1)."""
    seed_mu, lambex_mu = seed_and_lambex(mu(3 * n))
    seed_nu, lambex_nu = seed_and_lambex(nu(3 * n))
    return (seed_mu if lambex_mu > lambex_nu else seed_nu) // 3
