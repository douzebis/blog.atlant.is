-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Substitute

/-!
# Three players: the wins of a reset

Three players, each with a stack of hats; each sees the two other stacks
and points at a position of their own stack; they win when the three hats
pointed at are black.  The three players use the same table `s`: the
player who sees the stacks `u` and `v`, in the order of the players, points
at `s u v`.  Nothing here asks for `s u v = s v u`.

The reset of a table `S` on `n` hats by a table `M` on `k` hats (the
construction of Buhler, Freiling, Graham, Kariv, Roche, Tiefenbruck, Van
Alten and Yeroshkin for three players): a player who sees a stack that is
all white below, or two stacks that are all black below, plays `M` on the
`k` hats above; otherwise plays `S` on the `n` lowest hats.

`wins3_reset`: the result has
`8 ^ k * (wins3 S - 1) + (3 * 2 ^ n + 2) * wins3 M` wins.
-/

namespace Hats

open Finset

/-- What the triple of stacks `(a, b, c)` contributes to the wins of the
table `s`. -/
def term3 (s : ℕ → ℕ → ℤ) (a b c : ℕ) : ℕ :=
  hat a (s b c) * hat b (s a c) * hat c (s a b)

/-- The wins of the table `s` on `n` hats. -/
def wins3 (n : ℕ) (s : ℕ → ℕ → ℤ) : ℕ :=
  ∑ a ∈ range (2 ^ n), ∑ b ∈ range (2 ^ n), ∑ c ∈ range (2 ^ n), term3 s a b c

/-- A table on `n` hats is proper when it always points inside the stack. -/
def Proper3 (n : ℕ) (s : ℕ → ℕ → ℤ) : Prop :=
  ∀ u v, u < 2 ^ n → v < 2 ^ n → 0 ≤ s u v ∧ s u v < n

theorem Proper3.pos {n : ℕ} {s : ℕ → ℕ → ℤ} (h : Proper3 n s) : 1 ≤ n := by
  have := h 0 0 (Nat.two_pow_pos n) (Nat.two_pow_pos n)
  omega

/-- A player who sees the lower parts `lu` and `lv` goes up. -/
def go3 (n lu lv : ℕ) : Prop := lu = 0 ∨ lv = 0 ∨ (lu = 2 ^ n - 1 ∧ lv = 2 ^ n - 1)

instance (n lu lv : ℕ) : Decidable (go3 n lu lv) := by unfold go3; infer_instance

/-- The table `S` on `n` hats reset by the table `M`. -/
def reset3 (n : ℕ) (S M : ℕ → ℕ → ℤ) : ℕ → ℕ → ℤ := fun u v =>
  if go3 n (u % 2 ^ n) (v % 2 ^ n) then n + M (u / 2 ^ n) (v / 2 ^ n)
  else S (u % 2 ^ n) (v % 2 ^ n)

/-- What the triples of stacks with given lower parts contribute. -/
def block3 (n k : ℕ) (s : ℕ → ℕ → ℤ) (la lb lc : ℕ) : ℕ :=
  ∑ xa ∈ range (2 ^ k), ∑ xb ∈ range (2 ^ k), ∑ xc ∈ range (2 ^ k),
    term3 s (2 ^ n * xa + la) (2 ^ n * xb + lb) (2 ^ n * xc + lc)

/-- The wins of a table on `n + k` hats, sorted by the `n` lowest hats of
the three stacks. -/
theorem wins3_split (n k : ℕ) (s : ℕ → ℕ → ℤ) :
    wins3 (n + k) s = ∑ la ∈ range (2 ^ n), ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n),
      block3 n k s la lb lc := by
  unfold wins3 block3
  rw [pow_add]
  simp only [sum_range_mul]
  rw [sum_comm]
  refine sum_congr rfl fun la _ => ?_
  rw [sum_congr rfl fun xa _ => sum_comm, sum_comm]
  refine sum_congr rfl fun lb _ => ?_
  rw [sum_congr rfl fun xa _ => sum_congr rfl fun xb _ => sum_comm,
    sum_congr rfl fun xa _ => sum_comm, sum_comm]

theorem eight_pow (k : ℕ) : (8 : ℕ) ^ k = 2 ^ k * 2 ^ k * 2 ^ k := by
  rw [show (8 : ℕ) = 2 * 2 * 2 from rfl, mul_pow, mul_pow]

