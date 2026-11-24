-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Rates
import Mathlib.Probability.ProductMeasure

/-!
# Infinite stacks: the measure, and the strategies that look at finitely many hats

An infinite stack gives a color to every position `0, 1, 2, ...`.  The
hats are black or white with probability one half each, independently:
this is the product measure on stacks, and its product with itself on
pairs of stacks.  The win rate of a strategy is the measure of the set of
pairs on which both players point at a black hat.

This file shows that a strategy that only looks at the `n` lowest hats
has, on infinite stacks, the win rate it has on stacks of `n` hats.
-/

namespace Hats

open MeasureTheory Finset
open scoped ENNReal

/-- An infinite stack: `true` for a black hat. -/
abbrev Stack := ℕ → Bool

/-- A fair coin. -/
noncomputable def coin : Measure Bool := (2⁻¹ : ℝ≥0∞) • Measure.count

theorem coin_singleton (b : Bool) : coin {b} = 2⁻¹ := by
  simp [coin]

instance : IsProbabilityMeasure coin := by
  constructor
  have : (Set.univ : Set Bool) = {true} ∪ {false} := by ext b; cases b <;> simp
  rw [this, measure_union (by simp) (by simp), coin_singleton, coin_singleton]
  exact ENNReal.inv_two_add_inv_two

/-- The measure on infinite stacks: every hat is black with probability one
half, independently of the others. -/
noncomputable def stackMeasure : Measure Stack := Measure.infinitePi fun _ => coin

instance : IsProbabilityMeasure stackMeasure := by
  unfold stackMeasure; infer_instance

/-- The measure on pairs of infinite stacks. -/
noncomputable def pairMeasure : Measure (Stack × Stack) := stackMeasure.prod stackMeasure

instance : IsProbabilityMeasure pairMeasure := by
  unfold pairMeasure; infer_instance

/-! ### The `n` lowest hats of an infinite stack -/

/-- The `n` lowest hats of an infinite stack, as a stack of `n` hats. -/
def code : ℕ → Stack → ℕ
  | 0, _ => 0
  | n + 1, t => 2 ^ n * (if t n then 1 else 0) + code n t

theorem code_lt (n : ℕ) (t : Stack) : code n t < 2 ^ n := by
  induction n with
  | zero => simp [code]
  | succ n ih =>
    rw [code, pow_succ]
    split_ifs <;> omega

theorem testBit_code (n : ℕ) (t : Stack) (p : ℕ) :
    (code n t).testBit p = (decide (p < n) && t p) := by
  induction n with
  | zero => simp [code]
  | succ n ih =>
    rw [code, Nat.testBit_two_pow_mul_add _ (code_lt n t), ih]
    by_cases h : p < n
    · have : p < n + 1 := by omega
      simp [h, this]
    · by_cases h' : p = n
      · subst h'
        cases t p <;> simp
      · have h1 : ¬ p < n + 1 := by omega
        have h2 : p - n ≠ 0 := by omega
        have h3 : ∀ b : ℕ, b ≤ 1 → b.testBit (p - n) = false := by
          intro b hb
          apply Nat.testBit_lt_two_pow
          calc b < 2 := by omega
            _ = 2 ^ 1 := by norm_num
            _ ≤ 2 ^ (p - n) := Nat.pow_le_pow_right (by norm_num) (by omega)
        simp only [h, h1, decide_false, Bool.false_and]
        split_ifs
        exacts [rfl, h3 1 le_rfl, h3 0 (Nat.zero_le 1)]

/-- The color that a finite strategy's stack shows is the color of the
infinite stack, inside the `n` lowest hats. -/
theorem hat_code {n : ℕ} (t : Stack) {p : ℤ} (hp : 0 ≤ p) (hpn : p < n) :
    hat (code n t) p = if t p.toNat then 1 else 0 := by
  have : p.toNat < n := by omega
  simp [hat, hp, testBit_code, this]

theorem code_eq_iff {n a : ℕ} (ha : a < 2 ^ n) (t : Stack) :
    code n t = a ↔ ∀ i < n, t i = a.testBit i := by
  constructor
  · rintro rfl i hi
    simp [testBit_code, hi]
  · intro h
    apply Nat.eq_of_testBit_eq
    intro p
    rw [testBit_code]
    by_cases hp : p < n
    · simp [hp, h p hp]
    · have : a < 2 ^ p := lt_of_lt_of_le ha (Nat.pow_le_pow_right (by norm_num) (by omega))
      simp [hp, Nat.testBit_lt_two_pow this]

/-- The stacks whose `n` lowest hats are given have measure `1 / 2 ^ n`. -/
theorem measure_code_eq {n a : ℕ} (ha : a < 2 ^ n) :
    stackMeasure {t | code n t = a} = (2⁻¹ : ℝ≥0∞) ^ n := by
  have : {t : Stack | code n t = a} = Set.pi (range n) fun i => {a.testBit i} := by
    ext t
    simp [code_eq_iff ha, Set.mem_pi]
  rw [this, stackMeasure, Measure.infinitePi_pi _ (fun _ _ => measurableSet_singleton _)]
  simp [coin_singleton]

