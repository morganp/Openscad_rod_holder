# openGrid Rod Holder

A deep, narrow pot that snaps onto an [openGrid](https://www.opengrid.world/)
board and keeps thin steel rod sorted by diameter. Built for 0.5 mm and 0.8 mm
hinge pin stock, but every dimension is parametric.

![Rod holder](images/rod_holder.png)

- 2 grid cells wide, 6 cells tall: 55.6 x 167.6 x 16.7 mm
- 4 compartments, 11.7 mm square, 165.6 mm deep
- Card label pocket above each compartment
- Mounts on 4 snaps: two at the top, two at the bottom
- Tiles in both directions, so a wall of them lines up

## Requirements

The openGrid connector geometry lives in a separate library so other openGrid
projects can share it:

```sh
git clone https://github.com/morganp/openscad-opengrid.git \
  ~/Documents/OpenSCAD/libraries/opengrid
```

Then open `rod_holder.scad` in OpenSCAD.

---

## Tiling

![Tiling](images/rod_holder_tiling.png)

*Four holders in a 2 x 2 block, with the board cells their snaps sit in shown behind.*

The outer size is a whole number of grid cells **less `tile_clearance`**, taken
off the outside so the snaps stay put. At the defaults the holder is 55.6 x
167.6 mm and sits on a 56 x 168 mm footprint, which is 2 x 6 cells. Butt them up
against each other and every snap still lands on the 28 mm grid, with 0.4 mm of
air between neighbours so they do not rub.

Vertical tiling is what `height_mode` is for:

| `height_mode` | Height | Bore | Tiles vertically |
|---|---|---|---|
| `"grid"` (default) | Rounded up to a whole number of cells, 167.6 | 165.6 | Yes |
| `"exact"` | `bore_depth + floor_thickness`, 152 | 150 | No |

In `"grid"` mode `bore_depth` is a **minimum**. The height rounds up to the next
whole cell and the spare goes into the bore, so asking for 150 mm gets you
165.6 mm rather than 16 mm of dead plastic in the base. Use `"exact"` if you
want the bore depth you asked for and do not care about stacking.

---

## Layout

The pot's back wall *is* the mounting plate, so there is no separate bracket.
Snaps sit in the top and bottom rows only.

Snap centres have to land on the 28 mm grid and need 14 mm of clearance to any
plate edge, so the rows are pushed as far apart as the height allows and the
pair is centred:

```
snap_span = floor((pot_h - 28) / 28) * 28
snap_z0   = (pot_h - snap_span) / 2
```

At 167.6 mm tall that puts the rows 112 mm apart at z = 27.8 and z = 139.8.
Change `bore_depth` and they move to suit.

![Section](images/rod_holder_section.png)

*Cut through the middle: four full-depth bores, the floor, and the back plate the snaps hang off.*

---

## Card labels

Each compartment gets a pocket in the front wall that holds a slip of card
behind a window. Cards drop in from the top of the pot and pull straight back
out, so relabelling means writing a new slip rather than reprinting the holder.

At the defaults the card is 11.7 x 12 mm with a 9.7 x 11 mm window, in a 0.7 mm
slot. Cut a strip of 300 gsm card, or fold ordinary paper double.

Set `label_mode = "engraved"` to cut fixed text into the front face instead, or
`"none"` to leave it plain.

---

## Parameters

### openGrid

| Parameter | Default | Description |
|---|---|---|
| `grid_cols` | `2` | How many grid cells wide |
| `lite_board` | `false` | `true` for a 4.0 mm Lite board, `false` for a 6.8 mm Full board |
| `snap_clearance` | `0` | Raise to 0.05 to 0.1 if the snaps print tight |
| `tile_clearance` | `0.4` | Gap left between neighbouring holders. Taken off the outside, the snaps stay on the grid |
| `height_mode` | `"grid"` | `"grid"` rounds the height to whole cells so holders tile vertically. `"exact"` gives exactly `bore_depth + floor_thickness` |

### Pot

| Parameter | Default | Description |
|---|---|---|
| `bore_depth` | `150` | Usable compartment depth. A minimum in `"grid"` mode |
| `compartments` | `4` | Number of compartments across the width |
| `wall` | `2.0` | Front and side wall thickness |
| `divider` | `1.6` | Thickness of the walls between compartments |
| `back_plate` | `3.0` | Back plate thickness, this is what the snaps hang off |
| `floor_thickness` | `2.0` | Material under the compartments |
| `compartment_depth` | `0` | Front to back size. `0` makes the compartments square |
| `mouth_chamfer` | `1.0` | Lead-in at the mouth. Opens sideways and backwards only, so the front wall stays thick enough for the card pocket |

Compartment width is whatever is left over:

```
comp_w = (grid_cols * 28 - tile_clearance - 2 * wall
          - (compartments - 1) * divider) / compartments
```

which gives 11.7 mm at the defaults.

### Labels

| Parameter | Default | Description |
|---|---|---|
| `label_mode` | `"card"` | `"card"`, `"engraved"` or `"none"` |
| `card_height` | `12` | Height of the card pocket. Width follows the compartment |
| `card_thickness` | `0.7` | Thickness of card the slot takes |
| `card_lip` | `0.6` | Front frame that stops the card falling out |
| `card_lip_margin` | `1.0` | How far that frame overlaps the card at the sides and bottom |
| `card_side_gap` | `0.8` | Gap each side of the card. Twice this is the rib between neighbouring pockets, so keep it near half the divider thickness |
| `labels` | `["0.5", "0.8", "1.0", "1.5"]` | Engraved mode only. Left to right as mounted |
| `label_size` | `5` | Engraved glyph height |
| `label_depth` | `0.6` | Engraving depth |
| `label_inset` | `10` | Engraved mode only, distance from the top down to the middle of the text |

### Output

| Parameter | Default | Description |
|---|---|---|
| `layout` | `"assembled"` | `"assembled"` shows it as mounted, `"print"` lays it out for the bed |
| `show_board` | `false` | Draw the board cells behind it, preview only |

---

## Printing

![Print layout](images/rod_holder_print.png)

Set `layout = "print"`. That lays the pot **front face down** with the snaps
pointing up, which is the orientation this part wants:

- every snap overhang is 45 degrees or shallower, so no support is needed
- the card pocket frames are on the bed and come out crisp, and the roof of each
  pocket is a short flat bridge between two edges
- the compartment bores run horizontally and need no bridging

Following the [openGrid printing guide](https://www.opengrid.world/guides/printing/):

- 0.4 mm nozzle, 0.2 mm layer height
- PLA or PETG, not flexibles
- At least 3 perimeters, this part hangs off a wall
- 15% infill or more
- Do not use a draft or fast profile, it will ruin the snap tolerances

Bed needs to fit 167.6 x 55.6 mm. About 79 cm3 of material at the defaults.

**Print one snap first.** Run the library's tile and snap examples and check the
fit by hand before committing to a 168 mm part.

---

## Verifying the fit

`mountfit_check.scad` intersects the finished holder with the board cells its
snaps sit in. A snap that fits has zero overlap with the board, so exporting
that intersection should give a zero volume solid:

```sh
openscad --export-format=binstl -o mountfit.stl mountfit_check.scad
```

This currently comes out at 0 mm3, so the snaps clear their cells everywhere at
rest.

---

## Files

```
rod_holder.scad        -- the model
mountfit_check.scad    -- snap-to-board interference check
section_preview.scad   -- cutaway used for the README image
tiling_preview.scad    -- 2 x 2 block used for the README image
images/                -- rendered previews
```

## Credit

openGrid is a wall and desk mounting system by **David D**, CC BY 4.0:
<https://www.printables.com/model/1214361-opengrid-walldesk-mounting-framework-and-ecosystem>

Connector geometry comes from
[openscad-opengrid](https://github.com/morganp/openscad-opengrid).

## Versioning

[Semantic Versioning 2.0.0](https://semver.org).
