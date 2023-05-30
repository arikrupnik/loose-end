// stryker-q-guide.scad: rod guide to hold Stryker-Q from spinning on the launch rod

include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn=64;
$slop=0.1;

// base with holes for 1/8" rod and 1/4-20 set screw
difference() {
  union() {
    // base
    cube([20, 30, 20], anchor=TOP);
    // platform
    cube([80, 15, 5], anchor=TOP+FRONT);
  }
  /*back(1.5) may be unnecessary */ {
    // rod
    zcyl(d=4, h=20, anchor=TOP);
    // set screw hole
    down(10) {
      xrot(-90) {
        screw_hole("1/4-20", l=18, anchor=TOP, thread=true);
      }
    }
  }
}

// inner, long wings
xflip_copy() {
  down(5) {
    right(12) {
      prismoid([5, 30], [5, 15], h=55, shift=[1, 4.5], anchor=BOTTOM+FRONT+LEFT);
    }
  }
}

// outrer, short wings
xflip_copy() {
  right(40) {
    cube([5, 28, 10], anchor=FRONT+RIGHT);
  }
}
