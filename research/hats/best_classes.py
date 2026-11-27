# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""The best strategies on 2, 3 and 4 hats, sorted into classes.

usage: best_classes.py [HATS_JS]

Runs the search of the calculator (figures/hats/hats.js) under Node.js: it
lists every crushed strategy with the best score.  Then, with the
definitions of check_article.py:

- the classes of these strategies under the renamings of the positions
  (equivalent strategies, Section 2 of the article), the two choices that
  do not matter being set to 0;
- the classes that remain when a strategy and its dual are put together;
- the classes that hold a strategy built from the one-hat strategy with
  the resets and the shifts of the article, whatever the choices that do
  not matter in the parts.

Expected output (the search takes a second, the rest a minute):

    2 hats: best 5, 2 crushed strategies, 2 classes, 1 up to the colors, 2 built
    3 hats: best 22, 4 crushed strategies, 1 classes, 1 up to the colors, 1 built
    4 hats: best 89, 102 crushed strategies, 10 classes, 5 up to the colors, 6 built
"""

import itertools
import pathlib
import subprocess
import sys

import check_article as ca

# Asks the calculator for the program of its search (option -c), runs it,
# and prints what it displays.
HARNESS = """
const fs = require('fs');
const code = fs.readFileSync(process.argv[1], 'utf8');
const lines = [];
new Function('arguments', 'console', code)(
  ['search', '-n', process.argv[2], '-a', '-c'], {log: (t) => lines.push(String(t))});
new Function('console', lines.join('\\n'))(
  {log: (t) => process.stdout.write(String(t) + '\\n')});
"""

Class = tuple[int, ...]


def canonical(n: int, s: ca.Strategy) -> Class:
    """The same for all strategies equivalent to s, whatever s does for
    the all-white and the all-black stack."""
    forms = []
    for sigma in itertools.permutations(range(n)):
        p = ca.permuted(n, s, sigma)
        p[0] = p[-1] = 0
        forms.append(tuple(p))
    return min(forms)


def variants(n: int, s: Class) -> list[ca.Strategy]:
    """s with every choice for the all-white and the all-black stack."""
    result = []
    for x, y in itertools.product(range(n), repeat=2):
        v = list(s)
        v[0], v[-1] = x, y
        result.append(v)
    return result


def built(up_to: int) -> dict[int, set[Class]]:
    """The classes of the strategies built with resets and shifts."""
    classes: dict[int, set[Class]] = {1: {(0, 0)}}
    for n in range(2, up_to + 1):
        found: set[Class] = set()
        for m in range(1, n):
            for a, b in itertools.product(classes[m], classes[n - m]):
                for av, bv in itertools.product(variants(m, a), variants(n - m, b)):
                    for reset in (ca.white_reset, ca.black_reset, ca.double_reset):
                        found.add(canonical(n, reset(m, n - m, av, bv)))
        for a in classes[n - 1]:
            for av in variants(n - 1, a):
                found.add(canonical(n, ca.white_shift(n - 1, av)))
                found.add(canonical(n, ca.black_shift(n - 1, av)))
        if n >= 3:
            for a in classes[n - 2]:
                for av in variants(n - 2, a):
                    found.add(canonical(n, ca.double_shift(n - 2, av)))
        found |= {canonical(n, ca.dual(n, list(s))) for s in found}
        classes[n] = found
    return classes


def best_crushed(calculator: pathlib.Path, n: int) -> tuple[int, list[ca.Strategy]]:
    """The best score on n hats and the crushed strategies that have it."""
    output = subprocess.run(
        ["node", "-e", HARNESS, str(calculator), str(n)],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    words = [
        line.split('"')[1].replace("-", "")
        for line in output.splitlines()
        if line.startswith('"')
    ]
    strategies = [ca.strategy(w) for w in sorted(set(words))]
    best = max(ca.hits(n, s) for s in strategies)
    return best, [s for s in strategies if ca.hits(n, s) == best]


def main() -> int:
    here = pathlib.Path(__file__).resolve().parent
    default = here.parent.parent / "figures" / "hats" / "hats.js"
    calculator = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else default
    composed = built(4)
    for n in (2, 3, 4):
        best, strategies = best_crushed(calculator, n)
        classes = {canonical(n, s) for s in strategies}
        colors = {min(c, canonical(n, ca.dual(n, list(c)))) for c in classes}
        print(
            f"{n} hats: best {best}, {len(strategies)} crushed strategies, "
            f"{len(classes)} classes, {len(colors)} up to the colors, "
            f"{len(classes & composed[n])} built"
        )
        if n == 4:
            for c in sorted(classes - composed[n]):
                print("  not built: " + "".join(str(p) for p in c))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
