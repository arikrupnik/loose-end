// jawstand-bearing-scad: replacement lower bearing for the Jawstand launcher tripod


include <BOSL2/std.scad>

$fn=64;

H = 10;

difference() {
  union() {
    // main body
    linear_extrude(H) {
      regular_ngon(3, id=49, rounding=11);
    }
    // brim
    linear_extrude(2) {
      regular_ngon(3, id=51, rounding=11);
    }
  }
  // cutout
  zcyl(d=32.5, h=H, anchor=BOTTOM);
}
