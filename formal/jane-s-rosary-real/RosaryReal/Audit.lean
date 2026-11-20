-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import RosaryReal.Theorem3
import RosaryReal.Prop1
import RosaryReal.Theorem5
import RosaryReal.Theorem6
import RosaryReal.ThreeDistance
import RosaryReal.Lemma9Three

/-!
# What the proofs rest on

As in the first project: the check fails if a theorem listed here depends
on anything besides Lean's three standard axioms.
-/

open Rosary

#print axioms lemma5_up
#print axioms lemma5_down
#print axioms alpha_irrational
#print axioms rotation_cover
#print axioms eventually_large
#print axioms exists_up
#print axioms phase_track
#print axioms theorem3_by_rotation
#print axioms height_log
#print axioms theorem5_part1
#print axioms lemma9
#print axioms time_bound
#print axioms theorem6
#print axioms theorem6_exponent
#print axioms ThreeDistance.three_distance
#print axioms ThreeDistance.best_approx_gaps
#print axioms lemma9_three
#print axioms theorem6_frontier
