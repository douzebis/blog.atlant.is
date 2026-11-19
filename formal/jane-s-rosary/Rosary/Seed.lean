-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Lemma2
import Rosary.Parity

/-!
# Seed and lambex (Section 4 of the paper)

The seed of a bead `n` is the black bead from which `n` is reached by up
moves only; its lambex is the number of those up moves.  They are computed
by going back with `λ` until a black bead is met.

Lean only accepts a function if it can see that the computation stops.
The simplest way to show it is a counter (the "fuel") that decreases at
each step: `seedLamAux fuel n` makes at most `fuel` steps, and `n` steps
are enough for bead `n`.
-/

namespace Rosary

/-- Go back with `λ` from `n` until a black bead is met, at most `fuel`
times.  The result is the pair (bead reached, number of steps). -/
def seedLamAux : Nat → Nat → Nat × Nat
  | 0, n => (n, 0)
  | fuel + 1, n =>
    if n % 3 = 1 then (n, 0)
    else ((seedLamAux fuel (lam n)).1, (seedLamAux fuel (lam n)).2 + 1)

/-- **Seed**: `σ(n)`. -/
def seed (n : Nat) : Nat := (seedLamAux n n).1

/-- **Lambex**: `Λ(n)`. -/
def lambex (n : Nat) : Nat := (seedLamAux n n).2

/-- `lamPow n i` is `nλⁱ`. -/
def lamPow (n : Nat) : Nat → Nat
  | 0 => n
  | i + 1 => lamPow (lam n) i

/-- More fuel than needed changes nothing. -/
theorem seedLamAux_fuel (f : Nat) :
    ∀ g n, 1 ≤ n → n ≤ f → n ≤ g → seedLamAux f n = seedLamAux g n := by
  induction f with
  | zero => intro g n h1 h0; omega
  | succ f ih =>
    intro g n h1 hf hg
    cases g with
    | zero => omega
    | succ g =>
      simp only [seedLamAux]
      by_cases hb : n % 3 = 1
      · rw [if_pos hb, if_pos hb]
      · rw [if_neg hb, if_neg hb, ih g (lam n) (by rosary) (by rosary) (by rosary)]

/-- The seed of a black bead is itself, and its lambex is 0. -/
theorem seed_black (n : Nat) (hb : Black n) : seed n = n ∧ lambex n = 0 := by
  cases n with
  | zero => rosary
  | succ f =>
    have hb' : (f + 1) % 3 = 1 := hb
    simp [seed, lambex, seedLamAux, hb']

/-- For a white bead `n`: `σ(n) = σ(nλ)` and `Λ(n) = Λ(nλ) + 1`. -/
theorem seed_white (n : Nat) (hn : 1 ≤ n) (hw : White n) :
    seed n = seed (lam n) ∧ lambex n = lambex (lam n) + 1 := by
  cases n with
  | zero => omega
  | succ f =>
    have hfuel := seedLamAux_fuel f (lam (f + 1)) (lam (f + 1))
      (by rosary) (by rosary) (Nat.le_refl _)
    have hw' : ¬ (f + 1) % 3 = 1 := hw
    simp [seed, lambex, seedLamAux, hw', hfuel]

/-- The seed of a bead `n` is a black bead, at most `n`, and `Λ(n)` up
moves lead from it to `n`: `n = σ(n) U^Λ(n)`. -/
theorem seed_spec (n : Nat) (hn : 1 ≤ n) :
    Black (seed n) ∧ seed n ≤ n ∧ upPow (seed n) (lambex n) = n := by
  induction n using Nat.strongRecOn with
  | _ n ih =>
    by_cases hb : Black n
    · have := seed_black n hb
      rw [this.1, this.2]
      exact ⟨hb, Nat.le_refl n, rfl⟩
    · have hs := seed_white n hn hb
      have hl := lam_up n hn hb
      have := ih (lam n) (by rosary) hl.1
      rw [hs.1, hs.2]
      refine ⟨this.1, ?_, ?_⟩
      · have : lam n ≤ n := by rosary
        omega
      · simp only [upPow]
        rw [this.2.2, hl.2]

/-- The seed and the lambex are the only such pair: the up-chains of the
black beads do not meet.  With `seed_spec`, this says that
`n ↦ (σ(n), Λ(n))` is a bijection from the beads onto the pairs
(black bead, natural number). -/
theorem seed_upPow (b i : Nat) (hb : Black b) :
    seed (upPow b i) = b ∧ lambex (upPow b i) = i := by
  induction i with
  | zero => exact seed_black b hb
  | succ i ih =>
    have hpos : 1 ≤ upPow b i := upPow_pos b i (by rosary)
    have hw := up_white (upPow b i) hpos
    have hs := seed_white (upPow b (i + 1)) hw.1 hw.2
    simp only [upPow] at *
    rw [up_lam] at hs
    rw [hs.1, hs.2, ih.1, ih.2]
    exact ⟨rfl, rfl⟩

/-- Lemma 2, iterated: `h(n) = h(σ(n)) + Λ(n)`. -/
theorem height_seed (n : Nat) (hn : 1 ≤ n) :
    height n = height (seed n) + lambex n := by
  induction n using Nat.strongRecOn with
  | _ n ih =>
    by_cases hb : Black n
    · have := seed_black n hb
      rw [this.1, this.2]; rfl
    · have hs := seed_white n hn hb
      have hl := lam_up n hn hb
      have := ih (lam n) (by rosary) hl.1
      rw [hs.1, hs.2, lemma2 n hn hb, this]; rfl

/-- If the first `j` beads met when going back from `x` with `λ` are white,
they are beads, and the seed and the lambex of `x` are read from the next
one. -/
theorem seed_lamPow (j : Nat) :
    ∀ x, 1 ≤ x → (∀ i, i < j → White (lamPow x i)) →
      1 ≤ lamPow x j ∧ seed x = seed (lamPow x j) ∧
      lambex x = lambex (lamPow x j) + j := by
  induction j with
  | zero => intro x hx _; exact ⟨hx, rfl, rfl⟩
  | succ j ih =>
    intro x hx hwhite
    have hw : White x := hwhite 0 (Nat.zero_lt_succ j)
    have hs := seed_white x hx hw
    have := ih (lam x) (lam_up x hx hw).1 fun i hi => hwhite (i + 1) (Nat.succ_lt_succ hi)
    simp only [lamPow]
    refine ⟨this.1, by rw [hs.1, this.2.1], by rw [hs.2, this.2.2]; omega⟩

end Rosary