section

variable {n k : ℕ} {S M : ℕ → ℕ → ℤ}

theorem reset3_up (S M : ℕ → ℕ → ℤ) {lu lv : ℕ} (hlu : lu < 2 ^ n) (hlv : lv < 2 ^ n)
    (xu xv : ℕ) (h : go3 n lu lv) :
    reset3 n S M (2 ^ n * xu + lu) (2 ^ n * xv + lv) = n + M xu xv := by
  have hpos := Nat.two_pow_pos n
  simp [reset3, Nat.mod_eq_of_lt hlu, Nat.mod_eq_of_lt hlv,
    Nat.mul_add_div hpos, Nat.div_eq_of_lt hlu, Nat.div_eq_of_lt hlv, h]

theorem reset3_stay (S M : ℕ → ℕ → ℤ) {lu lv : ℕ} (hlu : lu < 2 ^ n) (hlv : lv < 2 ^ n)
    (xu xv : ℕ) (h : ¬ go3 n lu lv) :
    reset3 n S M (2 ^ n * xu + lu) (2 ^ n * xv + lv) = S lu lv := by
  simp [reset3, Nat.mod_eq_of_lt hlu, Nat.mod_eq_of_lt hlv, h]

variable (hS : Proper3 n S) (hM : Proper3 k M)

include hM in
/-- The hat pointed at by a player who goes up. -/
theorem fac_up (S : ℕ → ℕ → ℤ) {l lu lv x xu xv : ℕ} (hl : l < 2 ^ n) (hlu : lu < 2 ^ n)
    (hlv : lv < 2 ^ n) (hxu : xu < 2 ^ k) (hxv : xv < 2 ^ k) (h : go3 n lu lv) :
    hat (2 ^ n * x + l) (reset3 n S M (2 ^ n * xu + lu) (2 ^ n * xv + lv))
      = hat x (M xu xv) := by
  rw [reset3_up S M hlu hlv xu xv h, hat_above x hl (hM xu xv hxu hxv).1]

include hS in
/-- The hat pointed at by a player who stays. -/
theorem fac_stay (M : ℕ → ℕ → ℤ) {l lu lv : ℕ} (x xu xv : ℕ) (hl : l < 2 ^ n)
    (hlu : lu < 2 ^ n) (hlv : lv < 2 ^ n) (h : ¬ go3 n lu lv) :
    hat (2 ^ n * x + l) (reset3 n S M (2 ^ n * xu + lu) (2 ^ n * xv + lv))
      = hat l (S lu lv) := by
  rw [reset3_stay S M hlu hlv xu xv h,
    hat_low x hl (hS lu lv hlu hlv).1 (hS lu lv hlu hlv).2]

include hM in
/-- The three players go up. -/
theorem block_all {la lb lc : ℕ} (ha : la < 2 ^ n) (hb : lb < 2 ^ n) (hc : lc < 2 ^ n)
    (h1 : go3 n lb lc) (h2 : go3 n la lc) (h3 : go3 n la lb) :
    block3 n k (reset3 n S M) la lb lc = wins3 k M := by
  unfold block3 wins3
  refine sum_congr rfl fun xa hxa => sum_congr rfl fun xb hxb => sum_congr rfl fun xc hxc => ?_
  have hxa' := mem_range.mp hxa
  have hxb' := mem_range.mp hxb
  have hxc' := mem_range.mp hxc
  unfold term3
  rw [fac_up hM S ha hb hc hxb' hxc' h1, fac_up hM S hb ha hc hxa' hxc' h2,
    fac_up hM S hc ha hb hxa' hxb' h3]

include hS in
/-- Nobody goes up. -/
theorem block_none {la lb lc : ℕ} (ha : la < 2 ^ n) (hb : lb < 2 ^ n) (hc : lc < 2 ^ n)
    (h1 : ¬ go3 n lb lc) (h2 : ¬ go3 n la lc) (h3 : ¬ go3 n la lb) :
    block3 n k (reset3 n S M) la lb lc = 8 ^ k * term3 S la lb lc := by
  have term : ∀ xa xb xc, term3 (reset3 n S M) (2 ^ n * xa + la) (2 ^ n * xb + lb)
      (2 ^ n * xc + lc) = term3 S la lb lc := by
    intro xa xb xc
    unfold term3
    rw [fac_stay hS M xa xb xc ha hb hc h1, fac_stay hS M xb xa xc hb ha hc h2,
      fac_stay hS M xc xa xb hc ha hb h3]
  unfold block3
  simp only [term, sum_const, card_range, smul_eq_mul, eight_pow]
  ring

