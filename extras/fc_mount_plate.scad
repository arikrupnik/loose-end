

include <BOSL2/std.scad>

$fn=64;

MOUNTING_L=30.5;  // mounting hole pattern distance on center

// A single M2 nut boss
module m2_nut_boss() {
  diff("cutouts") {
    // nut boss, 7mm on bottom, 6.5 on top, 4mm high
    zcyl(d1=7, d2=6.5, h=4, anchor=BOTTOM) {
      // subtract cutouts from boss
      tag("cutouts") {
        // nuts are 1.5mm tall, plus .1 mm for clearance
        attach(TOP, overlap=1.6) {
          linear_extrude(height=2) {
            // nut recess; nuts are 4mm wide, plus .1mm for clearance
            hexagon(id=4.1);
          }
          // in case screw protrudes below nut; diameter 2mm, plus .1 for clearance
          zcyl(d=2.1, h=6);
        }
      }
    }
  }
}

// Four M2 nut bosses in a square pattern
module m2_nut_bosses(on_center) {
  for(x=[-1,1], y=[-1,1]) {
    translate([x*on_center/2, y*on_center/2, 0]) {
      m2_nut_boss();
    }
  }
}

module fc_mount_plate() {
  cube([50,40,1], anchor=CENTER+TOP);
  m2_nut_bosses(MOUNTING_L);
}

fc_mount_plate();
