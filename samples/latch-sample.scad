// satch-sample.scad: example using latch cutout

include <BOSL2/std.scad>
use <../latch.scad>

$fn=64;

difference() {
  cube([30, 50, 11], anchor=BACK);
  up(4) latch();
}
