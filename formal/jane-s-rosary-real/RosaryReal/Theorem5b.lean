-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import RosaryReal.Depth
import RosaryReal.Theorem5

/-!
# Theorem 5, parts 2 and 3

Under the hypothesis that `α` is badly approximable to the order `ν`
(an irrationality exponent of `log₂ 3`):
`log₂ ρ(t) ≤ 2 √t + O(log t)` and `u(t)/t = log₃ 2 + O(t^(-1/2))`.
-/

namespace Rosary

open Real

theorem logb_rho_lt (t : ℕ) : logb 2 (rho t) < (Nat.log 2 (rho t) : ℝ) + 1 := by
  have hpos : (0 : ℝ) < rho t := by exact_mod_cast rho_pos t
  rw [Real.logb_lt_iff_lt_rpow (by norm_num) hpos]
  have h : ((rho t : ℕ) : ℝ) < (2 : ℝ) ^ (Nat.log 2 (rho t) + 1) := by
    exact_mod_cast lt_two_pow_depth (rho t)
  rw [show ((Nat.log 2 (rho t) : ℝ) + 1) = ((Nat.log 2 (rho t) + 1 : ℕ) : ℝ) by push_cast; ring,
    Real.rpow_natCast]
  exact h

theorem alpha_lt_one : alpha < 1 := by
  have := Real.logb_lt_logb (b := 2) (by norm_num) (show (0 : ℝ) < 3 / 2 by norm_num)
    (show (3 : ℝ) / 2 < 2 by norm_num)
  rwa [Real.logb_self_eq_one (by norm_num)] at this

theorem alpha_pos : 0 < alpha :=
  Real.logb_pos (by norm_num) (by norm_num)

