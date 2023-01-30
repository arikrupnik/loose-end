

include <BOSL2/std.scad>
include <../servo_pocket.scad>

difference() {
  cube([20, 40, 25], anchor=TOP);
  fwd(10)
    down(4)
      svp_hs55();
}

ymove(50) svp_hs50();