include hS in
/-- A player whose lowest hats are all white stays: no win. -/
theorem block_zero_a {lb lc : ℕ} (hb : lb < 2 ^ n) (hc : lc < 2 ^ n) (h : ¬ go3 n lb lc) :
    block3 n k (reset3 n S M) 0 lb lc = 0 := by
  unfold block3
  refine sum_eq_zero fun xa _ => sum_eq_zero fun xb _ => sum_eq_zero fun xc _ => ?_
  unfold term3
  rw [fac_stay hS M xa xb xc (Nat.two_pow_pos n) hb hc h, hat_zero]
  simp

include hS in
theorem block_zero_b {la lc : ℕ} (ha : la < 2 ^ n) (hc : lc < 2 ^ n) (h : ¬ go3 n la lc) :
    block3 n k (reset3 n S M) la 0 lc = 0 := by
  unfold block3
  refine sum_eq_zero fun xa _ => sum_eq_zero fun xb _ => sum_eq_zero fun xc _ => ?_
  unfold term3
  rw [fac_stay hS M xb xa xc (Nat.two_pow_pos n) ha hc h, hat_zero]
  simp

include hS in
theorem block_zero_c {la lb : ℕ} (ha : la < 2 ^ n) (hb : lb < 2 ^ n) (h : ¬ go3 n la lb) :
    block3 n k (reset3 n S M) la lb 0 = 0 := by
  unfold block3
  refine sum_eq_zero fun xa _ => sum_eq_zero fun xb _ => sum_eq_zero fun xc _ => ?_
  unfold term3
  rw [fac_stay hS M xc xa xb (Nat.two_pow_pos n) ha hb h, hat_zero]
  simp

include hS hM in
/-- Two stacks all black below and a mixed one: the player with the mixed
stack goes up alone. -/
theorem block_one_a {la : ℕ} (h0 : 0 < la) (h1 : la < 2 ^ n - 1) :
    block3 n k (reset3 n S M) la (2 ^ n - 1) (2 ^ n - 1) = 2 ^ k * 2 ^ k * 2 ^ (k - 1) := by
  have hB : 2 ^ n - 1 < 2 ^ n := Nat.sub_lt (Nat.two_pow_pos n) one_pos
  have ha : la < 2 ^ n := by omega
  have r := hS la (2 ^ n - 1) ha hB
  have g1 : go3 n (2 ^ n - 1) (2 ^ n - 1) := by unfold go3; omega
  have g2 : ¬ go3 n la (2 ^ n - 1) := by unfold go3; omega
  have term : ∀ xa ∈ range (2 ^ k), ∀ xb ∈ range (2 ^ k), ∀ xc ∈ range (2 ^ k),
      term3 (reset3 n S M) (2 ^ n * xa + la) (2 ^ n * xb + (2 ^ n - 1))
        (2 ^ n * xc + (2 ^ n - 1)) = hat xa (M xb xc) := by
    intro xa _ xb hxb xc hxc
    unfold term3
    rw [fac_up hM S ha hB hB (mem_range.mp hxb) (mem_range.mp hxc) g1,
      fac_stay hS M xb xa xc hB ha hB g2, fac_stay hS M xc xa xb hB ha hB g2,
      hat_ones r.1 r.2]
    simp
  unfold block3
  rw [sum_congr rfl fun xa hxa => sum_congr rfl fun xb hxb => sum_congr rfl fun xc hxc =>
    term xa hxa xb hxb xc hxc]
  rw [sum_comm, sum_congr rfl fun xb _ => sum_comm]
  rw [sum_congr rfl fun xb hxb => sum_congr rfl fun xc hxc =>
    sum_hat (hM xb xc (mem_range.mp hxb) (mem_range.mp hxc)).1
      (hM xb xc (mem_range.mp hxb) (mem_range.mp hxc)).2]
  simp only [sum_const, card_range, smul_eq_mul]
  ring

