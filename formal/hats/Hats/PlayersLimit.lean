-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Players
import Mathlib.Analysis.SpecificLimits.Basic

/-!
# Any number of players: the win rate of repeated resets

A proper blind strategy `S` on `T` hats, reset by itself again and again:
`iterN T S j` is a strategy on `T * (j + 1)` hats.  With `n` players and
`P = 2 ^ T`, its win rate tends to

  `(wins S - 1) / ((P - 1) ^ n + n * (P - 1) ^ (n - 1) - (n + 1))`

(`tendsto_rateN`, `limitN_eq`): the formula of Buhler, Freiling, Graham,
Kariv, Roche, Tiefenbruck, Van Alten and Yeroshkin.
-/

namespace Hats

open Filter Topology Function

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

omit [Fintype ι] [DecidableEq ι] in
theorem goN_congr {T : ℕ} {i : ι} {l l' : ι → ℕ} (h : ∀ j, j ≠ i → l j = l' j) :
    goN T i l ↔ goN T i l' := by
  unfold goN
  constructor
  · rintro (⟨j, hj, h0⟩ | hall)
    · exact Or.inl ⟨j, hj, by rw [← h j hj]; exact h0⟩
    · exact Or.inr fun j hj => by rw [← h j hj]; exact hall j hj
  · rintro (⟨j, hj, h0⟩ | hall)
    · exact Or.inl ⟨j, hj, by rw [h j hj]; exact h0⟩
    · exact Or.inr fun j hj => by rw [h j hj]; exact hall j hj

