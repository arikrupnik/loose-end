// camera-mount.scad: mounting plate for ZR10 on the BULLY crawler
// chassis; includes bolt patter for flight controller.

include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn=64;

PLATE_H=8;

CHASSIS_MOUNTING_L=98.5;
CHASSIS_MOUNTING_W=32.8;
CHASSIS_MOUNTING_CLEARANCE_D=2.7;

CAMERA_MOUNTING_L=22.5;
CAMERA_MOUNTING_W=60;
CAMERA_MOUNTING_CLEARANCE_D=3.2;
CAMERA_MOUNTING_NUT_W=5.7;
CAMERA_MOUNTING_NUT_H=2.5;

FC_MOUNTING_L=30.5;  // mounting hole pattern distance on center

module zr10_holes() {
  // cutouts for stud screwheads
  for(x=[-1,1], y=[-1,1]) {
    translate([x*CAMERA_MOUNTING_W/2, y*CAMERA_MOUNTING_L/2, 0]) {
      zcyl(2, d=6, anchor=CENTER+TOP);
    }
  }
  // left and right sets of holes
  for(x=[-35,35], y=[-15,0,15]) {
    translate([x,y]) {
      zcyl(PLATE_H, d=CAMERA_MOUNTING_CLEARANCE_D, circum=true, anchor=CENTER+TOP);
      // nut recess
      down(PLATE_H) {
        linear_extrude(height=CAMERA_MOUNTING_NUT_H) {
          hexagon(id=CAMERA_MOUNTING_NUT_W);
        }
      }
    }
  }
  // front and back sets of holes
  for(x=[-20,0,20], y=[-27.5,27.5]) {
    translate([x,y]) {
      zcyl(PLATE_H, d=CAMERA_MOUNTING_CLEARANCE_D, circum=true, anchor=CENTER+TOP);
      // nut recess
      down(PLATE_H) {
        linear_extrude(height=CAMERA_MOUNTING_NUT_H) {
          hexagon(id=CAMERA_MOUNTING_NUT_W);
        }
      }
    }
  }
}


// horizontal plate
difference() {
  union() {
    // platform
    cube([50,140,PLATE_H], anchor=TOP);
    cube([80, 80,PLATE_H], anchor=TOP);
  }
  // holes for mounting plate to chassis
  for(x=[-1,0,1], y=[-1,1]) {
    translate([x*CHASSIS_MOUNTING_W/2, y*CHASSIS_MOUNTING_L/2, 0]) {
      zcyl(PLATE_H, d=CHASSIS_MOUNTING_CLEARANCE_D, circum=true, anchor=CENTER+TOP); // hole for screw
      zcyl(PLATE_H-3, d=5, anchor=CENTER+TOP); // hole for screwhead
    }
  }
  // camera mounting holes
  fwd(14) {
    zr10_holes();
    // tripod mount screw under camera
    $slop=0.1;
    screw_hole("1/4-20", l=PLATE_H+1, anchor=TOP, thread=true);
  }
}

// vertical plate for FC
back(30) {
  difference() {
    front_half() {
      prismoid([55,PLATE_H*2], [55,PLATE_H], h=37);
    }
    up(3.5) {
      xrot(90) {
        for(x=[-0.5,0.5], y=[0,1]) {
          translate([x*FC_MOUNTING_L, y*FC_MOUNTING_L, 0]) {
            zcyl(PLATE_H, d=2, anchor=CENTER+BOTTOM);
          }
        }
      }
    }
  }
}

// GPS tower

back(70) {
  difference() {
    zcyl(d=30, l=125, anchor=BOTTOM);
    zcyl(d=28, l=125, anchor=BOTTOM);
  }
  back_half() {
    zcyl(d=50, l=PLATE_H, anchor=TOP);
  }
}
