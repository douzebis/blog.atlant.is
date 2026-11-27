-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.DoubleShift

/-!
# Exchanging the colors

The *dual* of a strategy on `n` hats is the strategy with the two colors
exchanged: for a stack `t` it points where the strategy points for `t`
with every hat of the other color.

* A proper strategy and its dual have the same hits (`hits_dual`).
* The double shift has a sibling, its dual: where the double shift is
  built on the black shift followed by the white shift, the sibling is
  built on the white shift followed by the black shift
  (`sibling_eq`).  It has the same hits, `16 * hits s + 6`
  (`hits_sibling`).
-/

namespace Hats

open Finset

/-- The stack of `n` hats `t` with the colors exchanged. -/
def flip (n t : ℕ) : ℕ := 2 ^ n - 1 - t

/-- The dual of the strategy `s` on `n` hats. -/
def dual (n : ℕ) (s : ℕ → ℤ) : ℕ → ℤ := fun t => s (flip n t)

theorem flip_lt (n t : ℕ) : flip n t < 2 ^ n := by
  have := Nat.two_pow_pos n
  unfold flip
  omega

theorem flip_flip {n t : ℕ} (ht : t < 2 ^ n) : flip n (flip n t) = t := by
  unfold flip
  omega

/-- Exchanging the colors of a stack exchanges the color of each hat. -/
theorem hat_flip {n t : ℕ} (ht : t < 2 ^ n) {p : ℤ} (hp : 0 ≤ p) (hpn : p < n) :
    hat (flip n t) p + hat t p = 1 := by
  have hlt : p.toNat < n := by omega
  have h : (flip n t).testBit p.toNat = !t.testBit p.toNat := by
    unfold flip
    rw [Nat.sub_sub, Nat.add_comm 1 t, Nat.testBit_two_pow_sub_succ ht]
    simp [hlt]
  unfold hat
  rw [h]
  cases t.testBit p.toNat <;> simp [hp]

theorem dual_proper {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) : Proper n (dual n s) :=
  fun t _ => hs _ (flip_lt n t)

/-- The dual of the dual is the strategy itself, on stacks of `n` hats. -/
theorem dual_dual {n : ℕ} (s : ℕ → ℤ) {t : ℕ} (ht : t < 2 ^ n) :
    dual n (dual n s) t = s t := by
  unfold dual
  rw [flip_flip ht]