theorem resetN_blind {T : ℕ} {S M : ι → (ι → ℕ) → ℤ} (bS : Blind S) (bM : Blind M) :
    Blind (resetN T S M) := by
  intro i a b h
  have hl : ∀ j, j ≠ i → (fun j => a j % 2 ^ T) j = (fun j => b j % 2 ^ T) j :=
    fun j hj => by simp [h j hj]
  have hx : ∀ j, j ≠ i → (fun j => a j / 2 ^ T) j = (fun j => b j / 2 ^ T) j :=
    fun j hj => by simp [h j hj]
  unfold resetN
  rw [bS i _ _ hl, bM i _ _ hx]
  by_cases g : goN T i fun j => a j % 2 ^ T
  · have g' := (goN_congr hl).mp g
    simp [g, g']
  · have g' : ¬ goN T i fun j => b j % 2 ^ T := fun h' => g ((goN_congr hl).mpr h')
    simp [g, g']

theorem resetN_proper {T k : ℕ} {S M : ι → (ι → ℕ) → ℤ} (hS : ProperN T S)
    (hM : ProperN k M) : ProperN (T + k) (resetN T S M) := by
  intro i a ha
  have hpos := Nat.two_pow_pos T
  have hq : ∀ j, a j / 2 ^ T < 2 ^ k := by
    intro j
    have := ha j
    rwa [Nat.div_lt_iff_lt_mul hpos, mul_comm, ← pow_add]
  have x := hS i (fun j => a j % 2 ^ T) fun j => Nat.mod_lt _ hpos
  have y := hM i (fun j => a j / 2 ^ T) hq
  unfold resetN
  split_ifs <;> constructor <;> push_cast <;> omega

/-- `S` reset by itself `j` times: a strategy on `T * (j + 1)` hats. -/
def iterN (T : ℕ) (S : ι → (ι → ℕ) → ℤ) : ℕ → ι → (ι → ℕ) → ℤ
  | 0 => S
  | j + 1 => resetN T S (iterN T S j)

section

variable [Nontrivial ι] {T : ℕ} {S : ι → (ι → ℕ) → ℤ} (hS : ProperN T S) (bS : Blind S)
include hS bS

omit [Nontrivial ι] in
theorem iterN_spec : ∀ j, ProperN (T * (j + 1)) (iterN T S j) ∧ Blind (iterN T S j)
  | 0 => by simpa [iterN] using ⟨hS, bS⟩
  | j + 1 => by
    obtain ⟨p, b⟩ := iterN_spec j
    refine ⟨?_, resetN_blind bS b⟩
    have h := resetN_proper hS p
    rw [show T * (j + 1 + 1) = T + T * (j + 1) by ring]
    exact h

/-- The wins after one more reset. -/
theorem winsN_iter (j : ℕ) :
    winsN (2 ^ (T * (j + 2))) (iterN T S (j + 1)) + (2 ^ (T * (j + 1))) ^ Fintype.card ι
      = (2 ^ (T * (j + 1))) ^ Fintype.card ι * winsN (2 ^ T) S
        + resetCard ι T * winsN (2 ^ (T * (j + 1))) (iterN T S j) := by
  obtain ⟨p, b⟩ := iterN_spec hS bS j
  have h := winsN_reset hS p bS b
  rw [show T * (j + 2) = T + T * (j + 1) by ring]
  exact h

/-- The win rate of `S` reset by itself `j` times. -/
noncomputable def rateN (T : ℕ) (S : ι → (ι → ℕ) → ℤ) (j : ℕ) : ℝ :=
  (winsN (2 ^ (T * (j + 1))) (iterN T S j) : ℝ) / (2 ^ (T * (j + 1))) ^ Fintype.card ι

/-- The limit of these win rates. -/
noncomputable def limitN (ι : Type*) [Fintype ι] [DecidableEq ι] (T : ℕ)
    (S : ι → (ι → ℕ) → ℤ) : ℝ :=
  ((winsN (2 ^ T) S : ℝ) - 1) / ((2 ^ T) ^ Fintype.card ι - resetCard ι T)

theorem rateN_succ (j : ℕ) :
    rateN T S (j + 1)
      = ((winsN (2 ^ T) S : ℝ) - 1) / (2 ^ T) ^ Fintype.card ι
        + (resetCard ι T : ℝ) / (2 ^ T) ^ Fintype.card ι * rateN T S j := by
  have h := winsN_iter hS bS j
  have h' : (winsN (2 ^ (T * (j + 2))) (iterN T S (j + 1)) : ℝ)
        + (2 ^ (T * (j + 1))) ^ Fintype.card ι
      = (2 ^ (T * (j + 1))) ^ Fintype.card ι * (winsN (2 ^ T) S : ℝ)
        + (resetCard ι T : ℝ) * (winsN (2 ^ (T * (j + 1))) (iterN T S j) : ℝ) := by
    exact_mod_cast h
  have e : ((2 : ℝ) ^ (T * (j + 1 + 1))) ^ Fintype.card ι
      = (2 ^ T) ^ Fintype.card ι * (2 ^ (T * (j + 1))) ^ Fintype.card ι := by
    rw [← mul_pow, ← pow_add]; congr 2; ring
  have p1 : (0 : ℝ) < (2 ^ T) ^ Fintype.card ι := by positivity
  have p2 : (0 : ℝ) < (2 ^ (T * (j + 1))) ^ Fintype.card ι := by positivity
  unfold rateN
  rw [e]
  field_simp
  linarith

omit hS bS in
/-- Fewer than all the lower parts make everybody go up, with at least two
hats. -/
theorem resetCard_lt (hT : 2 ≤ T) : resetCard ι T < (2 ^ T) ^ Fintype.card ι := by
  have h := resetCard_add (ι := ι) (T := T) (by omega)
  have hn : 2 ≤ Fintype.card ι := Fintype.one_lt_card
  have hP : 4 ≤ 2 ^ T := by
    have : 2 ^ 2 ≤ 2 ^ T := Nat.pow_le_pow_right (by norm_num) hT
    simpa using this
  have h3 : 3 ≤ (2 ^ T - 1) ^ (Fintype.card ι - 1) := by
    calc 3 ≤ 2 ^ T - 1 := by omega
      _ = (2 ^ T - 1) ^ 1 := (pow_one _).symm
      _ ≤ (2 ^ T - 1) ^ (Fintype.card ι - 1) :=
        Nat.pow_le_pow_right (by omega) (by omega)
  have h4 : Fintype.card ι * 3 ≤ Fintype.card ι * (2 ^ T - 1) ^ (Fintype.card ι - 1) :=
    Nat.mul_le_mul_left _ h3
  omega

/-- **The win rates of repeated resets tend to
`(W - 1) / (P ^ n - resetCard)`**, for a proper blind strategy on at least
two hats. -/
theorem tendsto_rateN (hT : 2 ≤ T) :
    Tendsto (rateN T S) atTop (𝓝 (limitN ι T S)) := by
  have hc : (resetCard ι T : ℝ) < (2 ^ T) ^ Fintype.card ι := by
    exact_mod_cast resetCard_lt (ι := ι) hT
  have p1 : (0 : ℝ) < (2 ^ T) ^ Fintype.card ι := by positivity
  have q0 : (0 : ℝ) ≤ (resetCard ι T : ℝ) / (2 ^ T) ^ Fintype.card ι := by positivity
  have q1 : (resetCard ι T : ℝ) / (2 ^ T) ^ Fintype.card ι < 1 := by
    rw [div_lt_one p1]; exact hc
  have closed : ∀ j, rateN T S j
      = limitN ι T S + ((resetCard ι T : ℝ) / (2 ^ T) ^ Fintype.card ι) ^ j
        * (rateN T S 0 - limitN ι T S) := by
    intro j
    induction j with
    | zero => simp
    | succ j ih =>
      rw [rateN_succ hS bS, ih, pow_succ]
      have hd : ((2 : ℝ) ^ T) ^ Fintype.card ι - resetCard ι T ≠ 0 := by linarith
      unfold limitN
      field_simp
      ring
  have t := (tendsto_pow_atTop_nhds_zero_of_lt_one q0 q1).mul_const
    (rateN T S 0 - limitN ι T S)
  have t' := t.const_add (limitN ι T S)
  simp only [zero_mul, add_zero] at t'
  exact t'.congr fun j => (closed j).symm

omit hS bS in
/-- The denominator, as in the paper. -/
theorem limitN_eq (hT : 1 ≤ T) :
    limitN ι T S = ((winsN (2 ^ T) S : ℝ) - 1)
      / ((2 ^ T - 1) ^ Fintype.card ι
        + Fintype.card ι * (2 ^ T - 1) ^ (Fintype.card ι - 1) - (Fintype.card ι + 1)) := by
  have h := resetCard_add (ι := ι) (T := T) hT
  have h' : (resetCard ι T : ℝ) + ((2 : ℝ) ^ T - 1) ^ Fintype.card ι
      + Fintype.card ι * ((2 : ℝ) ^ T - 1) ^ (Fintype.card ι - 1)
      = ((2 : ℝ) ^ T) ^ Fintype.card ι + Fintype.card ι + 1 := by
    have one_le : 1 ≤ 2 ^ T := Nat.one_le_two_pow
    have := congrArg (Nat.cast : ℕ → ℝ) h
    push_cast [Nat.cast_sub one_le] at this
    exact this
  unfold limitN
  congr 1
  linarith

end

end Hats
