-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import RosaryReal.Track

/-!
# Theorem 3, by the proof of the paper (Section 8)

`Rosary.theorem3`, in the first project, proves Theorem 3 with integers
only.  Here is the proof of the paper: the cone of a bead, the logarithm
of Jane's bead, the rotation by `α`.
-/

namespace Rosary

open Real

/-- **Step 1.**  If a bead `b` is told, so is every bead `bD^p` below it.
Hence, if `m` is never told, Jane never enters the cone of `m`. -/
theorem told_div (p : ℕ) :
    ∀ b i, b ∈ told i → 1 ≤ b / 2 ^ p → ∃ i', b / 2 ^ p ∈ told i' := by
  induction p with
  | zero => intro b i hb _; exact ⟨i, by simpa using hb⟩
  | succ p ih =>
    intro b i hb h1
    have hdiv : b / 2 ^ (p + 1) = (b / 2 ^ p) / 2 := by
      rw [pow_succ, Nat.div_div_eq_div_mul]
    rw [hdiv] at h1 ⊢
    obtain ⟨i', hi'⟩ := ih b i hb (by omega)
    obtain ⟨i'', h⟩ := told_down (b / 2 ^ p) i' hi' (by omega)
    rw [down_eq] at h
    exact ⟨i'', h⟩

