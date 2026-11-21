-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Basic
import Rosary.Fact1

/-!
# The height of a bead (Sections 1 and 2 of the paper)

A recitation starts at bead 1 and moves up or down.  `Reach k n` says that
some recitation of `k` moves ends at bead `n`.  The height of `n` is the
least such `k`.  Nothing here presupposes the results of the paper: the
height is defined from the moves alone.
-/

namespace Rosary

/-- `Reach k n`: there is a recitation of `k` moves from bead 1 to bead `n`.
A down move is allowed from any bead except bead 1. -/
inductive Reach : Nat → Nat → Prop
  | start : Reach 0 1
  | up {k n : Nat} : Reach k n → Reach (k + 1) (up n)
  | down {k n : Nat} : Reach k n → 2 ≤ n → Reach (k + 1) (down n)

theorem Reach.pos {k n : Nat} (h : Reach k n) : 1 ≤ n := by
  induction h with
  | start => exact Nat.le_refl 1
  | up _ ih => rosary
  | down _ h2 ih => rosary

/-- How a recitation ends: it is empty, or its last move is up or down. -/
theorem Reach.inv {k n : Nat} (h : Reach k n) :
    (k = 0 ∧ n = 1) ∨
    ∃ j m, k = j + 1 ∧ Reach j m ∧ (n = Rosary.up m ∨ (2 ≤ m ∧ n = Rosary.down m)) := by
  cases h with
  | start => exact Or.inl ⟨rfl, rfl⟩
  | up h => exact Or.inr ⟨_, _, rfl, h, Or.inl rfl⟩
  | down h h2 => exact Or.inr ⟨_, _, rfl, h, Or.inr ⟨h2, rfl⟩⟩

theorem Reach.up' {k m n : Nat} (h : Reach k m) (e : Rosary.up m = n) :
    Reach (k + 1) n := e ▸ h.up

theorem Reach.down' {k m n : Nat} (h : Reach k m) (h2 : 2 ≤ m)
    (e : Rosary.down m = n) : Reach (k + 1) n := e ▸ h.down h2

/-! ## Six recitations, written out (the small cases of Proposition 1) -/

theorem reach_4 : Reach 5 4 := by
  have h := Reach.start
  have h := h.up' (n := 2) (by decide)
  have h := h.up' (n := 3) (by decide)
  have h := h.up' (n := 5) (by decide)
  have h := h.up' (n := 8) (by decide)
  have h := h.down' (n := 4) (by decide) (by decide)
  exact h

theorem reach_7 : Reach 9 7 := by
  have h := Reach.start
  have h := h.up' (n := 2) (by decide)
  have h := h.up' (n := 3) (by decide)
  have h := h.up' (n := 5) (by decide)
  have h := h.up' (n := 8) (by decide)
  have h := h.down' (n := 4) (by decide) (by decide)
  have h := h.up' (n := 6) (by decide)
  have h := h.up' (n := 9) (by decide)
  have h := h.up' (n := 14) (by decide)
  have h := h.down' (n := 7) (by decide) (by decide)
  exact h

theorem reach_10 : Reach 10 10 := by
  have h := Reach.start
  have h := h.up' (n := 2) (by decide)
  have h := h.up' (n := 3) (by decide)
  have h := h.up' (n := 5) (by decide)
  have h := h.up' (n := 8) (by decide)
  have h := h.down' (n := 4) (by decide) (by decide)
  have h := h.up' (n := 6) (by decide)
  have h := h.up' (n := 9) (by decide)
  have h := h.up' (n := 14) (by decide)
  have h := h.up' (n := 21) (by decide)
  have h := h.down' (n := 10) (by decide) (by decide)
  exact h

theorem reach_13 : Reach 13 13 := by
  have h := Reach.start
  have h := h.up' (n := 2) (by decide)
  have h := h.up' (n := 3) (by decide)
  have h := h.up' (n := 5) (by decide)
  have h := h.up' (n := 8) (by decide)
  have h := h.down' (n := 4) (by decide) (by decide)
  have h := h.up' (n := 6) (by decide)
  have h := h.up' (n := 9) (by decide)
  have h := h.up' (n := 14) (by decide)
  have h := h.down' (n := 7) (by decide) (by decide)
  have h := h.up' (n := 11) (by decide)
  have h := h.up' (n := 17) (by decide)
  have h := h.up' (n := 26) (by decide)
  have h := h.down' (n := 13) (by decide) (by decide)
  exact h