include hS hM in
theorem block_one_b {lb : ℕ} (h0 : 0 < lb) (h1 : lb < 2 ^ n - 1) :
    block3 n k (reset3 n S M) (2 ^ n - 1) lb (2 ^ n - 1) = 2 ^ k * 2 ^ k * 2 ^ (k - 1) := by
  have hB : 2 ^ n - 1 < 2 ^ n := Nat.sub_lt (Nat.two_pow_pos n) one_pos
  have hb : lb < 2 ^ n := by omega
  have r := hS lb (2 ^ n - 1) hb hB
  have r' := hS (2 ^ n - 1) lb hB hb
  have g1 : go3 n (2 ^ n - 1) (2 ^ n - 1) := by unfold go3; omega
  have g2 : ¬ go3 n lb (2 ^ n - 1) := by unfold go3; omega
  have g3 : ¬ go3 n (2 ^ n - 1) lb := by unfold go3; omega
  have term : ∀ xa ∈ range (2 ^ k), ∀ xb ∈ range (2 ^ k), ∀ xc ∈ range (2 ^ k),
      term3 (reset3 n S M) (2 ^ n * xa + (2 ^ n - 1)) (2 ^ n * xb + lb)
        (2 ^ n * xc + (2 ^ n - 1)) = hat xb (M xa xc) := by
    intro xa hxa xb _ xc hxc
    unfold term3
    rw [fac_stay hS M xa xb xc hB hb hB g2,
      fac_up hM S hb hB hB (mem_range.mp hxa) (mem_range.mp hxc) g1,
      fac_stay hS M xc xa xb hB hB hb g3, hat_ones r.1 r.2, hat_ones r'.1 r'.2]
    simp
  unfold block3
  rw [sum_congr rfl fun xa hxa => sum_congr rfl fun xb hxb => sum_congr rfl fun xc hxc =>
    term xa hxa xb hxb xc hxc]
  rw [sum_congr rfl fun xa _ => sum_comm]
  rw [sum_congr rfl fun xa hxa => sum_congr rfl fun xc hxc =>
    sum_hat (hM xa xc (mem_range.mp hxa) (mem_range.mp hxc)).1
      (hM xa xc (mem_range.mp hxa) (mem_range.mp hxc)).2]
  simp only [sum_const, card_range, smul_eq_mul]
  ring

include hS hM in
theorem block_one_c {lc : ℕ} (h0 : 0 < lc) (h1 : lc < 2 ^ n - 1) :
    block3 n k (reset3 n S M) (2 ^ n - 1) (2 ^ n - 1) lc = 2 ^ k * 2 ^ k * 2 ^ (k - 1) := by
  have hB : 2 ^ n - 1 < 2 ^ n := Nat.sub_lt (Nat.two_pow_pos n) one_pos
  have hc : lc < 2 ^ n := by omega
  have r' := hS (2 ^ n - 1) lc hB hc
  have g1 : go3 n (2 ^ n - 1) (2 ^ n - 1) := by unfold go3; omega
  have g3 : ¬ go3 n (2 ^ n - 1) lc := by unfold go3; omega
  have term : ∀ xa ∈ range (2 ^ k), ∀ xb ∈ range (2 ^ k), ∀ xc ∈ range (2 ^ k),
      term3 (reset3 n S M) (2 ^ n * xa + (2 ^ n - 1)) (2 ^ n * xb + (2 ^ n - 1))
        (2 ^ n * xc + lc) = hat xc (M xa xb) := by
    intro xa hxa xb hxb xc _
    unfold term3
    rw [fac_stay hS M xa xb xc hB hB hc g3, fac_stay hS M xb xa xc hB hB hc g3,
      fac_up hM S hc hB hB (mem_range.mp hxa) (mem_range.mp hxb) g1, hat_ones r'.1 r'.2]
    simp
  unfold block3
  rw [sum_congr rfl fun xa hxa => sum_congr rfl fun xb hxb => sum_congr rfl fun xc hxc =>
    term xa hxa xb hxb xc hxc]
  rw [sum_congr rfl fun xa hxa => sum_congr rfl fun xb hxb =>
    sum_hat (hM xa xb (mem_range.mp hxa) (mem_range.mp hxb)).1
      (hM xa xb (mem_range.mp hxa) (mem_range.mp hxb)).2]
  simp only [sum_const, card_range, smul_eq_mul]
  ring

