// fins.scad: 2D outlines of root ribs and fins, for DXF export and flat-sheet coutouts


include <BOSL2/std.scad>
include <parameters.inc>

// 2D root rib with cutouts for spar, servo wires and attachment tangs and optional children
module root_rib() {
  difference() {
    round2d(ir=5) {  // stress relief on LE root
      airfoil(WING_AIRFOIL, ROOT_CHORD);
      right(ROOT_CHORD)
        children();
    }
    // spar
    right(SPAR_C_ROOT) circle(d=SPAR_D);
    // servo wire
    right(SERVO_WIRE_TUNNEL_EXIT) circle(d=SERVO_WIRE_TUNNEL_D);
    // wing attachment tangs
    for(p=WING_TANGS)
      right(p)
        // gap is different from gaps in 3D tang; constraints are different when cutting sheet stock
        square([WING_TANG_W+SHEET_THICKNESS, SHEET_THICKNESS+.2], anchor=CENTER);
  }
}

// 2D fin on root rib
module fin_outline() {
  root_rib() {
    scale(MOTOR_D)
      polygon([[-5.5,0],[-.5,4],[1,4],[0,0]]);
  }
}