theorem reach_16 : Reach 11 16 := by
  have h := Reach.start
  have h := h.up' (n := 2) (by decide)
  have h := h.up' (n := 3) (by decide)
  have h := h.up' (n := 5) (by decide)
  have h := h.up' (n := 8) (by decide)
  have h := h.down' (n := 4) (by decide) (by decide)
  have h := h.up' (n := 6) (by decide)
  have h := h.up' (n := 9) (by decide)
  have h := h.up' (n := 14) (by decide)
  have h := h.up' (n := 21) (by decide)
  have h := h.up' (n := 32) (by decide)
  have h := h.down' (n := 16) (by decide) (by decide)
  exact h

theorem reach_19 : Reach 14 19 := by
  have h := Reach.start
  have h := h.up' (n := 2) (by decide)
  have h := h.up' (n := 3) (by decide)
  have h := h.up' (n := 5) (by decide)
  have h := h.up' (n := 8) (by decide)
  have h := h.down' (n := 4) (by decide) (by decide)
  have h := h.up' (n := 6) (by decide)
  have h := h.up' (n := 9) (by decide)
  have h := h.up' (n := 14) (by decide)
  have h := h.down' (n := 7) (by decide) (by decide)
  have h := h.up' (n := 11) (by decide)
  have h := h.up' (n := 17) (by decide)
  have h := h.up' (n := 26) (by decide)
  have h := h.up' (n := 39) (by decide)
  have h := h.down' (n := 19) (by decide) (by decide)
  exact h

/-! ## Every bead has a finite height -/

/-- Every bead `n` is reached, by a recitation of at most `(4n - 1)/3`
moves.  This is the proof of Proposition 1: a white bead is reached by one
up move from `nλ`, and a black bead by up, up, down from a bead `m < n`. -/
theorem exists_reach (n : Nat) (hn : 1 ≤ n) : ∃ k, Reach k n ∧ 3 * k + 1 ≤ 4 * n := by
  induction n using Nat.strongRecOn with
  | _ n ih =>
    by_cases h1 : n = 1
    · subst h1; exact ⟨0, Reach.start, by omega⟩
    by_cases hw : n % 3 = 1
    · -- a black bead
      by_cases h4 : n = 4
      · subst h4; exact ⟨_, reach_4, by omega⟩
      by_cases h7 : n = 7
      · subst h7; exact ⟨_, reach_7, by omega⟩
      by_cases h10 : n = 10
      · subst h10; exact ⟨_, reach_10, by omega⟩
      by_cases h13 : n = 13
      · subst h13; exact ⟨_, reach_13, by omega⟩
      by_cases h16 : n = 16
      · subst h16; exact ⟨_, reach_16, by omega⟩
      by_cases h19 : n = 19
      · subst h19; exact ⟨_, reach_19, by omega⟩
      by_cases h9 : n % 9 = 1
      · -- `n = mUUD` with `m = ⌈8n/9⌉`
        obtain ⟨k, hk, hb⟩ := ih ((8 * n + 1) / 9) (by omega) (by omega)
        refine ⟨k + 3, ((hk.up).up).down' (by rosary) (by rosary), by omega⟩
      · -- `n = mUUD` with `m = ⌊8n/9⌋`
        obtain ⟨k, hk, hb⟩ := ih (8 * n / 9) (by omega) (by omega)
        have h47 : n % 9 = 4 ∨ n % 9 = 7 := by omega
        refine ⟨k + 3, ((hk.up).up).down' (by rosary) ?_, by omega⟩
        rcases h47 with h | h <;> rosary
    · -- a white bead
      obtain ⟨k, hk, hb⟩ := ih (lam n) (by rosary) (by rosary)
      exact ⟨k + 1, hk.up' (lam_up n hn hw).2, by rosary⟩

/-- A set of natural numbers that is not empty has a least element. -/
theorem exists_least (p : Nat → Prop) (h : ∃ k, p k) :
    ∃ k, p k ∧ ∀ j, p j → k ≤ j := by
  obtain ⟨k, hk⟩ := h
  induction k using Nat.strongRecOn with
  | _ k ih =>
    by_cases hmin : ∀ j, p j → k ≤ j
    · exact ⟨k, hk, hmin⟩
    · have : ∃ j, p j ∧ j < k := Classical.byContradiction fun hno =>
        hmin fun j hj => Classical.byContradiction fun hlt => hno ⟨j, hj, by omega⟩
      obtain ⟨j, hj, hjk⟩ := this
      exact ih j hjk hj

