-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Reset2

/-!
# Substitution: every strategy is an operation

Let `m` be a strategy on `k + 1` hats and `s` a strategy on `n` hats.  The
substitution of `s` for the bottom hat of `m` is a strategy on `n + k`
hats:

* when the `n` lowest hats seen are not all of the same color, play `s` on
  them;
* when they are, read them as a single hat of that color under the `k`
  others and ask `m`: if `m` points at its bottom hat, play `s` on the `n`
  lowest hats; if it points at its hat `p`, point at the hat `n + p - 1`.

`hits_sub`: the result has `4 ^ k * hits s + hits m - 4 ^ k` hits.

The proof sorts the pairs of stacks by their `n` lowest hats.

* Both mixed: both players play `s`, and the pair counts as for `s`.
* Both of a single color: the pair counts as the pair of the two stacks of
  `k + 1` hats counts for `m`.
* The all-white stack and a mixed one: no hit, as for `s`.
* The all-black stack and a mixed one: whether the player who sees the
  all-black stack plays `s` or goes up, the hat pointed at is black for
  half of the stacks, less the all-black one.
-/

namespace Hats

open Finset

/-- What `m` says, on `n + k` hats: stay (and play `r`) or go up. -/
def subPoint (n : ℕ) (v r : ℤ) : ℤ := if v = 0 then r else n + (v - 1)

/-- `s` (a strategy on `n` hats) put in the place of the bottom hat of `m`. -/
def sub (n : ℕ) (m s : ℕ → ℤ) : ℕ → ℤ := fun t =>
  if t % 2 ^ n = 0 then subPoint n (m (2 * (t / 2 ^ n))) (s 0)
  else if t % 2 ^ n = 2 ^ n - 1 then subPoint n (m (2 * (t / 2 ^ n) + 1)) (s (2 ^ n - 1))
  else s (t % 2 ^ n)

/-- A sum over the numbers below `P`: the first and the last apart. -/
theorem sum_ends {P : ℕ} (hP : 2 ≤ P) (f : ℕ → ℕ) :
    ∑ t ∈ range P, f t = f 0 + f (P - 1) + ∑ t ∈ Ico 1 (P - 1), f t := by
  obtain ⟨Q, rfl⟩ : ∃ Q, P = Q + 2 := ⟨P - 2, by omega⟩
  rw [sum_range_succ, range_eq_Ico, sum_eq_sum_Ico_succ_bot (by omega)]
  simp
  ring

/-- The same for a sum over pairs. -/
theorem sum_ends2 {P : ℕ} (hP : 2 ≤ P) (f : ℕ → ℕ → ℕ) :
    ∑ t ∈ range P, ∑ u ∈ range P, f t u
      = f 0 0 + f 0 (P - 1) + f (P - 1) 0 + f (P - 1) (P - 1)
        + ∑ u ∈ Ico 1 (P - 1), (f 0 u + f (P - 1) u)
        + ∑ t ∈ Ico 1 (P - 1), (f t 0 + f t (P - 1))
        + ∑ t ∈ Ico 1 (P - 1), ∑ u ∈ Ico 1 (P - 1), f t u := by
  rw [sum_ends hP, sum_ends hP (f 0), sum_ends hP (f (P - 1)),
    sum_congr rfl fun t _ => sum_ends hP (f t)]
  simp only [sum_add_distrib]
  ring

section

variable {n k : ℕ} {m s : ℕ → ℤ}

theorem sub_mid (m s : ℕ → ℤ) (x : ℕ) {l : ℕ} (h1 : 0 < l) (h2 : l < 2 ^ n - 1) :
    sub n m s (2 ^ n * x + l) = s l := by
  have hmod : (2 ^ n * x + l) % 2 ^ n = l := by
    rw [Nat.mul_add_mod, Nat.mod_eq_of_lt (by omega)]
  have a : l ≠ 0 := by omega
  have b : l ≠ 2 ^ n - 1 := by omega
  simp [sub, hmod, a, b]

theorem sub_white (m s : ℕ → ℤ) (x : ℕ) :
    sub n m s (2 ^ n * x) = subPoint n (m (2 * x)) (s 0) := by
  have hdiv : 2 ^ n * x / 2 ^ n = x := Nat.mul_div_cancel_left x (Nat.two_pow_pos n)
  simp [sub, hdiv]

