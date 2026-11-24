-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Families

/-!
# What the strategies of the families do

The families are built by repeating an operation.  Here is what they
choose, stack by stack, and a few remarks of the article on strategies
that agree on the pairs they win.
-/

namespace Hats

open Finset

/-! ### Strategies with the same hits, pair by pair -/

/-- Two strategies on `n` hats are equivalent when they win on the same
pairs of stacks. -/
def Equivalent (n : ℕ) (a b : ℕ → ℤ) : Prop :=
  ∀ t, t < 2 ^ n → ∀ u, u < 2 ^ n → pair a t u = pair b t u

/-- Equivalent strategies have the same hits. -/
theorem Equivalent.hits_eq {n : ℕ} {a b : ℕ → ℤ} (h : Equivalent n a b) :
    hits n a = hits n b := by
  unfold hits
  exact sum_congr rfl fun t ht => sum_congr rfl fun u hu =>
    h t (mem_range.mp ht) u (mem_range.mp hu)

/-- Two strategies that only differ in what they do when they see the
all-white stack are equivalent. -/
theorem equivalent_of_eq_off_white {n : ℕ} {a b : ℕ → ℤ}
    (h : ∀ t, 0 < t → t < 2 ^ n → a t = b t) : Equivalent n a b := by
  intro t ht u hu
  unfold pair
  rcases Nat.eq_zero_or_pos t with rfl | ht0
  · simp [hat_zero]
  rcases Nat.eq_zero_or_pos u with rfl | hu0
  · simp [hat_zero]
  rw [h t ht0 ht, h u hu0 hu]

/-! ### Pointing outside the stack -/

/-- There is no black hat outside the stack. -/
theorem hat_outside {n t : ℕ} (ht : t < 2 ^ n) {p : ℤ} (hp : p < 0 ∨ (n : ℤ) ≤ p) :
    hat t p = 0 := by
  rcases hp with hp | hp
  · simp [hat, hp]
  · have h1 : n ≤ p.toNat := by omega
    have h2 : t < 2 ^ p.toNat := lt_of_lt_of_le ht (Nat.pow_le_pow_right (by norm_num) h1)
    simp [hat, Nat.testBit_lt_two_pow h2]

/-- A strategy that always points at the same place outside the stack
never wins. -/
theorem hits_const_outside {n : ℕ} {p : ℤ} (hp : p < 0 ∨ (n : ℤ) ≤ p) :
    hits n (fun _ => p) = 0 := by
  unfold hits pair
  refine sum_eq_zero fun t ht => sum_eq_zero fun u _ => ?_
  rw [hat_outside (mem_range.mp ht) hp, zero_mul]

/-! ### The top strategy -/

/-- The top strategy on `n` hats, as the article builds it: the one-hat
strategy double-reset `n` times, starting from the strategy on no hat. -/
def top : ℕ → ℕ → ℤ
  | 0 => none
  | n + 1 => dr 1 one (top n)

