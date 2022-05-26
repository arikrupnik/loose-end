// fuselage.scad: fuselage for Loose End rocket glider

include <airfoil.scad>
include <BOSL2/std.scad>
use <rail_guides.scad>
use <fc_mount.scad>
use <latch.scad>
use <wing-tang.scad>
include <parameters.inc>

// fuselage before cutouts
module fuselage_seamless() {
  difference() {
    union() {
        // main outside shape
        rot([90,0,90]) linear_extrude(FUSELAGE_W, center=true) {
          n = 00*100+FUSELAGE_THICKNESS*100;
          airfoil_poly(c=FUSELAGE_L, naca=n);
        }
        // front lug
        back(HATCH_F+HATCH_L) up(FUSELAGE_H/2) rail_guide1010(15, FUSELAGE_H/2);
        // rear lug (front conincides with cut line avoids the need for support)
        rear_lug_s = SPAR_C - SPAR_D;
        rear_lug_e = FUSELAGE_L - THRUST_PLATE_OFFSET;
        rear_lug_l = rear_lug_e - rear_lug_s;
        back(rear_lug_s) up(FUSELAGE_H/2) rail_guide1010(rear_lug_l, FUSELAGE_H/2);
    }
    // MMT
    back(FUSELAGE_L) ycyl(l=FUSELAGE_L*2/3, d=MMT_OD, anchor=BACK);
    // spar carrythrough
    back(SPAR_C) xcyl(l=FUSELAGE_W+10, d=SPAR_D);
    // wedge cutout
    back(FUSELAGE_L)
      prismoid(size1=[FUSELAGE_W*.85,FUSELAGE_H],
               size2=[MOTOR_D*1.25,FUSELAGE_H],
               h=THRUST_PLATE_OFFSET,
               orient=FWD);
    // fuselage reference lines
    xflip_copy()
      right(FUSELAGE_W/2)
        back(FUSELAGE_L)
          ycyl(d=SCRIBE_LINE_W,l=ROOT_CHORD+5, anchor=BACK);
    // pitot tube
    union() {
      ycyl(l=PITOT_TUBE_L, d=PITOT_TUBE_D, anchor=FRONT);
      back(PITOT_TUBE_L - PITOT_TUBE_D/2) ycyl(l=20, d=PITOT_TUBE_D*2, rounding=PITOT_TUBE_D, anchor=FRONT);
    }
    // cockpit (chamfer front and rear to ease bribging)
    back(PITOT_TUBE_L)  // far enough forward to meet pitot tube
      cuboid([FUSELAGE_W*.8,FUSELAGE_L*.4,COCKPIT_H],
             chamfer=COCKPIT_H/2,
             edges=[FRONT,BACK],
             anchor=FWD);
    // front latch
    back(HATCH_F + 3.5) up(COCKPIT_H/2 + 8) yflip() latch();
    // rear latch
    back(HATCH_F + HATCH_L) up(COCKPIT_H/2 + 10) latch();
    // flight contoller mount
    back(FUSELAGE_L*.35) down(COCKPIT_H/2) fc_mount();

    // servo wire channels
    tunnel_x_start = (MMT_OD+SERVO_WIRE_TUNNEL_D)/2 + EXTRUSION_W;
    tunnel_y_start = HATCH_F+HATCH_L;
    tunnel_x_exit = FUSELAGE_W/2;
    tunnel_y_exit = FUSELAGE_L - ROOT_CHORD + SERVO_WIRE_TUNNEL_EXIT;
    tunnel_x_l = (tunnel_x_exit - tunnel_x_start)/1.4;
    tunnel_path = [[tunnel_x_start, tunnel_y_start],
                   [tunnel_x_start, tunnel_y_exit-tunnel_x_l],
                   [tunnel_x_start+tunnel_x_l, tunnel_y_exit],
                   [tunnel_x_exit+.1,  tunnel_y_exit]
                   ];
    xflip_copy()
      path_extrude2d(tunnel_path)
        circle(d=SERVO_WIRE_TUNNEL_D);
    // igniter wire (spring) channels
    xflip_copy()
      right(tunnel_x_start)
        back(tunnel_y_exit-tunnel_x_l)
          xrot(10)
            ycyl(l=FUSELAGE_L*.25, d=4.7, anchor=FWD+DOWN);
    // wing tang pockets with screw holes
    xflip_copy()
      right(FUSELAGE_W/2)
        for(p=WING_TANGS)
          back(FUSELAGE_L - ROOT_CHORD + p)
            tang_pocket(WING_TANG_L, WING_TANG_W, SHEET_THICKNESS, WING_SCREW_D, WING_SCREW_L);
  }
}

module hatch_mask(gap=0) {
  trapeze_h = HATCH_L * .15;
  trapeze_top = 2;
  back(HATCH_F) {
    linear_extrude(FUSELAGE_H)
      round2d(r=FUSELAGE_W*.03) {
        back(gap) trapezoid(h=trapeze_h, w1=trapeze_top, w2=HATCH_W-gap, anchor=FWD);
        back(gap+trapeze_h) square([HATCH_W-gap, HATCH_L-trapeze_h-gap*2], anchor=FWD);
      }
  }
}

module hatch_lips(gap=0) {
  width = 10;
  thickness = .8;
  // fwd lip
  up(COCKPIT_H/2) back(HATCH_F) cube([FUSELAGE_W, width-gap, thickness], anchor=BOTTOM);
  // aft shelf - note no gap, hatch lies on top of shelf
  up(COCKPIT_H/2) back(HATCH_F+HATCH_L) cube([FUSELAGE_W, width-gap, thickness], anchor=BOTTOM);
}

module fuselage() {
  difference() {
    fuselage_seamless();
      hatch_mask();
  }
  hatch_lips(.5);
}

module hatch() {
  difference() {
    intersection() {
      fuselage_seamless();
      hatch_mask(.3);
    }
    hatch_lips();
  }
}

module fuse_cut(l) {
  back(l) cube([FUSELAGE_W*2, CUT_WIDTH, FUSELAGE_H*2], anchor=CENTER);
}


