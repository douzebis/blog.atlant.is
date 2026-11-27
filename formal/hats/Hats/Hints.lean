-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Schemes

/-!
# Hints, and the game on `d + 1` hats

The upper bounds on the value of the game come from *hints* (Buhler et
al., arXiv 1407.4711, Section 3).  In the hint game of dimension `d`,
Alice's stack is made of the values of an affine function
`x ↦ c · x + e` on `d` bits that is not constant (`c` is not zero): each
of her hats is its value at a point `x`.  Bob sees which function it is
and points at one of `k` hats of his own; Alice sees Bob's hats and picks
a point.  They win when Bob's hat is black and the function is `1` at
Alice's point.

This file defines that game and proves that it contains the game on
`d + 1` hats for a stack of Alice that is not of a single color
(Proposition 17 of the article): for any two strategies on `d + 1` hats,
one for each player, the winning pairs are at most `2 ^ d` plus the wins
of a hint game.  So a bound on all hint games of dimension `d` is a bound
on the best score on `d + 1` hats, with one strategy or with two
(`hitsTwo_le_of_hint_le`).
-/

namespace Hats

open Finset

/-- The winning pairs when Alice plays `a` and Bob plays `b`: Alice wears
`t`, sees `u` and points at `a u`; Bob wears `u`, sees `t` and points at
`b t`. -/
def hitsTwo (n : ℕ) (a b : ℕ → ℤ) : ℕ :=
  ∑ t ∈ range (2 ^ n), ∑ u ∈ range (2 ^ n), hat t (a u) * hat u (b t)

/-- With the same strategy for both, these are the hits. -/
theorem hitsTwo_self (n : ℕ) (s : ℕ → ℤ) : hitsTwo n s s = hits n s := rfl

/-! ### The hint game of dimension `d` -/

/-- The binary digit of weight `2 ^ i` of `c`. -/
def digit (c i : ℕ) : ℕ := if c.testBit i = true then 1 else 0

/-- The number of the `d` coordinates where both `c` and `x` have a `1`. -/
def dot (d c x : ℕ) : ℕ := ∑ i ∈ range d, digit c i * digit x i

/-- The value at the point `x` of the affine function `c · x + e`. -/
def affine (d c e x : ℕ) : ℕ := (dot d c x + e) % 2

/-- The wins of a hint game of dimension `d` in which Bob has `k` hats: he
points at `β c e` when Alice's function is `(c, e)`, and Alice, seeing
Bob's stack `v`, picks the point `α v`.  The functions are those with `c`
from `1` to `2 ^ d - 1` and `e` equal to `0` or `1`: there are
`2 * (2 ^ d - 1)` of them, so the wins are out of
`2 * (2 ^ d - 1) * 2 ^ k`. -/
def hintWins (d k : ℕ) (β : ℕ → ℕ → ℤ) (α : ℕ → ℕ) : ℕ :=
  ∑ c ∈ Ico 1 (2 ^ d), ∑ e ∈ range 2, ∑ v ∈ range (2 ^ k), affine d c e (α v) * hat v (β c e)

/-! ### From a stack of `d + 1` hats to an affine function -/

/-- The stack of `d + 1` hats made of the values of the function `(c, e)`
at the point `0` (the bottom hat) and at the `d` points with a single
coordinate `1`. -/
def stackOf (d c e : ℕ) : ℕ := 2 * (c ^^^ (if e = 1 then 2 ^ d - 1 else 0)) + e

/-- The point that goes with a position of that stack: the point `0` for
the bottom hat, the point with a single `1` at coordinate `p - 1` for the
hat at position `p`. -/
def pointOf (p : ℤ) : ℕ := if 1 ≤ p then 2 ^ (p.toNat - 1) else 0

theorem stackOf_lt {d c e : ℕ} (hc : c < 2 ^ d) (he : e < 2) : stackOf d c e < 2 ^ (d + 1) := by
  have hm : (if e = 1 then 2 ^ d - 1 else 0) < 2 ^ d := by
    have := Nat.two_pow_pos d
    split_ifs <;> omega
  have := Nat.xor_lt_two_pow hc hm
  unfold stackOf
  rw [pow_succ]
  omega

theorem dot_zero (d c : ℕ) : dot d c 0 = 0 := by
  simp [dot, digit]

theorem dot_two_pow {d i : ℕ} (hi : i < d) (c : ℕ) : dot d c (2 ^ i) = digit c i := by
  unfold dot
  rw [sum_eq_single i]
  · simp [digit]
  · intro j _ hj
    have : ¬ i = j := fun h => hj h.symm
    simp [digit, this]
  · intro h
    exact absurd (mem_range.mpr hi) h

