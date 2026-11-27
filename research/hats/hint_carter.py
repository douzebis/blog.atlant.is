# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""The hint bounds on V, and the Carter strategies.

usage: hint_carter.py [D]          (D at most 6; the default is 6)

The upper bounds on V of Buhler et al. (arXiv 1407.4711, Section 3) come
from a hint: Alice's stack is one of the non-constant affine functions on
d bits, her hats being its values at the 2^d points.  Bob, who sees which
function it is, sorts the 2 (2^d - 1) functions into blocks, one for each
of his own hats that he may point at.  The bound is the best value H_d of
this game over all the ways of sorting (81/224 for d = 3).

A strategy of Bob on n = d + 1 hats gives such a sorting: look at Alice's
hats at the points 0, e_1, ..., e_d only.  These n hats make every stack
of n hats that is not of a single color, once each.  So

    H_d  >=  (hits - 2^d) / (2^n (2^n - 2))                          (*)

for the hits of any pair of strategies on n hats, 2^d being the hits in
which Alice's stack is all black (none when it is all white).  In words:
the hint bound of dimension d is at least the win rate on d + 1 hats when
Alice's stack is known not to be of a single color.

This program computes H_d for the sorting that the Carter strategy on
d + 1 hats defines, Alice being free to point at any of the 2^d points,
and compares it with the right-hand side of (*).  They are equal for d
from 1 to 6, and equal to every known value of the best H_d:

    d = 1, 2   3/8         (the first bound of the paper)
    d = 3      81/224      (the paper, by exhaustion)
    d = 4      57/160      (the hill-climbing of the paper; claimed exact
                            in github.com/yangsong97/levine-hat-bounds,
                            November 2026, not reviewed)
    d = 5      1401/3968   (best found there, by annealing)
    d = 6      45/128      (the same)

Read the other way, (*) bounds the best score on n hats, with one
strategy or two: hits <= 2^d + 2^n (2^n - 2) max H_d.
"""

import sys
from fractions import Fraction

import check_article as ca


def value(a: int, b: int, x: int) -> int:
    """The affine function (a, b) at the point x."""
    return ((a & x).bit_count() + b) & 1


def referee_value(d: int, bob: ca.Strategy) -> Fraction:
    """H_d for the sorting that Bob's strategy on d + 1 hats defines."""
    n = d + 1
    labels = [(a, b) for a in range(1, 2**d) for b in (0, 1)]

    def stack(a: int, b: int) -> int:
        # hat 0 is the value at the point 0, hat i the value at e_i
        return value(a, b, 0) | sum(value(a, b, 1 << (i - 1)) << i for i in range(1, n))

    block = {label: bob[stack(*label)] for label in labels}
    total = 0
    for u in range(2**n):  # the hats of Bob
        kept = [label for label in labels if u >> block[label] & 1]
        total += max(sum(value(a, b, x) for a, b in kept) for x in range(2**d))
    return Fraction(total, 2**n * len(labels))


def main() -> int:
    top = int(sys.argv[1]) if len(sys.argv) > 1 else 6
    failures = 0
    for d in range(1, top + 1):
        n = d + 1
        carter = ca.carter(n)
        hits = ca.hits(n, carter)
        conditional = Fraction(hits - 2**d, 2**n * (2**n - 2))
        found = referee_value(d, carter)
        failures += found != conditional
        print(
            f"d = {d}: Carter on {n} hats has {hits} hits; "
            f"(hits - 2^d) / (2^n (2^n - 2)) = {conditional} = {float(conditional):.6f}; "
            f"H_d of its sorting = {found}"
        )
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
