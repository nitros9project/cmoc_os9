# LLVM OS-9 compatibility library

This is an LLVM-native adapter library for picolibc programs using Kreider
interfaces. It does not replace picolibc or link CMOC's assembly objects.
CMOC's existing lib/ and cgfx/ builds remain independent.

```sh
make -C llvm                 # llvm/out/Os/libcmoc_os9_compat.a
make -C llvm OPT=Oz
make -C llvm test            # host adapter tests, without an OS-9 boot
make -C llvm smoke           # build the real OS-9 smoke-test module
```

Default locations assume cmoc_os9, llvm-mc6809 and picolibc are siblings:

- LLVM_BIN: ../llvm-mc6809/build/bin
- OS9_SYSROOT: ../picolibc/builddir-mc6809-os9-Os/stage/usr/local

The sysroot must be an OS-9 picolibc build, not a bare-metal build. Override
LLVM_BIN, OS9_SYSROOT, OPT and HOST_CC on the make command line as needed.
Compilation regenerates objects on every invocation to avoid stale output
when the compiler, sysroot or flags change. Different OPT values are isolated.

Link after the application's objects and before the driver's standard libraries:

```sh
/path/to/clang --target=mc6809-unknown-os9 --sysroot=/path/to/os9/sysroot \
  -Os -Illvm/include program.c llvm/out/Os/libcmoc_os9_compat.a -o program
```

Include cmoc_os9_compat.h. Do not add this repository's CMOC include/ directory
or link its libc.a into a picolibc program: stdio layouts and compiler ABIs differ.

## Initial API

- getuid: F$ID, returns picolibc uid_t; preserves unsigned 16-bit OS-9 IDs when
  widening to picolibc's 32-bit type. Failure returns (uid_t)-1 and sets errno.
- asetuid: F$SUser ($1C), returns zero or -1/errno. It delegates permission checks
  to the kernel, matching lib/id.as's asetuid path. No userspace root-only gate.
- readln: I$ReadLn, returns bytes read, zero at EOF, or -1/errno. Converts a
  trailing CR to LF because LLVM C uses LF for '\n'. It does not append a NUL;
  the caller must reserve space and terminate strings. The raw _os_readln
  function in LLVM's os9.h remains available for unconverted OS-9 bytes.

src/syscalls.c uses LLVM's os9.h inline assembly constraints. src/compat.c
implements the legacy API and may be tested with mock syscall functions.
The assembly in lib/id.as and lib/read.as is the behavior reference, not a
binary dependency. The system wrappers rely on the target compiler's OS-9
runtime for errno, process-data addressing and register preservation.

## Verification

`make test` uses host mocks to exercise unsigned UID widening, error propagation,
zero/invalid reads, byte counts, LF conversion, and caller-owned termination.
It does not validate the OS-9 kernel or LLVM's target code generation.

`make smoke` builds os9smoke, which checks identity round-trip with the same UID
and reads a CR-terminated temporary file through I$ReadLn. It requires a writable
current directory and never deliberately changes the user's identity.
Run with an existing picolibc boot harness:

```sh
make -C llvm run-smoke \
  OS9_RUNNER=/path/to/picolibc/scripts/run-mc6809-os9
```

That runner needs ToolShed os9, usim09pt, NITROS9_BOOT_DSK and NITROS9_FIRMWARE
(or the recipe-based equivalents). No emulator or boot artifacts were available
on the development host, so kernel execution is not yet verified. The host
tests pass, and the cross-built smoke module passes OS-9 structural validation.
These tests are separate from the CMOC unit/graphics suites and disk recipes.

## UUCPbb

The uucpbb/build-llvm harness detects a sibling Projects/cmoc_os9/llvm checkout,
builds the archive and links it automatically. An alternate location can be set:

```sh
make -C /path/to/uucpbb/build-llvm TARGET=whoami \
  LLVM_OS9_COMPAT_ROOT=/path/to/cmoc_os9/llvm
```

The UUCPbb build-copy patch adds file-I/O declarations and terminates the
password reader's line buffer. whoami now links with getuid, asetuid and readln.
Further process, modem and terminal APIs remain to be ported.
