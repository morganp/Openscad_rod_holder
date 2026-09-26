/*
 * rod_holder.scad -- openGrid mounted pot for thin steel rods
 *
 * A deep, narrow pot that snaps onto an openGrid board and keeps hinge pin
 * stock sorted by diameter. Sized around 0.5 mm and 0.8 mm steel rod, but every
 * dimension is parametric.
 *
 * Version 2.0.0: one grid cell square, four compartments in a 2 x 2 grid, and
 * a lattice of diamond windows in the outer walls so short offcuts at the
 * bottom can be seen.
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
grid_cols = 1;          // [1:6]
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
bore_depth = 158;       // [20:1:300]
// number of compartments across the width
compartments = 2;       // [1:8]
// number of compartment rows, front to back
compartment_rows = 2;   // [1:4]
// overall depth from the board face to the front face. -1 matches the width,
// so a 1 cell holder is square. 0 sizes it from compartment_depth instead
pot_depth = -1;
// front and side wall thickness
wall = 2.0;
// thickness of the walls between compartments
divider = 1.6;
// back plate thickness, this is what the snaps hang off
back_plate = 3.0;
// thickness under the compartments
floor_thickness = 2.0;
// compartment size front to back, used only when pot_depth = 0. 0 makes them
// square
compartment_depth = 0;
// Lead in at the mouth of each compartment. Clamped so it cannot eat the tops
// of the dividers away, so the effective value may be smaller than this
mouth_chamfer = 1.0;

/* [Windows] */
// diamond cuts a lattice of diamonds through the outer walls, slot a ladder of
// narrow slots per compartment, none leaves the walls solid
window_style = "diamond";  // [diamond, slot, none]
// windows in the side walls
window_sides = true;
// windows in the front wall
window_front = true;
// solid band above the floor before the first window. Keeps the bottom end of
// a standing rod behind a wall, so it cannot slide out of a window
window_start = 4;
// height of the windowed region above window_start. 0 runs the windows up to
// just below the labels
window_zone = 0;

// -- diamond style --
// Diagonal of each diamond. 0 makes them as big as the faces allow, so the
// diamond on a face spans every compartment column behind it. Clamped to that
// size if set larger
diamond_size = 0;
// narrowest solid web left between neighbouring diamonds, and between the
// diamonds and the back plate or labels
diamond_web = 2.4;
// diamonds centred on the two front vertical edges, wrapping round the corner
// so half shows on the front and half on the side
diamond_corners = true;

// -- slot style --
// slot width. Clamped to the flat part of the compartment wall
window_width = 4;
// height of each slot
window_height = 10;
// solid rung left between slots
window_bar = 4;

/* [Rounding] */
// radius on the two front vertical edges, the ones you actually grip
outer_round = 3.0;
// radius on the two back vertical edges. Kept small: the back face has to stay
// flat out to the edge of the snaps, which reach 12.4 mm from each snap centre
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
// outer face, none leaves it plain. Front row labels go on the front face,
// rows behind it are labelled on the side wall they touch
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
// one label per compartment, "" for none. Front row left to right as mounted,
// then the next row back, left to right. Extras are ignored
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
pot_w    = og_span(grid_cols) - tile_clearance;         // 27.6 for 1 cell
grid_h   = ceil((bore_depth + floor_thickness) / OG_PITCH) * OG_PITCH;
pot_h    = height_mode == "grid" ? grid_h - tile_clearance
                                 : bore_depth + floor_thickness;
bore     = pot_h - floor_thickness;             // 165.6 in grid mode
inner_w  = pot_w - 2 * wall;
comp_w   = (inner_w - (compartments - 1) * divider) / compartments;

// Depth either comes from the compartments (pot_depth = 0) or is fixed and the
// compartments share out whatever is left behind the front wall.
rows_gaps = (compartment_rows - 1) * divider;
pot_d    = pot_depth < 0 ? pot_w
         : pot_depth > 0 ? pot_depth
         : back_plate + compartment_rows * (compartment_depth > 0 ? compartment_depth : comp_w)
           + rows_gaps + wall;
comp_d   = (pot_d - back_plate - wall - rows_gaps) / compartment_rows;

// The mouth lead in grows every compartment sideways, so two neighbours eat
// into the divider between them from both sides. Clamp it so the top of a
// divider keeps at least divider_top_min of material rather than coming to a
// knife edge, or vanishing entirely when 2 * mouth_chamfer exceeds divider.
divider_top_min = 0.4;
mouth = compartments > 1 || compartment_rows > 1
        ? min(mouth_chamfer, max(0, (divider - divider_top_min) / 2))
        : mouth_chamfer;

