
include <BOSL2/std.scad>

/* Rail guide.
   0Z=surface of airframe.
   0Y=top (front) of guide. */
module rail_guide1010(length, extra_h=0) {
    THIKNESS = 1.5;  // as if the guide were a sheet stamping
    WING_W = 10; // width of the wings that engage with rail
    NORMAL_STEM_H = 5;
    STEM_W = 6;
    STEM_H = NORMAL_STEM_H + extra_h;
    up(NORMAL_STEM_H) difference() {
        union() {
            // horizontal
            cube([WING_W, length, THIKNESS], anchor=FWD+DOWN);
            // stem
            down(STEM_H) cube([STEM_W, length, STEM_H], anchor=FWD+DOWN);
        }
        // cutout
        up(THIKNESS) cube([STEM_W-2*THIKNESS, length, STEM_H], anchor=FWD+UP);
    }
}
