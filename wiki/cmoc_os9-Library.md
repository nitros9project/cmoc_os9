# cmoc_os9 Library

`cmoc_os9` provides a C runtime, headers, tests, and graphics support for building OS-9 and NitrOS-9 software with [CMOC](https://perso.b2b2c.ca/~sarrazip/dev/cmoc.html).

The project is maintained as a source tree under the `cmoc_os9` repository and is consumed by NitrOS-9 recipe builds for CoCo 3 test disks.

## What it provides

The project currently builds three main libraries:

- `lib/libc.a`: base C library for integer and string-oriented programs
- `lib/libcf.a`: floating-point-enabled C library using the MC6839 float path
- `cgfx/libcgfx.a`: CGFX support library for graphics, windows, menus, dialogs, and related UI helpers

It also provides:

- public headers under `include/`
- CGFX headers under `cgfx/include/`
- unit and regression tests under `unittest/`
- a CoCo 3 `cmoc_os9` test-disk recipe and harness under `recipes/coco3/cmoc_os9/`

## Repository layout

- `include/`: public libc and OS-9 wrapper headers
- `lib/`: libc sources and build rules
- `cgfx/`: CGFX sources and build rules
- `unittest/`: runtime verification programs and focused regression probes
- `recipes/coco3/cmoc_os9/`: source-of-truth CoCo 3 disk recipe settings, `startup`, and `test`

## Building

Prerequisites:

- `cmoc`
- `lwasm` and `lwar` from LWTOOLS
- ToolShed / OS-9 disk utilities when working with disk images

Build the base and float libraries:

```sh
cd /path/to/cmoc_os9/lib
make libc.a libcf.a
```

Build CGFX:

```sh
cd /path/to/cmoc_os9/cgfx
make libcgfx.a
```

Build the unittest programs:

```sh
cd /path/to/cmoc_os9/unittest
make all
```

## Float support

`libc.a` is intended for non-float programs.

`libcf.a` is the float-enabled variant. It includes:

- float formatting support for `printf` / `sprintf`
- `atof`
- `frexp`
- `ldexp`
- the MC6839 float runtime path

Use `libcf.a` when the program needs `%f`, `%e`, `%g`, `atof`, or other float runtime services.

## OS-9 wrapper model

The library supports both traditional Microware-style calls and a more explicit OS-9 wrapper style.

Examples:

- traditional:
  - `open()`
  - `read()`
  - `write()`
- explicit wrapper:
  - `_os_open()`
  - `_os_read()`
  - `_os_write()`

The explicit wrapper path uses the return value as an error code and passes result values by reference. This keeps the low-level interface consistent across file, process, and system services.

## Testing

The unittest tree covers:

- low-level OS-9 I/O
- stdio
- strings and memory
- long integer formatting
- float formatting and runtime support
- process and signal wrappers
- time and date helpers
- compatibility helper functions

Representative test commands include:

- `memtest`
- `string`
- `stringexttest`
- `stdlibtest`
- `printtest`
- `streamiotest`
- `signaltest`
- `intercepttest`
- `floattest`
- `floatfmttest`

## CoCo 3 test-disk recipe

The source-of-truth recipe assets live in:

- `recipes/coco3/cmoc_os9/recipe.mak`
- `recipes/coco3/cmoc_os9/startup`
- `recipes/coco3/cmoc_os9/test`

These files are consumed by the CoCo 3 recipe build in the NitrOS-9 tree. The `startup` script is intentionally minimal, and the `test` script can be run manually from the shell to generate per-test `.out` files on the disk image.

The recipe is designed as a developer integration harness rather than a generic end-user distribution recipe.

## CGFX status

The CGFX side includes:

- low-level drawing helpers
- text and sound support
- mouse and keyboard helpers
- buttons and radio buttons
- menu and dialog support
- object and file-name helpers
- polygon and transform helpers

The historical `cgfx/todo` queue has been promoted into the live source tree.

## Current status

The library now includes:

- broad Kreider/KLibc compatibility coverage
- float formatting and runtime support verified by dedicated regression tests
- signal and process-wrapper fixes
- a large number of C-to-assembly reductions for size-sensitive libc helpers
- integrated CGFX support

Work still worth tracking separately:

- warning cleanup
- runtime smoke coverage for more CGFX behaviors
- recipe/integration refinement between `cmoc_os9` and the NitrOS-9 build tree

## Related pages

- [[C Compiler]]
- [[Writing your first C Program for NitrOS-9]]
