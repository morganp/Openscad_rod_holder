# Changelog

All notable changes to this project. Versions follow
[Semantic Versioning 2.0.0](https://semver.org).

## 2.0.0 - 2026-09-26

### Changed (breaking defaults)
- Default holder is now 1 grid cell square (27.6 x 27.6 x 167.6 mm) with four
  compartments in a 2 x 2 grid, 11.0 x 10.5 mm. The v1 holder is still available
  with `grid_cols = 2`, `compartments = 4`, `compartment_rows = 1`,
  `pot_depth = 0`, `bore_depth = 150` and the windows turned off, and produces
  the same solid as 1.2.0.
- `bore_depth` default 150 -> 158. In grid height mode the pot is still 6 cells,
  167.6 mm.
- The mouth lead-in no longer opens into an outer wall that carries a card
  pocket.

### Added
- `compartment_rows` and `pot_depth` (`-1` matches the width, `0` sizes from
  `compartment_depth`).
- Diamond lattice windows in the outer walls (`window_style = "diamond"`,
  default): one diamond per face in alternating rows with diamonds wrapped round
  the two front vertical edges (cut along the corner bisector so the outline is
  continuous over the rounded edge), 45 degree edges so the side holes print without
  bridges. `diamond_size`, `diamond_web`, `diamond_corners`.
- `window_style = "slot"` keeps a ladder of narrow slots per compartment
  (`window_width`, `window_height`, `window_bar`). Shared window settings:
  `window_sides`, `window_front`, `window_start`, `window_zone`.
- Card pockets and engraved labels on the side walls for compartments behind
  the front row.
- `windows_preview.scad` and `images/rod_holder_windows.png`.

## 1.2.0 - 2026-08-28
- Rounded outer edges and compartment insides, 45 degree relief on the front
  face for printing.

## 1.1.0 - 2026-08-28
- Tiling on both axes (`tile_clearance`, `height_mode`) and card label pockets.

## 1.0.0 - 2026-08-28
- openGrid rod holder, 4 compartments, 150 mm deep.
