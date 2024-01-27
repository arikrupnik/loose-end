include <BOSL2/std.scad>

$fn=64;

module boss() {
  difference() {
    cyl(d=6, d1=6.5, l=8, anchor=BOTTOM);
    cyl(d=2.6, l=20, anchor=CENTER);
  }
}

BOSS_CENTERS = [[15-(45/2), (50/2)-12, 0],
                [(45/2)-8.5, 16-(50/2), 0]];

module base_plate() {
  cube([45, 50, 1], anchor=BOTTOM);
  move([15-(45/2), (50/2)-12, 0]) {
    boss();
  }
  move([(45/2)-8.5, 16-(50/2), 0]) {
    boss();
  }
}

/* --- upper --- */

module antenna_mask() {
  up(9) {
      // antenna body
      cyl(d=9.2, l=64, anchor=BOTTOM);
      // screw
      cyl(d=3.5, l=10, anchor=TOP);
      down(5) {
        // contact plate
        cube([8.1, 10, 1.8], anchor=BOTTOM);
        // contact plate exit
        fwd(5) cuboid([8.1, 20, 10], chamfer=4, edges=BACK+TOP, anchor=BOTTOM+BACK);
        // nut
        back(3) cube([4, 20, 3.5], anchor=BOTTOM+BACK);
      }
      // screw head countersink
      down(6) cyl(d=6, l=10, anchor=TOP);
    }
}

module antenna_mount() {
  difference() {
    cyl(d=14, l=64, anchor=BOTTOM);
    antenna_mask();
  }
}

module crystal_mask(depth=20) {
  // main body
  cube([6.5,14,depth*2.1], anchor=CENTER);
  // rim
  cube([8,19,2], anchor=TOP);
  // finger grooves
  up(4) xcyl(d=15, l=20, rounding=5);
}

module move_antenna() {
  zmove(-5)
    xmove(-16.5)
      ymove(-32)
        xrot(-90)
          zrot(180)
            children();
}

module basic_box() {
  difference() {
    // main outline
    cube([48, 64, 24], anchor=TOP);
    // hollow out
    down(5) cube([45, 61, 20], anchor=TOP);
  }
}

module enclosure_top() {
  difference() {
    union() {
      // box
      basic_box();
      // antenna support
      move_antenna()
        antenna_mount();
      // bosses
      for(m = BOSS_CENTERS) {
        move(m) {
          zcyl(d=6, l=20, anchor=TOP);
          zcyl(d=8, l=12, anchor=TOP);
        }
      }
    }

    // opening for crystal
    move([1, -11, 0])
      crystal_mask();
    // cutout for antenna and feed
    move_antenna()
      antenna_mask();
    // bosses
    for(m = BOSS_CENTERS) {
      move(m) {
        zcyl(d=5.5, l=20);
        zcyl(d=5.3, l=18, anchor=TOP);
        zcyl(d=3, l=20, anchor=TOP);
      }
    }
  }
}

/* --- lower --- */

module jr_lower() {
  //difference() {
  //  cube([43, 59, 22], anchor=TOP);
  //  zmove(1) cube([39, 55, 5], anchor=TOP);
  //}
  move([-22, -30, -22]){
    import("jr_tx_module_body.stl");
  }
}

module enclosure_bottom() {
  // bottom
  jr_lower();
  // lip
  difference() {
    union() {
      cube([44.5, 61, 2], anchor=BOTTOM);
      difference() {
        cube([48, 64, 1], anchor=BOTTOM);
        // cutout for JR snaps
        cube([49, 17, 3], anchor=CENTER);
      }
    }
    cube([39,   55, 5], anchor=CENTER);
  }
  // bosses
  for(m = BOSS_CENTERS) {
    move(m) {
      zmove(2) {
        difference() {
          zcyl(d=6, d1=7, l=24, anchor=TOP);
          zcyl(d=2.6, l=8, anchor=TOP);
        }
      }
    }
  }
}


//xdistribute(50) {
  //enclosure_top();
  //difference() {
  //intersection() {
    enclosure_bottom();
//  cube([50, 80, 10], anchor=CENTER);
//}
//zcyl(d=15, l=20, anchor=CENTER);
//}
//}
