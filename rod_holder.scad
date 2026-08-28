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
 *
 * Holders tile. Width is a whole number of grid cells less tile_clearance, and
 * with height_mode = "grid" the height is too, so a row or a column of these
 * sits side by side on the board with every snap still on the 28 mm grid.
 */

include <opengrid/opengrid.scad>

/* [openGrid] */
// how many grid cells wide the holder is
grid_cols = 2;          // [1:6]
// true for a 4.0 mm Lite board, false for a 6.8 mm Full board
lite_board = false;
// raise if the snaps print tight
snap_clearance = 0;     // [0:0.01:0.2]
// gap left between neighbouring holders so they do not rub. Taken off the
// outside of the pot, the snaps stay on the grid
tile_clearance = 0.4;   // [0:0.1:2]
// exact makes the pot bore_depth + floor tall. grid rounds the height up to a
// whole number of cells so holders also tile vertically, deepening the bore
height_mode = "grid";   // [exact, grid]

/* [Pot] */
// usable depth of each rod compartment. With height_mode = "grid" this is a
// minimum and the bore gets deeper to reach the next whole cell
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
// Lead in at the mouth of each compartment. Clamped so it cannot eat the tops
// of the dividers away, so the effective value may be smaller than this
mouth_chamfer = 1.0;

/* [Rounding] */
// radius on the two front vertical edges, the ones you actually grip
outer_round = 3.0;
// radius on the two back vertical edges. Kept small: the back face has to stay
// flat out to the edge of the snaps, which reach 26.4 mm from the centre
back_round = 1.2;
// radius on the top and bottom outer edges
end_round = 2.0;
// 45 degree relief around the front face. The front face is the bed when
// printing, and a fillet tangent to the bed starts as a near horizontal
// overhang, so the rounding is cut back to 45 degrees where it meets that face.
// Set to 0 for an unbroken round, and print with support
front_chamfer = 1.6;
// radius on the inside vertical corners of each compartment
inner_round = 2.0;
// radius where the compartment walls meet the floor
floor_round = 2.0;

/* [Labels] */
// card holds a slip of card behind a window, engraved cuts the text into the
// front face, none leaves it plain
label_mode = "card";    // [card, engraved, none]

// -- card mode --
// height of the card pocket. Width follows the compartment
card_height = 12;
// thickness of card the pocket takes. 0.7 suits folded paper or 300 gsm card
card_thickness = 0.7;
// front frame that stops the card falling out
card_lip = 0.6;
// how far that frame overlaps the card at the sides and bottom
card_lip_margin = 1.0;
// gap each side of the card. Twice this is the rib left between neighbouring
// pockets, so do not take it below about half the divider thickness
card_side_gap = 0.8;

// -- engraved mode --
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

// Outer size is a whole number of cells less the tiling gap, so neighbouring
// holders leave tile_clearance between them while their snaps stay 28 mm apart.
pot_w    = og_span(grid_cols) - tile_clearance;         // 55.6 for 2 cells
grid_h   = ceil((bore_depth + floor_thickness) / OG_PITCH) * OG_PITCH;
pot_h    = height_mode == "grid" ? grid_h - tile_clearance
                                 : bore_depth + floor_thickness;
bore     = pot_h - floor_thickness;             // 165.6 in grid mode
inner_w  = pot_w - 2 * wall;
comp_w   = (inner_w - (compartments - 1) * divider) / compartments;
comp_d   = compartment_depth > 0 ? compartment_depth : comp_w;
pot_d    = back_plate + comp_d + wall;

// The mouth lead in grows every compartment sideways, so two neighbours eat
// into the divider between them from both sides. Clamp it so the top of a
// divider keeps at least divider_top_min of material rather than coming to a
// knife edge, or vanishing entirely when 2 * mouth_chamfer exceeds divider.
divider_top_min = 0.4;
mouth = compartments > 1
        ? min(mouth_chamfer, max(0, (divider - divider_top_min) / 2))
        : mouth_chamfer;

