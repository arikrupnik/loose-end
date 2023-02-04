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
include <BOSL2/fnliterals.scad>

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
  let(step = 1/($airfoil_fn), // average x-length of polygon segments,
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

assert(len(airfoil(0014, 100))==$airfoil_fn*2);

module airfoil(af, chord, shave=0) {
  polygon(airfoil(af, chord, shave));
}

// Returns the top and bottom skin distance from reference line at a
// point on the chord. For symetrical airfoils this is trivial, but
// for airfoils with positive camber, computation is more
// complex. This implementation returns values that are on the
// polygonal approximation that the rest of this file supports, rather
// than an idealized, infinite-precision formula. This guarantees that
// the results are on the surface of the polygon that is the result of
// `arifoil()' function.
function top_bottom_at_x(af_poly, chord_p) =
  let(line = [[chord_p,10], [chord_p,-10]],
      intersection_segments = polygon_line_intersection(af_poly, line))
  // intersection is a list of segments, each of which can be a point
  // or a line; undef when there is no intersection; in the case of a
  // NACA airfiol, there can be at most one segment; this segment is a
  // point at chord=0% and chord=100%, otherwise it is a line, a list
  // of two points whose x=chord_p and y is the answer:
  // pli(airfoil(0014, 100),   0) -> [[[0, 0]]]
  // pli(airfoil(0014, 100),  60) -> [[[60, 5.2961], [60, -5.2961]]]
  // pli(airfoil(0014, 100), 100) -> [[[100, 0]]]
  assert(is_def(intersection_segments), "chord_p outside airfoil")
  assert(len(intersection_segments)==1, "multiple intersections")
  let(segment = intersection_segments[0])
  len(segment)==1 ? [segment[0], segment[0]] : segment;

assert(top_bottom_at_x(airfoil(0014, 100),  0) == [[0,0],[0,0]]);
let($airfoil_fn=100) {
  assert(approx(top_bottom_at_x(airfoil(0014, 100), 30),
                [[30, 7], [30, -7]],
                0.001));
}
assert(top_bottom_at_x(airfoil(0014, 100),100) == [[100,0],[100,0]]);

// Generates a list of segments [[p0,p1],[p1,p2],[p2,p3]] from a list
// of points [p0,p1,p2,p3]. With closed=true(the default), adds
// [p3,p0] to the list. With top==undef, return all segments; with
// top=truem return top surface; with top=flase, bottom surface.
function segments_from_path(p, top=true, closed=true) =
  let(explicit_segments = accumulate(function(a,pt) [a[1],pt], list_tail(p,1), [undef,p[0]]),
      all_segments = closed ? concat(explicit_segments, [select(p,-1,0)]) : explicit_segments)
  is_undef(top) ? all_segments :
  top ?
  select(all_segments, 0, len(all_segments)/2-1) :
  select(all_segments, len(all_segments)/2, -1);

// number of segments matches $airfoil_fn*2 for full list, $airfoil_fn for top and bottom
assert(len(segments_from_path(airfoil(0014, 100), undef)) == $airfoil_fn*2);
assert(len(segments_from_path(airfoil(0014, 100), true))  == $airfoil_fn);
assert(len(segments_from_path(airfoil(0014, 100), false)) == $airfoil_fn);
// default is to return top surface
assert(segments_from_path(airfoil(0014, 100)) == segments_from_path(airfoil(0014, 100), true));
// top starts at [0,0] and ends at [chord,0]
assert(segments_from_path(airfoil(0014, 100), true)[0][0] == [0,0]);
assert(segments_from_path(airfoil(0014, 100), true)[$airfoil_fn-1][1] == [100,0]);
// bottom starts at [chord,0] and ends at [0,0]
assert(segments_from_path(airfoil(0014, 100), false)[0][0] == [100,0]);
assert(segments_from_path(airfoil(0014, 100), false)[$airfoil_fn-1][1] == [0,0]);

// The angle, in degrees, between the line [p0,p1] and the horizontal
// line [[0,0], [1,0]]. You need to rotate the horizontal line this
// many degrees clockwise to be parallel to the argument line.
function angle_between_points(p0, p1) =
  let(dx=p1.x-p0.x,
      dy=p1.y-p0.y)
  -atan(dy/dx);

// 8 cardinal points
assert(angle_between_points([0,0], [ 1, 0]) ==   0);
assert(angle_between_points([0,0], [ 1,-1]) ==  45);
assert(angle_between_points([0,0], [ 0,-1]) ==  90);
assert(angle_between_points([0,0], [-1,-1]) == -45);
assert(angle_between_points([0,0], [-1, 0]) ==   0);
assert(angle_between_points([0,0], [-1, 1]) ==  45);
assert(angle_between_points([0,0], [ 0, 1]) == -90);
assert(angle_between_points([0,0], [ 1, 1]) == -45);
// where origin is non-zero
assert(angle_between_points([1,1], [ 2, 2]) == -45);

// Computes the endpoints of a flat hatch of a specific length on an
// airfoil surface from the X location of its front, as well as the
// hatch's angle relative to chord line.
function af_hatch(af_poly, front, length, top=true) =
  let(pivot = top_bottom_at_x(af_poly, front)[top ? 0 : 1],
      segments = segments_from_path(af_poly, top),
      potential_isects = map(function(segment)
                             // cli() can find 0, 1 or 2
                             // intersections; in the case of a circle
                             // with radius on a segment and bounded
                             // segments, multiple intersections are
                             // impossible cli() always returns a list
                             // of length 1; hence [0]
                             circle_line_intersection(abs(length),
                                                      pivot,
                                                      segment,
                                                      true)[0],
                             segments),
      // pi has an element for each segment; at most two elements have
      // intersections with the circle; others are empty lists that I
      // filter out
      isects = filter(function(i) i,
                      potential_isects),
      // find intersection on the appropriate side of the pivot, if
      // one exists
      f = sign(length) > 0 ? f_gt() : f_lt(),
      isect = filter(function(i) f(i.x, front), isects))
  assert(len(isect)==1, "hatch length exceeds chord")
  let(pt1 = isect[0],
      angle = angle_between_points(pivot, pt1))
  [pivot, pt1, angle];

let($airfoil_fn = 100,
    af = airfoil(0014, 100)) {
  assert(approx(af_hatch(af, 60,  10),        [[60,  5.30428],[69.9438,  4.2452],  6.0795], 0.0001));
  assert(approx(af_hatch(af, 60, -10),        [[60,  5.30428],[50.037,   6.1639],  4.9314], 0.0001));
  assert(approx(af_hatch(af, 60,  10, false), [[60, -5.30428],[69.9438, -4.2452], -6.0795], 0.0001));
  assert(approx(af_hatch(af, 60, -10, false), [[60, -5.30428],[50.037,  -6.1639], -4.9314], 0.0001));
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

// Compute the length and setback of the chord at a span-wise distance
// from the root. Arguments are the same as `trapezoidal_wing' with
// the additional argument `span_x', denoting distance from the
// root. Returns the list [chord_at_x,sweep_at_x]
function trapezoidal_wing_chord_at_span(root_chord, tip_chord, le_sweep, panel_span, span_x) =
  let(span_ratio = span_x / panel_span,
      x_chord = lerp(root_chord, tip_chord, span_ratio))
  x_chord;
function trapezoidal_wing_sweep_at_span(root_chord, tip_chord, le_sweep, panel_span, span_x) =
  let(span_ratio = span_x / panel_span,
      x_sweep = lerp(0, le_sweep, span_ratio))
  x_sweep;

assert(trapezoidal_wing_chord_at_span(100, 20, 20, 200,   0) == 100);
assert(trapezoidal_wing_sweep_at_span(100, 20, 20, 200,   0) ==   0);
assert(trapezoidal_wing_chord_at_span(100, 20, 20, 200,  50) ==  80);
assert(trapezoidal_wing_sweep_at_span(100, 20, 20, 200,  50) ==   5);
assert(trapezoidal_wing_chord_at_span(100, 20, 20, 200, 100) ==  60);
assert(trapezoidal_wing_sweep_at_span(100, 20, 20, 200, 100) ==  10);
assert(trapezoidal_wing_chord_at_span(100, 20, 20, 200, 150) ==  40);
assert(trapezoidal_wing_sweep_at_span(100, 20, 20, 200, 150) ==  15);
assert(trapezoidal_wing_chord_at_span(100, 20, 20, 200, 200) ==  20);
assert(trapezoidal_wing_sweep_at_span(100, 20, 20, 200, 200) ==  20);

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