// Snap rows sit on the 28 mm grid and need 14 mm of clearance to a plate edge,
// so push them as far apart as the height allows and centre the pair.
snap_span = floor((pot_h - OG_PITCH) / OG_PITCH) * OG_PITCH;
snap_z0   = (pot_h - snap_span) / 2;
snap_zs   = snap_span > 0 ? [snap_z0, pot_h - snap_z0] : [pot_h / 2];
snap_xs   = [ for (c = [0 : grid_cols - 1]) (c - (grid_cols - 1) / 2) * OG_PITCH ];

assert(comp_w > 0, "compartments do not fit across the width, reduce compartments or walls");
assert(comp_d > 2 * inner_round, "compartment rows do not fit in the depth, raise pot_depth or reduce compartment_rows");
assert(pot_h >= OG_PITCH, "pot is too short to carry a snap row");
assert(label_mode != "card" || wall > card_lip + card_thickness,
       "wall is too thin for a card pocket, raise wall");
assert(back_round <= pot_w / 2 - (OG_SNAP_FLAT / 2 + max(snap_xs)),
       "back_round is too big, it would undercut the snaps");
assert(inner_round < comp_w / 2 && inner_round < comp_d / 2,
       "inner_round is too big for the compartment size");
assert(outer_round + back_round < pot_d, "outer_round and back_round do not fit in the pot depth");

// ---------------------------------------------------------------------------
// Compartment layout
// ---------------------------------------------------------------------------

// x position of the low-x edge of compartment column i.
// The pot is looked at from +y, where +x runs to the viewer's left, so
// column 0 is placed at high x. That way labels[0] is the leftmost
// compartment as you stand in front of it.
function comp_x(i) = inner_w / 2 - (i + 1) * comp_w - i * divider;

// y position of the back edge of compartment row j. Row 0 is the front row.
function comp_y(j) = pot_d - wall - (j + 1) * comp_d - j * divider;

// Which side walls a compartment touches: +1 is the +x wall (viewer's left),
// -1 the -x wall. A single column touches both.
function comp_sides(i) = concat(i == 0 ? [1] : [], i == compartments - 1 ? [-1] : []);

// Rows behind the front row are labelled on a side wall. Only compartments that
// touch a side can be, and a single column uses the +x wall.
function side_label_side(i, j) =
    j == 0 ? 0 : len(comp_sides(i)) > 0 ? comp_sides(i)[0] : 0;

function label_text(i, j) =
    let (n = j * compartments + i) n < len(labels) ? labels[n] : "";

unlabelled = [ for (j = [1 : max(1, compartment_rows - 1)], i = [0 : compartments - 1])
               if (compartment_rows > 1 && side_label_side(i, j) == 0) [i, j] ];
if (label_mode != "none" && len(unlabelled) > 0)
    echo(str("NOTE: compartments ", unlabelled,
             " touch no outer wall and are not labelled"));

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

// cross section of one compartment, corners rounded by inner_round
module comp_profile(i, j) {
    r = inner_round;
    if (r > 0)
        offset(r = r)
            translate([comp_x(i) + r, comp_y(j) + r])
                square([comp_w - 2 * r, comp_d - 2 * r]);
    else
        translate([comp_x(i), comp_y(j)]) square([comp_w, comp_d]);
}

/*
 * One compartment void: a square bore with rounded inside corners, a fillet
 * where the walls meet the floor, and a lead in at the mouth so rods drop in
 * without catching.
 */
module compartment_void(i, j) {
    z = floor_thickness;
    z_top = z + bore;

    translate([0, 0, z])
        rounded_extrude(bore + EPS, r_bottom = floor_round) comp_profile(i, j);

    // The lead in opens out into the dividers and the back plate, but not into
    // an outer wall that carries a card pocket: the front wall for the front
    // row, and the labelled side wall for rows behind it.
    side = label_mode == "card" ? side_label_side(i, j) : 0;
    x_lo = side == -1 ? -inner_w / 2 : -pot_w;
    x_hi = side ==  1 ?  inner_w / 2 :  pot_w;
    y_hi = j == 0 ? comp_y(0) + comp_d : pot_d;
    if (mouth > 0)
        intersection() {
            hull() {
                translate([0, 0, z_top - mouth])
                    linear_extrude(EPS) comp_profile(i, j);
                translate([0, 0, z_top - EPS])
                    linear_extrude(EPS) offset(r = mouth) comp_profile(i, j);
            }
            translate([x_lo, -pot_d, z_top - mouth - 1])
                cube([x_hi - x_lo, pot_d + y_hi, mouth + 2]);
        }
}

