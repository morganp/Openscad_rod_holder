// mountfit_check.scad -- verification, not part of the model.
// A snap that fits its cell has zero overlap with the board, so exporting this
// intersection should come out as an empty or zero volume solid.
use <rod_holder.scad>

intersection() {
    board_cells();
    rod_holder();
}
