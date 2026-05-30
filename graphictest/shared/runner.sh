#!/usr/bin/env bash
#
# Run a single graphics-test scenario in headless MAME and compare its
# snapshots against the scenario's goldens.
#
# Inputs (env):
#   DISK_SRC      bootable CoCo 3 disk image (required; recipe disk works)
#   ROMPATH       MAME rompath with a coco3 romset (required)
#   SCENARIO_DIR  scenario directory, e.g. graphictest/scenarios/wintest (required)
#   PROGRAM       OS-9 command to auto-run after boot (default: scenario dirname)
#   BUDGET        emulated-second budget per scenario (default 60)
#   DELAY         autoboot delay in seconds before typing DOS (default 8)
#   RESULTS_DIR   per-scenario results dir (default: mktemp)
#   COMPARE       path to compare.py (default: alongside this script)
#
# Exit: 0 if every snapshot matches its golden; non-zero on any mismatch or
# missing golden. Writes actual/<name>.png, golden/<name>.png and diff/<name>.png
# into RESULTS_DIR so failures are easy to eyeball.
set -u
: "${DISK_SRC:?DISK_SRC required}"
: "${ROMPATH:?ROMPATH required}"
: "${SCENARIO_DIR:?SCENARIO_DIR required}"
: "${BUDGET:=60}"
: "${DELAY:=8}"
SCENARIO_NAME=${SCENARIO_NAME:-$(basename "$SCENARIO_DIR")}
PROGRAM=${PROGRAM:-$SCENARIO_NAME}
RESULTS_DIR=${RESULTS_DIR:-$(mktemp -d)}
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
COMPARE=${COMPARE:-$HERE/compare.py}

# Pre-flight: compare.py needs Pillow + numpy. coco-dev ships them; bare
# macOS / Linux Pythons usually don't. Fail loudly with the install hint
# rather than letting the comparator throw a traceback per snapshot.
if ! python3 -c 'import PIL, numpy' >/dev/null 2>&1; then
	echo "ERROR: $0 needs python3 with Pillow + numpy." >&2
	echo "       Install with: python3 -m pip install --user Pillow numpy" >&2
	echo "       (drop --user if pyenv complains)" >&2
	exit 2
fi

mkdir -p "$RESULTS_DIR/actual" "$RESULTS_DIR/diff" "$RESULTS_DIR/mame-snap"

# Per-scenario disk: inject a startup that auto-runs PROGRAM and writes a
# completion sentinel. wintest/maze loop until SPACE; -seconds_to_run ends MAME.
disk="$RESULTS_DIR/disk.dsk"
cp "$DISK_SRC" "$disk"
# Use the recipe's own startup verbatim, which leaves us at the OS-9 shell
# prompt after configuring cowin. We then drive the test invocation from
# Lua via the natural keyboard, mimicking what a human does interactively.
# A startup-driven `shell wintest` runs but its _cgfx_select() display
# switch doesn't take effect; an interactive shell does the right thing.
ORIG_STARTUP="$HERE/../../recipes/coco3/startup"
if [ -f "$ORIG_STARTUP" ]; then
	cat "$ORIG_STARTUP" >"$RESULTS_DIR/startup"
else
	printf 'link shell\nload utilpak1\n' >"$RESULTS_DIR/startup"
fi
os9 copy -l -r "$RESULTS_DIR/startup" "$disk,startup" >/dev/null 2>&1
os9 attr -q -ne -npe "$disk,startup" >/dev/null 2>&1

# Run MAME with the scenario script as autoboot_script. -snapshot_directory
# directs MAME-side screen:snapshot() output to a dir we own. The scenario
# writes a manifest of (index, name, opts) into RESULTS_DIR/manifest.tsv that
# pairs MAME's auto-numbered PNGs with the scenario's logical names.
export GXTEST_RESULTS="$RESULTS_DIR" GXTEST_SCENARIO="$SCENARIO_NAME"
# Write a small shim that boots NitrOS-9 from BASIC (since -autoboot_script
# precludes -autoboot_command), then sets up the Lua path and runs the scenario.
shim="$RESULTS_DIR/_shim.lua"
abs_scenario=$(cd "$SCENARIO_DIR" && pwd)/scenario.lua
abs_shared=$(cd "$HERE" && pwd)
cat >"$shim" <<EOF
package.path = "$abs_shared/?.lua;" .. package.path
-- -autoboot_script suppresses -autoboot_command, so we drive everything
-- from Lua. Boot sequence:
--   1. Enable natural keyboard (coco3 ships with it disabled).
--   2. Type DOS<CR> at the BASIC OK prompt -> boots NitrOS-9 from disk.
--   3. Wait for the recipe's startup to finish (display init etc.) and
--      drop us at the OS-9: shell prompt.
--   4. Type "shell <PROGRAM><CR>" interactively. Running it from a
--      startup procedure file does NOT switch the GIME from /term to /w
--      when the program calls _cgfx_select(); typing it at the interactive
--      shell does.
-- Force the coco3 monitor type to RGB so colors are consistent across
-- hosts (composite mode has phasing artifacts that make goldens flaky).
manager.machine.ioport.ports[":screen_config"].fields["Monitor Type"]:set_value(1)

