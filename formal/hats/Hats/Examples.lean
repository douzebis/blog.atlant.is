-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Families

/-!
# Examples computed by Lean

Strategies of the article, written as the list of their choices: the entry
of rank `t` is the position chosen for stack `t`.
-/

namespace Hats

/-- The strategy whose choices are listed in `l`. -/
def ofList (l : List ℤ) : ℕ → ℤ := fun t => l.getD t 0

/-- The lowest-black strategy on two hats has 5 hits (out of 16). -/
example : hits 2 (ofList [1, 0, 1, 0]) = 5 := by decide

/-- The Carter strategy on three hats has 22 hits (out of 64). -/
example : hits 3 (ofList [0, 1, 0, 0, 2, 1, 2, 0]) = 22 := by decide

/-- A strategy that points outside its stack: `(1, 1)` on one hat has no
hit, and the left reset by `[00]` has 4 hits out of 16, not the 1 that the
formula would give.  The formula needs a proper strategy. -/
example : hits 1 (ofList [1, 1]) = 0 := by decide
example : hits 2 (lr 1 (ofList [1, 1]) (ofList [0, 0])) = 4 := by decide

/-- The same for the left shift: `(1, 1)` left-shifted has 4 hits, not the
`4 * 0 + 1` of the formula. -/
example : hits 2 (ls 1 (ofList [1, 1])) = 4 := by decide

/-- And for a strategy played on a taller stack: `(1, 1)` has no hit on
one hat and 4 on two. -/
example : hits 2 (emb 1 (ofList [1, 1])) = 4 := by decide

/-- Two examples that the article of 2020 printed with a wrong digit
(spec 0005, D12): `[0010]` double-reset by itself is
`[2012-2012-3013-2012]`, and `[00]` left-reset by `[0101]` (written
`[0101] → [00]` there) is `[1020-1020]`. -/
example : ∀ t < 16, dr 2 (ofList [0, 0, 1, 0]) (ofList [0, 0, 1, 0]) t
    = ofList [2, 0, 1, 2, 2, 0, 1, 2, 3, 0, 1, 3, 2, 0, 1, 2] t := by decide
example : ∀ t < 8, lr 1 (ofList [0, 0]) (ofList [0, 1, 0, 1]) t
    = ofList [1, 0, 2, 0, 1, 0, 2, 0] t := by decide

/-- Double reset is not associative: the two ways of resetting `[1010]`
twice by `[00]` differ (at stack 3, among others). -/
example : dr 3 (dr 2 (ofList [1, 0, 1, 0]) one) one 3
    ≠ dr 2 (ofList [1, 0, 1, 0]) (dr 1 one one) 3 := by decide

/-- The families, as the tuples of the article: following the lowest black
hat on two hats is `[1010]`; the Carter strategies on two, three and four
hats are `[0100]`, `[01002120]` and `[01002123-01002120]`. -/
example : ∀ t < 4, lowBlack 2 t = ofList [1, 0, 1, 0] t := by decide
example : ∀ t < 4, carter 2 t = ofList [0, 1, 0, 0] t := by decide
example : ∀ t < 8, carter 3 t = ofList [0, 1, 0, 0, 2, 1, 2, 0] t := by decide
example : ∀ t < 16, carter 4 t
    = ofList [0, 1, 0, 0, 2, 1, 2, 3, 0, 1, 0, 0, 2, 1, 2, 0] t := by decide

/-- The double shift of the article's example (spec 0005, D13). -/
example : ∀ t < 16, ds 2 (ofList [0, 0, 0, 0]) t
    = ofList [0, 0, 0, 2, 0, 0, 0, 0, 3, 0, 0, 2, 3, 0, 0, 0] t := by decide

end Hats