/-- **Theorem 5, part 2.**  If `α` is badly approximable to the order `ν`,
then `log₂ ρ(t) ≤ 2 √t + C log t` for some constant `C` and all `t ≥ 2`. -/
theorem theorem5_part2 (c ν : ℝ) (hν : 0 < ν) (H : BadlyApproximable c ν) :
    ∃ C : ℝ, ∀ t : ℕ, 2 ≤ t → logb 2 (rho t) ≤ 2 * √t + C * Real.log t := by
  obtain ⟨hc, H⟩ := H
  -- `c < 1`, from `q = 1`
  have hc1 : c < 1 := by
    have h := H 1 (le_refl 1) 0
    simp only [Nat.cast_one, Real.one_rpow, mul_one, one_mul, Int.cast_zero, sub_zero] at h
    rw [abs_of_pos alpha_pos] at h
    linarith [alpha_lt_one]
  have hl2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  refine ⟨(1 + ν) / (2 * Real.log 2) + 2 * |10 + ν - logb 2 c|, fun t ht => ?_⟩
  have ht2 : (2 : ℝ) ≤ t := by exact_mod_cast ht
  have ht0 : (0 : ℝ) < t := by linarith
  have hsq : √(t : ℝ) * √(t : ℝ) = t := Real.mul_self_sqrt ht0.le
  have hs1 : 1 < √(t : ℝ) := by
    rw [Real.lt_sqrt (by norm_num)]; linarith
  -- `K = ⌈√t⌉`
  have hKle : √(t : ℝ) ≤ (⌈√(t : ℝ)⌉₊ : ℝ) := Nat.le_ceil _
  have hKlt : (⌈√(t : ℝ)⌉₊ : ℝ) < √(t : ℝ) + 1 := Nat.ceil_lt_add_one (Real.sqrt_nonneg _)
  generalize ⌈√(t : ℝ)⌉₊ = K at hKle hKlt
  have hK1r : (1 : ℝ) < K := lt_of_lt_of_le hs1 hKle
  have hK2 : 2 ≤ K := by exact_mod_cast hK1r
  have hK0 : (0 : ℝ) < K := by linarith
  -- `η = c K^(-ν)`
  have hKpow : (0 : ℝ) < (K : ℝ) ^ (-ν) := Real.rpow_pos_of_pos hK0 _
  have hKpow1 : (K : ℝ) ^ (-ν) ≤ 1 := Real.rpow_le_one_of_one_le_of_nonpos hK1r.le (by linarith)
  have hη : 0 < c * (K : ℝ) ^ (-ν) := mul_pos hc hKpow
  have Hη : ∀ q : ℕ, 1 ≤ q → q < K → ∀ p : ℤ, c * (K : ℝ) ^ (-ν) ≤ |q * alpha - p| := by
    intro q hq1 hqK p
    have hq0 : (0 : ℝ) < q := by exact_mod_cast hq1
    have hqK' : (q : ℝ) ≤ K := by exact_mod_cast hqK.le
    have := Real.rpow_le_rpow_of_nonpos hq0 hqK' (show -ν ≤ 0 by linarith)
    exact le_trans (mul_le_mul_of_nonneg_left this hc.le) (H q hq1 p)
  -- `D` with `2^D ≥ 16 K / η`
  have hx1 : 1 ≤ 16 * (K : ℝ) / (c * (K : ℝ) ^ (-ν)) := by
    rw [le_div_iff₀ hη]
    have : c * (K : ℝ) ^ (-ν) ≤ 1 := by nlinarith
    linarith
  have hx0 : 0 < 16 * (K : ℝ) / (c * (K : ℝ) ^ (-ν)) := by linarith
  have hlogx : 0 ≤ logb 2 (16 * (K : ℝ) / (c * (K : ℝ) ^ (-ν))) :=
    Real.logb_nonneg (by norm_num) hx1
  have hDle : logb 2 (16 * (K : ℝ) / (c * (K : ℝ) ^ (-ν)))
      ≤ (⌈logb 2 (16 * (K : ℝ) / (c * (K : ℝ) ^ (-ν)))⌉₊ : ℝ) := Nat.le_ceil _
  have hDlt : (⌈logb 2 (16 * (K : ℝ) / (c * (K : ℝ) ^ (-ν)))⌉₊ : ℝ)
      < logb 2 (16 * (K : ℝ) / (c * (K : ℝ) ^ (-ν))) + 1 := Nat.ceil_lt_add_one hlogx
  -- the value of that logarithm
  have h16 : logb 2 (16 : ℝ) = 4 := by
    rw [show (16 : ℝ) = 2 ^ (4 : ℕ) by norm_num, Real.logb_pow,
      Real.logb_self_eq_one (by norm_num)]
    norm_num
  have hlogval : logb 2 (16 * (K : ℝ) / (c * (K : ℝ) ^ (-ν)))
      = 4 + (1 + ν) * logb 2 K - logb 2 c := by
    rw [Real.logb_div (by positivity) hη.ne', Real.logb_mul (by norm_num) hK0.ne',
      Real.logb_mul hc.ne' hKpow.ne', Real.logb_rpow_eq_mul_logb_of_pos hK0, h16]
    ring
  generalize hDdef : ⌈logb 2 (16 * (K : ℝ) / (c * (K : ℝ) ^ (-ν)))⌉₊ = D at hDle hDlt
  rw [hlogval] at hDle hDlt
  have hD : 16 * (K : ℝ) ≤ c * (K : ℝ) ^ (-ν) * 2 ^ D := by
    have h1 : logb 2 (16 * (K : ℝ) / (c * (K : ℝ) ^ (-ν))) ≤ (D : ℝ) := by
      rw [hlogval]; exact hDle
    rw [Real.logb_le_iff_le_rpow (by norm_num) hx0, Real.rpow_natCast, div_le_iff₀ hη] at h1
    linarith
  -- the count
  have hcount := depth_bound K D hK2 _ hη Hη hD t
  have hL : (Nat.log 2 (rho t) : ℝ) ≤ ((t : ℝ) + 1) / K + 1 + K + D := by
    have hdiv : 0 ≤ ((t : ℝ) + 1) / K := by positivity
    by_cases hsmall : Nat.log 2 (rho t) ≤ 1 + K + D
    · have : (Nat.log 2 (rho t) : ℝ) ≤ 1 + K + D := by exact_mod_cast hsmall
      linarith
    · obtain ⟨r, hr⟩ : ∃ r, Nat.log 2 (rho t) = (1 + K + D) + r :=
        ⟨Nat.log 2 (rho t) - (1 + K + D), by omega⟩
      rw [hr, show 1 + K + D + r - 1 - K - D = r by omega] at hcount
      have hr' : (K : ℝ) * r ≤ (t : ℝ) + 1 := by exact_mod_cast hcount
      have : (r : ℝ) ≤ ((t : ℝ) + 1) / K := by
        rw [le_div_iff₀ hK0]; linarith
      rw [hr]; push_cast; linarith
  have hlr := logb_rho_lt t
  have hdivK : ((t : ℝ) + 1) / K ≤ √(t : ℝ) + 1 := by
    rw [div_le_iff₀ hK0]; nlinarith
  -- `log₂ K ≤ 1 + log t / (2 log 2)`
  have hlogK : logb 2 (K : ℝ) ≤ 1 + Real.log t / (2 * Real.log 2) := by
    have h1 : (K : ℝ) ≤ 2 * √(t : ℝ) := by linarith
    have h2 : logb 2 (K : ℝ) ≤ logb 2 (2 * √(t : ℝ)) :=
      Real.logb_le_logb_of_le (by norm_num) hK0 h1
    rw [Real.logb_mul (by norm_num) (by positivity), Real.logb_self_eq_one (by norm_num)] at h2
    have h3 : logb 2 (√(t : ℝ)) = Real.log t / (2 * Real.log 2) := by
      rw [Real.logb, Real.log_sqrt ht0.le]; field_simp
    linarith
  have hlogt : Real.log 2 ≤ Real.log t := Real.log_le_log (by norm_num) ht2
  have hlogt0 : 0 ≤ Real.log t := by linarith
  -- putting the bounds together
  have hmain : logb 2 (rho t) ≤ 2 * √(t : ℝ) + (10 + ν - logb 2 c)
      + (1 + ν) / (2 * Real.log 2) * Real.log t := by
    have e : (1 + ν) / (2 * Real.log 2) * Real.log t
        = (1 + ν) * (Real.log t / (2 * Real.log 2)) := by ring
    rw [e]
    have hmul := mul_le_mul_of_nonneg_left hlogK (show (0 : ℝ) ≤ 1 + ν by linarith)
    linarith
  have habs : 10 + ν - logb 2 c ≤ 2 * |10 + ν - logb 2 c| * Real.log t := by
    have h1 := le_abs_self (10 + ν - logb 2 c)
    have h2 := abs_nonneg (10 + ν - logb 2 c)
    nlinarith
  linarith

