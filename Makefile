# Top-level build driver for the CMOC OS-9 library, tests, and utilities.

.PHONY: all libs tests utils clean clean-libs clean-tests clean-utils dsk run \
        lib cgfx unittest

all: libs tests utils

libs: lib cgfx

lib:
	$(MAKE) -C lib

cgfx:
	$(MAKE) -C cgfx

tests: libs
	$(MAKE) -C unittest

utils: libs
	$(MAKE) -C utils

dsk: libs
	$(MAKE) -C unittest dsk

run: libs
	$(MAKE) -C unittest run

clean: clean-tests clean-utils clean-libs

clean-libs:
	$(MAKE) -C cgfx clean
	$(MAKE) -C lib clean

clean-tests:
	$(MAKE) -C unittest clean

clean-utils:
	$(MAKE) -C utils clean
