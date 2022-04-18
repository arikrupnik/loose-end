
use <../wing.scad>

// straight leading edge
back(000) xflip_copy() {
  wing(200, 100, 0, 300);
}

// straight max-thickness linelength
back(300) xflip_copy() {
  wing(200, 100, 30, 300);
}

// straight trailing edge
back(600) xflip_copy() {
  wing(200, 100, 100, 300);
}
