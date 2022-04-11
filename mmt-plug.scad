// mmt-plug.scad: solid pressure-containing bulkhead for motor mount tubes

include <BOSL2/std.scad>

$fn=64;

D = 23.7;  // MMT inside diameter less clearance
h = .25;   // plug height as fraction of diameter
r = D*h;   // rounding radius

difference() {
    cyl(d=D, h=D*h, anchor=BOTTOM);
    up(r/2) cyl(d=D, h=D*h, rounding1=r, anchor=BOTTOM);
}