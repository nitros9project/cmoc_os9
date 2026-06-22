# Top-level build driver for the CMOC OS-9 library, tests, and utilities.

.PHONY: all libs tests utils clean clean-libs clean-tests clean-utils \
        clean-recipe dsk run unittest-dsk unittest-run lib cgfx unittest \
        test-ci graphics-test graphics-update gfx-have-disk help

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

# Headless MAME settings for test-ci. Requires `mame` (coco3 build) and `os9` on
# PATH -- i.e. run inside the jamieleecho/coco-dev image -- and MAME_ROMPATH set
# to a directory with a coco3 romset (coco3.rom plus a disk controller rom).
CI_DISK        := recipes/coco3/l2_coco3_cmoc_os9.dsk
CI_BUDGET      ?= 120
CI_BUDGET_SLOW ?= 600
CI_JOBS        ?= 16

# Run the unit tests headlessly (one MAME boot per test), gating pass/fail
test-ci:
	@test -n "$(MAME_ROMPATH)" || { echo "ERROR: set MAME_ROMPATH to a dir with a coco3 romset"; exit 2; }
	$(MAKE) dsk
	DISK_SRC=$(CI_DISK) ROMPATH=$(MAME_ROMPATH) \
	  BUDGET=$(CI_BUDGET) BUDGET_SLOW=$(CI_BUDGET_SLOW) JOBS=$(CI_JOBS) \
	  bash recipes/coco3/citest.sh

# Headless graphics tests: per-scenario MAME boot, snapshot, compare. Same
# environment requirements as test-ci (mame + os9 in coco-dev), plus Python 3
# with Pillow and NumPy (already in coco-dev). See graphictest/README.md.
GFX_SCENARIOS_DIR := graphictest/scenarios
GFX_RUNNER       := graphictest/shared/runner.sh
# Boot to BASIC, type DOS, wait for NitrOS-9 boot + recipe startup, type the
# program name, let it draw, then the scenario's snapshot waits on top. 100s
# emulated leaves headroom on top of that.
GFX_BUDGET       ?= 100
# Concurrency for `make graphics-test`. Each scenario boots its own MAME
# against its own disk copy, so they're independent. Default matches CI_JOBS.
GFX_JOBS         ?= 16
# Discover scenarios as the subdirectories of graphictest/scenarios/ that have
# a scenario.lua. Enables `make graphics-test-<name>` for each.
GFX_SCENARIOS    := $(notdir $(patsubst %/,%,$(dir $(wildcard $(GFX_SCENARIOS_DIR)/*/scenario.lua))))

# Build the recipe disk only if missing (skips when running in a container
# that doesn't have the nitros9 sources alongside cmoc_os9).
gfx-have-disk:
	@test -f $(CI_DISK) || $(MAKE) dsk

# Run all graphics-test scenarios in parallel (GFX_JOBS at a time) and gate
# on any mismatch. Each scenario's output is captured to a per-scenario log
# and replayed in deterministic order after all scenarios finish, so the
# top-level output stays readable even with parallelism.
#
# Results go under GFX_RESULTS_DIR (default: a fresh mktemp dir, printed at
# the end). Set it explicitly in CI so failure artifacts land in a known
# path for upload.
graphics-test: gfx-have-disk
	@test -n "$(MAME_ROMPATH)" || { echo "ERROR: set MAME_ROMPATH to a dir with a coco3 romset"; exit 2; }
	@base="$${GFX_RESULTS_DIR:-$$(mktemp -d "$${TMPDIR:-/tmp}/gxtest.XXXXXX")}"; \
	mkdir -p "$$base"; \
	export DISK_SRC="$(CI_DISK)" \
	       ROMPATH="$(MAME_ROMPATH)" \
	       BUDGET="$(GFX_BUDGET)" \
	       GFX_BASE="$$base" \
	       GFX_SCENARIOS_DIR="$(GFX_SCENARIOS_DIR)" \
	       GFX_RUNNER="$(GFX_RUNNER)"; \
	printf '%s\n' $(GFX_SCENARIOS) | \
	  xargs -P$(GFX_JOBS) -I{} sh -c ' \
	    SCENARIO_DIR="$$GFX_SCENARIOS_DIR/{}" RESULTS_DIR="$$GFX_BASE/{}" \
	      bash "$$GFX_RUNNER" >"$$GFX_BASE/{}.log" 2>&1; \
	    echo $$? >"$$GFX_BASE/{}.rc"'; \
	fail=0; \
	for s in $(GFX_SCENARIOS); do \
	  cat "$$base/$$s.log"; \
	  [ "$$(cat $$base/$$s.rc)" = 0 ] || fail=1; \
	done; \
	echo "Graphics-test results: $$base"; \
	exit $$fail

# Run a single graphics-test scenario by name (e.g. `make graphics-test-maze`)
graphics-test-%: gfx-have-disk
	@test -n "$(MAME_ROMPATH)" || { echo "ERROR: set MAME_ROMPATH to a dir with a coco3 romset"; exit 2; }
	DISK_SRC=$(CI_DISK) ROMPATH=$(MAME_ROMPATH) BUDGET=$(GFX_BUDGET) \
	  SCENARIO_DIR=$(GFX_SCENARIOS_DIR)/$* bash $(GFX_RUNNER)

# Bless captured actuals as goldens (use CONFIRM=1 to avoid accidental updates)
graphics-update: gfx-have-disk
	@test "$(CONFIRM)" = "1" || { echo "Refusing to overwrite goldens without CONFIRM=1"; exit 2; }
	@test -n "$(MAME_ROMPATH)" || { echo "ERROR: set MAME_ROMPATH to a dir with a coco3 romset"; exit 2; }
	@for s in $(GFX_SCENARIOS); do $(MAKE) graphics-update-$$s CONFIRM=1; done

graphics-update-%: gfx-have-disk
	@test "$(CONFIRM)" = "1" || { echo "Refusing to overwrite goldens without CONFIRM=1"; exit 2; }
	@test -n "$(MAME_ROMPATH)" || { echo "ERROR: set MAME_ROMPATH to a dir with a coco3 romset"; exit 2; }
	@d=$$(mktemp -d); \
	DISK_SRC=$(CI_DISK) ROMPATH=$(MAME_ROMPATH) BUDGET=$(GFX_BUDGET) \
	  SCENARIO_DIR=$(GFX_SCENARIOS_DIR)/$* RESULTS_DIR=$$d \
	  bash $(GFX_RUNNER) || true; \
	mkdir -p $(GFX_SCENARIOS_DIR)/$*/goldens; \
	cp -f $$d/actual/*.png $(GFX_SCENARIOS_DIR)/$*/goldens/ 2>/dev/null || true; \
	echo "Blessed: $(GFX_SCENARIOS_DIR)/$*/goldens/"

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
