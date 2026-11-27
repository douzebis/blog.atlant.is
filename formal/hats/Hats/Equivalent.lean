-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Crush
import Hats.Dual

/-!
# Equivalent strategies, and the operations

Two strategies are *equivalent* when one is the other with the positions
renamed.  Every renaming is a chain of exchanges of two positions, so this
file works with one exchange, `swapStrat` (`Hats/Crush.lean`).

* The resets and the shifts respect the exchanges: exchanging two
  positions of a part of a reset or of a shift gives the reset or the
  shift with the same two positions exchanged (`lr_swap_low`,
  `lr_swap_high`, the same for `rr` and `dr`, `ls_swap`, `rs_swap`,
  `ds_swap`).  This is Proposition 7 of the article.
* The second double shift, `sibling`, is the double shift with its two new
  positions exchanged (`sibling_eq_swap`).
-/

namespace Hats

/-! ### Exchanging two positions, and the lowest hats of a stack -/

theorem swapBits_zero (i j : ℕ) : swapBits i j 0 = 0 := by
  simp [swapBits]

theorem swapBits_eq_zero {i j : ℕ} (hij : i ≠ j) {t : ℕ} : swapBits i j t = 0 ↔ t = 0 := by
  constructor
  · intro h
    have := swapBits_swapBits hij t
    rw [h, swapBits_zero] at this
    exact this.symm
  · rintro rfl
    exact swapBits_zero i j

/-- The all-black stack of `m` hats stays as it is. -/
theorem swapBits_ones {i j m : ℕ} (hi : i < m) (hj : j < m) :
    swapBits i j (2 ^ m - 1) = 2 ^ m - 1 := by
  simp [swapBits, Nat.testBit_two_pow_sub_one, hi, hj]

theorem swapBits_eq_ones {i j m : ℕ} (hi : i < m) (hj : j < m) (hij : i ≠ j) {t : ℕ} :
    swapBits i j t = 2 ^ m - 1 ↔ t = 2 ^ m - 1 := by
  constructor
  · intro h
    have := swapBits_swapBits hij t
    rw [h, swapBits_ones hi hj] at this
    exact this.symm
  · rintro rfl
    exact swapBits_ones hi hj

/-- Exchanging two of the `m` lowest positions: the `m` lowest hats are
exchanged. -/
theorem swapBits_mod_low {i j m : ℕ} (hi : i < m) (hj : j < m) (hij : i ≠ j) (t : ℕ) :
    swapBits i j t % 2 ^ m = swapBits i j (t % 2 ^ m) := by
  apply Nat.eq_of_testBit_eq
  intro p
  rw [Nat.testBit_mod_two_pow, testBit_swapBits hij, testBit_swapBits hij,
    Nat.testBit_mod_two_pow]
  by_cases h1 : p = i
  · subst h1; simp [hi, hj]
  by_cases h2 : p = j
  · subst h2; simp [hi, hj]
  rw [Equiv.swap_apply_of_ne_of_ne h1 h2]

/-- Exchanging two of the `m` lowest positions: the hats above stay. -/
theorem swapBits_div_low {i j m : ℕ} (hi : i < m) (hj : j < m) (hij : i ≠ j) (t : ℕ) :
    swapBits i j t / 2 ^ m = t / 2 ^ m := by
  apply Nat.eq_of_testBit_eq
  intro p
  rw [Nat.testBit_div_two_pow, Nat.testBit_div_two_pow, testBit_swapBits hij,
    Equiv.swap_apply_of_ne_of_ne (by omega) (by omega)]

/-- Exchanging two positions above the `m` lowest: the `m` lowest hats
stay. -/
theorem swapBits_mod_high {i j : ℕ} (m : ℕ) (hij : i ≠ j) (t : ℕ) :
    swapBits (m + i) (m + j) t % 2 ^ m = t % 2 ^ m := by
  have hne : m + i ≠ m + j := by omega
  apply Nat.eq_of_testBit_eq
  intro p
  rw [Nat.testBit_mod_two_pow, Nat.testBit_mod_two_pow, testBit_swapBits hne]
  by_cases hp : p < m
  · rw [Equiv.swap_apply_of_ne_of_ne (by omega) (by omega)]
  · simp [hp]

