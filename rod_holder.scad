/*
 * rod_holder.scad -- openGrid mounted pot for thin steel rods
 *
 * A deep, narrow pot that snaps onto an openGrid board and keeps hinge pin
 * stock sorted by diameter. Sized around 0.5 mm and 0.8 mm steel rod, but every
 * dimension is parametric.
 *
 * Requires: https://github.com/morganp/openscad-opengrid
 *   git clone .../openscad-opengrid ~/Documents/OpenSCAD/libraries/opengrid
 *
 * Coordinates: the openGrid board face is the y = 0 plane. Snaps reach back into
 * the board at y < 0, the pot stands off the wall at y > 0, and z = 0 is the
 * bottom of the pot.
 */

include <opengrid/opengrid.scad>

/* [openGrid] */
// how many grid cells wide the holder is
grid_cols = 2;          // [1:6]
// true for a 4.0 mm Lite board, false for a 6.8 mm Full board
lite_board = false;
// raise if the snaps print tight
snap_clearance = 0;     // [0:0.01:0.2]

/* [Pot] */
// usable depth of each rod compartment
bore_depth = 150;       // [20:5:300]
// number of compartments across the width
compartments = 4;       // [1:8]
// front and side wall thickness
wall = 2.0;
// thickness of the walls between compartments
divider = 1.6;
// back plate thickness, this is what the snaps hang off
back_plate = 3.0;
// thickness under the compartments
floor_thickness = 2.0;
// compartment size front to back. 0 makes them square
compartment_depth = 0;
// 45 degree lead in at the mouth of each compartment
mouth_chamfer = 1.0;

/* [Labels] */
// one label per compartment, "" for none. Extras are ignored
labels = ["0.5", "0.8", "1.0", "1.5"];
label_size = 5;
label_depth = 0.6;
// distance from the top of the pot down to the middle of the label
label_inset = 10;

/* [Output] */
// assembled shows it as mounted, print lays it front face down on the bed
layout = "assembled";   // [assembled, print]
// draw a piece of board behind it, preview only
show_board = false;

/* [Hidden] */
$fn = 64;
EPS = 0.01;

// ---------------------------------------------------------------------------
// Derived dimensions
// ---------------------------------------------------------------------------

pot_w    = og_span(grid_cols);                  // 56 for 2 cells
pot_h    = bore_depth + floor_thickness;        // 152 by default
inner_w  = pot_w - 2 * wall;
comp_w   = (inner_w - (compartments - 1) * divider) / compartments;
comp_d   = compartment_depth > 0 ? compartment_depth : comp_w;
pot_d    = back_plate + comp_d + wall;

// Snap rows sit on the 28 mm grid and need 14 mm of clearance to a plate edge,
// so push them as far apart as the height allows and centre the pair.
snap_span = floor((pot_h - OG_PITCH) / OG_PITCH) * OG_PITCH;
snap_z0   = (pot_h - snap_span) / 2;
snap_zs   = snap_span > 0 ? [snap_z0, pot_h - snap_z0] : [pot_h / 2];
snap_xs   = [ for (c = [0 : grid_cols - 1]) (c - (grid_cols - 1) / 2) * OG_PITCH ];

assert(comp_w > 0, "compartments do not fit across the width, reduce compartments or walls");
assert(pot_h >= OG_PITCH, "pot is too short to carry a snap row");

// ---------------------------------------------------------------------------
// Parts
// ---------------------------------------------------------------------------

// the outer block, before anything is hollowed out
module pot_blank() {
    translate([-pot_w / 2, 0, 0]) cube([pot_w, pot_d, pot_h]);
}

// x position of the low-x edge of compartment i.
// The pot is looked at from +y, where +x runs to the viewer's left, so
// compartment 0 is placed at high x. That way labels[0] is the leftmost
// compartment as you stand in front of it.
function comp_x(i) = inner_w / 2 - (i + 1) * comp_w - i * divider;

/*
 * One compartment void: a square bore with a 45 degree lead in at the mouth so
 * rods drop in without catching.
 */
module compartment_void(i) {
    x = comp_x(i);
    y = back_plate;
    z = floor_thickness;
    h = bore_depth;

    translate([x, y, z]) cube([comp_w, comp_d, h + EPS]);

    if (mouth_chamfer > 0)
        translate([0, 0, z + h - mouth_chamfer])
            hull() {
                translate([x, y, 0]) cube([comp_w, comp_d, EPS]);
                translate([x - mouth_chamfer, y - mouth_chamfer, mouth_chamfer])
                    cube([comp_w + 2 * mouth_chamfer,
                          comp_d + 2 * mouth_chamfer, EPS]);
            }
}

/*
 * Engraved diameter labels on the front face, one per compartment.
 * Engraved rather than raised so they print cleanly with the front face on the
 * bed, which is the orientation this part wants.
 */
module label_voids() {
    for (i = [0 : compartments - 1])
        if (i < len(labels) && labels[i] != "")
            translate([comp_x(i) + comp_w / 2, pot_d + EPS, pot_h - label_inset])
                rotate([90, 0, 0])
                    // looking at the front face means looking down -Y, where +X
                    // runs to the left, so the glyphs need flipping in X to
                    // read the right way round
                    mirror([1, 0, 0])
                        linear_extrude(label_depth + EPS)
                            text(labels[i], size = label_size, halign = "center",
                                 valign = "center");
}

// Places a child at every snap centre, oriented so the library's z = 0 board
// face lands on this model's y = 0 board face.
module at_snap_cells() {
    for (x = snap_xs, z = snap_zs)
        translate([x, 0, z]) rotate([-90, 0, 0]) children();
}

module snaps() {
    at_snap_cells()
        opengrid_snap(lite = lite_board, corner_clearance = snap_clearance);
}

// The cell each snap sits in, for preview and for fit checking.
module board_cells() {
    at_snap_cells()
        translate([-OG_PITCH / 2, -OG_PITCH / 2, 0])
            opengrid_tile(1, 1, lite_board);
}

module rod_holder() {
    union() {
        difference() {
            pot_blank();
            for (i = [0 : compartments - 1]) compartment_void(i);
            label_voids();
        }
        snaps();
    }
}

// ---------------------------------------------------------------------------
// Output
// ---------------------------------------------------------------------------

if (show_board)
    color("silver") board_cells();

if (layout == "print")
    // front face down on the bed, snaps pointing up. Every snap overhang is
    // then 45 degrees or shallower, so no support is needed.
    translate([0, 0, pot_d]) rotate([-90, 0, 0]) rod_holder();
else
    rod_holder();
