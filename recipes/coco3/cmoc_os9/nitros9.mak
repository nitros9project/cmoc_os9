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
CMOC_OS9_ROGUE_EPYX_C_DIR ?= $(CMOC_OS9_UTILS_DIR)/rogue_epyx_c
CMOC_OS9_GRAPHICTEST_DIR ?= $(CMOC_OS9_DIR)/graphictest
CMOC_OS9_SYSGO ?= sysgo_dd

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

$(CMOC_OS9_GRAPHICTEST_DIR)/%: $(CMOC_OS9_GRAPHICTEST_DIR)/%.c $(CMOC_OS9_LIB_DIR)/libc.a $(CMOC_OS9_LIB_DIR)/libcf.a $(CMOC_OS9_CGFX_DIR)/libcgfx.a
	$(MAKE) -C $(CMOC_OS9_UNITTEST_DIR) $(@F)

$(CMOC_OS9_UTILS_DIR)/%: $(CMOC_OS9_UTILS_DIR)/%.c $(CMOC_OS9_LIB_DIR)/libc.a $(CMOC_OS9_LIB_DIR)/libcf.a $(CMOC_OS9_CGFX_DIR)/libcgfx.a
	$(MAKE) -C $(CMOC_OS9_UTILS_DIR) $(@F)

$(CMOC_OS9_UEMACS_DIR)/umacs: $(CMOC_OS9_LIB_DIR)/libc.a $(CMOC_OS9_LIB_DIR)/libcf.a
	$(MAKE) -C $(CMOC_OS9_UEMACS_DIR) umacs

$(CMOC_OS9_ROGUE_EPYX_C_DIR)/roguec: $(CMOC_OS9_LIB_DIR)/libc.a
	$(MAKE) -C $(CMOC_OS9_ROGUE_EPYX_C_DIR) roguec

$(CMOC_OS9_ROGUE_EPYX_C_DIR)/rogue.dat:
	$(MAKE) -C $(CMOC_OS9_ROGUE_EPYX_C_DIR) rogue.dat

$(CMOC_OS9_ROGUE_EPYX_C_DIR)/rogue.hlp:
	$(MAKE) -C $(CMOC_OS9_ROGUE_EPYX_C_DIR) rogue.hlp

$(CMOC_OS9_ROGUE_EPYX_C_DIR)/rogue.chr:
	$(MAKE) -C $(CMOC_OS9_ROGUE_EPYX_C_DIR) rogue.chr

$(addprefix $(MODDIR)/,$(CMOC_OS9_TESTS)): $(MODDIR)/%: $(CMOC_OS9_UNITTEST_DIR)/% | $(MODDIR)
	$(CP) $(CMOC_OS9_UNITTEST_DIR)/$(@F) $@

$(addprefix $(MODDIR)/,$(CMOC_OS9_GRAPHICS_TESTS)): $(MODDIR)/%: $(CMOC_OS9_UNITTEST_DIR)/% | $(MODDIR)
	$(CP) $(CMOC_OS9_UNITTEST_DIR)/$(@F) $@

$(addprefix $(MODDIR)/,$(CMOC_OS9_UTILITIES)): $(MODDIR)/%: $(CMOC_OS9_UTILS_DIR)/% | $(MODDIR)
	$(CP) $(CMOC_OS9_UTILS_DIR)/$(@F) $@

$(MODDIR)/umacs: $(CMOC_OS9_UEMACS_DIR)/umacs | $(MODDIR)
	$(CP) $(CMOC_OS9_UEMACS_DIR)/umacs $@

$(MODDIR)/roguec: $(CMOC_OS9_ROGUE_EPYX_C_DIR)/roguec | $(MODDIR)
	$(CP) $(CMOC_OS9_ROGUE_EPYX_C_DIR)/roguec $@

$(MODDIR)/rogue.dat: $(CMOC_OS9_ROGUE_EPYX_C_DIR)/rogue.dat | $(MODDIR)
	$(CP) $(CMOC_OS9_ROGUE_EPYX_C_DIR)/rogue.dat $@

$(MODDIR)/rogue.hlp: $(CMOC_OS9_ROGUE_EPYX_C_DIR)/rogue.hlp | $(MODDIR)
	$(CP) $(CMOC_OS9_ROGUE_EPYX_C_DIR)/rogue.hlp $@

$(MODDIR)/rogue.chr: $(CMOC_OS9_ROGUE_EPYX_C_DIR)/rogue.chr | $(MODDIR)
	$(CP) $(CMOC_OS9_ROGUE_EPYX_C_DIR)/rogue.chr $@

$(DSKIMAGE): kernelfile bootfile $(MODDIR)/$(CMOC_OS9_SYSGO) $(addprefix $(MODDIR)/,$(CMDS)) $(MODDIR)/rogue.dat $(MODDIR)/rogue.hlp $(MODDIR)/rogue.chr $(STARTUP) $(CMOC_OS9_TESTSCRIPT)
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
	$(OS9COPY) $(MODDIR)/rogue.dat $@,rogue.dat
	$(OS9COPY) $(MODDIR)/rogue.hlp $@,rogue.hlp
	$(OS9COPY) $(MODDIR)/rogue.chr $@,rogue.chr
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(CPL) $(CMOC_OS9_TESTSCRIPT) $@,test
	$(OS9ATTR_TEXT) $@,test

MAME         ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -inipath $(HOME)/mame -cfg_directory $(HOME)/mame/cfg -window -nothrottle -skip_gameinfo -autoboot_delay 5 -autoboot_command "DOS\n" -ext fdc -ext:fdc:wd17xx:0 525qd

run: $(DSKIMAGE)
	$(MAME) $(MAME_MACHINE) $(MAME_FLAGS) -flop1 $(DSKIMAGE) -flop2 /Users/boisy/Projects/coco-shelf/nitros9/3rdparty/packages/rogue/rogue.dsk

