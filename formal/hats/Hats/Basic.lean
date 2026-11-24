-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Mathlib.Algebra.BigOperators.Intervals
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic

/-!
# The game of hats: stacks, strategies, hits

Two players each wear a stack of `n` hats, black or white.  Each sees the
other's stack and points at a position of their own; they win when both
point at a black hat.

* A stack of `n` hats is a number below `2 ^ n`: the hat at position `p`
  (from the bottom, starting at `0`) is black when the binary digit of
  weight `2 ^ p` is `1`.
* A strategy tells, for the stack one sees, the position one points at.
  It may point outside the stack (below `0`, or at `n` and above): that
  is never a black hat.

Lean functions are defined everywhere, so a strategy is a function on all
numbers; only its values on stacks of `n` hats matter (`hits_congr`).
-/

namespace Hats

open Finset

/-- The color of the hat at position `p` of stack `t`: `1` for black, `0`
for white and for a position where there is no hat. -/
def hat (t : ℕ) (p : ℤ) : ℕ := if 0 ≤ p ∧ t.testBit p.toNat = true then 1 else 0

/-- What the pair of stacks `(t, u)` contributes to the hits of strategy
`s`: `1` when both players point at a black hat, `0` otherwise.  The
player who wears `t` sees `u` and points at `s u`. -/
def pair (s : ℕ → ℤ) (t u : ℕ) : ℕ := hat t (s u) * hat u (s t)

/-- The number of hits of strategy `s` on `n` hats: the pairs of stacks on
which both players point at a black hat. -/
def hits (n : ℕ) (s : ℕ → ℤ) : ℕ :=
  ∑ t ∈ range (2 ^ n), ∑ u ∈ range (2 ^ n), pair s t u

/-- A strategy on `n` hats is proper when it always points inside the
stack. -/
def Proper (n : ℕ) (s : ℕ → ℤ) : Prop := ∀ t, t < 2 ^ n → 0 ≤ s t ∧ s t < n

/-- The hits of a strategy only depend on what it does on stacks of `n`
hats. -/
theorem hits_congr {n : ℕ} {s s' : ℕ → ℤ} (h : ∀ t, t < 2 ^ n → s t = s' t) :
    hits n s = hits n s' := by
  unfold hits pair
  refine sum_congr rfl fun t ht => sum_congr rfl fun u hu => ?_
  rw [h t (mem_range.mp ht), h u (mem_range.mp hu)]

theorem hat_zero (p : ℤ) : hat 0 p = 0 := by simp [hat]

/-- Below position `m`, a stack shows its `m` lowest hats. -/
theorem hat_low {m t0 : ℕ} (t1 : ℕ) (h0 : t0 < 2 ^ m) {p : ℤ} (hp : 0 ≤ p) (hpm : p < m) :
    hat (2 ^ m * t1 + t0) p = hat t0 p := by
  have : p.toNat < m := by omega
  simp [hat, Nat.testBit_two_pow_mul_add t1 h0, this]

/-- From position `m` on, a stack whose `m` lowest hats are white shows the
hats above them. -/
theorem hat_high (m t1 : ℕ) (p : ℤ) : hat (2 ^ m * t1) (m + p) = hat t1 p := by
  by_cases hp : 0 ≤ p
  · have h1 : (m + p).toNat = p.toNat + m := by omega
    have h2 : (0 : ℤ) ≤ m + p := by omega
    simp [hat, hp, h2, h1, Nat.testBit_two_pow_mul]
  · by_cases h2 : (0 : ℤ) ≤ m + p
    · have : (m + p).toNat < m := by omega
      simp [hat, hp, Nat.testBit_two_pow_mul, this]
    · simp [hat, hp, h2]

/-- Below position `m`, a stack whose `m` lowest hats are white shows
white. -/
theorem hat_low_zero (m t1 : ℕ) {p : ℤ} (hp : 0 ≤ p) (hpm : p < m) :
    hat (2 ^ m * t1) p = 0 := by
  have := hat_low (t0 := 0) t1 (Nat.two_pow_pos m) hp hpm
  simpa [hat_zero] using this

