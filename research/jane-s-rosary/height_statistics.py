# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Numbers quoted with Conjecture D and Question E (typical and extreme
heights).

usage: python height_statistics.py     (about 1 minute)

Prints, for comparison with the paper:
- the constant 11 / ln(3^9 / 2^11) of Conjecture D;
- mean and standard deviation of h(n) / ln n for random n of 64, 256 and
  1024 bits (3000 samples each, fixed seed);
- the largest value of h(n) / ln n for 10^3 <= n < 10^6 (Question E).

Nothing is asserted: these are observations, not checks.
"""

import math
import random
import statistics

from rosary import height


def main() -> None:
    print(f"Conjecture D constant: {11 / math.log(3**9 / 2**11):.4f}")
    generator = random.Random(1)
    for bits in (64, 256, 1024):
        samples = [
            height(generator.getrandbits(bits) | (1 << (bits - 1))) for _ in range(3000)
        ]
        scale = bits * math.log(2)
        ratios = [h / scale for h in samples]
        print(
            f"random {bits}-bit n: mean h/ln n = {statistics.mean(ratios):.4f}, "
            f"sd of h = {statistics.pstdev(samples):.2f}, "
            f"sd / sqrt(ln n) = {statistics.pstdev(samples) / math.sqrt(scale):.3f}"
        )
    largest = max((height(n) / math.log(n), n) for n in range(10**3, 10**6))
    print(
        f"largest h(n)/ln n for 10^3 <= n < 10^6: {largest[0]:.3f} at n = {largest[1]}"
    )


if __name__ == "__main__":
    main()
