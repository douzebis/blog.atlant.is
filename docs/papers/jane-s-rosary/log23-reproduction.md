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

## On a GitHub machine, with signed logs (2026-11-20)

The workflow `formal-log23` of this repository, run on demand, does the
same from a clean machine: it fetches the fork
`github.com/douzebis/log23-measure` at commit
`2da397ecf69ef2990b4a84805387827cc13c6181` (the upstream commit plus the
two-line change of step 3), builds, applies `formal/check.sh`, then runs
`leanchecker` on every compiled module.

- Run: <https://github.com/douzebis/blog.atlant.is/actions/runs/44687110127>,
  at commit `8cdb9ec` of this repository, 06:20 to 07:53 UTC.
- Result: `Build completed successfully (9864 jobs)`, `check: ok`;
  `recheck: 939 of 939 modules replayed by the kernel, 0 failed`.
- The 939 modules are 914 of the 916 modules of the external
  formalization and 25 of ours. The two not included are
  `LogarithmExtension.LogRatioAverageAudit` and
  `LogarithmExtension.LogRatioScalingAudit`, which our project does not
  import and so does not build; they were built and replayed on our own
  host (step 5).
- GitHub's attestations for the two logs were verified with
  `gh attestation verify <file> --repo douzebis/blog.atlant.is`:

  | File | SHA-256 |
  |---|---|
  | `rosary-log23-check.log` | `f77250e1715a5826f42b64b9b2e5d7d09a549e000c4e2006ef5bd7173f7474db` |
  | `rosary-log23-recheck.log` | `a07dfe8d53371561030838bfe52f714b0f03a9d3db39035e1ccc6ad69e215972` |

  An attestation states that the file was produced by that workflow run
  at that commit. It says nothing about the content, which is to be read
  in the log.
