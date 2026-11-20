-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Mathlib
import Rosary.Reluctant

/-!
# Logarithms of beads (Section 8 of the paper): Lemma 5

The paper measures a bead `n` by `log₂ n`.  An up move adds
`α = log₂ (3/2)`, nearly; a run of down moves subtracts an integer,
nearly.
-/

namespace Rosary

open Real

/-- `α = log₂ (3/2)`. -/
noncomputable def alpha : ℝ := logb 2 (3 / 2)

/-- `log₂ (1 + x) < (3/2) x` for `x > 0`. -/
theorem logb_one_add_lt (x : ℝ) (hx : 0 < x) : logb 2 (1 + x) < 3 / 2 * x := by
  have h1 : Real.log (1 + x) ≤ x := by
    have := Real.log_le_sub_one_of_pos (show 0 < 1 + x by linarith)
    linarith
  have h2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  rw [Real.logb, div_lt_iff₀ (by linarith)]
  nlinarith

/-- **Lemma 5, part 1.**  `log₂ (nU) = log₂ n + α + ε` with
`0 ≤ ε < 1/(2n)`. -/
theorem lemma5_up (n : ℕ) (hn : 1 ≤ n) :
    logb 2 n + alpha ≤ logb 2 (up n) ∧
    logb 2 (up n) < logb 2 n + alpha + 1 / (2 * n) := by
  have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
  have h1 : 3 * n ≤ 2 * up n := by simp only [up, label]; omega
  have h2 : 2 * up n ≤ 3 * n + 1 := by simp only [up, label]; omega
  have h1' : (n : ℝ) * (3 / 2) ≤ up n := by
    have : (3 * n : ℝ) ≤ 2 * up n := by exact_mod_cast h1
    linarith
  have h2' : (up n : ℝ) ≤ n * (3 / 2) * (1 + 1 / (3 * n)) := by
    have : (2 * up n : ℝ) ≤ 3 * n + 1 := by exact_mod_cast h2
    have e : (n : ℝ) * (3 / 2) * (1 + 1 / (3 * n)) = (3 * n + 1) / 2 := by
      field_simp
    rw [e]; linarith
  have hmul : logb 2 ((n : ℝ) * (3 / 2)) = logb 2 n + alpha :=
    Real.logb_mul hn0.ne' (by norm_num)
  have hpos : (0 : ℝ) < n * (3 / 2) := by positivity
  have hx : (0 : ℝ) < 1 / (3 * n) := by positivity
  constructor
  · rw [← hmul]
    exact Real.logb_le_logb_of_le (by norm_num) hpos h1'
  · have hup : (0 : ℝ) < up n := lt_of_lt_of_le hpos h1'
    calc logb 2 (up n) ≤ logb 2 (n * (3 / 2) * (1 + 1 / (3 * n))) :=
          Real.logb_le_logb_of_le (by norm_num) hup h2'
      _ = logb 2 n + alpha + logb 2 (1 + 1 / (3 * n)) := by
          rw [Real.logb_mul hpos.ne' (by positivity), hmul]
      _ < logb 2 n + alpha + 3 / 2 * (1 / (3 * n)) := by
          linarith [logb_one_add_lt _ hx]
      _ = logb 2 n + alpha + 1 / (2 * n) := by field_simp

/-- **Lemma 4 and Lemma 5, part 2.**  If `m = nD^k`, that is
`m = ⌊n/2^k⌋ ≥ 1`, then `log₂ m = log₂ n - k - ε'` with
`0 ≤ ε' < 3/(2m)`. -/
theorem lemma5_down (n k m : ℕ) (hm : 1 ≤ m) (h : n / 2 ^ k = m) :
    logb 2 m + k ≤ logb 2 n ∧ logb 2 n < logb 2 m + k + 3 / (2 * m) := by
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  have h1 : m * 2 ^ k ≤ n := by rw [← h]; exact Nat.div_mul_le_self n (2 ^ k)
  have h2 : n < (m + 1) * 2 ^ k := by
    rw [← h, Nat.mul_comm]; exact Nat.lt_mul_div_succ n (by positivity)
  have h1' : (m : ℝ) * 2 ^ k ≤ n := by exact_mod_cast h1
  have h2' : (n : ℝ) ≤ m * (1 + 1 / m) * 2 ^ k := by
    have : (n : ℝ) ≤ (m + 1) * 2 ^ k := by exact_mod_cast h2.le
    have e : (m : ℝ) * (1 + 1 / m) = m + 1 := by field_simp
    rw [e]; exact this
  have hpow : logb 2 ((2 : ℝ) ^ k) = k := by
    rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num), mul_one]
  have hn0 : (0 : ℝ) < n := lt_of_lt_of_le (by positivity) h1'
  have hx : (0 : ℝ) < 1 / m := by positivity
  constructor
  · calc logb 2 m + k = logb 2 ((m : ℝ) * 2 ^ k) := by
          rw [Real.logb_mul hm0.ne' (by positivity), hpow]
      _ ≤ logb 2 n := Real.logb_le_logb_of_le (by norm_num) (by positivity) h1'
  · calc logb 2 n ≤ logb 2 ((m : ℝ) * (1 + 1 / m) * 2 ^ k) :=
          Real.logb_le_logb_of_le (by norm_num) hn0 h2'
      _ = logb 2 m + logb 2 (1 + 1 / m) + k := by
          rw [Real.logb_mul (by positivity) (by positivity),
            Real.logb_mul hm0.ne' (by positivity), hpow]
      _ < logb 2 m + k + 3 / (2 * m) := by
          have := logb_one_add_lt _ hx
          have e : (3 : ℝ) / 2 * (1 / m) = 3 / (2 * m) := by field_simp
          linarith

/-- `log₂ 3` is irrational, in the form used here: no positive multiple
of `α` is an integer.  (A power of 3 is not a power of 2.) -/
theorem alpha_irrational (k : ℕ) (hk : 1 ≤ k) (j : ℤ) : (k : ℝ) * alpha ≠ j := by
  intro h
  have e1 : (2 : ℝ) ^ ((k : ℝ) * alpha) = (3 / 2 : ℝ) ^ k := by
    rw [mul_comm, Real.rpow_mul (by norm_num), alpha,
      Real.rpow_logb (by norm_num) (by norm_num) (by norm_num), Real.rpow_natCast]
  have e2 : (2 : ℝ) ^ ((k : ℝ) * alpha) = (2 : ℝ) ^ j := by
    rw [h, Real.rpow_intCast]
  have e3 : (3 : ℝ) ^ k = (2 : ℝ) ^ (j + k) := by
    rw [zpow_add₀ (by norm_num), ← e2, e1, zpow_natCast, div_pow]
    field_simp
  by_cases hneg : j + k < 0
  · have : (2 : ℝ) ^ (j + k) < 1 := zpow_lt_one_of_neg₀ (by norm_num) hneg
    have : (1 : ℝ) ≤ 3 ^ k := one_le_pow₀ (by norm_num)
    linarith
  · obtain ⟨p, hp⟩ := Int.eq_ofNat_of_zero_le (by omega : 0 ≤ j + k)
    rw [hp, zpow_natCast] at e3
    have e4 : 3 ^ k = 2 ^ p := by exact_mod_cast e3
    have hp0 : p ≠ 0 := by
      intro h0
      rw [h0, pow_zero] at e4
      have : 3 ^ k ≥ 3 ^ 1 := Nat.pow_le_pow_right (by norm_num) hk
      omega
    have : 2 ∣ 3 ^ k := by rw [e4]; exact dvd_pow_self 2 hp0
    have := Nat.Prime.dvd_of_dvd_pow Nat.prime_two this
    omega

end Rosary
