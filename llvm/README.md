# LLVM OS-9 C library port

The LLVM build covers the complete callable interface of the active CMOC C
library: 280 original header declarations have explicit provider mappings in
`api-map.json`. Standard C uses picolibc and LLVM's OS-9 runtime. Kreider and
OS-9 extensions have native LLVM implementations; CMOC assembly objects are
never linked into an LLVM application.

The port includes path I/O and status services, process and module services,
signals, directory streams, password parsing, data modules, heap extensions,
calendar conversion, string/set/packed-integer helpers, CRC, diagnostics and
profiling hooks and the legacy `_chcodes` classification table. Vendored picolibc/fdlibm code supplies both IEEE float and
double math, numeric conversion and floating output missing from the installed
OS-9 sysroot. Existing CMOC `lib/` and `cgfx/` builds remain available.

## Build and use

The default paths assume `cmoc_os9`, `llvm-mc6809`, and `picolibc` are siblings.
The sysroot must be the OS-9 picolibc build, not the bare-metal build.

```sh
make -C llvm -j4
make -C llvm -j4 OPT=Oz
make -C llvm test
make -C llvm -j4 audit link-check smoke
```

Override `PROJECTS`, `LLVM_BIN`, `OS9_SYSROOT`, `HOST_CC`, and `OPT` as needed.
Objects are regenerated on each build so compiler/sysroot changes cannot leave
stale code. Outputs for different optimization levels are separate.

New code includes `cmoc_os9.h` and uses explicit `cmoc_*` names for interfaces
whose arguments differ from POSIX. Native standard headers remain available.
Legacy code can include `cmoc_os9_legacy.h` first, or force-include it:

```sh
/path/to/clang --target=mc6809-unknown-os9 --sysroot=/path/to/os9/sysroot \
  -Os -Illvm/include -include llvm/include/cmoc_os9_legacy.h program.c \
  llvm/out/Os/libcmoc_os9_compat.a -o program
```

For floating `printf`/`fprintf`/`sprintf` output, add the floating profile before
the compatibility archive, equivalent to choosing CMOC's floating library:

```sh
/path/to/clang --target=mc6809-unknown-os9 --sysroot=/path/to/os9/sysroot \
  -Os -Illvm/include -include llvm/include/cmoc_os9_legacy.h program.c \
  llvm/out/Os/libcmoc_os9_float.a llvm/out/Os/libcmoc_os9_compat.a -o program
```

The normal profile retains picolibc's smaller integer formatter. `ftoa` and
`pffloat` explicitly use the floating formatter regardless of profile. Ordinary
programs avoid the floating profile's code-size cost. Both profiles are limited
by OS-9's 65535-byte module size; a program using many double transcendental
routines may need to be split into smaller modules.

Do not add the original CMOC `include/` directory or link its `libc.a` into an
LLVM application. The legacy aliases deliberately use OS-9 access/permission
bytes and signal numbers, rather than POSIX meanings. Keep them within code
that uses the Kreider interface.

## ABI and behavior

* `FILE`, `DIR` from `dirent.h`, `size_t`, `uid_t`, `time_t`, `struct tm`, and
  floating values use native LLVM/picolibc layouts. `dir.h` supplies a distinct
  Kreider `DIR` and `DIRECT` interface. OS-9 wire packets use explicit fixed
  widths and target layout assertions.
* CMOC's private `FILE` fields and `_iob` array are replaced by native stdio.
  Code inspecting `_ptr`, `_base`, `_flag`, etc. must use public stream APIs.
  Tests of those private layouts are CMOC-specific and are not LLVM tests.
* The legacy memory bounds `_mtop`, `_memend`, `_sttop`, and `_stbot` are read
  expressions backed by LLVM startup variables. Allocation uses the heap
  functions. The heap can lie above the original stack after OS-9 memory
  growth, so the old ordering assumptions do not apply. `cmoc_sbrk`/`ibrk`
  zero allocations and use NULL on failure. Shrinking cannot cross the point
  where the compatibility heap functions were first used.
* Native `time_t` is 64 bits. Use `time_t` variables, not `long`, when passing
  pointers to `time`, `localtime`, or `ctime`. OS-9 months are 1–12; native
  `tm_mon` is 0–11. Gregorian century leap rules are honored.