// Snap rows sit on the 28 mm grid and need 14 mm of clearance to a plate edge,
// so push them as far apart as the height allows and centre the pair.
snap_span = floor((pot_h - OG_PITCH) / OG_PITCH) * OG_PITCH;
snap_z0   = (pot_h - snap_span) / 2;
snap_zs   = snap_span > 0 ? [snap_z0, pot_h - snap_z0] : [pot_h / 2];
snap_xs   = [ for (c = [0 : grid_cols - 1]) (c - (grid_cols - 1) / 2) * OG_PITCH ];

assert(comp_w > 0, "compartments do not fit across the width, reduce compartments or walls");
assert(pot_h >= OG_PITCH, "pot is too short to carry a snap row");
assert(label_mode != "card" || wall > card_lip + card_thickness,
       "front wall is too thin for a card pocket, raise wall");
assert(back_round <= pot_w / 2 - (OG_SNAP_FLAT / 2 + max(snap_xs)),
       "back_round is too big, it would undercut the snaps");
assert(inner_round < comp_w / 2 && inner_round < comp_d / 2,
       "inner_round is too big for the compartment size");
assert(outer_round + back_round < pot_d, "outer_round and back_round do not fit in the pot depth");

// ---------------------------------------------------------------------------
// Parts
// ---------------------------------------------------------------------------

/*
 * rounded_extrude -- extrude a 2D profile with its top and bottom edges rolled
 * over into a fillet.
 *
 * The fillet is made by lofting the profile through a quarter circle of inset
 * values: at the very end the profile is pulled in by r, and r away from the
 * end it is at full size. Both profiles used here are convex, so each hulled
 * slice is an exact loft.
 *
 * Used for the outside of the pot, and on the compartment voids, where an inset
 * void leaves a concave fillet in the solid.
 */
module rounded_extrude(h, r_bottom = 0, r_top = 0, steps = 8) {
    if (h - r_bottom - r_top > 0)
        translate([0, 0, r_bottom])
            linear_extrude(h - r_bottom - r_top) children();

    // z = r(1 - cos a) and inset = r(1 - sin a) sweeps a quarter circle as a
    // runs from 0 at the end face to 90 where the profile reaches full size
    if (r_bottom > 0)
        for (i = [0 : steps - 1]) {
            a0 = 90 * i / steps;
            a1 = 90 * (i + 1) / steps;
            hull() {
                translate([0, 0, r_bottom * (1 - cos(a0))])
                    linear_extrude(EPS) offset(r = -r_bottom * (1 - sin(a0))) children();
                translate([0, 0, r_bottom * (1 - cos(a1)) - EPS])
                    linear_extrude(EPS) offset(r = -r_bottom * (1 - sin(a1))) children();
            }
        }

    if (r_top > 0)
        for (i = [0 : steps - 1]) {
            a0 = 90 * i / steps;
            a1 = 90 * (i + 1) / steps;
            hull() {
                translate([0, 0, h - r_top * (1 - cos(a0)) - EPS])
                    linear_extrude(EPS) offset(r = -r_top * (1 - sin(a0))) children();
                translate([0, 0, h - r_top * (1 - cos(a1))])
                    linear_extrude(EPS) offset(r = -r_top * (1 - sin(a1))) children();
            }
        }
}

/*
 * The pot's cross section: a rectangle with the two front corners rounded by
 * outer_round and the two back corners by back_round.
 *
 * The two radii are separate because the back face has to stay flat right out
 * to the edge of the snaps, so it can only be softened a little, while the
 * front edges are the ones in your hand and can be rounded properly.
 */
module pot_profile() {
    hull() {
        for (sx = [-1, 1]) {
            translate([sx * (pot_w / 2 - back_round), back_round])
                circle(r = back_round, $fn = 32);
            translate([sx * (pot_w / 2 - outer_round), pot_d - outer_round])
                circle(r = outer_round, $fn = 32);
        }
    }
}

/*
 * Everything at or behind the front face, with a 45 degree relief running round
 * that face.
 *
 * Intersecting the pot with this turns the fillets where they run into the
 * front face into 45 degree chamfers. That matters because the front face is
 * the bed when printing: a fillet tangent to the bed leaves the first layers as
 * a near horizontal overhang, while 45 degrees prints cleanly. It catches the
 * side edges and the top and bottom edges in one operation.
 */
