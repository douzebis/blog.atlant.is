-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Conjecture
import Hats.SearchNative

/-!
# Three hats added: a gain of at most 25

`hits_sub_four_le` (Proposition 13 of the article for three hats added).
It rests on `hits_four_le`, the best score on four hats, which trusts the
compiler: the axioms of this file are not only the standard ones.
-/

namespace Hats

theorem hits_sub_four_le {n : ℕ} {m s : ℕ → ℤ} (hs : Proper n s) (hm : Proper 4 m) :
    hits (n + 3) (sub n m s) ≤ 64 * hits n s + 25 := by
  have h := hits_sub (k := 3) hs hm
  have b : hits (3 + 1) m ≤ 89 := hits_four_le m
  omega

end Hats
