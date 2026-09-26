// section_preview.scad -- cutaway used for the README image.
// Not part of the model, it just slices rod_holder() down the middle of the
// left hand column so the front and back bores, the floor, the diamond windows and the
// snap seating are all visible at once.
use <rod_holder.scad>
// @github: morganp/openscad-opengrid
include <opengrid/opengrid.scad>

difference() {
    rod_holder();
    // remove everything to the viewer's left of the middle of that column
    translate([6.3, -10, -1]) cube([20, 50, 200]);
}
