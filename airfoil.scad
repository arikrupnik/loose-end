$airfoil_fn = 120;
$close_airfoils = true;

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

  function foil_y(x, c, t) = 
(5*t*c)*( ( 0.2969 * sqrt(x/c) ) - ( 0.1260*(x/c) ) - ( 0.3516*pow((x/c),2) ) + ( 0.2843*pow((x/c),3) ) - ( ( $close_airfoils ? 0.1036 : 0.1015)*pow((x/c),4) ) ); //NACA symetrical airfoil formula
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
  
  
function airfoil(c = 100, naca = 0015) =
  let($close_airfoils = ($close_airfoils != undef) ? $close_airfoils : false,
      $airfoil_fn = ($airfoil_fn != undef) ? $airfoil_fn : 100,
      step = c/$airfoil_fn, // average length of polygon segments
      t = af_thickness(naca),
      m = af_camber(naca),
      p = af_max_camber_pos(naca),

      // points have to be generated with or without camber, depending.
      points_u = ( m == 0 || p == 0) ?
        [for (i = [0:step:c]) let (ex = exmap(i,c), y = foil_y(ex,c,t) ) [ex,y]] :
        [for (i = [0:step:c]) let (ex = exmap(i,c), x = camber_x(ex,c,t,m,p), y = camber_y(ex,c,t,m,p) ) [x,y]],

      points_l = ( m == 0 || p == 0) ?
        [for (i = [c:-1*step:0]) let (ex = exmap(max(i,0),c), y = foil_y(ex,c,t) * -1 ) [ex,y]] :
        [for (i = [c:-1*step:0]) let (ex = exmap(max(i,0),c), x = camber_x(ex,c,t,m,p,upper=false), y = camber_y(ex,c,t,m,p, upper=false) ) [x,y]])
   concat(points_u,points_l);

module airfoil(c = 100, naca = 0015) {
  polygon(airfoil(c, naca));
}
