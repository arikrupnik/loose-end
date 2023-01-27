// motor-plugs.scad: plugs for adapting SU Estes motors for use in RCRG

include <BOSL2/std.scad>

$fn=64;

module plug(d, h) {
  wall_thickness = d/12;
  difference() {
    cyl(d=d, h=h, anchor=BOTTOM);
    up(d/4) {
      id = d-2*wall_thickness;
      cyl(d=id, h=h, rounding1=id/2, anchor=BOTTOM);
    }
  }
}

// 13mm motors
plug(9.75, 6);
