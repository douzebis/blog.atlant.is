-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Examples
import Hats.Describe

/-!
# The best strategies on one and two hats

No strategy does better than 1 hit out of 4 on one hat, and than 5 hits
out of 16 on two hats: the Carter strategies are optimal there.  For
three, four and five hats the article relies on searches by computer,
which are not redone here.
-/

namespace Hats

open Finset

theorem hat_le_one (t : ℕ) (p : ℤ) : hat t p ≤ 1 := by
  unfold hat; split_ifs <;> omega

/-- On one hat, no strategy has more than one hit. -/
theorem hits_one_le (s : ℕ → ℤ) : hits 1 s ≤ 1 := by
  have h := hat_le_one 1 (s 1)
  have : hits 1 s = hat 1 (s 1) * hat 1 (s 1) := by
    simp [hits, pair, sum_range_succ, hat_zero]
  rw [this]
  nlinarith

/-- What matters in a choice on two hats: position `0`, position `1`, or
elsewhere. -/
def clamp2 (p : ℤ) : ℤ := if p = 0 then 0 else if p = 1 then 1 else -1

theorem hat_clamp2 {t : ℕ} (ht : t < 2 ^ 2) (p : ℤ) : hat t (clamp2 p) = hat t p := by
  unfold clamp2
  by_cases h0 : p = 0
  · simp [h0]
  by_cases h1 : p = 1
  · simp [h1]
  simp only [h0, h1, ↓reduceIte]
  rw [hat_outside ht (Or.inl (by norm_num)), hat_outside ht (by push_cast; omega)]

/-- **On two hats, no strategy has more than 5 hits.** -/
theorem hits_two_le (s : ℕ → ℤ) : hits 2 s ≤ 5 := by
  have key : hits 2 s
      = hits 2 (ofList [clamp2 (s 0), clamp2 (s 1), clamp2 (s 2), clamp2 (s 3)]) := by
    unfold hits pair
    refine sum_congr rfl fun t ht => sum_congr rfl fun u hu => ?_
    have ht' := mem_range.mp ht
    have hu' := mem_range.mp hu
    have e : ∀ v, v < 2 ^ 2 →
        ofList [clamp2 (s 0), clamp2 (s 1), clamp2 (s 2), clamp2 (s 3)] v = clamp2 (s v) := by
      intro v hv
      have : v < 4 := hv
      interval_cases v <;> rfl
    rw [e t ht', e u hu', hat_clamp2 ht', hat_clamp2 hu']
  have fin : ∀ a ∈ ({-1, 0, 1} : Finset ℤ), ∀ b ∈ ({-1, 0, 1} : Finset ℤ),
      ∀ c ∈ ({-1, 0, 1} : Finset ℤ), ∀ d ∈ ({-1, 0, 1} : Finset ℤ),
        hits 2 (ofList [a, b, c, d]) ≤ 5 := by decide
  have mem : ∀ p : ℤ, clamp2 p ∈ ({-1, 0, 1} : Finset ℤ) := by
    intro p; unfold clamp2; split_ifs <;> simp
  rw [key]
  exact fin _ (mem _) _ (mem _) _ (mem _) _ (mem _)

/-! ### Counting the strategies of a search (second article) -/

/-- The crushed strategies on four hats, the choices for the all-white and
the all-black stacks left out: 2 choices for stack 1, 3 for stack 2, 4 for
each of the 12 others. -/
example : 2 * 3 * 4 ^ 12 = 100663296 := by norm_num

/-- The same on five hats: 2, 3 and 4 choices for stacks 1, 2 and 3, then
5 for each of the 27 others. -/
example : 2 * 3 * 4 * 5 ^ 27 = 178813934326171875000 := by norm_num

end Hats
