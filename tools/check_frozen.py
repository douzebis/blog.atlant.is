# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Check that the earlier versions of the papers have not been modified.

usage: check_frozen.py RECORD            check every directory of the record
       check_frozen.py RECORD --freeze DIRECTORY
                                         add a directory to the record

The record (docs/papers/frozen-versions.sha256) has one line per frozen
directory: a digest, two spaces, the directory.  The digest covers the names
and the contents of all files of the directory.  A directory under
content/versions that the record does not list is an error too: a version
is frozen when it is created.
"""

import argparse
import hashlib
import pathlib
import sys

VERSIONS = pathlib.Path("content/versions")


def digest(directory: pathlib.Path) -> str:
    """One digest for the names and contents of the files of a directory."""
    total = hashlib.sha256()
    for path in sorted(p for p in directory.rglob("*") if p.is_file()):
        total.update(path.relative_to(directory).as_posix().encode())
        total.update(b"\0")
        total.update(hashlib.sha256(path.read_bytes()).digest())
    return total.hexdigest()


def read_record(record: pathlib.Path) -> dict[str, str]:
    entries: dict[str, str] = {}
    if record.exists():
        for line in record.read_text().splitlines():
            if line and not line.startswith("#"):
                value, name = line.split("  ", 1)
                entries[name] = value
    return entries


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("record", help="file listing the frozen directories")
    parser.add_argument("--freeze", metavar="DIRECTORY", help="add this directory")
    parser.add_argument(
        "--root", default=".", help="directory the names are relative to"
    )
    args = parser.parse_args()
    record = pathlib.Path(args.record)
    root = pathlib.Path(args.root)
    entries = read_record(record)

    if args.freeze:
        name = pathlib.Path(args.freeze).as_posix().rstrip("/")
        if name in entries:
            print(f"already frozen: {name}", file=sys.stderr)
            return 1
        if not (root / name / "index.md").is_file():
            print(f"not a version (no index.md): {name}", file=sys.stderr)
            return 1
        with record.open("a") as handle:
            handle.write(f"{digest(root / name)}  {name}\n")
        print(f"frozen: {name}")
        return 0

    errors: list[str] = []
    for name, value in entries.items():
        directory = root / name
        if not directory.is_dir():
            errors.append(f"{name}: recorded as frozen, but missing")
        elif digest(directory) != value:
            errors.append(f"{name}: modified since it was frozen")
    versions = root / VERSIONS
    if versions.is_dir():
        for index in sorted(versions.rglob("index.md")):
            name = index.parent.relative_to(root).as_posix()
            if name not in entries:
                errors.append(f"{name}: a version that is not in the record")
    for error in errors:
        print(f"frozen error: {error}", file=sys.stderr)
    print(f"check_frozen: {len(entries)} versions, {len(errors)} errors")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
