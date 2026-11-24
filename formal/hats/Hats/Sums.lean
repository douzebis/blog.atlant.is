-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Basic

/-!
# Sums over stacks: small tools

The stack of `m` black hats is the last one, `2 ^ m - 1`.  These lemmas
set it apart in a sum over all stacks of `m` hats, and count what a block
of hats above contributes.
-/

namespace Hats

open Finset

/-- A sum over the stacks of `m` hats: the all-black stack apart. -/
theorem sum_peel {M : Type*} [AddCommMonoid M] (m : ℕ) (f : ℕ → M) :
    ∑ t ∈ range (2 ^ m), f t = ∑ t ∈ range (2 ^ m - 1), f t + f (2 ^ m - 1) := by
  rw [show range (2 ^ m) = range (2 ^ m - 1 + 1) by
    rw [Nat.sub_add_cancel Nat.one_le_two_pow], sum_range_succ]

/-- A sum over the pairs of stacks of `m` hats: the all-black stack apart
on both sides. -/
theorem sum_peel2 {M : Type*} [AddCommMonoid M] (m : ℕ) (f : ℕ → ℕ → M) :
    ∑ t ∈ range (2 ^ m), ∑ u ∈ range (2 ^ m), f t u
      = ∑ t ∈ range (2 ^ m - 1), ∑ u ∈ range (2 ^ m - 1), f t u
        + ∑ t ∈ range (2 ^ m - 1), f t (2 ^ m - 1)
        + ∑ u ∈ range (2 ^ m - 1), f (2 ^ m - 1) u
        + f (2 ^ m - 1) (2 ^ m - 1) := by
  rw [sum_peel m, sum_congr rfl fun t _ => sum_peel m (f t), sum_add_distrib, sum_peel m (f _)]
  abel

/-- A sum whose first term differs from the others. -/
theorem sum_ite_zero {W : ℕ} (hW : 1 ≤ W) (x y : ℕ) :
    ∑ t ∈ range W, (if t = 0 then x else y) + y = x + W * y := by
  induction W, hW using Nat.le_induction with
  | base => simp
  | succ W hW ih =>
    have : W ≠ 0 := by omega
    rw [sum_range_succ]
    simp only [this, ↓reduceIte]
    linarith [ih, Nat.succ_mul W y]

/-- A sum in which only the term of rank `0` is not zero. -/
theorem sum_ite_zero' {W : ℕ} (hW : 1 ≤ W) (x : ℕ) :
    ∑ t ∈ range W, (if t = 0 then x else 0) = x := by
  simpa using sum_ite_zero hW x 0

theorem four_pow (n : ℕ) : (4 : ℕ) ^ n = 2 ^ n * 2 ^ n := by
  rw [show (4 : ℕ) = 2 * 2 from rfl, mul_pow]

/-- A term that does not depend on the hats above is counted `4 ^ n`
times. -/
theorem sum_above_const (n x : ℕ) :
    ∑ _t1 ∈ range (2 ^ n), ∑ _u1 ∈ range (2 ^ n), x = 4 ^ n * x := by
  simp only [sum_const, card_range, smul_eq_mul, four_pow]
  ring

/-- When only one player has moved to the hats above: that player points
at a black hat for half of the pairs. -/
theorem sum_above_one {n : ℕ} {b : ℕ → ℤ} (hb : Proper n b) :
    ∑ t1 ∈ range (2 ^ n), ∑ u1 ∈ range (2 ^ n), hat u1 (b t1) = 2 ^ n * 2 ^ (n - 1) := by
  rw [sum_congr rfl fun t1 ht1 =>
    sum_hat (hb t1 (mem_range.mp ht1)).1 (hb t1 (mem_range.mp ht1)).2]
  simp

theorem sum_above_one' {n : ℕ} {b : ℕ → ℤ} (hb : Proper n b) :
    ∑ t1 ∈ range (2 ^ n), ∑ u1 ∈ range (2 ^ n), hat t1 (b u1) = 2 ^ n * 2 ^ (n - 1) := by
  rw [sum_comm]; exact sum_above_one hb

/-- Twice that is `4 ^ n`. -/
theorem two_mul_half {n : ℕ} (hn : 1 ≤ n) : 2 * (2 ^ n * 2 ^ (n - 1)) = 4 ^ n := by
  obtain ⟨k, rfl⟩ : ∃ k, n = k + 1 := ⟨n - 1, by omega⟩
  rw [four_pow]; simp [pow_succ]; ring

/-- The hits of a proper strategy on `m` hats, the all-black stack apart:
the pairs of two other stacks, and `2 ^ m - 1` pairs that involve it. -/
theorem hits_peel {m : ℕ} {a : ℕ → ℤ} (ha : Proper m a) :
    hits m a = ∑ t ∈ range (2 ^ m - 1), ∑ u ∈ range (2 ^ m - 1), pair a t u + (2 ^ m - 1) := by
  have hm := ha.pos
  have hW : 2 ^ m - 1 < 2 ^ m := Nat.sub_lt (Nat.two_pow_pos m) one_pos
  have haW := ha _ hW
  have e1 : ∀ t ∈ range (2 ^ m - 1), pair a t (2 ^ m - 1) = hat t (a (2 ^ m - 1)) := by
    intro t ht
    have := ha t (lt_trans (mem_range.mp ht) hW)
    simp [pair, hat_ones this.1 this.2]
  have e2 : ∀ u ∈ range (2 ^ m - 1), pair a (2 ^ m - 1) u = hat u (a (2 ^ m - 1)) := by
    intro u hu
    have := ha u (lt_trans (mem_range.mp hu) hW)
    simp [pair, hat_ones this.1 this.2]
  have e3 : pair a (2 ^ m - 1) (2 ^ m - 1) = 1 := by
    simp [pair, hat_ones haW.1 haW.2]
  have c := sum_hat haW.1 haW.2
  rw [sum_peel, hat_ones haW.1 haW.2] at c
  have h2 : 2 * 2 ^ (m - 1) = 2 ^ m := by
    obtain ⟨k, rfl⟩ : ∃ k, m = k + 1 := ⟨m - 1, by omega⟩
    simp [pow_succ]; ring
  unfold hits
  rw [sum_peel2, sum_congr rfl e1, sum_congr rfl e2, e3]
  omega

end Hats
