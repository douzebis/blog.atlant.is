-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Basic

/-!
# The left reset and its win rate

`lr m a b` plays `a` on the `m` lowest hats, except when they are all
white: then it plays `b` on the hats above them.  (In the tuple of `a`,
the all-white stack is the entry on the left.)
-/

namespace Hats

open Finset

/-- `a` (a strategy on `m` hats) left-reset by `b`. -/
def lr (m : ℕ) (a b : ℕ → ℤ) : ℕ → ℤ := fun t =>
  if t % 2 ^ m = 0 then m + b (t / 2 ^ m) else a (t % 2 ^ m)

theorem lr_apply (m : ℕ) (a b : ℕ → ℤ) (t1 : ℕ) {t0 : ℕ} (h0 : t0 < 2 ^ m) :
    lr m a b (2 ^ m * t1 + t0) = if t0 = 0 then m + b t1 else a t0 := by
  have hpos : 0 < 2 ^ m := Nat.two_pow_pos m
  simp [lr, Nat.mod_eq_of_lt h0, Nat.mul_add_div hpos, Nat.div_eq_of_lt h0]

/-- What one pair of stacks contributes to the hits of a left reset: what
the lowest hats contribute to the hits of `a`, plus, when the lowest hats
of both stacks are all white, what the hats above contribute to the hits
of `b`. -/
theorem lr_term {m : ℕ} {a : ℕ → ℤ} (b : ℕ → ℤ) (ha : Proper m a)
    (t1 u1 : ℕ) {t0 u0 : ℕ} (ht : t0 < 2 ^ m) (hu : u0 < 2 ^ m) :
    pair (lr m a b) (2 ^ m * t1 + t0) (2 ^ m * u1 + u0)
      = hat t0 (a u0) * hat u0 (a t0)
        + if t0 = 0 ∧ u0 = 0 then hat t1 (b u1) * hat u1 (b t1) else 0 := by
  unfold pair
  rw [lr_apply m a b u1 hu, lr_apply m a b t1 ht]
  by_cases h0 : t0 = 0 <;> by_cases h1 : u0 = 0
  · subst h0; subst h1
    simp [hat_high, hat_zero]
  · subst h0
    have := ha u0 hu
    simp [h1, hat_low_zero m t1 this.1 this.2, hat_zero]
  · subst h1
    have := ha t0 ht
    simp [h0, hat_low_zero m u1 this.1 this.2, hat_zero]
  · have h2 := ha u0 hu
    have h3 := ha t0 ht
    simp [h0, h1, hat_low t1 ht h2.1 h2.2, hat_low u1 hu h3.1 h3.2]

/-- **Win rate after a left reset**, as a count of hits: if `a` is a proper
strategy on `m` hats and `b` any strategy on `n` hats, then the left reset
of `a` by `b`, on `m + n` hats, has `4 ^ n * hits a + hits b` hits.
Divided by `4 ^ (m + n)`: its win rate is that of `a` plus that of `b`
over `4 ^ m`. -/
theorem hits_lr {m : ℕ} (n : ℕ) {a : ℕ → ℤ} (b : ℕ → ℤ) (ha : Proper m a) :
    hits (m + n) (lr m a b) = 4 ^ n * hits m a + hits n b := by
  have h4 : (4 : ℕ) ^ n = 2 ^ n * 2 ^ n := by rw [show (4 : ℕ) = 2 * 2 from rfl, mul_pow]
  have hpos : 0 < 2 ^ m := Nat.two_pow_pos m
  unfold hits pair
  rw [pow_add, sum_range_mul]
  have step : ∀ t1 ∈ range (2 ^ n), ∀ t0 ∈ range (2 ^ m),
      ∑ u ∈ range (2 ^ m * 2 ^ n), hat (2 ^ m * t1 + t0) (lr m a b u)
          * hat u (lr m a b (2 ^ m * t1 + t0))
        = ∑ u1 ∈ range (2 ^ n), ∑ u0 ∈ range (2 ^ m),
            (hat t0 (a u0) * hat u0 (a t0)
              + if t0 = 0 ∧ u0 = 0 then hat t1 (b u1) * hat u1 (b t1) else 0) := by
    intro t1 _ t0 ht0
    rw [sum_range_mul]
    refine sum_congr rfl fun u1 _ => sum_congr rfl fun u0 hu0 => ?_
    exact lr_term b ha t1 u1 (mem_range.mp ht0) (mem_range.mp hu0)
  rw [sum_congr rfl fun t1 ht1 => sum_congr rfl fun t0 ht0 => step t1 ht1 t0 ht0]
  simp only [sum_add_distrib, sum_const, card_range, smul_eq_mul, ite_and]
  have hb : ∀ t1 u1 : ℕ, ∑ t0 ∈ range (2 ^ m), ∑ u0 ∈ range (2 ^ m),
      (if t0 = 0 then if u0 = 0 then hat t1 (b u1) * hat u1 (b t1) else 0 else 0)
        = hat t1 (b u1) * hat u1 (b t1) := by
    intro t1 u1
    rw [sum_eq_single 0, sum_eq_single 0] <;> simp_all
  congr 1
  · rw [h4, ← mul_sum]; ring
  · refine sum_congr rfl fun t1 _ => ?_
    rw [sum_comm]
    exact sum_congr rfl fun u1 _ => hb t1 u1

end Hats
