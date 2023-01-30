// wing.scad: wing panels for Loose End rocket glider

include <BOSL2/std.scad>
include <airfoil.scad>
include <parameters.inc>


// wing panel from parameters
module wing() {
  trapezoidal_wing(ROOT_CHORD, TIP_CHORD, LE_SWEEP, PANEL_SPAN, WING_AIRFOIL) {
    spar(SPAR_C_ROOT, SPAR_D, PANEL_SPAN);
    mid_hinge(ROOT_CHORD*(1-ELEVON_CHORD),
              LE_SWEEP+(TIP_CHORD*(1-ELEVON_CHORD)),
              ROOT_CHORD * af_thickness(WING_AIRFOIL),
              .75,
              PANEL_SPAN);
    for(p=WING_TANGS)
      back(p)
        left(SHEET_THICKNESS)  // accounting for fins
          tang_pocket(WING_TANG_L, WING_TANG_W, SHEET_THICKNESS);
  }
}

// individual wing segments for printing, in correct printing orientation
module wing_segment(n, side) {
  ocuts = concat(0, WING_PARTITIONS, PANEL_SPAN);
  root_x = ocuts[n-1];
  tip_x = ocuts[n];
  zrot(-90)  // better to fit on a print bed
    yrot(-90)  // root rib down
      // "Use a number larger than twice your object's largest axis."
      right_half(s=ROOT_CHORD*2, x=root_x)
        left_half(s=ROOT_CHORD*2, x=tip_x)
          wing();
}

// cutter planes to visualize segmentation
module wing_cuts() {
  for(p=WING_PARTITIONS)
    right(p)
      cube([CUT_WIDTH, ROOT_CHORD, ROOT_CHORD*af_thickness(WING_AIRFOIL)], anchor=FRONT);
}
