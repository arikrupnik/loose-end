// latch.scad: acommodation for a spring latch

include <BOSL2/std.scad>

// y=0 is top surface of the latch (bottom of cutout)
module latch() {
  fwd(8) {
    // latch body
    prismoid(size1=[17,48], size2=[17,32], h=15, anchor=BACK+TOP);
    // handle slot
    fwd(7) cube([2.5, 18, 12], anchor=BACK+BOTTOM);
    // shaft
    back(15) down(6) ycyl(l=50, d=2.5, anchor=BACK);
  }
}

latch();
