# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Check the built site: links, images, and requests to other hosts.

usage: check_site.py --base-url URL SITE_DIR

Fails when
- a link or an image that points into the site has no file behind it, or
  names a fragment that the target page does not define;
- a page or a style sheet makes the browser load something from another
  host (script, style sheet, image, frame, font, media).  Ordinary links to
  other sites are fine: they load nothing until the reader follows them.

The MathJax files copied into the site are not scanned: they are not pages,
and their scripts are covered by the configuration that points them at the
site's own copies (docs/invariants/0002-no-third-party-requests.md).
"""

import argparse
import pathlib
import re
import sys
import urllib.parse
from html.parser import HTMLParser

VENDORED = ("mathjax", "mathjax-fonts")
# Attributes that make the browser fetch their target when the page loads.
LOADING = {
    ("script", "src"),
    ("img", "src"),
    ("iframe", "src"),
    ("source", "src"),
    ("video", "src"),
    ("audio", "src"),
    ("embed", "src"),
    ("object", "data"),
    ("video", "poster"),
}


class Page(HTMLParser):
    """Collects the identifiers, links and loaded resources of one page."""

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.ids: set[str] = set()
        self.links: list[str] = []
        self.loads: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = {name: value for name, value in attrs if value is not None}
        for name in ("id", "name"):
            if name in values:
                self.ids.add(values[name])
        if tag == "a" and "href" in values:
            self.links.append(values["href"])
        if tag == "link" and "href" in values:
            rel = values.get("rel", "").split()
            if "stylesheet" in rel or "icon" in rel or "preload" in rel:
                self.loads.append(values["href"])
            else:
                self.links.append(values["href"])
        for name, value in values.items():
            if (tag, name) in LOADING:
                self.loads.append(value)
            if name == "srcset":
                self.loads.extend(part.split()[0] for part in value.split(",") if part)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-url", required=True, help="address of the site")
    parser.add_argument("site", help="directory holding the built site")
    args = parser.parse_args()

    site = pathlib.Path(args.site)
    base = urllib.parse.urlsplit(args.base_url)
    base_path = base.path if base.path.endswith("/") else base.path + "/"
    errors: list[str] = []

    files = [
        path
        for path in sorted(site.rglob("*"))
        if path.is_file() and path.relative_to(site).parts[0] not in VENDORED
    ]
    pages: dict[pathlib.Path, Page] = {}
    for path in files:
        if path.suffix == ".html":
            page = Page()
            page.feed(path.read_text())
            pages[path] = page

    def target(source: pathlib.Path, url: str) -> tuple[pathlib.Path | None, str]:
        """The file a URL of the site points at (None for another host)."""
        parts = urllib.parse.urlsplit(url)
        if parts.scheme in ("mailto", "tel", "data", "javascript"):
            return None, ""
        if parts.netloc and (parts.netloc != base.netloc):
            return None, ""
        path = urllib.parse.unquote(parts.path)
        if parts.netloc or path.startswith("/"):
            if not path.startswith(base_path):
                # Same host, but outside the site (another project's pages).
                return None, ""
            file = site / path[len(base_path) :]
        elif path:
            file = source.parent / path
        else:
            file = source
        if file.is_dir() or path.endswith("/"):
            file = file / "index.html"
        return file, parts.fragment

    def is_foreign(url: str) -> bool:
        parts = urllib.parse.urlsplit(url)
        if url.startswith("//"):
            return parts.netloc != base.netloc
        return parts.scheme in ("http", "https") and parts.netloc != base.netloc

    for path, page in pages.items():
        name = path.relative_to(site)
        for url in page.loads:
            if is_foreign(url):
                errors.append(f"{name}: loads {url} from another host")
        for url in page.links + page.loads:
            file, fragment = target(path, url)
            if file is None:
                continue
            if not file.is_file():
                errors.append(f"{name}: {url} points at nothing")
            elif fragment and file in pages and fragment not in pages[file].ids:
                errors.append(f"{name}: {url} names a fragment that does not exist")

    for path in files:
        if path.suffix == ".css":
            text = path.read_text()
            for url in re.findall(r"url\(\s*['\"]?([^'\")]+)", text) + re.findall(
                r"@import\s+['\"]([^'\"]+)", text
            ):
                if is_foreign(url):
                    errors.append(
                        f"{path.relative_to(site)}: loads {url} from another host"
                    )

    for error in errors:
        print(f"site error: {error}", file=sys.stderr)
    print(f"check_site: {len(pages)} pages, {len(files)} files, {len(errors)} errors")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