/-- Exchanging two positions above the `m` lowest: the hats above are
exchanged. -/
theorem swapBits_div_high {i j : ℕ} (m : ℕ) (hij : i ≠ j) (t : ℕ) :
    swapBits (m + i) (m + j) t / 2 ^ m = swapBits i j (t / 2 ^ m) := by
  have hne : m + i ≠ m + j := by omega
  apply Nat.eq_of_testBit_eq
  intro p
  rw [Nat.testBit_div_two_pow, testBit_swapBits hne, testBit_swapBits hij,
    Nat.testBit_div_two_pow]
  by_cases h1 : p = i
  · subst h1; simp [Nat.add_comm]
  by_cases h2 : p = j
  · subst h2; simp [Nat.add_comm]
  rw [Equiv.swap_apply_of_ne_of_ne h1 h2,
    Equiv.swap_apply_of_ne_of_ne (by omega) (by omega)]

/-- The exchange of two positions, on a position counted from `m`. -/
theorem swap_add (m i j : ℕ) (x : ℤ) :
    Equiv.swap ((m + i : ℕ) : ℤ) ((m + j : ℕ) : ℤ) (m + x)
      = m + Equiv.swap (i : ℤ) (j : ℤ) x := by
  by_cases h1 : x = i
  · subst h1; simp
  by_cases h2 : x = j
  · subst h2; simp
  rw [Equiv.swap_apply_of_ne_of_ne h1 h2,
    Equiv.swap_apply_of_ne_of_ne (by push_cast; omega) (by push_cast; omega)]

/-- A stack that an exchange leaves in place is only reached from itself. -/
theorem swapBits_eq_iff {i j : ℕ} (hij : i ≠ j) {c : ℕ} (hc : swapBits i j c = c) {t : ℕ} :
    swapBits i j t = c ↔ t = c := by
  constructor
  · intro h
    have := swapBits_swapBits hij t
    rw [h, hc] at this
    exact this.symm
  · rintro rfl
    exact hc

/-- A stack with no hat at positions `i` and `j` below position `n`: a
multiple of `2 ^ n`. -/
theorem swapBits_two_pow_mul {i j n : ℕ} (hi : i < n) (hj : j < n) (c : ℕ) :
    swapBits i j (2 ^ n * c) = 2 ^ n * c := by
  have h1 : (2 ^ n * c).testBit i = false := by
    rw [Nat.testBit_two_pow_mul]; simp [hi]
  have h2 : (2 ^ n * c).testBit j = false := by
    rw [Nat.testBit_two_pow_mul]; simp [hj]
  simp [swapBits, h1, h2]

/-! ### The resets respect the exchanges -/

section
variable {m n i j : ℕ} {a b : ℕ → ℤ} {t : ℕ}

private theorem div_lt_of_lt (ht : t < 2 ^ (m + n)) : t / 2 ^ m < 2 ^ n := by
  rw [Nat.div_lt_iff_lt_mul (Nat.two_pow_pos m), mul_comm, ← pow_add]
  exact ht

/-- Exchanging two positions of the lower strategy of a white reset. -/
theorem lr_swap_low (hi : i < m) (hj : j < m) (hij : i ≠ j) (a : ℕ → ℤ) (hb : Proper n b)
    (ht : t < 2 ^ (m + n)) :
    lr m (swapStrat i j a) b t = swapStrat i j (lr m a b) t := by
  have hbq := hb _ (div_lt_of_lt ht)
  unfold lr swapStrat
  simp only
  rw [swapBits_mod_low hi hj hij, swapBits_div_low hi hj hij]
  simp only [swapBits_eq_zero hij]
  split_ifs
  · rw [Equiv.swap_apply_of_ne_of_ne (by omega) (by omega)]
  · rfl

/-- Exchanging two positions of the upper strategy of a white reset. -/
theorem lr_swap_high (hij : i ≠ j) (ha : Proper m a) (b : ℕ → ℤ) (t : ℕ) :
    lr m a (swapStrat i j b) t = swapStrat (m + i) (m + j) (lr m a b) t := by
  have har := ha _ (Nat.mod_lt t (Nat.two_pow_pos m))
  unfold lr swapStrat
  simp only
  rw [swapBits_mod_high m hij, swapBits_div_high m hij]
  split_ifs
  · exact (swap_add m i j _).symm
  · rw [Equiv.swap_apply_of_ne_of_ne (by push_cast; omega) (by push_cast; omega)]

