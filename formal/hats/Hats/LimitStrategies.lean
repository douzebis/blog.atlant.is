-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Limit

/-!
# The limit strategies of the third article

A sequence of finite strategies that settles, stack by stack, defines a
strategy on infinite stacks: its limit.  Its win rate is the limit of
theirs.  Three cases: following the lowest black hat (`1 / 3`), the Carter
strategies and the Reyes strategies (`7 / 20` both).
-/

namespace Hats

open MeasureTheory Finset Filter Topology

/-! ### Tools on infinite stacks -/

/-- An infinite stack without its `m` lowest hats. -/
def drop (m : ℕ) (t : Stack) : Stack := fun i => t (i + m)

/-- The `m + n` lowest hats: the `m` lowest, and the `n` next ones above. -/
theorem code_add (m n : ℕ) (t : Stack) :
    code (m + n) t = 2 ^ m * code n (drop m t) + code m t := by
  apply Nat.eq_of_testBit_eq
  intro p
  rw [Nat.testBit_two_pow_mul_add _ (code_lt m t), testBit_code, testBit_code, testBit_code]
  by_cases h : p < m
  · have : p < m + n := by omega
    simp [h, this]
  · have e : p - m + m = p := by omega
    by_cases h' : p < m + n
    · have : p - m < n := by omega
      simp [h, h', this, drop, e]
    · have : ¬ p - m < n := by omega
      simp [h, h', this]

theorem code_mod (m n : ℕ) (t : Stack) : code (m + n) t % 2 ^ m = code m t := by
  rw [code_add, Nat.mul_add_mod, Nat.mod_eq_of_lt (code_lt m t)]

theorem code_div (m n : ℕ) (t : Stack) : code (m + n) t / 2 ^ m = code n (drop m t) := by
  rw [code_add, Nat.mul_add_div (Nat.two_pow_pos m), Nat.div_eq_of_lt (code_lt m t), add_zero]

/-- The `n` lowest hats are all white. -/
theorem code_eq_zero_iff (n : ℕ) (t : Stack) : code n t = 0 ↔ ∀ i < n, t i = false := by
  rw [code_eq_iff (Nat.two_pow_pos n)]
  simp

/-- The `n` lowest hats are all black. -/
theorem code_eq_ones_iff (n : ℕ) (t : Stack) :
    code n t = 2 ^ n - 1 ↔ ∀ i < n, t i = true := by
  rw [code_eq_iff (Nat.sub_lt (Nat.two_pow_pos n) one_pos)]
  constructor
  · intro h i hi; rw [h i hi]; simp [hi]
  · intro h i hi; rw [h i hi]; simp [hi]

/-! ### The limit of a sequence of finite strategies -/

section limit

variable (n : ℕ → ℕ) (s : ℕ → ℕ → ℤ) (A : ℕ → Finset ℕ)

/-- The limit of the strategies `s k` (on `n k` hats): for a stack whose
`n k` lowest hats are outside `A k` for some `k`, what the first such
`s k` chooses.  Elsewhere it points nowhere. -/
noncomputable def limitOf (t : Stack) : ℤ :=
  open Classical in
  if h : ∃ k, code (n k) t ∉ A k then s (Nat.find h) (code (n (Nat.find h)) t) else -1

/-- The sequence settles: once the lowest hats of a stack are outside
`A k`, they stay outside at the next step, and the choice does not
change. -/
def Settles : Prop :=
  ∀ k t, code (n k) t ∉ A k →
    code (n (k + 1)) t ∉ A (k + 1) ∧ s (k + 1) (code (n (k + 1)) t) = s k (code (n k) t)

variable {n s A}

/-- On a stack whose `n k` lowest hats are outside `A k`, all the
strategies from `s k` on choose what the limit chooses: the limit is a
limit. -/
theorem limitOf_eq (hst : Settles n s A) {k : ℕ} {t : Stack} (hk : code (n k) t ∉ A k) :
    ∀ m, k ≤ m → s m (code (n m) t) = limitOf n s A t := by
  classical
  have h : ∃ k, code (n k) t ∉ A k := ⟨k, hk⟩
  have key : ∀ j, code (n (Nat.find h + j)) t ∉ A (Nat.find h + j)
      ∧ s (Nat.find h + j) (code (n (Nat.find h + j)) t)
        = s (Nat.find h) (code (n (Nat.find h)) t) := by
    intro j
    induction j with
    | zero => exact ⟨Nat.find_spec h, rfl⟩
    | succ j ih =>
      have := hst _ t ih.1
      exact ⟨this.1, this.2.trans ih.2⟩
  intro m hm
  have hle : Nat.find h ≤ m := (Nat.find_min' h hk).trans hm
  obtain ⟨j, rfl⟩ := Nat.exists_eq_add_of_le hle
  have e : limitOf n s A t = s (Nat.find h) (code (n (Nat.find h)) t) := by
    simp only [limitOf, h, ↓reduceDIte]
  rw [e]
  exact (key j).2

/-- **The win rate of the limit** is the limit of the win rates, when the
exceptional sets `A k` become negligible. -/
theorem rateInf_limitOf {L : ℝ} (hs : ∀ k, Proper (n k) (s k)) (hst : Settles n s A)
    (hA : Tendsto (fun k => ((A k).card : ℝ) / 2 ^ n k) atTop (𝓝 0))
    (hL : Tendsto (fun k => rate (n k) (s k)) atTop (𝓝 L)) :
    rateInf (limitOf n s A) = L :=
  rateInf_eq_of_tendsto n s A hs
    (fun k _ hk => (limitOf_eq hst hk k le_rfl).symm) hA hL

end limit

/-! ### Following the lowest black hat -/

theorem lowBlack_proper (n : ℕ) : Proper (n + 1) (lowBlack (n + 1)) := by
  intro t ht
  rcases Nat.eq_zero_or_pos t with rfl | h0
  · rw [lowBlack_zero]; constructor <;> push_cast <;> omega
  · obtain ⟨p, hp, hb, -⟩ := lowBlack_spec (n + 1) h0 ht
    have : p < n + 1 := by
      by_contra hge
      have : t < 2 ^ p := lt_of_lt_of_le ht (Nat.pow_le_pow_right (by norm_num) (by omega))
      rw [Nat.testBit_lt_two_pow this] at hb
      exact Bool.false_ne_true hb
    rw [hp]; constructor <;> omega

/-- What `lowBlack` chooses on the lowest hats of an infinite stack that
has a black hat among them: the position of the lowest black hat of the
stack. -/
theorem lowBlack_code {n : ℕ} {t : Stack} (h : code n t ≠ 0) :
    ∃ p : ℕ, lowBlack n (code n t) = p ∧ p < n ∧ t p = true ∧ ∀ q < p, t q = false := by
  obtain ⟨p, hp, hb, hq⟩ := lowBlack_spec n (Nat.pos_of_ne_zero h) (code_lt n t)
  rw [testBit_code] at hb
  have hpn : p < n := by
    by_contra hge; simp [hge] at hb
  refine ⟨p, hp, hpn, by simpa [hpn] using hb, fun q hq' => ?_⟩
  have := hq q hq'
  rw [testBit_code] at this
  have hqn : q < n := by omega
  simpa [hqn] using this

/-- "Follow the lowest black hat" on infinite stacks, as the limit of the
finite strategies. -/
noncomputable def lowBlackInf : Stack → ℤ :=
  limitOf (fun k => k + 1) (fun k => lowBlack (k + 1)) (fun _ => {0})

theorem lowBlack_settles :
    Settles (fun k => k + 1) (fun k => lowBlack (k + 1)) (fun _ => {0}) := by
  intro k t hk
  have hk' : code (k + 1) t ≠ 0 := by simpa using hk
  have hk2 : code (k + 1 + 1) t ≠ 0 := by
    intro h0
    rw [code_eq_zero_iff] at h0
    exact hk' ((code_eq_zero_iff _ _).mpr fun i hi => h0 i (by omega))
  refine ⟨by simpa using hk2, ?_⟩
  obtain ⟨p, hp, -, hb, hq⟩ := lowBlack_code hk'
  obtain ⟨p', hp', -, hb', hq'⟩ := lowBlack_code hk2
  have : p = p' := by
    rcases Nat.lt_trichotomy p p' with h | h | h
    · rw [hq' p h] at hb; exact absurd hb Bool.false_ne_true
    · exact h
    · rw [hq p' h] at hb'; exact absurd hb' Bool.false_ne_true
  simp only [hp, hp', this]

/-- On a stack with a black hat, the limit points at the lowest one. -/
theorem lowBlackInf_spec {t : Stack} {p : ℕ} (hb : t p = true) (hq : ∀ q < p, t q = false) :
    lowBlackInf t = p := by
  have hk : code (p + 1) t ∉ ({0} : Finset ℕ) := by
    simp only [Finset.mem_singleton]
    intro h0
    rw [code_eq_zero_iff] at h0
    rw [h0 p (by omega)] at hb
    exact Bool.false_ne_true hb
  have h := limitOf_eq lowBlack_settles (k := p) hk p le_rfl
  rw [lowBlackInf, ← h]
  obtain ⟨p', hp', -, hb', hq'⟩ := lowBlack_code (by simpa using hk)
  have : p' = p := by
    rcases Nat.lt_trichotomy p' p with h | h | h
    · rw [hq p' h] at hb'; exact absurd hb' Bool.false_ne_true
    · exact h
    · rw [hq' p h] at hb; exact absurd hb Bool.false_ne_true
  simp only [hp', this]

/-- **On infinite stacks, "follow the lowest black hat" wins one time in
three.** -/
theorem rateInf_lowBlackInf : rateInf lowBlackInf = 1 / 3 := by
  refine rateInf_limitOf (fun k => lowBlack_proper k) lowBlack_settles ?_ ?_
  · have h := (tendsto_inv_four_pow.comp (tendsto_add_atTop_nat 1))
    have h2 : Tendsto (fun k : ℕ => (1 : ℝ) / 2 ^ (k + 1)) atTop (𝓝 0) := by
      have := tendsto_pow_atTop_nhds_zero_of_lt_one (r := (1 / 2 : ℝ)) (by norm_num) (by norm_num)
      have h3 := this.comp (tendsto_add_atTop_nat 1)
      refine h3.congr fun k => ?_
      simp [Function.comp, one_div, inv_pow]
    simpa using h2
  · exact tendsto_rate_lowBlack.comp (tendsto_add_atTop_nat 1)

/-! ### The Carter strategies -/

/-- On a stack whose `n` lowest hats are neither all white nor all black,
the double shift chooses what the strategy chose. -/
theorem ds_stable {n : ℕ} (s : ℕ → ℤ) {a : ℕ} (h0 : a % 2 ^ n ≠ 0)
    (h1 : a % 2 ^ n ≠ 2 ^ n - 1) : ds n s a = s (a % 2 ^ n) := by
  have hpos : 0 < 2 ^ n := Nat.two_pow_pos n
  have hQ : 2 ^ (n + 1) = 2 ^ n * 2 := pow_succ 2 n
  have e1 : a ≠ 2 ^ (n + 1) + 2 ^ n := by
    rintro rfl
    apply h0
    rw [hQ, show 2 ^ n * 2 + 2 ^ n = 2 ^ n * 3 by ring, Nat.mul_mod_right]
  have e2 : a ≠ 2 ^ (n + 1) := by
    rintro rfl
    apply h0
    rw [hQ, Nat.mul_mod_right]
  have e3 : a % 2 ^ (n + 1) % 2 ^ n = a % 2 ^ n :=
    Nat.mod_mod_of_dvd a (pow_dvd_pow 2 (Nat.le_succ n))
  have e4 : a % 2 ^ (n + 1) ≠ 2 ^ n - 1 := by
    intro h
    apply h1
    rw [← e3, h, Nat.mod_eq_of_lt (by omega)]
  simp [ds, ls, rs, e1, e2, e3, e4]

/-- The Carter strategies on infinite stacks: the limit of those on
`2 * k + 1` hats. -/
noncomputable def carterInf : Stack → ℤ :=
  limitOf (fun k => 2 * k + 1) carterOdd (fun k => {0, 2 ^ (2 * k + 1) - 1})

theorem carter_settles :
    Settles (fun k => 2 * k + 1) carterOdd (fun k => {0, 2 ^ (2 * k + 1) - 1}) := by
  intro k t hk
  simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hk ⊢
  have e : 2 * (k + 1) + 1 = 2 * k + 1 + 2 := by ring
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · intro h0
    rw [code_eq_zero_iff] at h0
    exact hk.1 ((code_eq_zero_iff _ _).mpr fun i hi => h0 i (by omega))
  · intro h1
    rw [code_eq_ones_iff] at h1
    exact hk.2 ((code_eq_ones_iff _ _).mpr fun i hi => h1 i (by omega))
  · have hm : code (2 * (k + 1) + 1) t % 2 ^ (2 * k + 1) = code (2 * k + 1) t := by
      rw [e, code_mod]
    change ds (2 * k + 1) (carterOdd k) (code (2 * (k + 1) + 1) t) = _
    rw [ds_stable _ (by rw [hm]; exact hk.1) (by rw [hm]; exact hk.2), hm]

/-- **On infinite stacks, the limit of the Carter strategies wins with
probability `7 / 20`.** -/
theorem rateInf_carterInf : rateInf carterInf = 7 / 20 := by
  refine rateInf_limitOf carterOdd_proper carter_settles ?_ ?_
  · have hcard : ∀ k : ℕ, (({0, 2 ^ (2 * k + 1) - 1} : Finset ℕ).card : ℝ) = 2 := by
      intro k
      have : (0 : ℕ) ≠ 2 ^ (2 * k + 1) - 1 := by
        have : 2 ^ 1 ≤ 2 ^ (2 * k + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
        omega
      rw [Finset.card_pair this]; norm_num
    have h2 : Tendsto (fun k : ℕ => (2 : ℝ) / 2 ^ (2 * k + 1)) atTop (𝓝 0) := by
      have := tendsto_pow_atTop_nhds_zero_of_lt_one (r := (1 / 4 : ℝ)) (by norm_num) (by norm_num)
      refine this.congr fun k => ?_
      rw [pow_succ, pow_mul]
      norm_num
      field_simp
      rw [← mul_pow]
      norm_num
    simpa [hcard] using h2
  · have h16 : Tendsto (fun k : ℕ => (1 : ℝ) / (10 * 16 ^ k)) atTop (𝓝 0) := by
      have := tendsto_pow_atTop_nhds_zero_of_lt_one (r := (1 / 16 : ℝ)) (by norm_num) (by norm_num)
      have h2 := this.const_mul (1 / 10 : ℝ)
      simp only [mul_zero] at h2
      refine h2.congr fun k => ?_
      simp [one_div, inv_pow]
      ring
    have h : Tendsto (fun k : ℕ => (7 : ℝ) / 20 - 1 / (10 * 16 ^ k)) atTop (𝓝 (7 / 20 - 0)) :=
      tendsto_const_nhds.sub h16
    simpa [rate_carterOdd] using h

/-! ### The Reyes strategies -/

/-- The stacks of `3 * (j + 1)` hats whose `j + 1` blocks of three hats
are each all white or all black. -/
def uniformBlocks (j : ℕ) : Finset ℕ :=
  (range (2 ^ (3 * (j + 1)))).filter fun a => ∀ i ≤ j, a / 8 ^ i % 8 = 0 ∨ a / 8 ^ i % 8 = 7

theorem drop_drop (a b : ℕ) (t : Stack) : drop a (drop b t) = drop (a + b) t := by
  funext i; simp [drop, add_assoc]

theorem drop_zero (t : Stack) : drop 0 t = t := by
  funext i; simp [drop]

/-- The block of rank `i` of the lowest hats of an infinite stack. -/
theorem code_block {j i : ℕ} (hi : i ≤ j) (t : Stack) :
    code (3 * (j + 1)) t / 8 ^ i % 8 = code 3 (drop (3 * i) t) := by
  have e1 : 3 * (j + 1) = 3 * i + (3 + 3 * (j - i)) := by omega
  have e2 : (8 : ℕ) ^ i = 2 ^ (3 * i) := by rw [pow_mul]; norm_num
  rw [e1, e2, code_div, show (8 : ℕ) = 2 ^ 3 by norm_num, code_mod]

theorem mem_uniformBlocks (j : ℕ) (t : Stack) :
    code (3 * (j + 1)) t ∈ uniformBlocks j
      ↔ ∀ i ≤ j, code 3 (drop (3 * i) t) = 0 ∨ code 3 (drop (3 * i) t) = 7 := by
  simp only [uniformBlocks, mem_filter, mem_range, code_lt, true_and]
  constructor
  · intro h i hi; rw [← code_block hi]; exact h i hi
  · intro h i hi; rw [code_block hi]; exact h i hi

theorem card_uniformBlocks (j : ℕ) : (uniformBlocks j).card ≤ 2 ^ (j + 1) := by
  induction j with
  | zero =>
    have : uniformBlocks 0 ⊆ {0, 7} := by
      intro a ha
      simp only [uniformBlocks, mem_filter, mem_range] at ha
      have := ha.2 0 le_rfl
      have h8 : a < 8 := by simpa using ha.1
      simp only [pow_zero, Nat.div_one] at this
      simp only [Finset.mem_insert, Finset.mem_singleton]
      omega
    exact (card_le_card this).trans (by simp)
  | succ j ih =>
    have hsub : uniformBlocks (j + 1)
        ⊆ (uniformBlocks j).image (fun x => 8 * x) ∪ (uniformBlocks j).image (fun x => 8 * x + 7) := by
      intro a ha
      simp only [uniformBlocks, mem_filter, mem_range] at ha
      have h0 := ha.2 0 (Nat.zero_le _)
      simp only [pow_zero, Nat.div_one] at h0
      have hlt : a / 8 < 2 ^ (3 * (j + 1)) := by
        have : 2 ^ (3 * (j + 1 + 1)) = 8 * 2 ^ (3 * (j + 1)) := by
          rw [show 3 * (j + 1 + 1) = 3 + 3 * (j + 1) by ring, pow_add]; norm_num
        have := ha.1
        omega
      have hmem : a / 8 ∈ uniformBlocks j := by
        simp only [uniformBlocks, mem_filter, mem_range]
        refine ⟨hlt, fun i hi => ?_⟩
        have := ha.2 (i + 1) (by omega)
        rwa [pow_succ', ← Nat.div_div_eq_div_mul] at this
      simp only [Finset.mem_union, Finset.mem_image]
      rcases h0 with h0 | h0
      · exact Or.inl ⟨a / 8, hmem, by omega⟩
      · exact Or.inr ⟨a / 8, hmem, by omega⟩
    calc (uniformBlocks (j + 1)).card
        ≤ ((uniformBlocks j).image (fun x => 8 * x)).card
          + ((uniformBlocks j).image (fun x => 8 * x + 7)).card :=
          (card_le_card hsub).trans (card_union_le _ _)
      _ ≤ (uniformBlocks j).card + (uniformBlocks j).card :=
          add_le_add card_image_le card_image_le
      _ ≤ 2 ^ (j + 1 + 1) := by rw [pow_succ 2 (j + 1)]; omega

/-- What the Reyes strategy on one more block chooses: the Carter strategy
on the lowest block, unless that block is all white or all black; then the
Reyes strategy on the blocks above. -/
theorem reyes_succ_code (j : ℕ) (t : Stack) :
    reyes (j + 1) (code (3 * (j + 1 + 1)) t)
      = if code 3 t = 0 ∨ code 3 t = 7 then 3 + reyes j (code (3 * (j + 1)) (drop 3 t))
        else carterOdd 1 (code 3 t) := by
  have e : 3 * (j + 1 + 1) = 3 + 3 * (j + 1) := by ring
  rw [e, code_add, reyes, dr_apply 3 _ _ _ (code_lt 3 t)]
  norm_num

/-- Adding a block does not change the choice, once a block is neither all
white nor all black. -/
theorem reyes_stable (j : ℕ) (t : Stack)
    (h : ∃ i ≤ j, ¬ (code 3 (drop (3 * i) t) = 0 ∨ code 3 (drop (3 * i) t) = 7)) :
    reyes (j + 1) (code (3 * (j + 1 + 1)) t) = reyes j (code (3 * (j + 1)) t) := by
  induction j generalizing t with
  | zero =>
    obtain ⟨i, hi, hu⟩ := h
    obtain rfl : i = 0 := by omega
    have hu' : ¬ (code 3 t = 0 ∨ code 3 t = 7) := by rwa [Nat.mul_zero, drop_zero] at hu
    rw [reyes_succ_code]
    simp only [hu', ↓reduceIte]
    rfl
  | succ j ih =>
    rw [reyes_succ_code (j + 1) t, reyes_succ_code j t]
    by_cases hu : code 3 t = 0 ∨ code 3 t = 7
    · simp only [hu, ↓reduceIte]
      obtain ⟨i, hi, hi'⟩ := h
      rcases i with _ | i
      · rw [Nat.mul_zero, drop_zero] at hi'; exact absurd hu hi'
      · rw [ih (drop 3 t) ⟨i, by omega, by rwa [drop_drop, show 3 * i + 3 = 3 * (i + 1) by ring]⟩]
    · simp only [hu, ↓reduceIte]

/-- The Reyes strategies on infinite stacks: the limit of those on
`3 * (j + 1)` hats. -/
noncomputable def reyesInf : Stack → ℤ :=
  limitOf (fun j => 3 * (j + 1)) reyes uniformBlocks

theorem reyes_settles : Settles (fun j => 3 * (j + 1)) reyes uniformBlocks := by
  intro j t hj
  rw [mem_uniformBlocks] at hj
  push Not at hj
  obtain ⟨i, hi, h1, h2⟩ := hj
  refine ⟨?_, reyes_stable j t ⟨i, hi, by push Not; exact ⟨h1, h2⟩⟩⟩
  rw [mem_uniformBlocks]
  push Not
  exact ⟨i, by omega, h1, h2⟩

/-- When the blocks below block `i` are each all white or all black, the
Reyes strategy on `i + 1` blocks plays the Carter strategy on block `i`. -/
theorem reyes_code_of_uniform (i : ℕ) (t : Stack)
    (h : ∀ i' < i, code 3 (drop (3 * i') t) = 0 ∨ code 3 (drop (3 * i') t) = 7) :
    reyes i (code (3 * (i + 1)) t) = 3 * i + carterOdd 1 (code 3 (drop (3 * i) t)) := by
  induction i generalizing t with
  | zero => simp [reyes, drop_zero]
  | succ i ih =>
    have h0 : code 3 t = 0 ∨ code 3 t = 7 := by
      have := h 0 (Nat.succ_pos i); rwa [Nat.mul_zero, drop_zero] at this
    rw [reyes_succ_code]
    simp only [h0, ↓reduceIte]
    rw [ih (drop 3 t) fun i' hi' => by
      have := h (i' + 1) (by omega)
      rwa [drop_drop, show 3 * i' + 3 = 3 * (i' + 1) by ring]]
    rw [drop_drop, show 3 * i + 3 = 3 * (i + 1) by ring]
    push_cast
    ring

/-- On a stack whose first block that is neither all white nor all black
is block `i`, the limit of the Reyes strategies plays the Carter strategy
on that block. -/
theorem reyesInf_spec {t : Stack} {i : ℕ}
    (hi : ¬ (code 3 (drop (3 * i) t) = 0 ∨ code 3 (drop (3 * i) t) = 7))
    (h : ∀ i' < i, code 3 (drop (3 * i') t) = 0 ∨ code 3 (drop (3 * i') t) = 7) :
    reyesInf t = 3 * i + carterOdd 1 (code 3 (drop (3 * i) t)) := by
  have hk : code (3 * (i + 1)) t ∉ uniformBlocks i := by
    rw [mem_uniformBlocks]
    intro hall
    exact hi (hall i le_rfl)
  rw [reyesInf, ← limitOf_eq reyes_settles hk i le_rfl]
  exact reyes_code_of_uniform i t h

/-- **On infinite stacks, the limit of the Reyes strategies wins with
probability `7 / 20`.** -/
theorem rateInf_reyesInf : rateInf reyesInf = 7 / 20 := by
  refine rateInf_limitOf reyes_proper reyes_settles ?_ tendsto_rate_reyes
  have hbound : ∀ j : ℕ,
      ((uniformBlocks j).card : ℝ) / 2 ^ (3 * (j + 1)) ≤ (1 / 4 : ℝ) ^ (j + 1) := by
    intro j
    have h1 : ((uniformBlocks j).card : ℝ) ≤ 2 ^ (j + 1) := by
      exact_mod_cast card_uniformBlocks j
    have e : (2 : ℝ) ^ (3 * (j + 1)) = 8 ^ (j + 1) := by rw [pow_mul]; norm_num
    rw [e, div_le_iff₀ (by positivity), ← mul_pow]
    norm_num
    exact h1
  have h0 : Tendsto (fun j : ℕ => (1 / 4 : ℝ) ^ (j + 1)) atTop (𝓝 0) :=
    (tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)).comp
      (tendsto_add_atTop_nat 1)
  exact squeeze_zero (fun j => by positivity) hbound h0

end Hats
