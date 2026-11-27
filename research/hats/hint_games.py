# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Upper bounds on the value of the game of hats, by hints to both players.

usage: hint_games.py A B [--lp] [--brute]

A and B name two matrices of 0s and 1s (below).  The referee draws the
stack of Alice among the columns of A and that of Bob among the columns of
B, as in the "matrix game" of Buhler et al. (arXiv 1407.4711, Section 3),
but with a hint for each player.  A strategy of Alice is a row of A for
each column of B (the stack she sees), a strategy of Bob a row of B for
each column of A.  The pair (j, k) of columns is a hit when
A[a(k)][j] = 1 and B[b(j)][k] = 1.  The value is the best number of hits
divided by the number of pairs of columns.

When every column of A and of B has as many 1s as 0s, each stack is a
sequence of fair coin tosses, the players are free to ignore the hints,
and so the value is an upper bound on V, the value of the game of hats.
With B = L<k> (all the columns of k bits) Bob has no hint but only k hats
to choose from: the value is then a lower bound on the value V(A) of the
matrix game of the paper.

Matrices:
  I2      the identity of size 2 (the hint of the 3/8 bound)
  U<m>    the columns of m bits with m/2 ones (m even)
  L<k>    all the columns of k bits
  H12     the Hadamard matrix of order 12 without its constant column,
          and the complements of its columns: 12 x 22
  A<d>    the non-constant affine functions on d bits, one per column,
          a row for each of the 2^d points (A3 is the 8 x 14 matrix of
          the bound 81/224)

--lp writes an integer program in CPLEX LP format (maximize the hits).
--brute finds the value by trying every strategy of Bob (small cases).
"""

import argparse
import itertools

Matrix = list[list[int]]  # rows


def matrix(name: str) -> Matrix:
    if name == "I2":
        return [[1, 0], [0, 1]]
    if name == "H12":
        return hadamard12()
    kind, size = name[0], int(name[1:])
    if kind == "U":
        columns = [
            c for c in itertools.product((0, 1), repeat=size) if 2 * sum(c) == size
        ]
    elif kind == "L":
        columns = list(itertools.product((0, 1), repeat=size))
    elif kind == "A":
        points = list(itertools.product((0, 1), repeat=size))
        columns = []
        for coefficients in itertools.product((0, 1), repeat=size):
            if any(coefficients):
                for constant in (0, 1):
                    columns.append(
                        tuple(
                            (constant + sum(c * x for c, x in zip(coefficients, p))) % 2
                            for p in points
                        )
                    )
    else:
        raise ValueError(name)
    return [list(row) for row in zip(*columns)]


def hadamard12() -> Matrix:
    """The Hadamard matrix of order 12 (Paley, with the squares modulo 11),
    without its constant column: 11 columns, and their complements."""
    squares = {x * x % 11 for x in range(1, 11)}
    rows = [[1] * 11]
    for i in range(11):
        rows.append([0 if (j - i) % 11 in squares | {0} else 1 for j in range(11)])
    # every column has six 1s and six 0s, and two rows agree in 5 places
    assert all(sum(row[j] for row in rows) == 6 for j in range(11))
    assert all(
        sum(x == y for x, y in zip(r, s)) == 5
        for r, s in itertools.combinations(rows, 2)
    )
    return [row + [1 - x for x in row] for row in rows]


def brute(a: Matrix, b: Matrix) -> int:
    """The best number of hits, by trying every strategy of Bob."""
    na, nb = len(a[0]), len(b[0])
    best = 0
    for bob in itertools.product(range(len(b)), repeat=na):
        total = 0
        for k in range(nb):
            good = [j for j in range(na) if b[bob[j]][k]]
            total += max(sum(row[j] for j in good) for row in a)
        best = max(best, total)
    return best


def write_lp(a: Matrix, b: Matrix) -> str:
    na, nb = len(a[0]), len(b[0])
    rows: list[str] = []
    hits: list[str] = []
    for k in range(nb):
        rows.append(" + ".join(f"a_{k}_{x}" for x in range(len(a))) + " = 1")
    for j in range(na):
        rows.append(" + ".join(f"b_{j}_{y}" for y in range(len(b))) + " = 1")
    for j in range(na):
        for k in range(nb):
            h = f"h_{j}_{k}"
            hits.append(h)
            rows.append(
                h + "".join(f" - a_{k}_{x}" for x in range(len(a)) if a[x][j]) + " <= 0"
            )
            rows.append(
                h + "".join(f" - b_{j}_{y}" for y in range(len(b)) if b[y][k]) + " <= 0"
            )
    lines = ["Maximize", " obj: " + " + ".join(hits), "Subject To"]
    lines += [f" c{i}: {row}" for i, row in enumerate(rows)]
    lines.append("Bounds")
    lines += [f" 0 <= {h} <= 1" for h in hits]
    lines.append("Binary")
    lines += [f" a_{k}_{x}" for k in range(nb) for x in range(len(a))]
    lines += [f" b_{j}_{y}" for j in range(na) for y in range(len(b))]
    lines.append("End")
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description="Hints to both players")
    parser.add_argument("a", help="the matrix of Alice's stacks")
    parser.add_argument("b", help="the matrix of Bob's stacks")
    parser.add_argument("--lp", action="store_true", help="write an integer program")
    parser.add_argument(
        "--brute", action="store_true", help="try every strategy of Bob"
    )
    args = parser.parse_args()
    a, b = matrix(args.a), matrix(args.b)
    pairs = len(a[0]) * len(b[0])
    if args.lp:
        print(write_lp(a, b), end="")
    elif args.brute:
        best = brute(a, b)
        print(f"{args.a} {args.b}: {best} hits out of {pairs}, {best / pairs:.6f}")
    else:
        print(
            f"{args.a}: {len(a)} x {len(a[0])}; {args.b}: {len(b)} x {len(b[0])}; {pairs} pairs"
        )


if __name__ == "__main__":
    main()