/-- Exchanging two positions of the lower strategy of a black reset. -/
theorem rr_swap_low (hi : i < m) (hj : j < m) (hij : i ≠ j) (a : ℕ → ℤ) (hb : Proper n b)
    (ht : t < 2 ^ (m + n)) :
    rr m (swapStrat i j a) b t = swapStrat i j (rr m a b) t := by
  have hbq := hb _ (div_lt_of_lt ht)
  unfold rr swapStrat
  simp only
  rw [swapBits_mod_low hi hj hij, swapBits_div_low hi hj hij]
  simp only [swapBits_eq_ones hi hj hij]
  split_ifs
  · rw [Equiv.swap_apply_of_ne_of_ne (by omega) (by omega)]
  · rfl

/-- Exchanging two positions of the upper strategy of a black reset. -/
theorem rr_swap_high (hij : i ≠ j) (ha : Proper m a) (b : ℕ → ℤ) (t : ℕ) :
    rr m a (swapStrat i j b) t = swapStrat (m + i) (m + j) (rr m a b) t := by
  have har := ha _ (Nat.mod_lt t (Nat.two_pow_pos m))
  unfold rr swapStrat
  simp only
  rw [swapBits_mod_high m hij, swapBits_div_high m hij]
  split_ifs
  · exact (swap_add m i j _).symm
  · rw [Equiv.swap_apply_of_ne_of_ne (by push_cast; omega) (by push_cast; omega)]

/-- Exchanging two positions of the lower strategy of a double reset. -/
theorem dr_swap_low (hi : i < m) (hj : j < m) (hij : i ≠ j) (a : ℕ → ℤ) (hb : Proper n b)
    (ht : t < 2 ^ (m + n)) :
    dr m (swapStrat i j a) b t = swapStrat i j (dr m a b) t := by
  have hbq := hb _ (div_lt_of_lt ht)
  unfold dr swapStrat
  simp only
  rw [swapBits_mod_low hi hj hij, swapBits_div_low hi hj hij]
  simp only [swapBits_eq_zero hij, swapBits_eq_ones hi hj hij]
  split_ifs
  · rw [Equiv.swap_apply_of_ne_of_ne (by omega) (by omega)]
  · rfl

/-- Exchanging two positions of the upper strategy of a double reset. -/
theorem dr_swap_high (hij : i ≠ j) (ha : Proper m a) (b : ℕ → ℤ) (t : ℕ) :
    dr m a (swapStrat i j b) t = swapStrat (m + i) (m + j) (dr m a b) t := by
  have har := ha _ (Nat.mod_lt t (Nat.two_pow_pos m))
  unfold dr swapStrat
  simp only
  rw [swapBits_mod_high m hij, swapBits_div_high m hij]
  split_ifs
  · exact (swap_add m i j _).symm
  · rw [Equiv.swap_apply_of_ne_of_ne (by push_cast; omega) (by push_cast; omega)]

end

/-! ### The shifts respect the exchanges -/

section
variable {n i j : ℕ}

/-- Exchanging two positions, then the white shift: the white shift, then
the exchange. -/
theorem ls_swap (hi : i < n) (hj : j < n) (hij : i ≠ j) (s : ℕ → ℤ) :
    ls n (swapStrat i j s) = swapStrat i j (ls n s) := by
  funext t
  have hfix : swapBits i j (2 ^ n) = 2 ^ n := by
    simpa using swapBits_two_pow_mul hi hj 1
  unfold ls swapStrat
  simp only
  rw [swapBits_mod_low hi hj hij]
  simp only [swapBits_eq_iff hij hfix]
  split_ifs
  · rw [Equiv.swap_apply_of_ne_of_ne (by omega) (by omega)]
  · rfl

