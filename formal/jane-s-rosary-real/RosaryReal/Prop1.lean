-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Mathlib
import Rosary.Fast

/-!
# Proposition 1, the logarithmic bound

`h(n) ≤ 4 + 3 ln n / ln (9/8)` for `n ≥ 2`.  The lower bound of
Proposition 1 is in the first project (`height_lower`), with the fact that
every bead has a height (`exists_reach`).
-/

namespace Rosary

open Real

/-- The step of the proof of Proposition 1: every bead `n ≥ 8` is reached
in at most 3 moves from a bead `m < n` with `m - 7 ≤ (8/9)(n - 7)`; and
`m` is at least `⌊2n/3⌋`. -/
theorem height_step (n : ℕ) (hn : 8 ≤ n) :
    ∃ m, 1 ≤ m ∧ m < n ∧ 9 * m ≤ 8 * n + 7 ∧ 2 * n ≤ 3 * m + 2 ∧
      height n ≤ height m + 3 := by
  by_cases hw : n % 3 = 1
  · -- a black bead: `n = mUUD`
    have key : ∀ m, 1 ≤ m → down (up (up m)) = n → height n ≤ height m + 3 := by
      intro m hm e
      have h1 := height_up_le m hm
      have h2 := height_up_le (up m) (by simp only [up, label]; omega)
      have h3 := height_down_le (up (up m)) (by simp only [up, label]; omega)
      rw [e] at h3
      omega
    by_cases h9 : n % 9 = 1
    · refine ⟨(8 * n + 1) / 9, by omega, by omega, by omega, by omega, key _ (by omega) ?_⟩
      simp only [up, down, label]; omega
    · have h47 : n % 9 = 4 ∨ n % 9 = 7 := by omega
      refine ⟨8 * n / 9, by omega, by omega, by omega, by omega, key _ (by omega) ?_⟩
      rcases h47 with h | h <;> (simp only [up, down, label]; omega)
  · -- a white bead: one up move from `nλ`
    have hl := lemma2 n (by omega) hw
    refine ⟨lam n, ?_, ?_, ?_, ?_, by omega⟩ <;> (simp only [lam]; omega)

/-- The heights of the beads 1 to 7 are at most 9. -/
theorem height_small (n : ℕ) (h1 : 1 ≤ n) (h7 : n ≤ 7) : height n ≤ 9 := by
  rw [height_eq_heightFast n h1]
  interval_cases n <;> decide

/-- The heights of the beads 8 to 11: `h(8) ≤ 4`, and the others are at
most 10.  These are the small cases of the induction below. -/
theorem height_base (n : ℕ) (h8 : 8 ≤ n) (h11 : n ≤ 11) :
    height n ≤ if n = 8 then 4 else 10 := by
  rw [height_eq_heightFast n (by omega)]
  interval_cases n <;> decide

/-- `log_{9/8} x ≥ 2` for `x ≥ 2`, because `(9/8)² = 81/64 ≤ 2`. -/
theorem two_le_logb (x : ℝ) (hx : 2 ≤ x) : 2 ≤ logb (9 / 8) x := by
  have e : logb (9 / 8) ((9 / 8 : ℝ) * (9 / 8)) = 2 := by
    rw [Real.logb_mul (by norm_num) (by norm_num),
      Real.logb_self_eq_one (by norm_num)]
    norm_num
  rw [← e]
  exact Real.logb_le_logb_of_le (by norm_num) (by norm_num) (by linarith)