/-! ### The table `S` alone, on the same triples -/

theorem term3_zero_a (S : ℕ → ℕ → ℤ) (b c : ℕ) : term3 S 0 b c = 0 := by
  simp [term3, hat_zero]

theorem term3_zero_b (S : ℕ → ℕ → ℤ) (a c : ℕ) : term3 S a 0 c = 0 := by
  simp [term3, hat_zero]

theorem term3_zero_c (S : ℕ → ℕ → ℤ) (a b : ℕ) : term3 S a b 0 = 0 := by
  simp [term3, hat_zero]

include hS in
theorem term3_black_a {la : ℕ} (ha : la < 2 ^ n) :
    term3 S la (2 ^ n - 1) (2 ^ n - 1) = hat la (S (2 ^ n - 1) (2 ^ n - 1)) := by
  have hB : 2 ^ n - 1 < 2 ^ n := Nat.sub_lt (Nat.two_pow_pos n) one_pos
  have r := hS la (2 ^ n - 1) ha hB
  simp [term3, hat_ones r.1 r.2]

include hS in
theorem term3_black_b {lb : ℕ} (hb : lb < 2 ^ n) :
    term3 S (2 ^ n - 1) lb (2 ^ n - 1) = hat lb (S (2 ^ n - 1) (2 ^ n - 1)) := by
  have hB : 2 ^ n - 1 < 2 ^ n := Nat.sub_lt (Nat.two_pow_pos n) one_pos
  have r := hS lb (2 ^ n - 1) hb hB
  have r' := hS (2 ^ n - 1) lb hB hb
  simp [term3, hat_ones r.1 r.2, hat_ones r'.1 r'.2]

include hS in
theorem term3_black_c {lc : ℕ} (hc : lc < 2 ^ n) :
    term3 S (2 ^ n - 1) (2 ^ n - 1) lc = hat lc (S (2 ^ n - 1) (2 ^ n - 1)) := by
  have hB : 2 ^ n - 1 < 2 ^ n := Nat.sub_lt (Nat.two_pow_pos n) one_pos
  have r' := hS (2 ^ n - 1) lc hB hc
  simp [term3, hat_ones r'.1 r'.2]

/-- What one player who goes up alone wins, against what is won without
the hats above. -/
theorem alone_eq (hn : 1 ≤ n) (hk : 1 ≤ k) :
    (2 ^ n - 1 - 1) * (2 ^ k * 2 ^ k * 2 ^ (k - 1)) = 8 ^ k * (2 ^ (n - 1) - 1) := by
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  obtain ⟨i, rfl⟩ : ∃ i, n = i + 1 := ⟨n - 1, by omega⟩
  obtain ⟨a, ha⟩ : ∃ a, 2 ^ i = a + 1 := ⟨2 ^ i - 1, by have := Nat.two_pow_pos i; omega⟩
  simp only [Nat.add_sub_cancel, pow_succ, ha, eight_pow]
  have e1 : (a + 1) * 2 - 1 - 1 = 2 * a := by omega
  rw [e1]
  ring

/-! ### Row by row -/

