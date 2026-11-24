-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Shift
import Hats.Examples

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