/-- For `n ≥ 8`: `h(n) ≤ 4 + 3 log_{9/8} (n - 7)`, with equality at
`n = 8`. -/
theorem height_log_aux (n : ℕ) : 8 ≤ n →
    (height n : ℝ) ≤ 4 + 3 * logb (9 / 8) ((n : ℝ) - 7) := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro hn
    by_cases h11 : n ≤ 11
    · -- the small cases: beads 8 to 11
      have hb := height_base n hn h11
      by_cases h8 : n = 8
      · subst h8
        have : height 8 ≤ 4 := by simpa using hb
        have : (height 8 : ℝ) ≤ 4 := by exact_mod_cast this
        have e : logb (9 / 8) (((8 : ℕ) : ℝ) - 7) = 0 := by norm_num
        rw [e]; linarith
      · have : height n ≤ 10 := by simpa [h8] using hb
        have : (height n : ℝ) ≤ 10 := by exact_mod_cast this
        have h9 : (9 : ℝ) ≤ n := by exact_mod_cast (by omega : 9 ≤ n)
        have := two_le_logb ((n : ℝ) - 7) (by linarith)
        linarith
    · -- the step: `m ≥ 8`, and the induction applies to it
      obtain ⟨m, _, hmn, hm9, hm2, hh⟩ := height_step n hn
      have hm8 : 8 ≤ m := by omega
      have hh' : (height n : ℝ) ≤ height m + 3 := by exact_mod_cast hh
      have ihm := ih m hmn hm8
      have hm7 : (1 : ℝ) ≤ (m : ℝ) - 7 := by
        have : (8 : ℝ) ≤ m := by exact_mod_cast hm8
        linarith
      have hle : (m : ℝ) - 7 ≤ 8 / 9 * ((n : ℝ) - 7) := by
        have : (9 * m : ℝ) ≤ 8 * n + 7 := by exact_mod_cast hm9
        linarith
      have hn7 : (1 : ℝ) ≤ (n : ℝ) - 7 := by
        have : (8 : ℝ) ≤ n := by exact_mod_cast hn
        linarith
      have hlog : logb (9 / 8) ((m : ℝ) - 7) ≤ logb (9 / 8) ((n : ℝ) - 7) - 1 := by
        have e : logb (9 / 8) (8 / 9 * ((n : ℝ) - 7)) = logb (9 / 8) ((n : ℝ) - 7) - 1 := by
          rw [Real.logb_mul (by norm_num) (by linarith)]
          have : logb (9 / 8) (8 / 9 : ℝ) = -1 := by
            rw [show (8 / 9 : ℝ) = (9 / 8)⁻¹ by norm_num, Real.logb_inv,
              Real.logb_self_eq_one (by norm_num)]
          rw [this]; ring
        rw [← e]
        exact Real.logb_le_logb_of_le (by norm_num) (by linarith) hle
      linarith

/-- **Proposition 1, the logarithmic bound.**  For all `n ≥ 2`,
`h(n) ≤ 4 + 3 ln n / ln (9/8)`. -/
theorem height_log (n : ℕ) (hn : 2 ≤ n) :
    (height n : ℝ) ≤ 4 + 3 * (Real.log n / Real.log (9 / 8)) := by
  have hn0 : (0 : ℝ) < n := by exact_mod_cast (by omega : 0 < n)
  have hlogn : 0 ≤ logb (9 / 8) (n : ℝ) :=
    Real.logb_nonneg (by norm_num) (by exact_mod_cast (by omega : 1 ≤ n))
  show (height n : ℝ) ≤ 4 + 3 * logb (9 / 8) n
  by_cases h8 : 8 ≤ n
  · have h := height_log_aux n h8
    have h8' : (8 : ℝ) ≤ n := by exact_mod_cast h8
    have : logb (9 / 8) ((n : ℝ) - 7) ≤ logb (9 / 8) n :=
      Real.logb_le_logb_of_le (by norm_num) (by linarith) (by linarith)
    linarith
  · -- beads 2 to 7: their heights are at most 9, and `log_{9/8} n ≥ 2`
    have := height_small n (by omega) (by omega)
    have : (height n : ℝ) ≤ 9 := by exact_mod_cast this
    have h2 : (2 : ℝ) ≤ n := by exact_mod_cast hn
    have := two_le_logb (n : ℝ) h2
    linarith

end Rosary
