include <BOSL2/std.scad>
use <../wing-tang.scad>

$fn=64;

wing_tang_l = 20;
wing_tang_w = 10;
wing_screw_d = 3;
wing_screw_l = 12;

sheet_thickness = 1.6;

difference() {
  cube([15, 20, 20], anchor=RIGHT);
  tang_pocket(wing_tang_l, wing_tang_w, sheet_thickness, wing_screw_d, wing_screw_l);
}

// screw-hole side
back(30) tang_pocket(wing_tang_l, wing_tang_w, sheet_thickness, wing_screw_d, wing_screw_l);

// glue side
back(50) tang_pocket(wing_tang_l, wing_tang_w, sheet_thickness);

right(20) wing_tang(wing_tang_l, wing_tang_w, sheet_thickness, wing_screw_d);
