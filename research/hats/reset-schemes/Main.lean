-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

/-!
# Generalized resets on blocks of four hats

A scheme is a set `Z` of stacks of four hats and a proper strategy `a` on
the other stacks of four hats: outside `Z` play `a` on the lowest block,
in `Z` skip the block and start again above
(`docs/papers/hats/open-questions.md`, question 4).  Its win rate is

    (A + c) / (256 - |Z|^2)

where `A` counts the pairs of stacks outside `Z` on which `a` wins, and
`c` the pairs `(t, u)` with `t` in `Z`, `u` outside and `t` black where
`a` points for `u`.

For every `Z`, up to the permutations of the four positions, this program
finds the largest `A + c` over all `a`, and prints the best win rates.  It
is not verified.

The counts are kept as in `formal/hats/HatsSearch/Program.lean`: a word
`w q` holds, for each position `p`, in a field of 8 bits, the number of
stacks outside `Z` seen so far that chose `q` and are black at `p`.
-/

@[inline] def bit (t q : UInt64) : UInt64 := (t >>> q) &&& 1

/-- One in the field of each black position of stack `t`. -/
@[inline] def spread (t : UInt64) : UInt64 :=
  (t &&& 1) ||| ((t &&& 2) <<< (7 : UInt64)) ||| ((t &&& 4) <<< (14 : UInt64))
    ||| ((t &&& 8) <<< (21 : UInt64))

@[inline] def seen (t w0 w1 w2 w3 : UInt64) : UInt64 :=
  w0 * bit t 0 + w1 * bit t 1 + w2 * bit t 2 + w3 * bit t 3

@[inline] def field (v p : UInt64) : UInt64 := (v >>> (8 * p)) &&& 0xFF

/-- What stack `t`, outside `Z`, adds when it chooses `p`: the pair
`(t, t)`, twice its pairs with the earlier stacks outside `Z`, and its
pairs with the stacks of `Z` (`zc` holds, for each position, the number of
stacks of `Z` that are black there). -/
@[inline] def gain (t v zc p : UInt64) : UInt64 :=
  2 * field v p + bit t p + field zc p

/-- The largest `A + c` from stack `t` on; `k` stacks remain. -/
def go (zmask zc : UInt64) : Nat → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 →
    UInt64 → UInt64
  | 0, _, acc, _, _, _, _, res => max res acc
  | k + 1, t, acc, w0, w1, w2, w3, res =>
    if bit zmask t == 1 then go zmask zc k (t + 1) acc w0 w1 w2 w3 res
    else
      let v := seen t w0 w1 w2 w3
      let m := spread t
      let r := go zmask zc k (t + 1) (acc + gain t v zc 0) (w0 + m) w1 w2 w3 res
      let r := go zmask zc k (t + 1) (acc + gain t v zc 1) w0 (w1 + m) w2 w3 r
      let r := go zmask zc k (t + 1) (acc + gain t v zc 2) w0 w1 (w2 + m) w3 r
      go zmask zc k (t + 1) (acc + gain t v zc 3) w0 w1 w2 (w3 + m) r

/-- The largest `A + c` for the set `Z` given by its mask. -/
def bestFor (zmask : UInt64) : UInt64 :=
  let zc := (List.range 16).foldl
    (fun s t => if bit zmask t.toUInt64 == 1 then s + spread t.toUInt64 else s) 0
  go zmask zc 16 0 0 0 0 0 0 0

/-- The 24 orders of the four positions. -/
def perms : List (List Nat) :=
  let l := [0, 1, 2, 3]
  l.flatMap fun a => (l.filter (· != a)).flatMap fun b =>
    ((l.filter fun x => x != a && x != b)).flatMap fun c =>
      ((l.filter fun x => x != a && x != b && x != c)).map fun d => [a, b, c, d]

/-- Stack `t` with its hats moved as `p` says. -/
def moveStack (p : List Nat) (t : Nat) : Nat :=
  (List.range 4).foldl (fun s i => s + ((t >>> i) &&& 1) <<< p[i]!) 0

/-- The set `Z` with the hats of its stacks moved as `p` says. -/
def moveMask (p : List Nat) (zmask : Nat) : Nat :=
  (List.range 16).foldl
    (fun s t => if (zmask >>> t) &&& 1 == 1 then s ||| (1 <<< moveStack p t) else s) 0

/-- Is this mask the smallest of its images?  The number of its images. -/
def canonical (zmask : Nat) : Bool × Nat :=
  let images := perms.map fun p => moveMask p zmask
  (images.all (zmask ≤ ·), images.eraseDups.length)

def popcount (zmask : Nat) : Nat :=
  (List.range 16).foldl (fun s t => s + ((zmask >>> t) &&& 1)) 0

def stacksOf (zmask : Nat) : List Nat :=
  (List.range 16).filter fun t => (zmask >>> t) &&& 1 == 1

def main : IO Unit := do
  let start ← IO.monoMsNow
  -- one task per set Z, up to the permutations of the positions
  let mut tasks : Array (Nat × Nat × Task UInt64) := #[]
  for zmask in [0:65535] do
    let (isCanonical, images) := canonical zmask
    if isCanonical then
      tasks := tasks.push (zmask, images, Task.spawn fun _ => bestFor zmask.toUInt64)
  IO.println s!"{tasks.size} sets Z up to the permutations of the positions"
  let results := tasks.map fun (zmask, images, task) => (zmask, images, task.get.toNat)
  -- the best win rate for each size of Z
  IO.println "size of Z | best A + c | win rate (A + c) / (256 - size^2) | against 7/20"
  for z in [0:16] do
    let ofSize := results.filter fun (zmask, _, _) => popcount zmask == z
    let top := ofSize.foldl (fun m (_, _, v) => max m v) 0
    let den := 256 - z * z
    let cmp := if 20 * top > 7 * den then "ABOVE" else if 20 * top == 7 * den then "equal" else "below"
    let rate := (top.toFloat / den.toFloat)
    IO.println s!"{z} | {top} | {top}/{den} = {rate} | {cmp}"
  -- the best of all
  let better (x y : Nat × Nat × Nat) : Bool :=
    x.2.2 * (256 - popcount y.1 ^ 2) > y.2.2 * (256 - popcount x.1 ^ 2)
  let best := results.foldl (fun b x => if better x b then x else b) results[0]!
  let ties := results.filter fun x => !better best x && !better x best
  IO.println s!"best win rate: {best.2.2}/{256 - popcount best.1 ^ 2}, \
    for {ties.size} set(s) Z up to the permutations:"
  for (zmask, images, v) in ties do
    IO.println s!"  Z = {stacksOf zmask} ({images} images), A + c = {v}"
  -- everything at 7/20 or above
  let high := results.filter fun (zmask, _, v) => 20 * v ≥ 7 * (256 - popcount zmask ^ 2)
  IO.println s!"sets Z that reach 7/20 or more: {high.size}"
  for (zmask, images, v) in high do
    IO.println s!"  Z = {stacksOf zmask} ({images} images), {v}/{256 - popcount zmask ^ 2}"
  let stop ← IO.monoMsNow
  IO.println s!"{(stop - start) / 1000} s"
