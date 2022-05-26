// loose_end.scad: main

include <BOSL2/std.scad>
include <fuselage.scad>
include <wing.scad>

$airfoil_fn = 600;
$fn=64;

module spar() {
  back(SPAR_C)
    xcyl(d=SPAR_D, l=PANEL_SPAN*2+FUSELAGE_W+.1);
}


wing_panels=[[FUSELAGE_L, 0,
              FUSELAGE_L, 0,
              FUSELAGE_W/2],
             [ROOT_CHORD, FUSELAGE_L-ROOT_CHORD,
              TIP_CHORD,  FUSELAGE_L-ROOT_CHORD+LE_SWEEP,
              PANEL_SPAN]];

// fuselage with CG marks and printing cut lines
difference() {
  fuselage();
  // CG marks
  for(cg=[.15,.2,.25]) {
    // position in mm from fuselage LE
    cg_p = mac_setback(wing_panels) + mac_length(wing_panels)*cg;
    // top of fuselage in this position
    fuse_h = foil_y(cg_p, FUSELAGE_L, FUSELAGE_THICKNESS);
    back(cg_p) {
    // top & bottom
    zflip_copy()
      up(fuse_h)
        xcyl(d=SCRIBE_LINE_W,l=FUSELAGE_W, anchor=CENTER);
    // fuselage sides
    xflip_copy()
      right(FUSELAGE_W/2)
        zcyl(d=SCRIBE_LINE_W,l=fuse_h*2, anchor=CENTER);
    }
  }
  // partitioning
  fuse_cut(HATCH_F+HATCH_L+10);  // aft of hatch
  fuse_cut(SPAR_C-SPAR_D);  // fwd of carrythrough
  //fuse_cut(SPAR_C+SPAR_D);  // aft of carrythrough
}

up(50)  hatch();

// 2D root rib with cutouts for spar, servo wires and attachment tangs and optional children
module root_rib() {
  difference() {
    round2d(ir=5) {  // stress relief on LE root
      airfoil_poly(c=ROOT_CHORD, naca=WING_AIRFOIL);
      right(ROOT_CHORD)
        children();
    }
    // spar
    right(SPAR_C_ROOT) circle(d=SPAR_D);
    // servo wire
    right(SERVO_WIRE_TUNNEL_EXIT) circle(d=SERVO_WIRE_TUNNEL_D);
    // wing attachment tangs
    for(p=WING_TANGS)
      right(p)
        // gap is different from gaps in 3D tang; contraints are different when cutting sheet stock
        square([WING_TANG_W+SHEET_THICKNESS, SHEET_THICKNESS+.2], anchor=CENTER);
  }
}

// 2D fin on root rib
module fin_outline() {
  root_rib() {
    scale(MOTOR_D)
      polygon([[-5.5,0],[-.5,4],[1,4],[0,0]]);
  }
}

// fins
%xflip_copy()
  ymove(FUSELAGE_L - ROOT_CHORD) xmove(FUSELAGE_W/2 + CUT_WIDTH)
    yrot(90)
      linear_extrude(SHEET_THICKNESS)
        zrot(90)
          fin_outline();

// wing with spar cutout
%xflip_copy() {
  difference() {
  back(FUSELAGE_L-ROOT_CHORD) {
    right(FUSELAGE_W/2)
      wing(ROOT_CHORD, TIP_CHORD, LE_SWEEP, PANEL_SPAN, WING_AIRFOIL);
    }
  spar();
  }
}

// print measurements
echo(str("root chord: ", ROOT_CHORD, "mm; tip chrod: ", TIP_CHORD, "mm; half-span: ", PANEL_SPAN, "mm; spar diameter: ", SPAR_D, "mm; spar center from root LE: ", SPAR_C-(FUSELAGE_L-ROOT_CHORD), "mm"));
echo(str("fuselage-length: ", FUSELAGE_L, "; width: ", FUSELAGE_W));

fuselage_cross_section = FUSELAGE_W*FUSELAGE_H;
wing_cross_section = (ROOT_CHORD*af_thickness(WING_AIRFOIL)+TIP_CHORD*af_thickness(WING_AIRFOIL)) * PANEL_SPAN;
cross_section_mm = fuselage_cross_section + wing_cross_section;
cross_section_inch = cross_section_mm/sqr(24.5);
echo(str("cross-section: ", cross_section_mm, "mm^2 (", cross_section_inch, "sq.in., eq ", sqrt(cross_section_inch/PI)*2,"in. diameter)"));
