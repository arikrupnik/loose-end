# Makefile: rules for generating STL and auxiliary files from OpenSCAD sources

# The purpose of this file is less for dependency tracking (we're
# happy to generate each product on each invocation) and more for
# aiding command-line operatoin.

VPATH = variants:samples

BUILD_DIR = /tmp

%.stl: %.scad
	openscad -o ${BUILD_DIR}/$@ $<

fin.dxf:
	openscad -o ${BUILD_DIR}/$@ fin-projection.scad

clean:
	rm -f *stl *dxf *html
