include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn=64;

/*
difference() {
  screw(struct_set(screw_info("M16x1.5", head="hex"),
                   ["head_size",19, "head_height",4]),
        length=20, thread_len=10, blunt_start=false, anchor=TOP);

  screw_hole(struct_set(screw_info("M10x1.5", head="socket"),
                        ["head_size",10.5, "head_height",7]),
             length=17, thread=true, blunt_start=false, tolerance="7G", bevel=true, anchor=TOP);
}
*/

nut("M16x1.5", thickness=5, nutwidth=20, ibevel=false); //, tolerance="7G");
