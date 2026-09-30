PROJECTS ?= $(abspath ../..)
LLVM_BIN ?= $(PROJECTS)/llvm-mc6809/build/bin
OS9_SYSROOT ?= $(PROJECTS)/picolibc/builddir-mc6809-os9-Os/stage/usr/local
OPT ?= Os
HOST_CC ?= /usr/bin/clang
OUT := out/$(OPT)
CLANG := $(LLVM_BIN)/clang
AR := $(LLVM_BIN)/llvm-ar
CFLAGS := --target=mc6809-unknown-os9 --sysroot=$(OS9_SYSROOT) -$(OPT) -Wall -Wextra -Werror -Iinclude
LIBRARY := $(OUT)/libcmoc_os9_compat.a
OBJECTS := $(OUT)/compat.o $(OUT)/syscalls.o
.DEFAULT_GOAL := all
.PHONY: all test FORCE
all: $(LIBRARY)
$(OUT):
	mkdir -p $@
# Recompile on every invocation: ninja/make cannot detect compiler or
# sysroot changes without explicit dependencies on those external files.
$(OUT)/%.o: src/%.c src/syscalls.h include/cmoc_os9_compat.h FORCE | $(OUT)
	$(CLANG) $(CFLAGS) -c $< -o $@
$(LIBRARY): $(OBJECTS)
	$(AR) rcs $@ $(OBJECTS)
FORCE:
test: | $(OUT)
	$(HOST_CC) -std=c99 -Wall -Wextra -Werror -Iinclude -Isrc src/compat.c tests/compat_test.c -o $(OUT)/compat-test
	$(OUT)/compat-test
OS9_RUNNER ?= $(PROJECTS)/picolibc/scripts/run-mc6809-os9
.PHONY: smoke run-smoke
smoke: $(OUT)/os9smoke
$(OUT)/os9smoke: tests/os9_smoke.c $(LIBRARY)
	$(CLANG) $(CFLAGS) $< $(LIBRARY) -o $@
# The runner requires a boot image, firmware, usim09pt and ToolShed os9.
run-smoke: smoke
	$(OS9_RUNNER) $(OUT)/os9smoke
