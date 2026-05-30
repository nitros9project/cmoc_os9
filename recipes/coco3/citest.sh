#!/usr/bin/env bash
#
# Headless CI runner for the cmoc_os9 unit tests.
#
# Boots the CoCo 3 NitrOS-9 test disk in MAME once per test (full isolation, so
# a hanging or crashing test cannot block the others), captures each test's
# output from the disk, and reports PASS / FAIL / TIMEOUT. Exits non-zero if any
# test fails or times out.
#
# Must run in an environment that has `mame` (a coco3-capable build) and the
# ToolShed `os9` tool on PATH -- i.e. inside the jamieleecho/coco-dev image.
# ROMs are NOT shipped with that image; point ROMPATH at a directory containing
# a coco3 romset (coco3.rom + a disk controller rom).
#
# Usage:
#   DISK_SRC=path/to/l2_coco3_cmoc_os9.dsk ROMPATH=/roms bash citest.sh
#   citest.sh --one <testname>      # run a single test (used internally per job)
#
# Environment knobs:
#   DISK_SRC      bootable test disk image (required)
#   ROMPATH       MAME rompath with a coco3 romset (required)
#   TEST_SCRIPT   file to derive the test list from (default: ./test next to this script)
#   TESTS         explicit space-separated test list (overrides TEST_SCRIPT)
#   BUDGET        fast per-test emulated-second budget (default 120)
#   BUDGET_SLOW   escalation budget retried once on a fast timeout (default 600)
#   DELAY         MAME autoboot delay in seconds before typing DOS (default 8)
#   JOBS          number of tests to run concurrently (default 4)
#   RESULTS       directory for per-test .out files and statuses (default: mktemp)
#   KNOWN_FAILURES        space-separated tests that may fail without failing the
#                         run (quarantine); reported as XFAIL. Overrides the file.
#   KNOWN_FAILURES_FILE   file of quarantined test names, one per line, '#'
#                         comments allowed (default: ./known-failures next to this)
set -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
: "${BUDGET:=120}"
: "${BUDGET_SLOW:=600}"
: "${DELAY:=8}"
: "${JOBS:=4}"
: "${TEST_SCRIPT:=$SCRIPT_DIR/test}"

# Boot the disk once, running exactly one test, with a given emulated-second
# budget. Leaves <test>.out and the zzdone sentinel on the returned disk copy.
# Echoes "COMPLETED" or "TIMEOUT".
run_once() {
	local test=$1 budget=$2 disk=$3
	local mdir; mdir=$(dirname "$disk")
	cp "$DISK_SRC" "$disk"
	{
		printf 'echo * %s *\nlink shell\nload utilpak1\n' "$test"
		printf 'shell %s >>>-%s.out\n' "$test" "$test"
		printf 'echo CIDONE >>>-zzdone.out\n'
	} >"$disk.startup"
	os9 copy -l -r "$disk.startup" "$disk,startup" >/dev/null 2>&1
	os9 attr -q -npe -npw -pr -ne -w -r "$disk,startup" >/dev/null 2>&1
	SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
		mame coco3 -rompath "$ROMPATH" -skip_gameinfo \
			-ext fdc -ext:fdc:wd17xx:0 525qd -flop1 "$disk" \
			-video none -sound none -nothrottle \
			-cfg_directory "$mdir/cfg" -nvram_directory "$mdir/nvram" \
			-snapshot_directory "$mdir/snap" -comment_directory "$mdir/cmt" \
			-autoboot_delay "$DELAY" -autoboot_command "DOS\n" \
			-seconds_to_run "$budget" >/dev/null 2>&1
	if os9 dir "$disk" 2>/dev/null | grep -q zzdone; then echo COMPLETED; else echo TIMEOUT; fi
}