/*
 * Places a child on an outer face, oriented so its x axis runs left to right
 * and its y axis up as you look at that face, and its z axis points out of the
 * face. face is "front", or a side wall as +1 / -1.
 */
module on_face(face, u, z) {
    if (face == "front")
        translate([u, pot_d, z]) multmatrix([[-1, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0]]) children();
    else if (face == 1)
        translate([pot_w / 2, u, z]) multmatrix([[0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0]]) children();
    else
        translate([-pot_w / 2, u, z]) multmatrix([[0, 0, -1, 0], [-1, 0, 0, 0], [0, 1, 0, 0]]) children();
}

// centre of compartment (i, j) along the face it is labelled or windowed on
function face_u(face, i, j) =
    face == "front" ? comp_x(i) + comp_w / 2 : comp_y(j) + comp_d / 2;

// width of compartment (i, j) along that face
function face_span(face) = face == "front" ? comp_w : comp_d;

// every labelled compartment as [i, j, face]
label_slots = concat(
    [ for (i = [0 : compartments - 1]) [i, 0, "front"] ],
    [ for (j = [1 : max(1, compartment_rows - 1)], i = [0 : compartments - 1])
        if (compartment_rows > 1 && side_label_side(i, j) != 0) [i, j, side_label_side(i, j)] ]);

/*
 * Engraved diameter labels, one per compartment.
 * Engraved rather than raised so they print cleanly with the front face on the
 * bed, which is the orientation this part wants.
 */
module engraved_label_voids() {
    for (s = label_slots) {
        t = label_text(s[0], s[1]);
        if (t != "")
            on_face(s[2], face_u(s[2], s[0], s[1]), pot_h - label_inset)
                translate([0, 0, -label_depth])
                    linear_extrude(label_depth + EPS)
                        text(t, size = label_size, halign = "center", valign = "center");
    }
}

// Card pocket sizes. The card is as wide as the compartment allows, and the
// window in front of it is inset by card_lip_margin at the sides and bottom.
card_z = pot_h - card_height;                   // bottom of the card pocket
function card_w(face)   = face_span(face) + divider - 2 * card_side_gap;
function window_w(face) = card_w(face) - 2 * card_lip_margin;

/*
 * A pocket that holds a slip of card, one per compartment.
 *
 * The card sits in a slot cut into the outer wall and is held by a thin frame
 * with a window in it. The pocket is open at the top of the pot, so cards drop
 * in from above and can be pulled straight back out.
 *
 * Printed front face down, a front frame is the first layer and the roof of the
 * pocket bridges the window, which is a short flat bridge between two edges.
 * A side pocket stands vertical and its window roof is a bridge of the same
 * length.
 */
module card_slot_void(i, j, face) {
    on_face(face, face_u(face, i, j), card_z) {
        // the slot the card lives in, run past the top face so it is open
        translate([-card_w(face) / 2, 0, -card_lip - card_thickness])
            cube([card_w(face), card_height + EPS, card_thickness]);

        // the window you read the card through, open at the top for the same reason
        translate([-window_w(face) / 2, card_lip_margin, -card_lip])
            cube([window_w(face), card_height - card_lip_margin + EPS, card_lip + EPS]);
    }
}

module label_voids() {
    if (label_mode == "engraved")
        engraved_label_voids();
    else if (label_mode == "card")
        for (s = label_slots) card_slot_void(s[0], s[1], s[2]);
}

// ---------------------------------------------------------------------------
// Windows
// ---------------------------------------------------------------------------

// Solid left between the windows and the labels above them, or the rounded top
// edge and the mouth lead in when there are none.
window_gap = window_style == "diamond" ? diamond_web : window_bar;
window_top_limit =
    label_mode == "card"     ? card_z - window_gap :
    label_mode == "engraved" ? pot_h - label_inset - label_size / 2 - window_gap :
                               pot_h - max(end_round, mouth) - window_gap;
window_z0  = floor_thickness + window_start;
window_top = window_zone > 0 ? min(window_top_limit, window_z0 + window_zone)
                             : window_top_limit;

// -- slot style --

window_count = max(0, floor((window_top - window_z0 + window_bar)
                            / (window_height + window_bar)));

// Slots sit on the flat part of the inner wall, clear of the rounded corners.
function window_w_on(face) = min(window_width, face_span(face) - 2 * inner_round);

