<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Jane's infinite rosary: statements

Every statement of the paper, where it stands, and what was checked by
computer. The programs are in `research/jane-s-rosary/`; its README gives
the commands. "Proved" always means: in the paper, in the section named.

The list is the one that `tools/compare_statements.py` extracts from the
paper; it is brought up to date when a version is frozen.

As of 2026-11-18 (the current version, beads counted from 1, spec 0003):

| Statement | Section | Program | Checked by computer |
|---|---|---|---|
| Fact 1 | 1. Prelude: names | `check_shortest.py` | beads below 60,000 |
| Proposition 1 | 2. The height of a bead | `check_shortest.py` | beads up to 10^6; the three cases of the proof, beads below 60,000 |
| Lemma 1 | 3. Minimal recitations | `check_shortest.py` | the six diagrams of the proof, k below 5,000 |
| Lemma 2 | 3. Minimal recitations | `check_shortest.py` | beads below 60,000 |
| Corollary 1 | 3. Minimal recitations | `check_shortest.py` | beads below 60,000 |
| Theorem 1 | 5. Theorem 1: minimal recitations ending in a black bead | `check_shortest.py` | the rule and parts 1 to 3, black beads below 60,000; the chains of the proof, onyxes below 3,000 |
| Lemma 3 | 6. Jane's reluctant recitation | — | immediate from the definition |
| Theorem 2 | 7. Theorem 2: Jane's reluctant recitation never halts | `check_reluctant.py`, `walk.c` | 300,000 moves; never stuck on 2^27 moves |
| Theorem 3 | 8. Theorem 3: Jane's reluctant recitation tells all beads | `walk.c` | every bead up to 10,801,813 told after 2^27 moves (an instance, not a check of the theorem) |
| Lemma 4 | 8. Theorem 3: Jane's reluctant recitation tells all beads | `check_reluctant.py` | beads below 5,000 |
| Lemma 5 | 8. Theorem 3: Jane's reluctant recitation tells all beads | `check_reluctant.py` | beads below 20,000 |
| Proposition 2 | Onyx ordering | `check_onyx.py` | onyxes below 20,000 |
| Lemma 6 | Theorem 4: every onyx has infinitely many covers | `check_onyx.py` | beads below 20,000 |
| Lemma 7 | Theorem 4: every onyx has infinitely many covers | `check_onyx.py` | beads below 20,000 |
| Lemma 8 | Theorem 4: every onyx has infinitely many covers | `check_onyx.py` | the computation it rests on, a below 3,000 |
| Theorem 4 | Theorem 4: every onyx has infinitely many covers | — | not checked |
| Corollary 2 | Corollary: the address of an onyx | `check_onyx.py` | the table tau(1..11) only |
| Corollary 3 | Jane's foraging sequence | `check_onyx.py` | the 24 values quoted only |
| Theorem 5 | Theorem 5: Jane moves up with frequency … | `check_reluctant.py`, `walk.c` | part 1 on 300,000 moves; u(t)/t on 2^27 moves |
| Lemma 9 | Theorem 6: bead … is told in polynomial time | `check_reluctant.py` | the fact on convergents, 8 denominators |
| Theorem 6 | Theorem 6: bead … is told in polynomial time | — | not checked |
| Conjecture A | 12. Conjectures and open questions | `walk.c` | evidence: 2^27 moves |
| Conjecture B | 12. Conjectures and open questions | `walk.c` | evidence: 2^27 moves |
| Question C | 12. Conjectures and open questions | `walk.c` | evidence: 2^27 moves |
| Conjecture D | 12. Conjectures and open questions | `height_statistics.py` | evidence: random n of 64 to 1024 bits |
| Question E | 12. Conjectures and open questions | `height_statistics.py` | evidence: n below 10^6 |
| Conjecture F | 12. Conjectures and open questions | — | no program kept |
| Question G | 12. Conjectures and open questions | — | no program kept |

Status of the statements across versions:

- 2023-01: Theorems 1, 2 and 4 are stated and proved (with other proofs
  than today's); that the reluctant recitation tells every bead is
  "Conjecture 3", with two lemmas toward it.
- 2026-11: Theorem 3 is proved; Theorems 5 and 6 and the open questions A
  to G are new.
- 2026-11-18: the same statements with the beads counted from 1 (spec
  0003); `check_renumbering.py` checks that the definitions are the
  earlier ones shifted by one.