module front_relief() {
    c = front_chamfer;
    if (c > 0)
        hull() {
            translate([-pot_w, -og_snap_depth(lite_board) - 1, 0])
                cube([2 * pot_w, pot_d - c + og_snap_depth(lite_board) + 1, pot_h]);
            translate([-(pot_w / 2 - c), pot_d - c, c])
                cube([pot_w - 2 * c, c, pot_h - 2 * c]);
        }
    else
        translate([-pot_w, -og_snap_depth(lite_board) - 1, 0])
            cube([2 * pot_w, pot_d + og_snap_depth(lite_board) + 1, pot_h]);
}

// the outer block, before anything is hollowed out
module pot_blank() {
    intersection() {
        rounded_extrude(pot_h, r_bottom = end_round, r_top = end_round)
            pot_profile();
        front_relief();
    }
}

// x position of the low-x edge of compartment i.
// The pot is looked at from +y, where +x runs to the viewer's left, so
// compartment 0 is placed at high x. That way labels[0] is the leftmost
// compartment as you stand in front of it.
function comp_x(i) = inner_w / 2 - (i + 1) * comp_w - i * divider;

// cross section of one compartment, corners rounded by inner_round
module comp_profile(i) {
    r = inner_round;
    if (r > 0)
        offset(r = r)
            translate([comp_x(i) + r, back_plate + r])
                square([comp_w - 2 * r, comp_d - 2 * r]);
    else
        translate([comp_x(i), back_plate]) square([comp_w, comp_d]);
}

/*
 * One compartment void: a square bore with rounded inside corners, a fillet
 * where the walls meet the floor, and a lead in at the mouth so rods drop in
 * without catching.
 */
module compartment_void(i) {
    z = floor_thickness;
    z_top = z + bore;

    translate([0, 0, z])
        rounded_extrude(bore + EPS, r_bottom = floor_round) comp_profile(i);

    // The lead in opens out sideways and towards the back, but not towards the
    // front: the front wall has to stay thick enough for the card pocket.
    if (mouth > 0)
        intersection() {
            hull() {
                translate([0, 0, z_top - mouth])
                    linear_extrude(EPS) comp_profile(i);
                translate([0, 0, z_top - EPS])
                    linear_extrude(EPS) offset(r = mouth) comp_profile(i);
            }
            translate([-pot_w, -pot_d, z_top - mouth - 1])
                cube([2 * pot_w, pot_d + back_plate + comp_d, mouth + 2]);
        }
}

/*
 * Engraved diameter labels on the front face, one per compartment.
 * Engraved rather than raised so they print cleanly with the front face on the
 * bed, which is the orientation this part wants.
 */
module engraved_label_voids() {
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

// Card pocket sizes. The card is as wide as the compartment allows, and the
// window in front of it is inset by card_lip_margin at the sides and bottom.
card_w   = comp_w + divider - 2 * card_side_gap;
window_w = card_w - 2 * card_lip_margin;
card_y   = pot_d - card_lip - card_thickness;   // back of the card pocket
card_z   = pot_h - card_height;                 // bottom of the card pocket

/*
 * A pocket that holds a slip of card, one per compartment.
 *
 * The card sits in a slot cut into the front wall and is held by a thin frame
 * with a window in it. The pocket is open at the top of the pot, so cards drop
 * in from above and can be pulled straight back out.
 *
 * Printed front face down, the frame is the first layer and the roof of the
 * pocket bridges the window, which is a short flat bridge between two edges.
 */
module card_slot_void(i) {
    cx = comp_x(i) + comp_w / 2;

    // the slot the card lives in, run past the top face so it is open
    translate([cx - card_w / 2, card_y, card_z])
        cube([card_w, card_thickness, card_height + EPS]);

    // the window you read the card through, open at the top for the same reason
    translate([cx - window_w / 2, pot_d - card_lip, card_z + card_lip_margin])
        cube([window_w, card_lip + EPS, card_height - card_lip_margin + EPS]);
}

module label_voids() {
    if (label_mode == "engraved")
        engraved_label_voids();
    else if (label_mode == "card")
        for (i = [0 : compartments - 1]) card_slot_void(i);
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
