// fin-projection.scad: utility to facilitate production of 2D DXF
// file for cutting fins out of sheet stock

use <loose_end.scad>

projection() linear_extrude(1) {
  fin_outline();
}
