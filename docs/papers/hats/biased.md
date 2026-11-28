<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Two players, hats black with probability p: record of results

Program: `research/hats/biased.py` (its header has the formulas).

## Published

Buhler et al. (arXiv:1407.4711v8, Section 2.2): four strategies S1 to S4
built from the best strategy on three hats, all worth 7/20 at p = 1/2;
their lower bound on `V(p)` is S1 for p <= 1/2 and S3 for p >= 1/2.
arXiv:2508.01737 (2025): a strategy on blocks of five hats, with a bound
U3 said to improve the earlier ones for 0 < p < 0.312. The formula of U3
used here comes from a summary of that paper made by a program, not from
the original: to be read before any claim.

## Ours (2026-11-28)

1. **Substitution with a biased coin.** The gain of putting `s` (on `n`
   hats) in the place of the bottom hat of `m` (on `k + 1` hats) has a
   closed form in `p`, `n` and four numbers that depend on `m` only.
   Checked against direct counts on random strategies; not in Lean.

2. **The exchange of the colors.** `V(1 - p) = V(p) + 1 - 2p`: the loss
   `p - V(p)` is the same at `p` and `1 - p`. A two-line argument; S3 is
   the dual of S1. (The paper has the remark that the value fixes the
   whole table of the four outcomes.)

3. **A better bound for most p.** For p < 1/2: play `C_3` on the first
   block of three hats seen that is not all white (white resets). Value

       (3p^2 - 6p^3 + 8p^4 - 6p^5 + 2p^6) / (1 - (1 - p)^6).

   Above S1 to S4 and U3 at every p = i/20 from 1/20 to 8/20 (and by the
   exchange of the colors from 12/20 to 19/20); for instance 17742/98039
   = 0.180969 at p = 3/10 against 0.180491. Exact check without the
   limit: the first three blocks, on nine hats, have value exactly
   0.180674 at p = 3/10. At 9/20 and 11/20 a chain that mixes double
   shifts and resets is slightly above the published bound
   (0.303268 against 0.303257, in floats only). At 1/2 the resets give
   22/63, below 7/20.

4. **Best chains.** With strategies on two and three hats to substitute
   into, the best chain is exactly the bound of the paper at every p
   tried. With the resets by three-hat strategies added, it is the
   chain of item 3 for p up to 0.4.

## Not done

- Reading arXiv:2508.01737 in the original; a search of the literature
  for the white resets (they are simple; somebody may have them).
- Pieces on five hats and more in the search for chains.
- A proof in Lean of the formula of item 1.
