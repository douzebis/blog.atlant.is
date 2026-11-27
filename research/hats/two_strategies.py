# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""The game of hats when the two players may use different strategies.

usage: two_strategies.py N                 the best score by enumeration
       two_strategies.py N --lp > model.lp an integer program for a solver

Alice wears stack t and sees u; she points at a(u).  Bob wears u, sees t
and points at b(t).  The pair (t, u) is a hit when t is black at a(u) and
u is black at b(t).  The question (Section 7 of the article): can the
best pair (a, b) on N hats win more pairs than the best strategy that
both players share?

By enumeration: for each strategy a of Alice, the best answer of Bob is
found one stack at a time, since what Bob does when he sees t only
matters to the pairs (t, u).  This takes N^(2^N) strategies of Alice: fine
for N up to 3.

With --lp: variables a_u_p and b_t_p (the choices) and h_t_u (the pair is
a hit), maximize the number of hits.  In CPLEX LP format.
"""

import argparse
import itertools


def black(t: int, n: int) -> list[int]:
    return [p for p in range(n) if t >> p & 1]


def best_by_enumeration(n: int) -> int:
    stacks = range(2**n)
    best = 0
    for a in itertools.product(range(n), repeat=2**n):
        total = 0
        for t in stacks:
            # the stacks u for which Alice, wearing t, points at a black hat
            good = [u for u in stacks if t >> a[u] & 1]
            total += max(sum(u >> q & 1 for u in good) for q in range(n))
        best = max(best, total)
    return best


def write_lp(n: int) -> str:
    # A player who wears the all-white stack cannot win: stack 0 is left out.
    stacks = range(1, 2**n)
    rows: list[str] = []
    hits: list[str] = []
    for u in stacks:
        rows.append(" + ".join(f"a_{u}_{p}" for p in range(n)) + " = 1")
        rows.append(" + ".join(f"b_{u}_{p}" for p in range(n)) + " = 1")
    for t in stacks:
        for u in stacks:
            h = f"h_{t}_{u}"
            hits.append(h)
            rows.append(h + "".join(f" - a_{u}_{p}" for p in black(t, n)) + " <= 0")
            rows.append(h + "".join(f" - b_{t}_{q}" for q in black(u, n)) + " <= 0")
    lines = ["Maximize", " obj: " + " + ".join(hits), "Subject To"]
    lines += [f" c{i}: {row}" for i, row in enumerate(rows)]
    lines.append("Bounds")
    lines += [f" 0 <= {h} <= 1" for h in hits]
    lines.append("Binary")
    lines += [f" {x}_{u}_{p}" for x in "ab" for u in stacks for p in range(n)]
    lines.append("End")
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description="Two players, two strategies")
    parser.add_argument("n", type=int, help="number of hats")
    parser.add_argument("--lp", action="store_true", help="write an integer program")
    args = parser.parse_args()
    if args.lp:
        print(write_lp(args.n), end="")
    else:
        print(
            f"{args.n} hats: best score with two strategies {best_by_enumeration(args.n)}"
        )


if __name__ == "__main__":
    main()
