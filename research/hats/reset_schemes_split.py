# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Generalized resets on blocks of m hats, one set of skipped stacks at a time.

usage: reset_schemes_split.py M Z OUT [--jobs N] [--limit SECONDS] [--optimize]

Question 4 of docs/papers/hats/open-questions.md, for the sizes of Z that
one run of the solver does not settle.  Permuting the positions of the
hats turns a scheme into a scheme with the same win rate, so one set Z in
each class is enough.  For each, this program writes the model of
reset_schemes_lp.py (--skip, --beat) and has SCIP solve it.

OUT gets one line per set as soon as it is settled: the stacks of Z, the
answer (none: no scheme with this Z beats 7/20; open: the solver ran out
of time; a number: the hits A + c of a scheme that beats 7/20), and the
seconds.  A run that is started again skips the sets that OUT already
settles, so it can be interrupted at any time.

With --optimize the solver looks for the best scheme of each Z instead,
and the answer is its A + c.  This is the check against the enumerations
on blocks of 3 and 4 hats.

The solver `scip` must be on the PATH.
"""

import argparse
import itertools
import re
import subprocess
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from reset_schemes_lp import write_lp_fixed


def stack_maps(m: int) -> list[list[int]]:
    """For each permutation of the positions, where it sends each stack."""
    maps = []
    for perm in itertools.permutations(range(m)):
        maps.append(
            [sum((t >> p & 1) << perm[p] for p in range(m)) for t in range(2**m)]
        )
    return maps


def representatives(m: int, size: int) -> list[tuple[int, ...]]:
    """One set of `size` stacks in each class under the permutations."""
    maps = stack_maps(m)
    seen: set[int] = set()
    found = []
    for skip in itertools.combinations(range(2**m), size):
        if sum(1 << t for t in skip) in seen:
            continue
        found.append(skip)
        for image in maps:
            seen.add(sum(1 << image[t] for t in skip))
    return found


def solve(
    m: int, skip: tuple[int, ...], optimize: bool, limit: int, work: Path
) -> tuple[str, float]:
    """The answer of the solver for one set, and the seconds it took."""
    name = "z" + "_".join(str(t) for t in skip)
    model = work / f"{name}.lp"
    model.write_text(write_lp_fixed(m, list(skip), beat=not optimize))
    start = time.monotonic()
    done = subprocess.run(
        [
            "scip",
            "-c",
            f"read {model}",
            "-c",
            f"set limits time {limit}",
            "-c",
            "set limits memory 2000",
            "-c",
            "optimize",
            "-c",
            "quit",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    seconds = time.monotonic() - start
    model.unlink()
    status = re.search(r"SCIP Status +: (.*)", done.stdout)
    primal = re.search(r"Primal Bound +: ([-+.e0-9]+)", done.stdout)
    if status is None or primal is None:
        return "error", seconds
    if "infeasible" in status.group(1):
        return "none", seconds
    if "optimal solution found" in status.group(1):
        return str(round(float(primal.group(1)))), seconds
    return "open", seconds


def main() -> None:
    parser = argparse.ArgumentParser(
        description=__doc__.split("\n")[0] if __doc__ else None
    )
    parser.add_argument("m", type=int, help="number of hats in a block")
    parser.add_argument("size", type=int, help="number of skipped stacks")
    parser.add_argument("out", type=Path, help="file of the answers, added to")
    parser.add_argument("--jobs", type=int, default=2, help="solvers at a time")
    parser.add_argument("--limit", type=int, default=3600, help="seconds per set")
    parser.add_argument(
        "--optimize", action="store_true", help="find the best scheme of each set"
    )
    args = parser.parse_args()

    settled: set[str] = set()
    if args.out.exists():
        for line in args.out.read_text().splitlines():
            key, answer = line.split("\t")[:2]
            if answer not in ("open", "error"):
                settled.add(key)
    todo = [
        skip
        for skip in representatives(args.m, args.size)
        if ",".join(str(t) for t in skip) not in settled
    ]
    print(f"{len(settled)} sets settled, {len(todo)} to do", flush=True)

    with tempfile.TemporaryDirectory() as tmp, args.out.open("a") as out:

        def one(skip: tuple[int, ...]) -> None:
            answer, seconds = solve(args.m, skip, args.optimize, args.limit, Path(tmp))
            key = ",".join(str(t) for t in skip)
            out.write(f"{key}\t{answer}\t{seconds:.1f}\n")
            out.flush()

        with ThreadPoolExecutor(args.jobs) as pool:
            list(pool.map(one, todo))


if __name__ == "__main__":
    main()
