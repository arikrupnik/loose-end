# Makefile: rules for generating Loose End STL, DXF and G-code from
# OpenSCAD sources

# Requires GNU Make with Guile support which I use for string
# manipulation (e.g. apt-get install make-guile)

VPATH = variants:samples

SLICER = PrusaSlicer-2.5.0+linux-x64-GTK3-202209060725.AppImage

# it takes over a minute to render each fuselage STL; running jobs in
# parallel, with multiple cores, means the total runtime is 1.3
# minutes instead of 6
MAKEFLAGS += -j 8

# Each OpenSCAD model is the source for multiple ouput files. Print
# volume and orientation limitations dictate partitioning into
# multiple STLs; DXFs for CNC cutting sheet stock; etc. I use the
# following filename convention for STL and GCODE:
# base_model_name-component-segment-side.stl `segment' and `side' are
# optional. Examples:
#
# loose_end_rj-hatch.stl
# loose_end_rj-fuselage-1.stl
# loose_end_rj-wing-2-r.stl
#
# Some of the knowledge about the structure of each model is in this
# makefile rather than the OpenSCAD code. This includes the number of
# segments and print settings for different STLs. I welcome ideas on
# reducing this abstraction leakage.


# Target sets for each variant

# current development target and default goal
loose_end_rj: \
	loose_end_rj-fuselage-1.gcode \
        loose_end_rj-fuselage-2.gcode \
	loose_end_rj-fuselage-3.gcode \
	loose_end_rj-fuselage-4.gcode \
	loose_end_rj-hatch.gcode \
	loose_end_rj-flat-parts-mm.dxf

loose_end_24: \
	loose_end_24-fuselage-1.gcode \
        loose_end_24-fuselage-2.gcode \
	loose_end_24-fuselage-3.gcode \
	loose_end_24-fuselage-4.gcode \
	loose_end_24-hatch.gcode \
	loose_end_24-flat-parts-mm.dxf


# Slicer settings

# base settigns (exported from slicer)
SLICER_BASE_INI = --load slicer-config/base-mk3s-0.15quality-prusamentPLA.ini

# most parts print using this light-weight configuration
%.gcode: \
	SLICER_FLAGS = --load slicer-config/single-wall.ini
# spar carrythroughs need extra structure
loose_end_rj-fuselage-3.gcode loose_end_24-fuselage-3.gcode : \
	SLICER_FLAGS = --load slicer-config/spar-carrythrough.ini
# MMT plugs use different fill pattern
%-mmtplug.gcode: \
	SLICER_FLAGS = --load slicer-config/motor-plug.ini


# STL from SCAD

%.stl: %.scad  # generic STL recipe
	openscad -o $@ $<

# common command for stemming
OPENSCAD_STEM_CL=openscad -o $@ $(guile (D "$*")) $<

# repeat for each variant :=(
loose_end_rj-%.stl: loose_end_rj.scad
	${OPENSCAD_STEM_CL}
loose_end_24-%.stl: loose_end_24.scad
	${OPENSCAD_STEM_CL}

# DXF from SCAD for CNC cutting
%-flat-parts-mm.dxf: %.scad
	openscad -o $@ -Doutput=\"flat-parts\" -Dunits=\"mm\" $<
%-flat-parts-inch.dxf: %.scad
	openscad -o $@ -Doutput=\"flat-parts\" -Dunits=\"inch\" $<


# G-CODE from STL

%.gcode: %.stl
	${SLICER} -g -o $@ ${SLICER_BASE_INI} ${SLICER_FLAGS} $<


# Housekeeping

clean:
	rm -fv *stl *dxf *gcode
.PHONY: clean

# keep intermediate files (STLs are only intermediate files right now)
.SECONDARY:


# Guile code at the bottom of file to preserve font-lock-mode's sanity

define GUILED
(use-modules (srfi srfi-1))  ; for mapping unequal-length lists

(define (double-quote s)  ; for string parameters
  (string-append "\\\"" s "\\\""))

(define param-names '("output" "segment" "side")) ;' segment is numeric

(define param-quotes (list double-quote values double-quote)) ;'

(define (D stem)
  (map (lambda (param-name param-quote value)
         (string-append "-D " param-name "=" (param-quote value)))
       param-names
       param-quotes
       (string-split stem #\-)))
;# (D "wing-1-r") -> -Doutput=\"wing\" -Dsegment=1 -Dside=\"r\"
endef
$(guile $(GUILED))
