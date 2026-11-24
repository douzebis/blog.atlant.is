-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Crush
import Hats.Shift

/-!
# The search for the best strategy, with its reductions

The second article describes a search for the strategies with the most
hits.  It does not try all strategies: it leaves aside the choices for the
all-white and the all-black stacks, which do not matter, and only tries
*crushed* strategies, which point at a position at most `t` when they see
stack number `t`.

Here the search is a Lean function, `best n`, and a theorem says that it
is right: no strategy on `n` hats has more hits than `best n`, and one has
exactly that many.
-/

namespace Hats

open Finset

/-! ### The reductions -/

/-- A strategy made proper: where it pointed outside the stack, it points
at the bottom hat. -/
def clampProper (n : ℕ) (s : ℕ → ℤ) : ℕ → ℤ := fun t =>
  if 0 ≤ s t ∧ s t < n then s t else 0

theorem clampProper_proper {n : ℕ} (hn : 1 ≤ n) (s : ℕ → ℤ) : Proper n (clampProper n s) := by
  intro t _
  unfold clampProper
  split_ifs with h
  · exact h
  · constructor <;> omega

/-- Pointing inside the stack instead of outside can only add hits. -/
theorem hits_le_clampProper (n : ℕ) (s : ℕ → ℤ) : hits n s ≤ hits n (clampProper n s) := by
  unfold hits pair
  refine sum_le_sum fun t ht => sum_le_sum fun u hu => ?_
  have key : ∀ v w, v < 2 ^ n → hat v (s w) ≤ hat v (clampProper n s w) := by
    intro v w hv
    unfold clampProper
    split_ifs with h
    · exact le_rfl
    · rw [hat_outside hv (by omega)]
      exact Nat.zero_le _
  exact Nat.mul_le_mul (key t u (mem_range.mp ht)) (key u t (mem_range.mp hu))

/-- A strategy with its choices for the all-white and the all-black stacks
replaced by the bottom hat. -/
def normalize (n : ℕ) (s : ℕ → ℤ) : ℕ → ℤ := fun t =>
  if t = 0 ∨ t = 2 ^ n - 1 then 0 else s t

theorem normalize_proper {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) : Proper n (normalize n s) := by
  intro t ht
  unfold normalize
  split_ifs
  · have := hs.pos; constructor <;> omega
  · exact hs t ht

