-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Equivalent

/-!
# Equivalent strategies: any chain of exchanges of two positions

`Renamed n s s'`: the strategy `s'` is `s` after a chain of exchanges of
two positions, on stacks of `n` hats.  Every renaming of the positions is
such a chain.

* `hits_renamed` (Proposition 2 of the article): equivalent strategies
  have the same hits.
* `ls_renamed`, `rs_renamed`, `ds_renamed`, `lr_renamed_low`,
  `lr_renamed_high`, and the same for `rr` and `dr` (Proposition 7):
  shifts and resets of equivalent strategies are equivalent.
-/

namespace Hats

/-- `s'` is `s` with its positions renamed, on stacks of `n` hats. -/
inductive Renamed (n : ℕ) : (ℕ → ℤ) → (ℕ → ℤ) → Prop
  | refl {s s' : ℕ → ℤ} : (∀ t, t < 2 ^ n → s' t = s t) → Renamed n s s'
  | step {s s' s'' : ℕ → ℤ} (i j : ℕ) (hi : i < n) (hj : j < n) (hij : i ≠ j) :
      Renamed n s s' → (∀ t, t < 2 ^ n → s'' t = swapStrat i j s' t) → Renamed n s s''

/-- **Renaming the positions keeps the hits.** -/
theorem hits_renamed {n : ℕ} {s s' : ℕ → ℤ} (h : Renamed n s s') : hits n s' = hits n s := by
  induction h with
  | refl h => exact hits_congr h
  | step i j hi hj hij _ hag ih =>
    rw [hits_congr hag, hits_swapStrat hi hj hij, ih]

