-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Mathlib
import Rosary.Reluctant

open Rosary

example : Real.logb 2 8 = 3 := by
  rw [show (8 : ℝ) = 2 ^ (3 : ℕ) by norm_num, Real.logb_pow]
  simp

example : rho 5 = 4 := by decide