theorem sub_black (hn : 1 ≤ n) (m s : ℕ → ℤ) (x : ℕ) :
    sub n m s (2 ^ n * x + (2 ^ n - 1)) = subPoint n (m (2 * x + 1)) (s (2 ^ n - 1)) := by
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have hl : 2 ^ n - 1 < 2 ^ n := by omega
  have hmod : (2 ^ n * x + (2 ^ n - 1)) % 2 ^ n = 2 ^ n - 1 := by
    rw [Nat.mul_add_mod, Nat.mod_eq_of_lt hl]
  have hdiv : (2 ^ n * x + (2 ^ n - 1)) / 2 ^ n = x := by
    rw [Nat.mul_add_div (Nat.two_pow_pos n), Nat.div_eq_of_lt hl, add_zero]
  have hne : 2 ^ n - 1 ≠ 0 := by omega
  simp [sub, hmod, hdiv, hne]

/-- The two stacks of `n` hats of a single color: `c = 0` for white,
`c = 1` for black. -/
theorem sub_end (hn : 1 ≤ n) (m s : ℕ → ℤ) (x : ℕ) {c : ℕ} (hc : c < 2) :
    sub n m s (2 ^ n * x + c * (2 ^ n - 1))
      = subPoint n (m (2 * x + c)) (s (c * (2 ^ n - 1))) := by
  obtain rfl | rfl : c = 0 ∨ c = 1 := by omega
  · simpa using sub_white m s x
  · simpa using sub_black hn m s x

theorem end_lt {c : ℕ} (hc : c < 2) : c * (2 ^ n - 1) < 2 ^ n := by
  have := Nat.two_pow_pos n
  obtain rfl | rfl : c = 0 ∨ c = 1 := by omega
  · simp
  · omega

/-- The hats of a stack whose `n` lowest hats are of a single color, at
the position that `sub` points at: the hats of the stack of `k + 1` hats
that it stands for, at the position that `m` points at. -/
theorem hat_end (x : ℕ) {c : ℕ} (hc : c < 2) {v r : ℤ} (hv : 0 ≤ v)
    (hr : 0 ≤ r) (hrn : r < n) :
    hat (2 ^ n * x + c * (2 ^ n - 1)) (subPoint n v r) = hat (2 * x + c) v := by
  have hl := end_lt (n := n) hc
  by_cases h : v = 0
  · subst h
    have e : subPoint n 0 r = r := by simp [subPoint]
    rw [e, hat_low x hl hr hrn]
    obtain rfl | rfl : c = 0 ∨ c = 1 := by omega
    · simp [hat]
    · rw [one_mul, hat_ones hr hrn]
      simp [hat]
  · have e : subPoint n v r = n + (v - 1) := by simp [subPoint, h]
    rw [e, hat_above x hl (by omega)]
    have h1 := hat_above (m := 1) x (t0 := c) (by simpa using hc) (p := v - 1) (by omega)
    have e2 : ((1 : ℕ) : ℤ) + (v - 1) = v := by push_cast; ring
    rw [e2, pow_one] at h1
    exact h1.symm

/-- Among the stacks of `n` hats that are not of a single color, those
with a black hat at a given position. -/
theorem sum_mid_hat (hn : 1 ≤ n) {p : ℤ} (hp : 0 ≤ p) (hpn : p < n) :
    ∑ l ∈ Ico 1 (2 ^ n - 1), hat l p = 2 ^ (n - 1) - 1 := by
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have c := sum_hat hp hpn
  rw [sum_ends hP, hat_zero, hat_ones hp hpn] at c
  omega

variable (hs : Proper n s) (hm : Proper (k + 1) m)
include hs hm