/-- These two choices do not change the hits of a proper strategy. -/
theorem hits_normalize {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    hits n (normalize n s) = hits n s := by
  let s1 : ℕ → ℤ := fun t => if t = 2 ^ n - 1 then 0 else s t
  have p1 : Proper n s1 := by
    intro t ht
    simp only [s1]
    split_ifs
    · have := hs.pos; constructor <;> omega
    · exact hs t ht
  have e1 : hits n (normalize n s) = hits n s1 := by
    refine hits_congr_white fun t ht0 _ => ?_
    have : t ≠ 0 := by omega
    simp [normalize, s1, this]
  have e2 : hits n s1 = hits n s := by
    refine hits_congr_black p1 hs fun t ht => ?_
    have : t ≠ 2 ^ n - 1 := by omega
    simp [s1, this]
  rw [e1, e2]

/-! ### The strategies that the search tries -/

/-- The choices allowed for stack number `t`: a position at most `t`, and
inside the stack. -/
def choices (n t : ℕ) : List ℕ := List.range (min t (n - 1) + 1)

/-- All the ways of choosing for the `k` stacks from number `t` on. -/
def enum (n : ℕ) : ℕ → ℕ → List (List ℕ)
  | 0, _ => [[]]
  | k + 1, t => (choices n t).flatMap fun p => (enum n k (t + 1)).map (p :: ·)

/-- The strategy with the listed choices for stacks `1`, `2`, ..., and the
bottom hat for the all-white and the all-black stacks. -/
def ofChoices (c : List ℕ) : ℕ → ℤ := fun t => ((0 :: c).getD t 0 : ℕ)

theorem ofChoices_zero (c : List ℕ) : ofChoices c 0 = 0 := by
  simp [ofChoices]

theorem ofChoices_succ (c : List ℕ) (i : ℕ) : ofChoices c (i + 1) = (c.getD i 0 : ℕ) := by
  simp [ofChoices]

theorem getD_map_range (k : ℕ) (f : ℕ → ℕ) (i : ℕ) :
    ((List.range k).map f).getD i 0 = if i < k then f i else 0 := by
  by_cases h : i < k
  · simp [h, List.getD_eq_getElem?_getD]
  · simp [h, List.getD_eq_getElem?_getD]

theorem mem_enum {n : ℕ} (k t : ℕ) (c : List ℕ) :
    c ∈ enum n k t ↔ c.length = k ∧ ∀ i < k, c.getD i 0 ≤ min (t + i) (n - 1) := by
  induction k generalizing t c with
  | zero =>
    simp only [enum, List.mem_singleton]
    constructor
    · rintro rfl; exact ⟨rfl, fun i hi => absurd hi (Nat.not_lt_zero i)⟩
    · rintro ⟨h, -⟩; exact List.length_eq_zero_iff.mp h
  | succ k ih =>
    simp only [enum, choices, List.mem_flatMap, List.mem_range, List.mem_map]
    constructor
    · rintro ⟨p, hp, c', hc', rfl⟩
      obtain ⟨hl, hb⟩ := (ih (t + 1) c').mp hc'
      refine ⟨by simp [hl], fun i hi => ?_⟩
      rcases i with _ | i
      · simpa using Nat.lt_succ_iff.mp hp
      · have := hb i (by omega)
        simpa [show t + 1 + i = t + (i + 1) by ring] using this
    · rintro ⟨hl, hb⟩
      rcases c with _ | ⟨p, c'⟩
      · simp at hl
      · refine ⟨p, ?_, c', (ih (t + 1) c').mpr ⟨by simpa using hl, fun i hi => ?_⟩, rfl⟩
        · have := hb 0 (Nat.succ_pos k)
          simpa using Nat.lt_succ_iff.mpr this
        · have := hb (i + 1) (by omega)
          simpa [show t + 1 + i = t + (i + 1) by ring] using this

/-- **The search**: the most hits among the strategies that it tries. -/
def best (n : ℕ) : ℕ :=
  ((enum n (2 ^ n - 2) 1).map fun c => hits n (ofChoices c)).foldr max 0

theorem le_foldr_max {l : List ℕ} {x : ℕ} (h : x ∈ l) : x ≤ l.foldr max 0 := by
  induction l with
  | nil => simp at h
  | cons a l ih =>
    rcases List.mem_cons.mp h with rfl | h'
    · exact le_max_left _ _
    · exact (ih h').trans (le_max_right _ _)

theorem foldr_max_mem {l : List ℕ} (h : l ≠ []) : l.foldr max 0 ∈ l := by
  induction l with
  | nil => exact absurd rfl h
  | cons a l ih =>
    by_cases hl : l = []
    · subst hl; simp
    · have := ih hl
      rcases max_choice a (l.foldr max 0) with e | e
      · rw [List.foldr_cons, e]; exact List.mem_cons_self
      · rw [List.foldr_cons, e]; exact List.mem_cons_of_mem _ this

/-- **The search is right, from above**: no strategy on `n` hats has more
hits than `best n`. -/
theorem hits_le_best {n : ℕ} (hn : 1 ≤ n) (s : ℕ → ℤ) : hits n s ≤ best n := by
  -- make it proper, crush it, forget the two choices that do not matter
  obtain ⟨s2, p2, h2, c2⟩ := exists_crushed (clampProper_proper hn s)
  have p3 := normalize_proper p2
  have h3 := hits_normalize p2
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  -- its choices, as a list
  let c : List ℕ := (List.range (2 ^ n - 2)).map fun i => (normalize n s2 (i + 1)).toNat
  have hc : c ∈ enum n (2 ^ n - 2) 1 := by
    rw [mem_enum]
    refine ⟨by simp [c], fun i hi => ?_⟩
    have hi' : i + 1 < 2 ^ n := by omega
    have hne : ¬ (i + 1 = 0 ∨ i + 1 = 2 ^ n - 1) := by omega
    have hb := p2 (i + 1) hi'
    have hcr := c2 (i + 1) hi'
    simp only [c, getD_map_range, hi, ↓reduceIte, normalize, hne]
    rw [Nat.le_min]
    constructor <;> omega
  have hagree : ∀ t, t < 2 ^ n → normalize n s2 t = ofChoices c t := by
    intro t ht
    rcases Nat.eq_zero_or_pos t with rfl | h0
    · simp [normalize, ofChoices_zero]
    · obtain ⟨i, rfl⟩ : ∃ i, t = i + 1 := ⟨t - 1, by omega⟩
      rw [ofChoices_succ]
      simp only [c, getD_map_range]
      by_cases hlast : i + 1 = 2 ^ n - 1
      · have : ¬ i < 2 ^ n - 2 := by omega
        simp [normalize, hlast, this]
      · have hi : i < 2 ^ n - 2 := by omega
        have hb := p3 (i + 1) ht
        simp only [hi, ↓reduceIte]
        omega
  calc hits n s ≤ hits n (clampProper n s) := hits_le_clampProper n s
    _ = hits n s2 := h2.symm
    _ = hits n (normalize n s2) := h3.symm
    _ = hits n (ofChoices c) := hits_congr hagree
    _ ≤ best n := le_foldr_max (List.mem_map.mpr ⟨c, hc, rfl⟩)

/-- **The search is right, from below**: a strategy has `best n` hits. -/
theorem exists_hits_eq_best (n : ℕ) : ∃ s : ℕ → ℤ, hits n s = best n := by
  have hne : ((enum n (2 ^ n - 2) 1).map fun c => hits n (ofChoices c)) ≠ [] := by
    have : ∀ k t, enum n k t ≠ [] := by
      intro k
      induction k with
      | zero => intro t; simp [enum]
      | succ k ih =>
        intro t
        obtain ⟨c, hc⟩ := List.exists_mem_of_ne_nil _ (ih (t + 1))
        refine List.ne_nil_of_mem (a := 0 :: c) ?_
        simp only [enum, choices, List.mem_flatMap, List.mem_range, List.mem_map]
        exact ⟨0, Nat.succ_pos _, c, hc, rfl⟩
    simpa using this _ _
  obtain ⟨c, -, hc⟩ := List.mem_map.mp (foldr_max_mem hne)
  exact ⟨ofChoices c, hc⟩

end Hats
