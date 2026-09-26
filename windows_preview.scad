// windows_preview.scad -- preview only, not part of the model.
// The bottom of a holder seen from the side, with a few short offcuts standing
// in the compartments to show what the diamond windows are for. The offcuts are drawn
// thicker than real hinge pin rod so they show up in the render.
use <rod_holder.scad>

intersection() {
    rod_holder();
    translate([-20, -10, -1]) cube([40, 50, 58]);   // cut just below the middle of a diamond row
}

// offcuts: [x, y, length], standing on the 2 mm floor
for (r = [[6.3, 20.4, 18], [5.0, 8.3, 35], [7.6, 9.0, 12], [-6.3, 20.4, 48],
          [-5.2, 7.8, 26]])
    color("silver") translate([r[0], r[1], 2]) cylinder(d = 2.5, h = r[2], $fn = 16);
