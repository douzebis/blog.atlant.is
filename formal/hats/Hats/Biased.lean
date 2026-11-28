-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Dual
import Mathlib.Analysis.SpecificLimits.Basic

/-!
# Two players, hats that are black with probability `p`

`wt p n t` is the probability of the stack `t` of `n` hats, and `val p n s`
the probability that both players point at a black hat with the strategy
`s`: the hits, each pair of stacks counted with its probability.

* `val_lr`: a white reset adds values.  If `a` is proper on `m` hats, the
  left (white) reset of `a` by `b` has the value
  `val a + (1 - p) ^ (2 * m) * val b`.
* `val_whiteChain`: the strategy `c3` on three hats, white-reset by itself
  `j` times, has the value `val c3 * (1 + r + ... + r ^ j)` with
  `r = (1 - p) ^ 6`; and `val_c3` is
  `3p² - 6p³ + 8p⁴ - 6p⁵ + 2p⁶`.
* `tendsto_whiteChain`: these values tend to `val c3 / (1 - (1 - p) ^ 6)`
  for `0 < p ≤ 1`.
-/

namespace Hats

open Finset

/-- The probability of the stack `t` of `n` hats. -/
noncomputable def wt (p : ℝ) (n t : ℕ) : ℝ :=
  ∏ j ∈ range n, if t.testBit j then p else 1 - p

/-- The probability that both players point at a black hat. -/
noncomputable def val (p : ℝ) (n : ℕ) (s : ℕ → ℤ) : ℝ :=
  ∑ t ∈ range (2 ^ n), ∑ u ∈ range (2 ^ n), wt p n t * wt p n u * (pair s t u : ℝ)

/-- The probability of a stack is that of its lowest hats times that of
the hats above. -/
theorem wt_split (p : ℝ) {m : ℕ} (n : ℕ) (t1 : ℕ) {t0 : ℕ} (h0 : t0 < 2 ^ m) :
    wt p (m + n) (2 ^ m * t1 + t0) = wt p m t0 * wt p n t1 := by
  unfold wt
  rw [prod_range_add]
  congr 1
  · refine prod_congr rfl fun j hj => ?_
    have := mem_range.mp hj
    simp [Nat.testBit_two_pow_mul_add t1 h0, this]
  · refine prod_congr rfl fun j _ => ?_
    simp [Nat.testBit_two_pow_mul_add t1 h0]

theorem wt_zero (p : ℝ) (n : ℕ) : wt p n 0 = (1 - p) ^ n := by
  simp [wt]

/-- The probabilities of the stacks of `n` hats add up to `1`. -/
theorem wt_sum (p : ℝ) (n : ℕ) : ∑ t ∈ range (2 ^ n), wt p n t = 1 := by
  induction n with
  | zero => simp [wt]
  | succ n ih =>
    rw [pow_succ, sum_range_mul]
    have e : ∀ q ∈ range 2, ∀ r ∈ range (2 ^ n),
        wt p (n + 1) (2 ^ n * q + r) = wt p n r * wt p 1 q := fun q _ r hr =>
      wt_split p 1 q (mem_range.mp hr)
    rw [sum_congr rfl fun q hq => sum_congr rfl fun r hr => e q hq r hr]
    simp only [← sum_mul, ih, one_mul]
    simp [sum_range_succ, wt]

/-- A sum over the pairs of stacks of `m + n` hats, sorted by the `m`
lowest hats. -/
theorem sum_split2 (m n : ℕ) (F : ℕ → ℕ → ℝ) :
    ∑ t ∈ range (2 ^ (m + n)), ∑ u ∈ range (2 ^ (m + n)), F t u
      = ∑ t0 ∈ range (2 ^ m), ∑ u0 ∈ range (2 ^ m),
        ∑ t1 ∈ range (2 ^ n), ∑ u1 ∈ range (2 ^ n), F (2 ^ m * t1 + t0) (2 ^ m * u1 + u0) := by
  rw [pow_add, sum_range_mul, sum_comm]
  refine sum_congr rfl fun t0 _ => ?_
  rw [sum_congr rfl fun t1 _ => sum_range_mul (2 ^ m) (2 ^ n) _]
  rw [sum_congr rfl fun t1 _ => sum_comm, sum_comm]

