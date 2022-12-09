# Makefile: rules for generating STL and auxiliary files from OpenSCAD sources

# The purpose of this file is less for dependency tracking (we're
# happy to generate each product on each invocation) and more for
# aiding command-line operation.

VPATH = variants:samples

BUILD_DIR = /tmp

%.stl: %.scad
	openscad -o ${BUILD_DIR}/$@ $<

%-fuselage.stl: %.scad
	openscad -o ${BUILD_DIR}/$@ -Doutput=\"fuselage\" $<

%-hatch.stl: %.scad
	openscad -o ${BUILD_DIR}/$@ -Doutput=\"hatch\" $<

%-fin.stl: %.scad
	openscad -o ${BUILD_DIR}/$@ -Doutput=\"fin\" $<

%-rib-template.stl: %.scad
	openscad -o ${BUILD_DIR}/$@ -Doutput=\"rib-template\" $<

%-flat-parts-mm.dxf: %.scad
	openscad -o ${BUILD_DIR}/$@ -Doutput=\"flat-parts\" -Dunits=\"mm\" $<

%-flat-parts-inch.dxf: %.scad
	openscad -o ${BUILD_DIR}/$@ -Doutput=\"flat-parts\" -Dunits=\"inch\" $<

clean:
	rm -f ${BUILD_DIR}/*stl ${BUILD_DIR}/*dxf #${BUILD_DIR}/*html
