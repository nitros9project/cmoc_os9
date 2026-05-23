# Top-level build driver for the CMOC OS-9 library, tests, and utilities.

.PHONY: all libs tests utils clean clean-libs clean-tests clean-utils \
        clean-recipe dsk run unittest-dsk unittest-run lib cgfx unittest help

# Build libs, tests, and utils (default target)
all: libs tests utils

# Build the lib/ and cgfx/ static libraries
libs: lib cgfx

# Build the lib/ static library (libc.a, libcf.a)
lib:
	$(MAKE) -C lib

# Build the cgfx/ static library (libcgfx.a)
cgfx:
	$(MAKE) -C cgfx

# Build the unit tests (depends on libs)
tests: libs
	$(MAKE) -C unittest

# Build the utils (depends on libs)
utils: libs
	$(MAKE) -C utils

# Build the CoCo 3 NitrOS-9 cmoc_os9 test disk
dsk:
	$(MAKE) -C recipes/coco3

# Build the standalone unit-test disk image
unittest-dsk: libs
	$(MAKE) -C unittest dsk

# Build the CoCo 3 NitrOS-9 cmoc_os9 test disk and launch MAME
run:
	$(MAKE) -C recipes/coco3 run

# Build the standalone unit-test disk and launch MAME
unittest-run: libs
	$(MAKE) -C unittest run

# Remove build artifacts in libs, tests, and utils
clean: clean-tests clean-utils clean-libs clean-recipe

# Remove build artifacts in cgfx/ and lib/
clean-libs:
	$(MAKE) -C cgfx clean
	$(MAKE) -C lib clean

# Remove build artifacts in unittest/
clean-tests:
	$(MAKE) -C unittest clean

# Remove build artifacts in utils/
clean-utils:
	$(MAKE) -C utils clean

# Remove recipe disk-image build artifacts
clean-recipe:
	$(MAKE) -C recipes/coco3 clean

# Display this help message listing available phony targets
help:
	@echo "Available targets:"
	@awk 'BEGIN{c=""} /^# /{c=substr($$0,3); next} /^[a-zA-Z_][a-zA-Z0-9_.-]*:/{if(c!=""){t=$$1; sub(/:.*/,"",t); printf "  %-20s %s\n", t, c}; c=""; next} {c=""}' $(MAKEFILE_LIST)