/-- **A white reset adds values.** -/
theorem val_lr (p : ℝ) {m : ℕ} (n : ℕ) {a : ℕ → ℤ} (b : ℕ → ℤ) (ha : Proper m a) :
    val p (m + n) (lr m a b) = val p m a + (1 - p) ^ (2 * m) * val p n b := by
  have inner : ∀ t0 ∈ range (2 ^ m), ∀ u0 ∈ range (2 ^ m),
      ∑ t1 ∈ range (2 ^ n), ∑ u1 ∈ range (2 ^ n),
        wt p (m + n) (2 ^ m * t1 + t0) * wt p (m + n) (2 ^ m * u1 + u0)
          * (pair (lr m a b) (2 ^ m * t1 + t0) (2 ^ m * u1 + u0) : ℝ)
      = wt p m t0 * wt p m u0 * (pair a t0 u0 : ℝ)
        + if t0 = 0 ∧ u0 = 0 then (1 - p) ^ (2 * m) * val p n b else 0 := by
    intro t0 ht0 u0 hu0
    have ht := mem_range.mp ht0
    have hu := mem_range.mp hu0
    have term : ∀ t1 u1 : ℕ,
        wt p (m + n) (2 ^ m * t1 + t0) * wt p (m + n) (2 ^ m * u1 + u0)
          * (pair (lr m a b) (2 ^ m * t1 + t0) (2 ^ m * u1 + u0) : ℝ)
        = wt p m t0 * wt p m u0 * (pair a t0 u0 : ℝ) * (wt p n t1 * wt p n u1)
          + (if t0 = 0 ∧ u0 = 0 then wt p m t0 * wt p m u0
              * (wt p n t1 * wt p n u1 * (pair b t1 u1 : ℝ)) else 0) := by
      intro t1 u1
      rw [wt_split p n t1 ht, wt_split p n u1 hu, lr_term b ha t1 u1 ht hu]
      unfold pair
      split_ifs <;> push_cast <;> ring
    rw [sum_congr rfl fun t1 _ => sum_congr rfl fun u1 _ => term t1 u1]
    simp only [sum_add_distrib]
    congr 1
    · simp only [← mul_sum, wt_sum, mul_one]
    · by_cases h : t0 = 0 ∧ u0 = 0
      · obtain ⟨rfl, rfl⟩ := h
        simp only [and_self, ↓reduceIte, ← mul_sum, wt_zero]
        unfold val
        ring
      · simp [h]
  rw [val, sum_split2, sum_congr rfl fun t0 ht0 => sum_congr rfl fun u0 hu0 => inner t0 ht0 u0 hu0]
  simp only [sum_add_distrib]
  congr 1
  have h0 : 0 ∈ range (2 ^ m) := mem_range.mpr (Nat.two_pow_pos m)
  rw [sum_eq_single_of_mem 0 h0, sum_eq_single_of_mem 0 h0]
  · simp only [and_self, ↓reduceIte]
  · intro u0 _ hu0; simp [hu0]
  · intro t0 _ ht0
    refine sum_eq_zero fun u0 _ => ?_
    simp [ht0]

/-! ### The white resets of the best strategy on three hats -/

/-- The strategy `01002120` on three hats (the Carter strategy `C_3`). -/
def c3 : ℕ → ℤ := fun t => if t = 1 ∨ t = 5 then 1 else if t = 4 ∨ t = 6 then 2 else 0

theorem c3_proper : Proper 3 c3 := by
  intro t _
  unfold c3
  split_ifs <;> constructor <;> norm_num

theorem hits_c3 : hits 3 c3 = 22 := by decide

