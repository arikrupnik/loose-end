# Makefile: rules for generating STL and auxiliary files from OpenSCAD sources

# The purpose of this file is less for dependency tracking (we're
# happy to generate each product on each invocation) and more for
# aiding command-line operation.

VPATH = variants:samples

SLIC3R = PrusaSlicer-2.5.0+linux-x64-GTK3-202209060725.AppImage
BASE_INI = slicer-config/base-mk3s-0.15quality-prusamentPLA.ini

.PHONY: clean

# STL from SCAD

%.stl: %.scad
	openscad -o $@ $<

%-fuselage.stl: %.scad
	openscad -o $@ -Doutput=\"fuselage\" $<

%-hatch.stl: %.scad
	openscad -o $@ -Doutput=\"hatch\" $<

%-fin.stl: %.scad
	openscad -o $@ -Doutput=\"fin\" $<

%-rib-template.stl: %.scad
	openscad -o $@ -Doutput=\"rib-template\" $<

%-flat-parts-mm.dxf: %.scad
	openscad -o $@ -Doutput=\"flat-parts\" -Dunits=\"mm\" $<

%-flat-parts-inch.dxf: %.scad
	openscad -o $@ -Doutput=\"flat-parts\" -Dunits=\"inch\" $<


# G-CODE from STL

%.gcode: %.stl
	${SLIC3R} -g -o $@ --load ${BASE_INI} --load slicer-config/single-wall.ini $<


clean:
	rm -fv *stl *dxf *gcode
