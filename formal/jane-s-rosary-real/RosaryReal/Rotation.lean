-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import RosaryReal.Phase

/-!
# The rotation by `α` (Step 4 of the proof of Theorem 3)

"The rotation of the circle by `α` is minimal: there is an integer `J`
such that any `J` consecutive points `θ, θ + α, …, θ + (J - 1) α` of any
orbit contain a point in a given arc."  Here the circle is the real line
modulo the integers, and an arc is an interval `[c, c + w]`.
-/

namespace Rosary

open Real

/-- Steps of length `e` from 0 reach `[y, y + e)` within `⌈1/e⌉` steps,
for `0 ≤ y < 1`. -/
theorem step_cover (e y : ℝ) (he : 0 < e) (hy0 : 0 ≤ y) (hy1 : y < 1) :
    ∃ i : ℕ, i ≤ ⌈1 / e⌉₊ ∧ y ≤ i * e ∧ i * e < y + e := by
  have hq : y / e * e = y := div_mul_cancel₀ y he.ne'
  have h1 : y / e ≤ (⌈y / e⌉₊ : ℝ) := Nat.le_ceil _
  have h2 : (⌈y / e⌉₊ : ℝ) < y / e + 1 := Nat.ceil_lt_add_one (div_nonneg hy0 he.le)
  have h3 := mul_le_mul_of_nonneg_right h1 he.le
  have h4 := mul_lt_mul_of_pos_right h2 he
  rw [hq] at h3
  rw [add_mul, one_mul, hq] at h4
  refine ⟨⌈y / e⌉₊, Nat.ceil_le_ceil ?_, h3, h4⟩
  exact div_le_div_of_nonneg_right hy1.le he.le

/-- The rotation by `α` reaches every arc in a bounded number of steps:
for every interval `[c, c + w]` there is a `J` such that, from any `θ`,
one of `θ, θ + α, …, θ + (J - 1) α` lies in `[c, c + w]` modulo 1. -/
theorem rotation_cover (c w : ℝ) (hw : 0 < w) :
    ∃ J : ℕ, ∀ θ : ℝ, ∃ j : ℕ, j < J ∧ ∃ z : ℤ,
      c ≤ θ + j * alpha - z ∧ θ + j * alpha - z ≤ c + w := by
  -- Dirichlet: some multiple `K α` is within `w` of an integer `j0`
  obtain ⟨j0, k, hk0, -, hd⟩ :=
    Real.exists_int_int_abs_mul_sub_le alpha (Nat.succ_pos ⌈1 / w⌉₊)
  obtain ⟨K, rfl⟩ := Int.eq_ofNat_of_zero_le hk0.le
  have hK : 1 ≤ K := by omega
  have hKr : ((K : ℤ) : ℝ) = (K : ℝ) := Int.cast_natCast K
  rw [hKr] at hd
  have hdw : |(K : ℝ) * alpha - j0| ≤ w := by
    refine le_trans hd ?_
    have h1 : (1 : ℝ) / w ≤ ⌈1 / w⌉₊ := Nat.le_ceil _
    have h2 : 1 ≤ w * (⌈1 / w⌉₊ : ℝ) := by
      have := mul_le_mul_of_nonneg_left h1 hw.le
      rwa [mul_one_div_cancel hw.ne'] at this
    rw [div_le_iff₀ (by positivity)]
    push_cast
    nlinarith
  have hd0 : (K : ℝ) * alpha - j0 ≠ 0 := fun h0 =>
    alpha_irrational K hK j0 (by linarith)
  generalize hdef : (K : ℝ) * alpha - j0 = d at hdw hd0
  refine ⟨K * (⌈1 / |d|⌉₊ + 1), fun θ => ?_⟩
  rcases lt_or_gt_of_ne hd0 with hneg | hpos
  · -- each `K` steps move the point back by `-d`
    have he : 0 < -d := neg_pos.mpr hneg
    have habs : |d| = -d := abs_of_neg hneg
    have f1 := Int.floor_le (θ - c - w)
    have f2 := Int.lt_floor_add_one (θ - c - w)
    obtain ⟨i, hi, s1, s2⟩ := step_cover (-d) (θ - ⌊θ - c - w⌋ - (c + w)) he
      (by linarith) (by linarith)
    rw [← habs] at hi
    refine ⟨i * K, by nlinarith, ⌊θ - c - w⌋ + i * j0, ?_, ?_⟩
    · push_cast; rw [habs] at hdw; nlinarith
    · push_cast; nlinarith
  · -- each `K` steps move the point forward by `d`
    have habs : |d| = d := abs_of_pos hpos
    have f1 := Int.le_ceil (θ - c)
    have f2 := Int.ceil_lt_add_one (θ - c)
    obtain ⟨i, hi, s1, s2⟩ := step_cover d (c - (θ - ⌈θ - c⌉)) hpos
      (by linarith) (by linarith)
    rw [← habs] at hi
    refine ⟨i * K, by nlinarith, ⌈θ - c⌉ + i * j0, ?_, ?_⟩
    · push_cast; nlinarith
    · push_cast; rw [habs] at hdw; nlinarith

end Rosary
