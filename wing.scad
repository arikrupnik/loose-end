// wing.scad: wing panels for Loose End rocket glider

include <BOSL2/std.scad>
include <airfoil.scad>
include <parameters.inc>
include <servo_pocket.scad>


// wing panel from parameters
module wing() {
  trapezoidal_wing(ROOT_CHORD, TIP_CHORD, LE_SWEEP, PANEL_SPAN, WING_AIRFOIL) {
    // spar cutout
    spar(SPAR_C_ROOT, SPAR_D, PANEL_SPAN);
    // hinge cutout
    mid_hinge(ROOT_CHORD*(1-ELEVON_CHORD),
              LE_SWEEP+(TIP_CHORD*(1-ELEVON_CHORD)),
              ROOT_CHORD * af_thickness(WING_AIRFOIL),
              PANEL_SPAN);
    // servo wire tunnel--end even with outboard-most servo's outer edge
    let(outboard_servo_n = len(SERVO_X) - 1,
        outboard_servo_x = SERVO_X[outboard_servo_n],
        outboard_servo = struct_val(SERVOS, SERVO_TYPE[outboard_servo_n]),
        outboard_servo_w = struct_val(outboard_servo, "w"))
      spar(SERVO_WIRE_TUNNEL_EXIT, SERVO_WIRE_TUNNEL_D, outboard_servo_x+outboard_servo_w/2);
    // servo pockets
    for(sn=[0:len(SERVO_X)-1])
      let(span_x = SERVO_X[sn],
          chord = trapezoidal_wing_chord_at_span(ROOT_CHORD, TIP_CHORD, LE_SWEEP, PANEL_SPAN, span_x),
          sweep = trapezoidal_wing_sweep_at_span(ROOT_CHORD, TIP_CHORD, LE_SWEEP, PANEL_SPAN, span_x),
          af = airfoil(WING_AIRFOIL, chord),
          chord_p = SERVO_Y-sweep,
          srv = struct_val(SERVOS, SERVO_TYPE[sn]),
          srv_l = struct_val(srv, "l"),
          srv_sink = struct_val(srv, "typ_sink"),
          hatch = af_hatch(af, chord_p, srv_l),
          angle = hatch[2])
        right(span_x) {
          // servo pocket
          back(SERVO_Y)
            up(hatch[0].y - srv_sink)
              xrot(-angle)
                servo_pocket_vertical(srv);
          // wire tunnel from servo to main tunnel
          back(SERVO_WIRE_TUNNEL_EXIT)
            down(SERVO_WIRE_TUNNEL_D/2)
              top_half()
                ycyl(l=SERVO_Y-SERVO_WIRE_TUNNEL_EXIT, d=SERVO_WIRE_TUNNEL_D, anchor=FRONT);
        }
    // wing tang pockets
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
      mirror([0,side=="r"?1:0,0])
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
