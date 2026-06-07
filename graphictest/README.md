# Graphics tests

Screenshot-based regression tests for the CoCo 3 graphics programs in this
repo (`maze`, ...). Each test is a small **scenario** -- a Lua script that
drives emulated time and asks the harness to capture the screen at chosen
moments -- paired with reference PNGs (*goldens*) checked into the repo. A
run boots the test in headless MAME (the existing `coco-dev` image), captures
the snapshots, and compares each one against its golden with a configurable
tolerance. Mismatches drop `actual.png`, `golden.png`, and a `diff.png` into
the run's results dir so the failure is easy to eyeball.

## How the boot is driven

The runner uses `-autoboot_script` (not `-autoboot_command`, which it
suppresses) and the natural keyboard to mimic an interactive session:

1. Force the GIME's `Monitor Type` config to RGB so colors are reproducible.
2. Wait, then `nk:post("DOS\r")` -- BASIC boots NitrOS-9 from disk.
3. Wait for the recipe's `startup` to finish (`display 1b 24 ...` sets up
   the cowin /term, then we land at an interactive shell prompt).
4. `nk:post("<program>\r")` to launch the test. **It must be typed
   interactively** -- launching the same program from a startup procedure
   file silently fails to switch the GIME from /term to the program's /w
   graphics window. (Posting longer strings drops chars to keyboard-scan
   timing; keep posted strings short.)
5. The scenario.lua then drives `g.wait()` / `g.snapshot()` from there.

## Layout

```
graphictest/
  README.md                  -- this file
  maze.c / wintest.c         -- the programs under test (built onto the recipe disk)
  shared/
    gxtest.lua               -- the scenario API loaded by MAME via -autoboot_script
    compare.py               -- pixel-diff / SSIM comparator with optional masks
    runner.sh                -- one scenario per MAME boot (handles RGB mode, DOS
                              -- boot, interactive shell launch, etc.)
  scenarios/
    <name>/                  -- the runner types "<name>\r" at the OS-9 shell;
                              -- pass PROGRAM=... to override
      scenario.lua           -- the scenario
      goldens/<snap>.png     -- reference images, one per g.snapshot() call
      masks/<mask>.png       -- optional, regions to ignore
```

## Scenario API

```lua
local g = require "gxtest"

g.wait(seconds)        -- advance N emulated seconds (the workhorse for animated programs)
g.wait_idle(seconds)   -- advance until the screen hasn't changed for N seconds
g.type(string)         -- post a string through MAME's natural keyboard

g.snapshot(name, opts) -- capture the screen. `name` is the basename used for
                       -- goldens/actual/diff. `opts` (all optional):
                       --   compare      = "pixel" (default) | "ssim"
                       --   max_delta    = max per-channel delta for pixel  (default 5)
                       --   max_diff_pct = max % differing pixels for pixel (default 0.1)
                       --   min_ssim     = min similarity score for ssim    (default 0.97)
                       --   mask         = mask basename (looks up masks/<name>.png)
```

A `pixel` comparison is the right default for static UI; switch to `ssim`
when a frame is intentionally variable (a random maze, an animation in
mid-cycle, etc.).

**MAME version matters.** `compare.py` requires the actual capture and the
golden to have identical dimensions -- a size mismatch is a hard error
(exit 2, "DIMENSION MISMATCH"), not silently resized away. Different MAME
versions can render the CoCo3 screen at a different geometry (or palette), so
goldens are effectively pinned to the MAME that blessed them. If you hit a
dimension mismatch or unexpected color failures, check `mame -version`
against whatever produced the goldens (CI uses `jamieleecho/coco-dev`) before
chasing it as a harness bug. The runner passes `-noreadconfig` so a local
`mame.ini` can't perturb the run, but it can't paper over a version gap.

## Running

The harness needs `mame`, ToolShed `os9`, Python 3 with Pillow + NumPy, plus a
CoCo 3 ROM -- i.e. the `jamieleecho/coco-dev` image -- and the recipe-built
test disk (`make dsk`). On bare macOS / Linux:
`python3 -m pip install --user Pillow numpy`, or
`brew install pillow numpy` if the system python is Homebrew's and
PEP 668 blocks pip.

```sh
# all scenarios
make graphics-test MAME_ROMPATH=/path/to/roms

# one scenario, fast iteration
make graphics-test-maze MAME_ROMPATH=/path/to/roms

# regenerate goldens (requires explicit confirmation)
make graphics-update CONFIRM=1 MAME_ROMPATH=/path/to/roms
make graphics-update-maze CONFIRM=1 MAME_ROMPATH=/path/to/roms
```

Each scenario boots in its own MAME instance, so they're independent and
parallelizable.

### When a scenario fails

The runner prints the `actual` / `golden` / `diff` path for each failing
snapshot, and packs all of them -- plus `mame.log` and a `report.txt`
recording your MAME version and host -- into a single
`<results-dir>/<scenario>-failure.tar.gz`. To get help, send that one file;
it's everything a maintainer needs to tell config/version drift from a real
regression. The path is printed at the end of the run (`>>> To report this`).
In CI the same artifacts upload as `graphics-test-results`.

## Authoring a new scenario

1. `mkdir graphictest/scenarios/<name> && cd $_`
2. Write `scenario.lua` that drives the program and calls `g.snapshot(...)`.
3. Run `make graphics-test-<name>` -- the first run reports `NEW` for each
   snapshot (no golden yet).
4. Inspect the captured `actual/*.png` in the results dir to confirm it's
   what you wanted.
5. `make graphics-update-<name> CONFIRM=1` to bless the actuals as goldens.
6. Future runs gate on those goldens.

## Updating goldens after an intentional change

When the program legitimately changes (a new feature, a fixed render bug),
`actual/*.png` no longer matches the golden. Inspect the diff, decide it's
the new truth, then `make graphics-update-<name> CONFIRM=1` to bless.
Goldens are reviewed in PRs because they live in git.
</content>
