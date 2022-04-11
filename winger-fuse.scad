// winger-fuse.scad: alternative fuselage for RadJet800 wings

include <airfoil.scad>
$airfoil_fn = 600;
include <BOSL2/std.scad>

$fn=64;

MMT_D = 25.6;
SPAR_D = 5.5;
FUSELAGE_W = 65;
FUSELAGE_L = 420;
A_CAMBER = 00;
A_THICKNESS = 12;
fuselage_h = FUSELAGE_L * (A_THICKNESS/100);
SPAR_C=FUSELAGE_L-140;  // center; 140=spar center distance from wing trailing edge

HATCH_F = FUSELAGE_L*.15;  // front
HATCH_L = FUSELAGE_L*.25;

module rail_guide1010(length, extra_h=0) {
    NORMAL_STEM_h = 5;
    STEM_h = NORMAL_STEM_h + extra_h;
    fwd(extra_h)
    difference() {
        union() {
            // horizontal
            back(STEM_h) cube([length, 1.5, 10], anchor=LEFT+FWD);
            // stem
            cube([length, STEM_h, 6], anchor=LEFT+FWD);
        }
        // cutout
        back(2.5) cube([length, STEM_h, 2.5], anchor=LEFT+FWD);
    }
}

module fuselage_seamless() {
    difference() {
        union() {
            // main outside shape
            linear_extrude(65, center=true) {
                n = A_CAMBER*100+A_THICKNESS;
                airfoil_poly(c=FUSELAGE_L, naca=n);
            }
            // front lug
            right(FUSELAGE_L*.4+.1) back(fuselage_h/2) rail_guide1010(20, 10);
            // rear lug (front conincides with cut line avoids the need for support)
            right(SPAR_C+SPAR_D)    back(fuselage_h/2) rail_guide1010(35, 13);
        }
        // MMT
        right(50) xcyl(l=FUSELAGE_L, d=MMT_D, anchor=LEFT);
        // spar carrythrough
        right(SPAR_C) zcyl(l=FUSELAGE_W+10, d=SPAR_D);
        // wedge cutout
        wedge_L=80;
        right(FUSELAGE_L-wedge_L)
            prismoid(size1=[MMT_D+4,fuselage_h],
                size2=[FUSELAGE_W-10,fuselage_h],
                h=-wedge_L,
                orient=LEFT);
        // fuselage reference lines
        up  (FUSELAGE_W/2) right(FUSELAGE_L/2) cube([FUSELAGE_L/2, .3, .3], anchor=LEFT);
        down(FUSELAGE_W/2) right(FUSELAGE_L/2) cube([FUSELAGE_L/2, .3, .3], anchor=LEFT);
        // cockpit (round front and rear to ease bribging)
        right(FUSELAGE_L*.1) cuboid([FUSELAGE_L*.4,fuselage_h*.65,FUSELAGE_W*.8], rounding=fuselage_h*.325, edges=[LEFT, RIGHT], anchor=LEFT);
    }
    // launch lugs
}

module hatch_mask(shrink=0) {
    right(HATCH_F+shrink)
        cuboid([HATCH_L-shrink*2,fuselage_h,FUSELAGE_W*.7-shrink*2], rounding=FUSELAGE_W*.1+shrink, anchor=LEFT+FRONT);
}

module fuselage() {
    difference() {
        fuselage_seamless();
        hatch_mask();
    }
}

module hatch() {
    intersection() {
        fuselage_seamless();
        hatch_mask(.1);
    }
}

module cut() {
    cube([.1,fuselage_h*2,FUSELAGE_W*2], anchor=CENTER);
}

difference() {
    fuselage();
    right(HATCH_F+HATCH_L+10) cut();  // aft of hatch
    right(SPAR_C-SPAR_D) cut();  // fwd of carrythrough
    right(SPAR_C+SPAR_D) cut();  // aft of carrythrough
}
back(0) hatch();
