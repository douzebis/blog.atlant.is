-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Theorem3
import Rosary.Onyx

/-!
# Corollary 3: Jane's foraging sequence

The foraging sequence lists the up-chains that Jane visits, one after the
other: the seed of `ρ(0)`, then the seed of the first bead with another
seed, and so on.  Corollary 3 says that it takes every value infinitely
often.  Here: for every black bead `B` and every time `T`, there is a later
time at which Jane enters the up-chain of `B`, coming from another one.
-/

namespace Rosary

/-- Jane is in the up-chain of each black bead `B` at arbitrarily late
times: she tells all its beads (Theorem 3), at different times. -/
theorem in_chain_late (B : Nat) (hb : Black B) (T : Nat) :
    ∃ i, T ≤ i ∧ seed (rho i) = B := by
  have hB1 : 1 ≤ B := by rosary
  have htime : ∀ k, ∃ i, rho i = upPow B k := fun k => theorem3 _ (upPow_pos B k hB1)
  apply Classical.byContradiction
  intro hno
  have hlt : ∀ k, k ≤ T → Classical.choose (htime k) < T := by
    intro k _
    apply Classical.byContradiction
    intro hge
    refine hno ⟨Classical.choose (htime k), by omega, ?_⟩
    rw [Classical.choose_spec (htime k)]
    exact (seed_upPow B k hb).1
  obtain ⟨k, k', hkk, _, he⟩ := pigeonhole T (fun k => Classical.choose (htime k)) hlt
  have he' : Classical.choose (htime k) = Classical.choose (htime k') := he
  have h1 := Classical.choose_spec (htime k)
  have h2 := Classical.choose_spec (htime k')
  rw [he'] at h1
  have := upPow_lt_index B k k' hB1 hkk
  omega

/-- **Corollary 3.**  The foraging sequence takes every value infinitely
often: for every black bead `B` and every time `T`, at some time `i ≥ T`
Jane is outside the up-chain of `B` and her next move brings her into it. -/
theorem corollary3 (B : Nat) (hb : Black B) (T : Nat) :
    ∃ i, T ≤ i ∧ seed (rho i) ≠ B ∧ seed (rho (i + 1)) = B := by
  -- a time `i1 ≥ T` in another up-chain, then the first later time in that of `B`
  obtain ⟨i1, hi1, hs1⟩ := in_chain_late (B + 3) (by rosary) T
  obtain ⟨i2, hi2, hs2⟩ := in_chain_late B hb (i1 + 1)
  have hex : ∃ d, seed (rho (i1 + 1 + d)) = B :=
    ⟨i2 - (i1 + 1), by rw [show i1 + 1 + (i2 - (i1 + 1)) = i2 by omega]; exact hs2⟩
  obtain ⟨d, hd, hmin⟩ := exists_least _ hex
  refine ⟨i1 + d, by omega, ?_, by rw [show i1 + d + 1 = i1 + 1 + d by omega]; exact hd⟩
  cases d with
  | zero => rw [Nat.add_zero, hs1]; omega
  | succ d =>
    intro h
    have := hmin d (by rw [show i1 + 1 + d = i1 + (d + 1) by omega]; exact h)
    omega

end Rosary
