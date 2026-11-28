-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.PlayersLimit

/-!
# Four players: a bound checked from the table to the limit

A table on three hats for four players, found by a search on 2026-11-28
(`research/hats/players4/results/t3-886.txt`).  Lean's kernel counts its
wins, `886` out of `4096` (`winsN_four3`), and the theorem on repeated
resets gives the limit `885 / 3768 = 0.234873...` (`tendsto_four3`), above
the `14844 / 64120 = 0.231503...` of Buhler, Freiling, Graham, Kariv,
Roche, Tiefenbruck, Van Alten and Yeroshkin (`four3_gt`).

So the best win rate for four players is at least `885 / 3768`, with
nothing left to a program.  (A table on four hats gives more,
`15191 / 64120`, but its `65536` placements are counted by programs.)
-/

namespace Hats

open Finset

/-- The table: the entry `(u * 8 + v) * 8 + w` is the position to point at
for the player who sees the stacks `u`, `v`, `w`. -/
def tbl3 : List ℕ := [
  0, 1, 1, 1, 1, 1, 0, 0, 1, 2, 0, 2, 0, 0, 0, 1, 1, 0, 2, 2, 2, 2, 2, 0, 1, 2, 2, 1, 0, 2, 0, 1,
  1, 0, 2, 0, 1, 1, 2, 1, 1, 0, 2, 2, 1, 0, 1, 0, 0, 0, 2, 0, 2, 1, 0, 2, 0, 1, 0, 1, 1, 0, 2, 1,
  1, 2, 0, 2, 0, 0, 0, 1, 2, 0, 2, 2, 1, 0, 1, 0, 0, 2, 1, 1, 0, 2, 0, 2, 2, 2, 1, 2, 0, 0, 0, 2,
  0, 1, 0, 0, 2, 1, 2, 1, 0, 0, 2, 0, 1, 1, 1, 0, 0, 1, 0, 0, 2, 1, 2, 1, 1, 0, 2, 2, 1, 0, 1, 2,
  1, 0, 2, 2, 2, 2, 2, 0, 0, 2, 1, 1, 0, 2, 0, 2, 2, 1, 0, 0, 2, 1, 2, 1, 2, 1, 0, 1, 2, 2, 2, 1,
  2, 0, 2, 2, 1, 0, 1, 0, 2, 2, 1, 2, 0, 0, 0, 2, 2, 0, 2, 2, 1, 0, 1, 0, 0, 2, 1, 1, 0, 2, 0, 1,
  1, 2, 2, 1, 0, 2, 0, 1, 2, 2, 1, 2, 0, 0, 0, 2, 2, 1, 0, 1, 2, 2, 2, 1, 1, 2, 1, 1, 0, 2, 0, 2,
  0, 0, 2, 0, 1, 1, 1, 0, 2, 0, 2, 2, 1, 0, 1, 0, 0, 0, 2, 0, 1, 1, 2, 1, 1, 2, 1, 2, 0, 0, 1, 1,
  1, 0, 2, 0, 1, 1, 2, 1, 0, 1, 0, 0, 2, 1, 2, 1, 2, 0, 2, 2, 1, 0, 1, 0, 0, 0, 2, 0, 1, 1, 1, 0,
  1, 2, 1, 1, 0, 2, 0, 2, 1, 1, 0, 1, 2, 2, 2, 1, 2, 2, 1, 1, 0, 2, 0, 2, 1, 1, 0, 0, 2, 1, 2, 0,
  1, 0, 2, 2, 1, 0, 1, 0, 0, 0, 2, 0, 1, 1, 1, 0, 2, 2, 1, 2, 0, 0, 0, 2, 2, 0, 2, 2, 1, 0, 1, 0,
  1, 1, 0, 1, 2, 2, 2, 1, 0, 1, 0, 0, 2, 1, 2, 1, 1, 1, 0, 1, 2, 2, 0, 2, 0, 0, 2, 0, 1, 1, 2, 2,
  0, 0, 2, 0, 2, 1, 0, 2, 0, 1, 0, 0, 2, 1, 2, 1, 2, 0, 2, 2, 1, 0, 1, 0, 0, 0, 2, 0, 1, 1, 2, 1,
  2, 2, 1, 1, 0, 2, 0, 2, 1, 1, 0, 1, 2, 2, 0, 2, 0, 2, 1, 2, 0, 0, 1, 0, 2, 1, 0, 1, 2, 2, 0, 0,
  0, 1, 0, 1, 1, 0, 2, 1, 1, 0, 2, 2, 1, 0, 1, 2, 0, 2, 1, 1, 0, 2, 0, 1, 1, 2, 1, 2, 0, 0, 1, 1,
  1, 1, 0, 0, 2, 1, 2, 0, 0, 0, 2, 0, 1, 1, 2, 2, 2, 1, 0, 1, 2, 2, 0, 0, 1, 2, 1, 1, 0, 2, 0, 1]

