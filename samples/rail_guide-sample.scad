
include <BOSL2/std.scad>
use <../rail_guides.scad>

$fn=64;

FUSELAGE_D=38;

// fuselage
ycyl(d=FUSELAGE_D, l=400, anchor=FWD);
// nose conde
yscale(4) sphere(d=FUSELAGE_D);

// fwd guide
back(200) up(FUSELAGE_D/2) rail_guide1010(20);

// aft guide
back(380) up(FUSELAGE_D/2) rail_guide1010(20);
