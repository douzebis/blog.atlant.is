-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Sums

/-!
# The right reset and the double reset

`rr m a b` plays `a` on the `m` lowest hats, except when they are all
black: then it plays `b` on the hats above them.  `dr m a b` does so when
they are all black or all white.
-/

namespace Hats

open Finset

/-- `a` (a strategy on `m` hats) right-reset by `b`. -/
def rr (m : ℕ) (a b : ℕ → ℤ) : ℕ → ℤ := fun t =>
  if t % 2 ^ m = 2 ^ m - 1 then m + b (t / 2 ^ m) else a (t % 2 ^ m)

/-- `a` (a strategy on `m` hats) double-reset by `b`. -/
def dr (m : ℕ) (a b : ℕ → ℤ) : ℕ → ℤ := fun t =>
  if t % 2 ^ m = 0 ∨ t % 2 ^ m = 2 ^ m - 1 then m + b (t / 2 ^ m) else a (t % 2 ^ m)

theorem rr_apply (m : ℕ) (a b : ℕ → ℤ) (t1 : ℕ) {t0 : ℕ} (h0 : t0 < 2 ^ m) :
    rr m a b (2 ^ m * t1 + t0) = if t0 = 2 ^ m - 1 then m + b t1 else a t0 := by
  have hpos : 0 < 2 ^ m := Nat.two_pow_pos m
  simp [rr, Nat.mod_eq_of_lt h0, Nat.mul_add_div hpos, Nat.div_eq_of_lt h0]

theorem dr_apply (m : ℕ) (a b : ℕ → ℤ) (t1 : ℕ) {t0 : ℕ} (h0 : t0 < 2 ^ m) :
    dr m a b (2 ^ m * t1 + t0)
      = if t0 = 0 ∨ t0 = 2 ^ m - 1 then m + b t1 else a t0 := by
  have hpos : 0 < 2 ^ m := Nat.two_pow_pos m
  simp [dr, Nat.mod_eq_of_lt h0, Nat.mul_add_div hpos, Nat.div_eq_of_lt h0]

theorem rr_stay (m : ℕ) (a b : ℕ → ℤ) (t1 : ℕ) {t0 : ℕ} (h0 : t0 < 2 ^ m)
    (h : t0 ≠ 2 ^ m - 1) : rr m a b (2 ^ m * t1 + t0) = a t0 := by
  simp [rr_apply m a b t1 h0, h]

theorem rr_move (m : ℕ) (a b : ℕ → ℤ) (t1 : ℕ) :
    rr m a b (2 ^ m * t1 + (2 ^ m - 1)) = m + b t1 := by
  simp [rr_apply m a b t1 (Nat.sub_lt (Nat.two_pow_pos m) one_pos)]

