-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Three

/-!
# Three players: the wins of a substitution

The substitution of a table `S` on `n` hats for the bottom hat of a table
`M` on `k + 1` hats: a player who sees two stacks whose `n` lowest hats
are of a single color reads each as one hat of that color under the `k`
others and asks `M`; if `M` points at the bottom hat, or if one of the two
stacks seen is mixed below, the player plays `S` on the `n` lowest hats.

`wins3_sub`: the result has `8 ^ k * (wins3 S - 1) + wins3 M` wins.
-/

namespace Hats

open Finset

/-- A player who sees the lower parts `lu` and `lv` asks `M`. -/
def ask3 (n lu lv : ℕ) : Prop := (lu = 0 ∨ lu = 2 ^ n - 1) ∧ (lv = 0 ∨ lv = 2 ^ n - 1)

instance (n lu lv : ℕ) : Decidable (ask3 n lu lv) := by unfold ask3; infer_instance

/-- The table `S` on `n` hats put in the place of the bottom hat of `M`. -/
def sub3 (n : ℕ) (M S : ℕ → ℕ → ℤ) : ℕ → ℕ → ℤ := fun u v =>
  if ask3 n (u % 2 ^ n) (v % 2 ^ n) then
    subPoint n
      (M (2 * (u / 2 ^ n) + (if u % 2 ^ n = 2 ^ n - 1 then 1 else 0))
        (2 * (v / 2 ^ n) + (if v % 2 ^ n = 2 ^ n - 1 then 1 else 0)))
      (S (u % 2 ^ n) (v % 2 ^ n))
  else S (u % 2 ^ n) (v % 2 ^ n)

/-- What the triples of stacks of `k + 1` hats with given bottom hats
contribute to the wins of `M`. -/
def bottom3 (k : ℕ) (M : ℕ → ℕ → ℤ) (ca cb cc : ℕ) : ℕ :=
  ∑ xa ∈ range (2 ^ k), ∑ xb ∈ range (2 ^ k), ∑ xc ∈ range (2 ^ k),
    term3 M (2 * xa + ca) (2 * xb + cb) (2 * xc + cc)

theorem wins3_bottom (k : ℕ) (M : ℕ → ℕ → ℤ) :
    wins3 (k + 1) M = bottom3 k M 0 0 0 + bottom3 k M 0 0 1 + bottom3 k M 0 1 0
      + bottom3 k M 0 1 1 + bottom3 k M 1 0 0 + bottom3 k M 1 0 1 + bottom3 k M 1 1 0
      + bottom3 k M 1 1 1 := by
  rw [show k + 1 = 1 + k from Nat.add_comm k 1, wins3_split]
  unfold block3 bottom3
  simp only [pow_one, sum_range_succ, sum_range_zero, zero_add]
  ring

section

variable {n k : ℕ} {S M : ℕ → ℕ → ℤ}

theorem sub3_stay (M S : ℕ → ℕ → ℤ) {lu lv : ℕ} (hlu : lu < 2 ^ n) (hlv : lv < 2 ^ n)
    (xu xv : ℕ) (h : ¬ ask3 n lu lv) :
    sub3 n M S (2 ^ n * xu + lu) (2 ^ n * xv + lv) = S lu lv := by
  simp [sub3, Nat.mod_eq_of_lt hlu, Nat.mod_eq_of_lt hlv, h]

