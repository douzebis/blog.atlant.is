-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Reset
import Hats.Reset2

/-!
# The left shift and the right shift

A shift adds one hat on top and changes the choice for one stack, which
now points at the new hat:

* the left shift, for the stack whose only black hat is the new one;
* the right shift, for the stack whose only white hat is the new one.
-/

namespace Hats

open Finset

/-- The strategy on one hat that points at it. -/
def one : ℕ → ℤ := fun _ => 0

theorem one_proper : Proper 1 one := fun _ _ => by simp [one]

theorem hits_one : hits 1 one = 1 := by decide

/-- `s` (a strategy on `n` hats) left-shifted. -/
def ls (n : ℕ) (s : ℕ → ℤ) : ℕ → ℤ := fun t => if t = 2 ^ n then n else s (t % 2 ^ n)

/-- `s` (a strategy on `n` hats) right-shifted. -/
def rs (n : ℕ) (s : ℕ → ℤ) : ℕ → ℤ := fun t => if t = 2 ^ n - 1 then n else s (t % 2 ^ n)

/-- Two strategies that only differ in what they do when they see the
all-white stack have the same hits: the player who wears that stack has no
black hat to point at. -/
theorem hits_congr_white {n : ℕ} {s s' : ℕ → ℤ} (h : ∀ t, 0 < t → t < 2 ^ n → s t = s' t) :
    hits n s = hits n s' := by
  unfold hits pair
  refine sum_congr rfl fun t ht => sum_congr rfl fun u hu => ?_
  rcases Nat.eq_zero_or_pos t with rfl | ht0
  · simp [hat_zero]
  rcases Nat.eq_zero_or_pos u with rfl | hu0
  · simp [hat_zero]
  rw [h t ht0 (mem_range.mp ht), h u hu0 (mem_range.mp hu)]

/-- Two proper strategies that only differ in what they do when they see
the all-black stack have the same hits. -/
theorem hits_congr_black {n : ℕ} {s s' : ℕ → ℤ} (hs : Proper n s) (hs' : Proper n s')
    (h : ∀ t, t < 2 ^ n - 1 → s t = s' t) : hits n s = hits n s' := by
  rw [hits_peel hs, hits_peel hs']
  congr 1
  refine sum_congr rfl fun t ht => sum_congr rfl fun u hu => ?_
  unfold pair
  rw [h t (mem_range.mp ht), h u (mem_range.mp hu)]

/-- **Win rate after a left shift**, as a count of hits: the left shift of
a proper strategy on `n` hats has `4 * hits s + 1` hits. -/
theorem hits_ls {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    hits (n + 1) (ls n s) = 4 * hits n s + 1 := by
  have key : hits (n + 1) (ls n s) = hits (n + 1) (lr n s one) := by
    refine hits_congr_white fun t ht0 ht => ?_
    have hpos : 0 < 2 ^ n := Nat.two_pow_pos n
    have ht' : t < 2 ^ n * 2 := by rw [pow_succ] at ht; exact ht
    by_cases h : t = 2 ^ n
    · subst h; simp [ls, lr, one]
    · have : t % 2 ^ n ≠ 0 := by
        intro h0
        obtain ⟨q, hq⟩ := Nat.dvd_of_mod_eq_zero h0
        have hq2 : q < 2 := by
          by_contra hq2
          have : 2 ^ n * 2 ≤ 2 ^ n * q := Nat.mul_le_mul_left _ (by omega)
          omega
        interval_cases q <;> simp_all
      simp [ls, lr, h, this]
  rw [key, hits_lr 1 one hs, hits_one]
  norm_num

/-- **Win rate after a right shift**, as a count of hits: the right shift
of a proper strategy on `n` hats has `4 * hits s + 1` hits. -/
theorem hits_rs {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    hits (n + 1) (rs n s) = 4 * hits n s + 1 := by
  have hpos : 0 < 2 ^ n := Nat.two_pow_pos n
  have hmod : ∀ t, 0 ≤ s (t % 2 ^ n) ∧ s (t % 2 ^ n) < n := fun t => hs _ (Nat.mod_lt _ hpos)
  have p1 : Proper (n + 1) (rs n s) := by
    intro t _
    unfold rs
    split_ifs
    · constructor <;> push_cast <;> omega
    · have := hmod t; constructor <;> push_cast <;> omega
  have p2 : Proper (n + 1) (rr n s one) := by
    intro t _
    unfold rr one
    split_ifs
    · constructor <;> push_cast <;> omega
    · have := hmod t; constructor <;> push_cast <;> omega
  have key : hits (n + 1) (rs n s) = hits (n + 1) (rr n s one) := by
    refine hits_congr_black p1 p2 fun t ht => ?_
    have ht' : t < 2 ^ n * 2 - 1 := by rw [pow_succ] at ht; exact ht
    by_cases h : t = 2 ^ n - 1
    · subst h
      simp [rs, rr, one, Nat.mod_eq_of_lt (Nat.sub_lt hpos one_pos)]
    · have : t % 2 ^ n ≠ 2 ^ n - 1 := by
        intro h0
        rcases Nat.lt_or_ge t (2 ^ n) with hlt | hge
        · rw [Nat.mod_eq_of_lt hlt] at h0; exact h h0
        · have : t % 2 ^ n = t - 2 ^ n := by
            rw [Nat.mod_eq_sub_mod hge, Nat.mod_eq_of_lt (by omega)]
          omega
      simp [rs, rr, h, this]
  rw [key, hits_rr hs one_proper, hits_one]
  norm_num

end Hats
