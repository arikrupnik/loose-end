// airfoil.scad: NACA 4-digit airfoils and simple wings forms

// Flat airfoil paths are in the XY plane as 2D objects are in
// OpenSCAD, with chords are along the X axis, with the leading edge
// at X=0 and trailing edges towards positive X. Heights are along Y,
// with upper surface towards positive Y.
//
// 3D wings' orientation is consistent with -Y=front, +X=right,
// +Z=up. Root leading edge is at the origin. Root chord is along the
// Y axis. Spar extends towards positive X.
//
// This file makes use of some routines from BOSL (most importantly,
// the *function* offset(), but is otherwise generic, without
// dependencies on anything in the Loose End project.
//
// NACA 4-digit math is from https://en.wikipedia.org/wiki/NACA_airfoil

include <BOSL2/std.scad>

/////////////////////
// NACA 4-digit airfoil construction

// Number of points on each side (top and bottom) of an airfoil polygon
$airfoil_fn = 120;

// A 4-digit code packs three numbers
// exmple: 2412 -> .02, .4, .12
function af_max_camber(af) = floor(af/1000) / 100;
function af_max_camber_pos(af) = floor(af/100) % 10 / 10;
function af_thickness(af) = (af%100) / 100;
// example: af(.02, .4, .12) -> 2412
function af(camber, camber_pos, thickness) =
  camber*100*1000 + camber_pos*10*100 + thickness*100;

// A set of polynomials describe the 4-digit curve as a function of
// location x [0.0..1.0] along the chord:

// Symetrical airfoil half-thickness, as a function of chord location
function half_thickness(x, thickness, closed=true) =
  let(t = thickness)
  5 * t * (0.2969 * pow(x, 1/2) -
           0.1260 * pow(x, 1) -
           0.3516 * pow(x, 2) +
           0.2843 * pow(x, 3) -
           (closed ? 0.1036 : 0.1015) * pow(x, 4));

// Camber line as a function of chord location. NACA4 uses different
// computation for points ahead and abaft maximum camber point
function camber(x, max_camber, max_camber_pos) =
  let(m = max_camber,
      p = max_camber_pos)
  x <= p ?
    (m/pow(p, 2)) * (2*p*x - pow(x, 2)) :
    (m/pow(1-p, 2)) * ((1 - 2*p) + 2*p*x - pow(x, 2));

// "For this cambered airfoil, the thickness needs to be applied
// perpendicular to the camber line." NACA4 uses different
// computation for points ahead and abaft maximum camber point
function theta(x, max_camber, max_camber_pos) =
  let(m = max_camber,
      p = max_camber_pos)
  atan(x <= p ?
       (2*m/pow(p, 2)) * (p - x) :
       (2*m/pow(1-p, 2)) * (p - x));

// For each point x on the chord, an airfoil has two points: one each
// on the upper and the lower surface. For sections with positive
// camber, where thickness applies at a normal to the camber curve,
// the x coordinate is different from the input x. This function
// returns, for each input x, a list of two points: [[xu,yu],[xl,yl]]
function points_at(x, max_camber, max_camber_pos, thickness) =
  let(m = max_camber,
      p = max_camber_pos,
      t = thickness,
      yt = half_thickness(x,t),
      yc = camber(x,m,p))
  [[x - yt * sin(theta(x,m,p)),
    yc + yt * cos(theta(x,m,p))],
   [x + yt * sin(theta(x,m,p)),
    yc - yt * cos(theta(x,m,p))]];