/-- The value of `c3`. -/
theorem val_c3 (p : ℝ) :
    val p 3 c3 = 3 * p ^ 2 - 6 * p ^ 3 + 8 * p ^ 4 - 6 * p ^ 5 + 2 * p ^ 6 := by
  simp [val, wt, sum_range_succ, prod_range_succ, pair, hat, c3, Nat.testBit]
  ring

/-- `c3` white-reset by itself `j` times: a strategy on `3 * (j + 1)` hats. -/
def whiteChain : ℕ → ℕ → ℤ
  | 0 => c3
  | j + 1 => lr (3 * (j + 1)) (whiteChain j) c3

theorem lr_proper' {m n : ℕ} {a b : ℕ → ℤ} (ha : Proper m a) (hb : Proper n b) :
    Proper (m + n) (lr m a b) := by
  intro t ht
  have hpos := Nat.two_pow_pos m
  have x := ha _ (Nat.mod_lt t hpos)
  have hq : t / 2 ^ m < 2 ^ n := by
    rwa [Nat.div_lt_iff_lt_mul hpos, mul_comm, ← pow_add]
  have y := hb _ hq
  unfold lr
  split_ifs <;> constructor <;> push_cast <;> omega

theorem whiteChain_proper : ∀ j, Proper (3 * (j + 1)) (whiteChain j)
  | 0 => c3_proper
  | j + 1 => by
    have h := lr_proper' (whiteChain_proper j) c3_proper
    rw [show 3 * (j + 1 + 1) = 3 * (j + 1) + 3 by ring]
    exact h

/-- **The value of the white resets**: `val c3 * (1 + r + ... + r ^ j)`
with `r = (1 - p) ^ 6`. -/
theorem val_whiteChain (p : ℝ) (j : ℕ) :
    val p (3 * (j + 1)) (whiteChain j)
      = val p 3 c3 * ∑ i ∈ range (j + 1), ((1 - p) ^ 6) ^ i := by
  induction j with
  | zero => simp [whiteChain]
  | succ j ih =>
    have h := val_lr p 3 c3 (whiteChain_proper j)
    rw [show 3 * (j + 1 + 1) = 3 * (j + 1) + 3 by ring]
    rw [show whiteChain (j + 1) = lr (3 * (j + 1)) (whiteChain j) c3 from rfl, h, ih,
      sum_range_succ _ (j + 1)]
    rw [show (1 - p) ^ (2 * (3 * (j + 1))) = ((1 - p) ^ 6) ^ (j + 1) by rw [← pow_mul]; congr 1; ring]
    ring

/-- **The values of the white resets tend to `val c3 / (1 - (1 - p) ^ 6)`**,
for `0 < p ≤ 1`: so the best value of the game with black-hat probability
`p` is at least that. -/
theorem tendsto_whiteChain {p : ℝ} (hp : 0 < p) (hp1 : p ≤ 1) :
    Filter.Tendsto (fun j => val p (3 * (j + 1)) (whiteChain j)) Filter.atTop
      (nhds (val p 3 c3 / (1 - (1 - p) ^ 6))) := by
  have r0 : 0 ≤ (1 - p) ^ 6 := by positivity
  have r1 : (1 - p) ^ 6 < 1 := by
    have h : |1 - p| < 1 := by rw [abs_lt]; constructor <;> linarith
    calc (1 - p) ^ 6 = |1 - p| ^ 6 := by rw [← abs_pow, abs_of_nonneg r0]
      _ < 1 := pow_lt_one₀ (abs_nonneg _) h (by norm_num)
  have g := (hasSum_geometric_of_lt_one r0 r1).tendsto_sum_nat
  have g' := (g.comp (Filter.tendsto_add_atTop_nat 1)).const_mul (val p 3 c3)
  simp only [Function.comp_def] at g'
  rw [show val p 3 c3 / (1 - (1 - p) ^ 6) = val p 3 c3 * (1 - (1 - p) ^ 6)⁻¹ from rfl]
  exact g'.congr fun j => (val_whiteChain p j).symm

/-! ### The exchange of the colors -/

