
include <BOSL2/std.scad>
use <../wing.scad>

// straight leading edge
back(000) xflip_copy() {
  trapezoidal_wing(200, 100, 0, 300, 0015) {
    // spar cutout goes clear to wingtip, as it would in wire-cut foam
    // (also, for visibility)
    spar(30, 5, 301);
    // constant-ratio elevon (10%)
    mid_hinge(190, 95, 30, .75, 300);
  }
}

// straight max-thickness line (positive camber)
back(300) xflip_copy() {
  trapezoidal_wing(200, 100, 30, 300, 2415) {
    spar(60, 5, 301);
  }
}

// straight trailing edge
back(600) xflip_copy() {
  trapezoidal_wing(200, 100, 100, 300, 0015) {
    spar(120, 5, 301);
    // constant-chord elevon (10% of root chord)
    mid_hinge(190, 190, 30, .75, 300);
  }
}
