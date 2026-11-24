-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Describe

/-!
# Exchanging two positions, and crushed strategies

Exchanging two positions in every stack, and in what a strategy points at,
does not change its hits.  It follows that the search for the best
strategy can be limited to *crushed* strategies: those that, seeing stack
number `t`, point at a position at most `t` (the second article, on the
calculator).
-/

namespace Hats

open Finset

/-- Stack `t` with the hats at positions `i` and `j` exchanged. -/
def swapBits (i j t : ℕ) : ℕ :=
  if t.testBit i = t.testBit j then t else t ^^^ (2 ^ i ||| 2 ^ j)

theorem testBit_swapBits {i j : ℕ} (hij : i ≠ j) (t p : ℕ) :
    (swapBits i j t).testBit p = t.testBit (Equiv.swap i j p) := by
  unfold swapBits
  by_cases h : t.testBit i = t.testBit j
  · simp only [h, ↓reduceIte]
    by_cases hi : p = i
    · subst hi; rw [Equiv.swap_apply_left, h]
    by_cases hj : p = j
    · subst hj; rw [Equiv.swap_apply_right, h]
    rw [Equiv.swap_apply_of_ne_of_ne hi hj]
  · simp only [h, ↓reduceIte]
    rw [Nat.testBit_xor, Nat.testBit_or, Nat.testBit_two_pow, Nat.testBit_two_pow]
    by_cases hi : p = i
    · subst hi
      rw [Equiv.swap_apply_left]
      have : ¬ j = p := fun e => hij e.symm
      cases h1 : t.testBit p <;> cases h2 : t.testBit j <;> simp_all
    by_cases hj : p = j
    · subst hj
      rw [Equiv.swap_apply_right]
      cases h1 : t.testBit i <;> cases h2 : t.testBit p <;> simp_all
    rw [Equiv.swap_apply_of_ne_of_ne hi hj]
    have h1 : ¬ i = p := fun e => hi e.symm
    have h2 : ¬ j = p := fun e => hj e.symm
    simp [h1, h2]

theorem swapBits_lt {n i j t : ℕ} (hi : i < n) (hj : j < n) (ht : t < 2 ^ n) :
    swapBits i j t < 2 ^ n := by
  unfold swapBits
  split_ifs
  · exact ht
  · refine Nat.xor_lt_two_pow ht (Nat.or_lt_two_pow ?_ ?_)
    · exact Nat.pow_lt_pow_right (by norm_num) hi
    · exact Nat.pow_lt_pow_right (by norm_num) hj

theorem swapBits_swapBits {i j : ℕ} (hij : i ≠ j) (t : ℕ) :
    swapBits i j (swapBits i j t) = t := by
  apply Nat.eq_of_testBit_eq
  intro p
  rw [testBit_swapBits hij, testBit_swapBits hij, Equiv.swap_apply_self]

/-- A stack below `2 ^ k` has no hat at position `k` or above: exchanging
two such positions leaves it as it is. -/
theorem swapBits_of_lt {i j t : ℕ} (hi : t < 2 ^ i) (hj : t < 2 ^ j) : swapBits i j t = t := by
  unfold swapBits
  have e : t.testBit i = t.testBit j := by
    rw [Nat.testBit_lt_two_pow hi, Nat.testBit_lt_two_pow hj]
  simp only [e, ↓reduceIte]

/-- Strategy `s` after the exchange of positions `i` and `j`. -/
def swapStrat (i j : ℕ) (s : ℕ → ℤ) : ℕ → ℤ := fun t =>
  Equiv.swap (i : ℤ) (j : ℤ) (s (swapBits i j t))

theorem hat_swap {i j : ℕ} (hij : i ≠ j) (t : ℕ) (p : ℤ) :
    hat t (Equiv.swap (i : ℤ) (j : ℤ) p) = hat (swapBits i j t) p := by
  by_cases hp : 0 ≤ p
  · obtain ⟨q, rfl⟩ := Int.eq_ofNat_of_zero_le hp
    have e : Equiv.swap (i : ℤ) (j : ℤ) (q : ℤ) = ((Equiv.swap i j q : ℕ) : ℤ) := by
      by_cases hi : q = i
      · subst hi; simp
      by_cases hj : q = j
      · subst hj; simp
      rw [Equiv.swap_apply_of_ne_of_ne hi hj,
        Equiv.swap_apply_of_ne_of_ne (by exact_mod_cast hi) (by exact_mod_cast hj)]
    rw [e]
    simp [hat, testBit_swapBits hij]
  · have e : Equiv.swap (i : ℤ) (j : ℤ) p = p :=
      Equiv.swap_apply_of_ne_of_ne (by omega) (by omega)
    rw [e]
    simp [hat, hp]