/-- **Exchanging the colors keeps the hits** of a proper strategy.  With
the colors exchanged, a pair of stacks wins when both players point at a
white hat; each player points at a black hat for half of the stacks that
they may wear, so there are as many such pairs as winning pairs. -/
theorem hits_dual {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) : hits n (dual n s) = hits n s := by
  have hn := hs.pos
  have reflect : ∀ G : ℕ → ℕ,
      ∑ t ∈ range (2 ^ n), G (flip n t) = ∑ t ∈ range (2 ^ n), G t :=
    fun G => sum_range_reflect G (2 ^ n)
  have h1 : hits n (dual n s) = ∑ t ∈ range (2 ^ n), ∑ u ∈ range (2 ^ n),
      hat (flip n t) (s u) * hat (flip n u) (s t) := by
    unfold hits pair dual
    rw [← reflect]
    refine sum_congr rfl fun t ht => ?_
    rw [← reflect]
    refine sum_congr rfl fun u hu => ?_
    rw [flip_flip (mem_range.mp ht), flip_flip (mem_range.mp hu)]
  have key : ∀ t ∈ range (2 ^ n), ∀ u ∈ range (2 ^ n),
      hat (flip n t) (s u) * hat (flip n u) (s t) + (hat t (s u) + hat u (s t))
        = 1 + hat t (s u) * hat u (s t) := by
    intro t ht u hu
    have a := hat_flip (mem_range.mp ht) (hs u (mem_range.mp hu)).1 (hs u (mem_range.mp hu)).2
    have b := hat_flip (mem_range.mp hu) (hs t (mem_range.mp ht)).1 (hs t (mem_range.mp ht)).2
    have e1 : hat (flip n t) (s u) = 1 - hat t (s u) := by omega
    have e2 : hat (flip n u) (s t) = 1 - hat u (s t) := by omega
    rw [e1, e2]
    rcases (by omega : hat t (s u) = 0 ∨ hat t (s u) = 1) with h | h <;>
      rcases (by omega : hat u (s t) = 0 ∨ hat u (s t) = 1) with h' | h' <;>
      simp [h, h']
  have total := sum_congr rfl fun t ht => sum_congr rfl fun u hu => key t ht u hu
  simp only [sum_add_distrib] at total
  have Sa : ∑ t ∈ range (2 ^ n), ∑ u ∈ range (2 ^ n), hat t (s u) = 2 ^ n * 2 ^ (n - 1) := by
    rw [sum_comm, sum_congr rfl fun u hu =>
      sum_hat (hs u (mem_range.mp hu)).1 (hs u (mem_range.mp hu)).2]
    simp
  have Sb : ∑ t ∈ range (2 ^ n), ∑ u ∈ range (2 ^ n), hat u (s t) = 2 ^ n * 2 ^ (n - 1) := by
    rw [sum_congr rfl fun t ht =>
      sum_hat (hs t (mem_range.mp ht)).1 (hs t (mem_range.mp ht)).2]
    simp
  have S1 : ∑ _t ∈ range (2 ^ n), ∑ _u ∈ range (2 ^ n), 1 = 2 * (2 ^ n * 2 ^ (n - 1)) := by
    obtain ⟨k, rfl⟩ : ∃ k, n = k + 1 := ⟨n - 1, by omega⟩
    simp [pow_succ]
    ring
  rw [Sa, Sb, S1] at total
  rw [h1]
  unfold hits pair
  omega

/-- **The sibling of the double shift**: the dual of the double shift of
the dual. -/
def sibling (n : ℕ) (s : ℕ → ℤ) : ℕ → ℤ := dual (n + 2) (ds n (dual n s))

theorem sibling_proper {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) : Proper (n + 2) (sibling n s) :=
  dual_proper (ds_proper (dual_proper hs))

/-- **Win rate after the sibling double shift**, as a count of hits:
`16 * hits s + 6`, as for the double shift. -/
theorem hits_sibling {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    hits (n + 2) (sibling n s) = 16 * hits n s + 6 := by
  unfold sibling
  rw [hits_dual (ds_proper (dual_proper hs)), hits_ds (dual_proper hs), hits_dual hs]

/-- The lowest hats of a stack with the colors exchanged. -/
theorem flip_mod (a b : ℕ) {t : ℕ} (ht : t < 2 ^ (a + b)) :
    flip (a + b) t % 2 ^ a = flip a (t % 2 ^ a) := by
  have hP := Nat.two_pow_pos a
  have hq : t / 2 ^ a < 2 ^ b := by
    rw [Nat.div_lt_iff_lt_mul hP, mul_comm, ← pow_add]
    exact ht
  have hr := Nat.mod_lt t hP
  have ht' := Nat.div_add_mod t (2 ^ a)
  have e : 2 ^ (a + b) - 1 - t
      = 2 ^ a * (2 ^ b - 1 - t / 2 ^ a) + (2 ^ a - 1 - t % 2 ^ a) := by
    have h1 : 2 ^ (a + b) = 2 ^ a * (2 ^ b - 1 - t / 2 ^ a) + 2 ^ a * (t / 2 ^ a) + 2 ^ a := by
      rw [pow_add, ← Nat.mul_add, ← Nat.mul_succ]
      congr 1
      omega
    omega
  unfold flip
  rw [e, Nat.mul_add_mod, Nat.mod_eq_of_lt (by omega)]

/-- **The sibling, written out**: the black shift of the white shift,
except that for the stack of `n` black hats under two white hats it
points at the top hat. -/
theorem sibling_eq {n : ℕ} (s : ℕ → ℤ) {t : ℕ} (ht : t < 2 ^ (n + 2)) :
    sibling n s t = if t = 2 ^ n - 1 then (n : ℤ) + 1 else rs (n + 1) (ls n s) t := by
  have hP := Nat.two_pow_pos n
  have hQ : 2 ^ (n + 1) = 2 * 2 ^ n := by rw [pow_succ]; ring
  have hR : 2 ^ (n + 2) = 4 * 2 ^ n := by rw [pow_succ, hQ]; ring
  have m1 := flip_mod (n + 1) 1 (t := t) ht
  have m2 := flip_mod n 1 (t := t % 2 ^ (n + 1)) (Nat.mod_lt _ (Nat.two_pow_pos _))
  have hmm : t % 2 ^ (n + 1) % 2 ^ n = t % 2 ^ n :=
    Nat.mod_mod_of_dvd t (pow_dvd_pow 2 (Nat.le_succ n))
  have hr1 := Nat.mod_lt t (Nat.two_pow_pos (n + 1))
  have hr0 := Nat.mod_lt t hP
  unfold sibling dual ds ls rs
  beta_reduce
  rw [m1, m2, hmm, flip_flip hr0]
  have hdm := Nat.div_add_mod t (2 ^ (n + 1))
  have hq : t / 2 ^ (n + 1) < 2 := by
    rw [Nat.div_lt_iff_lt_mul (Nat.two_pow_pos _)]
    omega
  push_cast
  unfold flip
  rcases Nat.le_one_iff_eq_zero_or_eq_one.mp (Nat.lt_succ_iff.mp hq) with h | h <;>
    rw [h] at hdm <;> split_ifs <;> first | rfl | omega