/-- Two stacks whose `n` lowest hats are of a single color. -/
theorem pair_end_end {c c' x x' : ℕ} (hc : c < 2) (hc' : c' < 2)
    (hx : x < 2 ^ k) (hx' : x' < 2 ^ k) :
    pair (sub n m s) (2 ^ n * x + c * (2 ^ n - 1)) (2 ^ n * x' + c' * (2 ^ n - 1))
      = pair m (2 * x + c) (2 * x' + c') := by
  have hn := hs.pos
  have b : 2 * x + c < 2 ^ (k + 1) := by rw [pow_succ]; omega
  have b' : 2 * x' + c' < 2 ^ (k + 1) := by rw [pow_succ]; omega
  have r := hs _ (end_lt (n := n) hc)
  have r' := hs _ (end_lt (n := n) hc')
  unfold pair
  rw [sub_end hn m s x hc, sub_end hn m s x' hc',
    hat_end x hc (hm _ b').1 r'.1 r'.2, hat_end x' hc' (hm _ b).1 r.1 r.2]

/-- The all-black stack and the mixed ones, for one stack above the
all-black one. -/
theorem sum_black_mid {x : ℕ} (hx : x < 2 ^ k) :
    ∑ x' ∈ range (2 ^ k), ∑ l' ∈ Ico 1 (2 ^ n - 1),
      pair (sub n m s) (2 ^ n * x + (2 ^ n - 1)) (2 ^ n * x' + l')
      = 2 ^ k * (2 ^ (n - 1) - 1) := by
  have hn := hs.pos
  have hl : 2 ^ n - 1 < 2 ^ n := Nat.sub_lt (Nat.two_pow_pos n) one_pos
  have b : 2 * x + 1 < 2 ^ (k + 1) := by rw [pow_succ]; omega
  have hv := hm _ b
  have r := hs _ hl
  have term : ∀ x' ∈ range (2 ^ k), ∀ l' ∈ Ico 1 (2 ^ n - 1),
      pair (sub n m s) (2 ^ n * x + (2 ^ n - 1)) (2 ^ n * x' + l')
        = if m (2 * x + 1) = 0 then hat l' (s (2 ^ n - 1))
          else hat x' (m (2 * x + 1) - 1) := by
    intro x' _ l' hl'
    have h1 := (mem_Ico.mp hl').1
    have h2 := (mem_Ico.mp hl').2
    have hl'' : l' < 2 ^ n := by omega
    have r' := hs l' hl''
    unfold pair
    rw [sub_mid m s x' h1 h2, sub_black hn m s x, hat_low x hl r'.1 r'.2,
      hat_ones r'.1 r'.2, one_mul]
    by_cases h : m (2 * x + 1) = 0
    · simp [subPoint, h, hat_low x' hl'' r.1 r.2]
    · have e : subPoint n (m (2 * x + 1)) (s (2 ^ n - 1)) = n + (m (2 * x + 1) - 1) := by
        simp [subPoint, h]
      rw [e, hat_above x' hl'' (by omega)]
      simp [h]
  rw [sum_congr rfl fun x' hx' => sum_congr rfl fun l' hl' => term x' hx' l' hl']
  by_cases h : m (2 * x + 1) = 0
  · simp only [h, ↓reduceIte]
    rw [sum_congr rfl fun x' _ => sum_mid_hat hn r.1 r.2]
    simp
  · simp only [h, ↓reduceIte]
    have hq0 : 0 ≤ m (2 * x + 1) - 1 := by omega
    have hqk : m (2 * x + 1) - 1 < k := by have := hv.2; push_cast at this; omega
    simp only [sum_const, smul_eq_mul, Nat.card_Ico]
    rw [← mul_sum, sum_hat hq0 hqk]
    obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
    obtain ⟨i, rfl⟩ : ∃ i, n = i + 1 := ⟨n - 1, by omega⟩
    obtain ⟨a, ha⟩ : ∃ a, 2 ^ i = a + 1 := ⟨2 ^ i - 1, by have := Nat.two_pow_pos i; omega⟩
    simp only [Nat.add_sub_cancel, pow_succ, ha]
    have e1 : (a + 1) * 2 - 1 - 1 = 2 * a := by omega
    rw [e1]
    ring

/-- **Hits of a substitution.**  If `s` is a proper strategy on `n` hats
and `m` a proper strategy on `k + 1` hats, then `s` put in the place of the
bottom hat of `m` has `4 ^ k * hits s + hits m - 4 ^ k` hits. -/
theorem hits_sub : hits (n + k) (sub n m s) + 4 ^ k = 4 ^ k * hits n s + hits (k + 1) m := by
  have hn := hs.pos
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have hl : 2 ^ n - 1 < 2 ^ n := by omega
  have rB := hs _ hl
  have r0 := hs 0 (Nat.two_pow_pos n)
  -- what the substitution does, block by block
  -- two mixed stacks
  have kmm : ∀ l ∈ Ico 1 (2 ^ n - 1), ∀ l' ∈ Ico 1 (2 ^ n - 1),
      ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k),
        pair (sub n m s) (2 ^ n * x + l) (2 ^ n * x' + l') = 4 ^ k * pair s l l' := by
    intro l hl1 l' hl1'
    have h1 := mem_Ico.mp hl1
    have h1' := mem_Ico.mp hl1'
    rw [← sum_above_const]
    refine sum_congr rfl fun x _ => sum_congr rfl fun x' _ => ?_
    exact pair_low_low hs (by omega) (by omega) (sub_mid m s x h1.1 h1.2)
      (sub_mid m s x' h1'.1 h1'.2)
  -- the all-white stack and a mixed one
  have kwm : ∀ l' ∈ Ico 1 (2 ^ n - 1),
      ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k),
        pair (sub n m s) (2 ^ n * x + 0) (2 ^ n * x' + l') = 0 := by
    intro l' hl1'
    have h1' := mem_Ico.mp hl1'
    have r' := hs l' (by omega)
    refine sum_eq_zero fun x _ => sum_eq_zero fun x' _ => ?_
    unfold pair
    rw [sub_mid m s x' h1'.1 h1'.2, add_zero, hat_low_zero n x r'.1 r'.2, zero_mul]
  -- the all-black stack and the mixed ones
  have kbm : ∑ l' ∈ Ico 1 (2 ^ n - 1), ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k),
      pair (sub n m s) (2 ^ n * x + (2 ^ n - 1)) (2 ^ n * x' + l')
        = 4 ^ k * (2 ^ (n - 1) - 1) := by
    rw [sum_comm, sum_congr rfl fun x _ => sum_comm,
      sum_congr rfl fun x hx => sum_black_mid hs hm (mem_range.mp hx)]
    simp only [sum_const, card_range, smul_eq_mul, four_pow]
    ring
  -- exchanging the two stacks
  have swap : ∀ l l', ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k),
      pair (sub n m s) (2 ^ n * x + l) (2 ^ n * x' + l')
        = ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k),
          pair (sub n m s) (2 ^ n * x + l') (2 ^ n * x' + l) := by
    intro l l'
    rw [sum_comm]
    exact sum_congr rfl fun x _ => sum_congr rfl fun x' _ => pair_comm _ _ _
  -- two stacks of a single color
  have kee : ∀ c c', c < 2 → c' < 2 →
      ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k),
        pair (sub n m s) (2 ^ n * x + c * (2 ^ n - 1)) (2 ^ n * x' + c' * (2 ^ n - 1))
        = ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k), pair m (2 * x + c) (2 * x' + c') := by
    intro c c' hc hc'
    exact sum_congr rfl fun x hx => sum_congr rfl fun x' hx' =>
      pair_end_end hs hm hc hc' (mem_range.mp hx) (mem_range.mp hx')
  have k00 := kee 0 0 (by norm_num) (by norm_num)
  have k01 := kee 0 1 (by norm_num) (by norm_num)
  have k10 := kee 1 0 (by norm_num) (by norm_num)
  have k11 := kee 1 1 (by norm_num) (by norm_num)
  simp only [zero_mul, one_mul] at k00 k01 k10 k11
  -- the hits of `m`, by the bottom hats
  have em : hits (k + 1) m
      = ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k), pair m (2 * x + 0) (2 * x' + 0)
        + ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k), pair m (2 * x + 0) (2 * x' + 1)
        + ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k), pair m (2 * x + 1) (2 * x' + 0)
        + ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k), pair m (2 * x + 1) (2 * x' + 1) := by
    rw [show k + 1 = 1 + k from Nat.add_comm k 1, hits_split]
    simp only [pow_one, sum_range_succ, sum_range_zero, zero_add]
    ring
  -- the hits of `s`, the two stacks of a single color apart
  have es0 : ∀ u, pair s 0 u = 0 := by
    intro u; simp [pair, hat_zero]
  have esB : ∀ u ∈ Ico 1 (2 ^ n - 1), pair s (2 ^ n - 1) u = hat u (s (2 ^ n - 1)) := by
    intro u hu
    have h1 := mem_Ico.mp hu
    have r' := hs u (by omega)
    simp [pair, hat_ones r'.1 r'.2]
  have esBB : pair s (2 ^ n - 1) (2 ^ n - 1) = 1 := by
    simp [pair, hat_ones rB.1 rB.2]
  have hmid := sum_mid_hat hn rB.1 rB.2
  have es : hits n s = 1 + 2 * (2 ^ (n - 1) - 1)
      + ∑ t ∈ Ico 1 (2 ^ n - 1), ∑ u ∈ Ico 1 (2 ^ n - 1), pair s t u := by
    unfold hits
    rw [sum_ends2 hP]
    have a1 : ∑ u ∈ Ico 1 (2 ^ n - 1), (pair s 0 u + pair s (2 ^ n - 1) u)
        = 2 ^ (n - 1) - 1 := by
      rw [← hmid]
      refine sum_congr rfl fun u hu => ?_
      rw [es0, esB u hu, zero_add]
    have a2 : ∑ t ∈ Ico 1 (2 ^ n - 1), (pair s t 0 + pair s t (2 ^ n - 1))
        = 2 ^ (n - 1) - 1 := by
      rw [← hmid]
      refine sum_congr rfl fun u hu => ?_
      rw [pair_comm s u 0, pair_comm s u (2 ^ n - 1), es0, esB u hu, zero_add]
    rw [a1, a2, es0, es0, pair_comm s (2 ^ n - 1) 0, es0, esBB]
    ring
  -- the hits of the substitution
  rw [hits_split, sum_ends2 hP]
  have b1 : ∑ u ∈ Ico 1 (2 ^ n - 1),
      (∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k),
          pair (sub n m s) (2 ^ n * x + 0) (2 ^ n * x' + u)
        + ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k),
          pair (sub n m s) (2 ^ n * x + (2 ^ n - 1)) (2 ^ n * x' + u))
      = 4 ^ k * (2 ^ (n - 1) - 1) := by
    rw [sum_add_distrib, sum_congr rfl kwm, kbm]
    simp
  have b2 : ∑ t ∈ Ico 1 (2 ^ n - 1),
      (∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k),
          pair (sub n m s) (2 ^ n * x + t) (2 ^ n * x' + 0)
        + ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k),
          pair (sub n m s) (2 ^ n * x + t) (2 ^ n * x' + (2 ^ n - 1)))
      = 4 ^ k * (2 ^ (n - 1) - 1) := by
    rw [← b1]
    refine sum_congr rfl fun t _ => ?_
    rw [swap t 0, swap t (2 ^ n - 1)]
  rw [b1, b2, sum_congr rfl fun t ht => sum_congr rfl fun u hu => kmm t ht u hu,
    k00, k01, k10, k11, es, em]
  simp only [← mul_sum]
  ring

/-- A substitution of proper strategies is proper. -/
theorem sub_proper : Proper (n + k) (sub n m s) := by
  intro t _
  have hn := hs.pos
  have r := hs _ (Nat.mod_lt t (Nat.two_pow_pos n))
  have r0 := hs 0 (Nat.two_pow_pos n)
  have rB := hs (2 ^ n - 1) (Nat.sub_lt (Nat.two_pow_pos n) one_pos)
  have hq : t / 2 ^ n < 2 ^ k := by
    rwa [Nat.div_lt_iff_lt_mul (Nat.two_pow_pos n), mul_comm, ← pow_add]
  have v0 := hm (2 * (t / 2 ^ n)) (by rw [pow_succ]; omega)
  have v1 := hm (2 * (t / 2 ^ n) + 1) (by rw [pow_succ]; omega)
  unfold sub subPoint
  split_ifs <;> constructor <;> push_cast at * <;> omega

end

end Hats
