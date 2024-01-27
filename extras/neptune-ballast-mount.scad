include <BOSL2/std.scad>

$fn=64;

difference() {
  union() {
    left(2+1.5) {
      // core
      // 13mm for aft set; 32.5mm for fwd
      cyl(d=13, l=32.5, anchor=BOTTOM);
      // insulator washer
      cyl(d=51, l=0.8, anchor=TOP);
      cube([50, 51, 0.8], anchor=TOP+RIGHT);}

  }
  union() {
    cyl(d=6.3, l=70, anchor=CENTER);
    left(94) {
      cyl(d=130, l=3, anchor=CENTER);}}}
