# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Strategies read from the bottom up, and their cuts to fewer hats.

usage: cuts.py [HATS_JS]

Two properties of a strategy s on n hats, and what they say of the
Carter strategies and of the best strategies on 3 and 4 hats.

- s is *bottom-up* when it never points above the hats that it had to
  read: if the k lowest hats of the stack seen are enough to know s, then
  s points below position k.
- The *cut* of s to k hats is the strategy on k hats that points where s
  points when the k hats seen are enough to know it (and the position is
  among them), and at the bottom hat otherwise.

What the program prints (2026-11-27):

- the Carter strategy on n hats is bottom-up, and its cut to k hats is
  the Carter strategy on k hats, for n up to 7;
- of the strategies equivalent to the Carter strategy on 3, 4, 5 hats
  (the positions renamed), 4 of 6, 16 of 24 and 80 of 120 are bottom-up,
  but only 2, 2 and 4 have cuts that are best strategies at every number
  of hats: one for each choice of a double shift or of the other one;
- on 4 hats, of the 10 classes of best strategies, the 6 that are built
  with resets and shifts have a member whose cuts are all best
  strategies (1, 5 and 22 hits), and the 4 others have none: their cuts
  to 3 hats have at most 20 hits.

The two choices that do not matter (for the all-white and the all-black
stack) are taken in the way that suits each property best.
"""

import itertools
import pathlib
import sys

import best_classes as bc
import check_article as ca

BEST = {1: 1, 2: 5, 3: 22, 4: 89, 5: 358}


def depth(n: int, s: ca.Strategy, t: int) -> int:
    """The number of hats to read from the bottom of t to know s(t)."""
    for m in range(n + 1):
        if all(s[u] == s[t] for u in range(2**n) if u % 2**m == t % 2**m):
            return m
    return n


def free_choices(n: int, s: ca.Strategy) -> list[ca.Strategy]:
    """s with every choice for the all-white and the all-black stack."""
    result = []
    for x, y in itertools.product(range(n), repeat=2):
        v = list(s)
        v[0], v[-1] = x, y
        result.append(v)
    return result


def bottom_up(n: int, s: ca.Strategy) -> bool:
    return any(
        all(v[t] < max(depth(n, v, t), 1) for t in range(2**n))
        for v in free_choices(n, s)
    )


def cut(n: int, s: ca.Strategy, k: int) -> ca.Strategy:
    result = []
    for t in range(2**k):
        seen = {s[u] for u in range(2**n) if u % 2**k == t}
        position = seen.pop() if len(seen) == 1 else k
        result.append(position if position < k else 0)
    return result


def cut_hits(n: int, s: ca.Strategy) -> tuple[int, ...]:
    """The hits of the cuts to 1, ..., n - 1 hats."""
    return tuple(ca.hits(k, cut(n, s, k)) for k in range(1, n))


def best_cuts(n: int, s: ca.Strategy) -> tuple[tuple[int, ...], int]:
    """Over the strategies equivalent to s: the best hits of the cuts, and
    how many strategies have them (up to the two free choices)."""
    found: dict[tuple[int, ...], set[tuple[int, ...]]] = {}
    for sigma in itertools.permutations(range(n)):
        for v in free_choices(n, ca.permuted(n, s, sigma)):
            found.setdefault(cut_hits(n, v), set()).add(tuple(v[1:-1]))
    top = max(found)
    return top, len(found[top])


def main() -> int:
    here = pathlib.Path(__file__).resolve().parent
    default = here.parent.parent / "figures" / "hats" / "hats.js"
    calculator = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else default

    for n in range(2, 8):
        carter = ca.carter(n)
        same = all(cut(n, carter, k)[1:-1] == ca.carter(k)[1:-1] for k in range(1, n))
        print(
            f"Carter on {n} hats: bottom-up {bottom_up(n, carter)}, cuts are Carter {same}"
        )
    for n in (3, 4, 5):
        carter = ca.carter(n)
        renamings = [
            ca.permuted(n, carter, sg) for sg in itertools.permutations(range(n))
        ]
        top, count = best_cuts(n, carter)
        print(
            f"Carter on {n} hats: {sum(bottom_up(n, m) for m in renamings)} of "
            f"{len(renamings)} renamings are bottom-up; best cuts {top} for {count}"
        )
    built = bc.built(4)
    for n in (3, 4):
        _, strategies = bc.best_crushed(calculator, n)
        for c in sorted({bc.canonical(n, s) for s in strategies}):
            top, count = best_cuts(n, list(c))
            hereditary = all(h == BEST[k + 1] for k, h in enumerate(top))
            print(
                f"{n} hats, class {''.join(str(p) for p in c)}: "
                f"{'built' if c in built[n] else 'not built'}, "
                f"best cuts {top} for {count} members"
                f"{', all best' if hereditary else ''}"
            )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
