# CMOC C Library support for OS-9/NitrOS-9

CMOC is an excellent ANSI C cross-compiler by Pierre Sarrazin. It supports the creation of OS-9 exectuables, which needs a complete C library. [Download CMOC here](https://perso.b2b2c.ca/~sarrazip/dev/cmoc.html).

This project aims to deliver two libraries: the standard C library (libc.a) and the CGFX library (libcgfx.a).

The code for the standard C library is based off of the Kreider C library, with yet-to-be ported files under the lib/todo folder.

Likewise, the code for the CGFX library is based off of Mike Sweet's CGFX7 library, with yet-to-be ported files under the cgfx/todo folder.

## Building

You will need LWTOOLS and ToolShed to build this library.

To make both the default non-floating-point `libc.a` and the floating-point
`libcf.a` C libraries, type:

```
cd cmoc_os9
cd lib; make clean all
cd ../cgfx; make
```

To make just the default non-floating-point `libc.a`, type:

```
cd cmoc_os9
cd lib; make clean libc.a
```

To make just the floating-point `libcf.a`, type:

```
cd cmoc_os9
cd lib; make clean libcf.a
```

The default `libc.a` build uses a small dummy `pffloat` implementation so the
library can be built and linked for integer/string-only programs without
pulling in the MC6839 floating-point path. The `libcf.a` build enables
the MC6839 floating-point configuration and includes the real formatting and
parsing support.

From there, you can build the CoCo 3 NitrOS-9 test disk:
```
make dsk
```

This will create a disk image called `l2_coco3_cmoc_os9.dsk` under
`recipes/coco3/`. The recipe uses the local `cmoc_os9` sources and a
nearby NitrOS-9 checkout for OS modules, commands, libraries, and disk tools.
Set `NITROS9DIR` if your NitrOS-9 checkout is not a sibling of this repository.

You can also build the smaller standalone unit-test disk:
```
make unittest-dsk
```

This will create a disk image called `test.dsk` which you can mount in an
emulator and run under NitrOS-9. A convenient script named `go` is placed in
the root folder of the disk. You can run this script to execute the
non-graphical runtime and regression tests. The CoCo 3-specific graphics
programs such as `wintest` and `maze` are built onto the disk as separate
manual tests; both now live under `graphictest/` instead of `unittest/`.

## Differences from the original Microware C Library

The original Microware C library worked within the limitations of the Microware K&R C compiler (e.g. the first 8 characters of a variable or function name were significant.) CMOC eliminates many of those limitations since it's a cross-compiler that runs on modern platforms.

Because of this, we have more freedom to be verbose with function names that were horribly abbreviated, and use calling conventions that are more uniform across the library.

An example of this are the low level C functions for opening and manipulating files in OS-9. Here's the way you would do this in Microware's K&R C compiler:

```
	int p = open("file", S_IREAD | S_IWRITE); // open file for reading and writing
	if (p != -1) {
		// success - valid path
		char buf[10];
		
		int c = read(p, buf, 10);
		if (c == -1) {
			// failure - print the error
			printf("error reading: %d\n", errno);
		}
	} else {
		// failure - print the error
		printf("error opening: %d\n", errno);
	}
```

While this code works and is certainly readable, it tends to fall in the trap of using the return value for one thing or another, complicating error handling.

In the case of open(), the return value is a path... unless -1 is returned, indicated an error occurred.

In the case of read(), a return value is the number of bytes read... unless -1 is returned, indicating an error occurred.

In both cases, we end up having to fetch the error in the global errno variable.

Microware moved to a more uniform method of function usage in [their Ultra C compiler](http://rab.ict.pwr.wroc.pl/dydaktyka/supwa/os9/MWARE/pdf/ultrac_lib_ref.pdf), which reserved the return value strictly for the error code. Here's the same code above rewritten with this new paradigm:

```
	pathid p;
	error_code result = _os_open("file", FAM_READ | FAM_WRITE, &p); // open file for reading and writing
	if (result == 0) {
		// success - valid path
		char buf[10];
		
		int size = 10;
		result = _os_read(p, buf, &size);
		if (result != 0) {
			// failure - print the error
			printf("error reading: %d\n", result);
		}
	} else {
		// failure - print the error
		printf("error opening: %d\n", result);
	}
```

There are several differences in this code:

1. Types are declared with more formal names (e.g. pathid instead of int)
2. The functions are prepended with '_os_'
3. The return value for the functions are reserved for the error -- no needing to pull the error out of errno.
4. The sane values that were being returned in the result of the function are now passed by reference.

While passing parameters by reference may be a bit more typing, this is arguably a cleaner, more consistent approach to using the low-level I/O and other system calls, and is the path being pursued in the creation of this library.

## Work to be done

The project is still mid-port.

- `lib/todo/` contains additional Kreider C library routines that have not yet
  been brought into the current CMOC-oriented source layout.
- `cgfx/todo/` likewise contains CGFX routines that still need to be ported.
- More unit tests are needed, especially around the low-level OS-9 I/O layer,
  stdio compatibility, and floating-point formatting/parsing behavior.

In other words, the core library is already usable, but it is not yet a
complete port of all historical Kreider and CGFX components.
