-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Mathlib.Algebra.BigOperators.Intervals
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic

/-!
# The game of hats: towers, strategies, hits

Two players each wear a tower of `n` hats, black or white.  Each sees the
other's tower and points at a position of their own; they win when both
point at a white hat.

* A tower of `n` hats is a number below `2 ^ n`: the hat at position `p`
  (from the bottom, starting at `0`) is white when the binary digit of
  weight `2 ^ p` is `1`.
* A strategy tells, for the tower one sees, the position one points at.
  It may point outside the tower (below `0`, or at `n` and above): that
  is never a white hat.

Lean functions are defined everywhere, so a strategy is a function on all
numbers; only its values on towers of `n` hats matter (`hits_congr`).
-/

namespace Hats

open Finset

/-- The color of the hat at position `p` of tower `t`: `1` for white, `0`
for black and for a position where there is no hat. -/
def hat (t : ℕ) (p : ℤ) : ℕ := if 0 ≤ p ∧ t.testBit p.toNat = true then 1 else 0

/-- The number of hits of strategy `s` on `n` hats: the pairs of towers
`(t, u)` on which both players point at a white hat.  The player who wears
`t` sees `u` and points at `s u`. -/
def hits (n : ℕ) (s : ℕ → ℤ) : ℕ :=
  ∑ t ∈ range (2 ^ n), ∑ u ∈ range (2 ^ n), hat t (s u) * hat u (s t)

/-- A strategy on `n` hats is proper when it always points inside the
tower. -/
def Proper (n : ℕ) (s : ℕ → ℤ) : Prop := ∀ t, t < 2 ^ n → 0 ≤ s t ∧ s t < n

/-- The hits of a strategy only depend on what it does on towers of `n`
hats. -/
theorem hits_congr {n : ℕ} {s s' : ℕ → ℤ} (h : ∀ t, t < 2 ^ n → s t = s' t) :
    hits n s = hits n s' := by
  unfold hits
  refine sum_congr rfl fun t ht => sum_congr rfl fun u hu => ?_
  rw [h t (mem_range.mp ht), h u (mem_range.mp hu)]

theorem hat_zero (p : ℤ) : hat 0 p = 0 := by simp [hat]

/-- Below position `m`, a tower shows its `m` lowest hats. -/
theorem hat_low {m t0 : ℕ} (t1 : ℕ) (h0 : t0 < 2 ^ m) {p : ℤ} (hp : 0 ≤ p) (hpm : p < m) :
    hat (2 ^ m * t1 + t0) p = hat t0 p := by
  have : p.toNat < m := by omega
  simp [hat, Nat.testBit_two_pow_mul_add t1 h0, this]

/-- From position `m` on, a tower whose `m` lowest hats are black shows the
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

/-- Below position `m`, a tower whose `m` lowest hats are black shows
black. -/
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

end Hats
