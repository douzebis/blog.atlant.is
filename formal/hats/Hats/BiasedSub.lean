-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Biased
import Hats.Substitute

/-!
# Substitution when hats are black with probability `p`

`val_sub`: the value of `s` (on `n` hats) put in the place of the bottom
hat of `m` (on `k + 1` hats) is the value of `s`, plus a gain that depends
on `m` through five numbers only: the values `bottomVal` of `m` among the
pairs of stacks with given bottom hats, and the probability `stayProb`
that `m` points at the bottom hat when it sees a black one.

With `p = 1 / 2` the last term vanishes and this is `hits_sub`.
-/

namespace Hats

open Finset

theorem sum_endsR {P : ℕ} (hP : 2 ≤ P) (f : ℕ → ℝ) :
    ∑ t ∈ range P, f t = f 0 + f (P - 1) + ∑ t ∈ Ico 1 (P - 1), f t := by
  obtain ⟨Q, rfl⟩ : ∃ Q, P = Q + 2 := ⟨P - 2, by omega⟩
  rw [sum_range_succ, range_eq_Ico, sum_eq_sum_Ico_succ_bot (by omega)]
  simp
  ring

theorem sum_ends2R {P : ℕ} (hP : 2 ≤ P) (f : ℕ → ℕ → ℝ) :
    ∑ t ∈ range P, ∑ u ∈ range P, f t u
      = f 0 0 + f 0 (P - 1) + f (P - 1) 0 + f (P - 1) (P - 1)
        + ∑ u ∈ Ico 1 (P - 1), (f 0 u + f (P - 1) u)
        + ∑ t ∈ Ico 1 (P - 1), (f t 0 + f t (P - 1))
        + ∑ t ∈ Ico 1 (P - 1), ∑ u ∈ Ico 1 (P - 1), f t u := by
  rw [sum_endsR hP, sum_endsR hP (f 0), sum_endsR hP (f (P - 1)),
    sum_congr rfl fun t _ => sum_endsR hP (f t)]
  simp only [sum_add_distrib]
  ring

/-- The probability that `n` hats are all black. -/
theorem wt_ones (p : ℝ) (n : ℕ) : wt p n (2 ^ n - 1) = p ^ n := by
  unfold wt
  have each : ∀ j ∈ range n, (if (2 ^ n - 1).testBit j then p else 1 - p) = p := by
    intro j hj
    simp [Nat.testBit_two_pow_sub_one, mem_range.mp hj]
  rw [prod_congr rfl each]
  simp

/-- The value of `m`, on `k + 1` hats, among the pairs of stacks whose
bottom hats have the colors `c` and `c'`; the two bottom hats do not count
in the probability. -/
noncomputable def bottomVal (p : ℝ) (k : ℕ) (m : ℕ → ℤ) (c c' : ℕ) : ℝ :=
  ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k),
    wt p k x * wt p k x' * (pair m (2 * x + c) (2 * x' + c') : ℝ)

/-- The probability that `m` points at the bottom hat when the bottom hat
seen is black. -/
noncomputable def stayProb (p : ℝ) (k : ℕ) (m : ℕ → ℤ) : ℝ :=
  ∑ x ∈ range (2 ^ k), wt p k x * if m (2 * x + 1) = 0 then 1 else 0

section

variable {n k : ℕ} {m s : ℕ → ℤ} (p : ℝ)

/-- What the pairs of stacks with the lower parts `l` and `l'` contribute. -/
noncomputable def blockVal (n k : ℕ) (σ : ℕ → ℤ) (l l' : ℕ) : ℝ :=
  ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k),
    wt p (n + k) (2 ^ n * x + l) * wt p (n + k) (2 ^ n * x' + l')
      * (pair σ (2 ^ n * x + l) (2 ^ n * x' + l') : ℝ)