theorem sub3_end (hn : 1 ≤ n) (M S : ℕ → ℕ → ℤ) (xu xv : ℕ) {cu cv : ℕ}
    (hcu : cu < 2) (hcv : cv < 2) :
    sub3 n M S (2 ^ n * xu + cu * (2 ^ n - 1)) (2 ^ n * xv + cv * (2 ^ n - 1))
      = subPoint n (M (2 * xu + cu) (2 * xv + cv))
        (S (cu * (2 ^ n - 1)) (cv * (2 ^ n - 1))) := by
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have hpos := Nat.two_pow_pos n
  have hu := end_lt (n := n) hcu
  have hv := end_lt (n := n) hcv
  have hne : (0 : ℕ) ≠ 2 ^ n - 1 := by omega
  have hne' : 2 ^ n - 1 ≠ 0 := by omega
  obtain rfl | rfl : cu = 0 ∨ cu = 1 := by omega
  · obtain rfl | rfl : cv = 0 ∨ cv = 1 := by omega
    · simp [sub3, ask3, Nat.mul_div_cancel_left _ hpos, hne]
    · simp [sub3, ask3, Nat.mul_div_cancel_left _ hpos, hne, Nat.mul_add_div hpos,
        Nat.mod_eq_of_lt (show 2 ^ n - 1 < 2 ^ n by omega),
        Nat.div_eq_of_lt (show 2 ^ n - 1 < 2 ^ n by omega)]
  · obtain rfl | rfl : cv = 0 ∨ cv = 1 := by omega
    · simp [sub3, ask3, Nat.mul_div_cancel_left _ hpos, hne, Nat.mul_add_div hpos,
        Nat.mod_eq_of_lt (show 2 ^ n - 1 < 2 ^ n by omega),
        Nat.div_eq_of_lt (show 2 ^ n - 1 < 2 ^ n by omega)]
    · simp [sub3, ask3, Nat.mul_add_div hpos,
        Nat.mod_eq_of_lt (show 2 ^ n - 1 < 2 ^ n by omega),
        Nat.div_eq_of_lt (show 2 ^ n - 1 < 2 ^ n by omega)]

