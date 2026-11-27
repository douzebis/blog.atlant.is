# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Check the Rust scorer of this directory against score.py.

usage: check_players.py [BINARY]

Random symmetric tables on 2, 3 and 4 hats, and the table of Winkler's
sum: the binary (target/release/players by default) must count the wins
that score.py counts, and print the same Winkler tables.
"""

import pathlib
import random
import subprocess
import sys

import score


def run(binary: pathlib.Path, arguments: list[str], text: str = "") -> str:
    return subprocess.run(
        [str(binary), *arguments],
        input=text,
        check=True,
        capture_output=True,
        text=True,
    ).stdout


def main() -> int:
    here = pathlib.Path(__file__).resolve().parent
    binary = (
        pathlib.Path(sys.argv[1])
        if len(sys.argv) > 1
        else here / "target/release/players"
    )
    rng = random.Random(2026)
    failures = 0
    checked = 0
    for t in (2, 3, 4):
        size = 2**t
        if run(binary, ["winkler", str(t)]) != score.write_table(score.winkler(t)):
            print(f"FAILED: the table of Winkler's sum on {t} hats")
            failures += 1
        for _ in range(20):
            table = [[0] * size for _ in range(size)]
            for u in range(size):
                for v in range(u, size):
                    table[u][v] = table[v][u] = rng.randrange(t)
            wanted = score.wins_symmetric(t, table)
            got = int(run(binary, ["score", str(t)], score.write_table(table)))
            checked += 1
            if got != wanted:
                print(f"FAILED: {t} hats: {got} wins, {wanted} expected")
                failures += 1
    print(f"check_players: {checked} tables, {failures} failures")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
