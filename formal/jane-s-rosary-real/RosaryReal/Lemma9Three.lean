-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import RosaryReal.BestApprox
import RosaryReal.Lemma9
import Rosary.Height

/-!
# Lemma 9, by the three-distance theorem

This is the proof of the paper, with its constant: `J ≤ (2/w)^ν / c`.
Take the first best approximation `q ≥ 2/w`.  By the three-distance
theorem the `q` points `0, α, …, (q-1) α` leave arcs shorter than
`2/q ≤ w`; and `q` is at most `(2/w)^ν / c` because `α` is badly
approximable.

(`RosaryReal/Lemma9.lean` has a shorter proof, without the three-distance
theorem, with the constant 4 in place of 2.)
-/

namespace Rosary

open Real ThreeDistance

theorem alpha_irr : Irrational alpha := by
  rw [irrational_iff_ne_rational]
  intro a b hb h
  have hbr : (b : ℝ) ≠ 0 := by exact_mod_cast hb
  have e : (b : ℝ) * alpha = a := by rw [h]; field_simp
  rcases lt_or_gt_of_ne hb with hneg | hpos
  · obtain ⟨k, hk⟩ := Int.eq_ofNat_of_zero_le (show 0 ≤ -b by omega)
    apply alpha_irrational k (by omega) (-a)
    have : ((k : ℤ) : ℝ) = -(b : ℝ) := by rw [← hk]; push_cast; ring
    push_cast at this ⊢
    rw [this]; linarith
  · obtain ⟨k, hk⟩ := Int.eq_ofNat_of_zero_le hpos.le
    apply alpha_irrational k (by omega) a
    have : ((k : ℤ) : ℝ) = (b : ℝ) := by rw [← hk]
    push_cast at this
    rw [this]; exact e

