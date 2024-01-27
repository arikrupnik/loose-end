
include <BOSL2/std.scad>

$fn=64;

difference() {
  up(0.5) {
    zcyl(d=94, h=5);}
  zcyl(d=10, h=7, circum=true);
  zcyl(d=90, h=4, anchor=BOTTOM);
  for(i = [0:30:360]) {
    zrot(i) {
      xmove(35) {
        zcyl(d=15, h=7);}
      zrot(15) {
        xmove(20) {
          zcyl(d=8, h=7);}}}}}

up(10)
difference() {
  zcyl(d=18, h=10);
  zcyl(d=10, h=10, circum=true);}