// Computes a path that represents a 4-digit airfoil, with leading
// edge at [0,0] and trailing edge at [chord,0]
// af: 4-digit airfoil designator
// chord: length of airfoil
// shave: remove the thickness of a skin from the airfoil, e.g.,
// computing the shape of a rib accounting for skin of this thickness;
// negative numbers increase the size of the shape, as if draping this
// much skin on a nominal airfoil
// P: distribution of points along the chord; P=1 produces even
// spacing of segments; the more positive, the more segments at LE and
// larger segments at TE
function airfoil(af, chord, shave=0, P=2) =
  let(step = 1/($airfoil_fn-1), // average x-length of polygon segments,
      m = af_max_camber(af),
      p = af_max_camber_pos(af),
      t = af_thickness(af),
      // To avoid duplicating points at c=0% and c=100%, I exclude them
      // from computation and add them in the final
      // concatenation. Duplicate (or very close) points interfere with
      // BOSL's offset computation. The need for a point at c=100%
      // renders the question of open or closed trailing edge moot.
      xs = [for (x = [step:step:1-step]) x],
      // Airfoils have sharper curves on the leading edge than
      // trailing edge. This mapping produces an alternative spacing,
      // with tighter segments at LE.
      exs = [for (x = xs) pow(x, P)],
      af_points = [for (x = exs) points_at(x,m,p,t)],
      // extract upper-surface points...
      upper_surface = [for (pp = af_points) pp[0]],
      // ...lower-surface points...
      lower_surface = [for (pp = af_points) pp[1]],
      // ...and reverse, to make a continuous outline
      lower_surface_r = reverse(lower_surface),
      // concatenate upper, lower and extreme points
      points = concat([[0,0]], upper_surface, [[1,0]], lower_surface_r),
      // scale to user chord
      scaled_points = [for (p = points) [for (xy = p) xy*chord]])
  // optionaly, add or remove a skin
  offset(scaled_points, delta=-shave, closed=true, same_length=true);

module airfoil(af, chord, shave=0) {
  polygon(airfoil(af, chord, shave));
}


/////////////////////
// Wings from airfoils

// A trapezoidal wing without washout and with identical sections root
// and tip, but with (possibly) different chords and with a sweep.
// le_sweep: tip leading edge is this far behind root LE; negative values produce forward sweep
module trapezoidal_wing(root_chord, tip_chord, le_sweep, panel_span, af, shave=0) {
  root_rib = airfoil(af, root_chord, shave);
  tip_rib = airfoil(af, tip_chord, shave);
  difference() {
    yrot(90)  // spar along x axis
      zrot(90)  // root chord on y axis
        skin([root_rib, right(le_sweep, tip_rib)],
             slices=0,
             z=[0,panel_span]);
    children();
  }
}

// simple, round spar cutout, perpendicular to fuselage
// root_loc: distance from root LE to center of spar
module spar(root_loc, diameter, length) {
  back(root_loc)
    xcyl(d=diameter, l=length, anchor=LEFT);
}

// hinge in the middle of an airfoil, with equal cutouts top and bottom
module mid_hinge(root_loc, tip_loc, root_thickness, bridge_thickness, length) {
  back(root_loc)
    skew(syx=(tip_loc-root_loc)/length)
      zflip_copy()
        xrot(45)
          zmove(bridge_thickness/2)
            cube([length, root_thickness, root_thickness]);
}


/////////////////////
// MAC

// functions for computing Mean Aerodynamic Chord in a
// multi-trapezoidal wing, useful for setting CG ranges. `panels' is a
// list of sub-panels. Each panel is a five-item list of the form
// [root_chord, root_setback,
//  tip_chord,  sweep,
//  panel_span]
// If a panel's leading edge is offset from the previous panel's,
// `root_setback' descibes this iffset; positive values move this
// panel back; for a continuous leading edge, or for the innermost
// panel, `root_setback is 0.
// `sweep' describes how far the tip leading edge is behind root LE.

function mac_length_panel(panel) =
  let(root_chord=panel[0],
      root_setback=panel[1],
      tip_chord=panel[2],
      tip_setback=panel[3])
    let (taper_ratio = tip_chord/root_chord)
      root_chord * 2/3 * ((1 + taper_ratio + taper_ratio*taper_ratio) /
                          (1 + taper_ratio ));

function mac_setback_panel(panel) =
  let(root_chord=panel[0],
      root_setback=panel[1],
      tip_chord=panel[2],
      tip_setback=panel[3])
    let (taper_ratio = tip_chord/root_chord)
      root_setback + (tip_setback-root_setback) * ((1 + 2*taper_ratio) /
                                                   (3 + 3*taper_ratio));

function area_panel(panel) =
  let(root_chord=panel[0],
      tip_chord=panel[2],
      span=panel[4])
    (root_chord + tip_chord) / 2 * span;

// length of MAC; CG ranges are fractions of this value
function mac_length(panels) =
  sum([for(p=panels) mac_length_panel(p) * area_panel(p)]) /
  sum([for(p=panels) area_panel(p)]);

// distance from the leading edge of root rib in inner-most panel and
// the LE of MAC; CG ranges are set back from this point
function mac_setback(panels) =
  sum([for(p=panels) mac_setback_panel(p) * area_panel(p)]) /
  sum([for(p=panels) area_panel(p)]);
