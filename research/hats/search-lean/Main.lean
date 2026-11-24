-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

/-!
# The search for the best strategy on `n` hats, as a fast program

The search of the hats calculator (the second article), written in Lean
and compiled: it tries every crushed strategy on `n` hats (`n` from 2 to
4), with fixed choices for the all-white and the all-black stacks, and
reports the most hits and the number of strategies that reach it.

It is not verified.  The verified search is `Hats.bestFast` in
`formal/hats/Hats/SearchFast.lean`, which computes the same thing slowly.

How it counts.  The choices are fixed stack by stack, in the order of the
numbers of the stacks.  A word `w q` holds, for each position `p`, in a
field of 8 bits, the number of stacks seen so far that chose `q` and have
a black hat at `p`.  When stack `t` chooses `p`, the pairs it completes
are, twice, the earlier stacks `u` such that `t` is black where `u`
pointed and `u` is black at `p`: the field `p` of the sum of the `w q`
over the black positions `q` of `t`.  One addition of words updates the
counts.  The all-black stack always adds `2 ^ n - 1` hits.
-/

/-- A result: the most hits in the high bits, the number of strategies
that reach it in the 40 low bits. -/
@[inline] def merge (a b : UInt64) : UInt64 :=
  let ba := a >>> (40 : UInt64)
  let bb := b >>> (40 : UInt64)
  if ba > bb then a else if bb > ba then b else a + (b &&& 0xFFFFFFFFFF)

@[inline] def bit (t q : UInt64) : UInt64 := (t >>> q) &&& 1

/-- One in the field of each black position of stack `t`. -/
@[inline] def spread (t : UInt64) : UInt64 :=
  (t &&& 1) ||| ((t &&& 2) <<< (7 : UInt64)) ||| ((t &&& 4) <<< (14 : UInt64))
    ||| ((t &&& 8) <<< (21 : UInt64))

/-- For each position `p`: the earlier stacks that are black at `p` and
pointed at a black hat of `t`. -/
@[inline] def seen (t w0 w1 w2 w3 : UInt64) : UInt64 :=
  w0 * bit t 0 + w1 * bit t 1 + w2 * bit t 2 + w3 * bit t 3

/-- What stack `t` adds when it chooses `p`. -/
@[inline] def gain (t v p : UInt64) : UInt64 :=
  2 * ((v >>> (8 * p)) &&& 0xFF) + bit t p

/-- The search from stack `t` on.  `last` is the last stack that has a
choice, `top` the highest position, `fin` what the all-black stack adds. -/
partial def go (last top fin t acc w0 w1 w2 w3 res : UInt64) : UInt64 :=
  let v := seen t w0 w1 w2 w3
  if t == last then
    let r := merge res (((acc + gain t v 0 + fin) <<< (40 : UInt64)) ||| 1)
    let r := if top ≥ 1 then merge r (((acc + gain t v 1 + fin) <<< (40 : UInt64)) ||| 1) else r
    let r := if top ≥ 2 then merge r (((acc + gain t v 2 + fin) <<< (40 : UInt64)) ||| 1) else r
    if top ≥ 3 then merge r (((acc + gain t v 3 + fin) <<< (40 : UInt64)) ||| 1) else r
  else
    let m := spread t
    let r := go last top fin (t + 1) (acc + gain t v 0) (w0 + m) w1 w2 w3 res
    let r := if top ≥ 1 && t ≥ 1 then
      go last top fin (t + 1) (acc + gain t v 1) w0 (w1 + m) w2 w3 r else r
    let r := if top ≥ 2 && t ≥ 2 then
      go last top fin (t + 1) (acc + gain t v 2) w0 w1 (w2 + m) w3 r else r
    if top ≥ 3 && t ≥ 3 then
      go last top fin (t + 1) (acc + gain t v 3) w0 w1 w2 (w3 + m) r else r

/-- The same search, cut into tasks: the choices of the first stacks are
fixed one way per task. -/
partial def split (last top fin : UInt64) (depth : Nat) (t acc w0 w1 w2 w3 : UInt64)
    (tasks : Array (Task UInt64)) : Array (Task UInt64) :=
  if depth == 0 || t == last then
    tasks.push (Task.spawn fun _ => go last top fin t acc w0 w1 w2 w3 0)
  else
    let v := seen t w0 w1 w2 w3
    let m := spread t
    let ts := split last top fin (depth - 1) (t + 1) (acc + gain t v 0) (w0 + m) w1 w2 w3 tasks
    let ts := if top ≥ 1 && t ≥ 1 then
      split last top fin (depth - 1) (t + 1) (acc + gain t v 1) w0 (w1 + m) w2 w3 ts else ts
    let ts := if top ≥ 2 && t ≥ 2 then
      split last top fin (depth - 1) (t + 1) (acc + gain t v 2) w0 w1 (w2 + m) w3 ts else ts
    if top ≥ 3 && t ≥ 3 then
      split last top fin (depth - 1) (t + 1) (acc + gain t v 3) w0 w1 w2 (w3 + m) ts else ts

def usage : String :=
  "usage: hats-search N [DEPTH]\n" ++
  "  N      number of hats, from 2 to 4\n" ++
  "  DEPTH  number of stacks whose choices are shared out to tasks (default 0: one task)"

def main (args : List String) : IO UInt32 := do
  let some n := args.head? >>= String.toNat? | IO.eprintln usage; return 2
  if n < 2 || n > 4 then IO.eprintln usage; return 2
  let depth := (args.drop 1).head? >>= String.toNat? |>.getD 0
  let last : UInt64 := (1 <<< n.toUInt64) - 2
  let top : UInt64 := n.toUInt64 - 1
  let fin : UInt64 := (1 <<< n.toUInt64) - 1
  let start ← IO.monoNanosNow
  let tasks := split last top fin depth 1 0 0 0 0 0 #[]
  let res := tasks.foldl (fun r t => merge r t.get) 0
  let stop ← IO.monoNanosNow
  IO.println s!"{n} hats: best {res >>> (40 : UInt64)} hits out of {(4 : Nat) ^ n}, \
    reached by {res &&& 0xFFFFFFFFFF} strategies"
  IO.println s!"{tasks.size} task(s), {(stop - start) / 1000000} ms"
  return 0
