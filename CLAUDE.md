# Agent guide

Project-specific notes for AI assistants (Claude Code, Codex, etc.) working
in this repo. The two big "how do I add a test?" workflows are unit tests
and graphics tests -- both run headlessly in MAME via the
`jamieleecho/coco-dev` container image, gated by CI.

## Layout cheat-sheet

```
lib/                C library sources (libc.a, libcf.a)
cgfx/               CGFX graphics library (libcgfx.a)
unittest/           Text-mode unit tests (one .c per test)
graphictest/        Graphics tests: .c programs + scenario harness
  README.md         Detailed graphics-harness docs
  scenarios/<n>/    A graphics scenario
  shared/           gxtest.lua, compare.py, runner.sh
recipes/coco3/      Disk-image recipe; citest.sh; the test/ procedure file
```

## Running the test suites

Both require `MAME_ROMPATH` to point at a directory with `coco3.rom` plus a
disk-controller ROM (e.g. `disk11.rom`). Run inside `coco-dev`:

```sh
# Unit tests (text-mode, parallel, one MAME boot per test)
make test-ci MAME_ROMPATH=/roms

# Graphics tests (one MAME boot per scenario; GFX_JOBS=4 in parallel)
make graphics-test MAME_ROMPATH=/roms
make graphics-test-maze MAME_ROMPATH=/roms             # single scenario
make graphics-test MAME_ROMPATH=/roms GFX_JOBS=8       # bump concurrency

# Re-bless graphics goldens after intentional output change
make graphics-update-maze CONFIRM=1 MAME_ROMPATH=/roms
```

`make dsk` rebuilds the recipe disk and needs the **NitrOS-9 source tree**
mounted as a sibling at `/src/nitros9`. The recipe disk
(`recipes/coco3/l2_coco3_cmoc_os9.dsk`) is committed, so the graphics tests
will use the committed one if the build deps aren't available.

---

## Adding a unit test

Unit tests are plain C programs that print `[PASS]` / `[FAIL]` to stdout.
The runner (`recipes/coco3/citest.sh`) captures stdout to a per-test `.out`
file on disk, then `grep -c '[FAIL]'` decides pass/fail.

1. **Write the test** at `unittest/<name>test.c`. Convention:

   ```c
   #include <stdio.h>
   int main(void) {
       int ok = check_some_thing();
       if (ok) printf("%s [PASS]\n", __func__);
       else    printf("%s [FAIL] reason\n", __func__);
       return ok ? 0 : 1;
   }
   ```

   Multiple `[PASS]`/`[FAIL]` lines per test are fine; any single `[FAIL]`
   marks the whole test as failed.

2. **Register the test in four places** (yes, four -- they're scoped to
   different artifacts):
   - `unittest/Makefile`: nothing needed if the default `%: %.c` rule fits
     (it does for most). Tests that need extra flags (e.g.
     `--add-os9-stack-space=NNNN` for big-stack programs) need an explicit
     rule like `hello:` / `maze:`.
   - `recipes/coco3/recipe.mak`: add the test name to the `CMOC_OS9_TESTS`
     variable so it gets copied onto the disk.
   - `recipes/coco3/test`: append `echo <name>` and
     `<name> >>>-<name>.out`. This procedure file is what runs inside OS-9
     after boot.
   - (Optionally) `unittest/Makefile`'s `TESTS=` list, used by
     `make unittest-dsk` -- the smaller standalone disk used by humans.

3. **Verify**:
   ```sh
   make dsk
   make test-ci MAME_ROMPATH=/roms
   ```

If a test is known-broken and you want CI green, add its name to
`recipes/coco3/known-failures` (it becomes `XFAIL` instead of `FAIL`).

A test that times out at the fast `BUDGET` (default 120 s emulated) is
**automatically retried once at `BUDGET_SLOW`** (default 600 s) before
being reported as `TIMEOUT`. Don't pad the fast budget for legitimately
slow tests -- the retry handles it and keeps the common-case latency low.

The OS-9 shell's `>>>` operator is a **truncating redirect** (different
from `>` which appends to an existing file). The `test` procedure file uses
`>>>-<name>.out` to capture each test's output into a fresh file on the
disk; citest then reads those files back. If you write a test that uses
`>` accidentally, you'll see output from the previous run leak in.

---

## Adding a graphics test

Graphics tests are C programs that exercise the behavior of full
applications, including keyboard and mouse (joystick) input and video
output. The harness snapshots the running program at chosen moments and
compares each capture against a checked-in golden PNG.

