// fuselage.scad: fuselage for Loose End rocket glider

include <airfoil.scad>
include <BOSL2/std.scad>
use <rail_guides.scad>
use <fc_mount.scad>
use <latch.scad>
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
        back(HATCH_F+HATCH_L-5) up(FUSELAGE_H/2) rail_guide1010(20, FUSELAGE_H/2);
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
          ycyl(d=.3,l=ROOT_CHORD, anchor=BACK);
    // pitot tube
    union() {
      ycyl(l=PITOT_TUBE_L, d=PITOT_TUBE_D, anchor=FRONT);
      back(PITOT_TUBE_L - PITOT_TUBE_D/2) ycyl(l=20, d=PITOT_TUBE_D*2, rounding=PITOT_TUBE_D, anchor=FRONT);
    }
    // cockpit (chamfer front and rear to ease bribging)
    back(PITOT_TUBE_L)  // far enough forward to meet pitot tube
      cuboid([FUSELAGE_W*.8,FUSELAGE_L*.4,cockpit_h],
             chamfer=cockpit_h/2,
             edges=[FRONT,BACK],
             anchor=FWD);
    // flight contoller mount
    back(FUSELAGE_L*.35) down(cockpit_h/2) fc_mount();
    // servo wire channels
    xflip_copy()
      right((FUSELAGE_W-MMT_OD)/2)
        back(FUSELAGE_L - ROOT_CHORD +  SERVO_WIRE_TUNNEL_EXIT) {
          // longitudinal
          ycyl(l=FUSELAGE_L*.3, d=SERVO_WIRE_TUNNEL_D, anchor=BACK);
          // transverse: exit
          xcyl(l=FUSELAGE_W*.4, d=SERVO_WIRE_TUNNEL_D, anchor=LEFT+BACK);
          // igniter wire (spring) exit
          xrot(25) ycyl(l=FUSELAGE_L*.1, d=4.75, anchor=FORWARD+DOWN);
        }
    // cockpit hatch latch
    back(HATCH_F + HATCH_L) up(cockpit_h/2 + 10) latch();
  }
}

module hatch_mask(gap=0) {
  trapeze_h = HATCH_L * .2;
  trapeze_top = 2;
  back(HATCH_F) {
    linear_extrude(FUSELAGE_H)
      round2d(r=FUSELAGE_W*.03) {
        difference() {
          union() {
            back(trapeze_h) square([HATCH_W, HATCH_L-trapeze_h], anchor=FWD);
            trapezoid(h=trapeze_h, w1=trapeze_top, w2=HATCH_W, anchor=FWD);
          }
          shell2d(-gap) {
            back(trapeze_h) square([HATCH_W, HATCH_L-trapeze_h], anchor=FWD);
            trapezoid(h=trapeze_h, w1=trapeze_top, w2=HATCH_W, anchor=FWD);
          }
        }
    }
  }
}

module fuselage() {
    difference() {
        fuselage_seamless();
        hatch_mask();
    }
    // hatch lips
    up(cockpit_h/2) back(HATCH_F) cube([FUSELAGE_W, 10, 1], anchor=TOP);
    up(cockpit_h/2) back(HATCH_F+HATCH_L) cube([FUSELAGE_W, 10, 1], anchor=TOP);
}

module hatch() {
    intersection() {
        fuselage_seamless();
        hatch_mask(.1);
        // round off the rear to ease opening and closing
        up(foil_y(HATCH_F, FUSELAGE_L, FUSELAGE_THICKNESS))
          back(HATCH_F)
            xcyl(l=HATCH_W, r=HATCH_L, $fn=360);
    }
}

module fuse_cut(l) {
  back(l) cube([FUSELAGE_W*2, .1, FUSELAGE_H*2], anchor=CENTER);
}