/-- A stack that is mixed below, at the position that a player who asks
`M` points at: summed over the mixed lower parts and the hats above. -/
theorem sum_mixed_point (hn : 1 ≤ n) {v r : ℤ} (hv : 0 ≤ v) (hvk : v < k + 1)
    (hr : 0 ≤ r) (hrn : r < n) :
    ∑ l ∈ Ico 1 (2 ^ n - 1), ∑ x ∈ range (2 ^ k), hat (2 ^ n * x + l) (subPoint n v r)
      = 2 ^ k * (2 ^ (n - 1) - 1) := by
  have term : ∀ l ∈ Ico 1 (2 ^ n - 1), ∀ x ∈ range (2 ^ k),
      hat (2 ^ n * x + l) (subPoint n v r) = if v = 0 then hat l r else hat x (v - 1) := by
    intro l hl x _
    have h := mem_Ico.mp hl
    have hl' : l < 2 ^ n := by omega
    by_cases h0 : v = 0
    · simp [subPoint, h0, hat_low x hl' hr hrn]
    · have e : subPoint n v r = n + (v - 1) := by simp [subPoint, h0]
      rw [e, hat_above x hl' (by omega)]
      simp [h0]
  rw [sum_congr rfl fun l hl => sum_congr rfl fun x hx => term l hl x hx]
  by_cases h0 : v = 0
  · simp only [h0, ↓reduceIte, sum_const, card_range, smul_eq_mul]
    rw [← mul_sum, sum_mid_hat hn hr hrn]
  · simp only [h0, ↓reduceIte]
    rw [sum_congr rfl fun l _ => sum_hat (show 0 ≤ v - 1 by omega) (show v - 1 < k by omega)]
    simp only [sum_const, smul_eq_mul, Nat.card_Ico]
    obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
    obtain ⟨i, rfl⟩ : ∃ i, n = i + 1 := ⟨n - 1, by omega⟩
    obtain ⟨a, ha⟩ : ∃ a, 2 ^ i = a + 1 := ⟨2 ^ i - 1, by have := Nat.two_pow_pos i; omega⟩
    simp only [Nat.add_sub_cancel, pow_succ, ha]
    have e1 : (a + 1) * 2 - 1 - 1 = 2 * a := by omega
    rw [e1]
    ring

variable (hS : Proper3 n S) (hM : Proper3 (k + 1) M)

include hS in
theorem fac3_stay (M : ℕ → ℕ → ℤ) {l lu lv : ℕ} (x xu xv : ℕ) (hl : l < 2 ^ n)
    (hlu : lu < 2 ^ n) (hlv : lv < 2 ^ n) (h : ¬ ask3 n lu lv) :
    hat (2 ^ n * x + l) (sub3 n M S (2 ^ n * xu + lu) (2 ^ n * xv + lv))
      = hat l (S lu lv) := by
  rw [sub3_stay M S hlu hlv xu xv h,
    hat_low x hl (hS lu lv hlu hlv).1 (hS lu lv hlu hlv).2]

include hS hM in
/-- A player whose stack is of a single color below and who asks `M`. -/
theorem fac3_ask {c cu cv x xu xv : ℕ} (hc : c < 2) (hcu : cu < 2) (hcv : cv < 2)
    (hxu : xu < 2 ^ k) (hxv : xv < 2 ^ k) :
    hat (2 ^ n * x + c * (2 ^ n - 1))
        (sub3 n M S (2 ^ n * xu + cu * (2 ^ n - 1)) (2 ^ n * xv + cv * (2 ^ n - 1)))
      = hat (2 * x + c) (M (2 * xu + cu) (2 * xv + cv)) := by
  have r := hS _ _ (end_lt (n := n) hcu) (end_lt (n := n) hcv)
  have b := hM (2 * xu + cu) (2 * xv + cv) (by rw [pow_succ]; omega) (by rw [pow_succ]; omega)
  rw [sub3_end hS.pos M S xu xv hcu hcv, hat_end x hc b.1 r.1 r.2]

include hS hM in
/-- Three stacks of a single color below. -/
theorem block3_ends {ca cb cc : ℕ} (ha : ca < 2) (hb : cb < 2) (hc : cc < 2) :
    block3 n k (sub3 n M S) (ca * (2 ^ n - 1)) (cb * (2 ^ n - 1)) (cc * (2 ^ n - 1))
      = bottom3 k M ca cb cc := by
  unfold block3 bottom3
  refine sum_congr rfl fun xa hxa => sum_congr rfl fun xb hxb => sum_congr rfl fun xc hxc => ?_
  unfold term3
  rw [fac3_ask hS hM ha hb hc (mem_range.mp hxb) (mem_range.mp hxc),
    fac3_ask hS hM hb ha hc (mem_range.mp hxa) (mem_range.mp hxc),
    fac3_ask hS hM hc ha hb (mem_range.mp hxa) (mem_range.mp hxb)]

include hS in
/-- Nobody asks `M`. -/
theorem block3_none {la lb lc : ℕ} (ha : la < 2 ^ n) (hb : lb < 2 ^ n) (hc : lc < 2 ^ n)
    (h1 : ¬ ask3 n lb lc) (h2 : ¬ ask3 n la lc) (h3 : ¬ ask3 n la lb) :
    block3 n k (sub3 n M S) la lb lc = 8 ^ k * term3 S la lb lc := by
  have term : ∀ xa xb xc, term3 (sub3 n M S) (2 ^ n * xa + la) (2 ^ n * xb + lb)
      (2 ^ n * xc + lc) = term3 S la lb lc := by
    intro xa xb xc
    unfold term3
    rw [fac3_stay hS M xa xb xc ha hb hc h1, fac3_stay hS M xb xa xc hb ha hc h2,
      fac3_stay hS M xc xa xb hc ha hb h3]
  unfold block3
  simp only [term, sum_const, card_range, smul_eq_mul, eight_pow]
  ring

include hS in
theorem block3_zero_a {lb lc : ℕ} (hb : lb < 2 ^ n) (hc : lc < 2 ^ n) (h : ¬ ask3 n lb lc) :
    block3 n k (sub3 n M S) 0 lb lc = 0 := by
  unfold block3
  refine sum_eq_zero fun xa _ => sum_eq_zero fun xb _ => sum_eq_zero fun xc _ => ?_
  unfold term3
  rw [fac3_stay hS M xa xb xc (Nat.two_pow_pos n) hb hc h, hat_zero]
  simp

include hS in
theorem block3_zero_b {la lc : ℕ} (ha : la < 2 ^ n) (hc : lc < 2 ^ n) (h : ¬ ask3 n la lc) :
    block3 n k (sub3 n M S) la 0 lc = 0 := by
  unfold block3
  refine sum_eq_zero fun xa _ => sum_eq_zero fun xb _ => sum_eq_zero fun xc _ => ?_
  unfold term3
  rw [fac3_stay hS M xb xa xc (Nat.two_pow_pos n) ha hc h, hat_zero]
  simp

include hS in
theorem block3_zero_c {la lb : ℕ} (ha : la < 2 ^ n) (hb : lb < 2 ^ n) (h : ¬ ask3 n la lb) :
    block3 n k (sub3 n M S) la lb 0 = 0 := by
  unfold block3
  refine sum_eq_zero fun xa _ => sum_eq_zero fun xb _ => sum_eq_zero fun xc _ => ?_
  unfold term3
  rw [fac3_stay hS M xc xa xb (Nat.two_pow_pos n) ha hb h, hat_zero]
  simp

include hS hM in
/-- Two stacks all black below and the first one mixed. -/
theorem sum_block3_a :
    ∑ la ∈ Ico 1 (2 ^ n - 1), block3 n k (sub3 n M S) la (2 ^ n - 1) (2 ^ n - 1)
      = 8 ^ k * (2 ^ (n - 1) - 1) := by
  have hn := hS.pos
  have hB : 2 ^ n - 1 < 2 ^ n := Nat.sub_lt (Nat.two_pow_pos n) one_pos
  have rB := hS _ _ hB hB
  have term : ∀ la ∈ Ico 1 (2 ^ n - 1), ∀ xa ∈ range (2 ^ k), ∀ xb ∈ range (2 ^ k),
      ∀ xc ∈ range (2 ^ k),
      term3 (sub3 n M S) (2 ^ n * xa + la) (2 ^ n * xb + (2 ^ n - 1))
        (2 ^ n * xc + (2 ^ n - 1))
        = hat (2 ^ n * xa + la)
          (subPoint n (M (2 * xb + 1) (2 * xc + 1)) (S (2 ^ n - 1) (2 ^ n - 1))) := by
    intro la hla xa _ xb _ xc _
    have h := mem_Ico.mp hla
    have ha : la < 2 ^ n := by omega
    have r := hS la (2 ^ n - 1) ha hB
    have g : ¬ ask3 n la (2 ^ n - 1) := by unfold ask3; omega
    have e := sub3_end hn M S xb xc (cu := 1) (cv := 1) (by norm_num) (by norm_num)
    simp only [one_mul] at e
    unfold term3
    rw [e, fac3_stay hS M xb xa xc hB ha hB g, fac3_stay hS M xc xa xb hB ha hB g,
      hat_ones r.1 r.2]
    simp
  unfold block3
  rw [sum_congr rfl fun la hla => sum_congr rfl fun xa hxa => sum_congr rfl fun xb hxb =>
    sum_congr rfl fun xc hxc => term la hla xa hxa xb hxb xc hxc]
  rw [sum_congr rfl fun la _ => sum_comm,
    sum_congr rfl fun la _ => sum_congr rfl fun xb _ => sum_comm, sum_comm,
    sum_congr rfl fun xb _ => sum_comm]
  rw [sum_congr rfl fun xb hxb => sum_congr rfl fun xc hxc => by
    have b := hM (2 * xb + 1) (2 * xc + 1)
      (by rw [pow_succ]; have := mem_range.mp hxb; omega)
      (by rw [pow_succ]; have := mem_range.mp hxc; omega)
    exact sum_mixed_point hn b.1 (by exact_mod_cast b.2) rB.1 rB.2]
  simp only [sum_const, card_range, smul_eq_mul, eight_pow]
  ring

include hS hM in
theorem sum_block3_b :
    ∑ lb ∈ Ico 1 (2 ^ n - 1), block3 n k (sub3 n M S) (2 ^ n - 1) lb (2 ^ n - 1)
      = 8 ^ k * (2 ^ (n - 1) - 1) := by
  have hn := hS.pos
  have hB : 2 ^ n - 1 < 2 ^ n := Nat.sub_lt (Nat.two_pow_pos n) one_pos
  have rB := hS _ _ hB hB
  have term : ∀ lb ∈ Ico 1 (2 ^ n - 1), ∀ xa ∈ range (2 ^ k), ∀ xb ∈ range (2 ^ k),
      ∀ xc ∈ range (2 ^ k),
      term3 (sub3 n M S) (2 ^ n * xa + (2 ^ n - 1)) (2 ^ n * xb + lb)
        (2 ^ n * xc + (2 ^ n - 1))
        = hat (2 ^ n * xb + lb)
          (subPoint n (M (2 * xa + 1) (2 * xc + 1)) (S (2 ^ n - 1) (2 ^ n - 1))) := by
    intro lb hlb xa _ xb _ xc _
    have h := mem_Ico.mp hlb
    have hb : lb < 2 ^ n := by omega
    have r := hS lb (2 ^ n - 1) hb hB
    have r' := hS (2 ^ n - 1) lb hB hb
    have g : ¬ ask3 n lb (2 ^ n - 1) := by unfold ask3; omega
    have g' : ¬ ask3 n (2 ^ n - 1) lb := by unfold ask3; omega
    have e := sub3_end hn M S xa xc (cu := 1) (cv := 1) (by norm_num) (by norm_num)
    simp only [one_mul] at e
    unfold term3
    rw [e, fac3_stay hS M xa xb xc hB hb hB g, fac3_stay hS M xc xa xb hB hB hb g',
      hat_ones r.1 r.2, hat_ones r'.1 r'.2]
    simp
  unfold block3
  rw [sum_congr rfl fun lb hlb => sum_congr rfl fun xa hxa => sum_congr rfl fun xb hxb =>
    sum_congr rfl fun xc hxc => term lb hlb xa hxa xb hxb xc hxc]
  rw [sum_comm, sum_congr rfl fun xa _ => sum_congr rfl fun lb _ => sum_comm,
    sum_congr rfl fun xa _ => sum_comm]
  rw [sum_congr rfl fun xa hxa => sum_congr rfl fun xc hxc => by
    have b := hM (2 * xa + 1) (2 * xc + 1)
      (by rw [pow_succ]; have := mem_range.mp hxa; omega)
      (by rw [pow_succ]; have := mem_range.mp hxc; omega)
    exact sum_mixed_point hn b.1 (by exact_mod_cast b.2) rB.1 rB.2]
  simp only [sum_const, card_range, smul_eq_mul, eight_pow]
  ring

include hS hM in
theorem sum_block3_c :
    ∑ lc ∈ Ico 1 (2 ^ n - 1), block3 n k (sub3 n M S) (2 ^ n - 1) (2 ^ n - 1) lc
      = 8 ^ k * (2 ^ (n - 1) - 1) := by
  have hn := hS.pos
  have hB : 2 ^ n - 1 < 2 ^ n := Nat.sub_lt (Nat.two_pow_pos n) one_pos
  have rB := hS _ _ hB hB
  have term : ∀ lc ∈ Ico 1 (2 ^ n - 1), ∀ xa ∈ range (2 ^ k), ∀ xb ∈ range (2 ^ k),
      ∀ xc ∈ range (2 ^ k),
      term3 (sub3 n M S) (2 ^ n * xa + (2 ^ n - 1)) (2 ^ n * xb + (2 ^ n - 1))
        (2 ^ n * xc + lc)
        = hat (2 ^ n * xc + lc)
          (subPoint n (M (2 * xa + 1) (2 * xb + 1)) (S (2 ^ n - 1) (2 ^ n - 1))) := by
    intro lc hlc xa _ xb _ xc _
    have h := mem_Ico.mp hlc
    have hc : lc < 2 ^ n := by omega
    have r' := hS (2 ^ n - 1) lc hB hc
    have g' : ¬ ask3 n (2 ^ n - 1) lc := by unfold ask3; omega
    have e := sub3_end hn M S xa xb (cu := 1) (cv := 1) (by norm_num) (by norm_num)
    simp only [one_mul] at e
    unfold term3
    rw [e, fac3_stay hS M xa xb xc hB hB hc g', fac3_stay hS M xb xa xc hB hB hc g',
      hat_ones r'.1 r'.2]
    simp
  unfold block3
  rw [sum_congr rfl fun lc hlc => sum_congr rfl fun xa hxa => sum_congr rfl fun xb hxb =>
    sum_congr rfl fun xc hxc => term lc hlc xa hxa xb hxb xc hxc]
  rw [sum_comm, sum_congr rfl fun xa _ => sum_comm]
  rw [sum_congr rfl fun xa hxa => sum_congr rfl fun xb hxb => by
    have b := hM (2 * xa + 1) (2 * xb + 1)
      (by rw [pow_succ]; have := mem_range.mp hxa; omega)
      (by rw [pow_succ]; have := mem_range.mp hxb; omega)
    exact sum_mixed_point hn b.1 (by exact_mod_cast b.2) rB.1 rB.2]
  simp only [sum_const, card_range, smul_eq_mul, eight_pow]
  ring

/-! ### Row by row -/

include hS hM in
theorem sub_row_white :
    ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), block3 n k (sub3 n M S) 0 lb lc
      = bottom3 k M 0 0 0 + bottom3 k M 0 0 1 + bottom3 k M 0 1 0 + bottom3 k M 0 1 1 := by
  have hn := hS.pos
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have hB : 2 ^ n - 1 < 2 ^ n := by omega
  have c1 := block3_ends hS hM (ca := 0) (cb := 0) (cc := 0) (by norm_num) (by norm_num)
    (by norm_num)
  have c2 := block3_ends hS hM (ca := 0) (cb := 0) (cc := 1) (by norm_num) (by norm_num)
    (by norm_num)
  have c3 := block3_ends hS hM (ca := 0) (cb := 1) (cc := 0) (by norm_num) (by norm_num)
    (by norm_num)
  have c4 := block3_ends hS hM (ca := 0) (cb := 1) (cc := 1) (by norm_num) (by norm_num)
    (by norm_num)
  simp only [zero_mul, one_mul] at c1 c2 c3 c4
  have s1 : ∀ u ∈ Ico 1 (2 ^ n - 1), block3 n k (sub3 n M S) 0 0 u
      + block3 n k (sub3 n M S) 0 (2 ^ n - 1) u = 0 := by
    intro u hu
    have h := mem_Ico.mp hu
    rw [block3_zero_a hS (by omega) (by omega) (by unfold ask3; omega), block3_zero_a hS hB (by omega) (by unfold ask3; omega)]
  have s2 : ∀ t ∈ Ico 1 (2 ^ n - 1), block3 n k (sub3 n M S) 0 t 0
      + block3 n k (sub3 n M S) 0 t (2 ^ n - 1) = 0 := by
    intro t ht
    have h := mem_Ico.mp ht
    rw [block3_zero_a hS (by omega) (by omega) (by unfold ask3; omega), block3_zero_a hS (by omega) hB (by unfold ask3; omega)]
  have s3 : ∀ t ∈ Ico 1 (2 ^ n - 1), ∀ u ∈ Ico 1 (2 ^ n - 1),
      block3 n k (sub3 n M S) 0 t u = 0 := by
    intro t ht u hu
    have h := mem_Ico.mp ht
    have h' := mem_Ico.mp hu
    exact block3_zero_a hS (by omega) (by omega) (by unfold ask3; omega)
  rw [sum_ends2 hP, c1, c2, c3, c4, sum_congr rfl s1, sum_congr rfl s2,
    sum_congr rfl fun t ht => sum_congr rfl fun u hu => s3 t ht u hu]
  simp

include hS hM in
theorem sub_row_black :
    ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n),
        block3 n k (sub3 n M S) (2 ^ n - 1) lb lc + 8 ^ k
      = bottom3 k M 1 0 0 + bottom3 k M 1 0 1 + bottom3 k M 1 1 0 + bottom3 k M 1 1 1
        + 8 ^ k * ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), term3 S (2 ^ n - 1) lb lc := by
  have hn := hS.pos
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have hB : 2 ^ n - 1 < 2 ^ n := by omega
  have rB := hS _ _ hB hB
  have c1 := block3_ends hS hM (ca := 1) (cb := 0) (cc := 0) (by norm_num) (by norm_num)
    (by norm_num)
  have c2 := block3_ends hS hM (ca := 1) (cb := 0) (cc := 1) (by norm_num) (by norm_num)
    (by norm_num)
  have c3 := block3_ends hS hM (ca := 1) (cb := 1) (cc := 0) (by norm_num) (by norm_num)
    (by norm_num)
  have c4 := block3_ends hS hM (ca := 1) (cb := 1) (cc := 1) (by norm_num) (by norm_num)
    (by norm_num)
  simp only [zero_mul, one_mul] at c1 c2 c3 c4
  have s1 : ∑ u ∈ Ico 1 (2 ^ n - 1), (block3 n k (sub3 n M S) (2 ^ n - 1) 0 u
      + block3 n k (sub3 n M S) (2 ^ n - 1) (2 ^ n - 1) u) = 8 ^ k * (2 ^ (n - 1) - 1) := by
    rw [← sum_block3_c hS hM]
    refine sum_congr rfl fun u hu => ?_
    have h := mem_Ico.mp hu
    rw [block3_zero_b hS hB (by omega) (by unfold ask3; omega), zero_add]
  have s2 : ∑ t ∈ Ico 1 (2 ^ n - 1), (block3 n k (sub3 n M S) (2 ^ n - 1) t 0
      + block3 n k (sub3 n M S) (2 ^ n - 1) t (2 ^ n - 1)) = 8 ^ k * (2 ^ (n - 1) - 1) := by
    rw [← sum_block3_b hS hM]
    refine sum_congr rfl fun t ht => ?_
    have h := mem_Ico.mp ht
    rw [block3_zero_c hS hB (by omega) (by unfold ask3; omega), zero_add]
  have s3 : ∀ t ∈ Ico 1 (2 ^ n - 1), ∀ u ∈ Ico 1 (2 ^ n - 1),
      block3 n k (sub3 n M S) (2 ^ n - 1) t u = 8 ^ k * term3 S (2 ^ n - 1) t u := by
    intro t ht u hu
    have h := mem_Ico.mp ht
    have h' := mem_Ico.mp hu
    exact block3_none hS hB (by omega) (by omega) (by unfold ask3; omega) (by unfold ask3; omega) (by unfold ask3; omega)
  have t1 : ∀ u ∈ Ico 1 (2 ^ n - 1), term3 S (2 ^ n - 1) 0 u
      + term3 S (2 ^ n - 1) (2 ^ n - 1) u = hat u (S (2 ^ n - 1) (2 ^ n - 1)) := by
    intro u hu
    have h := mem_Ico.mp hu
    rw [term3_zero_b, term3_black_c hS (by omega), zero_add]
  have t2 : ∀ t ∈ Ico 1 (2 ^ n - 1), term3 S (2 ^ n - 1) t 0
      + term3 S (2 ^ n - 1) t (2 ^ n - 1) = hat t (S (2 ^ n - 1) (2 ^ n - 1)) := by
    intro t ht
    have h := mem_Ico.mp ht
    rw [term3_zero_c, term3_black_b hS (by omega), zero_add]
  have tBBB : term3 S (2 ^ n - 1) (2 ^ n - 1) (2 ^ n - 1) = 1 := by
    rw [term3_black_a hS hB, hat_ones rB.1 rB.2]
  have hmid := sum_mid_hat hn rB.1 rB.2
  rw [sum_ends2 hP, sum_ends2 hP, c1, c2, c3, c4, s1, s2,
    sum_congr rfl fun t ht => sum_congr rfl fun u hu => s3 t ht u hu,
    sum_congr rfl t1, sum_congr rfl t2, hmid, term3_zero_b, term3_zero_b, term3_zero_c, tBBB]
  simp only [← mul_sum]
  ring

