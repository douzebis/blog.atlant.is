# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Recompute the numbers of the article "The game of hats".

usage: check_article.py [--seed N]

Everything is computed from the definitions below, which are those of the
article and of the Lean project (formal/hats/Hats/): nothing is read from
the article.  The program checks

- the formulas for the hits of the resets and the shifts, on all proper
  strategies on one and two hats and on random ones on three and four;
- the three facts of Section 2 (the choices for the all-white and the
  all-black stack, the permutations of the positions, the exchange of the
  colors);
- the families of Section 5 and their closed forms;
- the words, hits and win rates that the article quotes (the table
  QUOTED at the end of this file: one line per number of the article).

Conventions: a stack of n hats is a number below 2^n, the bottom hat is
the units digit, black is 1.  A strategy on n hats is the list of the
positions it points at, for the stacks 0, 1, ..., 2^n - 1; written as a
word of digits it is what the calculator reads and prints.
"""

import argparse
import itertools
import random
from fractions import Fraction

Strategy = list[int]


def hat(t: int, p: int) -> int:
    """The color of the hat at position p of stack t: 1 for black."""
    return t >> p & 1 if p >= 0 else 0


def hits(n: int, s: Strategy) -> int:
    """The pairs of stacks on which both players point at a black hat."""
    stacks = range(2**n)
    return sum(hat(t, s[u]) * hat(u, s[t]) for t in stacks for u in stacks)


def rate(n: int, s: Strategy) -> Fraction:
    return Fraction(hits(n, s), 4**n)


def word(s: Strategy) -> str:
    return "".join(str(p) for p in s)


def strategy(text: str) -> Strategy:
    return [int(c) for c in text]


# Resets: `a` is on m hats, `b` on n hats, the result on m + n hats.


def white_reset(m: int, n: int, a: Strategy, b: Strategy) -> Strategy:
    """Play a; when the m lowest hats are all white, play b above them."""
    low = 2**m
    return [m + b[t >> m] if t % low == 0 else a[t % low] for t in range(2 ** (m + n))]


def black_reset(m: int, n: int, a: Strategy, b: Strategy) -> Strategy:
    """Play a; when the m lowest hats are all black, play b above them."""
    low = 2**m
    return [
        m + b[t >> m] if t % low == low - 1 else a[t % low] for t in range(2 ** (m + n))
    ]


def double_reset(m: int, n: int, a: Strategy, b: Strategy) -> Strategy:
    """Play a; when the m lowest hats have one color, play b above them."""
    low = 2**m
    return [
        m + b[t >> m] if t % low in (0, low - 1) else a[t % low]
        for t in range(2 ** (m + n))
    ]


# Shifts: `s` is on n hats, the result on n + 1 hats (n + 2 for the double
# shifts).


def white_shift(n: int, s: Strategy) -> Strategy:
    """Play s on the n lowest hats; for the stack of n white hats under a
    black one, point at the top hat."""
    low = 2**n
    return [n if t == low else s[t % low] for t in range(2 * low)]


def black_shift(n: int, s: Strategy) -> Strategy:
    """Play s on the n lowest hats; for the stack of n black hats under a
    white one, point at the top hat."""
    low = 2**n
    return [n if t == low - 1 else s[t % low] for t in range(2 * low)]


def double_shift(n: int, s: Strategy) -> Strategy:
    """The white shift of the black shift, with one choice changed."""
    result = white_shift(n + 1, black_shift(n, s))
    result[2 ** (n + 1) + 2**n] = n + 1
    return result


def sibling_double_shift(n: int, s: Strategy) -> Strategy:
    """The black shift of the white shift, with one choice changed.  It is
    the double shift with its two new positions exchanged."""
    result = black_shift(n + 1, white_shift(n, s))
    result[2**n - 1] = n + 1
    return result


def dual(n: int, s: Strategy) -> Strategy:
    """The strategy with the two colors exchanged."""
    return [s[2**n - 1 - t] for t in range(2**n)]


def permuted(n: int, s: Strategy, sigma: tuple[int, ...]) -> Strategy:
    """The strategy s with position p renamed sigma[p]."""

    def stack(t: int) -> int:
        return sum(hat(t, p) << sigma[p] for p in range(n))

    result = [0] * 2**n
    for t in range(2**n):
        result[stack(t)] = sigma[s[t]]
    return result


# Families.

ONE: Strategy = [0, 0]  # the strategy on one hat


def low_black(n: int) -> Strategy:
    """Point where the stack one sees has its lowest black hat."""
    return [next((p for p in range(n) if hat(t, p)), 0) for t in range(2**n)]


def low_white(n: int) -> Strategy:
    """Point where the stack one sees has its lowest white hat."""
    return [next((p for p in range(n) if not hat(t, p)), 0) for t in range(2**n)]


def carter(n: int) -> Strategy:
    """The Carter strategy on n hats: the one-hat strategy double-shifted,
    and black-shifted once more when n is even."""
    s, size = ONE, 1
    while size + 2 <= n:
        s, size = double_shift(size, s), size + 2
    return s if size == n else black_shift(size, s)


def reyes(j: int) -> Strategy:
    """The Reyes strategy on 3 j hats: the Carter strategy on three hats,
    double-reset by itself."""
    c3 = carter(3)
    s = c3
    for i in range(1, j):
        s = double_reset(3, 3 * i, c3, s)
    return s


# Checks.

FAILURES: list[str] = []


def check(name: str, condition: bool) -> None:
    if not condition:
        FAILURES.append(name)


def proper_strategies(n: int, rng: random.Random, count: int) -> list[Strategy]:
    """All proper strategies on n hats if they are at most `count`, random
    ones otherwise."""
    if n ** (2**n) <= count:
        return [list(s) for s in itertools.product(range(n), repeat=2**n)]
    return [[rng.randrange(n) for _ in range(2**n)] for _ in range(count)]


def check_formulas(rng: random.Random) -> int:
    done = 0
    samples = {n: proper_strategies(n, rng, 40 if n > 2 else 300) for n in (1, 2, 3, 4)}
    for m, n in itertools.product((1, 2, 3), (1, 2, 3)):
        for a in samples[m][:12]:
            for b in samples[n][:12]:
                ha, hb = hits(m, a), hits(n, b)
                check(
                    "white reset",
                    hits(m + n, white_reset(m, n, a, b)) == 4**n * ha + hb,
                )
                check(
                    "black reset",
                    hits(m + n, black_reset(m, n, a, b)) == 4**n * ha + hb,
                )
                check(
                    "double reset",
                    hits(m + n, double_reset(m, n, a, b)) == 4**n * ha + 4 * hb - 4**n,
                )
                check(
                    "the black reset is the dual of the white reset of the duals",
                    dual(m + n, black_reset(m, n, a, b))
                    == white_reset(m, n, dual(m, a), dual(n, b)),
                )
                done += 4
    for n in (1, 2, 3, 4):
        for s in samples[n]:
            h = hits(n, s)
            both = white_shift(n + 1, black_shift(n, s))
            other = black_shift(n + 1, white_shift(n, s))
            check("white shift", hits(n + 1, white_shift(n, s)) == 4 * h + 1)
            check("black shift", hits(n + 1, black_shift(n, s)) == 4 * h + 1)
            check("two shifts", hits(n + 2, both) == 16 * h + 5)
            check("two shifts, other order", hits(n + 2, other) == 16 * h + 5)
            check("double shift", hits(n + 2, double_shift(n, s)) == 16 * h + 6)
            check(
                "sibling double shift",
                hits(n + 2, sibling_double_shift(n, s)) == 16 * h + 6,
            )
            check(
                "sibling is the dual",
                sibling_double_shift(n, s) == dual(n + 2, double_shift(n, dual(n, s))),
            )
            swap = tuple(list(range(n)) + [n + 1, n])
            check(
                "the sibling is the double shift, two positions exchanged",
                sibling_double_shift(n, s) == permuted(n + 2, double_shift(n, s), swap),
            )
            check(
                "the dual of the double shift",
                dual(n + 2, double_shift(n, s))
                == permuted(n + 2, double_shift(n, dual(n, s)), swap),
            )
            check(
                "the dual of the black shift",
                dual(n + 1, black_shift(n, s)) == white_shift(n, dual(n, s)),
            )
            check("dual", hits(n, dual(n, s)) == h)
            taller = [s[t % 2**n] for t in range(2 ** (n + 2))]
            check("taller stacks", hits(n + 2, taller) == 16 * h)
            # the choices for the all-white and the all-black stack
            changed = list(s)
            changed[0] = rng.randrange(n)
            changed[-1] = rng.randrange(n)
            check("choices that do not matter", hits(n, changed) == h)
            sigma = list(range(n))
            rng.shuffle(sigma)
            check("permutation", hits(n, permuted(n, s, tuple(sigma))) == h)
            done += 14
    # associativity of the white and of the black reset
    for a, b, c in itertools.product(samples[1], samples[2][:6], samples[2][:6]):
        for reset in (white_reset, black_reset):
            check(
                "associativity",
                reset(3, 2, reset(1, 2, a, b), c) == reset(1, 4, a, reset(2, 2, b, c)),
            )
            done += 1
    # how far the double reset is from associative
    for a, b, c in itertools.product(samples[1][:2], samples[2][:8], samples[2][:8]):
        right = double_reset(1, 4, a, double_reset(2, 2, b, c))
        left = double_reset(3, 2, double_reset(1, 2, a, b), c)
        check(
            "double reset, two nestings",
            hits(5, right) - hits(5, left) == 12 * (hits(2, c) - 4),
        )
        done += 1
    return done


def check_families() -> int:
    done = 0
    for n in range(1, 9):
        check("same hat", hits(n, [0] * 2**n) == 4 ** (n - 1))
        check("lowest black", 3 * hits(n, low_black(n)) + 1 == 4**n)
        check("lowest white", 3 * hits(n, low_white(n)) + 1 == 4**n)
        check("Carter", hits(n, carter(n)) == 7 * 4**n // 20)
        done += 4
    for k in range(4):
        gap = Fraction(7, 20) - rate(2 * k + 1, carter(2 * k + 1))
        check("Carter, odd", gap == Fraction(1, 10 * 16**k))
        gap = Fraction(7, 20) - rate(2 * k + 2, carter(2 * k + 2))
        check("Carter, even", gap == Fraction(3, 80 * 16**k))
        done += 2
    for j in (1, 2, 3):
        gap = Fraction(7, 20) - rate(3 * j, reyes(j))
        check("Reyes", gap == Fraction(1, 10 * 16**j))
        done += 1
    # the lowest black hat and the lowest white hat as chains of resets
    for n in range(2, 7):
        # (the choice for the stack that has no such hat does not matter)
        check(
            "lowest black, as resets",
            low_black(n)[1:] == white_reset(1, n - 1, ONE, low_black(n - 1))[1:],
        )
        check(
            "lowest white, as resets",
            low_white(n)[:-1] == black_reset(1, n - 1, ONE, low_white(n - 1))[:-1],
        )
        done += 2
    return done


def best(n: int) -> int:
    """The most hits of a strategy on n hats, by trying them all."""
    return max(hits(n, list(s)) for s in itertools.product(range(n), repeat=2**n))


# What the article quotes: (where, what, value computed here, value quoted).
# One line is added with each number that enters the article.


def quoted() -> list[tuple[str, str, object, object]]:
    return [
        ("caption", "stack of the first picture", 0b011, 3),
        (
            "Section 1",
            "lowest black on 3 hats, Alice 011 and Bob 110",
            (low_black(3)[0b110], low_black(3)[0b011]),
            (1, 0),
        ),
        (
            "Section 1",
            "win rate of the lowest black hat on n hats",
            [rate(n, low_black(n)) for n in range(1, 7)],
            [Fraction(1, 3) * (1 - Fraction(1, 4**n)) for n in range(1, 7)],
        ),
        (
            "Section 1",
            "strategies on 3 and 4 hats",
            (3**8, 4**16 > 4 * 10**9),
            (6561, True),
        ),
        (
            "Section 1",
            "table of the Carter strategies: winning pairs",
            [hits(n, carter(n)) for n in range(1, 9)],
            [1, 5, 22, 89, 358, 1433, 5734, 22937],
        ),
        (
            "Section 1",
            "table of the Carter strategies: out of",
            [4**n for n in range(1, 9)],
            [4, 16, 64, 256, 1024, 4096, 16384, 65536],
        ),
        (
            "Section 1",
            "table of the Carter strategies: short of 7/20 by",
            [Fraction(7, 20) - rate(n, carter(n)) for n in range(1, 9)],
            [
                Fraction(1, 10),
                Fraction(3, 80),
                Fraction(1, 160),
                Fraction(3, 1280),
                Fraction(1, 2560),
                Fraction(3, 20480),
                Fraction(1, 40960),
                Fraction(3, 327680),
            ],
        ),
        ("Section 2", "the plan of Section 1 on two hats", word(low_black(2)), "0010"),
        (
            "Section 2",
            "the hits of 0010",
            [
                (t, u)
                for t in range(4)
                for u in range(4)
                if hat(t, strategy("0010")[u]) * hat(u, strategy("0010")[t])
            ],
            [(1, 1), (1, 3), (2, 2), (3, 1), (3, 3)],
        ),
        ("Section 2", "win rate of 0010", rate(2, strategy("0010")), Fraction(5, 16)),
        ("Section 2", "hits of 0000", hits(2, strategy("0000")), 4),
        (
            "Section 2",
            "one hat: 00, and pointing above when seeing black",
            (hits(1, [0, 0]), hits(1, [0, 1])),
            (1, 0),
        ),
        (
            "Section 2",
            "one hat: pointing above when seeing white, and its dual",
            (hits(1, [1, 0]), hits(1, dual(1, [1, 0]))),
            (1, 0),
        ),
        (
            "Section 3",
            "the three resets of 0010 by 00",
            [
                word(f(2, 1, strategy("0010"), ONE))
                for f in (white_reset, black_reset, double_reset)
            ],
            ["20102010", "00120012", "20122012"],
        ),
        (
            "Section 3",
            "the reset at stacks 4 and 6",
            [white_reset(2, 1, strategy("0010"), ONE)[t] for t in (4, 6)],
            [2, 1],
        ),
        (
            "Section 3",
            "00 white-reset by 00",
            word(white_reset(1, 1, ONE, ONE)),
            "1010",
        ),
        (
            "Section 3",
            "lower strategy not proper",
            (
                hits(1, [0, 1]),
                word(white_reset(1, 1, [0, 1], ONE)),
                hits(2, white_reset(1, 1, [0, 1], ONE)),
            ),
            (0, "1111", 4),
        ),
        (
            "Section 3",
            "upper strategy not proper",
            (hits(1, [0, -1]), hits(2, black_reset(1, 1, ONE, [0, -1]))),
            (0, 5),
        ),
        (
            "Section 3",
            "fixed point of the double reset, 22 hits on 3 hats",
            (64 * Fraction(22, 64) - 1) / (64 - 4),
            Fraction(7, 20),
        ),
        (
            "Section 3",
            "fixed point of the white reset, 22 hits on 3 hats",
            Fraction(22, 64) / (1 - Fraction(1, 64)),
            Fraction(22, 63),
        ),
        (
            "Section 3",
            "0010 double-reset by itself: 84, 1348, 1360",
            (
                hits(4, double_reset(2, 2, strategy("0010"), strategy("0010"))),
                hits(
                    6,
                    double_reset(
                        4,
                        2,
                        double_reset(2, 2, strategy("0010"), strategy("0010")),
                        strategy("0010"),
                    ),
                ),
                hits(
                    6,
                    double_reset(
                        2,
                        4,
                        strategy("0010"),
                        double_reset(2, 2, strategy("0010"), strategy("0010")),
                    ),
                ),
            ),
            (84, 1348, 1360),
        ),
        (
            "Section 4",
            "the shifts of 00",
            [word(white_shift(1, ONE)), word(black_shift(1, ONE))],
            ["0010", "0100"],
        ),
        (
            "Section 4",
            "two shifts of 00, and the double shift",
            [word(white_shift(2, black_shift(1, ONE))), word(double_shift(1, ONE))],
            ["01002100", "01002120"],
        ),
        (
            "Section 4",
            "their hits",
            [
                hits(3, white_shift(2, black_shift(1, ONE))),
                hits(3, double_shift(1, ONE)),
            ],
            [21, 22],
        ),
        (
            "Section 4",
            "the two orders of two shifts of 00 are not renamings of each other",
            any(
                permuted(3, white_shift(2, black_shift(1, ONE)), sigma)[1:-1]
                == black_shift(2, white_shift(1, ONE))[1:-1]
                for sigma in itertools.permutations(range(3))
            ),
            False,
        ),
        ("Section 1", "81/224", str(Fraction(81, 224).numerator / 224)[:6], "0.3616"),
        ("Section 5", "word of C_3", word(carter(3)), "01002120"),
        ("Section 5", "hits of C_3", hits(3, carter(3)), 22),
        ("Section 7", "best on 1 hat", best(1), 1),
        ("Section 7", "best on 2 hats", best(2), 5),
        ("Section 7", "best on 3 hats", best(3), 22),
    ]


def main() -> int:
    parser = argparse.ArgumentParser(description="Recompute the numbers of the article")
    parser.add_argument("--seed", type=int, default=2020)
    args = parser.parse_args()
    rng = random.Random(args.seed)
    formulas = check_formulas(rng)
    families = check_families()
    table = quoted()
    for where, what, computed, expected in table:
        check(
            f"{where}: {what} (computed {computed}, quoted {expected})",
            computed == expected,
        )
    for name in sorted(set(FAILURES)):
        print(f"FAILED: {name}")
    print(
        f"check_article: {formulas} checks of formulas, {families} of families, "
        f"{len(table)} quoted numbers, {len(set(FAILURES))} failures"
    )
    return 1 if FAILURES else 0


if __name__ == "__main__":
    raise SystemExit(main())