# Run a single test: fast budget, escalate to the slow budget on timeout (to
# tell a genuinely slow test apart from a hang). Writes RESULTS/<test>.out and
# RESULTS/<test>.status.
run_one() {
	local test=$1
	local disk; disk=$(mktemp -u)/d.dsk; mkdir -p "$(dirname "$disk")"
	local state; state=$(run_once "$test" "$BUDGET" "$disk")
	if [ "$state" = TIMEOUT ]; then state=$(run_once "$test" "$BUDGET_SLOW" "$disk"); fi
	os9 list "$disk,$test.out" >"$RESULTS/$test.out" 2>/dev/null || : >"$RESULTS/$test.out"
	local status
	if [ "$state" = TIMEOUT ]; then
		status=TIMEOUT
	else
		local nf; nf=$(grep -c '\[FAIL\]' "$RESULTS/$test.out" 2>/dev/null) || true
		[ "${nf:-0}" -gt 0 ] && status="FAIL[$nf]" || status=PASS
	fi
	echo "$status" >"$RESULTS/$test.status"
	rm -rf "$(dirname "$disk")"
}

# --- single-test mode (invoked per job) ---
if [ "${1:-}" = --one ]; then
	: "${DISK_SRC:?need DISK_SRC}"; : "${ROMPATH:?need ROMPATH}"; : "${RESULTS:?need RESULTS}"
	run_one "$2"
	exit 0
fi

# --- orchestrator mode ---
: "${DISK_SRC:?need DISK_SRC (bootable test disk)}"
: "${ROMPATH:?need ROMPATH (dir with a coco3 romset)}"
[ -f "$DISK_SRC" ] || { echo "DISK_SRC not found: $DISK_SRC" >&2; exit 2; }

if [ -z "${TESTS:-}" ]; then
	[ -f "$TEST_SCRIPT" ] || { echo "TEST_SCRIPT not found: $TEST_SCRIPT" >&2; exit 2; }
	TESTS=$(awk '/>>>/{print $1}' "$TEST_SCRIPT")
fi

export RESULTS="${RESULTS:-$(mktemp -d)}"
mkdir -p "$RESULTS"
export DISK_SRC ROMPATH BUDGET BUDGET_SLOW DELAY

ntests=$(echo $TESTS | wc -w | tr -d ' ')
echo "Running $ntests tests, $JOBS at a time (budget ${BUDGET}s, escalate ${BUDGET_SLOW}s)..."
printf '%s\n' $TESTS | xargs -P "$JOBS" -I{} bash "${BASH_SOURCE[0]}" --one {}

# Load the quarantine list (known failures reported but not gated).
: "${KNOWN_FAILURES_FILE:=$SCRIPT_DIR/known-failures}"
if [ -n "${KNOWN_FAILURES:-}" ]; then
	known=" $KNOWN_FAILURES "
elif [ -f "$KNOWN_FAILURES_FILE" ]; then
	known=" $(sed 's/#.*//' "$KNOWN_FAILURES_FILE" | tr '\n' ' ') "
else
	known=" "
fi
is_known() { case "$known" in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

# Aggregate, preserving the test-script order.
pass=0; xfail=0; failed=()
echo
echo "==================== RESULTS ===================="
for t in $TESTS; do
	st=$(cat "$RESULTS/$t.status" 2>/dev/null || echo "NO-RESULT")
	note=""
	if [ "$st" = PASS ]; then
		pass=$((pass+1))
		is_known "$t" && note="  <- listed in known-failures but passing; consider removing"
	elif is_known "$t"; then
		xfail=$((xfail+1)); st="XFAIL[$st]"
	else
		failed+=("$t:$st")
	fi
	printf '  %-18s %s%s\n' "$t" "$st" "$note"
done
echo "================================================="
echo "PASS: $pass / $ntests   XFAIL(known): $xfail   (per-test output in $RESULTS)"
if [ ${#failed[@]} -gt 0 ]; then
	echo "UNEXPECTED FAILURES: ${failed[*]}"
	exit 1
fi
echo "No unexpected failures."
