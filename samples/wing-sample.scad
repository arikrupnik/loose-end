
use <../wing.scad>

// straight leading edge
back(000) xflip_copy() {
  wing(200, 100, 0, 300, 0015, 30, 5);
}

// straight max-thickness line (positive camber)
back(300) xflip_copy() {
  wing(200, 100, 30, 300, 2415, 60, 5);
}

// straight trailing edge
back(600) xflip_copy() {
  wing(200, 100, 100, 300, 0015, 120, 5);
}
