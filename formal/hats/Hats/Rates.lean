-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Describe
import Mathlib.Analysis.SpecificLimits.Basic

/-!
# Win rates

The win rate of a strategy on `n` hats is the number of its hits divided
by the number of pairs of stacks, `4 ^ n`.  Here the results on hits are
stated as the article states them, on win rates, and the limits of the
win rates of the families are computed.
-/

namespace Hats

open Filter Topology

/-- The win rate of strategy `s` on `n` hats. -/
noncomputable def rate (n : ℕ) (s : ℕ → ℤ) : ℝ := (hits n s : ℝ) / 4 ^ n

/-! ### The six formulas -/

/-- **Win rate after a left reset.** -/
theorem rate_lr {m : ℕ} (n : ℕ) {a : ℕ → ℤ} (b : ℕ → ℤ) (ha : Proper m a) :
    rate (m + n) (lr m a b) = rate m a + rate n b / 4 ^ m := by
  unfold rate
  rw [hits_lr n b ha, pow_add]
  push_cast
  field_simp

/-- **Win rate after a right reset.** -/
theorem rate_rr {m n : ℕ} {a b : ℕ → ℤ} (ha : Proper m a) (hb : Proper n b) :
    rate (m + n) (rr m a b) = rate m a + rate n b / 4 ^ m := by
  unfold rate
  rw [hits_rr ha hb, pow_add]
  push_cast
  field_simp

