<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Reproduction of an external Lean proof: the irrationality exponent of log 3 / log 2 is at most 3

Record of what was done on 2026-11-19 and 2026-11-20, so that it can be
redone. Nothing of that proof is copied in this repository.

## The source

- Repository: <https://github.com/rohitkrjha/log23-measure>, by Rohit
  Kumar Jha; commit `8a43e6032ae33045cd76c76b34b7383391187ed0`
  (2026-10-09). Lean project in `sources/lean/`: 916 local modules, about
  104 000 lines, of which 81 modules by the author
  (`LogarithmExtension/`) and 835 copied from `github.com/openai/math`
  (`vendor/openai-math/`). License Apache-2.0.
- Lean 4.34.1; Mathlib revision
  `d13f23b723b8a846827a245b89c10fc7d3f11612`.

## The statement

`LogarithmExtension/LogRatioMain.lean`:

```lean
theorem logRatio_approximation_bound (epsilon : ℝ) (hepsilon : 0 < epsilon) :
    ∃ Q : ℕ, 2 ≤ Q ∧ ∀ p : ℤ, ∀ q : ℕ, Q ≤ q →
      (q : ℝ)^(-(3+epsilon)) ≤ |Real.log 3/Real.log 2-(p : ℝ)/(q : ℝ)|
```

It uses Mathlib notions only.

## What was done

1. The sources were read for `sorry`, `axiom`, `native_decide`, `unsafe`,
   `implemented_by`, `extern`, `#eval`, `run_cmd`, `IO`, `initialize`,
   `elab`, `macro`, `opaque`: no declaration of that kind in the 916
   modules. One standalone script (`VerifyLogRatioComponents.lean`) does
   input and output; it is not part of the build and was not run.
2. Build as shipped, from `sources/lean`:
   `lake exe cache get`, then
   `lake build LogarithmExtension.LogRatioMain LogarithmExtension.LogRatioAverageAudit`.
   It fails at once: `object file ... LogRatioAdmissibleData.olean ... does
   not exist`. The `roots` of the two libraries in `lakefile.toml` name
   single modules.
3. With `roots = ["LogarithmExtension"]` and `roots = ["OAI"]` in
   `lakefile.toml`, and nothing else changed, the same build ends with
   `Build completed successfully (9839 jobs)`. Mathlib came from its
   prebuilt files.
4. `#print axioms` on `logRatio_approximation_bound`,
   `logRatio_eventual_lower_bound`,
   `logRatio_irrationalityExponent_bounds` and `ratioTheta_irrational`:
   `[propext, Classical.choice, Quot.sound]` for each. A restatement of
   the first with `_root_`-qualified names is proved by it.
5. `leanchecker` (the kernel replay tool shipped with Lean 4.34.1) was run
   on each of the 916 local modules, one module per call
   (`lake env leanchecker <module>`): 916 exits with status 0, no failure.
   Mathlib was not replayed.

Platform: Linux x86_64 (NixOS), Lean installed by elan.

## What was not done

- The mathematics was not read: neither the 12-page manuscript beyond its
  introduction, nor the proofs.
- The author's own replay script was not run.
- No kernel other than Lean's own was used.
