# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Draw the two figures of the paper that are not interactive.

usage: python draw_figures.py OUTDIR

Writes, each in a light and a dark variant (NAME.svg and NAME-dark.svg):

- figure-10: the binary tree of the rosary drawn with the phase as
  abscissa, the cone of bead 4, and what up moves do to the phase
  (Section 8);
- figure-13: the numerical data of Section 11, read from
  results/walk-27.log: F(t) log2(t) / t and u(t) - t log_3 2 against
  log2 t.

The drawings are plain SVG, written by hand below: no plotting library.
"""

import math
import pathlib
import sys

from rosary import down, is_black, up

THEMES = {
    "": {
        "background": "#fdfdfb",
        "text": "#1c1c1a",
        "muted": "#666660",
        "rule": "#d9d9d2",
        "black_bead": "#4d4d4d",
        "white_bead": "#e6e6e6",
        "bead_edge": "#9a9a94",
        "cone": "#f3d9a4",
        "accent": "#c0392b",
        "plot": "#1a5a96",
    },
    "-dark": {
        "background": "#191918",
        "text": "#e4e4de",
        "muted": "#a0a098",
        "rule": "#3c3c38",
        "black_bead": "#737373",
        "white_bead": "#e6e6e6",
        "bead_edge": "#9a9a94",
        "cone": "#5a4520",
        "accent": "#ff8a75",
        "plot": "#8fbfe8",
    },
}
FONT = 'font-family="Charter, Georgia, serif"'


def svg(width: int, height: int, body: list[str], colors: dict[str, str]) -> str:
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}">\n'
        f'<rect width="{width}" height="{height}" fill="{colors["background"]}"/>\n'
        + "\n".join(body)
        + "\n</svg>\n"
    )


def tree_figure(colors: dict[str, str]) -> str:
    """The beads of depth 0 to 5, the phase as abscissa, the root at the
    bottom."""
    width, height = 720, 400
    left, right, bottom, row = 50, 30, 330, 52
    span = width - left - right
    depth_of_cone, cone_bead = 2, 4

    def place(bead: int) -> tuple[float, float]:
        depth = bead.bit_length() - 1
        return left + (math.log2(bead) - depth) * span, bottom - depth * row

    body = []
    # The cone of bead 4: a strip of phases, from its depth upward.
    cone_left = left + (math.log2(cone_bead) - depth_of_cone) * span
    cone_right = left + (math.log2(cone_bead + 1) - depth_of_cone) * span
    top = bottom - 5 * row - 16
    strip_bottom = bottom - depth_of_cone * row + 18
    body.append(
        f'<rect x="{cone_left - 14:.1f}" y="{top}" width="{cone_right - cone_left + 14:.1f}" '
        f'height="{strip_bottom - top}" rx="8" fill="{colors["cone"]}"/>'
    )
    # Down moves: each bead joined to its parent.
    for bead in range(2, 64):
        x1, y1 = place(bead)
        x2, y2 = place(down(bead))
        body.append(
            f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" '
            f'stroke="{colors["rule"]}" stroke-width="1"/>'
        )
    # Up moves from the beads of the cone at depths 3 and 4.
    body.append(
        f'<defs><marker id="tip" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" '
        f'markerHeight="6" orient="auto"><path d="M0,0 L10,5 L0,10 z" fill="{colors["accent"]}"/>'
        f"</marker></defs>"
    )
    for bead in (8, 9, 16, 17, 18, 19):
        x1, y1 = place(bead)
        x2, y2 = place(up(bead))
        bend = 26 if y1 == y2 else 0
        body.append(
            f'<path d="M{x1:.1f},{y1 - 9:.1f} Q{(x1 + x2) / 2:.1f},{min(y1, y2) - 9 - bend:.1f} '
            f'{x2 - 4:.1f},{y2 - 9:.1f}" fill="none" stroke="{colors["accent"]}" '
            f'stroke-width="1.4" marker-end="url(#tip)"/>'
        )
    # The beads.
    for bead in range(1, 64):
        x, y = place(bead)
        depth = bead.bit_length() - 1
        black = is_black(bead)
        fill = colors["black_bead"] if black else colors["white_bead"]
        radius = 11 if depth <= 4 else 4
        body.append(
            f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{radius}" fill="{fill}" '
            f'stroke="{colors["bead_edge"]}" stroke-width="0.8"/>'
        )
        if depth <= 4:
            ink = "#f0f0f0" if black else "#3a3a3a"
            body.append(
                f'<text x="{x:.1f}" y="{y + 3.6:.1f}" text-anchor="middle" font-size="10.5" '
                f'font-family="Helvetica, Arial, sans-serif" fill="{ink}">{bead}</text>'
            )
    # The axis of phases.
    axis = bottom + 34
    body.append(
        f'<line x1="{left}" y1="{axis}" x2="{left + span}" y2="{axis}" '
        f'stroke="{colors["muted"]}" stroke-width="1"/>'
    )
    for tick in (0, 0.25, 0.5, 0.75, 1):
        x = left + tick * span
        body.append(
            f'<line x1="{x:.1f}" y1="{axis - 4}" x2="{x:.1f}" y2="{axis + 4}" '
            f'stroke="{colors["muted"]}" stroke-width="1"/>'
        )
        body.append(
            f'<text x="{x:.1f}" y="{axis + 20}" text-anchor="middle" font-size="13" {FONT} '
            f'fill="{colors["muted"]}">{tick:g}</text>'
        )
    body.append(
        f'<text x="{left + span / 2:.1f}" y="{axis + 38}" text-anchor="middle" font-size="13" '
        f'{FONT} font-style="italic" fill="{colors["muted"]}">phase</text>'
    )
    body.append(
        f'<text x="{(cone_left + cone_right) / 2 - 7:.1f}" y="{top - 8}" text-anchor="middle" '
        f'font-size="13" {FONT} font-style="italic" fill="{colors["text"]}">cone of bead 4</text>'
    )
    return svg(width, height + 8, body, colors)


def read_walk(log: pathlib.Path) -> list[tuple[int, float, float]]:
    """(log2 t, F(t) log2(t) / t, u(t) - t log_3 2) for t = 2^10, ..., 2^27."""
    rows = []
    for line in log.read_text().splitlines():
        fields = line.split()
        if len(fields) == 8 and fields[0].isdigit() and int(fields[0]) >= 10:
            rows.append((int(fields[0]), float(fields[4]), float(fields[6])))
    return rows


def panel(
    body: list[str],
    colors: dict[str, str],
    origin: tuple[int, int],
    size: tuple[int, int],
    points: list[tuple[float, float]],
    y_range: tuple[float, float],
    y_ticks: list[float],
    title: str,
) -> None:
    left, top = origin
    width, height = size
    x_min, x_max = 10, 27
    y_min, y_max = y_range

    def place(x: float, y: float) -> tuple[float, float]:
        return (
            left + (x - x_min) / (x_max - x_min) * width,
            top + height - (y - y_min) / (y_max - y_min) * height,
        )

    for tick in y_ticks:
        _, y = place(x_min, tick)
        body.append(
            f'<line x1="{left}" y1="{y:.1f}" x2="{left + width}" y2="{y:.1f}" '
            f'stroke="{colors["rule"]}" stroke-width="1"/>'
        )
        body.append(
            f'<text x="{left - 8}" y="{y + 4:.1f}" text-anchor="end" font-size="12" {FONT} '
            f'fill="{colors["muted"]}">{tick:g}</text>'
        )
    for tick in range(10, 28, 3):
        x, _ = place(tick, y_min)
        body.append(
            f'<text x="{x:.1f}" y="{top + height + 18}" text-anchor="middle" font-size="12" '
            f'{FONT} fill="{colors["muted"]}">{tick}</text>'
        )
    body.append(
        f'<text x="{left + width / 2}" y="{top + height + 38}" text-anchor="middle" '
        f'font-size="13" {FONT} font-style="italic" fill="{colors["muted"]}">log₂ t</text>'
    )
    body.append(
        f'<text x="{left}" y="{top - 12}" font-size="14" {FONT} fill="{colors["text"]}">{title}</text>'
    )
    path = " ".join(
        f"{'M' if i == 0 else 'L'}{place(x, y)[0]:.1f},{place(x, y)[1]:.1f}"
        for i, (x, y) in enumerate(points)
    )
    body.append(
        f'<path d="{path}" fill="none" stroke="{colors["plot"]}" stroke-width="1.2"/>'
    )
    for x, y in points:
        px, py = place(x, y)
        body.append(
            f'<circle cx="{px:.1f}" cy="{py:.1f}" r="3" fill="{colors["plot"]}"/>'
        )


def data_figure(colors: dict[str, str], rows: list[tuple[int, float, float]]) -> str:
    width, height = 720, 300
    body: list[str] = []
    panel(
        body,
        colors,
        (48, 40),
        (280, 190),
        [(lg, frontier) for lg, frontier, _ in rows],
        (0, 4),
        [0, 1, 2, 3, 4],
        "F(t) log₂ t / t",
    )
    panel(
        body,
        colors,
        (410, 40),
        (280, 190),
        [(lg, excess) for lg, _, excess in rows],
        (0, 20),
        [0, 5, 10, 15, 20],
        "u(t) − t log₃ 2",
    )
    return svg(width, height, body, colors)


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    out = pathlib.Path(sys.argv[1])
    rows = read_walk(pathlib.Path(__file__).parent / "results" / "walk-27.log")
    if len(rows) != 18:
        print(f"expected 18 lines of data, found {len(rows)}")
        return 1
    for suffix, colors in THEMES.items():
        (out / f"figure-10{suffix}.svg").write_text(tree_figure(colors))
        (out / f"figure-13{suffix}.svg").write_text(data_figure(colors, rows))
    print(f"wrote 4 files in {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
