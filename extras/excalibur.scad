// excaliburd: rocket MMT for HobbyKing Excalibur warmliner

include <BOSL2/std.scad>
include <../airfoil.scad>

$fn=128;

SPAR_D_FRONT = 6.2; // front spar diameter
SPAR_D_REAR = 6.2;  // rear spar diameter
SPAR_CENTERS=29;    // distance between spars front-to-back
PYLON_CENTERS=20;   // distance between pylons, left-to-right
PYLON_H = 50;       // distance between MMT center and spar centers, top-to-bottom
MMT_ID = 31.7;      // cardboard tube OD, plastic tube ID (was 31.5, 32)
MMT_OD = MMT_ID+1;  // plastic tube OD
MMT_L = 120;        // cardboard tube length
NC_L = 40;          // nose cone length

module mmt_cutout() {
  zmove(-0.5) {
    zcyl(d=MMT_ID, l=MMT_L+1, circum=true, anchor=BOTTOM);}
}

module mmt() {
  zcyl(d=MMT_OD, l=MMT_L, circum=true, anchor=BOTTOM);
}

module pylon(mount_tab_th=2, margin=SPAR_D_FRONT+SPAR_D_REAR) {
  h = SPAR_CENTERS+margin*1.5;
  zmove(h/2) {
    difference() {
      union() {
        cube([mount_tab_th, margin*1.5, h],
             anchor=CENTER);
        cube([mount_tab_th, PYLON_H, h],
             anchor=CENTER+BACK);}
      for(c=[[-1,SPAR_D_REAR],[1,SPAR_D_FRONT]]) {
        zmove(c[0]*SPAR_CENTERS/2)
          xcyl(d=c[1], l=mount_tab_th*1.5, circum=true);}}}}

module nosecone() {
  af_l = NC_L/3*10;
  af_th = MMT_OD / af_l * 100;
  top_half() {
    zmove(NC_L) {
      rotate_extrude() {
        zrot(270) {
          difference() {
            polygon(filter(function(p) p.y>=0, airfoil(af_th, af_l)));
            polygon(filter(function(p) p.y>=0, airfoil(af_th, af_l, shave=1)));}}}}}}

difference() {
  union() {
    mmt();
    zmove(MMT_L) {
      nosecone();}
    for(p=[-0.5, 0.5]) {
      xmove(p*PYLON_CENTERS) {
        ymove(PYLON_H) {
          pylon();}}}}
  mmt_cutout();}

/*
  Perimeters: 1
  Seam Position: Rear

  Top Fill Pattern: Concentric

  Skirt Loops: 0
  Brim Width: 3mm
 */
