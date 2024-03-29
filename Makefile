# Makefile: rules for generating Loose End STL, DXF and G-code from
# OpenSCAD sources

# Requires GNU Make with Guile support which I use for string
# manipulation (e.g. apt-get install make-guile)

VPATH = variants:samples

# asking openscad to generate dependency files as a side effect:
# http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/
OPENSCAD = openscad -d $@.deps

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
loose_end_24.zip: \
	loose_end_24-fuselage-1.gcode \
        loose_end_24-fuselage-2.gcode \
	loose_end_24-fuselage-3.gcode \
	loose_end_24-fuselage-4.gcode \
	loose_end_24-hatch.gcode \
	loose_end_24-mmtbulkhead.gcode \
	loose_end_24-wing-1-r.gcode \
	loose_end_24-wing-1-l.gcode \
	loose_end_24-wing-2-r.gcode \
	loose_end_24-wing-2-l.gcode \
	loose_end_24-flat-parts-mm.dxf

loose_end_f86.zip: \
	loose_end_f86-fuselage-1.gcode \
	loose_end_f86-fuselage-2.gcode \
	loose_end_f86-fuselage-3.gcode \
	loose_end_f86-fuselage-4.gcode \
	loose_end_f86-fuselage-5.gcode \
	loose_end_f86-hatch.gcode \
	loose_end_f86-mmtbulkhead.gcode \
	loose_end_f86-flat-parts-mm.dxf

loose_end_rj.zip: \
	loose_end_rj-fuselage-1.gcode \
        loose_end_rj-fuselage-2.gcode \
	loose_end_rj-fuselage-3.gcode \
	loose_end_rj-fuselage-4.gcode \
	loose_end_rj-hatch.gcode \
	loose_end_rj-mmtbulkhead.gcode \
	loose_end_rj-flat-parts-mm.dxf


# Slicer settings

# base settigns (exported from slicer)
SLICER_BASE_INI = --load slicer-config/base-mk3s-0.15quality-prusamentPLA.ini

# most parts print using this light-weight configuration
%.gcode: \
	SLICER_FLAGS = --load slicer-config/single-wall.ini
# wing uses different infill
loose_end_24-wing%.gcode: \
	SLICER_FLAGS = --load slicer-config/single-wall-wing.ini
# spar carrythroughs need extra structure
loose_end_rj-fuselage-3.gcode loose_end_24-fuselage-3.gcode loose_end_f86-fuselage-4.gcode %-spartestblock.gcode : \
	SLICER_FLAGS = --load slicer-config/spar-carrythrough.ini
# MMT plugs use different fill pattern
%-mmtbulkhead.gcode: \
	SLICER_FLAGS = --load slicer-config/mmtbulkhead.ini


# STL from SCAD

# generic STL recipe, especially relevant for samples
%.stl: %.scad
	$(OPENSCAD) -o $@ $<

# common command for stemming
OPENSCAD_STEM_CL=$(OPENSCAD) -o $@ $(guile (D "$*")) $<

# repeat for each variant :=(
loose_end_rj-%.stl: loose_end_rj.scad
	${OPENSCAD_STEM_CL}
loose_end_24-%.stl: loose_end_24.scad
	${OPENSCAD_STEM_CL}
loose_end_f86-%.stl: loose_end_f86.scad
	${OPENSCAD_STEM_CL}

# DXF from SCAD for CNC cutting
%-flat-parts-mm.dxf: %.scad
	$(OPENSCAD) -o $@ -Doutput=\"flat-parts\" -Dunits=\"mm\" $<
%-flat-parts-inch.dxf: %.scad
	$(OPENSCAD) -o $@ -Doutput=\"flat-parts\" -Dunits=\"inch\" $<

# including available dependency files (comment in OPENSCAD= above)
include $(wildcard *.deps)


# G-CODE from STL

# it's a little lazy to list all slicer config files as dependencies,
# but slicing is relatively cheap and it avoids cluttering the
# makefile
%.gcode: %.stl $(wildcard slicer-config/*ini)
	${SLICER} -g -o $@ ${SLICER_BASE_INI} ${SLICER_FLAGS} $<

# archiving

%.zip:
	zip $@ $(foreach g,$(filter %.gcode,$+),$(basename $g).stl) $+
	cp $@ $*-$(shell git describe --tags --dirty).zip


# Housekeeping

clean:
	rm -fv *stl *dxf *gcode *zip *deps
.PHONY: clean

# keep intermediate files (STLs are only intermediate files right now)
.SECONDARY:

# discard built-in suffix rules
.SUFFIXES:


# Guile code at the bottom of file to preserve font-lock-mode's sanity

define GUILED
(use-modules (srfi srfi-1))  ; for mapping unequal-length lists

(define (double-quote s)  ; for string parameters
  (string-append "\\\"" s "\\\""))

(define param-names '("output" "segment" "side")) ;' segment is numeric

(define param-quotes (list double-quote values double-quote)) ;

(define (D stem)
  (map (lambda (param-name param-quote value)
         (string-append "-D " param-name "=" (param-quote value)))
       param-names
       param-quotes
       (string-split stem #\-)))
;# (D "wing-1-r") -> -Doutput=\"wing\" -Dsegment=1 -Dside=\"r\"
endef
$(guile $(GUILED))