Two facts about how the harness drives the test that shape how you author
one (the rest are in the gotchas section below):

- **Tests are launched by typing the program name at the NitrOS-9 shell
  prompt**, not from a startup procedure file. Startup-driven launches
  appear to run but the GIME never switches from `/term` to the program's
  `/w` graphics window when `_cgfx_select()` fires, so snapshots come back
  as the cowin text terminal instead of your graphics. The shim handles
  the typing -- you just write the scenario.

- **Disk activity has to settle before we can type reliably.** The CoCo
  keyboard scan drops characters that arrive while the FDC is busy, so
  the shim waits ~35 s after `DOS\r` for NitrOS-9 boot + recipe startup
  to finish before typing the program name. If you write scenarios that
  type additional commands later, leave similarly generous gaps after any
  disk-touching action (loading a module, opening a file).

See `graphictest/README.md` for the long-form docs. The short version:

1. **Write the program** at `graphictest/<name>.c` -- opens `/w`, calls
   `_cgfx_select(outpath)`, draws.

2. **Build it onto the disk** by adding it to `CMOC_OS9_GRAPHICS_TESTS` in
   `recipes/coco3/recipe.mak`. If it needs more than the default OS-9 data
   memory (a stack-overflow at runtime), give it an explicit Makefile rule
   in `unittest/Makefile` with `--add-os9-stack-space=NNNN` (maze uses 5518;
   bigger programs may need more).

3. **Write the scenario** at `graphictest/scenarios/<name>/scenario.lua`:

   ```lua
   local g = require "gxtest"
   g.wait(15)                                            -- let the program draw
   g.snapshot("01-first", { compare = "ssim", min_ssim = 0.55 })
   g.wait(10)
   g.snapshot("02-second", { compare = "ssim", min_ssim = 0.55 })
   ```

   The runner types `<name>\r` at the OS-9 shell prompt to launch the
   program. Override with `PROGRAM=...` if the scenario name and program
   name differ.

4. **First run will be NEW** (no golden):
   ```sh
   make graphics-test-<name> MAME_ROMPATH=/roms
   ```

5. **Eyeball the captures** at `<results-dir>/actual/*.png` (path printed
   in the runner output), then bless:
   ```sh
   make graphics-update-<name> CONFIRM=1 MAME_ROMPATH=/roms
   ```

6. **Run again to confirm** the harness now passes against the goldens.

### Comparison modes

- `compare = "pixel"` (default): per-channel delta tolerance. Good for
  deterministic output. `max_delta` (default 5), `max_diff_pct` (default
  0.1%).
- `compare = "ssim"`: structural-similarity score. Use for animated /
  random output. `min_ssim` (default 0.97; the maze scenario uses 0.55
  because mazes vary by seed -- though see note below).

Optional `mask = "name"` looks up `masks/<name>.png` in the scenario dir
and ignores any pixel where the mask is non-zero (white).

### Important gotchas (learned the hard way)

These are baked into `graphictest/shared/runner.sh`; preserve them if you
refactor.

- **MAME's `-autoboot_command` is silently suppressed when
  `-autoboot_script` is also set.** The shim drives the BASIC -> NitrOS-9
  transition itself by typing `DOS\r` via the natural keyboard.

- **The natural keyboard is disabled by default on the coco3 driver.** Set
  `manager.machine.natkeyboard.in_use = true` before posting.

- **Posting long strings drops characters** to the CoCo's keyboard-scan
  timing. Keep `nk:post()` arguments short (~8 chars including the CR).
  Per-char chunking is *worse*, not better -- `nk.empty` goes true before
  the keypress is actually delivered.

- **Typing while the disk drive is active drops characters.** Wait
  generously (~35s) between booting NitrOS-9 and typing the program name.

- **Use the recipe's own `startup` verbatim.** The
  `display 1b 24 1b 20 1 0 0 28 18 0 1 2 1b 21` line configures cowin's
  `/term` window -- without it the GIME stays in an unknown mode and
  graphics programs appear to do nothing.

- **Launch the program interactively, not from a startup procedure.** A
  startup-driven `shell <program>` runs but `_cgfx_select()` does not
  switch the GIME from `/term` to the program's `/w` window. Typing the
  program name at an interactive shell prompt does.

- **Force RGB monitor mode** for reproducible colors. The shim does:
  ```lua
  manager.machine.ioport.ports[":screen_config"]
      .fields["Monitor Type"]:set_value(1)  -- 1 = RGB, 0 = Composite
  ```

