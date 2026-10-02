PROJECTS ?= $(abspath ../..)
LLVM_BIN ?= $(PROJECTS)/llvm-mc6809/build/bin
OS9_SYSROOT ?= $(PROJECTS)/picolibc/builddir-mc6809-os9-Os/stage/usr/local
OPT ?= Os
HOST_CC ?= /usr/bin/clang
OUT := out/$(OPT)
CLANG := $(LLVM_BIN)/clang
AR := $(LLVM_BIN)/llvm-ar
CFLAGS := --target=mc6809-unknown-os9 --sysroot=$(OS9_SYSROOT) -$(OPT) -Wall -Wextra -Werror -ffunction-sections -fdata-sections -Iinclude -Imath
LIBRARY := $(OUT)/libcmoc_os9_compat.a
SOURCES := $(filter-out src/float_stdio.c,$(wildcard src/*.c))
OBJECTS := $(patsubst src/%.c,$(OUT)/%.o,$(SOURCES)) $(OUT)/native.o $(patsubst math/%.c,$(OUT)/math/%.o,$(wildcard math/*.c)) $(patsubst stdio/%.c,$(OUT)/stdio/%.o,$(filter-out stdio/conv_flt.c stdio/vfprintf_float.c stdio/vfprintf_char.c stdio/vfprintf_str.c stdio/vfprintf_n.c stdio/vfprintf_int.c stdio/ultoa_invert.c,$(wildcard stdio/*.c)))
.DEFAULT_GOAL := all
.PHONY: all test audit link-check FORCE
all: $(LIBRARY) $(OUT)/libcmoc_os9_float.a
$(OUT):
	mkdir -p $@
# Recompile on every invocation: ninja/make cannot detect compiler or
# sysroot changes without explicit dependencies on those external files.
$(OUT)/%.o: src/%.c $(wildcard include/*.h) src/syscalls.h FORCE | $(OUT)
	$(CLANG) $(CFLAGS) -c $< -o $@
$(OUT)/math/%.o: math/%.c $(wildcard math/*.h) FORCE | $(OUT)
	mkdir -p $(OUT)/math
	$(CLANG) $(CFLAGS) -Wno-attribute-alias -include math/build_config.h -c $< -o $@
$(OUT)/stdio/%.o: stdio/%.c $(wildcard stdio/*.h) $(wildcard stdio/*.c) FORCE | $(OUT)
	mkdir -p $(OUT)/stdio
	$(CLANG) $(CFLAGS) -Wno-attribute-alias -c $< -o $@
$(OUT)/native.o: src/native.S FORCE | $(OUT)
	$(CLANG) --target=mc6809-unknown-os9 -c $< -o $@
$(LIBRARY): $(OBJECTS)
	$(RM) $@
	$(AR) rcs $@ $(OBJECTS)
$(OUT)/libcmoc_os9_float.a: $(OUT)/float_stdio.o
	$(RM) $@
	$(AR) rcs $@ $<
FORCE:
test: | $(OUT)
	$(HOST_CC) -std=c99 -Wall -Wextra -Werror -ffunction-sections -fdata-sections -Iinclude -Isrc src/compat.c tests/compat_test.c -o $(OUT)/compat-test
	$(OUT)/compat-test
	$(HOST_CC) -std=c11 -Wall -Wextra -Werror -DCMOC_HOST_TEST -Iinclude src/kernel.c tests/kernel_test.c -o $(OUT)/kernel-test
	$(OUT)/kernel-test
	$(HOST_CC) -std=c11 -Wall -Wextra -Werror -fno-builtin -Iinclude src/extensions.c src/calendar.c src/float.c tests/extension_test.c -o $(OUT)/extension-test
	$(OUT)/extension-test
	$(HOST_CC) -std=c11 -Wall -Wextra -Werror -fno-builtin -include tests/host-math/config.h -Itests/host-math -Iinclude -Imath math/*.c src/math_legacy.c tests/math_test.c -o $(OUT)/math-test
	$(OUT)/math-test
	$(HOST_CC) -std=c11 -Wall -Wextra -Werror -DCMOC_HOST_TEST -Dsbrk=cmoc_test_sbrk -Wno-deprecated-declarations -Iinclude src/password.c src/modules.c src/memory.c src/extensions.c tests/service_test.c -o $(OUT)/service-test
	$(OUT)/service-test
	$(HOST_CC) -std=c11 -Wall -Wextra -Werror -DCMOC_HOST_TEST -Iinclude src/signals.c tests/signal_test.c -o $(OUT)/signal-test
	$(OUT)/signal-test
	$(HOST_CC) -std=c11 -Wall -Wextra -Werror -DCMOC_HOST_TEST -Ddup=cmoc_test_dup -Dclose=cmoc_test_close -Dfdopen=cmoc_test_fdopen -Dfileno=cmoc_test_fileno -Dfclose=cmoc_test_fclose -Iinclude src/commands.c tests/command_test.c -o $(OUT)/command-test
	$(OUT)/command-test
OS9_RUNNER ?= $(PROJECTS)/picolibc/scripts/run-mc6809-os9
.PHONY: smoke run-smoke
smoke: $(OUT)/os9smoke $(OUT)/floatsmoke
	$(PYTHON) tests/os9_module.py $(OUT)/os9smoke $(OUT)/floatsmoke
$(OUT)/os9smoke: tests/os9_smoke.c $(LIBRARY)
	$(CLANG) $(CFLAGS) $< $(LIBRARY) -o $@
$(OUT)/floatsmoke: tests/floating_smoke.c $(LIBRARY) $(OUT)/libcmoc_os9_float.a
	$(CLANG) $(CFLAGS) $< $(OUT)/libcmoc_os9_float.a $(LIBRARY) -o $@
# The runner requires a boot image, firmware, usim09pt and ToolShed os9.
run-smoke: smoke
	$(OS9_RUNNER) $(OUT)/os9smoke
	$(OS9_RUNNER) $(OUT)/floatsmoke

PYTHON ?= python3
NM := $(LLVM_BIN)/llvm-nm
RUNTIME = $(shell $(CLANG) --target=mc6809-unknown-os9 -print-file-name=libclang_rt.os9.a)
audit: $(LIBRARY)
	$(PYTHON) tests/audit_api.py --clang $(CLANG) --nm $(NM) --sysroot $(OS9_SYSROOT) --runtime $(RUNTIME) --out $(OUT)
link-check: $(LIBRARY)
	$(PYTHON) tests/link_all.py --clang $(CLANG) --nm $(NM) --sysroot $(OS9_SYSROOT) --out $(OUT) --opt $(OPT)
