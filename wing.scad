// wing.scad: wing panels with sweep and taper from airfiol
// front-most point of leading edge aligns with Y=0
// default is the right wing, with wingtip extending towards positive X

include <BOSL2/std.scad>
include <airfoil.scad>


// outer skin of a wing panel
module wing_envelope(root_chord, tip_chord, le_sweep, panel_span, af, shave=0) {
  root_rib = offset(airfoil(c=root_chord, naca=af), delta=-shave, closed=true, same_length=true);
  tip_rib = offset(airfoil(c=tip_chord, naca=af), delta=-shave, closed=true, same_length=true);
  yrot(90)  // spar along x axis
    zrot(90)  // root chord on y axis
      skin([root_rib, right(le_sweep, tip_rib)],
           slices=0,
           z=[0,panel_span]);
}

// simple, round spar cutout, perpendicular to fuselage
module spar(root_loc, diameter, length) {
  back(root_loc)
    xcyl(d=diameter, l=length, anchor=LEFT);
}

// wing panel with optional spar cutouts
module wing(root_chord, tip_chord, le_sweep, panel_span, af, shave=0) {
  difference() {
    wing_envelope(root_chord, tip_chord, le_sweep, panel_span, af, shave);
    children();
  }
}

include <parameters.inc>
module wing_cuts() {
  for(p=WING_PARTITIONS)
    right(p)
      cube([CUT_WIDTH, ROOT_CHORD, ROOT_CHORD*af_thickness(WING_AIRFOIL)], anchor=FRONT);
}
module wing_segment(n, side) {
  ocuts = concat(0, WING_PARTITIONS, PANEL_SPAN);
  root_x = ocuts[n-1];
  tip_x = ocuts[n];
  zrot(-90)  // better to fit on a print bed
    yrot(-90)
      // "Use a number larger than twice your object's largest axis."
      right_half(s=ROOT_CHORD*2, x=root_x)
        left_half(s=ROOT_CHORD*2, x=tip_x)
          wing(ROOT_CHORD, TIP_CHORD, LE_SWEEP, PANEL_SPAN, WING_AIRFOIL)
            spar(SPAR_C_ROOT, SPAR_D, PANEL_SPAN);
}

function mac_length_panel(panel) =
  let(root_chord=panel[0], root_setback=panel[1], tip_chord=panel[2], tip_setback=panel[3])
    let (taper_ratio = tip_chord/root_chord)
      root_chord * 2/3 * (( 1 + taper_ratio + taper_ratio*taper_ratio ) / ( 1 + taper_ratio ));

function mac_setback_panel(panel) =
  let(root_chord=panel[0], root_setback=panel[1], tip_chord=panel[2], tip_setback=panel[3])
    let (taper_ratio = tip_chord/root_chord)
      root_setback + (tip_setback-root_setback) * ((1 + 2*taper_ratio) / (3 + 3*taper_ratio));

function area_panel(panel) =
  let(root_chord=panel[0], tip_chord=panel[2], span=panel[4])
    (root_chord + tip_chord) / 2 * span;

function mac_length(panels) =
  sum([for(p=panels) mac_length_panel(p) * area_panel(p)]) /
  sum([for(p=panels) area_panel(p)]);

function mac_setback(panels) =
  sum([for(p=panels) mac_setback_panel(p) * area_panel(p)]) /
  sum([for(p=panels) area_panel(p)]);

