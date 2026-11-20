-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Fast
import Rosary.Lemma1
import Rosary.Reluctant
import Rosary.Onyx
import Rosary.Theorem3
import Rosary.Address
import Rosary.Foraging

/-!
# What the proofs rest on

`#print axioms` lists the axioms that a theorem depends on.  The build
fails if anything appears here besides the three standard axioms of Lean
(`propext`, `Classical.choice`, `Quot.sound`); in particular `sorryAx`,
which is what an unfinished proof leaves behind.
-/

open Rosary

#print axioms up_injective
#print axioms up_white
#print axioms lam_up
#print axioms up_lam
#print axioms black_not_up
#print axioms down_eq_iff
#print axioms lemma1
#print axioms lemma6
#print axioms lemma7_even
#print axioms lemma7_odd
#print axioms lemma7
#print axioms height_spec
#print axioms height_upper
#print axioms height_lower
#print axioms lemma2
#print axioms corollary1
#print axioms seed_spec
#print axioms seed_upPow
#print axioms height_seed
#print axioms theorem1_part1
#print axioms theorem1_part2
#print axioms theorem1_part3
#print axioms theorem1_part4
#print axioms theorem1_part5_mu
#print axioms theorem1_part5_nu
#print axioms height_eq_heightFast
#print axioms rho_succ
#print axioms mem_told
#print axioms lemma3
#print axioms theorem2_fresh
#print axioms theorem2_injective
#print axioms theorem2_no_gap
#print axioms proposition2
#print axioms gap_one_iff
#print axioms lemma8
#print axioms theorem4
#print axioms small_ratio
#print axioms cover
#print axioms untold_double
#print axioms untold_triple
#print axioms theorem3
#print axioms theorem3_permutation
#print axioms corollary2_injective
#print axioms corollary2_surjective
#print axioms corollary2_prefix
#print axioms corollary3