/-- **Win rate after a double reset.** -/
theorem rate_dr {m n : ℕ} {a b : ℕ → ℤ} (ha : Proper m a) (hb : Proper n b) :
    rate (m + n) (dr m a b) = rate m a + (4 * rate n b - 1) / 4 ^ m := by
  have h := hits_dr ha hb
  have h' : (hits (m + n) (dr m a b) : ℝ) = 4 ^ n * hits m a + 4 * hits n b - 4 ^ n := by
    have := congrArg (Nat.cast : ℕ → ℝ) h
    push_cast at this
    linarith
  unfold rate
  rw [h', pow_add]
  field_simp
  ring

/-- **Win rate after a left shift.** -/
theorem rate_ls {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    rate (n + 1) (ls n s) = rate n s + 1 / 4 ^ (n + 1) := by
  unfold rate
  rw [hits_ls hs, pow_succ]
  push_cast
  field_simp

/-- **Win rate after a right shift.** -/
theorem rate_rs {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    rate (n + 1) (rs n s) = rate n s + 1 / 4 ^ (n + 1) := by
  unfold rate
  rw [hits_rs hs, pow_succ]
  push_cast
  field_simp

/-- **Win rate after a double shift.** -/
theorem rate_ds {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    rate (n + 2) (ds n s) = rate n s + 1 / 4 ^ (n + 1) + 2 / 4 ^ (n + 2) := by
  unfold rate
  rw [hits_ds hs, pow_succ, pow_succ]
  push_cast
  field_simp
  ring

/-- A proper strategy has the same win rate on a taller stack. -/
theorem rate_emb {n : ℕ} (k : ℕ) {s : ℕ → ℤ} (hs : Proper n s) :
    rate (n + k) (emb n s) = rate n s := by
  unfold rate
  rw [hits_emb k hs, pow_add]
  push_cast
  field_simp

/-! ### The families -/

/-- Following the lowest black hat. -/
theorem rate_lowBlack (n : ℕ) : rate n (lowBlack n) = 1 / 3 * (1 - 1 / 4 ^ n) := by
  have h := congrArg (Nat.cast : ℕ → ℝ) (hits_lowBlack n)
  push_cast at h
  unfold rate
  field_simp
  linarith

/-- Following the lowest white hat. -/
theorem rate_lowWhite (n : ℕ) : rate n (lowWhite n) = 1 / 3 * (1 - 1 / 4 ^ n) := by
  have h := congrArg (Nat.cast : ℕ → ℝ) (hits_lowWhite n)
  push_cast at h
  unfold rate
  field_simp
  linarith

/-- The Carter strategy on an odd number of hats. -/
theorem rate_carterOdd (k : ℕ) :
    rate (2 * k + 1) (carterOdd k) = 7 / 20 - 1 / (10 * 16 ^ k) := by
  have h := congrArg (Nat.cast : ℕ → ℝ) (hits_carterOdd k)
  push_cast at h
  have e : (4 : ℝ) ^ (2 * k + 1) = 4 * 16 ^ k := by
    rw [pow_succ, pow_mul]; norm_num; ring
  unfold rate
  rw [e]
  field_simp
  linarith

/-- The Carter strategy on an even number of hats. -/
theorem rate_carterEven (k : ℕ) :
    rate (2 * k + 2) (carterEven k) = 7 / 20 - 3 / (80 * 16 ^ k) := by
  have h := congrArg (Nat.cast : ℕ → ℝ) (hits_carterEven k)
  push_cast at h
  have e : (4 : ℝ) ^ (2 * k + 2) = 16 * 16 ^ k := by
    rw [pow_add, pow_mul]; norm_num; ring
  unfold rate
  rw [e]
  field_simp
  linarith

/-- The Reyes strategy on `3 * (j + 1)` hats. -/
theorem rate_reyes (j : ℕ) :
    rate (3 * (j + 1)) (reyes j) = 7 / 20 - 1 / (10 * 16 ^ (j + 1)) := by
  have h := congrArg (Nat.cast : ℕ → ℝ) (hits_reyes j)
  push_cast at h
  have e : (4 : ℝ) ^ (3 * (j + 1)) = 64 ^ (j + 1) := by rw [pow_mul]; norm_num
  have e2 : (64 : ℝ) ^ (j + 1) = 4 ^ (j + 1) * 16 ^ (j + 1) := by
    rw [← mul_pow]; norm_num
  rw [e2] at h
  unfold rate
  rw [e, e2]
  field_simp
  linarith

/-! ### Limits -/

theorem tendsto_inv_four_pow : Tendsto (fun n : ℕ => (1 : ℝ) / 4 ^ n) atTop (𝓝 0) := by
  have := tendsto_pow_atTop_nhds_zero_of_lt_one (r := (1 / 4 : ℝ)) (by norm_num) (by norm_num)
  simpa [one_div, inv_pow] using this

/-- As the stacks grow, the win rate of "follow the lowest black hat"
tends to `1 / 3`. -/
theorem tendsto_rate_lowBlack :
    Tendsto (fun n => rate n (lowBlack n)) atTop (𝓝 (1 / 3)) := by
  have h : Tendsto (fun n : ℕ => (1 : ℝ) / 3 * (1 - 1 / 4 ^ n)) atTop (𝓝 (1 / 3 * (1 - 0))) :=
    (tendsto_const_nhds.sub tendsto_inv_four_pow).const_mul _
  simpa [rate_lowBlack] using h

/-- The same for the lowest white hat. -/
theorem tendsto_rate_lowWhite :
    Tendsto (fun n => rate n (lowWhite n)) atTop (𝓝 (1 / 3)) := by
  have h : Tendsto (fun n : ℕ => (1 : ℝ) / 3 * (1 - 1 / 4 ^ n)) atTop (𝓝 (1 / 3 * (1 - 0))) :=
    (tendsto_const_nhds.sub tendsto_inv_four_pow).const_mul _
  simpa [rate_lowWhite] using h

/-- The win rate of the Carter strategy on `n` hats is within `1 / 4 ^ n`
of `7 / 20`, from below. -/
theorem rate_carter_bounds {n : ℕ} (hn : 1 ≤ n) :
    7 / 20 - 1 / 4 ^ n ≤ rate n (carter n) ∧ rate n (carter n) ≤ 7 / 20 := by
  have h := hits_carter hn
  have h1 : 20 * hits n (carter n) ≤ 7 * 4 ^ n := by
    rw [h]; exact Nat.mul_div_le _ _
  have h2 : 7 * 4 ^ n < 20 * hits n (carter n) + 20 := by
    rw [h]; have := Nat.lt_div_mul_add (a := 7 * 4 ^ n) (b := 20) (by norm_num); omega
  have h1' : (20 : ℝ) * hits n (carter n) ≤ 7 * 4 ^ n := by exact_mod_cast h1
  have h2' : (7 : ℝ) * 4 ^ n < 20 * hits n (carter n) + 20 := by exact_mod_cast h2
  have hpos : (0 : ℝ) < 4 ^ n := by positivity
  unfold rate
  constructor
  · rw [div_sub_div _ _ (by norm_num) hpos.ne', div_le_div_iff₀ (by positivity) hpos]
    nlinarith
  · rw [div_le_div_iff₀ hpos (by norm_num)]
    linarith

/-- **As the stacks grow, the win rate of the Carter strategies tends to
`7 / 20`.** -/
theorem tendsto_rate_carter : Tendsto (fun n => rate n (carter n)) atTop (𝓝 (7 / 20)) := by
  have lower : Tendsto (fun n : ℕ => (7 : ℝ) / 20 - 1 / 4 ^ n) atTop (𝓝 (7 / 20 - 0)) :=
    tendsto_const_nhds.sub tendsto_inv_four_pow
  rw [sub_zero] at lower
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' lower tendsto_const_nhds ?_ ?_
  · filter_upwards [eventually_ge_atTop 1] with n hn using (rate_carter_bounds hn).1
  · filter_upwards [eventually_ge_atTop 1] with n hn using (rate_carter_bounds hn).2

/-- The win rate of the Reyes strategies tends to `7 / 20` too. -/
theorem tendsto_rate_reyes :
    Tendsto (fun j => rate (3 * (j + 1)) (reyes j)) atTop (𝓝 (7 / 20)) := by
  have h16 : Tendsto (fun j : ℕ => (1 : ℝ) / (10 * 16 ^ (j + 1))) atTop (𝓝 0) := by
    have := tendsto_pow_atTop_nhds_zero_of_lt_one (r := (1 / 16 : ℝ)) (by norm_num) (by norm_num)
    have h2 := (this.comp (tendsto_add_atTop_nat 1)).const_mul (1 / 10 : ℝ)
    simp only [mul_zero] at h2
    refine h2.congr fun j => ?_
    simp [Function.comp, one_div, inv_pow]
    ring
  have h : Tendsto (fun j : ℕ => (7 : ℝ) / 20 - 1 / (10 * 16 ^ (j + 1))) atTop (𝓝 (7 / 20 - 0)) :=
    tendsto_const_nhds.sub h16
  simpa [rate_reyes] using h

end Hats
