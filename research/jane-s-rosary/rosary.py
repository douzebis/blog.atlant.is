# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Jane's rosary: the moves and the notions of the paper, as plain functions.

Names follow the paper ("Jane's infinite rosary"): beads are numbered from 1,
bead 1 is the end of the rosary, every third bead (1, 4, 7, ...) is black,
the others are white.  The black bead number k is the bead 3k - 2; the paper
writes it with a bullet and calls k an onyx.  The check_*.py programs of
this directory import this module.

Until 2026-11-18 the paper numbered the beads from 0; check_renumbering.py
checks that the functions below are the earlier ones shifted by one.
"""

import collections


def label(n: int) -> int:
    """The length of Jane's step at bead n: ceil(n/2)."""
    return (n + 1) // 2


def up(n: int) -> int:
    """The bead reached from n by an up move: n + L(n) = ceil(3n/2)."""
    return (3 * n + 1) // 2


def down(n: int) -> int:
    """The bead reached from n > 1 by a down move: n - L(n) = floor(n/2)."""
    return n // 2


def lam(n: int) -> int:
    """For a white bead n, the bead from which an up move leads to n."""
    return (2 * n) // 3


def mu(n: int) -> int:
    """The even bead from which a down move leads to n."""
    return 2 * n


def nu(n: int) -> int:
    """The odd bead from which a down move leads to n."""
    return 2 * n + 1


def is_black(n: int) -> bool:
    return n % 3 == 1


def black_bead(k: int) -> int:
    """The black bead number k (the bead of onyx k): 3k - 2."""
    return 3 * k - 2


def onyx(n: int) -> int:
    """For a black bead n, its number among the black beads."""
    if not is_black(n):
        raise ValueError(f"bead {n} is white")
    return (n + 2) // 3


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
    while n > 1:
        if not is_black(n):  # white bead: one up move from lam(n)
            n = lam(n)
            h += 1
        else:  # black bead: n becomes b_1 = (2/3)(2n + 1)
            n = (4 * n + 2) // 3
            h += 2  # one down move and one up move
            while n % 3 == 0:  # a_i = b_i - 1 and b_i are both white
                n = lam(n)
                h += 1
            if is_black(n):  # b_i is black: mu wins, continue from a_i
                n -= 1
    return h


def heights_by_exploration(largest: int) -> dict[int, int]:
    """Lengths of shortest recitations that stay among the beads 1..largest,
    found by breadth-first exploration from bead 1.

    These are upper bounds for the heights (a shortest recitation might
    leave the range).  They do not rely on any result of the paper.
    """
    found = {1: 0}
    queue = collections.deque([1])
    while queue:
        bead = queue.popleft()
        for other in (up(bead),) if bead == 1 else (up(bead), down(bead)):
            if other <= largest and other not in found:
                found[other] = found[bead] + 1
                queue.append(other)
    return found


def reluctant_recitation(moves: int) -> list[int]:
    """The beads rho(0), ..., rho(moves) of Jane's reluctant recitation."""
    told = {1}
    bead = 1
    beads = [1]
    for _ in range(moves):
        bead = down(bead) if bead > 1 and down(bead) not in told else up(bead)
        if bead in told:
            raise RuntimeError(f"the recitation is stuck after {len(beads) - 1} moves")
        told.add(bead)
        beads.append(bead)
    return beads


def onyx_predecessor(k: int) -> int:
    """For an onyx k > 1, the onyx of the seed of the winner among the two
    beads above the black bead number k (Theorem 1)."""
    seed_mu, lambex_mu = seed_and_lambex(mu(black_bead(k)))
    seed_nu, lambex_nu = seed_and_lambex(nu(black_bead(k)))
    return onyx(seed_mu if lambex_mu > lambex_nu else seed_nu)


def foraging_sequence(moves: int) -> list[int]:
    """Jane's foraging sequence on the first moves of the reluctant
    recitation: the onyxes of the seeds, without direct repetitions."""
    sequence: list[int] = []
    for bead in reluctant_recitation(moves):
        k = onyx(seed_and_lambex(bead)[0])
        if not sequence or k != sequence[-1]:
            sequence.append(k)
    return sequence