/-- **Theorem 5, part 3.**  If `α` is badly approximable, then
`u(t)/t = log₃ 2 + O(t^(-1/2))`: there is a constant `C` such that
`|u(t)/t - log₃ 2| ≤ C/√t` for all `t ≥ 2`. -/
theorem theorem5_part3 (c ν : ℝ) (hν : 0 < ν) (H : BadlyApproximable c ν) :
    ∃ C : ℝ, ∀ t : ℕ, 2 ≤ t → |(ups t : ℝ) / t - logb 3 2| ≤ C / √t := by
  obtain ⟨C2, h2⟩ := theorem5_part2 c ν hν H
  refine ⟨13 / 2 + 2 * |C2|, fun t ht => ?_⟩
  have ht2 : (2 : ℝ) ≤ t := by exact_mod_cast ht
  have ht0 : (0 : ℝ) < t := by linarith
  have hsq : √(t : ℝ) * √(t : ℝ) = t := Real.mul_self_sqrt ht0.le
  have hs0 : 0 < √(t : ℝ) := Real.sqrt_pos.mpr ht0
  have hs1 : 1 ≤ √(t : ℝ) := Real.one_le_sqrt.mpr (by linarith)
  have hL3 : 1 ≤ logb 2 3 := by
    rw [logb_two_three]; linarith [alpha_pos]
  have hinv : logb 3 2 = (logb 2 3)⁻¹ := (Real.inv_logb 2 3).symm
  -- `log t ≤ 2 √t`
  have hlog : Real.log t ≤ 2 * √(t : ℝ) := by
    have h := Real.log_le_sub_one_of_pos hs0
    rw [Real.log_sqrt ht0.le] at h
    linarith
  have hlog0 : 0 ≤ Real.log t := Real.log_nonneg (by linarith)
  -- the three ingredients
  have p1 := abs_le.mp (theorem5_part1 t (by omega))
  have hlr0 : 0 ≤ logb 2 (rho t) :=
    Real.logb_nonneg (by norm_num) (by exact_mod_cast rho_pos t)
  have hlr := h2 t ht
  have hC2 : C2 * Real.log t ≤ |C2| * (2 * √(t : ℝ)) :=
    le_trans (mul_le_mul_of_nonneg_right (le_abs_self C2) hlog0)
      (mul_le_mul_of_nonneg_left hlog (abs_nonneg C2))
  have hA : |(ups t : ℝ) * logb 2 3 - t| ≤ (13 / 2 + 2 * |C2|) * √(t : ℝ) := by
    rw [abs_le]
    constructor <;> nlinarith [p1.1, p1.2, abs_nonneg C2]
  -- divide by `t log₂ 3`
  have hM : 0 ≤ 13 / 2 + 2 * |C2| := by positivity
  have e : (ups t : ℝ) / t - logb 3 2 = ((ups t : ℝ) * logb 2 3 - t) / (t * logb 2 3) := by
    rw [hinv]; field_simp
  rw [e, abs_div, abs_of_pos (by positivity : (0 : ℝ) < t * logb 2 3),
    div_le_div_iff₀ (by positivity) hs0]
  have h3 : |(ups t : ℝ) * logb 2 3 - t| * √(t : ℝ)
      ≤ (13 / 2 + 2 * |C2|) * √(t : ℝ) * √(t : ℝ) :=
    mul_le_mul_of_nonneg_right hA hs0.le
  have h4 : (13 / 2 + 2 * |C2|) * √(t : ℝ) * √(t : ℝ) = (13 / 2 + 2 * |C2|) * t := by
    rw [mul_assoc, hsq]
  have h5 : (13 / 2 + 2 * |C2|) * (t : ℝ) ≤ (13 / 2 + 2 * |C2|) * (t * logb 2 3) := by
    apply mul_le_mul_of_nonneg_left _ hM
    nlinarith
  linarith

end Rosary
