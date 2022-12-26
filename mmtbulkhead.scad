// mmtbulkhead.scad: solid pressure-containing bulkhead for motor mount tubes

include <BOSL2/std.scad>
include <parameters.inc>

h = MMT_ID * .25;  // plug height as fraction of diameter

module mmtbulkhead() {
  // main body
  difference() {
    cyl(d=MMT_ID, h=h, anchor=BOTTOM);
    up(h/2) cyl(d=MMT_ID, h=h, rounding1=h, anchor=BOTTOM);
  }
  // shoulder
  cyl(d=MMT_OD, h=MMT_OD*.03, anchor=TOP);
}
