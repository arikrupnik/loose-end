// winger-fuse.scad: alternative fuselage for RadJet800 wings

include <airfoil.scad>
$airfoil_fn = 600;
include <BOSL2/std.scad>
use <rail_guides.scad>

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

module fuselage_seamless() {
    difference() {
        union() {
            // main outside shape
            rot([90,0,90]) linear_extrude(FUSELAGE_W, center=true) {
                n = A_CAMBER*100+A_THICKNESS;
                airfoil_poly(c=FUSELAGE_L, naca=n);
            }
            // front lug
            back(FUSELAGE_L*.4+.1) up(fuselage_h/2) rail_guide1010(20, 10);
            // rear lug (front conincides with cut line avoids the need for support)
            back(SPAR_C+SPAR_D)    up(fuselage_h/2) rail_guide1010(35, 13);
        }
        // MMT
        back(FUSELAGE_L) ycyl(l=FUSELAGE_L*2/3, d=MMT_D, anchor=BACK);
        // spar carrythrough
        back(SPAR_C) xcyl(l=FUSELAGE_W+10, d=SPAR_D);
        // wedge cutout
        wedge_L=80;
        back(FUSELAGE_L)
            prismoid(size1=[FUSELAGE_W-10,fuselage_h],
                size2=[MMT_D+4,fuselage_h],
                h=wedge_L,
                orient=FWD);
        // fuselage reference lines
        right(FUSELAGE_W/2) back(FUSELAGE_L) ycyl(d=.3,l=FUSELAGE_L/2, anchor=BACK);
        left (FUSELAGE_W/2) back(FUSELAGE_L) ycyl(d=.3,l=FUSELAGE_L/2, anchor=BACK);
        // cockpit (round front and rear to ease bribging)
        back(FUSELAGE_L*.1) cuboid([FUSELAGE_W*.8,FUSELAGE_L*.4,fuselage_h*.65], rounding=fuselage_h*.325, edges=[FRONT,BACK], anchor=FWD);
    }
}

module hatch_mask(shrink=0) {
    back(HATCH_F+shrink)
        cuboid([FUSELAGE_W*.7-shrink*2,HATCH_L-shrink*2,fuselage_h], rounding=FUSELAGE_W*.1+shrink, anchor=FWD+DOWN);
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
    cube([FUSELAGE_W*2, .1, fuselage_h*2], anchor=CENTER);
}

difference() {
    fuselage();
    back(HATCH_F+HATCH_L+10) cut();  // aft of hatch
    back(SPAR_C-SPAR_D) cut();  // fwd of carrythrough
    back(SPAR_C+SPAR_D) cut();  // aft of carrythrough
}
up(0) hatch();
