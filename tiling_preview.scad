// tiling_preview.scad -- preview only, not part of the model.
// Four holders in a 2 x 2 block on a shared board, to show that the outer size
// is a whole number of grid cells and everything still lands on the 28 mm grid.
use <rod_holder.scad>
// @github: morganp/openscad-opengrid
include <opengrid/opengrid.scad>

x_pitch = og_span(1);    // 28, one cell per holder at the defaults
z_pitch = og_span(6);    // 168, six cells per holder in grid height mode

for (i = [0, 1], j = [0, 1])
    translate([(i - 0.5) * x_pitch, 0, j * z_pitch]) {
        color(i == j ? "orangered" : "steelblue") rod_holder();
        color("silver") board_cells();
    }
