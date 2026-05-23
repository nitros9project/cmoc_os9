This directory owns the CoCo 3 `cmoc_os9` NitrOS-9 test-disk recipe.

Files here:
- `makefile`: local recipe driver that builds the disk image in this directory.
- `recipe.mak`: recipe settings consumed by the local recipe build.
- `nitros9.mak`: CMOC OS-9 build and disk population rules.
- `startup`: minimal boot script copied onto the test disk as `startup`.
- `test`: manual regression batch script copied onto the disk when needed.

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
