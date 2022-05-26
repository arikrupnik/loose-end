include <BOSL2/std.scad>

EXTRUSION_W = is_undef(EXTRUSION_W) ? 0.45 : EXTRUSION_W;

// length is the dimension that goes into mating parts
module wing_tang(length, width, thickness, diameter, gap=0) {
  difference() {
    cuboid([length+gap, width+gap, thickness+gap], rounding=length/10, edges="Z");
    // holes only when rendering tangs; when clearing pockets for
    // tangs (gap>0), clear a complete hull
    if(gap == 0)
      xflip_copy() left(length/4) zcyl(d=diameter, l=thickness+EPSILON);
  }
}

module tang_pocket(length, width, thickness, screw_d, screw_l) {
  screw_head_d = screw_d*2;
  screw_tap_d = screw_d*.85;
  
  // tang cutout
  tang_gap = .3; // .2 tight .3 loose for PLA tangs
  wing_tang(length, width, thickness, screw_d, tang_gap);

  // screw holes and screw blocks
  left(length/4) {
    // screw hole
    zcyl(d=screw_tap_d, l=screw_l);
    // screw head hole
    up(screw_l/2-EPSILON) zcyl(d=screw_head_d, l=100, anchor=BOTTOM);
    // screw hole ribs
    rib_step = .7;
    rib_gap = .2;
    for(z=[thickness+tang_gap : rib_step : screw_l/2])
      zflip_copy()
        up(z)
          left(EXTRUSION_W)
            cube([length/2-EXTRUSION_W*3, width+EXTRUSION_W*2, rib_gap], anchor=CENTER);
  }
}

tang_pocket(20, 10, 1.6, 3, 12);
right(20) wing_tang(20, 10, 1.6, 3);