- **`maze` (and `wintest`) are deterministic** because the source redefines
  `time()` as `return 0;`. `srand(0)` produces the same maze every boot,
  so even `ssim` matches give 1.0 -- a fresh random maze would not.

- **`make graphics-test-*` won't rebuild the disk** if
  `recipes/coco3/l2_coco3_cmoc_os9.dsk` already exists (`gfx-have-disk`
  helper). Lets the harness run in `coco-dev` without needing the sibling
  `nitros9` source tree.

- **GFX_BUDGET=100 (emulated seconds) is the floor.** Boot + display init +
  program launch + scenario waits add up.

- **`emu.wait(secs)` is the pause primitive in an autoboot_script Lua
  coroutine.** Don't try `coroutine.yield()` or
  `add_machine_frame_notifier()` -- both look reasonable but neither
  actually advances emulated time inside an autoboot_script context.

- **MAME's `-video none` snapshots reflect the GIME's live state**, not a
  cached framebuffer. `-video soft` produces byte-identical PNGs. So you
  don't need Xvfb, an X display, or any host video pipeline -- the
  snapshot is rendered straight from the emulated chip state. If a
  snapshot looks "stuck", the GIME *is* stuck; don't chase it as a
  rendering problem.

### Diagnosing a failing scenario

When a snapshot doesn't match its golden and the diff PNG isn't enough,
**color-quantize the actual capture** -- it tells you immediately what
NitrOS-9 state the screen is in:

```python
from PIL import Image; from collections import Counter
img = Image.open("path/to/actual.png").convert("RGB")
px = list(img.getdata())
q = [(r>>5, g>>5, b>>5) for r,g,b in px]
for (r,g,b), n in Counter(q).most_common(5):
    print(f"({r*32},{g*32},{b*32}): {100*n/len(px):.0f}%")
```

Rough signatures observed in this project:

| Top colors                                  | What it means                         |
| ------------------------------------------- | ------------------------------------- |
| ~62% green (32,128,0) / ~37% black          | Still at the Color BASIC `OK` prompt  |
| ~99% green / ~1% black                      | Color BASIC `OK` with nothing typed   |
| ~80% purple (64,0,128) / ~20% black + white | NitrOS-9 `/term` cowin window         |
| ~80% black / white + dark grey              | A maze (RGB-mode palette 0/63/07)     |

If the screen is purple instead of "mazey", the program was launched but
its `_cgfx_select()` didn't switch the GIME -- check that you used
interactive launch and the recipe startup ran.

---

## Claude-only conventions

(Applies to Claude Code. Codex reads the same file via the `AGENTS.md`
symlink and can ignore the section or honor it.)

**Target verbosity: ~30 % of default** for everything Claude writes in
this repo -- comments, doc strings, README prose, scenario file headers,
PR / commit bodies, chat responses.

Trim:
- Sentences that narrate what code already says.
- "I've done X, now let me Y" connective tissue.
- Marketing intros to docs.
- A paragraph where a bullet would lose nothing.
- Restating what the user just said.

Keep:
- The *why* when it's non-obvious.
- Surprises the reader needs (gotchas, invariants).
- Comments that flag things the code can't express.

If a section feels under-explained, ask before re-padding.

---

## Keeping docs in sync with the code

When changing how anything in this repo is built, tested, configured, or
laid out, **update the docs in the same change**:

- **`CLAUDE.md` / `AGENTS.md`** (this file) -- the agent-facing guide.
  Anything that contradicts what's here is a doc bug. Examples that
  warrant an update: a new `make` target, a new env knob, a new
  scenario / unit-test registration step, a new gotcha, a deprecated
  flow, a relocated file.
- **`README.md`** -- user-facing build & quickstart.
- **`graphictest/README.md`** -- the graphics harness's own long-form
  doc; mirror any runner.sh / scenario API change here.
- **`recipes/coco3/README.md`** -- for recipe-disk or boot-disk changes.

A code change that leaves a doc stale is not done. If the change is too
small for a paragraph but worth a sentence, add the sentence.

## Pull-request flow

- Branch from `master`; we open PRs against `nitros9project/cmoc_os9`.
- `make test-ci` and `make graphics-test` should both be green before
  merge.
- Commit messages: imperative subject ("Fix X" not "Fixed X"), body
  explains the why, end with the standard `Co-Authored-By:` trailer.
- Graphics goldens live in git (small PNGs, ~10 KB each). Re-bless in a
  separate commit so reviewers can see the visual change distinctly.
