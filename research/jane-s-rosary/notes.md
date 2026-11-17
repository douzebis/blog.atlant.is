<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Jane's infinite rosary: findings, future work, publication

Status as of 2026-11-14. Companion to `jane-s-infinite-rosary.md` (the revised
paper, same directory).

## 1. Sources

- Live post (January 2023, the most recent text): <https://blog.douzeb.is/?p=6271>
- Markdown export (December 2022, older than the live post):
  <https://github.com/douzebis/blog.atlant.is-import/tree/1af18d0973c2f327afeab302f101d13be815162f/2022-12-02-jane-s-infinite-rosary>
- Interactive figures (vis-network): <https://github.com/douzebis/jane-s-rosary>
- OEIS: A358838 (height), A359005 (reluctant walk), A359008 (its inverse),
  A061419 (the up-chain of 0, shifted by one).

## 2. Findings

Notation: beads are the naturals, up is `n -> floor(3n/2) + 1`, down is
`n -> ceil(n/2) - 1`, `rho` is the reluctant recitation (down unless the bead
below is already told).

### 2.1 Proved (new)

All of these are new proofs written in this session. They were checked
numerically where possible but have not been refereed.

1. **`rho` is a permutation of N** (former Conjecture 3; the conjecture stated
   in A359005 and A359008). Ingredients:
   - the set of told beads is closed under "down", except for the bead Jane
     is on;
   - with `x = n + 1`, down is `x -> floor(x/2)` (binary heap parent) and up is
     `x -> ceil(3x/2)`; so down moves preserve the phase `log2(x) mod 1` and
     each up move rotates it by the irrational angle `log2(3/2)`;
   - the perturbations are `O(1/x)` and Jane eventually stays above any
     bound, so the phases are dense and she must enter the "cone" of any
     untold bead, which forces her to tell it.
2. **Up moves have asymptotic frequency exactly `log_3 2 = 0.63093...`**, with
   `|u(t) log2(3) - t - log2(rho(t)+1)| <= 1.5 (1 + ln t)`.
3. **`log2 rho(t) <= 2 sqrt(t) + O(log t)`** (uses a finite irrationality
   exponent for `log2 3`; `o(t)` needs irrationality only).
4. **Bead `m` is told within `O(m^(2 mu - 1))` moves**, `mu` an irrationality
   exponent of `log2 3` (Rhin: `mu <= 8.616`, to be confirmed at the source).
   Hence the smallest untold bead `F(t)` grows at least like a power of `t`.
5. **Explicit rule in Theorem 1**: for a black bead `3n`, write
   `2n + 1 = 3^e q`; then `mu` wins iff `2^(e+1) q = 1 (mod 3)`, and the
   smaller lambex is `e + 1`.
6. **Shorter proof of Theorem 2** (never halts) from one commutation lemma,
   which also proves the white-bead lemma.
7. **Onyx ordering**: `pi(n) <= 8n/9`, so it is a well-founded tree; with
   Theorem 4 it is isomorphic to the full infinitely branching tree.
8. `liminf h(n)/ln n = 1/ln(3/2)`; `h(n) <= 12 + 3 ln n / ln(9/8)`.
9. The foraging sequence takes every value infinitely often (now
   unconditional).

### 2.2 Errors found in the January 2023 text

- Fast `height` algorithm: returns 6 for `n = 3`, loops forever on `n = 6`.
- Lemma 3: parity condition reversed. Lemma 5: "at most 2 elements" is false
  (9 elements for the chains of 21 and 255); only finiteness is true and
  needed.
- Canonical onyx mapping: "prefix" should be "suffix" with the printed
  definition and table.
- `h(n) <= 6 log n / log(9/8)` fails at `n = 1`.
- Theorem 1: base case and the "easy" claims were not proved; Figure 7
  caption says "lower lambex" (the theorem says larger; not checked against
  the rendered figure).
- Onyx ordering properties and Lemma 1 were stated without proof.

### 2.3 Observed (2^27 moves, single core, 21 s)

| quantity | observation |
|---|---|
| smallest untold bead `F(t)` | `F(t) log2(t) / t` between 1.9 and 3.1; 10 801 813 at `t = 2^27` |
| up-move frequency | 0.630930 (theory: 0.6309297) |
| `u(t) - t log_3 2` | grows like `log t` (15.9 at `2^27`) |
| `log2 max rho` | about `1.4 log2 t`, never above `1.5 log2 t` at powers of 2 |
| run lengths `p_0, p_1, ...` | 0.1012, 0.4999, 0.1552, 0.1429, 0.0565, 0.0296, ... |
| `h(n)/ln n`, random 1024-bit `n` | mean 4.849, sd of `h` about `2.4 sqrt(ln n)` |

