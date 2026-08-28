# openGrid Rod Holder

A deep, narrow pot that snaps onto an [openGrid](https://www.opengrid.world/)
board and keeps thin steel rod sorted by diameter. Built for 0.5 mm and 0.8 mm
hinge pin stock, but every dimension is parametric.

![Rod holder](images/rod_holder.png)

- 2 grid cells wide (56 mm), 152 mm tall, 16.8 mm deep
- 4 compartments, 11.8 mm square, 150 mm deep
- Engraved diameter labels on the front face
- Mounts on 4 snaps: two at the top, two at the bottom

## Requirements

The openGrid connector geometry lives in a separate library so other openGrid
projects can share it:

```sh
git clone https://github.com/morganp/openscad-opengrid.git \
  ~/Documents/OpenSCAD/libraries/opengrid
```

Then open `rod_holder.scad` in OpenSCAD.

---

## Layout

The pot's back wall *is* the mounting plate, so there is no separate bracket.
Snaps sit in the top and bottom rows only, 112 mm apart, which is 4 grid cells.

Snap centres have to land on the 28 mm grid and need 14 mm of clearance to any
plate edge. For a 152 mm pot that works out as:

```
snap_span = floor((152 - 28) / 28) * 28   = 112
snap_z0   = (152 - 112) / 2               = 20
```

so the rows sit at z = 20 and z = 132, with 20 mm of margin at each end. Change
`bore_depth` and the rows move to suit automatically.

![Section](images/rod_holder_section.png)

*Cut through the middle: four full-depth bores, a 2 mm floor and the back plate the snaps hang off.*

---

## Parameters

### openGrid

| Parameter | Default | Description |
|---|---|---|
| `grid_cols` | `2` | How many grid cells wide. Sets the pot width, `grid_cols * 28` |
| `lite_board` | `false` | `true` for a 4.0 mm Lite board, `false` for a 6.8 mm Full board |
| `snap_clearance` | `0` | Raise to 0.05 to 0.1 if the snaps print tight |

### Pot

| Parameter | Default | Description |
|---|---|---|
| `bore_depth` | `150` | Usable depth of each compartment |
| `compartments` | `4` | Number of compartments across the width |
| `wall` | `2.0` | Front and side wall thickness |
| `divider` | `1.6` | Thickness of the walls between compartments |
| `back_plate` | `3.0` | Back plate thickness, this is what the snaps hang off |
| `floor_thickness` | `2.0` | Material under the compartments |
| `compartment_depth` | `0` | Front to back size. `0` makes the compartments square |
| `mouth_chamfer` | `1.0` | 45 degree lead-in at the mouth so rods drop in cleanly |

Compartment width is whatever is left over:

```
comp_w = (grid_cols * 28 - 2 * wall - (compartments - 1) * divider) / compartments
```

which gives 11.8 mm at the defaults.

### Labels

| Parameter | Default | Description |
|---|---|---|
| `labels` | `["0.5", "0.8", "1.0", "1.5"]` | One per compartment, left to right as mounted. `""` for none, extras are ignored |
| `label_size` | `5` | Glyph height |
| `label_depth` | `0.6` | Engraving depth |
| `label_inset` | `10` | Distance from the top of the pot down to the middle of the label |

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
- the engraved labels end up on the bed and come out crisp
- the compartment bores run horizontally and need no bridging

Following the [openGrid printing guide](https://www.opengrid.world/guides/printing/):

- 0.4 mm nozzle, 0.2 mm layer height
- PLA or PETG, not flexibles
- At least 3 perimeters, this part hangs off a wall
- 15% infill or more
- Do not use a draft or fast profile, it will ruin the snap tolerances

Bed needs to fit 152 x 56 mm. About 74 cm3 of material at the defaults.

**Print one snap first.** Run the library's tile and snap examples and check the
fit by hand before committing to a 150 mm part.

---

## Verifying the fit

`mountfit_check.scad` intersects the finished holder with the board cells its
snaps sit in. A snap that fits has zero overlap with the board, so exporting
that intersection should give a zero volume solid:

```sh
openscad --export-format=binstl -o mountfit.stl mountfit_check.scad
```

This currently comes out at 0 mm3, so the snaps clear their cells everywhere at
rest. `section_preview.scad` produces the cutaway image above.

---

## Files

```
rod_holder.scad        -- the model
mountfit_check.scad    -- snap-to-board interference check
section_preview.scad   -- cutaway used for the README image
images/                -- rendered previews
```

## Credit

openGrid is a wall and desk mounting system by **David D**, CC BY 4.0:
<https://www.printables.com/model/1214361-opengrid-walldesk-mounting-framework-and-ecosystem>

Connector geometry comes from
[openscad-opengrid](https://github.com/morganp/openscad-opengrid).

## Versioning

[Semantic Versioning 2.0.0](https://semver.org).
