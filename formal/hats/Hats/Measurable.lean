-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.LimitStrategies

/-!
# The hit sets are measurable

The win rate of a strategy on infinite stacks is the measure of its hit
set.  For a measurable strategy the hit set is measurable; strategies that
look at finitely many hats, and limits of such strategies, are measurable.
-/

namespace Hats

open MeasureTheory

/-- The `n` lowest hats depend measurably on the stack. -/
theorem measurable_code (n : ℕ) : Measurable (code n) :=
  measurable_to_countable' fun a => measurableSet_code_eq n a

/-- A strategy that looks at finitely many hats is measurable. -/
theorem measurable_lift (n : ℕ) (s : ℕ → ℤ) : Measurable (lift n s) :=
  (measurable_from_top (f := s)).comp (measurable_code n)

/-- The limit of a sequence of finite strategies is measurable. -/
theorem measurable_limitOf (n : ℕ → ℕ) (s : ℕ → ℕ → ℤ) (A : ℕ → Finset ℕ) :
    Measurable (limitOf n s A) := by
  classical
  refine measurable_to_countable' fun z => ?_
  have hD : ∀ k, MeasurableSet {t : Stack | code (n k) t ∈ A k} := fun k =>
    measurable_code (n k) (A k).measurableSet
  have hF : ∀ k, MeasurableSet {t : Stack | s k (code (n k) t) = z} := fun k =>
    (measurable_lift (n k) (s k)) (measurableSet_singleton z)
  have hset : limitOf n s A ⁻¹' {z}
      = (⋃ k, ({t : Stack | code (n k) t ∈ A k}ᶜ ∩ ⋂ j ∈ Finset.range k,
            {t : Stack | code (n j) t ∈ A j}) ∩ {t : Stack | s k (code (n k) t) = z})
        ∪ ((⋂ k, {t : Stack | code (n k) t ∈ A k}) ∩ {_t : Stack | z = -1}) := by
    ext t
    simp only [Set.mem_preimage, Set.mem_singleton_iff, Set.mem_union, Set.mem_iUnion,
      Set.mem_inter_iff, Set.mem_compl_iff, Set.mem_ofPred_eq, Set.mem_iInter,
      Finset.mem_range]
    by_cases h : ∃ k, code (n k) t ∉ A k
    · have e : limitOf n s A t = s (Nat.find h) (code (n (Nat.find h)) t) := by
        simp only [limitOf, h, ↓reduceDIte]
      rw [e]
      constructor
      · intro hz
        exact Or.inl ⟨Nat.find h, ⟨Nat.find_spec h, fun j hj => by
          simpa using Nat.find_min h hj⟩, hz⟩
      · rintro (⟨k, ⟨hk, hlt⟩, hz⟩ | ⟨hall, -⟩)
        · have : Nat.find h = k := by
            rw [Nat.find_eq_iff]
            exact ⟨hk, fun j hj => by simpa using hlt j hj⟩
          rw [this]; exact hz
        · obtain ⟨k, hk⟩ := h
          exact absurd (hall k) hk
    · have e : limitOf n s A t = -1 := by
        simp only [limitOf, h, ↓reduceDIte]
      rw [e]
      push Not at h
      constructor
      · intro hz
        exact Or.inr ⟨h, hz.symm⟩
      · rintro (⟨k, ⟨hk, -⟩, -⟩ | ⟨-, hz⟩)
        · exact absurd (h k) hk
        · exact hz.symm
  rw [hset]
  refine MeasurableSet.union (MeasurableSet.iUnion fun k => ?_) ?_
  · exact (((hD k).compl).inter
      (MeasurableSet.biInter (Finset.countable_toSet _) fun j _ => hD j)).inter (hF k)
  · exact (MeasurableSet.iInter hD).inter (MeasurableSet.const _)

/-- The stacks with a black hat at position `p`. -/
theorem measurableSet_black (p : ℤ) : MeasurableSet {t : Stack | 0 ≤ p ∧ t p.toNat = true} := by
  by_cases hp : 0 ≤ p
  · have : {t : Stack | 0 ≤ p ∧ t p.toNat = true} = (fun t : Stack => t p.toNat) ⁻¹' {true} := by
      ext t; simp [hp]
    rw [this]
    exact (measurable_pi_apply _) (measurableSet_singleton true)
  · have : {t : Stack | 0 ≤ p ∧ t p.toNat = true} = ∅ := by
      ext t; simp [hp]
    rw [this]; exact MeasurableSet.empty

/-- **The hit set of a measurable strategy is measurable.** -/
theorem measurableSet_hitSet {S : Stack → ℤ} (hS : Measurable S) :
    MeasurableSet (hitSet S) := by
  have half : ∀ (f g : Stack × Stack → Stack), Measurable f → Measurable g →
      MeasurableSet {x : Stack × Stack | 0 ≤ S (g x) ∧ f x (S (g x)).toNat = true} := by
    intro f g hf hg
    have : {x : Stack × Stack | 0 ≤ S (g x) ∧ f x (S (g x)).toNat = true}
        = ⋃ p : ℤ, (g ⁻¹' (S ⁻¹' {p})) ∩ f ⁻¹' {t : Stack | 0 ≤ p ∧ t p.toNat = true} := by
      ext x
      simp only [Set.mem_ofPred_eq, Set.mem_iUnion, Set.mem_inter_iff, Set.mem_preimage,
        Set.mem_singleton_iff]
      constructor
      · intro h; exact ⟨S (g x), rfl, h⟩
      · rintro ⟨p, rfl, h⟩; exact h
    rw [this]
    exact MeasurableSet.iUnion fun p =>
      (hg (hS (measurableSet_singleton p))).inter (hf (measurableSet_black p))
  have : hitSet S = {x : Stack × Stack | 0 ≤ S x.2 ∧ x.1 (S x.2).toNat = true}
      ∩ {x : Stack × Stack | 0 ≤ S x.1 ∧ x.2 (S x.1).toNat = true} := by
    ext x; simp [hitSet]
  rw [this]
  exact (half Prod.fst Prod.snd measurable_fst measurable_snd).inter
    (half Prod.snd Prod.fst measurable_snd measurable_fst)

/-- The hit sets of the three limit strategies are measurable. -/
theorem measurableSet_hitSet_lowBlackInf : MeasurableSet (hitSet lowBlackInf) :=
  measurableSet_hitSet (measurable_limitOf _ _ _)

theorem measurableSet_hitSet_carterInf : MeasurableSet (hitSet carterInf) :=
  measurableSet_hitSet (measurable_limitOf _ _ _)

theorem measurableSet_hitSet_reyesInf : MeasurableSet (hitSet reyesInf) :=
  measurableSet_hitSet (measurable_limitOf _ _ _)

end Hats
