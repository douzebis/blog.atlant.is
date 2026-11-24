-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Infinite

/-!
# The win rate of a limit of finite strategies

If a strategy on infinite stacks agrees with a finite strategy except on
the stacks whose lowest hats fall in a small set, their win rates are
close.  If it is so approached by a sequence of finite strategies, its win
rate is the limit of theirs.
-/

namespace Hats

open MeasureTheory Finset Filter Topology
open scoped ENNReal

/-- The stacks whose `n` lowest hats fall in a set of `c` stacks of `n`
hats have measure at most `c / 2 ^ n`. -/
theorem measure_code_mem_le (n : ℕ) (A : Finset ℕ) :
    stackMeasure {t | code n t ∈ A} ≤ A.card * (2⁻¹ : ℝ≥0∞) ^ n := by
  have hset : {t : Stack | code n t ∈ A} = ⋃ a ∈ A, {t : Stack | code n t = a} := by
    ext t; simp
  rw [hset]
  refine (measure_biUnion_finset_le A _).trans ?_
  rw [← nsmul_eq_mul, ← sum_const]
  refine sum_le_sum fun a _ => ?_
  by_cases ha : a < 2 ^ n
  · rw [measure_code_eq ha]
  · have : {t : Stack | code n t = a} = ∅ := by
      ext t
      have := code_lt n t
      simp; omega
    rw [this]; simp

/-- Two strategies on infinite stacks that agree outside a set of stacks
`E`: their hit sets differ at most by the pairs with a stack in `E`. -/
theorem hitSet_subset_of_agree {S S' : Stack → ℤ} {E : Set Stack}
    (h : ∀ t, t ∉ E → S t = S' t) :
    hitSet S ⊆ hitSet S' ∪ (E ×ˢ Set.univ ∪ Set.univ ×ˢ E) := by
  rintro ⟨t, u⟩ hx
  by_cases ht : t ∈ E
  · exact Or.inr (Or.inl ⟨ht, trivial⟩)
  by_cases hu : u ∈ E
  · exact Or.inr (Or.inr ⟨trivial, hu⟩)
  left
  simp only [hitSet, Set.mem_ofPred_eq] at hx ⊢
  rw [← h t ht, ← h u hu]
  exact hx

theorem measure_bad_le (E : Set Stack) :
    pairMeasure (E ×ˢ Set.univ ∪ Set.univ ×ˢ E) ≤ 2 * stackMeasure E := by
  refine (measure_union_le _ _).trans ?_
  rw [pairMeasure, Measure.prod_prod, Measure.prod_prod, measure_univ, mul_one, one_mul, two_mul]

/-- **Close strategies have close win rates**: if `S` agrees with the
strategy `s` on `n` hats except on the stacks whose `n` lowest hats fall
in `A`, their win rates differ by at most `2 * card A / 2 ^ n`. -/
theorem abs_rateInf_sub_rate_le {S : Stack → ℤ} {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s)
    (A : Finset ℕ) (h : ∀ t, code n t ∉ A → S t = s (code n t)) :
    |rateInf S - rate n s| ≤ 2 * (A.card / 2 ^ n) := by
  set E : Set Stack := {t | code n t ∈ A} with hE
  have hagree : ∀ t, t ∉ E → S t = lift n s t := fun t ht => h t ht
  have hagree' : ∀ t, t ∉ E → lift n s t = S t := fun t ht => (h t ht).symm
  have hbad : pairMeasure (E ×ˢ Set.univ ∪ Set.univ ×ˢ E) ≤ 2 * (A.card * (2⁻¹ : ℝ≥0∞) ^ n) :=
    (measure_bad_le E).trans (by gcongr; exact measure_code_mem_le n A)
  have hfin : 2 * ((A.card : ℝ≥0∞) * (2⁻¹ : ℝ≥0∞) ^ n) ≠ ∞ := by
    refine ENNReal.mul_ne_top (by norm_num) (ENNReal.mul_ne_top (by simp) ?_)
    exact ENNReal.pow_ne_top (by norm_num)
  have hreal : (2 * ((A.card : ℝ≥0∞) * (2⁻¹ : ℝ≥0∞) ^ n)).toReal = 2 * (A.card / 2 ^ n) := by
    simp only [ENNReal.toReal_mul, ENNReal.toReal_natCast, ENNReal.toReal_pow,
      ENNReal.toReal_inv, ENNReal.toReal_ofNat]
    rw [div_eq_mul_inv, ← inv_pow]
  have le1 : pairMeasure (hitSet S)
      ≤ pairMeasure (hitSet (lift n s)) + 2 * (A.card * (2⁻¹ : ℝ≥0∞) ^ n) :=
    (measure_mono (hitSet_subset_of_agree hagree)).trans
      ((measure_union_le _ _).trans (add_le_add le_rfl hbad))
  have le2 : pairMeasure (hitSet (lift n s))
      ≤ pairMeasure (hitSet S) + 2 * (A.card * (2⁻¹ : ℝ≥0∞) ^ n) :=
    (measure_mono (hitSet_subset_of_agree hagree')).trans
      ((measure_union_le _ _).trans (add_le_add le_rfl hbad))
  have r1 := ENNReal.toReal_mono (ENNReal.add_ne_top.mpr ⟨measure_ne_top _ _, hfin⟩) le1
  have r2 := ENNReal.toReal_mono (ENNReal.add_ne_top.mpr ⟨measure_ne_top _ _, hfin⟩) le2
  rw [ENNReal.toReal_add (measure_ne_top _ _) hfin, hreal] at r1 r2
  have e : (pairMeasure (hitSet (lift n s))).toReal = rate n s := rateInf_lift hs
  rw [e] at r1 r2
  unfold rateInf
  rw [abs_le]
  constructor <;> linarith

/-- **The win rate of a limit strategy.**  Let `S` be a strategy on
infinite stacks and, for every `k`, `s k` a proper strategy on `n k` hats
that `S` agrees with, except on the stacks whose `n k` lowest hats fall in
`A k`.  If the proportion of `A k` among the stacks of `n k` hats tends to
`0` and the win rate of `s k` tends to `L`, the win rate of `S` is `L`. -/
theorem rateInf_eq_of_tendsto {S : Stack → ℤ} {L : ℝ} (n : ℕ → ℕ) (s : ℕ → ℕ → ℤ)
    (A : ℕ → Finset ℕ) (hs : ∀ k, Proper (n k) (s k))
    (h : ∀ k t, code (n k) t ∉ A k → S t = s k (code (n k) t))
    (hA : Tendsto (fun k => ((A k).card : ℝ) / 2 ^ n k) atTop (𝓝 0))
    (hL : Tendsto (fun k => rate (n k) (s k)) atTop (𝓝 L)) : rateInf S = L := by
  have hbound : ∀ k, |rateInf S - rate (n k) (s k)| ≤ 2 * ((A k).card / 2 ^ n k) :=
    fun k => abs_rateInf_sub_rate_le (hs k) (A k) (h k)
  have h0 : Tendsto (fun k => 2 * (((A k).card : ℝ) / 2 ^ n k)) atTop (𝓝 0) := by
    simpa using hA.const_mul 2
  have hx : Tendsto (fun k => rate (n k) (s k)) atTop (𝓝 (rateInf S)) := by
    rw [tendsto_iff_dist_tendsto_zero]
    refine squeeze_zero (fun _ => dist_nonneg) (fun k => ?_) h0
    rw [Real.dist_eq, abs_sub_comm]
    exact hbound k
  exact tendsto_nhds_unique hx hL

end Hats
