-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Height

/-! # Lemma 2 (white beads) and Corollary 1 (black beads) -/

namespace Rosary

/-- The heart of Lemma 2: a recitation of `k` moves to a white bead `w`
gives a recitation of fewer than `k` moves to `wλ`.  This is the proof of
the paper: look at the last move; if it is a down move, use the diagrams of
Lemma 1. -/
theorem reach_lam (k : Nat) :
    ∀ w, 1 ≤ w → White w → Reach k w → ∃ j, j < k ∧ Reach j (lam w) := by
  induction k using Nat.strongRecOn with
  | _ k ih =>
    intro w hw hwhite h
    rcases h.inv with ⟨_, h1⟩ | ⟨j, p, rfl, hp, hup | ⟨hp2, hdown⟩⟩
    · -- the empty recitation ends at bead 1, which is black
      rosary
    · -- the last move is up, from `p = wλ`
      subst hup
      exact ⟨j, Nat.lt_succ_self j, by rw [up_lam]; exact hp⟩
    · -- the last move is down, from `p = wμ` or `p = wν`
      have hpw : p = mu w ∨ p = nu w := (down_eq_iff p w).mp hdown.symm
      by_cases hpwhite : White p
      · -- `p` is the white bead `ŵ`: first diagram of Lemma 1
        obtain ⟨i, hi, hreach⟩ := ih j (Nat.lt_succ_self j) p (by omega) hpwhite hp
        exact ⟨i + 1, by omega, hreach.down' (by rosary) (by rosary)⟩
      · -- `p` is the black bead `b`: it was reached by a down move from `p'`
        have hpb : Black p := by rosary
        rcases hp.inv with ⟨_, hp1⟩ | ⟨j', p', rfl, hp', hup' | ⟨hp'2, hdown'⟩⟩
        · omega
        · exact absurd hup'.symm (black_not_up p p' hpb)
        · -- second diagram of Lemma 1
          have hp'w : p' = mu p ∨ p' = nu p := (down_eq_iff p' p).mp hdown'.symm
          obtain ⟨i, hi, hreach⟩ :=
            ih j' (by omega) p' (by omega) (by rosary) hp'
          exact ⟨i + 2, by omega,
            (hreach.down' (by rosary) rfl).down' (by rosary) (by rosary)⟩

/-- **Lemma 2 (white beads).**  For every white bead `w`,
`h(w) = h(wλ) + 1`: some minimal recitation to `w` ends with an up move. -/
theorem lemma2 (w : Nat) (hw : 1 ≤ w) (hwhite : White w) :
    height w = height (lam w) + 1 := by
  have hl := lam_up w hw hwhite
  have h1 : height w ≤ height (lam w) + 1 :=
    height_le ((reach_height (lam w) hl.1).up' hl.2)
  obtain ⟨j, hj, hr⟩ := reach_lam _ w hw hwhite (reach_height w hw)
  have h2 := height_le hr
  omega

/-- The two beads above a black bead are white. -/
theorem white_above_black (b : Nat) (hb : Black b) : White (mu b) ∧ White (nu b) := by
  rosary

/-- **Corollary 1 (black beads).**  For every black bead `b > 1`,
`h(b) = 1 + min (h(bμ), h(bν))`.  (Both `bμ` and `bν` are white, so by
Lemma 2 some minimal recitation to `b` ends with up, down.) -/
theorem corollary1 (b : Nat) (hb : Black b) (h2 : 2 ≤ b) :
    height b = 1 + min (height (mu b)) (height (nu b)) := by
  have hmu := height_down_le (mu b) (by rosary)
  have hnu := height_down_le (nu b) (by rosary)
  rw [mu_down] at hmu
  rw [nu_down] at hnu
  rcases (reach_height b (by omega)).inv with ⟨_, h1⟩ | ⟨j, p, hj, hp, hup | ⟨hp2, hdown⟩⟩
  · omega
  · exact absurd hup.symm (black_not_up b p hb)
  · have hle := height_le hp
    rcases (down_eq_iff p b).mp hdown.symm with rfl | rfl <;> omega

end Rosary
