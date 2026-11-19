-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Fact1

/-!
# The reluctant recitation (Sections 6 and 7 of the paper)

Jane starts at bead 1 and moves down whenever the bead below has not been
told yet; otherwise she moves up.

`told i` is the list of the beads told after `i` moves, the latest first
(the paper's set `V_i`), and `rho i` is the bead where Jane is after `i`
moves.  The definition always produces a next bead: when Jane cannot go
down, it sends her up without asking whether the bead above is fresh.
That it always is fresh is part of Theorem 2 (`theorem2_fresh`); this is
how "the recitation is well defined" is expressed here.
-/

namespace Rosary

/-- The beads told after `i` moves, the latest first. -/
def told : Nat → List Nat
  | 0 => [1]
  | i + 1 =>
    if 2 ≤ (told i).headD 1 ∧ down ((told i).headD 1) ∉ told i
    then down ((told i).headD 1) :: told i
    else up ((told i).headD 1) :: told i

/-- `ρ(i)`: the bead where Jane is after `i` moves. -/
def rho (i : Nat) : Nat := (told i).headD 1

theorem rho_zero : rho 0 = 1 := rfl

theorem told_zero : told 0 = [1] := rfl

theorem told_succ' (i : Nat) :
    told (i + 1) =
      (if 2 ≤ rho i ∧ down (rho i) ∉ told i then down (rho i) else up (rho i))
        :: told i := by
  show (if 2 ≤ (told i).headD 1 ∧ down ((told i).headD 1) ∉ told i
    then down ((told i).headD 1) :: told i
    else up ((told i).headD 1) :: told i) = _
  by_cases h : 2 ≤ rho i ∧ down (rho i) ∉ told i
  · have h' : 2 ≤ (told i).headD 1 ∧ down ((told i).headD 1) ∉ told i := h
    simp only [if_pos h, if_pos h'] <;> rfl
  · have h' : ¬ (2 ≤ (told i).headD 1 ∧ down ((told i).headD 1) ∉ told i) := h
    simp only [if_neg h, if_neg h'] <;> rfl

/-- The reluctant rule: down if Jane is not at bead 1 and the bead below
has not been told, up otherwise. -/
theorem rho_succ (i : Nat) :
    rho (i + 1) =
      if 2 ≤ rho i ∧ down (rho i) ∉ told i then down (rho i) else up (rho i) := by
  show (told (i + 1)).headD 1 = _
  rw [told_succ'] <;> rfl

/-- After one more move, the beads told are the new bead and the old ones. -/
theorem told_succ (i : Nat) : told (i + 1) = rho (i + 1) :: told i := by
  rw [told_succ', rho_succ]

theorem rho_mem (i : Nat) : rho i ∈ told i := by
  cases i with
  | zero => simp [rho, told]
  | succ i => rw [told_succ]; exact List.mem_cons_self

theorem told_mono {i j : Nat} (h : i ≤ j) {n : Nat} (hn : n ∈ told i) : n ∈ told j := by
  induction j with
  | zero => rw [show i = 0 by omega] at hn; exact hn
  | succ j ih =>
    by_cases hij : i = j + 1
    · rw [hij] at hn; exact hn
    · rw [told_succ]; exact List.mem_cons_of_mem _ (ih (by omega))

/-- `told i` is the set `V_i = {ρ(0), …, ρ(i)}`. -/
theorem mem_told (i n : Nat) : n ∈ told i ↔ ∃ j, j ≤ i ∧ rho j = n := by
  induction i with
  | zero =>
    simp only [told_zero, List.mem_singleton]
    constructor
    · intro h; exact ⟨0, Nat.le_refl 0, by rw [h]; rfl⟩
    · intro ⟨j, hj, hr⟩; rw [show j = 0 by omega] at hr; rw [← hr]; rfl
  | succ i ih =>
    rw [told_succ, List.mem_cons, ih]
    constructor
    · rintro (h | ⟨j, hj, hr⟩)
      · exact ⟨i + 1, Nat.le_refl _, h.symm⟩
      · exact ⟨j, by omega, hr⟩
    · intro ⟨j, hj, hr⟩
      by_cases hji : j = i + 1
      · left; rw [← hr, hji]
      · right; exact ⟨j, by omega, hr⟩

theorem told_pos (i n : Nat) (hn : n ∈ told i) : 1 ≤ n := by
  induction i generalizing n with
  | zero => rw [told_zero, List.mem_singleton] at hn; omega
  | succ i ih =>
    rw [told_succ, List.mem_cons] at hn
    rcases hn with h | h
    · have hp := ih _ (rho_mem i)
      rw [h, rho_succ]
      by_cases hd : 2 ≤ rho i ∧ down (rho i) ∉ told i
      · have := hd.1
        rw [if_pos hd]; rosary
      · rw [if_neg hd]; rosary
    · exact ih _ h

theorem rho_pos (i : Nat) : 1 ≤ rho i := told_pos i _ (rho_mem i)

/-- The reluctant recitation is a recitation: each move is up or down. -/
theorem rho_move (i : Nat) :
    rho (i + 1) = up (rho i) ∨ (2 ≤ rho i ∧ rho (i + 1) = down (rho i)) := by
  rw [rho_succ]
  split
  · next h => exact Or.inr ⟨h.1, rfl⟩
  · exact Or.inl rfl

/-- **Lemma 3 (down-closure).**  If `n ∈ V_i`, `n > 1` and `n ≠ ρ(i)`,
then `nD ∈ V_i`. -/
theorem lemma3 (i n : Nat) (hn : n ∈ told i) (h2 : 2 ≤ n) (hne : n ≠ rho i) :
    down n ∈ told i := by
  induction i with
  | zero => rw [told_zero, List.mem_singleton] at hn; omega
  | succ i ih =>
    rw [told_succ, List.mem_cons] at hn
    rcases hn with h | h
    · exact absurd h hne
    · by_cases hni : n = rho i
      · -- Jane has just left `n`: she went down to `nD`, or `nD` was told
        subst hni
        rw [told_succ, List.mem_cons, rho_succ]
        by_cases hd : 2 ≤ rho i ∧ down (rho i) ∉ told i
        · left; rw [if_pos hd]
        · right
          apply Classical.byContradiction
          intro hnot
          exact hd ⟨h2, hnot⟩
      · exact told_mono (Nat.le_succ i) (ih h hni)

/-- The invariant of the proof of Theorem 2, at time `i`:
(a) the bead `ρ(i)` was not told before; (b) no gap in an up-chain. -/
theorem theorem2_aux (i : Nat) :
    (∀ j, j < i → rho i ∉ told j) ∧
    (∀ w, w ∈ told i → White w → lam w ∈ told i) := by
  induction i using Nat.strongRecOn with
  | _ i ih =>
    cases i with
    | zero =>
      refine ⟨fun j hj => by omega, fun w hw hwhite => ?_⟩
      rw [told_zero, List.mem_singleton] at hw
      rosary
    | succ i =>
      have hpos := rho_pos i
      -- (a) the new bead is fresh
      have hfresh : rho (i + 1) ∉ told i := by
        rw [rho_succ]
        by_cases hd : 2 ≤ rho i ∧ down (rho i) ∉ told i
        · rw [if_pos hd]; exact hd.2
        · rw [if_neg hd]
          intro hmem
          obtain ⟨j, hj, hr⟩ := (mem_told i _).mp hmem
          have hji : j ≠ i := by
            intro e; rw [e] at hr
            have : up (rho i) ≠ rho i := by rosary
            exact this hr.symm
          -- at time `j`, the bead `ρ(i)U` was told: no gap, so `ρ(i)` was too
          have hgap := (ih j (by omega)).2 (up (rho i)) (hr ▸ rho_mem j)
            (up_white (rho i) hpos).2
          rw [up_lam] at hgap
          exact (ih i (Nat.lt_succ_self i)).1 j (by omega) hgap
      refine ⟨fun j hj => fun hmem => hfresh (told_mono (by omega) hmem), ?_⟩
      -- (b) no gap at time `i + 1`
      intro w hw hwhite
      rw [told_succ, List.mem_cons] at hw
      rcases hw with hw | hw
      · -- `w` is the new bead
        rcases rho_move i with hup | ⟨h2, hdown⟩
        · -- reached by an up move, from `wλ`
          rw [hw, hup, up_lam]
          exact told_mono (Nat.le_succ i) (rho_mem i)
        · -- reached by a down move, from `p = ρ(i)`
          rw [← hw] at hdown
          have hpw : rho i = mu w ∨ rho i = nu w := (down_eq_iff _ w).mp hdown.symm
          have hwpos : 1 ≤ w := by rw [hw]; exact rho_pos (i + 1)
          by_cases hpwhite : White (rho i)
          · -- first diagram of Lemma 1
            have hg := (ih i (Nat.lt_succ_self i)).2 (rho i) (rho_mem i) hpwhite
            have hd := lemma3 i (lam (rho i)) hg (by rosary) (by rosary)
            have e : down (lam (rho i)) = lam w := by rosary
            rw [e] at hd
            exact told_mono (Nat.le_succ i) hd
          · -- `ρ(i)` is black: Jane came down to it, from `ρ(i - 1)`
            have hblack : Black (rho i) := by rosary
            cases i with
            | zero => rw [rho_zero] at hpw; rosary
            | succ i =>
              rcases rho_move i with hup' | ⟨h2', hdown'⟩
              · exact absurd hup'.symm (black_not_up _ _ hblack)
              · -- second diagram of Lemma 1
                have hp'w : rho i = mu (rho (i + 1)) ∨ rho i = nu (rho (i + 1)) :=
                  (down_eq_iff _ _).mp hdown'.symm
                have hg := (ih i (by omega)).2 (rho i) (rho_mem i) (by rosary)
                have hd1 := lemma3 i (lam (rho i)) hg (by rosary) (by rosary)
                have hd2 := lemma3 i (down (lam (rho i))) hd1 (by rosary) (by rosary)
                have e : down (down (lam (rho i))) = lam w := by rosary
                rw [e] at hd2
                exact told_mono (by omega) hd2
      · exact told_mono (Nat.le_succ i) ((ih i (Nat.lt_succ_self i)).2 w hw hwhite)

/-- **Theorem 2, first part.**  Jane never has to step on a bead already
told: the bead she moves to is new. -/
theorem theorem2_fresh (i : Nat) : rho (i + 1) ∉ told i :=
  (theorem2_aux (i + 1)).1 i (Nat.lt_succ_self i)

/-- **Theorem 2, second part.**  `ρ` is injective: no bead is told twice. -/
theorem theorem2_injective (i j : Nat) (h : rho i = rho j) : i = j := by
  apply Classical.byContradiction
  intro hne
  by_cases hlt : i < j
  · exact (theorem2_aux j).1 i hlt (h ▸ rho_mem i)
  · exact (theorem2_aux i).1 j (by omega) (h ▸ rho_mem j)

/-- **Theorem 2, third part.**  No gap in an up-chain: for every `i` and
every white bead `w ∈ V_i`, we have `wλ ∈ V_i`. -/
theorem theorem2_no_gap (i w : Nat) (hw : w ∈ told i) (hwhite : White w) :
    lam w ∈ told i :=
  (theorem2_aux i).2 w hw hwhite

end Rosary
