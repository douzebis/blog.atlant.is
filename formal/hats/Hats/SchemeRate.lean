-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Schemes
import Hats.Reset2
import Hats.Rates

/-!
# The win rate of a scheme (Proposition 14 of the article)

A scheme on blocks of `m` hats: a set `Z` of skipped stacks and a strategy
`a`.  `sr m Z a b` plays `a` on the `m` lowest hats unless they make a
stack of `Z`, and then plays `b` on the hats above.  `schemeChain` repeats
this: the scheme on `j + 1` blocks.

* `hits_sr`: `4 ^ k * schemeScore + |Z| ^ 2 * hits b`;
* `tendsto_rate_schemeChain`: the win rates of the scheme on more and more
  blocks tend to `schemeScore / (4 ^ m - |Z| ^ 2)`.
-/

namespace Hats

open Finset Filter Topology

/-- `a` (on `m` hats), with the stacks of `Z` skipped: on those, play `b`
on the hats above. -/
def sr (m : ℕ) (Z : Finset ℕ) (a b : ℕ → ℤ) : ℕ → ℤ := fun t =>
  if t % 2 ^ m ∈ Z then m + b (t / 2 ^ m) else a (t % 2 ^ m)

theorem sr_stay (m : ℕ) (Z : Finset ℕ) (a b : ℕ → ℤ) (t1 : ℕ) {t0 : ℕ} (h0 : t0 < 2 ^ m)
    (h : t0 ∉ Z) : sr m Z a b (2 ^ m * t1 + t0) = a t0 := by
  simp [sr, Nat.mod_eq_of_lt h0, h]

theorem sr_move (m : ℕ) (Z : Finset ℕ) (a b : ℕ → ℤ) (t1 : ℕ) {t0 : ℕ} (h0 : t0 < 2 ^ m)
    (h : t0 ∈ Z) : sr m Z a b (2 ^ m * t1 + t0) = m + b t1 := by
  have hpos := Nat.two_pow_pos m
  simp [sr, Nat.mod_eq_of_lt h0, h, Nat.mul_add_div hpos, Nat.div_eq_of_lt h0]

theorem sr_proper {m k : ℕ} {Z : Finset ℕ} {a b : ℕ → ℤ} (ha : Proper m a) (hb : Proper k b) :
    Proper (m + k) (sr m Z a b) := by
  intro t ht
  have hpos := Nat.two_pow_pos m
  have x := ha _ (Nat.mod_lt t hpos)
  have hq : t / 2 ^ m < 2 ^ k := by
    rwa [Nat.div_lt_iff_lt_mul hpos, mul_comm, ← pow_add]
  have y := hb _ hq
  unfold sr
  split_ifs <;> constructor <;> push_cast <;> omega