// every slotted compartment as [i, j, face]
window_slots = concat(
    window_front ? [ for (i = [0 : compartments - 1]) [i, 0, "front"] ] : [],
    window_sides ? [ for (j = [0 : compartment_rows - 1], i = [0 : compartments - 1],
                          s = comp_sides(i)) [i, j, s] ] : []);

/*
 * A ladder of slots through the outer wall of one compartment.
 *
 * The slots cut the outer wall only, never a divider, so rods cannot cross
 * between compartments. The first slot starts window_start above the floor:
 * a rod standing on the floor keeps its bottom end behind solid wall and has to
 * be lifted before it could lean out, so gravity holds it in.
 */
module slot_voids(i, j, face) {
    w = window_w_on(face);
    if (w > 0)
        for (k = [0 : window_count - 1])
            on_face(face, face_u(face, i, j),
                    window_z0 + k * (window_height + window_bar))
                translate([-w / 2, 0, -wall - 1])
                    cube([w, window_height, wall + 2]);
}

// -- diamond style --

/*
 * The diamonds form a lattice of alternating rows up the pot.
 *
 * Row A puts one diamond in the middle of each grid cell on the front face, and
 * one in the middle of each side face, between the back plate and the front
 * wall. Row B sits half a pitch higher and puts a diamond on every cell
 * boundary of the front face: the two at the ends are centred on the front
 * vertical edges and wrap round the corner onto the sides.
 *
 * All diamonds are squares turned 45 degrees, so every edge is 45 degrees in
 * the print orientation too and the holes in the vertical side walls need no
 * support. Neighbouring diamonds in the lattice then face each other across a
 * diagonal web, rows of the same kind across a vertical web between tips.
 */

// front face: cell centres for row A, cell boundaries for row B
dia_front_a  = snap_xs;
dia_front_b  = [ for (c = [0 : grid_cols]) (c - grid_cols / 2) * OG_PITCH ];
// side face: row A centred between the back plate and the front wall
dia_side_u   = (back_plate + pot_d - wall) / 2;

// horizontal distance from a row A centre to the nearest row B centre, along
// each face. The two front edges are at +-pot_w / 2, not on the grid lines
dia_dh_front = min(OG_PITCH / 2, pot_w / 2 - max(snap_xs));
dia_dh_side  = pot_d - dia_side_u;
dia_dh = min(window_front ? dia_dh_front : pot_w,
             window_sides ? dia_dh_side : pot_w);

// Largest half diagonal each face allows. A front diamond must stay inside the
// cell and clear of the side walls, a side diamond clear of the back plate.
dia_max_front = min(OG_PITCH / 2, inner_w / 2 - max(snap_xs)) - diamond_web / 2;
dia_max_side  = dia_side_u - back_plate - diamond_web / 2;
// Beyond this the rows would have to spread so far apart that bigger diamonds
// just leave bigger webs, see dia_pitch below.
dia_max_lattice = dia_dh - sqrt(2) * diamond_web + diamond_web / 2;
// A corner diamond must leave the back plate and the far side of the front
// face alone.
dia_max_corner = min(pot_d - back_plate, pot_w / 2) - diamond_web / 2;
dia_auto = min(window_front    ? dia_max_front  : pot_w,
               window_sides    ? dia_max_side   : pot_w,
               diamond_corners ? dia_max_corner : pot_w,
               dia_max_lattice);
dia_a = diamond_size > 0 ? min(diamond_size / 2, dia_auto) : dia_auto;
if (window_style == "diamond" && diamond_size > 0 && diamond_size / 2 > dia_auto)
    echo(str("NOTE: diamond_size clamped to ", 2 * dia_auto, " mm to fit the faces"));

// Vertical offset between an A row and the next B row. Rows of the same kind
// are two offsets apart and need diamond_web between their tips; an A and a B
// diamond need diamond_web across the diagonal between their facing edges.
dia_step = max(dia_a + diamond_web / 2,
               2 * dia_a + sqrt(2) * diamond_web - dia_dh);
dia_rows = dia_a > 0
           ? max(0, floor((window_top - window_z0 - 2 * dia_a) / dia_step) + 1)
           : 0;
// centre height of row k. Row 0 is an A row
function dia_z(k) = window_z0 + dia_a + k * dia_step;

assert(window_style != "diamond" || diamond_web >= 1.6,
       "diamond_web below 1.6 mm leaves webs too thin to print reliably");

