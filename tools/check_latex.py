# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Check that the posts with formulas convert to LaTeX with Pandoc.

usage: check_latex.py CONTENT_DIR

Every index.md whose front matter says `math: true` is converted to LaTeX
(nothing is compiled).  Any Pandoc warning is an error.  This keeps the
sources usable for a LaTeX version of the papers.  Earlier versions of a
paper (content/versions) are not concerned: they are kept as they were.
"""

import pathlib
import re
import subprocess
import sys


def main() -> int:
    content = pathlib.Path(sys.argv[1])
    checked = 0
    failed = 0
    for path in sorted(content.rglob("*.md")):
        if "versions" in path.relative_to(content).parts:
            continue
        front = re.match(r"---\n(.*?)\n---\n", path.read_text(), re.S)
        if front is None or not re.search(r"^math:\s*true\s*$", front.group(1), re.M):
            continue
        checked += 1
        result = subprocess.run(
            [
                "pandoc",
                "--from=markdown-smart",
                "--to=latex",
                "--fail-if-warnings",
                "--output=/dev/null",
                str(path),
            ],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            failed += 1
            print(f"latex error: {path}:\n{result.stderr}", file=sys.stderr)
    print(f"check_latex: {checked} posts, {failed} errors")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
