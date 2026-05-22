This directory is the source of truth for the CoCo 3 `cmoc_os9` test-disk recipe.

Files here:
- `recipe.mak`: recipe settings consumed by the `nitros9` CoCo 3 recipe build.
- `nitros9.mak`: shared `make` rules consumed by the `nitros9` CoCo 3 wrapper.
- `startup`: minimal boot script copied onto the test disk as `startup`.
- `test`: manual regression batch script copied onto the disk when needed.

The `nitros9` tree still owns the actual disk-image build outputs. Its
`recipes/coco3/cmoc_os9/makefile` includes the shared files here so the recipe
settings, build rules, and harness scripts do not drift across repositories.