/-- The same for the black shift. -/
theorem rs_swap (hi : i < n) (hj : j < n) (hij : i ≠ j) (s : ℕ → ℤ) :
    rs n (swapStrat i j s) = swapStrat i j (rs n s) := by
  funext t
  unfold rs swapStrat
  simp only
  rw [swapBits_mod_low hi hj hij]
  simp only [swapBits_eq_ones hi hj hij]
  split_ifs
  · rw [Equiv.swap_apply_of_ne_of_ne (by omega) (by omega)]
  · rfl

/-- The same for the double shift. -/
theorem ds_swap (hi : i < n) (hj : j < n) (hij : i ≠ j) (s : ℕ → ℤ) :
    ds n (swapStrat i j s) = swapStrat i j (ds n s) := by
  funext t
  have hfix : swapBits i j (2 ^ (n + 1) + 2 ^ n) = 2 ^ (n + 1) + 2 ^ n := by
    have h := swapBits_two_pow_mul hi hj 3
    have e : 2 ^ n * 3 = 2 ^ (n + 1) + 2 ^ n := by rw [pow_succ]; ring
    rwa [e] at h
  unfold ds
  rw [rs_swap hi hj hij, ls_swap (by omega) (by omega) hij]
  unfold swapStrat
  simp only [swapBits_eq_iff hij hfix]
  split_ifs
  · rw [Equiv.swap_apply_of_ne_of_ne (by omega) (by omega)]
  · rfl

end

/-! ### The second double shift -/

private theorem ifp {c : Prop} [Decidable c] {α : Type} (h : c) (x y : α) :
    (if c then x else y) = x := by simp [h]

private theorem ifn {c : Prop} [Decidable c] {α : Type} (h : ¬ c) (x y : α) :
    (if c then x else y) = y := by simp [h]

section
variable {n : ℕ}

/-- The `n + 1` lowest hats, then the `n` lowest hats, of a stack given by
its `n` lowest hats `r` and the two hats `b` and `a` above them. -/
private theorem mod_parts (a : ℕ) {b r : ℕ} (hb : b < 2) (hr : r < 2 ^ n) :
    (2 ^ n * (2 * a + b) + r) % 2 ^ (n + 1) = 2 ^ n * b + r ∧ (2 ^ n * b + r) % 2 ^ n = r := by
  have hQ : 2 ^ (n + 1) = 2 * 2 ^ n := by rw [pow_succ]; ring
  have e : 2 ^ n * (2 * a + b) + r = 2 ^ (n + 1) * a + (2 ^ n * b + r) := by rw [hQ]; ring
  have hle : 2 ^ n * b ≤ 2 ^ n * 1 := Nat.mul_le_mul_left _ (by omega)
  constructor
  · rw [e, Nat.mul_add_mod, Nat.mod_eq_of_lt (by omega)]
  · rw [Nat.mul_add_mod, Nat.mod_eq_of_lt hr]

/-- The double shift, by the `n` lowest hats `r` of the stack it sees and
the two hats `b` and `a` above them. -/
theorem ds_apply (hn : 1 ≤ n) (s : ℕ → ℤ) {a b r : ℕ} (ha : a < 2) (hb : b < 2)
    (hr : r < 2 ^ n) :
    ds n s (2 ^ n * (2 * a + b) + r)
      = if b = 0 ∧ r = 2 ^ n - 1 then (n : ℤ)
        else if a = 1 ∧ r = 0 then (n : ℤ) + 1 else s r := by
  have hP : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
  have hQ : 2 ^ (n + 1) = 2 * 2 ^ n := by rw [pow_succ]; ring
  obtain ⟨h1, h2⟩ := mod_parts a hb hr
  unfold ds ls rs
  simp only [h1, h2]
  simp only [hQ]
  clear h1 h2 hQ
  push_cast
  generalize 2 ^ n = P at *
  interval_cases a <;> interval_cases b <;> split_ifs <;> first | rfl | omega | simp_all

