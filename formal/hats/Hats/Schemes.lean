-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Describe

/-!
# Generalized resets: a bound that needs no computer

A *scheme* on blocks of `m` hats is a set `Z` of stacks of `m` hats, the
stacks that are skipped, and a strategy `a` for the others: outside `Z`
play `a` on the lowest block, in `Z` skip it and start again above
(`docs/papers/hats/open-questions.md`, question 4).  The double reset is
the scheme with `Z` = {all white, all black}.

The win rate of a scheme is its *score* divided by `4 ^ m - |Z| ^ 2`.
This file defines the score and proves that it is at most
`2 ^ (m - 1) * (2 ^ m - |Z|)`.  So a scheme with `7 * |Z|` at least
`6 * 2 ^ (m - 1)` does not win more than 7 times in 20.

What is not proved here: that the win rate is the score divided by
`4 ^ m - |Z| ^ 2`.
-/

namespace Hats

open Finset

/-- The color of a hat is `0` or `1`. -/
theorem hat_le_one (t : ℕ) (p : ℤ) : hat t p ≤ 1 := by
  unfold hat
  split_ifs <;> simp

/-- Among the stacks of `n` hats, at most half have a black hat at a given
position: exactly half if the position is in the stack, none otherwise. -/
theorem sum_hat_le (n : ℕ) (p : ℤ) : ∑ t ∈ range (2 ^ n), hat t p ≤ 2 ^ (n - 1) := by
  by_cases h : 0 ≤ p ∧ p < n
  · exact (sum_hat h.1 h.2).le
  · have : ∑ t ∈ range (2 ^ n), hat t p = 0 := by
      refine sum_eq_zero fun t ht => ?_
      exact hat_outside (mem_range.mp ht) (by omega)
    rw [this]
    exact Nat.zero_le _

/-- **The score of a scheme.**  For each stack `u` that is not skipped:
the stacks `t` that are not skipped and form a winning pair with `u`, and
the skipped stacks `t` that are black where `a` points for `u`. -/
def schemeScore (m : ℕ) (Z : Finset ℕ) (a : ℕ → ℤ) : ℕ :=
  ∑ u ∈ range (2 ^ m) \ Z,
    ((∑ t ∈ range (2 ^ m) \ Z, pair a t u) + ∑ t ∈ Z, hat t (a u))

/-- With nothing skipped, the score is the number of hits. -/
theorem schemeScore_empty (m : ℕ) (a : ℕ → ℤ) : schemeScore m ∅ a = hits m a := by
  unfold schemeScore hits
  simp only [sdiff_empty, sum_empty, add_zero]
  exact sum_comm

/-- **The bound.**  For each stack `u` that is not skipped, the score
counts some of the stacks that are black where `a` points for `u`, and
these are at most half of the stacks. -/
theorem schemeScore_le (m : ℕ) {Z : Finset ℕ} (hZ : Z ⊆ range (2 ^ m)) (a : ℕ → ℤ) :
    schemeScore m Z a ≤ 2 ^ (m - 1) * (2 ^ m - Z.card) := by
  have hcard : (range (2 ^ m) \ Z).card = 2 ^ m - Z.card := by
    rw [card_sdiff_of_subset hZ, card_range]
  unfold schemeScore
  calc ∑ u ∈ range (2 ^ m) \ Z,
        ((∑ t ∈ range (2 ^ m) \ Z, pair a t u) + ∑ t ∈ Z, hat t (a u))
      ≤ ∑ u ∈ range (2 ^ m) \ Z, 2 ^ (m - 1) := by
        refine sum_le_sum fun u _ => ?_
        have h1 : ∑ t ∈ range (2 ^ m) \ Z, pair a t u
            ≤ ∑ t ∈ range (2 ^ m) \ Z, hat t (a u) := by
          refine sum_le_sum fun t _ => ?_
          unfold pair
          exact (Nat.mul_le_mul_left _ (hat_le_one u (a t))).trans (by simp)
        have h2 : ∑ t ∈ range (2 ^ m) \ Z, hat t (a u) + ∑ t ∈ Z, hat t (a u)
            = ∑ t ∈ range (2 ^ m), hat t (a u) := sum_sdiff hZ
        have h3 := sum_hat_le m (a u)
        omega
    _ = 2 ^ (m - 1) * (2 ^ m - Z.card) := by
        rw [sum_const, hcard, smul_eq_mul, mul_comm]

/-- **A scheme that skips many stacks does not beat 7/20**: if `7 * |Z|` is
at least `6 * 2 ^ (m - 1)`, then the score is at most 7/20 of
`4 ^ m - |Z| ^ 2`.  On blocks of five hats: 14 skipped stacks or more. -/
theorem schemeScore_le_seven_twentieths {m : ℕ} (hm : 1 ≤ m) {Z : Finset ℕ}
    (hZ : Z ⊆ range (2 ^ m)) (a : ℕ → ℤ) (hbig : 6 * 2 ^ (m - 1) ≤ 7 * Z.card) :
    20 * schemeScore m Z a ≤ 7 * (4 ^ m - Z.card ^ 2) := by
  have hle : Z.card ≤ 2 ^ m := by
    simpa using card_le_card hZ
  have hbound := schemeScore_le m hZ a
  obtain ⟨k, rfl⟩ : ∃ k, m = k + 1 := ⟨m - 1, by omega⟩
  simp only [Nat.add_sub_cancel] at hbound hbig
  set z := Z.card with hz
  set h := 2 ^ k with hh
  have h2 : 2 ^ (k + 1) = 2 * h := by rw [pow_succ, mul_comm]
  have h4 : 4 ^ (k + 1) = (2 * h) * (2 * h) := by
    rw [show (4 : ℕ) = 2 * 2 by norm_num, mul_pow, h2]
  rw [h2] at hbound hle
  rw [h4]
  -- with `d = 2 h - z`: the score is at most `h d`, and `20 h ≤ 7 (2 h + z)`
  obtain ⟨d, hd⟩ : ∃ d, 2 * h = z + d := ⟨2 * h - z, by omega⟩
  have hsub : 2 * h - z = d := by omega
  rw [hsub] at hbound
  have hsq : 2 * h * (2 * h) - z ^ 2 = d * (2 * h + z) := by
    rw [hd]
    have : (z + d) * (z + d) = z ^ 2 + d * (z + d + z) := by ring
    rw [this, Nat.add_sub_cancel_left]
  rw [hsq]
  calc 20 * schemeScore (k + 1) Z a ≤ 20 * (h * d) := Nat.mul_le_mul_left _ hbound
    _ = d * (20 * h) := by ring
    _ ≤ d * (7 * (2 * h + z)) := Nat.mul_le_mul_left _ (by omega)
    _ = 7 * (d * (2 * h + z)) := by ring

end Hats
