// wing.scad: wing panels with sweep and taper from airfiol
// front-most point of leading edge aligns with Y=0

include <BOSL2/std.scad>
include <airfoil.scad>


// outer skin of a wing panel
module wing_envelope(root_chord, tip_chord, le_sweep, panel_span, af) {
  root_rib = airfoil(c=root_chord, naca=af);
  tip_rib = airfoil(c=tip_chord, naca=af);
  yrot(90)  // spar along x axis
    zrot(90)  // root chord on y axis
      skin([root_rib, right(le_sweep, tip_rib)],
           slices=0,
           z=[0,panel_span]);
}

// wing panel with optional spar cutout
module wing(root_chord, tip_chord, le_sweep, panel_span, af) {
  difference() {
    wing_envelope(root_chord, tip_chord, le_sweep, panel_span, af);
    children();
  }
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

