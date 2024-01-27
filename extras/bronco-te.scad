include <BOSL2/std.scad>

$fn=64;
H=100;
PITCH=85;

module te() {
  difference() {
    rect([170, PITCH], anchor=LEFT);
    right(91) fwd(7)
      import("bronco-te.svg", center=true);
  }
}

module te_rack() {
  intersection() {
    difference() {
      union() {
        ycopies(spacing=PITCH, n=3)
          linear_extrude(H)
          te();
        // brim
        left(5)
          cube([170+20, PITCH*3, 0.3], anchor=BOTTOM+LEFT);
      }
      // velcro
      ycopies(spacing=250, n=2) {
        move([120, 0, 50])
          cuboid([100, 6, 29], chamfer=3, edges="X", anchor=CENTER);}
      // inscriptions
      ymove(100) {
        zmove(H)
          text3d(" OV-10 Bronco", h=1, anchor=TOP+LEFT, size=12);
        yrot(180)
          text3d("OV-10 Bronco ", h=1, anchor=TOP+RIGHT, size=12);
      }
    }
    right(90) {
      cube([210, 250, H], anchor=BOTTOM);
    }
  }
}
  
*te();
zrot(90)
  te_rack();
