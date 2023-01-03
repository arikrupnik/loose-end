// loose_end.scad: main

include <BOSL2/std.scad>
include <fuselage.scad>
include <mmtbulkhead.scad>
include <fins.scad>
include <wing.scad>

$fn=64;

// Runtime parameters, mainly for manipulation through the makefile
output = undef;
segment = undef;
// All dimensions in this project are in mm. Both STL and DXF use
// implicit units. All STL workflows so far use mm. A vendor that uses
// DXF requires inch dimensions.
units = "mm";

scale_factor = units=="inch" ? 1.0/25.4 : 1.0;

scale([scale_factor, scale_factor, scale_factor]) {

  // fuselage parts and marks
  cg_marks=[for (cg = [.15,.2,.25])
    mac_setback(WING_PANELS) + mac_length(WING_PANELS)*cg];

  // main fuselage
  if(output==undef)
    difference() {
      fuselage(cg_marks);
      fuse_cuts();
    }
  else if(output=="fuselage")
    if(segment)
      fuselage_segment(cg_marks, segment);
    else
      fuselage(cg_marks);

  // fuselage hatch
  if(output==undef)
    up(50)
      hatch(cg_marks);
  else if(output=="hatch")
    zrot(180)
      xrot(-90)
        hatch(cg_marks);

  // MMT bulkhead
  if(output==undef)
    back(HATCH_F+HATCH_L)
      xrot(-90)
        mmtbulkhead();
  else if(output=="mmtbulkhead")
    mmtbulkhead();

  // fins
  if(output==undef)
    %xflip_copy()
       ymove(FUSELAGE_L - ROOT_CHORD) xmove(FUSELAGE_W/2 + CUT_WIDTH)
         yrot(90)
           linear_extrude(SHEET_THICKNESS)
             zrot(90)
               fin_outline();
  if(output=="fin")  // 3D for prototyping
    linear_extrude(SHEET_THICKNESS)
      fin_outline();

  // wing
  if(output==undef)
    xflip_copy()
      back(FUSELAGE_L-ROOT_CHORD)
        right(FUSELAGE_W/2)
          difference() {
            wing(ROOT_CHORD, TIP_CHORD, LE_SWEEP, PANEL_SPAN, WING_AIRFOIL)
              spar(SPAR_C_ROOT, SPAR_D, PANEL_SPAN);
            wing_cuts();
          }
  else if(output=="wing")
    if(segment)
      wing_segment(segment, side);
    else
      wing(ROOT_CHORD, TIP_CHORD, LE_SWEEP, PANEL_SPAN, WING_AIRFOIL)
        spar(SPAR_C_ROOT, SPAR_D, PANEL_SPAN);

  // single-layer template for marking cutouts in foam cores
  if(output=="rib-template")
    linear_extrude(0.2)
      root_rib();

  // 2D for DXF generation
  if(output=="flat-parts") {
    xflip_copy()
      right(WING_TANG_L)
        fin_outline();
    projection()
      for(c=[1:4])
        back(c*WING_TANG_W*1.5)
          wing_tang(WING_TANG_L, WING_TANG_W, SHEET_THICKNESS, WING_SCREW_D);
  }
}

module print_measurements() {
  echo(str("root chord: ", ROOT_CHORD, "mm; tip chrod: ", TIP_CHORD, "mm; ",
           "half-span: ", PANEL_SPAN, "mm; spar diameter: ", SPAR_D, "mm; ",
           "spar center from root LE: ", SPAR_C-(FUSELAGE_L-ROOT_CHORD), "mm"));
  echo(str("fuselage-length: ", FUSELAGE_L, "; width: ", FUSELAGE_W));

  fuselage_cross_section = FUSELAGE_W*FUSELAGE_H;
  wing_cross_section = (ROOT_CHORD*af_thickness(WING_AIRFOIL)+TIP_CHORD*af_thickness(WING_AIRFOIL)) * PANEL_SPAN;
  cross_section_mm = fuselage_cross_section + wing_cross_section;
  cross_section_inch = cross_section_mm/sqr(24.5);
  echo(str("cross-section: ", cross_section_mm, "mm^2 ",
           "(", cross_section_inch, "sq.in., ",
           "eq ", sqrt(cross_section_inch/PI)*2,"in. diameter)"));
}

if(output==undef || output=="measurements")
  print_measurements();
