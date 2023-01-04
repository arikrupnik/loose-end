// airfoil.scad: NACA 4-digit airfoils and simple wings forms

// Flat airfoils path are in the XY plane as 2D objects are in
// OpenSCAD, with chords are along the X axis, with the leading edge
// at X=0 and trailing edges towards positive X. Heights are along Y,
// with upper surface towards positive Y.
//
// Wings' orientation is consistent with -Y=front, +X=right,
// +Z=up. Root leading edge is at the origin. Root chord is along the
// Y axis. Spar extends towards positive X.

include <BOSL2/std.scad>

$airfoil_fn = 120;

/* Airfoils have sharper curves on the leading edge than trailing
   edge. This function produces an alternative spacing, with tighter
   segments at LE. */
function exmap(x, xmax, P=2) =
  // x: between 0..xmax
  // xmax: chord length
  // P=1 produces even spacing of segments; the more positive, the
  // more segments at LE and larger segments at TE
  pow(x/xmax, P) * xmax;

//https://en.wikipedia.org/wiki/NACA_airfoil

// exmple: 2412 -> .02, .4, .12
function af_camber(af) = floor(af/1000) / 100;
function af_max_camber_pos(af) = floor(af/100) % 10 / 10;
function af_thickness(af) = (af%100) / 100;

// NACA symetrical airfoil formula
function foil_y(x, c, t, closed=true) =
  (5*t*c)*( ( 0.2969 * sqrt(x/c) ) - ( 0.1260*(x/c) ) - ( 0.3516*pow((x/c),2) ) + ( 0.2843*pow((x/c),3) ) - ( ( closed ? 0.1036 : 0.1015)*pow((x/c),4) ) );

function camber(x,c,m,p) = ( x <= (p * c) ?
  ( ( (c * m)/pow( p, 2 ) ) * ( ( 2 * p * (x / c) ) - pow( (x / c) , 2) ) ) :
  ( ( (c * m)/pow((1 - p),2) ) * ( (1-(2 * p) ) + ( 2 * p * (x / c) ) - pow( (x / c) ,  2)))
);

function theta(x,c,m,p) = ( x <= (p * c) ?
  atan( ((m)/pow(p,2)) * (p - (x / c)) ) :
  atan( ((m)/pow((1 - p),2)) * (p - (x / c))  )
);

function camber_y(x,c,t,m,p, upper=true) = ( upper == true ?
  ( camber(x,c,m,p) + (foil_y(x,c,t) * cos( theta(x,c,m,p) ) ) ) :
  ( camber(x,c,m,p) - (foil_y(x,c,t) * cos( theta(x,c,m,p) ) ) )
);

function camber_x(x,c,t,m,p, upper=true) = ( upper == true ?
  ( x - (foil_y(x,c,t) * sin( theta(x,c,m,p) ) ) ) :
  ( x + (foil_y(x,c,t) * sin( theta(x,c,m,p) ) ) )
);


// chord: length of airfoil
// af: 4-digit airfoil designator
// shave: remove the thickness of a skin from the airfoil, e.g.,
// computing the shape of a rib accounting for skin of this thickness;
// negative numbers increase the size of the shape, as if draping this
// much skin on a nominal airfoil
function airfoil(c, af, shave=0) =
  let(step = c/$airfoil_fn, // average length of polygon segments
    t = af_thickness(af),
    m = af_camber(af),
    p = af_max_camber_pos(af),

    // To avoid duplicating points at c=0% and c=100%, I exclude them
    // from computation and add them in the final
    // concatenation. Duplicate (or very close) points interfere with
    // BOSL's offset computation. The need for a point at c=100%
    // renders the question of open or closed trailing edge moot.
    points_u = ( m == 0 || p == 0) ?
      [for (i = [step:step:c-step]) let (ex = exmap(i,c), y = foil_y(ex,c,t) ) [ex,y]] :
      [for (i = [step:step:c-step]) let (ex = exmap(i,c), x = camber_x(ex,c,t,m,p), y = camber_y(ex,c,t,m,p) ) [x,y]],

    points_l = ( m == 0 || p == 0) ?
      [for (i = [c-step:-1*step:step]) let (ex = exmap(max(i,0),c), y = foil_y(ex,c,t) * -1 ) [ex,y]] :
      [for (i = [c-step:-1*step:step]) let (ex = exmap(max(i,0),c), x = camber_x(ex,c,t,m,p,upper=false), y = camber_y(ex,c,t,m,p, upper=false) ) [x,y]],

    points = concat([[0,0]], points_u, [[c,0]], points_l))
  offset(points, delta=-shave, closed=true, same_length=true);

module airfoil(c, af, shave=0) {
  polygon(airfoil(c, af, shave));
}


// A trapezoidal wing without washout and with identical sections root
// and tip, but with (possibly) different chords and with a sweep.
// le_sweep: tip leading edge is this far behind root LE; negative values produce forward sweep
module trapezoidal_wing(root_chord, tip_chord, le_sweep, panel_span, af, shave=0) {
  root_rib = airfoil(root_chord, af, shave);
  tip_rib = airfoil(tip_chord, af, shave);
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


// functions for computing CG in a multi-trapezoidal wing. `panels' is
// a list of sub-panels. The first panel (root) has the form
// [root_chord, tip_chord, half_span]. Subsequent panels have the form
// [root_chord, root_chord_setback_from_previous_tip, tip_chord, sweep, panel_span]
// Sweep describes how far the tip leading edge is behind root LE.
//
// TODO: description above agrees with WING_PANELS in parameters.inc
// but may be inconsistent with code below.

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
