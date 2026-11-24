# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Generalized resets on blocks of m hats, as an integer program.

usage: reset_schemes_lp.py M [--size Z] [--beat] > model.lp

Question 4 of docs/papers/hats/open-questions.md.  A scheme gives every
stack of m hats either a position to point at or the order to skip the
block; Z is the set of the skipped stacks.  Its win rate is

    (A + c) / (4^m - |Z|^2)

so it is 7/20 or more exactly when

    F = 20 (A + c) + 7 |Z|^2  >=  7 * 4^m.

F is a sum over the pairs of stacks of a term that only depends on what
the two stacks do, as the hits of a strategy are.  This program writes
"maximize F" in CPLEX LP format, for SCIP or another solver.  With --beat
it adds the row F >= 7 * 4^m + 1: the model is then infeasible exactly
when no scheme beats 7/20.

With --size Z the number of skipped stacks is fixed.  The model is then
"maximize A + c", and --beat asks for A + c > 7 (4^m - Z^2) / 20.

Variables: x_t_p = 1 when stack t points at p, s_t = 1 when it is
skipped; w, h, g stand for the products that F needs (both stacks point
and win; one is skipped and black where the other points; both are
skipped).  They are only bounded from above, which is enough in a
maximization.
"""

import argparse


def black(t: int, m: int) -> list[int]:
    """The positions of the black hats of stack t."""
    return [p for p in range(m) if t >> p & 1]


def write_lp(m: int, beat: bool, size: int | None = None) -> str:
    stacks = range(2**m)
    # The weights of F; with a fixed size, those of A + c.
    unit = 20 if size is None else 1
    objective: dict[str, int] = {}
    rows: list[str] = []
    products: list[str] = []
    for t in stacks:
        rows.append(" + ".join(f"x_{t}_{p}" for p in range(m)) + f" + s_{t} = 1")
        if size is None:
            objective[f"s_{t}"] = 7
        for p in black(t, m):
            objective[f"x_{t}_{p}"] = unit
    for t in stacks:
        for u in stacks:
            if u == t:
                continue
            # t is skipped, u points at a black hat of t
            if black(t, m):
                h = f"h_{t}_{u}"
                products.append(h)
                objective[h] = unit
                rows.append(f"{h} - s_{t} <= 0")
                rows.append(h + "".join(f" - x_{u}_{q}" for q in black(t, m)) + " <= 0")
            if u < t:
                continue
            # both are skipped
            if size is None:
                g = f"g_{t}_{u}"
                products.append(g)
                objective[g] = 14
                rows.append(f"{g} - s_{t} <= 0")
                rows.append(f"{g} - s_{u} <= 0")
            # both point, and both at a black hat
            if black(t, m) and black(u, m):
                w = f"w_{t}_{u}"
                products.append(w)
                objective[w] = 2 * unit
                rows.append(w + "".join(f" - x_{t}_{p}" for p in black(u, m)) + " <= 0")
                rows.append(w + "".join(f" - x_{u}_{q}" for q in black(t, m)) + " <= 0")
    skipped = " + ".join(f"s_{t}" for t in stacks)
    score = " + ".join(f"{c} {v}" for v, c in objective.items())
    if size is None:
        # Z is not everything
        rows.append(f"{skipped} <= {2**m - 1}")
        if beat:
            rows.append(f"{score} >= {7 * 4**m + 1}")
    else:
        rows.append(f"{skipped} = {size}")
        if beat:
            rows.append(f"{score} >= {7 * (4**m - size**2) // 20 + 1}")
    lines = ["Maximize", f" obj: {score}", "Subject To"]
    lines += [f" c{i}: {row}" for i, row in enumerate(rows)]
    lines.append("Bounds")
    lines += [f" 0 <= {v} <= 1" for v in products]
    lines.append("Binary")
    lines += [f" x_{t}_{p}" for t in stacks for p in range(m)]
    lines += [f" s_{t}" for t in stacks]
    lines.append("End")
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(
        description=__doc__.split("\n")[0] if __doc__ else None
    )
    parser.add_argument("m", type=int, help="number of hats in a block")
    parser.add_argument(
        "--beat", action="store_true", help="ask for a scheme that beats 7/20"
    )
    parser.add_argument("--size", type=int, help="number of skipped stacks")
    args = parser.parse_args()
    print(write_lp(args.m, args.beat, args.size), end="")


if __name__ == "__main__":
    main()
