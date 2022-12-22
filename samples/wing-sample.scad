
include <BOSL2/std.scad>
use <../wing.scad>

// straight leading edge
back(000) xflip_copy() {
  wing(200, 100, 0, 300, 0015) {
    // spar cutout goes clear to wingtip, as it would in wire-cut foam
    // (also, for visibility)
    back(30) xcyl(d=5, l=301, anchor=LEFT);
  }
}

// straight max-thickness line (positive camber)
back(300) xflip_copy() {
  wing(200, 100, 30, 300, 2415) {
    back(60) xcyl(d=5, l=301, anchor=LEFT);
  }
}

// straight trailing edge
back(600) xflip_copy() {
  wing(200, 100, 100, 300, 0015) {
    back(120) xcyl(d=5, l=301, anchor=LEFT);
  }
}