/-- A sum over the numbers below `a * b`, by quotient and remainder. -/
theorem sum_range_mul {M : Type*} [AddCommMonoid M] (a b : ℕ) (G : ℕ → M) :
    ∑ t ∈ range (a * b), G t = ∑ q ∈ range b, ∑ r ∈ range a, G (a * q + r) := by
  induction b with
  | zero => simp
  | succ b ih => rw [Nat.mul_succ, sum_range_add, ih, sum_range_succ]

/-- From position `m` on, a stack shows the hats above its `m` lowest. -/
theorem hat_above {m t0 : ℕ} (t1 : ℕ) (h0 : t0 < 2 ^ m) {p : ℤ} (hp : 0 ≤ p) :
    hat (2 ^ m * t1 + t0) (m + p) = hat t1 p := by
  have h1 : (m + p).toNat = p.toNat + m := by omega
  have h2 : (0 : ℤ) ≤ m + p := by omega
  simp [hat, hp, h2, h1, Nat.testBit_two_pow_mul_add t1 h0]

/-- The stack of `m` black hats shows black at every position. -/
theorem hat_ones {m : ℕ} {p : ℤ} (hp : 0 ≤ p) (hpm : p < m) : hat (2 ^ m - 1) p = 1 := by
  have : p.toNat < m := by omega
  simp [hat, hp, this]

/-- A proper strategy needs at least one hat. -/
theorem Proper.pos {n : ℕ} {s : ℕ → ℤ} (h : Proper n s) : 1 ≤ n := by
  have := h 0 (Nat.two_pow_pos n)
  omega

/-- Half of the numbers below `2 ^ (k + 1)` are odd. -/
theorem sum_odd (k : ℕ) :
    ∑ q ∈ range (2 ^ (k + 1)), (if q.testBit 0 = true then 1 else 0) = 2 ^ k := by
  rw [pow_succ, mul_comm, sum_range_mul]
  simp [Nat.testBit_zero, Nat.add_mod]
  decide

/-- Among the stacks of `n` hats, half have a black hat at a given
position. -/
theorem sum_hat {n : ℕ} {p : ℤ} (hp : 0 ≤ p) (hpn : p < n) :
    ∑ u ∈ range (2 ^ n), hat u p = 2 ^ (n - 1) := by
  obtain ⟨k, hk⟩ : ∃ k, n = p.toNat + (k + 1) := ⟨n - p.toNat - 1, by omega⟩
  have key : ∀ q r : ℕ, r < 2 ^ p.toNat →
      hat (2 ^ p.toNat * q + r) p = if q.testBit 0 = true then 1 else 0 := by
    intro q r hr
    simp [hat, hp, Nat.testBit_two_pow_mul_add q hr]
  rw [hk, pow_add, sum_range_mul]
  rw [sum_congr rfl fun q _ => sum_congr rfl fun r hr => key q r (mem_range.mp hr)]
  rw [sum_comm, sum_congr rfl fun r _ => sum_odd k]
  have : p.toNat + (k + 1) - 1 = p.toNat + k := by omega
  simp [this, pow_add]

/-- The hits of a strategy on `m + n` hats, sorted by the `m` lowest hats
of the two stacks. -/
theorem hits_split (m n : ℕ) (s : ℕ → ℤ) :
    hits (m + n) s = ∑ t0 ∈ range (2 ^ m), ∑ u0 ∈ range (2 ^ m),
      ∑ t1 ∈ range (2 ^ n), ∑ u1 ∈ range (2 ^ n),
        pair s (2 ^ m * t1 + t0) (2 ^ m * u1 + u0) := by
  unfold hits
  rw [pow_add, sum_range_mul, sum_comm]
  refine sum_congr rfl fun t0 _ => ?_
  rw [sum_congr rfl fun t1 _ => sum_range_mul (2 ^ m) (2 ^ n) _]
  rw [sum_congr rfl fun t1 _ => sum_comm, sum_comm]

end Hats
