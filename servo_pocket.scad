
// servo_pocket.scad: cutouts for servos


// the canonical definitions for these variables are in parameters.inc
LAYER_H = 0.15;
EXTRUSION_W = 0.45;

include <BOSL2/std.scad>
include <BOSL2/structs.scad>

/*
         _             _
        | |____       | |
     ==|       |==   |===|
  _^   |       |     |   | ^ (z=0 at bottom of tab)
 | v  _|       |     |   | h (from bottom of tab to bottom of servo)
 |     |_______|     |___| v
 |     |<- l ->|     |<w>|
 |   |<-l_w_tabs->|
 |
  \ wire exit (from bottom of tab to top of wire)

*/

// servo pocket where the servo shaft is normal to the surface in
// which it embeds

module servo_pocket_vertical(srv, projection_h=15) {
  let(w = struct_val(srv, "w"),
      l = struct_val(srv, "l"),
      h = struct_val(srv, "h"),
      l_w_tabs = struct_val(srv, "l_w_tabs"),
      wire_exit = struct_val(srv, "wire_exit")) {
    difference() {
      _servo_plug(w, l, h, l_w_tabs, wire_exit, projection_h);
      _servo_supports(w, l, h, l_w_tabs, wire_exit, projection_h);
    }
  }
}

module _servo_plug(w, l, h, l_w_tabs, wire_exit, projection_h) {
  // main body
  cube([w,l,h], anchor=FRONT+TOP);
  // tabs and their projection upward
  tab = (l_w_tabs - l) / 2;
  fwd(tab)
    cube([w, l_w_tabs, projection_h],
         anchor=FRONT+BOTTOM);
  // TODO: screw holes
  // clearance for wire during insertion
  let(wire_width = 4,
      wire_thick = 1.5)
    fwd(wire_thick)
          cube([wire_width, wire_thick, wire_thick+wire_exit],
               anchor=FRONT+TOP);
}

module _servo_supports(w, l, h, l_w_tabs, wire_exit, projection_h) {
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


function servo(w, l, h, l_w_tabs, wire_exit, typ_sink, tab_h) =
  struct_set([], ["w", w,
                  "l", l,
                  "h", h,
                  "l_w_tabs", l_w_tabs,
                  "wire_exit", wire_exit,
                  "typ_sink", typ_sink,
                  "tab_h", tab_h]);


// definitions for specific servos
SERVOS = struct_set([], ["HS-50", servo(w=11.5,
                                        l=21,
                                        h=14,
                                        l_w_tabs=30,
                                        wire_exit=9,
                                        typ_sink=5,
                                        tab_h=1.0),
                         "HS-55", servo(w=12,
                                        l=23.75,
                                        h=16.5,
                                        l_w_tabs=32.5,
                                        wire_exit=12,
                                        typ_sink=4,
                                        tab_h=1.2)]);