theorem dr_stay (m : ℕ) (a b : ℕ → ℤ) (t1 : ℕ) {t0 : ℕ} (h0 : t0 < 2 ^ m)
    (h : t0 ≠ 0) (h' : t0 ≠ 2 ^ m - 1) : dr m a b (2 ^ m * t1 + t0) = a t0 := by
  simp [dr_apply m a b t1 h0, h, h']

theorem dr_move_black (m : ℕ) (a b : ℕ → ℤ) (t1 : ℕ) :
    dr m a b (2 ^ m * t1 + (2 ^ m - 1)) = m + b t1 := by
  simp [dr_apply m a b t1 (Nat.sub_lt (Nat.two_pow_pos m) one_pos)]

theorem dr_move_white (m : ℕ) (a b : ℕ → ℤ) (t1 : ℕ) :
    dr m a b (2 ^ m * t1 + 0) = m + b t1 := by
  rw [dr_apply m a b t1 (Nat.two_pow_pos m)]
  simp

/-! ### What a pair of stacks contributes, by what the two players do -/

section pairs

variable {m n : ℕ} {a b s : ℕ → ℤ} {t0 u0 t1 u1 : ℕ}

/-- Both players stay on the lowest hats. -/
theorem pair_low_low (ha : Proper m a) (ht : t0 < 2 ^ m) (hu : u0 < 2 ^ m)
    (hst : s (2 ^ m * t1 + t0) = a t0) (hsu : s (2 ^ m * u1 + u0) = a u0) :
    pair s (2 ^ m * t1 + t0) (2 ^ m * u1 + u0) = pair a t0 u0 := by
  have h1 := ha t0 ht
  have h2 := ha u0 hu
  simp [pair, hst, hsu, hat_low t1 ht h2.1 h2.2, hat_low u1 hu h1.1 h1.2]

/-- The player who sees `t` moves to the hats above; the other one stays. -/
theorem pair_high_low (ha : Proper m a) (hb : Proper n b) (ht1 : t1 < 2 ^ n)
    (ht : t0 < 2 ^ m) (hu : u0 < 2 ^ m)
    (hst : s (2 ^ m * t1 + t0) = m + b t1) (hsu : s (2 ^ m * u1 + u0) = a u0) :
    pair s (2 ^ m * t1 + t0) (2 ^ m * u1 + u0) = hat t0 (a u0) * hat u1 (b t1) := by
  have h2 := ha u0 hu
  have h3 := hb t1 ht1
  simp [pair, hst, hsu, hat_low t1 ht h2.1 h2.2, hat_above u1 hu h3.1]

/-- Both players move to the hats above. -/
theorem pair_high_high (hb : Proper n b) (ht1 : t1 < 2 ^ n) (hu1 : u1 < 2 ^ n)
    (ht : t0 < 2 ^ m) (hu : u0 < 2 ^ m)
    (hst : s (2 ^ m * t1 + t0) = m + b t1) (hsu : s (2 ^ m * u1 + u0) = m + b u1) :
    pair s (2 ^ m * t1 + t0) (2 ^ m * u1 + u0) = pair b t1 u1 := by
  have h3 := hb t1 ht1
  have h4 := hb u1 hu1
  simp [pair, hst, hsu, hat_above t1 ht h4.1, hat_above u1 hu h3.1]

theorem pair_comm (s : ℕ → ℤ) (t u : ℕ) : pair s t u = pair s u t := by
  simp [pair, mul_comm]

end pairs

/-- **Win rate after a right reset**, as a count of hits: if `a` is a
proper strategy on `m` hats and `b` a proper strategy on `n` hats, the
right reset of `a` by `b` has `4 ^ n * hits a + hits b` hits. -/
theorem hits_rr {m n : ℕ} {a b : ℕ → ℤ} (ha : Proper m a) (hb : Proper n b) :
    hits (m + n) (rr m a b) = 4 ^ n * hits m a + hits n b := by
  have hW : 2 ^ m - 1 < 2 ^ m := Nat.sub_lt (Nat.two_pow_pos m) one_pos
  have haW := ha _ hW
  -- two stacks other than the all-black one
  have k1 : ∀ t0 ∈ range (2 ^ m - 1), ∀ u0 ∈ range (2 ^ m - 1),
      ∑ t1 ∈ range (2 ^ n), ∑ u1 ∈ range (2 ^ n),
        pair (rr m a b) (2 ^ m * t1 + t0) (2 ^ m * u1 + u0) = 4 ^ n * pair a t0 u0 := by
    intro t0 ht0 u0 hu0
    have ht : t0 < 2 ^ m := lt_trans (mem_range.mp ht0) hW
    have hu : u0 < 2 ^ m := lt_trans (mem_range.mp hu0) hW
    have ht' : t0 ≠ 2 ^ m - 1 := (mem_range.mp ht0).ne
    have hu' : u0 ≠ 2 ^ m - 1 := (mem_range.mp hu0).ne
    rw [← sum_above_const]
    refine sum_congr rfl fun t1 _ => sum_congr rfl fun u1 _ => ?_
    exact pair_low_low ha ht hu (rr_stay m a b t1 ht ht') (rr_stay m a b u1 hu hu')
  -- the all-black stack on one side
  have k2 : ∀ u0 ∈ range (2 ^ m - 1),
      ∑ t1 ∈ range (2 ^ n), ∑ u1 ∈ range (2 ^ n),
        pair (rr m a b) (2 ^ m * t1 + (2 ^ m - 1)) (2 ^ m * u1 + u0) = 2 ^ n * 2 ^ (n - 1) := by
    intro u0 hu0
    have hu : u0 < 2 ^ m := lt_trans (mem_range.mp hu0) hW
    have hu' : u0 ≠ 2 ^ m - 1 := (mem_range.mp hu0).ne
    have h2 := ha u0 hu
    rw [← sum_above_one hb]
    refine sum_congr rfl fun t1 ht1 => sum_congr rfl fun u1 _ => ?_
    rw [pair_high_low ha hb (mem_range.mp ht1) hW hu
      (rr_move m a b t1) (rr_stay m a b u1 hu hu'), hat_ones h2.1 h2.2, one_mul]
  have k3 : ∀ t0 ∈ range (2 ^ m - 1),
      ∑ t1 ∈ range (2 ^ n), ∑ u1 ∈ range (2 ^ n),
        pair (rr m a b) (2 ^ m * t1 + t0) (2 ^ m * u1 + (2 ^ m - 1)) = 2 ^ n * 2 ^ (n - 1) := by
    intro t0 ht0
    rw [← k2 t0 ht0, sum_comm]
    exact sum_congr rfl fun u1 _ => sum_congr rfl fun t1 _ => pair_comm _ _ _
  -- the all-black stack on both sides
  have k4 : ∑ t1 ∈ range (2 ^ n), ∑ u1 ∈ range (2 ^ n),
      pair (rr m a b) (2 ^ m * t1 + (2 ^ m - 1)) (2 ^ m * u1 + (2 ^ m - 1)) = hits n b := by
    unfold hits
    refine sum_congr rfl fun t1 ht1 => sum_congr rfl fun u1 hu1 => ?_
    exact pair_high_high hb (mem_range.mp ht1) (mem_range.mp hu1) hW hW
      (rr_move m a b t1) (rr_move m a b u1)
  rw [hits_split, sum_peel2, k4, sum_congr rfl k3, sum_congr rfl k2,
    sum_congr rfl fun t0 ht0 => sum_congr rfl fun u0 hu0 => k1 t0 ht0 u0 hu0, hits_peel ha]
  simp only [sum_const, card_range, smul_eq_mul, ← mul_sum]
  have hE := two_mul_half hb.pos
  rw [← hE]
  ring

/-- **Win rate after a double reset**, as a count of hits: if `a` is a
proper strategy on `m` hats and `b` a proper strategy on `n` hats, the
hits of the double reset of `a` by `b`, plus `4 ^ n`, are
`4 ^ n * hits a + 4 * hits b`.  Divided by `4 ^ (m + n)`: its win rate is
that of `a`, plus four times that of `b` minus one, over `4 ^ m`. -/
theorem hits_dr {m n : ℕ} {a b : ℕ → ℤ} (ha : Proper m a) (hb : Proper n b) :
    hits (m + n) (dr m a b) + 4 ^ n = 4 ^ n * hits m a + 4 * hits n b := by
  have hW : 2 ^ m - 1 < 2 ^ m := Nat.sub_lt (Nat.two_pow_pos m) one_pos
  have hpos : 0 < 2 ^ m := Nat.two_pow_pos m
  have hW1 : 1 ≤ 2 ^ m - 1 := by
    have : 2 ^ 1 ≤ 2 ^ m := Nat.pow_le_pow_right (by norm_num) ha.pos
    omega
  -- two stacks other than the all-black one
  have k1 : ∀ t0 ∈ range (2 ^ m - 1), ∀ u0 ∈ range (2 ^ m - 1),
      ∑ t1 ∈ range (2 ^ n), ∑ u1 ∈ range (2 ^ n),
        pair (dr m a b) (2 ^ m * t1 + t0) (2 ^ m * u1 + u0)
          = 4 ^ n * pair a t0 u0 + if t0 = 0 then if u0 = 0 then hits n b else 0 else 0 := by
    intro t0 ht0 u0 hu0
    have ht : t0 < 2 ^ m := lt_trans (mem_range.mp ht0) hW
    have hu : u0 < 2 ^ m := lt_trans (mem_range.mp hu0) hW
    have ht' : t0 ≠ 2 ^ m - 1 := (mem_range.mp ht0).ne
    have hu' : u0 ≠ 2 ^ m - 1 := (mem_range.mp hu0).ne
    by_cases h0 : t0 = 0 <;> by_cases h1 : u0 = 0
    · subst h0; subst h1
      have : pair a 0 0 = 0 := by simp [pair, hat_zero]
      simp only [this, mul_zero, zero_add, ite_true]
      unfold hits
      refine sum_congr rfl fun t1 ht1 => sum_congr rfl fun u1 hu1 => ?_
      exact pair_high_high hb (mem_range.mp ht1) (mem_range.mp hu1) hpos hpos
        (dr_move_white m a b t1) (dr_move_white m a b u1)
    · subst h0
      have : pair a 0 u0 = 0 := by simp [pair, hat_zero]
      simp only [this, mul_zero, h1, ite_false, ite_true, add_zero]
      refine sum_eq_zero fun t1 ht1 => sum_eq_zero fun u1 _ => ?_
      have e := pair_high_low ha hb (mem_range.mp ht1) hpos hu
        (dr_move_white m a b t1) (dr_stay m a b u1 hu h1 hu')
      simpa [hat_zero] using e
    · subst h1
      have : pair a t0 0 = 0 := by simp [pair, hat_zero]
      simp only [this, mul_zero, h0, ite_false, add_zero]
      refine sum_eq_zero fun t1 _ => sum_eq_zero fun u1 hu1 => ?_
      have e := pair_high_low ha hb (mem_range.mp hu1) hpos ht
        (dr_move_white m a b u1) (dr_stay m a b t1 ht h0 ht')
      rw [pair_comm]
      simpa [hat_zero] using e
    · simp only [h0, ite_false, add_zero]
      rw [← sum_above_const]
      refine sum_congr rfl fun t1 _ => sum_congr rfl fun u1 _ => ?_
      exact pair_low_low ha ht hu (dr_stay m a b t1 ht h0 ht') (dr_stay m a b u1 hu h1 hu')
  -- the all-black stack on one side
  have k2 : ∀ u0 ∈ range (2 ^ m - 1),
      ∑ t1 ∈ range (2 ^ n), ∑ u1 ∈ range (2 ^ n),
        pair (dr m a b) (2 ^ m * t1 + (2 ^ m - 1)) (2 ^ m * u1 + u0)
          = if u0 = 0 then hits n b else 2 ^ n * 2 ^ (n - 1) := by
    intro u0 hu0
    have hu : u0 < 2 ^ m := lt_trans (mem_range.mp hu0) hW
    have hu' : u0 ≠ 2 ^ m - 1 := (mem_range.mp hu0).ne
    by_cases h1 : u0 = 0
    · subst h1
      simp only [ite_true]
      unfold hits
      refine sum_congr rfl fun t1 ht1 => sum_congr rfl fun u1 hu1 => ?_
      exact pair_high_high hb (mem_range.mp ht1) (mem_range.mp hu1) hW hpos
        (dr_move_black m a b t1) (dr_move_white m a b u1)
    · have h2 := ha u0 hu
      simp only [h1, ite_false]
      rw [← sum_above_one hb]
      refine sum_congr rfl fun t1 ht1 => sum_congr rfl fun u1 _ => ?_
      rw [pair_high_low ha hb (mem_range.mp ht1) hW hu
        (dr_move_black m a b t1) (dr_stay m a b u1 hu h1 hu'), hat_ones h2.1 h2.2, one_mul]
  have k3 : ∀ t0 ∈ range (2 ^ m - 1),
      ∑ t1 ∈ range (2 ^ n), ∑ u1 ∈ range (2 ^ n),
        pair (dr m a b) (2 ^ m * t1 + t0) (2 ^ m * u1 + (2 ^ m - 1))
          = if t0 = 0 then hits n b else 2 ^ n * 2 ^ (n - 1) := by
    intro t0 ht0
    rw [← k2 t0 ht0, sum_comm]
    exact sum_congr rfl fun u1 _ => sum_congr rfl fun t1 _ => pair_comm _ _ _
  -- the all-black stack on both sides
  have k4 : ∑ t1 ∈ range (2 ^ n), ∑ u1 ∈ range (2 ^ n),
      pair (dr m a b) (2 ^ m * t1 + (2 ^ m - 1)) (2 ^ m * u1 + (2 ^ m - 1)) = hits n b := by
    unfold hits
    refine sum_congr rfl fun t1 ht1 => sum_congr rfl fun u1 hu1 => ?_
    exact pair_high_high hb (mem_range.mp ht1) (mem_range.mp hu1) hW hW
      (dr_move_black m a b t1) (dr_move_black m a b u1)
  have hI := sum_ite_zero hW1 (hits n b) (2 ^ n * 2 ^ (n - 1))
  have hE := two_mul_half hb.pos
  rw [hits_split, sum_peel2, k4, sum_congr rfl k3, sum_congr rfl k2,
    sum_congr rfl fun t0 ht0 => sum_congr rfl fun u0 hu0 => k1 t0 ht0 u0 hu0, hits_peel ha]
  simp only [sum_add_distrib, ← mul_sum]
  rw [sum_congr rfl fun t0 _ => (by
    by_cases h : t0 = 0
    · simp only [h, ite_true]; exact sum_ite_zero' hW1 _
    · simp [h] : ∑ u0 ∈ range (2 ^ m - 1),
        (if t0 = 0 then if u0 = 0 then hits n b else 0 else 0)
          = if t0 = 0 then hits n b else 0), sum_ite_zero' hW1]
  rw [← hE] at *
  nlinarith [hI]

end Hats
