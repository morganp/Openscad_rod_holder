// section_preview.scad -- cutaway used for the README image.
// Not part of the model, it just slices rod_holder() in half so the compartment
// bores, the floor and the snap seating are all visible at once.
use <rod_holder.scad>
include <opengrid/opengrid.scad>

difference() {
    rod_holder();
    // remove everything in front of the middle of the compartments
    translate([-40, 9, -1]) cube([80, 40, 200]);
}