/-- **A hat of the stack is the value of the function at its point**, for
the positions of the stack; elsewhere there is no hat. -/
theorem hat_stackOf_le {d c e : ℕ} (hc : c < 2 ^ d) (he : e < 2) (p : ℤ) :
    hat (stackOf d c e) p ≤ affine d c e (pointOf p) := by
  by_cases hp : 0 ≤ p ∧ p < d + 1
  swap
  · rw [hat_outside (stackOf_lt hc he) (by push_cast; omega)]
    exact Nat.zero_le _
  obtain ⟨q, rfl⟩ := Int.eq_ofNat_of_zero_le hp.1
  have hq : q < d + 1 := by omega
  refine le_of_eq ?_
  rcases q with _ | i
  · -- the bottom hat: the value at the point 0
    have h0 : (stackOf d c e).testBit 0 = decide (e = 1) := by
      unfold stackOf
      rw [Nat.testBit_zero]
      congr 1
      simp only [eq_iff_iff]
      omega
    have hpt : pointOf ((0 : ℕ) : ℤ) = 0 := by simp [pointOf]
    have hhat : hat (stackOf d c e) ((0 : ℕ) : ℤ)
        = if (stackOf d c e).testBit 0 = true then 1 else 0 := by simp [hat]
    rw [hhat, h0, hpt]
    unfold affine
    rw [dot_zero]
    interval_cases e <;> simp
  · -- the hat at position i + 1: the value at the point with a 1 at i
    have hi : i < d := by omega
    have hbit : (stackOf d c e).testBit (i + 1)
        = (c.testBit i ^^ decide (e = 1)) := by
      unfold stackOf
      rw [Nat.testBit_succ]
      have : (2 * (c ^^^ (if e = 1 then 2 ^ d - 1 else 0)) + e) / 2
          = c ^^^ (if e = 1 then 2 ^ d - 1 else 0) := by omega
      rw [this, Nat.testBit_xor]
      interval_cases e <;> simp [hi]
    have hpt : pointOf ((i + 1 : ℕ) : ℤ) = 2 ^ i := by
      simp [pointOf]
    have hhat : hat (stackOf d c e) ((i + 1 : ℕ) : ℤ)
        = if (stackOf d c e).testBit (i + 1) = true then 1 else 0 := by
      have : (0 : ℤ) ≤ (i : ℤ) + 1 := by omega
      simp [hat, this]
    rw [hhat, hbit, hpt]
    unfold affine
    rw [dot_two_pow hi]
    unfold digit
    interval_cases e <;> cases c.testBit i <;> simp

/-! ### Sorting the stacks of `d + 1` hats by their function -/

/-- A sum over the numbers below `2 ^ d`, after an exchange of `0` and `1`
in all their digits or in none. -/
theorem sum_xor (d : ℕ) {m : ℕ} (hm : m < 2 ^ d) (G : ℕ → ℕ) :
    ∑ c ∈ range (2 ^ d), G (c ^^^ m) = ∑ c ∈ range (2 ^ d), G c := by
  refine sum_nbij' (fun c => c ^^^ m) (fun c => c ^^^ m) ?_ ?_ ?_ ?_ ?_
  · intro c hc
    exact mem_range.mpr (Nat.xor_lt_two_pow (mem_range.mp hc) hm)
  · intro c hc
    exact mem_range.mpr (Nat.xor_lt_two_pow (mem_range.mp hc) hm)
  · intro c _
    rw [Nat.xor_assoc, Nat.xor_self, Nat.xor_zero]
  · intro c _
    rw [Nat.xor_assoc, Nat.xor_self, Nat.xor_zero]
  · intro c _
    rfl

/-- Every stack of `d + 1` hats is the stack of one function `(c, e)`,
with `c` below `2 ^ d`. -/
theorem sum_stackOf (d : ℕ) (G : ℕ → ℕ) :
    ∑ t ∈ range (2 ^ (d + 1)), G t
      = ∑ c ∈ range (2 ^ d), ∑ e ∈ range 2, G (stackOf d c e) := by
  have hm : 2 ^ d - 1 < 2 ^ d := Nat.sub_lt (Nat.two_pow_pos d) one_pos
  have h0 := sum_xor d (Nat.two_pow_pos d) fun y => G (2 * y + 0)
  have h1 := sum_xor d hm fun y => G (2 * y + 1)
  rw [pow_succ, mul_comm, sum_range_mul]
  simp only [sum_range_succ, sum_range_zero, zero_add, stackOf, sum_add_distrib]
  simp only [Nat.xor_zero] at h0
  simp only [show (0 : ℕ) ≠ 1 by norm_num, ite_false, ite_true, Nat.xor_zero]
  rw [h1]

/-! ### The proposition -/