theorem measurableSet_code_eq (n a : ℕ) : MeasurableSet {t : Stack | code n t = a} := by
  by_cases ha : a < 2 ^ n
  · have : {t : Stack | code n t = a} = Set.pi (range n) fun i => {a.testBit i} := by
      ext t
      simp [code_eq_iff ha, Set.mem_pi]
    rw [this]
    exact MeasurableSet.pi (Finset.countable_toSet _) fun _ _ => measurableSet_singleton _
  · have : {t : Stack | code n t = a} = ∅ := by
      ext t
      have := code_lt n t
      simp; omega
    rw [this]; exact MeasurableSet.empty

/-! ### Strategies on infinite stacks -/

/-- The pairs of infinite stacks on which strategy `S` wins: both players
point at a black hat.  The player who wears `x.1` sees `x.2`. -/
def hitSet (S : Stack → ℤ) : Set (Stack × Stack) :=
  {x | (0 ≤ S x.2 ∧ x.1 (S x.2).toNat = true) ∧ (0 ≤ S x.1 ∧ x.2 (S x.1).toNat = true)}

/-- The win rate of a strategy on infinite stacks. -/
noncomputable def rateInf (S : Stack → ℤ) : ℝ := (pairMeasure (hitSet S)).toReal

/-- A strategy on `n` hats, played on infinite stacks by looking at the `n`
lowest hats. -/
def lift (n : ℕ) (s : ℕ → ℤ) : Stack → ℤ := fun t => s (code n t)

theorem mem_hitSet_iff {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) {S : Stack → ℤ} {t u : Stack}
    (ht : S t = s (code n t)) (hu : S u = s (code n u)) :
    (t, u) ∈ hitSet S ↔ pair s (code n t) (code n u) = 1 := by
  have h1 := hs _ (code_lt n t)
  have h2 := hs _ (code_lt n u)
  simp only [hitSet, Set.mem_ofPred_eq, ht, hu, pair, hat_code t h2.1 h2.2, hat_code u h1.1 h1.2]
  by_cases a : t (s (code n u)).toNat = true <;> by_cases b : u (s (code n t)).toNat = true <;>
    simp [a, b, h1.1, h2.1]

/-- The pairs of stacks of `n` hats on which a strategy wins. -/
def hitPairs (n : ℕ) (s : ℕ → ℤ) : Finset (ℕ × ℕ) :=
  (range (2 ^ n) ×ˢ range (2 ^ n)).filter fun ab => pair s ab.1 ab.2 = 1

theorem pair_le_one (s : ℕ → ℤ) (t u : ℕ) : pair s t u ≤ 1 := by
  unfold pair hat; split_ifs <;> simp

theorem card_hitPairs (n : ℕ) (s : ℕ → ℤ) : (hitPairs n s).card = hits n s := by
  unfold hitPairs hits
  rw [card_filter, sum_product]
  refine sum_congr rfl fun t _ => sum_congr rfl fun u _ => ?_
  have := pair_le_one s t u
  split_ifs with h
  · exact h.symm
  · have h' : pair s t u ≠ 1 := h
    omega

/-- **A strategy on `n` hats has the same win rate on infinite stacks.** -/
theorem measure_hitSet_lift {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    pairMeasure (hitSet (lift n s)) = hits n s * ((2⁻¹ : ℝ≥0∞) ^ n * (2⁻¹ : ℝ≥0∞) ^ n) := by
  have hset : hitSet (lift n s) = ⋃ ab ∈ hitPairs n s,
      {t : Stack | code n t = ab.1} ×ˢ {u : Stack | code n u = ab.2} := by
    ext ⟨t, u⟩
    rw [mem_hitSet_iff hs rfl rfl]
    simp only [hitPairs, Set.mem_iUnion, Set.mem_prod, Set.mem_ofPred_eq, mem_filter,
      mem_product, mem_range, exists_prop, Prod.exists]
    constructor
    · intro h
      exact ⟨code n t, code n u, ⟨⟨code_lt n t, code_lt n u⟩, h⟩, rfl, rfl⟩
    · rintro ⟨a, b, ⟨_, h⟩, rfl, rfl⟩
      exact h
  rw [hset, measure_biUnion_finset]
  · have each : ∀ ab ∈ hitPairs n s,
        pairMeasure ({t : Stack | code n t = ab.1} ×ˢ {u : Stack | code n u = ab.2})
          = (2⁻¹ : ℝ≥0∞) ^ n * (2⁻¹ : ℝ≥0∞) ^ n := by
      intro ab hab
      simp only [hitPairs, mem_filter, mem_product, mem_range] at hab
      rw [pairMeasure, Measure.prod_prod, measure_code_eq hab.1.1, measure_code_eq hab.1.2]
    rw [sum_congr rfl each, sum_const, card_hitPairs, nsmul_eq_mul]
  · intro ab _ cd _ hne
    rw [Function.onFun, Set.disjoint_left]
    rintro ⟨t, u⟩ ⟨h1, h2⟩ ⟨h3, h4⟩
    simp only [Set.mem_ofPred_eq] at h1 h2 h3 h4
    exact hne (Prod.ext (h1.symm.trans h3) (h2.symm.trans h4))
  · intro ab _
    exact (measurableSet_code_eq n ab.1).prod (measurableSet_code_eq n ab.2)

theorem rateInf_lift {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) : rateInf (lift n s) = rate n s := by
  unfold rateInf rate
  rw [measure_hitSet_lift hs]
  simp only [ENNReal.toReal_mul, ENNReal.toReal_natCast, ENNReal.toReal_pow,
    ENNReal.toReal_inv, ENNReal.toReal_ofNat]
  rw [← mul_pow, div_eq_mul_inv, ← inv_pow]
  norm_num

end Hats
