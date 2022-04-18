// fc_mount-sample.scad: example using flight controller mount

include <../fc_mount.scad>

difference() {
    cube([60,40,3], anchor=CENTER+TOP);
    
    down(0.5) linear_extrude(1) text("TOP", valign="baseline", anchor=CENTER+TOP);
    
    fc_mount();
}