/-- **The game on `d + 1` hats is inside the hint game of dimension `d`.**
For any two strategies on `d + 1` hats, the winning pairs are at most
`2 ^ d` (those in which Alice's stack is all black) plus the wins of a
hint game in which Bob has `d + 1` hats. -/
theorem hitsTwo_le_hintWins (d : ℕ) (a b : ℕ → ℤ) :
    hitsTwo (d + 1) a b
      ≤ 2 ^ d + hintWins d (d + 1) (fun c e => b (stackOf d c e)) (fun u => pointOf (a u)) := by
  have hpos := Nat.two_pow_pos d
  unfold hitsTwo hintWins
  rw [sum_stackOf, range_eq_Ico, sum_eq_sum_Ico_succ_bot hpos]
  refine add_le_add ?_ ?_
  · -- the function with c = 0: the all-white and the all-black stack
    have e0 : stackOf d 0 0 = 0 := by simp [stackOf]
    have e1 : stackOf d 0 1 = 2 ^ (d + 1) - 1 := by
      simp only [stackOf, ite_true, Nat.zero_xor]
      rw [pow_succ]; omega
    simp only [sum_range_succ, sum_range_zero, zero_add, e0, e1, hat_zero, zero_mul,
      sum_const_zero]
    calc ∑ u ∈ range (2 ^ (d + 1)), hat (2 ^ (d + 1) - 1) (a u) * hat u (b (2 ^ (d + 1) - 1))
        ≤ ∑ u ∈ range (2 ^ (d + 1)), hat u (b (2 ^ (d + 1) - 1)) := by
          refine sum_le_sum fun u _ => ?_
          exact (Nat.mul_le_mul_right _ (hat_le_one _ _)).trans (by simp)
      _ ≤ 2 ^ (d + 1 - 1) := sum_hat_le (d + 1) _
      _ = 2 ^ d := by simp
  · -- the other functions
    rw [range_eq_Ico]
    refine sum_le_sum fun c hc => sum_le_sum fun e he => sum_le_sum fun u _ => ?_
    have hc' : c < 2 ^ d := (mem_Ico.mp hc).2
    have he' : e < 2 := by simpa using he
    exact Nat.mul_le_mul_right _ (hat_stackOf_le hc' he' (a u))

/-- **Proposition 17.**  If no hint game of dimension `d` wins more than
`N / D` of the time, then no two strategies on `d + 1` hats win more than
`2 ^ d + (N / D) * 2 ^ (d + 1) * (2 ^ (d + 1) - 2)` pairs of stacks. -/
theorem hitsTwo_le_of_hint_le {d N D : ℕ}
    (h : ∀ k β α, D * hintWins d k β α ≤ N * (2 * (2 ^ d - 1) * 2 ^ k)) (a b : ℕ → ℤ) :
    D * hitsTwo (d + 1) a b ≤ D * 2 ^ d + N * (2 ^ (d + 1) * (2 ^ (d + 1) - 2)) := by
  have h1 := hitsTwo_le_hintWins d a b
  have h2 := h (d + 1) (fun c e => b (stackOf d c e)) (fun u => pointOf (a u))
  have e : 2 * (2 ^ d - 1) * 2 ^ (d + 1) = 2 ^ (d + 1) * (2 ^ (d + 1) - 2) := by
    have : 2 ^ (d + 1) - 2 = 2 * (2 ^ d - 1) := by rw [pow_succ]; omega
    rw [this]; ring
  rw [e] at h2
  calc D * hitsTwo (d + 1) a b
      ≤ D * (2 ^ d + hintWins d (d + 1) (fun c e => b (stackOf d c e))
          (fun u => pointOf (a u))) := Nat.mul_le_mul_left _ h1
    _ = D * 2 ^ d + D * hintWins d (d + 1) (fun c e => b (stackOf d c e))
          (fun u => pointOf (a u)) := by ring
    _ ≤ D * 2 ^ d + N * (2 ^ (d + 1) * (2 ^ (d + 1) - 2)) := Nat.add_le_add_left h2 _

/-- If the hint games of dimension 3 win at most 81 times in 224 (the
computation of Buhler et al.), no two strategies on four hats win more
than 89 pairs. -/
theorem hitsTwo_four_le
    (h : ∀ k β α, 224 * hintWins 3 k β α ≤ 81 * (2 * (2 ^ 3 - 1) * 2 ^ k)) (a b : ℕ → ℤ) :
    hitsTwo 4 a b ≤ 89 := by
  have := hitsTwo_le_of_hint_le h a b
  norm_num at this
  omega

/-- If the hint games of dimension 4 win at most 57 times in 160 (the
computation of `research/hats/hint-search`), no two strategies on five
hats win more than 358 pairs. -/
theorem hitsTwo_five_le
    (h : ∀ k β α, 160 * hintWins 4 k β α ≤ 57 * (2 * (2 ^ 4 - 1) * 2 ^ k)) (a b : ℕ → ℤ) :
    hitsTwo 5 a b ≤ 358 := by
  have := hitsTwo_le_of_hint_le h a b
  norm_num at this
  omega

end Hats
