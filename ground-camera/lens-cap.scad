
include <BOSL2/std.scad>

$fn=64;

difference() {
  zcyl(d=33, h=3, anchor=BOTTOM);
  zcyl(d=32, h=4, anchor=BOTTOM);
}
zcyl(d=38, h=1, anchor=TOP);