/-- With the colors exchanged and `p` replaced by `1 - p`, a stack keeps
its probability. -/
theorem wt_flip (p : ℝ) {n t : ℕ} (ht : t < 2 ^ n) : wt (1 - p) n (flip n t) = wt p n t := by
  unfold wt
  refine prod_congr rfl fun j hj => ?_
  have hj' := mem_range.mp hj
  have h : (flip n t).testBit j = !t.testBit j := by
    unfold flip
    rw [Nat.sub_sub, Nat.add_comm 1 t, Nat.testBit_two_pow_sub_succ ht]
    simp [hj']
  rw [h]
  cases t.testBit j <;> simp

/-- A hat at a given position is black with probability `p`. -/
theorem wsum_hat (p : ℝ) {n : ℕ} {j : ℤ} (hj : 0 ≤ j) (hjn : j < n) :
    ∑ t ∈ range (2 ^ n), wt p n t * (hat t j : ℝ) = p := by
  obtain ⟨k, hk⟩ : ∃ k, n = j.toNat + (1 + k) := ⟨n - j.toNat - 1, by omega⟩
  have key : ∀ q r : ℕ, r < 2 ^ j.toNat →
      hat (2 ^ j.toNat * q + r) j = if q.testBit 0 = true then 1 else 0 := by
    intro q r hr
    simp [hat, hj, Nat.testBit_two_pow_mul_add q hr]
  have key2 : ∀ q' b : ℕ, b < 2 ^ 1 → (2 ^ 1 * q' + b).testBit 0 = decide (b = 1) := by
    intro q' b hb
    rw [Nat.testBit_two_pow_mul_add q' hb]
    have : b = 0 ∨ b = 1 := by omega
    rcases this with rfl | rfl <;> simp
  rw [hk, pow_add, sum_range_mul]
  have e : ∀ q ∈ range (2 ^ (1 + k)), ∀ r ∈ range (2 ^ j.toNat),
      wt p (j.toNat + (1 + k)) (2 ^ j.toNat * q + r) * (hat (2 ^ j.toNat * q + r) j : ℝ)
        = wt p j.toNat r * (wt p (1 + k) q * if q.testBit 0 = true then 1 else 0) := by
    intro q _ r hr
    rw [wt_split p (1 + k) q (mem_range.mp hr), key q r (mem_range.mp hr)]
    push_cast
    ring
  rw [sum_congr rfl fun q hq => sum_congr rfl fun r hr => e q hq r hr]
  simp only [← sum_mul, wt_sum, one_mul]
  rw [pow_add, sum_range_mul]
  have e2 : ∀ q' ∈ range (2 ^ k), ∀ b ∈ range (2 ^ 1),
      wt p (1 + k) (2 ^ 1 * q' + b) * (if (2 ^ 1 * q' + b).testBit 0 = true then 1 else 0)
        = wt p k q' * (wt p 1 b * if b = 1 then 1 else 0) := by
    intro q' _ b hb
    rw [wt_split p k q' (mem_range.mp hb), key2 q' b (mem_range.mp hb)]
    simp only [decide_eq_true_eq]
    ring
  rw [sum_congr rfl fun q' hq' => sum_congr rfl fun b hb => e2 q' hq' b hb]
  simp only [← mul_sum]
  rw [← sum_mul, wt_sum, one_mul]
  simp [wt]

