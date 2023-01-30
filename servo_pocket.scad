
// servo_pocket.scad: cutouts for servos


// the canonical definitions for these variables are in parameters.inc
LAYER_H = 0.15;
EXTRUSION_W = 0.45;

include <BOSL2/std.scad>

/*
         _             _
        | |____       | |
     ==|       |==   |===|
  _^   |       |     |   | ^ (z=0 at bottom of tab)
 | v  _|       |     |   | h (from bottom of tab to bottom of servo)
 |     |_______|     |___| v
 |     |<- l ->|     |<w>|
 |   |<- l_tabs ->|
 |
  \ wire exit (from bottom of tab to top of wire)

*/

// servo pocket where the servo shaft is normal to the surface in
// which it embeds

module servo_pocket_vertical(w, l, h, l_tabs, wire_exit, projection_h) {
  difference() {
    union() {
      // main body
      cube([w,l,h], anchor=FRONT+TOP);
      // tabs and their projection upward
      tab = (l_tabs - l) / 2;
      fwd(tab)
        cube([w, l_tabs, projection_h],
             anchor=FRONT+BOTTOM);
      // TODO: screw holes
      // clearance for wire during insertion
      let(wire_width = 4,
          wire_thick = 1.5)
        fwd(wire_thick)
          cube([wire_width, wire_thick, wire_thick+wire_exit],
               anchor=FRONT+TOP);
      // wire exit
      let(servo_connector_h = 3.5,
          servo_connector_w = 8.5,
          wire_exit_length = 15,
          wire_exit_angle = 10)
        down(wire_exit)
          xrot(wire_exit_angle)
            cube([servo_connector_w, wire_exit_length, servo_connector_h],
                 anchor=BACK+TOP);
    }
    // supports
    let(max_span_l = 5,
        num_spans = ceil(l / max_span_l),
        span_l = l / num_spans)
      up(projection_h)
        for(i=[span_l:span_l:l-span_l])
          back(i)
            cube([w-LAYER_H,  // to skip a layer on top and bottom
                  EXTRUSION_W,  // single-wall-thick
                  // not quite touching the inside wall
                  h+projection_h-EXTRUSION_W/2],
                 anchor=TOP);
  }
}

// typ. sink: 5mm
module svp_hs50(projection_h=7) {
  servo_pocket_vertical(w=11.5,
                        l=21,
                        h=14,
                        l_tabs=30,
                        wire_exit=9,
                        projection_h=projection_h);
}

// typ. sink: 4mm
module svp_hs55(projection_h=7) {
  servo_pocket_vertical(w=12,
                        l=23.75,
                        h=16.5,
                        l_tabs=32.5,
                        wire_exit=12,
                        projection_h=projection_h);
}
