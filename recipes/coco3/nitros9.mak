UTILPAK1 = attr build copy del deldir dir display list makdir mdir merge mfree procs rename tmode
DSDD80 = -DCyls=80 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1 -DD35

ifeq ($(CPU),6309)
AFLAGS := $(filter-out -DH6309=1,$(AFLAGS))
else
AFLAGS := $(filter-out -DH6309=0,$(AFLAGS))
endif

CMOC_OS9_LIB_DIR ?= $(CMOC_OS9_DIR)/lib
CMOC_OS9_CGFX_DIR ?= $(CMOC_OS9_DIR)/cgfx
CMOC_OS9_UNITTEST_DIR ?= $(CMOC_OS9_DIR)/unittest
CMOC_OS9_UTILS_DIR ?= $(CMOC_OS9_DIR)/utils
CMOC_OS9_UEMACS_DIR ?= $(CMOC_OS9_UTILS_DIR)/uemacs
CMOC_OS9_GRAPHICTEST_DIR ?= $(CMOC_OS9_DIR)/graphictest
CMOC_OS9_SYSGO ?= sysgo_dd

# SYS/ binaries that NitrOS-9 conventionally ships: fonts, mouse pointers, and
# the three pattern tables for 2/4/16-color graphics modes. Loaded into grfdrv
# state by the `merge` line in startup so /w windows can use them.
CMOC_OS9_SYS_DIR ?= $(NITROS9DIR)/level2/coco3/sys
CMOC_OS9_SYS_BIN_FILES ?= $(addprefix $(CMOC_OS9_SYS_DIR)/,\
	stdfonts stdpats_2 stdpats_4 stdpats_16 stdptrs)

# A fresh nitros9 checkout (e.g. in CI) doesn't have these built yet. Run the
# sys/ subdir's own makefile to produce them on demand.
$(CMOC_OS9_SYS_BIN_FILES):
	$(MAKE) -C $(CMOC_OS9_SYS_DIR) $(@F)

$(MODDIR)/ddd0_80d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD80) -DDNum=0 -DDD=1

$(MODDIR)/d0_80d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD80) -DDNum=0

$(MODDIR)/d1_80d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD80) -DDNum=1

$(MODDIR)/d2_80d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD80) -DDNum=2

$(CMOC_OS9_LIB_DIR)/libc.a $(CMOC_OS9_LIB_DIR)/libcf.a:
	$(MAKE) -C $(CMOC_OS9_LIB_DIR) libc.a libcf.a

$(CMOC_OS9_CGFX_DIR)/libcgfx.a:
	$(MAKE) -C $(CMOC_OS9_CGFX_DIR) libcgfx.a

$(CMOC_OS9_UNITTEST_DIR)/%: $(CMOC_OS9_UNITTEST_DIR)/%.c $(CMOC_OS9_LIB_DIR)/libc.a $(CMOC_OS9_LIB_DIR)/libcf.a $(CMOC_OS9_CGFX_DIR)/libcgfx.a
	$(MAKE) -C $(CMOC_OS9_UNITTEST_DIR) $(@F)

$(CMOC_OS9_UNITTEST_DIR)/%: $(CMOC_OS9_GRAPHICTEST_DIR)/%.c $(CMOC_OS9_LIB_DIR)/libc.a $(CMOC_OS9_LIB_DIR)/libcf.a $(CMOC_OS9_CGFX_DIR)/libcgfx.a
	$(MAKE) -C $(CMOC_OS9_UNITTEST_DIR) $(@F)

$(CMOC_OS9_UTILS_DIR)/%: $(CMOC_OS9_UTILS_DIR)/%.c $(CMOC_OS9_LIB_DIR)/libc.a $(CMOC_OS9_LIB_DIR)/libcf.a $(CMOC_OS9_CGFX_DIR)/libcgfx.a
	$(MAKE) -C $(CMOC_OS9_UTILS_DIR) $(@F)

$(CMOC_OS9_UEMACS_DIR)/umacs: $(CMOC_OS9_LIB_DIR)/libc.a $(CMOC_OS9_LIB_DIR)/libcf.a
	$(MAKE) -C $(CMOC_OS9_UEMACS_DIR) umacs

$(addprefix $(MODDIR)/,$(CMOC_OS9_TESTS)): $(MODDIR)/%: $(CMOC_OS9_UNITTEST_DIR)/% | $(MODDIR)
	$(CP) $(CMOC_OS9_UNITTEST_DIR)/$(@F) $@

$(addprefix $(MODDIR)/,$(CMOC_OS9_GRAPHICS_TESTS)): $(MODDIR)/%: $(CMOC_OS9_UNITTEST_DIR)/% | $(MODDIR)
	$(CP) $(CMOC_OS9_UNITTEST_DIR)/$(@F) $@

$(addprefix $(MODDIR)/,$(CMOC_OS9_UTILITIES)): $(MODDIR)/%: $(CMOC_OS9_UTILS_DIR)/% | $(MODDIR)
	$(CP) $(CMOC_OS9_UTILS_DIR)/$(@F) $@

$(MODDIR)/umacs: $(CMOC_OS9_UEMACS_DIR)/umacs | $(MODDIR)
	$(CP) $(CMOC_OS9_UEMACS_DIR)/umacs $@

$(DSKIMAGE): kernelfile bootfile $(MODDIR)/$(CMOC_OS9_SYSGO) $(addprefix $(MODDIR)/,$(CMDS)) $(STARTUP) $(CMOC_OS9_TESTSCRIPT) $(CMOC_OS9_SYS_BIN_FILES)
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=bootfile -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) $(MODDIR)/$(CMOC_OS9_SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(OS9COPY) $(addprefix $(MODDIR)/,$(CMDS)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9COPY) $(CMOC_OS9_SYS_BIN_FILES) $@,SYS
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(CPL) $(CMOC_OS9_TESTSCRIPT) $@,test
	$(OS9ATTR_TEXT) $@,test

MAME         ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -rompath $(MAME_ROM_PATH) -window -nothrottle -skip_gameinfo -autoboot_delay 5 -autoboot_command "DOS\n" -ext fdc -ext:fdc:wd17xx:0 525qd

run: $(DSKIMAGE)
	$(MAME) $(MAME_MACHINE) $(MAME_FLAGS) -flop1 $(DSKIMAGE)