/-- **Exchanging two positions does not change the hits.** -/
theorem hits_swapStrat {n i j : ℕ} (hi : i < n) (hj : j < n) (hij : i ≠ j) (s : ℕ → ℤ) :
    hits n (swapStrat i j s) = hits n s := by
  have hpair : ∀ t u, pair (swapStrat i j s) t u = pair s (swapBits i j t) (swapBits i j u) := by
    intro t u
    simp [pair, swapStrat, hat_swap hij]
  have hmem : ∀ t ∈ range (2 ^ n), swapBits i j t ∈ range (2 ^ n) := fun t ht =>
    mem_range.mpr (swapBits_lt hi hj (mem_range.mp ht))
  unfold hits
  simp only [hpair]
  refine sum_nbij' (swapBits i j) (swapBits i j) hmem hmem
    (fun t _ => swapBits_swapBits hij t) (fun t _ => swapBits_swapBits hij t) fun t _ => ?_
  exact sum_nbij' (swapBits i j) (swapBits i j) hmem hmem
    (fun u _ => swapBits_swapBits hij u) (fun u _ => swapBits_swapBits hij u) fun u _ => rfl

theorem swapStrat_proper {n i j : ℕ} (hi : i < n) (hj : j < n) {s : ℕ → ℤ} (hs : Proper n s) :
    Proper n (swapStrat i j s) := by
  intro t ht
  have h := hs _ (swapBits_lt hi hj ht)
  unfold swapStrat
  by_cases h1 : s (swapBits i j t) = i
  · rw [h1, Equiv.swap_apply_left]; constructor <;> omega
  by_cases h2 : s (swapBits i j t) = j
  · rw [h2, Equiv.swap_apply_right]; constructor <;> omega
  rw [Equiv.swap_apply_of_ne_of_ne h1 h2]; exact h

/-- **Crushed strategies are enough**: for every proper strategy there is
a proper strategy with the same hits that, seeing stack number `t`, points
at a position at most `t`. -/
theorem exists_crushed {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    ∃ s' : ℕ → ℤ, Proper n s' ∧ hits n s' = hits n s ∧ ∀ t, t < 2 ^ n → s' t ≤ t := by
  have step : ∀ k, k ≤ n →
      ∃ s' : ℕ → ℤ, Proper n s' ∧ hits n s' = hits n s ∧ ∀ t, t < k → s' t ≤ t := by
    intro k
    induction k with
    | zero => exact fun _ => ⟨s, hs, rfl, fun t ht => absurd ht (Nat.not_lt_zero t)⟩
    | succ k ih =>
      intro hk
      obtain ⟨s', hp, hh, hle⟩ := ih (by omega)
      have hk2 : k < 2 ^ k := Nat.lt_two_pow_self
      have hkn : k < 2 ^ n := lt_of_lt_of_le hk2 (Nat.pow_le_pow_right (by norm_num) (by omega))
      by_cases hsk : s' k ≤ k
      · refine ⟨s', hp, hh, fun t ht => ?_⟩
        rcases Nat.lt_succ_iff_lt_or_eq.mp ht with h | rfl
        · exact hle t h
        · exact hsk
      · have hb := hp k hkn
        obtain ⟨j, hj⟩ := Int.eq_ofNat_of_zero_le hb.1
        have hjk : k < j := by omega
        have hjn : j < n := by omega
        refine ⟨swapStrat k j s', swapStrat_proper (by omega) hjn hp,
          (hits_swapStrat (by omega) hjn (by omega) s').trans hh, fun t ht => ?_⟩
        have hfix : ∀ u, u ≤ k → swapBits k j u = u := fun u hu =>
          swapBits_of_lt (lt_of_le_of_lt hu hk2)
            (lt_of_le_of_lt hu (lt_trans hk2 (Nat.pow_lt_pow_right (by norm_num) hjk)))
        unfold swapStrat
        rcases Nat.lt_succ_iff_lt_or_eq.mp ht with h | rfl
        · rw [hfix t (by omega)]
          have := hle t h
          have hpt := hp t (lt_trans h hkn)
          rw [Equiv.swap_apply_of_ne_of_ne (by omega) (by omega)]
          exact this
        · rw [hfix t le_rfl, hj, Equiv.swap_apply_right]
  obtain ⟨s', hp, hh, hle⟩ := step n le_rfl
  refine ⟨s', hp, hh, fun t ht => ?_⟩
  rcases Nat.lt_or_ge t n with h | h
  · exact hle t h
  · have := hp t ht
    omega

end Hats
