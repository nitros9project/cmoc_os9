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

## Running

The harness needs `mame`, ToolShed `os9`, Python 3 with Pillow + NumPy, plus a
CoCo 3 ROM -- i.e. the `jamieleecho/coco-dev` image -- and the recipe-built
test disk (`make dsk`). On bare macOS / Linux:
`pip install --user Pillow numpy`.

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
