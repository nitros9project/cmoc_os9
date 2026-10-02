#ifndef CMOC_LLVM_DIR_H
#define CMOC_LLVM_DIR_H
#include "cmoc_os9.h"
typedef CMOC_DIR DIR;
#define DIRECT struct direct
#define opendir cmoc_opendir
#define readdir cmoc_readdir
#define closedir cmoc_closedir
#define seekdir cmoc_seekdir
#define telldir cmoc_telldir
#define rewinddir(d) cmoc_seekdir(d, 0L)
#endif