/-- The second double shift, in the same way. -/
theorem sibling_apply (hn : 1 ≤ n) (s : ℕ → ℤ) {a b r : ℕ} (ha : a < 2) (hb : b < 2)
    (hr : r < 2 ^ n) :
    sibling n s (2 ^ n * (2 * a + b) + r)
      = if b = 1 ∧ r = 0 then (n : ℤ)
        else if a = 0 ∧ r = 2 ^ n - 1 then (n : ℤ) + 1 else s r := by
  have hP : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
  have hQ : 2 ^ (n + 1) = 2 * 2 ^ n := by rw [pow_succ]; ring
  have hR : 2 ^ (n + 2) = 4 * 2 ^ n := by rw [pow_succ, hQ]; ring
  obtain ⟨h1, h2⟩ := mod_parts a hb hr
  have hlt : 2 ^ n * (2 * a + b) + r < 2 ^ (n + 2) := by
    have : 2 ^ n * (2 * a + b) ≤ 2 ^ n * 3 := Nat.mul_le_mul_left _ (by omega)
    omega
  rw [sibling_eq s hlt]
  unfold rs ls
  simp only [h1, h2]
  simp only [hQ]
  clear h1 h2 hlt hR hQ
  push_cast
  generalize 2 ^ n = P at *
  interval_cases a <;> interval_cases b <;> split_ifs <;> first | rfl | omega | simp_all

/-- **The second double shift is the first with its two new positions
exchanged.** -/
theorem sibling_eq_swap {s : ℕ → ℤ} (hs : Proper n s) {t : ℕ} (ht : t < 2 ^ (n + 2)) :
    sibling n s t = swapStrat n (n + 1) (ds n s) t := by
  have hn := hs.pos
  have hP : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
  have hpos := Nat.two_pow_pos n
  have hR : 2 ^ (n + 2) = 4 * 2 ^ n := by rw [pow_succ, pow_succ]; ring
  have hr := Nat.mod_lt t hpos
  have hu : t / 2 ^ n < 4 := by
    rw [Nat.div_lt_iff_lt_mul hpos]; omega
  -- the stack `t`: its `n` lowest hats `r`, and the hats `b` and `a` above
  obtain ⟨a, b, ha, hb, hab⟩ : ∃ a b, a < 2 ∧ b < 2 ∧ t / 2 ^ n = 2 * a + b :=
    ⟨t / 2 ^ n / 2, t / 2 ^ n % 2, by omega, by omega, by omega⟩
  have ht0 : t = 2 ^ n * (2 * a + b) + t % 2 ^ n := by
    rw [← hab]; exact (Nat.div_add_mod t (2 ^ n)).symm
  -- the same stack with the two hats exchanged
  have hsw : swapBits 0 1 (2 * a + b) = 2 * b + a := by
    interval_cases a <;> interval_cases b <;> decide
  have ht1 : swapBits n (n + 1) t = 2 ^ n * (2 * b + a) + t % 2 ^ n := by
    have hmod : swapBits n (n + 1) t % 2 ^ n = t % 2 ^ n := by
      simpa using swapBits_mod_high (i := 0) (j := 1) n (by norm_num) t
    have hdiv : swapBits n (n + 1) t / 2 ^ n = swapBits 0 1 (t / 2 ^ n) := by
      simpa using swapBits_div_high (i := 0) (j := 1) n (by norm_num) t
    have h := Nat.div_add_mod (swapBits n (n + 1) t) (2 ^ n)
    rw [hmod, hdiv, hab, hsw] at h
    exact h.symm
  have hx := hs _ hr
  unfold swapStrat
  rw [ht1, ds_apply hn s hb ha hr]
  conv_lhs => rw [ht0]
  rw [sibling_apply hn s ha hb hr]
  by_cases c1 : b = 1 ∧ t % 2 ^ n = 0
  · have c2 : ¬ (a = 0 ∧ t % 2 ^ n = 2 ^ n - 1) := by omega
    rw [ifp c1, ifn c2, ifp c1]
    have e : ((n : ℤ) + 1) = ((n + 1 : ℕ) : ℤ) := by push_cast; rfl
    rw [e, Equiv.swap_apply_right]
  · by_cases c2 : a = 0 ∧ t % 2 ^ n = 2 ^ n - 1
    · rw [ifn c1, ifp c2, ifp c2, Equiv.swap_apply_left]
      push_cast; rfl
    · rw [ifn c1, ifn c2, ifn c2, ifn c1,
        Equiv.swap_apply_of_ne_of_ne (by omega) (by push_cast; omega)]

end

end Hats