include hS hM in
/-- The first player's lowest hats are all white. -/
theorem row_white :
    ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), block3 n k (reset3 n S M) 0 lb lc
      = 2 * 2 ^ n * wins3 k M := by
  have hn := hS.pos
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have h0 : 0 < 2 ^ n := by omega
  have hB : 2 ^ n - 1 < 2 ^ n := by omega
  rw [sum_ends2 hP]
  have c1 := block_all (S := S) hM h0 h0 h0 (by unfold go3; omega) (by unfold go3; omega)
    (by unfold go3; omega)
  have c2 := block_all (S := S) hM h0 h0 hB (by unfold go3; omega) (by unfold go3; omega)
    (by unfold go3; omega)
  have c3 := block_all (S := S) hM h0 hB h0 (by unfold go3; omega) (by unfold go3; omega)
    (by unfold go3; omega)
  have c4 := block_all (S := S) hM h0 hB hB (by unfold go3; omega) (by unfold go3; omega)
    (by unfold go3; omega)
  have s1 : ∀ u ∈ Ico 1 (2 ^ n - 1), block3 n k (reset3 n S M) 0 0 u
      + block3 n k (reset3 n S M) 0 (2 ^ n - 1) u = wins3 k M := by
    intro u hu
    have h := mem_Ico.mp hu
    rw [block_all (S := S) hM h0 h0 (by omega) (by unfold go3; omega) (by unfold go3; omega)
      (by unfold go3; omega),
      block_zero_a hS hB (by omega) (by unfold go3; omega)]
    rfl
  have s2 : ∀ t ∈ Ico 1 (2 ^ n - 1), block3 n k (reset3 n S M) 0 t 0
      + block3 n k (reset3 n S M) 0 t (2 ^ n - 1) = wins3 k M := by
    intro t ht
    have h := mem_Ico.mp ht
    rw [block_all (S := S) hM h0 (by omega) h0 (by unfold go3; omega) (by unfold go3; omega)
      (by unfold go3; omega),
      block_zero_a hS (by omega) hB (by unfold go3; omega)]
    rfl
  have s3 : ∀ t ∈ Ico 1 (2 ^ n - 1), ∀ u ∈ Ico 1 (2 ^ n - 1),
      block3 n k (reset3 n S M) 0 t u = 0 := by
    intro t ht u hu
    have h := mem_Ico.mp ht
    have h' := mem_Ico.mp hu
    exact block_zero_a hS (by omega) (by omega) (by unfold go3; omega)
  rw [c1, c2, c3, c4, sum_congr rfl s1, sum_congr rfl s2,
    sum_congr rfl fun t ht => sum_congr rfl fun u hu => s3 t ht u hu]
  simp only [sum_const, Nat.card_Ico, smul_eq_mul, mul_zero, add_zero]
  obtain ⟨Q, hQ⟩ : ∃ Q, 2 ^ n = Q + 2 := ⟨2 ^ n - 2, by omega⟩
  rw [hQ]
  have e : Q + 2 - 1 - 1 = Q := by omega
  rw [e]
  ring

include hS hM in
/-- The first player's lowest hats are all black. -/
theorem row_black :
    ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n),
        block3 n k (reset3 n S M) (2 ^ n - 1) lb lc + 8 ^ k
      = 4 * wins3 k M
        + 8 ^ k * ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), term3 S (2 ^ n - 1) lb lc := by
  have hn := hS.pos
  have hk := hM.pos
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have h0 : 0 < 2 ^ n := by omega
  have hB : 2 ^ n - 1 < 2 ^ n := by omega
  have rB := hS _ _ hB hB
  rw [sum_ends2 hP, sum_ends2 hP]
  have c1 := block_all (S := S) hM hB h0 h0 (by unfold go3; omega) (by unfold go3; omega)
    (by unfold go3; omega)
  have c2 := block_all (S := S) hM hB h0 hB (by unfold go3; omega) (by unfold go3; omega)
    (by unfold go3; omega)
  have c3 := block_all (S := S) hM hB hB h0 (by unfold go3; omega) (by unfold go3; omega)
    (by unfold go3; omega)
  have c4 := block_all (S := S) hM hB hB hB (by unfold go3; omega) (by unfold go3; omega)
    (by unfold go3; omega)
  have s1 : ∀ u ∈ Ico 1 (2 ^ n - 1), block3 n k (reset3 n S M) (2 ^ n - 1) 0 u
      + block3 n k (reset3 n S M) (2 ^ n - 1) (2 ^ n - 1) u = 2 ^ k * 2 ^ k * 2 ^ (k - 1) := by
    intro u hu
    have h := mem_Ico.mp hu
    rw [block_zero_b hS hB (by omega) (by unfold go3; omega), block_one_c hS hM h.1 h.2,
      zero_add]
  have s2 : ∀ t ∈ Ico 1 (2 ^ n - 1), block3 n k (reset3 n S M) (2 ^ n - 1) t 0
      + block3 n k (reset3 n S M) (2 ^ n - 1) t (2 ^ n - 1) = 2 ^ k * 2 ^ k * 2 ^ (k - 1) := by
    intro t ht
    have h := mem_Ico.mp ht
    rw [block_zero_c hS hB (by omega) (by unfold go3; omega), block_one_b hS hM h.1 h.2,
      zero_add]
  have s3 : ∀ t ∈ Ico 1 (2 ^ n - 1), ∀ u ∈ Ico 1 (2 ^ n - 1),
      block3 n k (reset3 n S M) (2 ^ n - 1) t u = 8 ^ k * term3 S (2 ^ n - 1) t u := by
    intro t ht u hu
    have h := mem_Ico.mp ht
    have h' := mem_Ico.mp hu
    exact block_none hS hB (by omega) (by omega) (by unfold go3; omega) (by unfold go3; omega)
      (by unfold go3; omega)
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
  rw [c1, c2, c3, c4, sum_congr rfl s1, sum_congr rfl s2,
    sum_congr rfl fun t ht => sum_congr rfl fun u hu => s3 t ht u hu,
    sum_congr rfl t1, sum_congr rfl t2, hmid, term3_zero_b, term3_zero_b, term3_zero_c, tBBB]
  simp only [sum_const, Nat.card_Ico, smul_eq_mul, ← mul_sum]
  have e := alone_eq hn hk
  generalize 2 ^ k * 2 ^ k * 2 ^ (k - 1) = H at *
  generalize ∑ t ∈ Ico 1 (2 ^ n - 1), ∑ u ∈ Ico 1 (2 ^ n - 1), term3 S (2 ^ n - 1) t u = X
  generalize 2 ^ (n - 1) - 1 = Hn at *
  generalize 2 ^ n - 1 - 1 = c at *
  generalize 8 ^ k = E at *
  generalize wins3 k M = W
  nlinarith [e]

