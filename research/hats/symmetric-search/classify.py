#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Which strategies found by symsearch are substitutions?

usage: classify.py N HITS LOG...

Reads the lines "found HITS WORD" of the logs.  A strategy on N hats is a
substitution on a block A of positions (2 <= |A| < N) when

- for the stacks whose hats in A are not of a single color, it points
  inside A, at a position that depends on the hats in A only;
- for the stacks whose hats in A are of a single color, it points outside
  A, or inside A at one position for each of the two colors.

After a renaming of the positions that puts A at the bottom, this is the
substitution of Theorem 6 of the article.  The program counts the
strategies that are substitutions as they stand, and those that become
one after loose choices: changes of the choice for one stack that keep the
number of hits.  A substitution reached this way is recounted in full.
"""

import collections
import itertools
import sys

Strategy = list[int]


def hits(n: int, w: Strategy) -> int:
    size = 2**n
    return sum(
        (t >> w[u] & 1) & (u >> w[t] & 1) for t in range(size) for u in range(size)
    )


def row(n: int, w: Strategy, t: int, p: int) -> int:
    """The hits that involve stack t when it points at p."""
    h = sum((t >> w[u] & 1) & (u >> p & 1) for u in range(2**n) if u != t)
    return 2 * h + (t >> p & 1)


def loose(n: int, w: Strategy) -> list[set[int]]:
    """For each stack, the positions it can point at for the same hits."""
    full = 2**n - 1
    result = []
    for t in range(full + 1):
        if t in (0, full):
            result.append(set(range(n)))
            continue
        base = row(n, w, t, w[t])
        result.append({p for p in range(n) if row(n, w, t, p) == base})
    return result


def block(
    n: int, w: Strategy, allowed: list[set[int]], target: int
) -> tuple[int, ...] | None:
    """A block on which w, after choices among `allowed`, is a substitution
    with `target` hits."""
    full = 2**n - 1
    for size in range(2, n):
        for positions in itertools.combinations(range(n), size):
            inside = set(positions)
            mask = sum(1 << p for p in positions)
            groups: dict[tuple[bool, int], list[int]] = {}
            possible = True
            for t in range(1, full):
                a = t & mask
                single = a in (0, mask)
                if single and allowed[t] - inside:
                    continue
                if not allowed[t] & inside:
                    possible = False
                    break
                groups.setdefault((single, a), []).append(t)
            if not possible:
                continue
            v = list(w)
            for stacks in groups.values():
                common = set(inside)
                for t in stacks:
                    common &= allowed[t]
                if not common:
                    possible = False
                    break
                for t in stacks:
                    v[t] = min(common)
            if not possible:
                continue
            for t in range(1, full):
                outside = allowed[t] - inside
                if t & mask in (0, mask) and outside and v[t] in inside:
                    v[t] = min(outside)
            if hits(n, v) == target:
                return positions
    return None


def main() -> int:
    n, target = int(sys.argv[1]), int(sys.argv[2])
    words = set()
    for path in sys.argv[3:]:
        with open(path, encoding="utf-8") as lines:
            for line in lines:
                fields = line.split()
                if (
                    len(fields) == 3
                    and fields[0] == "found"
                    and int(fields[1]) == target
                ):
                    words.add(fields[2])
    as_is: collections.Counter[int] = collections.Counter()
    after: collections.Counter[int] = collections.Counter()
    for text in sorted(words):
        w = [int(c) for c in text]
        exact = [{p} for p in w]
        exact[0] = exact[-1] = set(range(n))
        found = block(n, w, exact, target)
        if found:
            as_is[len(found)] += 1
            continue
        found = block(n, w, loose(n, w), target)
        after[len(found) if found else 0] += 1
    print(f"{len(words)} strategies with {target} hits on {n} hats")
    print(
        "substitutions as they stand, by size of the first block found:",
        dict(sorted(as_is.items())),
    )
    print(
        "substitutions after loose choices, by size of the first block found (0: none):",
        dict(sorted(after.items())),
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
