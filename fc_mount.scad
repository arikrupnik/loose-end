// fc_mount.scad: mount plate for 30.5mm flight controllers, specifically Matek Wing stacks

include <BOSL2/std.scad>

$fn=64;

MOUNTING_L=30.5;  // mounting hole pattern distance on center

module fc_mount() {
    for(x=[-1,1], y=[-1,1]) {
        translate([x*MOUNTING_L/2, y*MOUNTING_L/2, 0]) {
            zcyl(0.7, d=3.1, anchor=CENTER+TOP);                // recess for M3 standoff
            zcyl(2, d=2, anchor=CENTER+TOP);                    // hole for screw
            down(1) zcyl(0.6, d2=2, d1=2.8, anchor=CENTER+TOP); // chamfer for screwhead
            down(1.6) zcyl(100, d=2.8, anchor=CENTER+TOP);      // hole for screwhead
        }
    }
}