open Classical in
/-- **Height**: `height n` is the length of a minimal recitation to `n`,
that is, the least `k` such that `Reach k n`.  (For `n = 0`, which is not a
bead, the value is 0 and means nothing.) -/
noncomputable def height (n : Nat) : Nat :=
  if h : ∃ k, Reach k n then Classical.choose (exists_least _ h) else 0

theorem height_spec (n : Nat) (hn : 1 ≤ n) :
    Reach (height n) n ∧ ∀ j, Reach j n → height n ≤ j := by
  have h : ∃ k, Reach k n := let ⟨k, hk, _⟩ := exists_reach n hn; ⟨k, hk⟩
  unfold height
  rw [dif_pos h]
  exact Classical.choose_spec (exists_least _ h)

/-- Some recitation to `n` has `height n` moves. -/
theorem reach_height (n : Nat) (hn : 1 ≤ n) : Reach (height n) n :=
  (height_spec n hn).1

/-- No recitation to `n` has fewer moves. -/
theorem height_le {k n : Nat} (h : Reach k n) : height n ≤ k :=
  (height_spec n h.pos).2 k h

/-- `h(1) = 0`. -/
theorem height_one : height 1 = 0 := Nat.le_zero.mp (height_le Reach.start)

theorem height_up_le (n : Nat) (hn : 1 ≤ n) : height (up n) ≤ height n + 1 :=
  height_le (reach_height n hn).up

theorem height_down_le (n : Nat) (hn : 2 ≤ n) : height (down n) ≤ height n + 1 :=
  height_le ((reach_height n (by omega)).down hn)

/-! ## Proposition 1 -/

/-- A linear upper bound: `h(n) ≤ (4n - 1)/3`.  The paper stated it in
Proposition 1 until November 2026; it now states the logarithmic bound only
(`height_log`, in the second project). -/
theorem height_upper (n : Nat) (hn : 1 ≤ n) : 3 * height n + 1 ≤ 4 * n := by
  obtain ⟨k, hk, hb⟩ := exists_reach n hn
  have := height_le hk
  omega

theorem reach_lower {k n : Nat} (h : Reach k n) : (n + 1) * 2 ^ k ≤ 2 * 3 ^ k := by
  induction h with
  | start => decide
  | @up k n _ ih =>
    have key : (Rosary.up n + 1) * 2 ≤ 3 * (n + 1) := by rosary
    calc (Rosary.up n + 1) * 2 ^ (k + 1)
        = ((Rosary.up n + 1) * 2) * 2 ^ k := by rw [Nat.pow_succ]; ac_rfl
      _ ≤ (3 * (n + 1)) * 2 ^ k := Nat.mul_le_mul_right _ key
      _ = 3 * ((n + 1) * 2 ^ k) := by ac_rfl
      _ ≤ 3 * (2 * 3 ^ k) := Nat.mul_le_mul_left _ ih
      _ = 2 * 3 ^ (k + 1) := by rw [Nat.pow_succ]; ac_rfl
  | @down k n _ h2 ih =>
    have key : Rosary.down n + 1 ≤ n + 1 := by rosary
    calc (Rosary.down n + 1) * 2 ^ (k + 1)
        = 2 * ((Rosary.down n + 1) * 2 ^ k) := by rw [Nat.pow_succ]; ac_rfl
      _ ≤ 2 * ((n + 1) * 2 ^ k) :=
          Nat.mul_le_mul_left _ (Nat.mul_le_mul_right _ key)
      _ ≤ 2 * (2 * 3 ^ k) := Nat.mul_le_mul_left _ ih
      _ ≤ 2 * 3 ^ (k + 1) := by rw [Nat.pow_succ]; omega

/-- **Proposition 1, lower bound**: `n + 1 ≤ 2 (3/2)^h(n)`, that is,
`log_{3/2} ((n + 1)/2) ≤ h(n)`.  Written without fractions:
`(n + 1) 2^h ≤ 2 · 3^h`. -/
theorem height_lower (n : Nat) (hn : 1 ≤ n) :
    (n + 1) * 2 ^ height n ≤ 2 * 3 ^ height n :=
  reach_lower (reach_height n hn)

end Rosary
