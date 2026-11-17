<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# 0003 — An earlier version of a paper is never modified

**Spec:** `docs/specs/0002-rosary-presentation-overhaul.md`

## Guarantee

Once a version of a paper is kept under `content/versions/`, its text and
its pictures stay byte for byte what they were: no file changed, added,
removed or renamed. A reader who compares versions compares what was
actually published.

## Why it holds

- `docs/papers/frozen-versions.sha256` records, for each version, one
  digest of the names and contents of all its files, written by
  `tools/check_frozen.py --freeze` when the version is created.
- Every build runs `tools/check_frozen.py`, which fails when a recorded
  directory differs from its digest or is missing, and when a directory
  under `content/versions/` is not in the record.

## Regression test

`tools/test_checks.py`, class `CheckFrozen`, run by every build: an
unrecorded version, a changed text, a changed picture, an added file, a
renamed file and a missing version each make the check fail; freezing
twice is refused.

## Limits

- The guarantee is about the sources. What a reader sees also depends on
  the templates, the style sheet, MathJax and the figure code, which keep
  evolving: an earlier version is shown with today's site around it, and
  its embedded or linked figures are today's figure pages.
- Whoever edits a version and its digest together defeats the check; the
  record is small enough for such a change to stand out in a review.
