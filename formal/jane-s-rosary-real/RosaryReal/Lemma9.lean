-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import RosaryReal.Rotation

/-!
# Lemma 9: the covering time of the rotation, with a bound

The hypothesis is that `α` is badly approximable to the order `ν`: there
is a `c > 0` with `|q α - p| ≥ c q^(-ν)` for all integers `p` and `q ≥ 1`.
(With `ν = μ₀ - 1` this says that `μ₀` is an irrationality exponent of
`log₂ 3`.)  It is an explicit hypothesis of the lemma, not an axiom.

The proof is not the paper's (three-distance theorem): take a fraction
`P/Q` close to `α`, in lowest terms; the points `i α`, `i < Q`, are then
close to the points `i P/Q`, which are all the multiples of `1/Q`.
-/

namespace Rosary

open Real

/-- `α` is badly approximable to the order `ν`, with constant `c`. -/
def BadlyApproximable (c ν : ℝ) : Prop :=
  0 < c ∧ ∀ q : ℕ, 1 ≤ q → ∀ p : ℤ, c * (q : ℝ) ^ (-ν) ≤ |q * alpha - p|

/-- **Lemma 9 (covering time of a rotation).**  If `α` is badly
approximable to the order `ν`, then for every `w > 0` some
`J ≤ (4/w)^ν / c + 1` consecutive points of any orbit of the rotation by
`α` meet every arc of length `w`. -/
theorem lemma9 (c ν : ℝ) (hν : 0 < ν) (H : BadlyApproximable c ν)
    (w : ℝ) (hw : 0 < w) :
    ∃ J : ℕ, (J : ℝ) ≤ (4 / w) ^ ν / c + 1 ∧ ∀ θ a : ℝ, ∃ j : ℕ, j < J ∧ ∃ z : ℤ,
      a ≤ θ + j * alpha - z ∧ θ + j * alpha - z ≤ a + w := by
  obtain ⟨hc, H⟩ := H
  have hbig : 0 < (4 / w) ^ ν / c := by positivity
  -- a fraction `P/Q` in lowest terms, with `Q ≤ n` and `|Q α - P| ≤ 1/(n+1)`
  have hn : 0 < ⌈(4 / w) ^ ν / c⌉₊ := Nat.ceil_pos.mpr hbig
  obtain ⟨r, hr, hden⟩ := Real.exists_rat_abs_sub_le_and_den_le alpha hn
  generalize hndef : ⌈(4 / w) ^ ν / c⌉₊ = n at hn hr hden
  have hnle : (4 / w) ^ ν / c ≤ n := by rw [← hndef]; exact Nat.le_ceil _
  have hnlt : (n : ℝ) < (4 / w) ^ ν / c + 1 := by
    rw [← hndef]; exact Nat.ceil_lt_add_one hbig.le
  have hQpos : (0 : ℝ) < r.den := by exact_mod_cast r.den_pos
  have hQn : (r.den : ℝ) ≤ n := by exact_mod_cast hden
  have hn1 : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  -- `δ = Q α - P` is small
  have hδ : |(r.den : ℝ) * alpha - r.num| ≤ 1 / ((n : ℝ) + 1) := by
    have e : (r.den : ℝ) * alpha - r.num = r.den * (alpha - (r : ℝ)) := by
      rw [Rat.cast_def]; field_simp
    rw [e, abs_mul, abs_of_pos hQpos]
    calc (r.den : ℝ) * |alpha - (r : ℝ)| ≤ r.den * (1 / (((n : ℝ) + 1) * r.den)) :=
          mul_le_mul_of_nonneg_left hr hQpos.le
      _ = 1 / ((n : ℝ) + 1) := by field_simp
  -- so `Q` is large: `Q > 4/w`
  have hQbig : 4 / w < r.den := by
    have h1 := H r.den r.den_pos r.num
    have h2 : c * (r.den : ℝ) ^ (-ν) ≤ 1 / ((n : ℝ) + 1) := le_trans h1 hδ
    have hpow : (0 : ℝ) < (r.den : ℝ) ^ ν := Real.rpow_pos_of_pos hQpos ν
    rw [Real.rpow_neg hQpos.le] at h2
    have h3 : c * ((n : ℝ) + 1) ≤ (r.den : ℝ) ^ ν := by
      have := mul_le_mul_of_nonneg_right h2 (mul_pos hpow hn1).le
      field_simp at this
      linarith
    have h4 : (4 / w) ^ ν < (r.den : ℝ) ^ ν := by
      have : (4 / w) ^ ν ≤ c * n := by
        have := mul_le_mul_of_nonneg_left hnle hc.le
        rwa [mul_div_cancel₀ _ hc.ne'] at this
      nlinarith
    exact (Real.rpow_lt_rpow_iff (by positivity) hQpos.le hν).mp h4
  have h4Q : 4 < w * r.den := by
    have := (div_lt_iff₀ hw).mp hQbig
    linarith
  refine ⟨r.den, le_trans hQn hnlt.le, fun θ a => ?_⟩
  -- the multiple `t/Q` of `1/Q` just below the middle of the arc
  obtain ⟨u, v, huv⟩ := Rat.isCoprime_num_den r
  have hQz : (0 : ℤ) < r.den := by exact_mod_cast r.den_pos
  generalize hQdef : (r.den : ℤ) = Q at huv hQz
  have hQr : (r.den : ℝ) = (Q : ℝ) := by rw [← hQdef]; simp
  rw [hQr] at hQpos hQn hδ h4Q
  generalize r.num = P at huv hδ
  let t : ℤ := ⌊(Q : ℝ) * (a + w / 2 - θ)⌋
  have ht1 : (t : ℝ) ≤ Q * (a + w / 2 - θ) := Int.floor_le _
  have ht2 : (Q : ℝ) * (a + w / 2 - θ) < t + 1 := Int.lt_floor_add_one _
  -- `i < Q` with `i P ≡ t (mod Q)`
  have hi0 : 0 ≤ (t * u) % Q := Int.emod_nonneg _ hQz.ne'
  have hi1 : (t * u) % Q < Q := Int.emod_lt_of_pos _ hQz
  have hmod : (t * u) % Q = t * u - Q * ((t * u) / Q) := Int.emod_def _ _
  obtain ⟨i, hi⟩ := Int.eq_ofNat_of_zero_le hi0
  have hiP : (i : ℤ) * P - t = Q * (-(t * v) - (t * u) / Q * P) := by
    rw [← hi, hmod]; linear_combination t * huv
  have hiQ : i < r.den := by
    have : (i : ℤ) < r.den := by rw [hQdef, ← hi]; exact hi1
    exact_mod_cast this
  refine ⟨i, hiQ, -(t * v) - (t * u) / Q * P, ?_⟩
  -- `i α - z = t/Q + i δ / Q`
  have hiPr : (i : ℝ) * P - t = Q * ((-(t * v) - (t * u) / Q * P : ℤ) : ℝ) := by
    exact_mod_cast hiP
  have hiR : (0 : ℝ) ≤ i := by positivity
  have hiQr : (i : ℝ) < Q := by
    have : (i : ℤ) < Q := by rw [← hi]; exact hi1
    exact_mod_cast this
  generalize ((-(t * v) - (t * u) / Q * P : ℤ) : ℝ) = z at hiPr ⊢
  generalize hδdef : (Q : ℝ) * alpha - P = δ at hδ
  have hδ1 : |δ| * ((n : ℝ) + 1) ≤ 1 := by
    have := mul_le_mul_of_nonneg_right hδ hn1.le
    rwa [one_div, inv_mul_cancel₀ hn1.ne'] at this
  have hδQ : |δ| * Q < 1 := by nlinarith [abs_nonneg δ]
  have habs := abs_le.mp (le_refl |δ|)
  -- multiply everything by `Q`
  have key : (Q : ℝ) * (θ + i * alpha - z) = Q * θ + t + i * δ := by
    rw [← hδdef]; linear_combination hiPr
  have hlo : (Q : ℝ) * a ≤ Q * (θ + i * alpha - z) := by
    rw [key]; nlinarith [abs_nonneg δ]
  have hhi : (Q : ℝ) * (θ + i * alpha - z) ≤ Q * (a + w) := by
    rw [key]; nlinarith [abs_nonneg δ]
  exact ⟨le_of_mul_le_mul_left hlo hQpos, le_of_mul_le_mul_left hhi hQpos⟩

end Rosary
