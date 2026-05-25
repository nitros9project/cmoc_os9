This directory owns the CoCo 3 `cmoc_os9` NitrOS-9 test-disk recipe.

Files here:
- `makefile`: local recipe driver that builds the disk image in this directory.
- `recipe.mak`: recipe settings consumed by the local recipe build.
- `nitros9.mak`: CMOC OS-9 build and disk population rules.
- `startup`: minimal boot script copied onto the test disk as `startup`.
- `test`: manual regression batch script copied onto the disk when needed.
- `citest.sh`: headless CI runner used by `make test-ci` (see below).

The recipe still consumes modules, commands, libraries, and disk tools from a
nearby NitrOS-9 checkout. By default it looks for that checkout at
`../nitros9` relative to the `cmoc_os9` repository root; set `NITROS9DIR` to
override that location.

Build from the repository root with:

```sh
make dsk
```

or directly from this directory with:

```sh
make
```

The default output is `l2_coco3_cmoc_os9.dsk` in this directory.

## Headless automated testing (`make test-ci`)

`citest.sh` runs the unit tests automatically and headlessly: it boots the test
disk in MAME **once per test** (full isolation, so a hanging or crashing test
can't block the others), captures each test's output from the disk, and reports
`PASS` / `FAIL` / `TIMEOUT`. It exits non-zero if any test fails or times out.

Each test runs with a fast emulated-second budget and is retried once at a
larger budget only if it times out, so a genuinely slow test (e.g. `iotest`,
which does heavy floppy I/O) is not confused with a hang.

This needs `mame` (a coco3 build) and ToolShed `os9` on `PATH` — i.e. the
[`jamieleecho/coco-dev`](https://github.com/jamieleecho/coco-dev) image — plus a
CoCo 3 romset (not shipped: `coco3.rom` and a disk-controller rom such as
`disk11.rom`). From the repository root:

```sh
# inside the coco-dev container, with a NitrOS-9 checkout and ROMs available
make test-ci MAME_ROMPATH=/path/to/roms
```

Run it from the host via the container, mounting this repo, a NitrOS-9 checkout,
and the romset:

```sh
docker run --rm \
  -e NITROS9DIR=/src/nitros9 -e MAME_ROMPATH=/roms \
  -v "$PWD":/src/cmoc_os9 -v /path/to/nitros9:/src/nitros9 \
  -v /path/to/roms:/roms:ro -w /src/cmoc_os9 \
  jamieleecho/coco-dev make test-ci
```

Knobs (Make variables / env): `CI_JOBS` (parallel tests, default 4),
`CI_BUDGET` (fast per-test emulated seconds, default 120), `CI_BUDGET_SLOW`
(timeout-retry budget, default 600). Per-test output is left in a temporary
`RESULTS` directory printed at the end.