include hS hM in
/-- The first player's lowest hats are mixed. -/
theorem row_mixed {la : ℕ} (h0 : 0 < la) (h1 : la < 2 ^ n - 1) :
    ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), block3 n k (reset3 n S M) la lb lc
        + 8 ^ k * hat la (S (2 ^ n - 1) (2 ^ n - 1))
      = wins3 k M + 2 ^ k * 2 ^ k * 2 ^ (k - 1)
        + 8 ^ k * ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), term3 S la lb lc := by
  have hn := hS.pos
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have hz : 0 < 2 ^ n := by omega
  have hB : 2 ^ n - 1 < 2 ^ n := by omega
  have ha : la < 2 ^ n := by omega
  rw [sum_ends2 hP, sum_ends2 hP]
  have c1 := block_all (S := S) hM ha hz hz (by unfold go3; omega) (by unfold go3; omega)
    (by unfold go3; omega)
  have c2 : block3 n k (reset3 n S M) la 0 (2 ^ n - 1) = 0 :=
    block_zero_b hS ha hB (by unfold go3; omega)
  have c3 : block3 n k (reset3 n S M) la (2 ^ n - 1) 0 = 0 :=
    block_zero_c hS ha hB (by unfold go3; omega)
  have c4 := block_one_a hS hM h0 h1
  have s1 : ∀ u ∈ Ico 1 (2 ^ n - 1), block3 n k (reset3 n S M) la 0 u
      + block3 n k (reset3 n S M) la (2 ^ n - 1) u
        = 8 ^ k * (term3 S la 0 u + term3 S la (2 ^ n - 1) u) := by
    intro u hu
    have h := mem_Ico.mp hu
    rw [block_zero_b hS ha (by omega) (by unfold go3; omega),
      block_none hS ha hB (by omega) (by unfold go3; omega) (by unfold go3; omega)
        (by unfold go3; omega), term3_zero_b, zero_add, zero_add]
  have s2 : ∀ t ∈ Ico 1 (2 ^ n - 1), block3 n k (reset3 n S M) la t 0
      + block3 n k (reset3 n S M) la t (2 ^ n - 1)
        = 8 ^ k * (term3 S la t 0 + term3 S la t (2 ^ n - 1)) := by
    intro t ht
    have h := mem_Ico.mp ht
    rw [block_zero_c hS ha (by omega) (by unfold go3; omega),
      block_none hS ha (by omega) hB (by unfold go3; omega) (by unfold go3; omega)
        (by unfold go3; omega), term3_zero_c, zero_add, zero_add]
  have s3 : ∀ t ∈ Ico 1 (2 ^ n - 1), ∀ u ∈ Ico 1 (2 ^ n - 1),
      block3 n k (reset3 n S M) la t u = 8 ^ k * term3 S la t u := by
    intro t ht u hu
    have h := mem_Ico.mp ht
    have h' := mem_Ico.mp hu
    exact block_none hS ha (by omega) (by omega) (by unfold go3; omega) (by unfold go3; omega)
      (by unfold go3; omega)
  rw [c1, c2, c3, c4, sum_congr rfl s1, sum_congr rfl s2,
    sum_congr rfl fun t ht => sum_congr rfl fun u hu => s3 t ht u hu,
    term3_zero_b, term3_zero_b, term3_zero_c, term3_black_a hS ha]
  simp only [← mul_sum]
  ring