/-- It always points at the top hat. -/
theorem top_apply (n t : ℕ) : top n t = (n : ℤ) - 1 := by
  induction n generalizing t with
  | zero => simp [top, none]
  | succ n ih =>
    have h : t % 2 = 0 ∨ t % 2 = 1 := by omega
    have h' : t % 2 = 0 ∨ t % 2 = 2 - 1 := h
    simp only [top, dr, pow_one, h', ↓reduceIte, ih]
    push_cast
    ring

/-- The top strategy wins one time in four, on one hat or more. -/
theorem hits_top {n : ℕ} (hn : 1 ≤ n) : hits n (top n) = 4 ^ (n - 1) := by
  have : top n = fun _ => (n : ℤ) - 1 := funext fun t => top_apply n t
  rw [this]
  exact hits_const (by omega) (by omega)

/-! ### Following the lowest black hat -/

theorem lowBlack_succ (n t : ℕ) :
    lowBlack (n + 1) t = if t % 2 = 0 then 1 + lowBlack n (t / 2) else 0 := by
  simp [lowBlack, lr, one]

/-- Seeing a stack with a black hat, `lowBlack` points at the position of
its lowest black hat. -/
theorem lowBlack_spec (n : ℕ) {t : ℕ} (ht : 0 < t) (htn : t < 2 ^ n) :
    ∃ p : ℕ, lowBlack n t = p ∧ t.testBit p = true ∧ ∀ q < p, t.testBit q = false := by
  induction n generalizing t with
  | zero => simp at htn; omega
  | succ n ih =>
    rw [lowBlack_succ]
    by_cases h : t % 2 = 0
    · have h1 : 0 < t / 2 := by omega
      have h2 : t / 2 < 2 ^ n := by rw [pow_succ] at htn; omega
      obtain ⟨p, hp, hb, hq⟩ := ih h1 h2
      refine ⟨p + 1, by simp only [h, ↓reduceIte, hp]; push_cast; ring, ?_, ?_⟩
      · rw [Nat.testBit_succ]; exact hb
      · intro q hq'
        rcases q with _ | q
        · simp [Nat.testBit_zero, h]
        · rw [Nat.testBit_succ]; exact hq q (by omega)
    · refine ⟨0, by simp [h], ?_, fun q hq => absurd hq (Nat.not_lt_zero q)⟩
      have : t % 2 = 1 := by omega
      simp [Nat.testBit_zero, this]

/-- Seeing the all-white stack, it points at the top hat. -/
theorem lowBlack_zero (n : ℕ) : lowBlack n 0 = (n : ℤ) - 1 := by
  induction n with
  | zero => simp [lowBlack, none]
  | succ n ih => rw [lowBlack_succ]; simp [ih]

/-! ### Following the lowest white hat -/

theorem lowWhite_succ (n t : ℕ) :
    lowWhite (n + 2) t = if t % 2 = 1 then 1 + lowWhite (n + 1) (t / 2) else 0 := by
  simp [lowWhite, rr, one]

/-- Seeing a stack with a white hat, `lowWhite` points at the position of
its lowest white hat. -/
theorem lowWhite_spec (n : ℕ) {t : ℕ} (htn : t < 2 ^ (n + 1) - 1) :
    ∃ p : ℕ, p < n + 1 ∧ lowWhite (n + 1) t = p ∧ t.testBit p = false
      ∧ ∀ q < p, t.testBit q = true := by
  induction n generalizing t with
  | zero =>
    have : t = 0 := by simp at htn; omega
    subst this
    exact ⟨0, by omega, by simp [lowWhite, one], by simp, fun q hq => absurd hq (Nat.not_lt_zero q)⟩
  | succ n ih =>
    rw [lowWhite_succ]
    by_cases h : t % 2 = 1
    · have h2 : t / 2 < 2 ^ (n + 1) - 1 := by rw [pow_succ 2 (n + 1)] at htn; omega
      obtain ⟨p, hpn, hp, hb, hq⟩ := ih h2
      refine ⟨p + 1, by omega, by simp only [h, ↓reduceIte, hp]; push_cast; ring, ?_, ?_⟩
      · rw [Nat.testBit_succ]; exact hb
      · intro q hq'
        rcases q with _ | q
        · simp [Nat.testBit_zero, h]
        · rw [Nat.testBit_succ]; exact hq q (by omega)
    · refine ⟨0, by omega, by simp [h], ?_,
        fun q hq => absurd hq (Nat.not_lt_zero q)⟩
      have : t % 2 = 0 := by omega
      simp [Nat.testBit_zero, this]

/-- Seeing the all-black stack, it points at the top hat. -/
theorem lowWhite_ones (n : ℕ) : lowWhite (n + 1) (2 ^ (n + 1) - 1) = (n : ℤ) := by
  induction n with
  | zero => simp [lowWhite, one]
  | succ n ih =>
    have h1 : (2 ^ (n + 1 + 1) - 1) % 2 = 1 := by
      have : 2 ^ (n + 1 + 1) = 2 * 2 ^ (n + 1) := by rw [pow_succ]; ring
      have := Nat.two_pow_pos (n + 1)
      omega
    have h2 : (2 ^ (n + 1 + 1) - 1) / 2 = 2 ^ (n + 1) - 1 := by
      have : 2 ^ (n + 1 + 1) = 2 * 2 ^ (n + 1) := by rw [pow_succ]; ring
      have := Nat.two_pow_pos (n + 1)
      omega
    simp only [lowWhite_succ, h1, ↓reduceIte, h2, ih]
    push_cast
    ring

end Hats
