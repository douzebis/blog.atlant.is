-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Assoc
import Hats.Rates
import Hats.Crush
import Hats.Optimal
import Hats.Topology
import Hats.Measurable
import Hats.Readers
import Hats.SearchRun
import Hats.SearchProgram

/-!
# What the proofs rest on

The check fails if a theorem listed here depends on anything besides
Lean's three standard axioms.
-/

open Hats

#print axioms hits_congr
#print axioms hits_lr
#print axioms hits_rr
#print axioms hits_dr
#print axioms hits_congr_white
#print axioms hits_congr_black
#print axioms hits_ls
#print axioms hits_rs
#print axioms hits_ds
#print axioms hits_const
#print axioms hits_lowBlack
#print axioms hits_lowWhite
#print axioms hits_carter
#print axioms hits_reyes
#print axioms hits_emb
#print axioms lr_assoc
#print axioms rr_assoc
#print axioms Equivalent.hits_eq
#print axioms equivalent_of_eq_off_white
#print axioms hits_const_outside
#print axioms hits_top
#print axioms lowBlack_spec
#print axioms lowBlack_zero
#print axioms lowWhite_spec
#print axioms lowWhite_ones
#print axioms rate_lr
#print axioms rate_rr
#print axioms rate_dr
#print axioms rate_ls
#print axioms rate_rs
#print axioms rate_ds
#print axioms rate_emb
#print axioms rate_lowBlack
#print axioms rate_lowWhite
#print axioms rate_carterOdd
#print axioms rate_carterEven
#print axioms rate_reyes
#print axioms tendsto_rate_lowBlack
#print axioms tendsto_rate_lowWhite
#print axioms tendsto_rate_carter
#print axioms tendsto_rate_reyes
#print axioms hits_swapStrat
#print axioms exists_crushed
#print axioms hits_one_le
#print axioms hits_two_le
#print axioms rateInf_lift
#print axioms abs_rateInf_sub_rate_le
#print axioms limitOf_eq
#print axioms rateInf_limitOf
#print axioms lowBlackInf_spec
#print axioms rateInf_lowBlackInf
#print axioms rateInf_carterInf
#print axioms reyesInf_spec
#print axioms rateInf_reyesInf
#print axioms mk_stack
#print axioms continuum_lt_mk_strategies
#print axioms tendsto_trunc
#print axioms continuous_lift
#print axioms carterOdd_zero
#print axioms carterOdd_ones
#print axioms measurable_limitOf
#print axioms measurableSet_hitSet
#print axioms measurableSet_hitSet_lowBlackInf
#print axioms measurableSet_hitSet_carterInf
#print axioms measurableSet_hitSet_reyesInf
#print axioms lowBlackReader_outputs
#print axioms carterReader_outputs
#print axioms reyesReader_outputs
#print axioms lowBlackReader_computable
#print axioms carterReader_computable
#print axioms reyesReader_computable
#print axioms hits_le_best
#print axioms exists_hits_eq_best
#print axioms bestFast_eq_best
#print axioms best_three
#print axioms hits_three_le
#print axioms go_toNat
#print axioms search_toNat
#print axioms search_spec