-- Single :post() with the whole short string works (the natkeyboard
-- handles inter-char timing internally); chunked per-char posting drops
-- chars because nk.empty goes true before the keypress is actually
-- delivered. Keep posted strings short (<=8 chars including the CR).
--
-- The waits between commands are generous: NitrOS-9 boot is disk-bound
-- and so is forking the test program. Typing while the disk drive is
-- working causes the keyboard scan to miss characters.
local nk = manager.machine.natkeyboard
nk.in_use = true
emu.wait(2)
nk:post("DOS\r")
emu.wait(35)
-- After the recipe startup runs, we are at the interactive OS-9 shell
-- prompt -- type the program name directly (no "shell" prefix needed).
nk:post("$PROGRAM\r")
emu.wait(5)
dofile("$abs_scenario")
EOF
# MAME runs at ~thousands-of-percent emulated speed in -video none, so
# WALL_TIMEOUT (default 2x BUDGET seconds, real-time) is generous; it exists
# to kill a hung emulator rather than to bound normal completion time.
#
# Prefer GNU `timeout` (Linux / coco-dev) or `gtimeout` (macOS with
# Homebrew coreutils); fall back to a perl SIGALRM one-liner so bare
# macOS still gets hang protection. perl is preinstalled on every
# macOS. The perl path can't do the SIGTERM-then-SIGKILL escalation
# that --kill-after gives, but for MAME (which doesn't trap SIGALRM)
# the single signal is enough.
: "${WALL_TIMEOUT:=$((BUDGET * 2))}"
TIMEOUT_ARGS=()
if command -v timeout >/dev/null 2>&1; then
	TIMEOUT_ARGS=(timeout --kill-after=5 "$WALL_TIMEOUT")
elif command -v gtimeout >/dev/null 2>&1; then
	TIMEOUT_ARGS=(gtimeout --kill-after=5 "$WALL_TIMEOUT")
elif command -v perl >/dev/null 2>&1; then
	TIMEOUT_ARGS=(perl -e 'alarm shift; exec @ARGV' "$WALL_TIMEOUT")
fi
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
	"${TIMEOUT_ARGS[@]+${TIMEOUT_ARGS[@]}}" \
	mame coco3 -rompath "$ROMPATH" -skip_gameinfo \
		-ext fdc -ext:fdc:wd17xx:0 525qd -flop1 "$disk" \
		-video none -sound none -nothrottle \
		-snapshot_directory "$RESULTS_DIR/mame-snap" \
		-cfg_directory "$RESULTS_DIR/cfg" -nvram_directory "$RESULTS_DIR/nvram" \
		-autoboot_delay "$DELAY" -autoboot_script "$shim" \
		-seconds_to_run "$BUDGET" >"$RESULTS_DIR/mame.log" 2>&1
mame_rc=$?
# 124 = GNU timeout exit; 137 = SIGKILL after --kill-after; 142 = SIGALRM
# from the perl fallback (128+14). Everything else is MAME's own exit
# (often non-zero even on a clean -seconds_to_run, so we tolerate it --
# the snapshot manifest check below is the real success gate).
if [ "$mame_rc" = 124 ] || [ "$mame_rc" = 137 ] || [ "$mame_rc" = 142 ]; then
	echo "[$SCENARIO_NAME] MAME killed by WALL_TIMEOUT=${WALL_TIMEOUT}s" >&2
fi

# MAME emits snapshots as <snapshot_directory>/<system>/<NNNN>.png. Flatten and
# rename in manifest order so we have actual/<name>.png for compare.
manifest="$RESULTS_DIR/manifest.tsv"
if [ ! -s "$manifest" ]; then
	echo "ERROR: scenario produced no snapshot manifest (Lua didn't run?). MAME log tail:" >&2
	tail -20 "$RESULTS_DIR/mame.log" >&2
	exit 2
fi

# bash 3.2 (stock macOS) has no `mapfile` builtin, so read into the array
# the long way. Paths in mame-snap never contain newlines.
mame_pngs=()
while IFS= read -r line; do mame_pngs+=("$line"); done \
	< <(find "$RESULTS_DIR/mame-snap" -type f -name '*.png' | sort)
fail=0
while IFS=$'\t' read -r idx name compare max_delta max_pct min_ssim mask; do
	mame_png=${mame_pngs[$((idx-1))]:-}
	if [ -z "$mame_png" ] || [ ! -f "$mame_png" ]; then
		echo "  [$SCENARIO_NAME] $name: MISSING (MAME didn't emit a PNG for this snapshot)"
		fail=1; continue
	fi
	actual="$RESULTS_DIR/actual/$name.png"
	cp "$mame_png" "$actual"
	golden="$SCENARIO_DIR/goldens/$name.png"
	if [ ! -f "$golden" ]; then
		echo "  [$SCENARIO_NAME] $name: NEW (no golden -- bless with 'make graphics-update')"
		fail=1; continue
	fi
	diff_png="$RESULTS_DIR/diff/$name.png"
	mask_arg=""
	[ -n "$mask" ] && [ -f "$SCENARIO_DIR/masks/$mask.png" ] && mask_arg="--mask $SCENARIO_DIR/masks/$mask.png"
	if python3 "$COMPARE" --mode "$compare" --max-delta "$max_delta" \
		--max-diff-pct "$max_pct" --min-ssim "$min_ssim" $mask_arg \
		--actual "$actual" --golden "$golden" --diff "$diff_png"; then
		echo "  [$SCENARIO_NAME] $name: PASS ($compare)"
	else
		echo "  [$SCENARIO_NAME] $name: FAIL ($compare)"
		echo "    actual: $actual"
		echo "    golden: $golden"
		echo "    diff:   $diff_png"
		fail=1
	fi
done <"$manifest"

if [ "$fail" = 0 ]; then
	echo "[$SCENARIO_NAME] OK ($RESULTS_DIR)"
else
	echo "[$SCENARIO_NAME] FAILED ($RESULTS_DIR)"
	echo "  MAME log tail:"
	tail -20 "$RESULTS_DIR/mame.log" | sed 's/^/    /'
fi
exit "$fail"