def look3 (u v w : ℕ) : ℤ := ((tbl3.getD ((u * 8 + v) * 8 + w) 0 : ℕ) : ℤ)

/-- The strategy of the four players: each looks up the three other
stacks, in the order of the players. -/
def four3 : Fin 4 → (Fin 4 → ℕ) → ℤ := fun i a =>
  match i with
  | 0 => look3 (a 1) (a 2) (a 3)
  | 1 => look3 (a 0) (a 2) (a 3)
  | 2 => look3 (a 0) (a 1) (a 3)
  | 3 => look3 (a 0) (a 1) (a 2)

theorem tbl3_lt : ∀ x ∈ tbl3, x < 3 := by decide +kernel

theorem look3_bounds (u v w : ℕ) : 0 ≤ look3 u v w ∧ look3 u v w < 3 := by
  unfold look3
  have h : tbl3.getD ((u * 8 + v) * 8 + w) 0 < 3 := by
    rw [List.getD_eq_getElem?_getD]
    cases h : tbl3[(u * 8 + v) * 8 + w]? with
    | none => simp
    | some x => simpa using tbl3_lt x (List.mem_of_getElem? h)
  constructor
  · positivity
  · exact_mod_cast h

theorem four3_proper : ProperN 3 four3 := by
  intro i a _
  fin_cases i <;> exact look3_bounds _ _ _

theorem four3_blind : Blind four3 := by
  intro i a b h
  fin_cases i <;> simp [four3, h]

def q3 (a b c d : ℕ) : ℕ :=
  hat a (look3 b c d) * hat b (look3 a c d) * hat c (look3 a b d) * hat d (look3 a b c)

/-- The count, by the kernel: 4096 placements of the hats. -/
theorem count3 :
    (∑ a : Fin 8, ∑ b : Fin 8, ∑ c : Fin 8, ∑ d : Fin 8, q3 a b c d) = 886 := by
  decide +kernel

/-- A sum over the stacks of several players, the first player apart. -/
theorem sum_pi_succ (n N : ℕ) (F : (Fin (n + 1) → Fin N) → ℕ) :
    ∑ a : Fin (n + 1) → Fin N, F a
      = ∑ x : Fin N, ∑ f : Fin n → Fin N, F (Fin.cons x f) := by
  rw [← Fintype.sum_equiv (Fin.consEquiv fun _ : Fin (n + 1) => Fin N)
    (fun p => F (Fin.cons p.1 p.2)) F (fun _ => rfl), Fintype.sum_prod_type]

/-- A sum over the stacks of four players, one player at a time. -/
theorem sum_fin4 (N : ℕ) (F : (Fin 4 → Fin N) → ℕ) :
    ∑ a : Fin 4 → Fin N, F a
      = ∑ x0 : Fin N, ∑ x1 : Fin N, ∑ x2 : Fin N, ∑ x3 : Fin N, F ![x0, x1, x2, x3] := by
  rw [sum_pi_succ]
  refine sum_congr rfl fun x0 _ => ?_
  rw [sum_pi_succ]
  refine sum_congr rfl fun x1 _ => ?_
  rw [sum_pi_succ]
  refine sum_congr rfl fun x2 _ => ?_
  rw [sum_pi_succ]
  refine sum_congr rfl fun x3 _ => ?_
  rw [Fintype.sum_unique]
  congr 1

theorem winsN_four3 : winsN (2 ^ 3) four3 = 886 := by
  rw [← count3]
  show winsN 8 four3 = _
  unfold winsN termN
  rw [sum_fin4]
  refine sum_congr rfl fun x0 _ => sum_congr rfl fun x1 _ => sum_congr rfl fun x2 _ =>
    sum_congr rfl fun x3 _ => ?_
  simp [Fin.prod_univ_four, four3, q3]

/-- **Four players win at least `885 / 3768` of the time**: the win rates
of this table reset by itself tend to that number. -/
theorem tendsto_four3 :
    Filter.Tendsto (rateN 3 four3) Filter.atTop (nhds (885 / 3768)) := by
  have h := tendsto_rateN four3_proper four3_blind (by norm_num : 2 ≤ 3)
  rw [limitN_eq (by norm_num : 1 ≤ 3), winsN_four3] at h
  norm_num at h
  have e : (885 : ℝ) / 3768 = 295 / 1256 := by norm_num
  rw [e]
  exact h

/-- The bound of the paper is smaller. -/
theorem four3_gt : (14844 : ℝ) / 64120 < 885 / 3768 := by norm_num

end Hats