/-- **The hits of one step of a scheme.** -/
theorem hits_sr {m k : ℕ} {Z : Finset ℕ} {a b : ℕ → ℤ} (hZ : Z ⊆ range (2 ^ m))
    (ha : Proper m a) (hb : Proper k b) :
    hits (m + k) (sr m Z a b) = 4 ^ k * schemeScore m Z a + Z.card ^ 2 * hits k b := by
  have hk := hb.pos
  have lt_of_mem : ∀ {t}, t ∈ range (2 ^ m) \ Z → t < 2 ^ m := fun h =>
    mem_range.mp (mem_sdiff.mp h).1
  have lt_of_memZ : ∀ {t}, t ∈ Z → t < 2 ^ m := fun h => mem_range.mp (hZ h)
  -- neither stack is skipped
  have k1 : ∀ t0 ∈ range (2 ^ m) \ Z, ∀ u0 ∈ range (2 ^ m) \ Z,
      ∑ t1 ∈ range (2 ^ k), ∑ u1 ∈ range (2 ^ k),
        pair (sr m Z a b) (2 ^ m * t1 + t0) (2 ^ m * u1 + u0) = 4 ^ k * pair a t0 u0 := by
    intro t0 ht0 u0 hu0
    rw [← sum_above_const]
    refine sum_congr rfl fun t1 _ => sum_congr rfl fun u1 _ => ?_
    exact pair_low_low ha (lt_of_mem ht0) (lt_of_mem hu0)
      (sr_stay m Z a b t1 (lt_of_mem ht0) (mem_sdiff.mp ht0).2)
      (sr_stay m Z a b u1 (lt_of_mem hu0) (mem_sdiff.mp hu0).2)
  -- the stack `t` is skipped, the stack `u` is not
  have k2 : ∀ t0 ∈ Z, ∀ u0 ∈ range (2 ^ m) \ Z,
      ∑ t1 ∈ range (2 ^ k), ∑ u1 ∈ range (2 ^ k),
        pair (sr m Z a b) (2 ^ m * t1 + t0) (2 ^ m * u1 + u0)
        = 2 ^ k * 2 ^ (k - 1) * hat t0 (a u0) := by
    intro t0 ht0 u0 hu0
    rw [← sum_above_one hb, sum_mul]
    refine sum_congr rfl fun t1 ht1 => ?_
    rw [sum_mul]
    refine sum_congr rfl fun u1 _ => ?_
    rw [pair_high_low ha hb (mem_range.mp ht1) (lt_of_memZ ht0) (lt_of_mem hu0)
      (sr_move m Z a b t1 (lt_of_memZ ht0) ht0)
      (sr_stay m Z a b u1 (lt_of_mem hu0) (mem_sdiff.mp hu0).2)]
    ring
  have k3 : ∀ t0 ∈ range (2 ^ m) \ Z, ∀ u0 ∈ Z,
      ∑ t1 ∈ range (2 ^ k), ∑ u1 ∈ range (2 ^ k),
        pair (sr m Z a b) (2 ^ m * t1 + t0) (2 ^ m * u1 + u0)
        = 2 ^ k * 2 ^ (k - 1) * hat u0 (a t0) := by
    intro t0 ht0 u0 hu0
    rw [← k2 u0 hu0 t0 ht0, sum_comm]
    exact sum_congr rfl fun u1 _ => sum_congr rfl fun t1 _ => pair_comm _ _ _
  -- both are skipped
  have k4 : ∀ t0 ∈ Z, ∀ u0 ∈ Z,
      ∑ t1 ∈ range (2 ^ k), ∑ u1 ∈ range (2 ^ k),
        pair (sr m Z a b) (2 ^ m * t1 + t0) (2 ^ m * u1 + u0) = hits k b := by
    intro t0 ht0 u0 hu0
    unfold hits
    refine sum_congr rfl fun t1 ht1 => sum_congr rfl fun u1 hu1 => ?_
    exact pair_high_high hb (mem_range.mp ht1) (mem_range.mp hu1) (lt_of_memZ ht0)
      (lt_of_memZ hu0) (sr_move m Z a b t1 (lt_of_memZ ht0) ht0)
      (sr_move m Z a b u1 (lt_of_memZ hu0) hu0)
  have split : ∀ f : ℕ → ℕ, ∑ t ∈ range (2 ^ m), f t
      = ∑ t ∈ range (2 ^ m) \ Z, f t + ∑ t ∈ Z, f t := fun f => (sum_sdiff hZ).symm
  have inner1 : ∀ t0 ∈ range (2 ^ m) \ Z,
      ∑ u0 ∈ range (2 ^ m), ∑ t1 ∈ range (2 ^ k), ∑ u1 ∈ range (2 ^ k),
        pair (sr m Z a b) (2 ^ m * t1 + t0) (2 ^ m * u1 + u0)
      = 4 ^ k * ∑ u0 ∈ range (2 ^ m) \ Z, pair a t0 u0
        + 2 ^ k * 2 ^ (k - 1) * ∑ u0 ∈ Z, hat u0 (a t0) := by
    intro t0 ht0
    rw [split, sum_congr rfl (k1 t0 ht0), sum_congr rfl (k3 t0 ht0), mul_sum, mul_sum]
  have inner2 : ∀ t0 ∈ Z,
      ∑ u0 ∈ range (2 ^ m), ∑ t1 ∈ range (2 ^ k), ∑ u1 ∈ range (2 ^ k),
        pair (sr m Z a b) (2 ^ m * t1 + t0) (2 ^ m * u1 + u0)
      = 2 ^ k * 2 ^ (k - 1) * ∑ u0 ∈ range (2 ^ m) \ Z, hat t0 (a u0)
        + Z.card * hits k b := by
    intro t0 ht0
    rw [split, sum_congr rfl (k2 t0 ht0), sum_congr rfl (k4 t0 ht0), mul_sum]
    simp
  have hE := two_mul_half hk
  rw [hits_split, split, sum_congr rfl inner1, sum_congr rfl inner2]
  unfold schemeScore
  simp only [sum_add_distrib, sum_const, smul_eq_mul, ← mul_sum]
  have sym : ∑ t ∈ range (2 ^ m) \ Z, ∑ u ∈ range (2 ^ m) \ Z, pair a t u
      = ∑ u ∈ range (2 ^ m) \ Z, ∑ t ∈ range (2 ^ m) \ Z, pair a t u := sum_comm
  have c2 : ∑ t ∈ Z, ∑ u ∈ range (2 ^ m) \ Z, hat t (a u)
      = ∑ u ∈ range (2 ^ m) \ Z, ∑ t ∈ Z, hat t (a u) := sum_comm
  rw [sym, c2]
  generalize ∑ u ∈ range (2 ^ m) \ Z, ∑ t ∈ range (2 ^ m) \ Z, pair a t u = A
  generalize ∑ u ∈ range (2 ^ m) \ Z, ∑ t ∈ Z, hat t (a u) = C
  rw [← hE]
  ring

/-- The scheme on `j + 1` blocks. -/
def schemeChain (m : ℕ) (Z : Finset ℕ) (a : ℕ → ℤ) : ℕ → ℕ → ℤ
  | 0 => a
  | j + 1 => sr m Z a (schemeChain m Z a j)