* LLVM `float` is IEEE binary32 and `double` is binary64. CMOC accumulator
  layouts and compiler arithmetic helpers are replaced by LLVM code generation
  and its runtime. Formatting follows native rounding; `ftoa` uses seven
  significant digits and preserves Kreider's omitted zero before a fraction.
* `rad(void)` and `deg(void)` select the mode of legacy trig aliases. Standard
  `sin`/`cos`/etc. stay in radians. `dexp(double, int)` scales by a power of two.
  These signatures correct the original header's declarations using the
  [Kreider manual](https://colorcomputerarchive.com/repo/Documents/Manuals/Programming/CLib%2091%20C%20Library%20Reference%20%28Carl%20Kreider%29.pdf).
* `getuid` keeps native `uid_t`; the legacy header selects the 16-bit getter.
  `asetuid` delegates permission checking to OS-9. Legacy `setuid` keeps its
  root-only userspace check.
* `readln` converts a final CR to C LF, without adding a NUL. `writeln` converts
  C LF to CR in a temporary buffer. `cmoc_os_readln`/`cmoc_os_writeln` transfer
  raw OS-9 bytes, preserve actual counts, and return OS-9 error codes.
* The generic syscall adapter captures CC/D/DP/X/Y/U, preserves process U/DP,
  and does not install a caller-supplied DP or S. The S field is reserved.
  Callers must provide correct register operands for the service.
* Signal callbacks preserve LLVM virtual registers. Legacy handlers are
  single-use, except `SIG_IGN`; the table holds 20 entries. `intercept` and
  `signal` replace each other's dispatch mode. `SIGKILL` is OS-9 signal zero.
* `system` launches the named module directly, passing the remaining command
  text with a trailing CR. It does not parse shell redirections. `popen` uses
  `/pipe`, restores the parent's standard path, and `pclose` waits for its child.
* `pflinit`/`pffinit` need no runtime registration. `_prof`/`_dumprof` support
  explicit calls; compiler instrumentation uses LLVM's facilities.

`cgfx`, graphics examples, private CMOC compiler entry points, and the matrix
prototypes in `mat.h` (which have no implementation in the active C library)
are separate from this port's callable C-library scope.

## Verification

`audit` compares every original callable declaration against the checked-in
mapping, checks providers in the archives, and compiles references through the
LLVM headers. Adding a declaration without a mapping fails the audit.

`link-check` makes every callable archive symbol an explicit linker root, in
separate OS-9 modules. Each function and all its dependencies must link; unused
sections cannot hide a missing dependency. Separate modules avoid exceeding the
16-bit module-size limit merely by aggregating the entire library.

Seven host test suites cover UID/readln behavior, register/error/count handling,
strings/sets/CRC/calendar operations, float/double math, password/module/heap
services, signals, and process/pipe behavior. They use mock kernel services.
`smoke` builds real OS-9 identity/I/O and floating-conversion/stdio modules.

```sh
make -C llvm run-smoke OS9_RUNNER=/path/to/picolibc/scripts/run-mc6809-os9
```

The runner needs ToolShed `os9`, `usim09pt`, `NITROS9_BOOT_DSK`, and
`NITROS9_FIRMWARE` (or recipe equivalents). No emulator/boot artifacts were
available on the development host. Cross compilation, linkage, host behavior,
and module structure are verified; execution on an OS-9 kernel remains a
required validation step before treating the port as runtime-validated.

## UUCPbb

The `uucpbb/build-llvm` harness detects a sibling `cmoc_os9/llvm`, builds the
compatibility archive and links it. An alternate checkout can be selected:

```sh
LLVM_OS9_COMPAT_ROOT=/path/to/cmoc_os9/llvm make -C /path/to/uucpbb/build-llvm
```

The small `cmoc_os9_compat.h` header and its existing `getuid`, `asetuid`, and
`readln` interfaces remain usable independently. UUCPbb's own adapters can
continue to supply its differing legacy conventions.

## Imported code

`math/` is a self-contained subset of picolibc's fdlibm math sources, with
original licensing notices preserved; `COPYING.picolibc` includes the upstream
license inventory. `math/build_config.h` selects the
portable algorithms. The math build permits aliases between ABI-equivalent
`double` and `long double` on this target, which clang otherwise warns about.
`stdio/` vendors picolibc's conversion/floating-output code and private headers;
relative include paths are adjusted to this repository. MC6809 conversion
engines are retained. Other vendor source remains unchanged.
