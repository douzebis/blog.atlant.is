# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""The programs printed in the paper do what the paper says.

usage: python check_paper_code.py [PAPER.md]     (about 5 s)

The four Python listings of the paper (height by exploration, height in
logarithmic time, rho, Phi) are extracted from its source and run; their
results are compared with those of rosary.py.  Every line printed must end
with "ok".
"""

import pathlib
import re
import sys

from rosary import height, reluctant_recitation, seed_and_lambex

PAPER = (
    pathlib.Path(__file__).resolve().parents[2]
    / "content"
    / "posts"
    / "2022-12-02-jane-s-infinite-rosary"
    / "index.md"
)


def report(name: str, passed: bool) -> bool:
    print(f"{name}: {'ok' if passed else 'FAILED'}")
    return passed


def main() -> int:
    paper = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else PAPER
    listings = re.findall(r"```python\n(.*?)```", paper.read_text(), re.S)
    if len(listings) != 4:
        print(f"expected 4 Python listings in {paper}, found {len(listings)}")
        return 1
    spaces: list[dict[str, object]] = [{} for _ in listings]
    for listing, space in zip(listings, spaces):
        exec(listing, space)  # the listings are the paper's own text
    explore, fast, rho, phi = (
        spaces[0]["height"],
        spaces[1]["height"],
        spaces[2]["rho"],
        spaces[3]["Phi"],
    )
    assert callable(explore) and callable(fast) and callable(rho) and callable(phi)

    beads = reluctant_recitation(400)
    foraging = [0]
    for bead in beads:
        onyx = seed_and_lambex(bead)[0] // 3
        if onyx != foraging[-1]:
            foraging.append(onyx)
    results = [
        report(
            "height by exploration, n < 3000",
            all(explore(n) == height(n) for n in range(3000)),
        ),
        report(
            "height in logarithmic time, n < 100000",
            all(fast(n) == height(n) for n in range(100000)),
        ),
        report("rho(i), i < 300", all(rho(i) == beads[i] for i in range(300))),
        report("Phi(i), i < 60", all(phi(i) == foraging[i] for i in range(60))),
    ]
    return 0 if all(results) else 1


if __name__ == "__main__":
    sys.exit(main())
