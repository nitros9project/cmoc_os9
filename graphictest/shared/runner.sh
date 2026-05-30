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

mkdir -p "$RESULTS_DIR/actual" "$RESULTS_DIR/diff" "$RESULTS_DIR/mame-snap"

# Per-scenario disk: inject a startup that auto-runs PROGRAM and writes a
# completion sentinel. wintest/maze loop until SPACE; -seconds_to_run ends MAME.
disk="$RESULTS_DIR/disk.dsk"
cp "$DISK_SRC" "$disk"
{
	printf 'echo * %s *\nlink shell\nload utilpak1\n' "$SCENARIO_NAME"
	printf 'shell %s\n' "$PROGRAM"
	printf 'echo CIDONE >>>-zzdone.out\n'
} >"$RESULTS_DIR/startup"
os9 copy -l -r "$RESULTS_DIR/startup" "$disk,startup" >/dev/null 2>&1
os9 attr -q -ne -npe "$disk,startup" >/dev/null 2>&1

# Run MAME with the scenario script as autoboot_script. -snapshot_directory
# directs MAME-side screen:snapshot() output to a dir we own. The scenario
# writes a manifest of (index, name, opts) into RESULTS_DIR/manifest.tsv that
# pairs MAME's auto-numbered PNGs with the scenario's logical names.
export GXTEST_RESULTS="$RESULTS_DIR" GXTEST_SCENARIO="$SCENARIO_NAME"
# Write a small shim that puts gxtest on the Lua path, then runs the scenario.
shim="$RESULTS_DIR/_shim.lua"
abs_scenario=$(cd "$SCENARIO_DIR" && pwd)/scenario.lua
abs_shared=$(cd "$HERE" && pwd)
cat >"$shim" <<EOF
package.path = "$abs_shared/?.lua;" .. package.path
dofile("$abs_scenario")
EOF
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
	mame coco3 -rompath "$ROMPATH" -skip_gameinfo \
		-ext fdc -ext:fdc:wd17xx:0 525qd -flop1 "$disk" \
		-video none -sound none -nothrottle \
		-snapshot_directory "$RESULTS_DIR/mame-snap" \
		-cfg_directory "$RESULTS_DIR/cfg" -nvram_directory "$RESULTS_DIR/nvram" \
		-autoboot_delay "$DELAY" -autoboot_command "DOS\n" \
		-autoboot_script "$shim" \
		-seconds_to_run "$BUDGET" >"$RESULTS_DIR/mame.log" 2>&1 || true

# MAME emits snapshots as <snapshot_directory>/<system>/<NNNN>.png. Flatten and
# rename in manifest order so we have actual/<name>.png for compare.
manifest="$RESULTS_DIR/manifest.tsv"
if [ ! -s "$manifest" ]; then
	echo "ERROR: scenario produced no snapshot manifest (Lua didn't run?). MAME log tail:" >&2
	tail -20 "$RESULTS_DIR/mame.log" >&2
	exit 2
fi

mapfile -t mame_pngs < <(find "$RESULTS_DIR/mame-snap" -type f -name '*.png' | sort)
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
		echo "  [$SCENARIO_NAME] $name: FAIL ($compare; see $diff_png)"
		fail=1
	fi
done <"$manifest"

[ "$fail" = 0 ] && echo "[$SCENARIO_NAME] OK ($RESULTS_DIR)" || echo "[$SCENARIO_NAME] FAILED ($RESULTS_DIR)"
exit "$fail"
