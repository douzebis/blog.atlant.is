-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Theorem1

/-!
# Computing the height in logarithmic time (end of Section 5)

`heightFast` is the program printed in the paper, and
`height_eq_heightFast` says that it computes the height.

As for the seed, each loop carries a counter (the "fuel") that lets Lean
see that it stops.
-/

namespace Rosary

/-- The inner loop of the program: `while n % 3 == 0: n = 2n/3; h += 1`.
The result is the pair (last value of `n`, number of turns). -/
def ladderAux : Nat → Nat → Nat × Nat
  | 0, b => (b, 0)
  | fuel + 1, b =>
    if b % 3 = 0 then ((ladderAux fuel (lam b)).1, (ladderAux fuel (lam b)).2 + 1)
    else (b, 0)

def ladder (b : Nat) : Nat × Nat := ladderAux b b

/-- The program of the paper.  From a white bead `n`: go to `nλ`, one
move.  From a black bead `n`: start from `b₁ = (4n + 2)/3`, run the inner
loop (`s` turns, ending at `x`), keep `w = x - 1` if `x` is black ("μ
wins") and `w = x` otherwise; that makes `s + 2` moves.  The bead `w` is
white, and the program printed in the paper handles it at its next turn;
here that turn is taken at once: go to `wλ`, one more move. -/
def heightFastAux : Nat → Nat → Nat
  | 0, _ => 0
  | fuel + 1, n =>
    if n ≤ 1 then 0
    else if n % 3 ≠ 1 then heightFastAux fuel (lam n) + 1
    else
      let x := (ladder ((4 * n + 2) / 3)).1
      let s := (ladder ((4 * n + 2) / 3)).2
      let w := if x % 3 = 1 then x - 1 else x
      heightFastAux fuel (lam w) + s + 3

def heightFast (n : Nat) : Nat := heightFastAux n n

/-! ## The inner loop -/

theorem ladderAux_fuel (f : Nat) :
    ∀ g b, 1 ≤ b → b ≤ f → b ≤ g → ladderAux f b = ladderAux g b := by
  induction f with
  | zero => intro g b h1 h0; omega
  | succ f ih =>
    intro g b h1 hf hg
    cases g with
    | zero => omega
    | succ g =>
      simp only [ladderAux]
      by_cases h0 : b % 3 = 0
      · rw [if_pos h0, if_pos h0, ih g (lam b) (by rosary) (by rosary) (by rosary)]
      · rw [if_neg h0, if_neg h0]

theorem ladder_stop (b : Nat) (h : b % 3 ≠ 0) : ladder b = (b, 0) := by
  cases b with
  | zero => omega
  | succ f => simp [ladder, ladderAux, h]

theorem ladder_go (b : Nat) (hb : 1 ≤ b) (h : b % 3 = 0) :
    ladder b = ((ladder (lam b)).1, (ladder (lam b)).2 + 1) := by
  cases b with
  | zero => omega
  | succ f =>
    have hfuel := ladderAux_fuel f (lam (f + 1)) (lam (f + 1))
      (by rosary) (by rosary) (Nat.le_refl _)
    simp [ladder, ladderAux, h, hfuel]

/-- What the inner loop does, started at `b`: it follows `b` and its
neighbor `b - 1` back with `λ` as long as `b` is a multiple of 3; the
beads met are white. -/
theorem ladder_spec (b : Nat) : 2 ≤ b →
    (ladder b).1 % 3 ≠ 0 ∧ 2 ≤ (ladder b).1 ∧ (ladder b).1 ≤ b ∧
    lamPow b (ladder b).2 = (ladder b).1 ∧
    lamPow (b - 1) (ladder b).2 = (ladder b).1 - 1 ∧
    ∀ i, i < (ladder b).2 → White (lamPow b i) ∧ White (lamPow (b - 1) i) := by
  induction b using Nat.strongRecOn with
  | _ b ih =>
    intro hb
    by_cases h0 : b % 3 = 0
    · rw [ladder_go b (by omega) h0]
      obtain ⟨i1, i2, i3, i4, i5, i6⟩ := ih (lam b) (by rosary) (by rosary)
      have hl : lam (b - 1) = lam b - 1 := by rosary
      have hle : lam b ≤ b := by rosary
      refine ⟨i1, i2, by omega, i4, ?_, ?_⟩
      · simp only [lamPow]; rw [hl]; exact i5
      · intro i hi
        cases i with
        | zero => simp only [lamPow]; rosary
        | succ i =>
          simp only [lamPow]
          rw [hl]
          exact i6 i (by omega)
    · rw [ladder_stop b h0]
      exact ⟨h0, hb, Nat.le_refl b, rfl, rfl, fun i hi => by omega⟩

/-- Lemma 2, iterated along white beads. -/
theorem height_lamPow (j : Nat) :
    ∀ x, 1 ≤ x → (∀ i, i < j → White (lamPow x i)) →
      height x = height (lamPow x j) + j := by
  induction j with
  | zero => intro x _ _; rfl
  | succ j ih =>
    intro x hx hwhite
    have hw : White x := hwhite 0 (Nat.zero_lt_succ j)
    have := ih (lam x) (lam_up x hx hw).1 fun i hi => hwhite (i + 1) (Nat.succ_lt_succ hi)
    simp only [lamPow]
    rw [lemma2 x hx hw, this]
    omega

/-! ## The program computes the height -/

theorem height_eq_heightFastAux (f : Nat) :
    ∀ n, 1 ≤ n → n ≤ f → height n = heightFastAux f n := by
  induction f with
  | zero => intro n h1 h0; omega
  | succ f ih =>
    intro n hn hf
    simp only [heightFastAux]
    by_cases h1 : n ≤ 1
    · rw [if_pos h1, show n = 1 by omega]; exact height_one
    rw [if_neg h1]
    by_cases hw : n % 3 ≠ 1
    · -- a white bead: Lemma 2
      rw [if_pos hw, lemma2 n hn hw, ih (lam n) (by rosary) (by rosary)]
    · -- a black bead: Corollary 1 and Theorem 1
      rw [if_neg hw]
      have hb : Black n := by rosary
      have h4 : 4 ≤ n := by rosary
      have c1 := corollary1 n hb (by omega)
      have win := winner_height n hb h4
      have wab := white_above_black n hb
      have hmu := lemma2 (mu n) (by rosary) wab.1
      have hnu := lemma2 (nu n) (by rosary) wab.2
      have smu := (seed_white (mu n) (by rosary) wab.1).2
      have snu := (seed_white (nu n) (by rosary) wab.2).2
      have e1 : lam (mu n) = (4 * n + 2) / 3 - 1 := by rosary
      have e2 : lam (nu n) = (4 * n + 2) / 3 := by rosary
      rw [e1] at hmu smu
      rw [e2] at hnu snu
      have hb1 : 6 ≤ (4 * n + 2) / 3 := by omega
      obtain ⟨l1, l2, l3, l4, l5, l6⟩ := ladder_spec ((4 * n + 2) / 3) (by omega)
      have hhb := height_lamPow _ ((4 * n + 2) / 3) (by omega) fun i hi => (l6 i hi).1
      have hha := height_lamPow _ ((4 * n + 2) / 3 - 1) (by omega) fun i hi => (l6 i hi).2
      have hsb := (seed_lamPow _ ((4 * n + 2) / 3) (by omega) fun i hi => (l6 i hi).1).2.2
      have hsa := (seed_lamPow _ ((4 * n + 2) / 3 - 1) (by omega) fun i hi => (l6 i hi).2).2.2
      rw [l4] at hhb hsb
      rw [l5] at hha hsa
      generalize (ladder ((4 * n + 2) / 3)).1 = x at *
      generalize (ladder ((4 * n + 2) / 3)).2 = s at *
      by_cases hx : x % 3 = 1
      · -- `x` is black: μ wins, continue from `x - 1`
        simp only [if_pos hx]
        have sx := (seed_black x hx).2
        have hxw : White (x - 1) := by rosary
        have sx1 := (seed_white (x - 1) (by omega) hxw).2
        have hx1 := lemma2 (x - 1) (by omega) hxw
        have := ih (lam (x - 1)) (by rosary) (by rosary)
        omega
      · -- `x - 1` is black: ν wins, continue from `x`
        simp only [if_neg hx]
        have sx := (seed_black (x - 1) (by rosary)).2
        have hxw : White x := hx
        have sx1 := (seed_white x (by omega) hxw).2
        have hx1 := lemma2 x (by omega) hxw
        have := ih (lam x) (by rosary) (by rosary)
        omega

/-- **The fast algorithm computes the height.** -/
theorem height_eq_heightFast (n : Nat) (hn : 1 ≤ n) : height n = heightFast n :=
  height_eq_heightFastAux n n hn (Nat.le_refl n)

end Rosary