// a diamond of half diagonal a, cut through a wall depth d thick
module diamond_prism(a, d) {
    translate([0, 0, -d])
        linear_extrude(d + 1)
            polygon([[a, 0], [0, a], [-a, 0], [0, -a]]);
}

// axis aligned box between two opposite corners, in any order
module box_between(p0, p1) {
    translate([min(p0[0], p1[0]), min(p0[1], p1[1]), min(p0[2], p1[2])])
        cube([abs(p1[0] - p0[0]), abs(p1[1] - p0[1]), abs(p1[2] - p0[2])]);
}

/*
 * A diamond wrapped round the front vertical edge on side sx.
 *
 * Cut as a single prism running in along the 45 degree bisector of the corner.
 * Its section is a diamond narrowed by sqrt(2) across the bisector, so where it
 * meets the front and side faces each shows a half diamond with the same 45
 * degree edges as the rest of the lattice. Because it is one cut rather than a
 * half diamond pushed straight into each face, the outline runs continuously
 * over the rounded corner instead of leaving pinched nubs where the webs cross
 * the corner edge.
 *
 * The prism is trimmed to the two outer walls, plus the rounded inside corner
 * of the compartment behind, so it never reaches the dividers or the back plate.
 */
module corner_diamond(sx, z) {
    a    = dia_a;
    span = 2 * a + 2;   // long enough to clear both walls along the bisector
    top  = z + a + 1;
    bot  = z - a - 1;
    intersection() {
        translate([sx * pot_w / 2, pot_d, z])
            rotate([0, 0, -sx * 45])
                translate([0, 2, 0])
                    rotate([90, 0, 0])
                        linear_extrude(span + 2)
                            polygon([[a / sqrt(2), 0], [0, a], [-a / sqrt(2), 0], [0, -a]]);
        union() {
            // front wall
            box_between([sx * EPS, pot_d - wall - EPS, bot],
                        [sx * (pot_w / 2 + 1), pot_d + 1, top]);
            // side wall, clear of the back plate
            box_between([sx * (pot_w / 2 - wall - EPS), back_plate + EPS, bot],
                        [sx * (pot_w / 2 + 1), pot_d + 1, top]);
            // the compartment's rounded inside corner, which would otherwise be
            // left as a thin free standing sliver in the middle of the opening
            box_between([sx * (inner_w / 2 - inner_round - EPS), pot_d - wall - inner_round - EPS, bot],
                        [sx * (pot_w / 2 + 1), pot_d + 1, top]);
        }
    }
}

module diamond_voids() {
    for (k = [0 : dia_rows - 1]) {
        z = dia_z(k);
        if (k % 2 == 0) {
            if (window_front)
                for (x = dia_front_a) on_face("front", x, z) diamond_prism(dia_a, wall + EPS);
            if (window_sides)
                for (s = [1, -1]) on_face(s, dia_side_u, z) diamond_prism(dia_a, wall + EPS);
        } else {
            if (window_front)
                for (x = dia_front_b)
                    if (abs(x) < pot_w / 2 - EPS)
                        on_face("front", x, z) diamond_prism(dia_a, wall + EPS);
            if (diamond_corners)
                for (s = [1, -1]) corner_diamond(s, z);
        }
    }
}

module windows() {
    if (window_style == "slot" && window_count > 0)
        for (s = window_slots) slot_voids(s[0], s[1], s[2]);
    else if (window_style == "diamond" && dia_rows > 0)
        diamond_voids();
}

// ---------------------------------------------------------------------------
// Snaps and assembly
// ---------------------------------------------------------------------------

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
            for (j = [0 : compartment_rows - 1], i = [0 : compartments - 1])
                compartment_void(i, j);
            label_voids();
            windows();
        }
        snaps();
    }
}

// ---------------------------------------------------------------------------
// Output
// ---------------------------------------------------------------------------

echo(str("rod_holder: ", pot_w, " x ", pot_d, " x ", pot_h, " mm, compartments ",
         comp_w, " x ", comp_d, " x ", bore,
         window_style == "diamond"
            ? str(", ", dia_rows, " diamond rows, ", 2 * dia_a, " mm diamonds, pitch ",
                  2 * dia_step)
         : window_style == "slot" ? str(", ", window_count, " slots per column") : ""));

if (show_board)
    color("silver") board_cells();

if (layout == "print")
    // front face down on the bed, snaps pointing up. Every snap overhang is
    // then 45 degrees or shallower, so no support is needed.
    translate([0, 0, pot_d]) rotate([-90, 0, 0]) rod_holder();
else
    rod_holder();