/-- A bead `b > m` whose logarithm, minus an integer `Z`, lies strictly
between `log₂ m` and `log₂ (m + 1)` is in the cone of `m`: `bD^p = m`. -/
theorem cone_of_phase (m N b : ℕ) (hm : 1 ≤ m) (hNm : m ≤ N) (hbN : N < b) (Z : ℤ)
    (hlo : logb 2 m < logb 2 b - (Z : ℝ))
    (hhi : logb 2 b - (Z : ℝ) < logb 2 ((m : ℝ) + 1)) : ∃ p : ℕ, b / 2 ^ p = m := by
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  have hb0 : (0 : ℝ) < b := by exact_mod_cast (by omega : 0 < b)
  -- `b` is larger than `m`, so the integer `Z` is not negative
  have hZ : 0 ≤ Z := by
    by_contra hneg
    have hZ1 : (Z : ℝ) ≤ -1 := by exact_mod_cast (by omega : Z ≤ -1)
    have h1 : logb 2 ((m : ℝ) + 1) - 1 ≤ logb 2 m := by
      have e : logb 2 (((m : ℝ) + 1) / 2) = logb 2 ((m : ℝ) + 1) - 1 := by
        rw [Real.logb_div (by positivity) (by norm_num),
          Real.logb_self_eq_one (by norm_num)]
      rw [← e]
      apply Real.logb_le_logb_of_le (by norm_num) (by positivity)
      have : (1 : ℝ) ≤ m := by exact_mod_cast hm
      linarith
    have h2 : logb 2 b < logb 2 m := by linarith
    have h3 : (b : ℝ) < m := (Real.logb_lt_logb_iff (by norm_num) hb0 hm0).mp h2
    have : b < m := by exact_mod_cast h3
    omega
  obtain ⟨p, rfl⟩ := Int.eq_ofNat_of_zero_le hZ
  -- `m 2^p < b < (m + 1) 2^p`: the bead `b` is in the cone of `m`
  have hpow : logb 2 ((2 : ℝ) ^ p) = p := by
    rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num), mul_one]
  have c1 : (m : ℝ) * 2 ^ p < b := by
    apply (Real.logb_lt_logb_iff (b := 2) (by norm_num) (by positivity) hb0).mp
    rw [Real.logb_mul hm0.ne' (by positivity), hpow]
    push_cast at hlo
    linarith
  have c2 : (b : ℝ) < ((m : ℝ) + 1) * 2 ^ p := by
    apply (Real.logb_lt_logb_iff (b := 2) (by norm_num) hb0 (by positivity)).mp
    rw [Real.logb_mul (by positivity) (by positivity), hpow]
    push_cast at hhi
    linarith
  have c1' : m * 2 ^ p ≤ b := by exact_mod_cast c1.le
  have c2' : b < (m + 1) * 2 ^ p := by exact_mod_cast c2
  have hdiv : b / 2 ^ p = m := Nat.div_eq_of_lt_le c1' c2'
  exact ⟨p, hdiv⟩

/-- **Theorem 3, by the rotation.**  The reluctant recitation tells every
bead. -/
theorem theorem3_by_rotation (m : ℕ) (hm : 1 ≤ m) : ∃ i, rho i = m := by
  by_contra hno
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  -- the arc of `m`: from `log₂ m` to `log₂ (m + 1)`, of length `w`
  have hw : 0 < logb 2 ((m : ℝ) + 1) - logb 2 m := by
    have := Real.logb_lt_logb (b := 2) (by norm_num) hm0 (show (m : ℝ) < m + 1 by linarith)
    linarith
  generalize hwdef : logb 2 ((m : ℝ) + 1) - logb 2 m = w at hw
  -- `J` steps of the rotation reach its middle third
  obtain ⟨J, hJ⟩ := rotation_cover (logb 2 m + w / 3) (w / 3) (by positivity)
  -- `N` so large that the errors of `J` steps stay below `w/3`
  obtain ⟨N, hN1, hNm, hNJ⟩ : ∃ N : ℕ, 1 ≤ N ∧ m ≤ N ∧ (J : ℝ) * (2 / N) < w / 3 := by
    refine ⟨m + ⌈6 * J / w⌉₊ + 1, by omega, by omega, ?_⟩
    have h1 : 6 * J / w ≤ (⌈6 * J / w⌉₊ : ℝ) := Nat.le_ceil _
    have h2 : 6 * (J : ℝ) ≤ ⌈6 * J / w⌉₊ * w := by rwa [div_le_iff₀ hw] at h1
    have hpos : (0 : ℝ) < ((m + ⌈6 * J / w⌉₊ + 1 : ℕ) : ℝ) := by positivity
    rw [mul_div_assoc', div_lt_iff₀ hpos]
    push_cast
    nlinarith
  -- Step 2: after time `T`, all beads are larger than `N`
  obtain ⟨T, hT⟩ := eventually_large N
  -- Step 4: some `j < J` brings the phase into the middle third
  obtain ⟨j, hj, z1, hz1, hz2⟩ := hJ (logb 2 (rho T))
  -- Step 3: a time `t` at which Jane has made `j` up moves since `T`
  obtain ⟨t, ht, hups⟩ := exists_ups T j
  obtain ⟨b, k, u, z, hb, hrho, hu, herr⟩ :=
    phase_track N T hN1 t ht fun s h1 _ => hT s h1
  have huj : u = j := by omega
  subst huj
  have herr' : |logb 2 b - logb 2 (rho T) - u * alpha - z| < w / 3 := by
    refine lt_of_le_of_lt herr (lt_of_le_of_lt ?_ hNJ)
    have : (u : ℝ) ≤ J := by exact_mod_cast hj.le
    exact mul_le_mul_of_nonneg_right this (by positivity)
  rw [abs_lt] at herr'
  -- so the told bead `b` has its phase in the arc of `m`
  have hlo : logb 2 m < logb 2 b - ((z + z1 : ℤ) : ℝ) := by
    push_cast; linarith [herr'.1]
  have hhi : logb 2 b - ((z + z1 : ℤ) : ℝ) < logb 2 ((m : ℝ) + 1) := by
    push_cast; linarith [herr'.2]
  have hbN : N < b := lt_of_lt_of_le (hT t ht) (by rw [hrho]; exact Nat.div_le_self b _)
  obtain ⟨p, hdiv⟩ := cone_of_phase m N b hm hNm hbN _ hlo hhi
  -- Step 1: then `m` is told
  obtain ⟨i', hi'⟩ := told_div p b t hb (by omega)
  rw [hdiv] at hi'
  obtain ⟨i, _, hi⟩ := (mem_told i' m).mp hi'
  exact hno ⟨i, hi⟩

end Rosary
