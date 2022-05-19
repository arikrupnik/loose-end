include <BOSL2/std.scad>
use <../wing-tang.scad>

$fn=64;

wing_tang_l = 20;
wing_tang_w = 10;
wing_screw_d = 3;
wing_screw_l = 12;

sheet_thickness = 1.6;

xrot(90) difference() {
  cube([15, 20, 20], anchor=RIGHT);
  tang_pocket(wing_tang_l, wing_tang_w, sheet_thickness, wing_screw_d, wing_screw_l);
}

right(20) wing_tang(wing_tang_l, wing_tang_w, sheet_thickness, wing_screw_d);
