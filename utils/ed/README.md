# ed

This is the Unix `ed` line editor, originally ported from Minix to OS-9
Level One.

`ed` remains useful on small OS-9 systems because it fits in limited memory,
does not depend on terminal escape sequences, and can be driven from scripts.

## Building

From this directory:

```sh
make
```

From the parent utilities directory:

```sh
make ed
```

The build uses `cmoc --os9` and links against the local CMOC OS-9 C library in
`../../lib`.

## Notes

The original package included OS-9 shell build helpers. Those obsolete files
are not used in this tree; the maintained build entry point is the local
`makefile`.