include hS in
theorem sub_row_mixed {la : ℕ} (h0 : 0 < la) (h1 : la < 2 ^ n - 1) :
    ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), block3 n k (sub3 n M S) la lb lc
        + 8 ^ k * hat la (S (2 ^ n - 1) (2 ^ n - 1))
      = block3 n k (sub3 n M S) la (2 ^ n - 1) (2 ^ n - 1)
        + 8 ^ k * ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), term3 S la lb lc := by
  have hn := hS.pos
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have hz : 0 < 2 ^ n := by omega
  have hB : 2 ^ n - 1 < 2 ^ n := by omega
  have ha : la < 2 ^ n := by omega
  have c1 : block3 n k (sub3 n M S) la 0 0 = 0 := block3_zero_b hS ha hz (by unfold ask3; omega)
  have c2 : block3 n k (sub3 n M S) la 0 (2 ^ n - 1) = 0 := block3_zero_b hS ha hB (by unfold ask3; omega)
  have c3 : block3 n k (sub3 n M S) la (2 ^ n - 1) 0 = 0 := block3_zero_c hS ha hB (by unfold ask3; omega)
  have s1 : ∀ u ∈ Ico 1 (2 ^ n - 1), block3 n k (sub3 n M S) la 0 u
      + block3 n k (sub3 n M S) la (2 ^ n - 1) u
        = 8 ^ k * (term3 S la 0 u + term3 S la (2 ^ n - 1) u) := by
    intro u hu
    have h := mem_Ico.mp hu
    rw [block3_none hS ha hz (by omega) (by unfold ask3; omega) (by unfold ask3; omega) (by unfold ask3; omega), block3_none hS ha hB (by omega) (by unfold ask3; omega) (by unfold ask3; omega) (by unfold ask3; omega)]
    ring
  have s2 : ∀ t ∈ Ico 1 (2 ^ n - 1), block3 n k (sub3 n M S) la t 0
      + block3 n k (sub3 n M S) la t (2 ^ n - 1)
        = 8 ^ k * (term3 S la t 0 + term3 S la t (2 ^ n - 1)) := by
    intro t ht
    have h := mem_Ico.mp ht
    rw [block3_none hS ha (by omega) hz (by unfold ask3; omega) (by unfold ask3; omega) (by unfold ask3; omega), block3_none hS ha (by omega) hB (by unfold ask3; omega) (by unfold ask3; omega) (by unfold ask3; omega)]
    ring
  have s3 : ∀ t ∈ Ico 1 (2 ^ n - 1), ∀ u ∈ Ico 1 (2 ^ n - 1),
      block3 n k (sub3 n M S) la t u = 8 ^ k * term3 S la t u := by
    intro t ht u hu
    have h := mem_Ico.mp ht
    have h' := mem_Ico.mp hu
    exact block3_none hS ha (by omega) (by omega) (by unfold ask3; omega) (by unfold ask3; omega) (by unfold ask3; omega)
  rw [sum_ends2 hP, sum_ends2 hP, c1, c2, c3, sum_congr rfl s1, sum_congr rfl s2,
    sum_congr rfl fun t ht => sum_congr rfl fun u hu => s3 t ht u hu,
    term3_zero_b, term3_zero_b, term3_zero_c, term3_black_a hS ha]
  simp only [← mul_sum]
  ring

