-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

/-!
# The search for the best strategy on `n` hats, as a fast program

The search of the hats calculator (the second article), for `n` from 2 to
4: it tries every crushed strategy, with fixed choices for the all-white
and the all-black stacks, and returns the most hits.  It is proved correct
in `Hats/SearchProgram.lean`; this file has the program only, and needs no
library, so that it compiles to a small executable.

How it counts.  The choices are fixed stack by stack, in the order of the
numbers of the stacks.  A word `w q` holds, for each position `p`, in a
field of 8 bits, the number of stacks seen so far that chose `q` and have
a black hat at `p`.  When stack `t` chooses `p`, the pairs it completes
are, twice, the earlier stacks `u` such that `t` is black where `u`
pointed and `u` is black at `p`: the field `p` of the sum of the `w q`
over the black positions `q` of `t`.  One addition of words updates the
counts.  The all-black stack always adds `2 ^ n - 1` hits.
-/

namespace HatsSearch

/-- The color of the hat at position `q` of stack `t`: `1` for black. -/
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

/-- The search from stack `t` on.  `k` stacks with a choice come after
`t`; `top` is the highest position, `fin` what the all-black stack adds;
`acc` is the score so far, `res` the best score found so far. -/
def go (top fin : UInt64) : Nat → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 →
    UInt64 → UInt64
  | 0, t, acc, w0, w1, w2, w3, res =>
    let v := seen t w0 w1 w2 w3
    let r := max res (acc + gain t v 0 + fin)
    let r := if top ≥ 1 && t ≥ 1 then max r (acc + gain t v 1 + fin) else r
    let r := if top ≥ 2 && t ≥ 2 then max r (acc + gain t v 2 + fin) else r
    if top ≥ 3 && t ≥ 3 then max r (acc + gain t v 3 + fin) else r
  | k + 1, t, acc, w0, w1, w2, w3, res =>
    let v := seen t w0 w1 w2 w3
    let m := spread t
    let r := go top fin k (t + 1) (acc + gain t v 0) (w0 + m) w1 w2 w3 res
    let r := if top ≥ 1 && t ≥ 1 then
      go top fin k (t + 1) (acc + gain t v 1) w0 (w1 + m) w2 w3 r else r
    let r := if top ≥ 2 && t ≥ 2 then
      go top fin k (t + 1) (acc + gain t v 2) w0 w1 (w2 + m) w3 r else r
    if top ≥ 3 && t ≥ 3 then
      go top fin k (t + 1) (acc + gain t v 3) w0 w1 w2 (w3 + m) r else r

/-- The same search, cut into tasks: the choices of the first `depth`
stacks are fixed one way per task. -/
def split (top fin : UInt64) : Nat → Nat → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 →
    UInt64 → List (Task UInt64)
  | 0, k, t, acc, w0, w1, w2, w3 => [Task.spawn fun _ => go top fin k t acc w0 w1 w2 w3 0]
  | _ + 1, 0, t, acc, w0, w1, w2, w3 => [Task.spawn fun _ => go top fin 0 t acc w0 w1 w2 w3 0]
  | d + 1, k + 1, t, acc, w0, w1, w2, w3 =>
    let v := seen t w0 w1 w2 w3
    let m := spread t
    split top fin d k (t + 1) (acc + gain t v 0) (w0 + m) w1 w2 w3
      ++ (if top ≥ 1 && t ≥ 1 then
        split top fin d k (t + 1) (acc + gain t v 1) w0 (w1 + m) w2 w3 else [])
      ++ (if top ≥ 2 && t ≥ 2 then
        split top fin d k (t + 1) (acc + gain t v 2) w0 w1 (w2 + m) w3 else [])
      ++ (if top ≥ 3 && t ≥ 3 then
        split top fin d k (t + 1) (acc + gain t v 3) w0 w1 w2 (w3 + m) else [])

/-- **The search**: the most hits of a strategy on `n` hats, for `n` from
2 to 4.  `depth` is the number of stacks whose choices are shared out to
tasks; it does not change the result. -/
def search (n depth : Nat) : UInt64 :=
  (split (n.toUInt64 - 1) ((1 <<< n.toUInt64) - 1) depth (2 ^ n - 3) 1 0 0 0 0 0).foldl
    (fun r task => max r task.get) 0

end HatsSearch
