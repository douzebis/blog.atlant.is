-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import HatsSearch.Program

def usage : String :=
  "usage: hats-search N [DEPTH]\n" ++
  "  N      number of hats, from 2 to 4\n" ++
  "  DEPTH  number of stacks whose choices are shared out to tasks (default 0: one task)"

def main (args : List String) : IO UInt32 := do
  let some n := args.head? >>= String.toNat? | IO.eprintln usage; return 2
  if n < 2 || n > 4 then IO.eprintln usage; return 2
  let depth := (args.drop 1).head? >>= String.toNat? |>.getD 0
  let start ← IO.monoNanosNow
  let best := HatsSearch.search n depth
  IO.println s!"{n} hats: the best strategies have {best} hits out of {(4 : Nat) ^ n}"
  let stop ← IO.monoNanosNow
  IO.println s!"{(stop - start) / 1000000} ms"
  return 0
