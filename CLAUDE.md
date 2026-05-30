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

# Graphics tests (one MAME boot per scenario)
make graphics-test MAME_ROMPATH=/roms
make graphics-test-maze MAME_ROMPATH=/roms   # single scenario

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

---

## Adding a graphics test

Graphics tests are C programs that exercise the behavior of full
applications, including keyboard and mouse (joystick) input and video
output. The harness snapshots the running program at chosen moments and
compares each capture against a checked-in golden PNG.

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

---

## Pull-request flow

- Branch from `master`; we open PRs against `nitros9project/cmoc_os9`.
- `make test-ci` and `make graphics-test` should both be green before
  merge.
- Commit messages: imperative subject ("Fix X" not "Fixed X"), body
  explains the why, end with the standard `Co-Authored-By:` trailer.
- Graphics goldens live in git (small PNGs, ~10 KB each). Re-bless in a
  separate commit so reviewers can see the visual change distinctly.
