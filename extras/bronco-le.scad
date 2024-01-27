include <BOSL2/std.scad>

$fn=64;
H=100;
PITCH=85;

module le() {
  difference() {
    rect([105, PITCH], anchor=RIGHT);
    left(58)
      import("bronco-le.svg", center=true);
  }
}

module le_rack() {
  intersection() {
    difference() {
      union() {
        ycopies(spacing=PITCH, n=3)
          linear_extrude(H)
            le();
        // brim
        right(5)
          cube([105+20, PITCH*3, 0.3], anchor=BOTTOM+RIGHT);
      }
      // velcro
      ycopies(spacing=250, n=2) {
        move([-70, 0, 50])
          cube([70, 4, 29], chamfer=3, edges="X", anchor=CENTER);}
      // inscriptions
      ymove(110) {
        zmove(H)
          text3d("OV-10 ", h=1, anchor=TOP+RIGHT, size=10);
        yrot(180)
          text3d(" OV-10", h=1, anchor=TOP+LEFT, size=10);
      }
    }
    left(50) {
      cube([210, 250, H], anchor=BOTTOM);
    }
  }
}

*le();
zrot(90)
  le_rack();