## 3. Conjectures and open questions

- **A.** `F(t) = Theta(t / log t)`.
- **B.** `rho(t) <= t^C` (C = 3/2 fits). Would give `u(t) = t log_3 2 + O(log t)`.
- **C.** The run-length frequencies `p_r` converge. Is `p_1 = 1/2` exactly?
- **D.** `h(n)/ln n -> 11 / ln(3^9 / 2^11) = 4.861` for almost all `n`, with a
  central limit theorem.
- **E.** What is `limsup h(n)/ln n`? (Between about 7.7 observed and 25.5 proved.)
- **F.** The `k`-th cover of an onyx bead grows like `(9/4)^k` (equivalent to
  parity equidistribution along up-chains; Mahler 3/2 flavor, probably hard).
- **G.** Which other walk rules give permutations? The surjectivity proof only
  needs: injective, infinitely many up moves, told set closed under down.

## 4. Future work

### 4.1 Before any submission

- Have the proofs of Theorems 3, 5 and 6 read by someone else; the delicate
  points are the error bookkeeping in the phase lemma and the block count in
  Theorem 6.
- Check the bibliography against the originals: Rhin 1987 (exponent 7.616 /
  8.616), Odlyzko-Wilf 1991, Mahler 1968, Sos 1958; confirm A061419.
- Decide whether to restore the xy-pic / CD diagrams (replaced by tables).
- Convert to the target format (WordPress + MathJax for the blog, LaTeX for a
  journal); re-embed the interactive figures; check the Figure 7 caption.
- Run `reuse annotate` once the files live in a repository.

### 4.2 Mathematics

- Try to prove `p_1 = 1/2` (a short proof would be worth more than digits).
- Sharpen Theorem 6: the exponent `2 mu - 1` comes from a crude block count;
  a direct argument on the tree may give something near `m log m`.
- Prove Conjecture B, which would upgrade Theorem 5 to `O(log t)`.
- Make Conjecture D rigorous for a density-1 set (3-adic equidistribution of
  the canonical backward path looks tractable).
- Explore Question G on a few variants; the proof template is short.

### 4.3 Experiments

Hardware available: dual Xeon E5-2699A v4 (44 cores), 512 GB RAM.

- The walk is sequential: one core, memory-bound. Reach about `2^35`-`2^36`
  moves with a bitmap below a few times the frontier plus a compact hash
  above; huge pages, `numactl --interleave=all`, prefetch of both candidate
  next beads; `u64` with an overflow check.
- Measure first, at `2^30`: the level profile (told beads per depth of the
  binary tree) and `p_1(t)` over time. Then size the big run.
- Big run targets: `p_r` to about `3e-6`; `F(t)` at every `2^(k/8)`;
  `max rho`; level profiles at checkpoints.
- Parallel, cheap: height histograms at many bit lengths; residue search mod
  `3^k` for extreme heights; parity statistics on long up-chains; onyx cover
  counts; variants of the walk.

Scratch code from this session is kept in `numerics/` (unpolished, no license
headers yet): `walk.c` (the walk in heap coordinates, `./walk 27` for `2^27`
moves; output in `walk27.log`), `checks.py` (Theorem 1, onyx tree, lemmas,
heights), `bounds.py` (height bounds), `final.py` (runs the paper's code
listings and checks Theorem 5).

## 5. Publication opportunities

- **arXiv first** (math.NT or math.CO), then add a comment and link to
  A359005 and A359008: the entries still list the permutation property as a
  conjecture, and a web search found no proof.
- **Journal of Integer Sequences**: best fit for "proof of an OEIS conjecture";
  free, no fees.
- **INTEGERS**: free, refereed, short self-contained papers in combinatorial
  number theory; equally plausible.
- **Experimental Mathematics**: only if the paper is rebuilt around the
  conjectures with the large-scale experiments of Section 4.3.

Suggested split:

1. *Short paper*: reluctant recitation only. Never halts, is a permutation,
   up-frequency `log_3 2`, polynomial bound, conjectures A-C. About 8 pages.
2. *Blog or second note*: heights (Theorem 1, the fast algorithm, Conjecture
   D, Question E) and the onyx tree (Theorem 4, Conjecture F).
