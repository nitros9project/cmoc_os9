# CMOC OS-9 Utilities

This directory contains small userland utilities for the CMOC OS-9 test disk.

Most of the single-command utilities in this directory are adapted from the
suckless `sbase` project:

https://git.suckless.org/sbase/

The adapted utilities are intentionally not direct imports of the `sbase`
support library. They have been rewritten or reduced to build against the
CMOC OS-9 C library and OS-9 system interfaces. In particular, these ports
avoid the upstream `util.h`, `text.h`, UTF helper library, POSIX `getline()`,
and Unix APIs that are not available in this environment.

The current sbase-derived utilities include:

`basename`, `cat`, `cksum`, `cmp`, `comm`, `cut`, `dirname`, `echo`, `false`,
`head`, `mkdir`, `paste`, `rev`, `rmdir`, `seq`, `sleep`, `split`, `strings`,
`sync`, `tail`, `tee`, `tr`, `true`, `tty`, `uniq`, `wc`, and `yes`.

These ports favor small fixed buffers and simple option handling suitable for
the target OS-9 environment. Some commands therefore support a smaller option
set than upstream `sbase`. See each source file for command-specific behavior.

The sbase-derived code is covered by the MIT license in `LICENSE.sbase`.

Subdirectories may have separate provenance:

- `rogue/` contains the Rogue 5.4-derived port and its own license/readme.
- `uemacs/` contains the uEmacs sources and its own readme.
