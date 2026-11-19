-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Fact1
import Rosary.Lemma1
import Rosary.Parity

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