include hS hM in
/-- **Wins of a reset, three players.**  If `S` is a proper table on `n`
hats and `M` a proper table on `k` hats, the reset of `S` by `M` has
`8 ^ k * (wins3 S - 1) + (3 * 2 ^ n + 2) * wins3 M` wins. -/
theorem wins3_reset :
    wins3 (n + k) (reset3 n S M) + 8 ^ k
      = 8 ^ k * wins3 n S + (3 * 2 ^ n + 2) * wins3 k M := by
  have hn := hS.pos
  have hk := hM.pos
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have hB : 2 ^ n - 1 < 2 ^ n := by omega
  have rB := hS _ _ hB hB
  have hmid := sum_mid_hat hn rB.1 rB.2
  have e := alone_eq hn hk
  have r0 := row_white hS hM
  have r1 := row_black hS hM
  have r2 : ∑ la ∈ Ico 1 (2 ^ n - 1),
      ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), block3 n k (reset3 n S M) la lb lc
        + 8 ^ k * (2 ^ (n - 1) - 1)
      = (2 ^ n - 1 - 1) * (wins3 k M + 2 ^ k * 2 ^ k * 2 ^ (k - 1))
        + 8 ^ k * ∑ la ∈ Ico 1 (2 ^ n - 1),
          ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), term3 S la lb lc := by
    have := sum_congr rfl fun la (hla : la ∈ Ico 1 (2 ^ n - 1)) =>
      row_mixed hS hM (mem_Ico.mp hla).1 (mem_Ico.mp hla).2
    rw [sum_add_distrib, sum_add_distrib, ← mul_sum, hmid, ← mul_sum] at this
    simpa [sum_const, Nat.card_Ico] using this
  have z : ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), term3 S 0 lb lc = 0 :=
    sum_eq_zero fun lb _ => sum_eq_zero fun lc _ => term3_zero_a S lb lc
  have eS : wins3 n S = ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), term3 S (2 ^ n - 1) lb lc
      + ∑ la ∈ Ico 1 (2 ^ n - 1), ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), term3 S la lb lc := by
    unfold wins3
    rw [sum_ends hP, z, zero_add]
  rw [wins3_split, sum_ends hP, r0, eS]
  generalize ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n),
    block3 n k (reset3 n S M) (2 ^ n - 1) lb lc = RB at *
  generalize ∑ la ∈ Ico 1 (2 ^ n - 1), ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n),
    block3 n k (reset3 n S M) la lb lc = RM at *
  generalize ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n), term3 S (2 ^ n - 1) lb lc = SB at *
  generalize ∑ la ∈ Ico 1 (2 ^ n - 1), ∑ lb ∈ range (2 ^ n), ∑ lc ∈ range (2 ^ n),
    term3 S la lb lc = SM at *
  generalize 2 ^ k * 2 ^ k * 2 ^ (k - 1) = H at *
  generalize 2 ^ (n - 1) - 1 = Hn at *
  generalize 8 ^ k = E at *
  generalize wins3 k M = W at *
  have hc : 2 ^ n = 2 ^ n - 1 - 1 + 2 := by omega
  generalize 2 ^ n - 1 - 1 = c at *
  rw [hc]
  nlinarith [e, r1, r2]

end

/-- On one hat, the only proper table wins for one triple out of eight. -/
example : wins3 1 (fun _ _ => 0) = 1 := by decide

end Hats
