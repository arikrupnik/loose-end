// wing.scad: wing panels with sweep and taper from airfiol

include <BOSL2/std.scad>
include <airfoil.scad>

// aligns front-most point of leading edge with Y=0
module wing(root_cord, tip_cord, le_sweep, panel_span, af) {
  d = le_sweep / (1-tip_cord/root_cord);
  back(d)  // align leading edge with 0
    yrot(90)
      linear_extrude(height=panel_span, scale=tip_cord/root_cord)
        fwd(d)  // align extrusion center with 0
          zrot(90) // align airfoil with y axis
            airfoil_poly(c=root_cord, naca=af);
}

function af_thickness(af) = (af % 100) / 100;

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