/-- If every arc between the `q` points has length at most `w`, then every
arc of length `w` of the circle contains one of the points, wherever the
orbit starts. -/
theorem cover_of_gaps {α : ℝ} (hα : Irrational α) (q : ℕ) (hq : 1 ≤ q) (w : ℝ)
    (hgap : ∀ i : ℕ, i < q → ∃ j : ℕ, j < q ∧ j ≠ i ∧ fr α ((j : ℤ) - i) ≤ w) :
    ∀ θ a : ℝ, ∃ j : ℕ, j < q ∧ ∃ z : ℤ, a ≤ θ + j * α - z ∧ θ + j * α - z ≤ a + w := by
  intro θ a
  -- the point just behind `a`: the one whose distance forward from `a` is largest
  obtain ⟨i, hi, hmax⟩ := Finset.exists_max_image (Finset.range q)
    (fun j : ℕ => Int.fract (θ + j * α - a)) ⟨0, Finset.mem_range.mpr (by omega)⟩
  rw [Finset.mem_range] at hi
  obtain ⟨j, hj, hji, hg⟩ := hgap i hi
  have hmaxj := hmax j (Finset.mem_range.mpr hj)
  have hpos : 0 < fr α ((j : ℤ) - i) := fr_pos hα (by omega)
  -- the next point is just ahead of `a`
  obtain ⟨z, hz⟩ := Int.fract_add (θ + i * α - a) ((((j : ℤ) - i : ℤ) : ℝ) * α)
  have e : θ + (i : ℝ) * α - a + (((j : ℤ) - i : ℤ) : ℝ) * α = θ + j * α - a := by
    push_cast; ring
  rw [e] at hz
  change Int.fract (θ + j * α - a) - Int.fract (θ + i * α - a) - fr α ((j : ℤ) - i) = z at hz
  have b1 := Int.fract_nonneg (θ + (j : ℝ) * α - a)
  have b2 := Int.fract_lt_one (θ + (j : ℝ) * α - a)
  have b3 := Int.fract_nonneg (θ + (i : ℝ) * α - a)
  have b4 := Int.fract_lt_one (θ + (i : ℝ) * α - a)
  have b5 := fr_lt_one (α := α) ((j : ℤ) - i)
  have hz1 : (-2 : ℝ) < z := by linarith
  have hz2 : (z : ℝ) < 0 := by
    have : Int.fract (θ + (j : ℝ) * α - a) ≤ Int.fract (θ + (i : ℝ) * α - a) := hmaxj
    linarith
  have hz' : z = -1 := by
    have h1 : -2 < z := by exact_mod_cast hz1
    have h2 : z < 0 := by exact_mod_cast hz2
    omega
  rw [hz'] at hz
  push_cast at hz
  refine ⟨j, hj, ⌊θ + j * α - a⌋, ?_, ?_⟩
  · have := Int.self_sub_floor (θ + (j : ℝ) * α - a)
    linarith
  · have := Int.self_sub_floor (θ + (j : ℝ) * α - a)
    linarith

/-- **Lemma 9, with the paper's constant.**  If `α` is badly approximable
to the order `ν`, then for every `0 < w ≤ 1` some `J ≤ (2/w)^ν / c`
consecutive points of any orbit of the rotation by `α` meet every arc of
length `w`. -/
theorem lemma9_three (c ν : ℝ) (hν : 0 < ν) (H : BadlyApproximable c ν)
    (w : ℝ) (hw : 0 < w) (hw1 : w ≤ 1) :
    ∃ J : ℕ, (J : ℝ) ≤ (2 / w) ^ ν / c ∧ ∀ θ a : ℝ, ∃ j : ℕ, j < J ∧ ∃ z : ℤ,
      a ≤ θ + j * alpha - z ∧ θ + j * alpha - z ≤ a + w := by
  obtain ⟨hc, H⟩ := H
  have hα := alpha_irr
  have nnpos : ∀ k : ℕ, 1 ≤ k → 0 < nn alpha k := fun k hk => by
    have h1 := fr_pos hα (show ((k : ℕ) : ℤ) ≠ 0 by omega)
    have h2 := fr_lt_one (α := alpha) (k : ℤ)
    exact lt_min h1 (by linarith)
  -- `M = ⌈2/w⌉ ≥ 2`, and the best `k₀` below `M`
  have h2w : 2 ≤ 2 / w := by rw [le_div_iff₀ hw]; linarith
  have hMle : 2 / w ≤ (⌈2 / w⌉₊ : ℝ) := Nat.le_ceil _
  have hMlt : (⌈2 / w⌉₊ : ℝ) < 2 / w + 1 := Nat.ceil_lt_add_one (by positivity)
  generalize ⌈2 / w⌉₊ = M at hMle hMlt
  have hM2 : 2 ≤ M := by exact_mod_cast le_trans h2w hMle
  obtain ⟨k0, hk0, hmin⟩ := Finset.exists_min_image (Finset.Icc 1 (M - 1))
    (fun k : ℕ => nn alpha k) ⟨1, Finset.mem_Icc.mpr ⟨le_refl 1, by omega⟩⟩
  rw [Finset.mem_Icc] at hk0
  have hη := nnpos k0 hk0.1
  -- some `k` does better than `k₀` (Dirichlet); take the first one, `q`
  have hex : ∃ k : ℕ, 1 ≤ k ∧ nn alpha k < nn alpha k0 := by
    obtain ⟨j, k, hkpos, -, hd⟩ :=
      Real.exists_int_int_abs_mul_sub_le alpha (Nat.succ_pos ⌈1 / nn alpha k0⌉₊)
    obtain ⟨K, rfl⟩ := Int.eq_ofNat_of_zero_le hkpos.le
    refine ⟨K, by omega, lt_of_le_of_lt (nn_le_abs (K : ℤ) j) (lt_of_le_of_lt hd ?_)⟩
    have h1 : 1 / nn alpha k0 ≤ (⌈1 / nn alpha k0⌉₊ : ℝ) := Nat.le_ceil _
    rw [div_lt_iff₀ (by positivity)]
    have h2 : 1 ≤ nn alpha k0 * (⌈1 / nn alpha k0⌉₊ : ℝ) := by
      have := mul_le_mul_of_nonneg_left h1 hη.le
      rwa [mul_one_div_cancel hη.ne'] at this
    push_cast
    nlinarith
  obtain ⟨q, ⟨hq1, hqlt⟩, hqmin⟩ := exists_least _ hex
  have hnotP : ∀ k : ℕ, 1 ≤ k → k < q → nn alpha k0 ≤ nn alpha k := by
    intro k hk hkq
    by_contra hc'
    have := hqmin k ⟨hk, by linarith⟩
    omega
  have hMq : M ≤ q := by
    by_contra hlt
    have := hmin q (Finset.mem_Icc.mpr ⟨hq1, by omega⟩)
    linarith
  have hbest : ∀ k : ℕ, 1 ≤ k → k < q → nn alpha q < nn alpha k := fun k hk hkq =>
    lt_of_lt_of_le hqlt (hnotP k hk hkq)
  -- `‖k₀ α‖ ≤ 1/q` (Dirichlet again)
  have hηq : nn alpha k0 ≤ 1 / (q : ℝ) := by
    obtain ⟨j, k, hkpos, hkle, hd⟩ :=
      Real.exists_int_int_abs_mul_sub_le alpha (show 0 < q - 1 by omega)
    obtain ⟨K, rfl⟩ := Int.eq_ofNat_of_zero_le hkpos.le
    have hK : K ≤ q - 1 := by exact_mod_cast hkle
    have h1 := hnotP K (by omega) (by omega)
    have h2 := nn_le_abs (α := alpha) (K : ℤ) j
    have e : (((q - 1 : ℕ) : ℝ) + 1) = q := by
      rw [Nat.cast_sub (by omega)]; push_cast; ring
    rw [e] at hd
    linarith
  have hq0 : (0 : ℝ) < q := by exact_mod_cast (by omega : 0 < q)
  have hM0 : (0 : ℝ) < M := by exact_mod_cast (by omega : 0 < M)
  refine ⟨q, ?_, ?_⟩
  · -- `q ≤ 1/‖k₀ α‖ ≤ k₀^ν / c ≤ (2/w)^ν / c`
    obtain ⟨p, hp⟩ := nn_eq_abs (α := alpha) (k0 : ℤ)
    have hH := H k0 hk0.1 p
    have hk0r : (0 : ℝ) < k0 := by exact_mod_cast hk0.1
    have hk0w : (k0 : ℝ) ≤ 2 / w := by
      have : (k0 : ℝ) ≤ (M : ℝ) - 1 := by
        have : k0 + 1 ≤ M := by omega
        have : ((k0 + 1 : ℕ) : ℝ) ≤ M := by exact_mod_cast this
        push_cast at this; linarith
      linarith
    have hpow : (k0 : ℝ) ^ ν ≤ (2 / w) ^ ν := Real.rpow_le_rpow hk0r.le hk0w hν.le
    have hpowpos : (0 : ℝ) < (k0 : ℝ) ^ ν := Real.rpow_pos_of_pos hk0r ν
    have hη' : c / (k0 : ℝ) ^ ν ≤ nn alpha k0 := by
      have e : (((k0 : ℕ) : ℤ) : ℝ) = (k0 : ℝ) := by push_cast; rfl
      rw [hp, e, div_eq_mul_inv, ← Real.rpow_neg hk0r.le]
      exact hH
    have h1 : (q : ℝ) * nn alpha k0 ≤ 1 := by
      have := mul_le_mul_of_nonneg_left hηq hq0.le
      rwa [mul_one_div_cancel hq0.ne'] at this
    have h2 : (q : ℝ) * (c / (k0 : ℝ) ^ ν) ≤ 1 :=
      le_trans (mul_le_mul_of_nonneg_left hη' hq0.le) h1
    have h3 : (q : ℝ) * c ≤ (k0 : ℝ) ^ ν := by
      have := mul_le_mul_of_nonneg_right h2 hpowpos.le
      rw [mul_assoc, div_mul_cancel₀ _ hpowpos.ne', one_mul] at this
      exact this
    rw [le_div_iff₀ hc]
    linarith
  · -- the arcs are shorter than `2/q ≤ w`
    apply cover_of_gaps hα q (by omega) w
    intro i hi
    obtain ⟨j, hj, hji, hk⟩ := best_approx_gaps hα q (by omega) hbest i hi
    refine ⟨j, hj, hji, ?_⟩
    have h1 := hk k0 hk0.1 (by omega)
    have h2 : 2 / (q : ℝ) ≤ w := by
      rw [div_le_iff₀ hq0]
      have : (M : ℝ) ≤ q := by exact_mod_cast hMq
      have : 2 ≤ w * M := by
        have := (div_le_iff₀ hw).mp hMle
        linarith
      nlinarith
    have h3 : 2 / (q : ℝ) = 1 / q + 1 / q := by ring
    linarith

end Rosary