/-- A renaming on `n` hats is one on more hats. -/
theorem Renamed.lift {n : ℕ} {F : (ℕ → ℤ) → ℕ → ℤ} {N : ℕ} (hN : n ≤ N)
    (hcongr : ∀ s s' : ℕ → ℤ, (∀ t, t < 2 ^ n → s' t = s t) → ∀ t, t < 2 ^ N → F s' t = F s t)
    (hswap : ∀ (i j : ℕ), i < n → j < n → i ≠ j → ∀ s : ℕ → ℤ, ∀ t, t < 2 ^ N →
      F (swapStrat i j s) t = swapStrat i j (F s) t)
    {s s' : ℕ → ℤ} (h : Renamed n s s') : Renamed N (F s) (F s') := by
  induction h with
  | refl h => exact Renamed.refl (hcongr _ _ h)
  | step i j hi hj hij _ hag ih =>
    refine Renamed.step i j (by omega) (by omega) hij ih fun t ht => ?_
    rw [hcongr _ _ hag t ht, hswap i j hi hj hij _ t ht]

theorem ls_renamed {n : ℕ} {s s' : ℕ → ℤ} (h : Renamed n s s') :
    Renamed (n + 1) (ls n s) (ls n s') := by
  refine Renamed.lift (F := ls n) (by omega) ?_ ?_ h
  · intro s s' hag t _
    unfold ls
    rw [hag _ (Nat.mod_lt _ (Nat.two_pow_pos n))]
  · intro i j hi hj hij s t _
    rw [ls_swap hi hj hij]

theorem rs_renamed {n : ℕ} {s s' : ℕ → ℤ} (h : Renamed n s s') :
    Renamed (n + 1) (rs n s) (rs n s') := by
  refine Renamed.lift (F := rs n) (by omega) ?_ ?_ h
  · intro s s' hag t _
    unfold rs
    rw [hag _ (Nat.mod_lt _ (Nat.two_pow_pos n))]
  · intro i j hi hj hij s t _
    rw [rs_swap hi hj hij]

theorem ds_renamed {n : ℕ} {s s' : ℕ → ℤ} (h : Renamed n s s') :
    Renamed (n + 2) (ds n s) (ds n s') := by
  refine Renamed.lift (F := ds n) (by omega) ?_ ?_ h
  · intro s s' hag t _
    unfold ds ls rs
    rw [hag _ (Nat.mod_lt _ (Nat.two_pow_pos n))]
  · intro i j hi hj hij s t _
    rw [ds_swap hi hj hij]

section

variable {m n : ℕ} {a a' b : ℕ → ℤ}

theorem lr_renamed_low (hb : Proper n b) (h : Renamed m a a') :
    Renamed (m + n) (lr m a b) (lr m a' b) := by
  refine Renamed.lift (F := fun a => lr m a b) (by omega) ?_ ?_ h
  · intro s s' hag t _
    simp only [lr]
    rw [hag _ (Nat.mod_lt _ (Nat.two_pow_pos m))]
  · intro i j hi hj hij s t ht
    exact lr_swap_low hi hj hij s hb ht

theorem rr_renamed_low (hb : Proper n b) (h : Renamed m a a') :
    Renamed (m + n) (rr m a b) (rr m a' b) := by
  refine Renamed.lift (F := fun a => rr m a b) (by omega) ?_ ?_ h
  · intro s s' hag t _
    simp only [rr]
    rw [hag _ (Nat.mod_lt _ (Nat.two_pow_pos m))]
  · intro i j hi hj hij s t ht
    exact rr_swap_low hi hj hij s hb ht

theorem dr_renamed_low (hb : Proper n b) (h : Renamed m a a') :
    Renamed (m + n) (dr m a b) (dr m a' b) := by
  refine Renamed.lift (F := fun a => dr m a b) (by omega) ?_ ?_ h
  · intro s s' hag t _
    simp only [dr]
    rw [hag _ (Nat.mod_lt _ (Nat.two_pow_pos m))]
  · intro i j hi hj hij s t ht
    exact dr_swap_low hi hj hij s hb ht

/-- The same, when the positions renamed are those of the hats above the
`m` lowest. -/
theorem Renamed.liftAbove {F : (ℕ → ℤ) → ℕ → ℤ}
    (hcongr : ∀ s s' : ℕ → ℤ, (∀ t, t < 2 ^ n → s' t = s t) →
      ∀ t, t < 2 ^ (m + n) → F s' t = F s t)
    (hswap : ∀ (i j : ℕ), i ≠ j → ∀ s : ℕ → ℤ, ∀ t,
      F (swapStrat i j s) t = swapStrat (m + i) (m + j) (F s) t)
    {s s' : ℕ → ℤ} (h : Renamed n s s') : Renamed (m + n) (F s) (F s') := by
  induction h with
  | refl h => exact Renamed.refl (hcongr _ _ h)
  | step i j hi hj hij _ hag ih =>
    refine Renamed.step (m + i) (m + j) (by omega) (by omega) (by omega) ih fun t ht => ?_
    rw [hcongr _ _ hag t ht, hswap i j hij _ t]

omit a' in
theorem div_lt_above {t : ℕ} (ht : t < 2 ^ (m + n)) : t / 2 ^ m < 2 ^ n := by
  rwa [Nat.div_lt_iff_lt_mul (Nat.two_pow_pos m), mul_comm, ← pow_add]

variable {b' : ℕ → ℤ}

theorem lr_renamed_high (ha : Proper m a) (h : Renamed n b b') :
    Renamed (m + n) (lr m a b) (lr m a b') := by
  refine Renamed.liftAbove (F := fun b => lr m a b) ?_ ?_ h
  · intro s s' hag t ht
    simp only [lr]
    rw [hag _ (div_lt_above ht)]
  · intro i j hij s t
    exact lr_swap_high hij ha s t

theorem rr_renamed_high (ha : Proper m a) (h : Renamed n b b') :
    Renamed (m + n) (rr m a b) (rr m a b') := by
  refine Renamed.liftAbove (F := fun b => rr m a b) ?_ ?_ h
  · intro s s' hag t ht
    simp only [rr]
    rw [hag _ (div_lt_above ht)]
  · intro i j hij s t
    exact rr_swap_high hij ha s t

theorem dr_renamed_high (ha : Proper m a) (h : Renamed n b b') :
    Renamed (m + n) (dr m a b) (dr m a b') := by
  refine Renamed.liftAbove (F := fun b => dr m a b) ?_ ?_ h
  · intro s s' hag t ht
    simp only [dr]
    rw [hag _ (div_lt_above ht)]
  · intro i j hij s t
    exact dr_swap_high hij ha s t

end

end Hats