include hS hM in
/-- **Wins of a substitution, three players.**  If `S` is a proper table
on `n` hats and `M` a proper table on `k + 1` hats, then `S` put in the
place of the bottom hat of `M` has `8 ^ k * (wins3 S - 1) + wins3 M` wins. -/
theorem wins3_sub :
    wins3 (n + k) (sub3 n M S) + 8 ^ k = 8 ^ k * wins3 n S + wins3 (k + 1) M := by
  have hn := hS.pos
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have hB : 2 ^ n - 1 < 2 ^ n := by omega
  have rB := hS _ _ hB hB
  have hmid := sum_mid_hat hn rB.1 rB.2
  have r0 := sub_row_white hS hM
  have r1 := sub_row_black hS hM
  have r2 : ∑ la ∈ Ico 1 (2 ^ n - 1),
      ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), block3 n k (sub3 n M S) la lb lc
      = 8 ^ k * ∑ la ∈ Ico 1 (2 ^ n - 1),
          ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), term3 S la lb lc := by
    have := sum_congr rfl fun la (hla : la ∈ Ico 1 (2 ^ n - 1)) =>
      sub_row_mixed (M := M) (k := k) hS (mem_Ico.mp hla).1 (mem_Ico.mp hla).2
    rw [sum_add_distrib, sum_add_distrib, ← mul_sum, hmid, ← mul_sum,
      sum_block3_a hS hM] at this
    omega
  have z : ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), term3 S 0 lb lc = 0 :=
    sum_eq_zero fun lb _ => sum_eq_zero fun lc _ => term3_zero_a S lb lc
  have eS : wins3 n S = ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), term3 S (2 ^ n - 1) lb lc
      + ∑ la ∈ Ico 1 (2 ^ n - 1), ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), term3 S la lb lc := by
    unfold wins3
    rw [sum_ends hP, z, zero_add]
  rw [wins3_split, sum_ends hP, r0, r2, eS, wins3_bottom, mul_add]
  omega

end

end Hats