/-- **The exchange of the colors**: the dual of a proper strategy, at the
probability `1 - p`, has the value `val p s + 1 - 2 * p`. -/
theorem val_dual (p : ℝ) {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    val (1 - p) n (dual n s) = val p n s + 1 - 2 * p := by
  have reflect : ∀ G : ℕ → ℝ,
      ∑ t ∈ range (2 ^ n), G (flip n t) = ∑ t ∈ range (2 ^ n), G t :=
    fun G => sum_range_reflect G (2 ^ n)
  have h1 : val (1 - p) n (dual n s) = ∑ t ∈ range (2 ^ n), ∑ u ∈ range (2 ^ n),
      wt p n t * wt p n u * ((1 - (hat t (s u) : ℝ)) * (1 - (hat u (s t) : ℝ))) := by
    unfold val pair dual
    rw [← reflect]
    refine sum_congr rfl fun t ht => ?_
    rw [← reflect]
    refine sum_congr rfl fun u hu => ?_
    have ht' := mem_range.mp ht
    have hu' := mem_range.mp hu
    have a := hat_flip ht' (hs u hu').1 (hs u hu').2
    have b := hat_flip hu' (hs t ht').1 (hs t ht').2
    have a' : (hat (flip n t) (s u) : ℝ) = 1 - hat t (s u) := by
      have := congrArg (Nat.cast : ℕ → ℝ) a; push_cast at this; linarith
    have b' : (hat (flip n u) (s t) : ℝ) = 1 - hat u (s t) := by
      have := congrArg (Nat.cast : ℕ → ℝ) b; push_cast at this; linarith
    rw [flip_flip ht', flip_flip hu', wt_flip p ht', wt_flip p hu']
    push_cast
    rw [a', b']
  have Sa : ∑ t ∈ range (2 ^ n), ∑ u ∈ range (2 ^ n),
      wt p n t * wt p n u * (hat t (s u) : ℝ) = p := by
    rw [sum_comm]
    have row : ∀ u ∈ range (2 ^ n),
        ∑ t ∈ range (2 ^ n), wt p n t * wt p n u * (hat t (s u) : ℝ) = wt p n u * p := by
      intro u hu
      have b := hs u (mem_range.mp hu)
      have e : ∑ t ∈ range (2 ^ n), wt p n t * wt p n u * (hat t (s u) : ℝ)
          = wt p n u * ∑ t ∈ range (2 ^ n), wt p n t * (hat t (s u) : ℝ) := by
        rw [mul_sum]
        exact sum_congr rfl fun t _ => by ring
      rw [e, wsum_hat p b.1 b.2]
    rw [sum_congr rfl row, ← sum_mul, wt_sum, one_mul]
  have Sb : ∑ t ∈ range (2 ^ n), ∑ u ∈ range (2 ^ n),
      wt p n t * wt p n u * (hat u (s t) : ℝ) = p := by
    have row : ∀ t ∈ range (2 ^ n),
        ∑ u ∈ range (2 ^ n), wt p n t * wt p n u * (hat u (s t) : ℝ) = wt p n t * p := by
      intro t ht
      have b := hs t (mem_range.mp ht)
      have e : ∑ u ∈ range (2 ^ n), wt p n t * wt p n u * (hat u (s t) : ℝ)
          = wt p n t * ∑ u ∈ range (2 ^ n), wt p n u * (hat u (s t) : ℝ) := by
        rw [mul_sum]
        exact sum_congr rfl fun u _ => by ring
      rw [e, wsum_hat p b.1 b.2]
    rw [sum_congr rfl row, ← sum_mul, wt_sum, one_mul]
  have S1 : ∑ t ∈ range (2 ^ n), ∑ u ∈ range (2 ^ n), wt p n t * wt p n u = 1 := by
    rw [← sum_mul_sum, wt_sum, mul_one]
  have expand : ∀ t u : ℕ,
      wt p n t * wt p n u * ((1 - (hat t (s u) : ℝ)) * (1 - (hat u (s t) : ℝ)))
        = wt p n t * wt p n u - wt p n t * wt p n u * (hat t (s u) : ℝ)
          - wt p n t * wt p n u * (hat u (s t) : ℝ)
          + wt p n t * wt p n u * ((pair s t u : ℕ) : ℝ) := by
    intro t u
    unfold pair
    push_cast
    ring
  rw [h1, sum_congr rfl fun t _ => sum_congr rfl fun u _ => expand t u]
  simp only [sum_add_distrib, sum_sub_distrib]
  rw [S1, Sa, Sb]
  unfold val
  ring

end Hats