theorem blockVal_eq (σ : ℕ → ℤ) {l l' : ℕ} (hl : l < 2 ^ n) (hl' : l' < 2 ^ n)
    (g : ℕ → ℕ → ℝ)
    (hg : ∀ x ∈ range (2 ^ k), ∀ x' ∈ range (2 ^ k),
      (pair σ (2 ^ n * x + l) (2 ^ n * x' + l') : ℝ) = g x x') :
    blockVal p n k σ l l'
      = wt p n l * wt p n l'
        * ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k), wt p k x * wt p k x' * g x x' := by
  unfold blockVal
  simp only [mul_sum]
  refine sum_congr rfl fun x hx => sum_congr rfl fun x' hx' => ?_
  rw [wt_split p k x hl, wt_split p k x' hl', hg x hx x' hx']
  ring

theorem sum_wt2 (k : ℕ) (c : ℝ) :
    ∑ x ∈ range (2 ^ k), ∑ x' ∈ range (2 ^ k), wt p k x * wt p k x' * c = c := by
  simp only [← sum_mul, ← mul_sum, wt_sum, mul_one, one_mul]

theorem blockVal_swap (σ : ℕ → ℤ) (l l' : ℕ) :
    blockVal p n k σ l l' = blockVal p n k σ l' l := by
  unfold blockVal
  rw [sum_comm]
  refine sum_congr rfl fun x _ => sum_congr rfl fun x' _ => ?_
  rw [pair_comm σ]
  ring

/-- Among the stacks of `n` hats that are not of a single color, the
probability of a black hat at a given position. -/
theorem wsum_mid_hat (hn : 1 ≤ n) {j : ℤ} (hj : 0 ≤ j) (hjn : j < n) :
    ∑ l ∈ Ico 1 (2 ^ n - 1), wt p n l * (hat l j : ℝ) = p - p ^ n := by
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have c := wsum_hat p hj hjn
  rw [sum_endsR hP, hat_zero, hat_ones hj hjn, wt_ones] at c
  push_cast at c
  linarith

/-- The probability that `n` hats are not of a single color. -/
theorem wsum_mid (hn : 1 ≤ n) :
    ∑ l ∈ Ico 1 (2 ^ n - 1), wt p n l = 1 - (1 - p) ^ n - p ^ n := by
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have c := wt_sum p n
  rw [sum_endsR hP, wt_zero, wt_ones] at c
  linarith

variable (hs : Proper n s) (hm : Proper (k + 1) m)
include hs hm

/-- **The value of a substitution.** -/
theorem val_sub :
    val p (n + k) (sub n m s)
      = val p n s - p ^ (2 * n)
        + (1 - p) ^ (2 * n) * bottomVal p k m 0 0
        + (p * (1 - p)) ^ n * (bottomVal p k m 0 1 + bottomVal p k m 1 0)
        + p ^ (2 * n) * bottomVal p k m 1 1
        - 2 * p ^ n * (1 - stayProb p k m)
          * ((p - p ^ n) - p * (1 - (1 - p) ^ n - p ^ n)) := by
  have hn := hs.pos
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have hz : 0 < 2 ^ n := by omega
  have hB : 2 ^ n - 1 < 2 ^ n := by omega
  have rB := hs _ hB
  -- two mixed stacks
  have kmm : ∀ l ∈ Ico 1 (2 ^ n - 1), ∀ l' ∈ Ico 1 (2 ^ n - 1),
      blockVal p n k (sub n m s) l l' = wt p n l * wt p n l' * (pair s l l' : ℝ) := by
    intro l hl l' hl'
    have h1 := mem_Ico.mp hl
    have h1' := mem_Ico.mp hl'
    rw [blockVal_eq p _ (by omega) (by omega) (fun _ _ => (pair s l l' : ℝ)) fun x _ x' _ => by
      rw [pair_low_low hs (by omega) (by omega) (sub_mid m s x h1.1 h1.2)
        (sub_mid m s x' h1'.1 h1'.2)], sum_wt2]
  -- the all-white stack and a mixed one
  have kwm : ∀ l' ∈ Ico 1 (2 ^ n - 1), blockVal p n k (sub n m s) 0 l' = 0 := by
    intro l' hl'
    have h1' := mem_Ico.mp hl'
    have r' := hs l' (by omega)
    rw [blockVal_eq p _ hz (by omega) (fun _ _ => 0) fun x _ x' _ => by
      unfold pair
      rw [sub_mid m s x' h1'.1 h1'.2, add_zero, hat_low_zero n x r'.1 r'.2, zero_mul]
      simp]
    simp
  -- the all-black stack and a mixed one
  have kbm : ∀ l' ∈ Ico 1 (2 ^ n - 1), blockVal p n k (sub n m s) (2 ^ n - 1) l'
      = p ^ n * wt p n l' * (stayProb p k m * (hat l' (s (2 ^ n - 1)) : ℝ)
        + (1 - stayProb p k m) * p) := by
    intro l' hl'
    have h1 := (mem_Ico.mp hl').1
    have h2 := (mem_Ico.mp hl').2
    have hl'' : l' < 2 ^ n := by omega
    have r' := hs l' hl''
    have term : ∀ x ∈ range (2 ^ k), ∀ x' ∈ range (2 ^ k),
        (pair (sub n m s) (2 ^ n * x + (2 ^ n - 1)) (2 ^ n * x' + l') : ℝ)
          = if m (2 * x + 1) = 0 then (hat l' (s (2 ^ n - 1)) : ℝ)
            else (hat x' (m (2 * x + 1) - 1) : ℝ) := by
      intro x hx x' _
      have b : 2 * x + 1 < 2 ^ (k + 1) := by rw [pow_succ]; have := mem_range.mp hx; omega
      have hv := hm _ b
      unfold pair
      rw [sub_mid m s x' h1 h2, sub_black hn m s x, hat_low x hB r'.1 r'.2,
        hat_ones r'.1 r'.2, one_mul]
      by_cases h : m (2 * x + 1) = 0
      · simp [subPoint, h, hat_low x' hl'' rB.1 rB.2]
      · have e : subPoint n (m (2 * x + 1)) (s (2 ^ n - 1)) = n + (m (2 * x + 1) - 1) := by
          simp [subPoint, h]
        rw [e, hat_above x' hl'' (by omega)]
        simp [h]
    rw [blockVal_eq p _ hB hl'' _ term, wt_ones]
    have inner : ∀ x ∈ range (2 ^ k),
        ∑ x' ∈ range (2 ^ k), wt p k x * wt p k x'
          * (if m (2 * x + 1) = 0 then (hat l' (s (2 ^ n - 1)) : ℝ)
            else (hat x' (m (2 * x + 1) - 1) : ℝ))
        = wt p k x * ((if m (2 * x + 1) = 0 then 1 else 0) * (hat l' (s (2 ^ n - 1)) : ℝ)
          + (1 - if m (2 * x + 1) = 0 then 1 else 0) * p) := by
      intro x hx
      have b : 2 * x + 1 < 2 ^ (k + 1) := by rw [pow_succ]; have := mem_range.mp hx; omega
      have hv := hm _ b
      by_cases h : m (2 * x + 1) = 0
      · simp only [h, ↓reduceIte]
        have e : ∑ x' ∈ range (2 ^ k), wt p k x * wt p k x' * (hat l' (s (2 ^ n - 1)) : ℝ)
            = wt p k x * (hat l' (s (2 ^ n - 1)) : ℝ) * ∑ x' ∈ range (2 ^ k), wt p k x' := by
          rw [mul_sum]
          exact sum_congr rfl fun _ _ => by ring
        rw [e, wt_sum]
        ring
      · simp only [h, ↓reduceIte]
        have w := wsum_hat p (show 0 ≤ m (2 * x + 1) - 1 by omega)
          (show m (2 * x + 1) - 1 < k by have := hv.2; push_cast at this; omega)
        have e : ∑ x' ∈ range (2 ^ k), wt p k x * wt p k x' * (hat x' (m (2 * x + 1) - 1) : ℝ)
            = wt p k x * ∑ x' ∈ range (2 ^ k), wt p k x' * (hat x' (m (2 * x + 1) - 1) : ℝ) := by
          rw [mul_sum]
          exact sum_congr rfl fun _ _ => by ring
        rw [e, w]
        ring
    rw [sum_congr rfl inner]
    unfold stayProb
    have e : ∑ x ∈ range (2 ^ k), wt p k x
          * ((if m (2 * x + 1) = 0 then 1 else 0) * (hat l' (s (2 ^ n - 1)) : ℝ)
            + (1 - if m (2 * x + 1) = 0 then 1 else 0) * p)
        = (∑ x ∈ range (2 ^ k), wt p k x * if m (2 * x + 1) = 0 then 1 else 0)
            * (hat l' (s (2 ^ n - 1)) : ℝ)
          + (∑ x ∈ range (2 ^ k), wt p k x
            - ∑ x ∈ range (2 ^ k), wt p k x * if m (2 * x + 1) = 0 then 1 else 0) * p := by
      rw [sum_mul, ← sum_sub_distrib, sum_mul, ← sum_add_distrib]
      exact sum_congr rfl fun x _ => by ring
    rw [e, wt_sum]
  -- two stacks of a single color
  have kee : ∀ c c', c < 2 → c' < 2 →
      blockVal p n k (sub n m s) (c * (2 ^ n - 1)) (c' * (2 ^ n - 1))
        = wt p n (c * (2 ^ n - 1)) * wt p n (c' * (2 ^ n - 1)) * bottomVal p k m c c' := by
    intro c c' hc hc'
    exact blockVal_eq p _ (end_lt hc) (end_lt hc') _ fun x hx x' hx' => by
      rw [pair_end_end hs hm hc hc' (mem_range.mp hx) (mem_range.mp hx')]
  have k00 := kee 0 0 (by norm_num) (by norm_num)
  have k01 := kee 0 1 (by norm_num) (by norm_num)
  have k10 := kee 1 0 (by norm_num) (by norm_num)
  have k11 := kee 1 1 (by norm_num) (by norm_num)
  simp only [zero_mul, one_mul, wt_zero, wt_ones] at k00 k01 k10 k11
  -- the sums over the mixed stacks
  have sB : ∑ l' ∈ Ico 1 (2 ^ n - 1), blockVal p n k (sub n m s) (2 ^ n - 1) l'
      = p ^ n * (stayProb p k m * (p - p ^ n)
        + (1 - stayProb p k m) * p * (1 - (1 - p) ^ n - p ^ n)) := by
    have e : ∑ l' ∈ Ico 1 (2 ^ n - 1), p ^ n * wt p n l'
          * (stayProb p k m * (hat l' (s (2 ^ n - 1)) : ℝ) + (1 - stayProb p k m) * p)
        = p ^ n * stayProb p k m
            * ∑ l' ∈ Ico 1 (2 ^ n - 1), wt p n l' * (hat l' (s (2 ^ n - 1)) : ℝ)
          + p ^ n * (1 - stayProb p k m) * p * ∑ l' ∈ Ico 1 (2 ^ n - 1), wt p n l' := by
      rw [mul_sum, mul_sum, ← sum_add_distrib]
      exact sum_congr rfl fun l' _ => by ring
    rw [sum_congr rfl kbm, e, wsum_mid_hat p hn rB.1 rB.2, wsum_mid p hn]
    ring
  -- the value of `s`, the two stacks of a single color apart
  have es : val p n s = p ^ (2 * n) + 2 * (p ^ n * (p - p ^ n))
      + ∑ l ∈ Ico 1 (2 ^ n - 1), ∑ l' ∈ Ico 1 (2 ^ n - 1),
        wt p n l * wt p n l' * (pair s l l' : ℝ) := by
    have es0 : ∀ u, pair s 0 u = 0 := fun u => by simp [pair, hat_zero]
    have esB : ∀ u ∈ Ico 1 (2 ^ n - 1), pair s (2 ^ n - 1) u = hat u (s (2 ^ n - 1)) := by
      intro u hu
      have h1 := mem_Ico.mp hu
      have r' := hs u (by omega)
      simp [pair, hat_ones r'.1 r'.2]
    have esBB : pair s (2 ^ n - 1) (2 ^ n - 1) = 1 := by
      simp [pair, hat_ones rB.1 rB.2]
    unfold val
    rw [sum_ends2R hP]
    have a1 : ∑ u ∈ Ico 1 (2 ^ n - 1), (wt p n 0 * wt p n u * (pair s 0 u : ℝ)
        + wt p n (2 ^ n - 1) * wt p n u * (pair s (2 ^ n - 1) u : ℝ))
        = p ^ n * (p - p ^ n) := by
      rw [← wsum_mid_hat p hn rB.1 rB.2, mul_sum]
      refine sum_congr rfl fun u hu => ?_
      rw [es0, esB u hu, wt_ones]
      push_cast
      ring
    have a2 : ∑ t ∈ Ico 1 (2 ^ n - 1), (wt p n t * wt p n 0 * (pair s t 0 : ℝ)
        + wt p n t * wt p n (2 ^ n - 1) * (pair s t (2 ^ n - 1) : ℝ))
        = p ^ n * (p - p ^ n) := by
      rw [← wsum_mid_hat p hn rB.1 rB.2, mul_sum]
      refine sum_congr rfl fun u hu => ?_
      rw [pair_comm s u 0, pair_comm s u (2 ^ n - 1), es0, esB u hu, wt_ones]
      push_cast
      ring
    rw [a1, a2, es0, es0, pair_comm s (2 ^ n - 1) 0, es0, esBB, wt_ones]
    push_cast
    ring
  -- together
  have split : val p (n + k) (sub n m s)
      = ∑ l ∈ range (2 ^ n), ∑ l' ∈ range (2 ^ n), blockVal p n k (sub n m s) l l' := by
    unfold val blockVal
    exact sum_split2 n k _
  rw [split, sum_ends2R hP]
  have b1 : ∑ u ∈ Ico 1 (2 ^ n - 1), (blockVal p n k (sub n m s) 0 u
      + blockVal p n k (sub n m s) (2 ^ n - 1) u)
      = p ^ n * (stayProb p k m * (p - p ^ n)
        + (1 - stayProb p k m) * p * (1 - (1 - p) ^ n - p ^ n)) := by
    rw [sum_add_distrib, sum_congr rfl kwm, sB]
    simp
  have b2 : ∑ t ∈ Ico 1 (2 ^ n - 1), (blockVal p n k (sub n m s) t 0
      + blockVal p n k (sub n m s) t (2 ^ n - 1))
      = p ^ n * (stayProb p k m * (p - p ^ n)
        + (1 - stayProb p k m) * p * (1 - (1 - p) ^ n - p ^ n)) := by
    rw [← b1]
    refine sum_congr rfl fun t _ => ?_
    rw [blockVal_swap p _ t 0, blockVal_swap p _ t (2 ^ n - 1)]
  rw [b1, b2, sum_congr rfl fun t ht => sum_congr rfl fun u hu => kmm t ht u hu,
    k00, k01, k10, k11, es, mul_pow]
  ring

end

end Hats