section

variable {m : ℕ} {Z : Finset ℕ} {a : ℕ → ℤ} (hZ : Z ⊆ range (2 ^ m)) (ha : Proper m a)
include ha

theorem schemeChain_proper : ∀ j, Proper (m * (j + 1)) (schemeChain m Z a j)
  | 0 => by simpa [schemeChain] using ha
  | j + 1 => by
    have h := sr_proper (Z := Z) ha (schemeChain_proper j)
    rw [show m * (j + 1 + 1) = m + m * (j + 1) by ring]
    exact h

include hZ

theorem hits_schemeChain (j : ℕ) :
    hits (m * (j + 2)) (schemeChain m Z a (j + 1))
      = 4 ^ (m * (j + 1)) * schemeScore m Z a
        + Z.card ^ 2 * hits (m * (j + 1)) (schemeChain m Z a j) := by
  have h := hits_sr hZ ha (schemeChain_proper (Z := Z) ha j)
  rw [show m * (j + 2) = m + m * (j + 1) by ring]
  exact h

theorem rate_schemeChain_succ (j : ℕ) :
    rate (m * (j + 2)) (schemeChain m Z a (j + 1))
      = (schemeScore m Z a : ℝ) / 4 ^ m
        + (Z.card : ℝ) ^ 2 / 4 ^ m * rate (m * (j + 1)) (schemeChain m Z a j) := by
  have h := hits_schemeChain hZ ha j
  have h' : (hits (m * (j + 2)) (schemeChain m Z a (j + 1)) : ℝ)
      = 4 ^ (m * (j + 1)) * (schemeScore m Z a : ℝ)
        + (Z.card : ℝ) ^ 2 * (hits (m * (j + 1)) (schemeChain m Z a j) : ℝ) := by
    exact_mod_cast h
  have e : (4 : ℝ) ^ (m * (j + 2)) = 4 ^ m * 4 ^ (m * (j + 1)) := by
    rw [← pow_add]; congr 1; ring
  have p1 : (0 : ℝ) < 4 ^ m := by positivity
  have p2 : (0 : ℝ) < 4 ^ (m * (j + 1)) := by positivity
  unfold rate
  rw [e, h']
  field_simp

/-- **The win rate of a scheme** that does not skip every stack: the win
rates on more and more blocks tend to `schemeScore / (4 ^ m - |Z| ^ 2)`. -/
theorem tendsto_rate_schemeChain (hlt : Z.card < 2 ^ m) :
    Tendsto (fun j => rate (m * (j + 1)) (schemeChain m Z a j)) atTop
      (𝓝 ((schemeScore m Z a : ℝ) / (4 ^ m - (Z.card : ℝ) ^ 2))) := by
  have hc : (Z.card : ℝ) ^ 2 < 4 ^ m := by
    have h : Z.card ^ 2 < (2 ^ m) ^ 2 := Nat.pow_lt_pow_left hlt (by norm_num)
    have e : ((2 : ℕ) ^ m) ^ 2 = 4 ^ m := by rw [← pow_mul, mul_comm, pow_mul]; norm_num
    rw [e] at h
    exact_mod_cast h
  have p1 : (0 : ℝ) < 4 ^ m := by positivity
  have q0 : (0 : ℝ) ≤ (Z.card : ℝ) ^ 2 / 4 ^ m := by positivity
  have q1 : (Z.card : ℝ) ^ 2 / 4 ^ m < 1 := by rw [div_lt_one p1]; exact hc
  set L : ℝ := (schemeScore m Z a : ℝ) / (4 ^ m - (Z.card : ℝ) ^ 2) with hL
  have hLq : L = (schemeScore m Z a : ℝ) / 4 ^ m + (Z.card : ℝ) ^ 2 / 4 ^ m * L := by
    have hd : (4 : ℝ) ^ m - (Z.card : ℝ) ^ 2 ≠ 0 := by linarith
    have p1' : (4 : ℝ) ^ m ≠ 0 := ne_of_gt p1
    rw [hL]
    field_simp
    ring
  have closed : ∀ j, rate (m * (j + 1)) (schemeChain m Z a j)
      = L + ((Z.card : ℝ) ^ 2 / 4 ^ m) ^ j * (rate (m * 1) (schemeChain m Z a 0) - L) := by
    intro j
    induction j with
    | zero => simp
    | succ j ih =>
      rw [show j + 1 + 1 = j + 2 from rfl, rate_schemeChain_succ hZ ha, ih, pow_succ]
      linear_combination (-1 : ℝ) * hLq
  have t := (tendsto_pow_atTop_nhds_zero_of_lt_one q0 q1).mul_const
    (rate (m * 1) (schemeChain m Z a 0) - L)
  have t' := t.const_add L
  simp only [zero_mul, add_zero] at t'
  exact t'.congr fun j => (closed j).symm

end

end Hats
