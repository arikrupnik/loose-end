

include <BOSL2/std.scad>
include <../servo_pocket.scad>

servo_names = struct_keys(SERVOS);
for (i=[0:len(servo_names)-1]) {
  name = servo_names[i];
  s_struct = struct_val(SERVOS, name);
  ymove(i*50) {
    // "plug"
    servo_pocket_vertical(s_struct);
    // pocket
    left(30)
      difference() {
        fwd(10) up(10) cube([20, 40, 30], anchor=TOP+FWD);
        servo_pocket_vertical(s_struct);
        fwd(-10) down(19) yrot(180) linear_extrude(2) text(name, 7, spin=90, anchor=TOP+FWD);
    }
  }
}
