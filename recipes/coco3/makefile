# Local CoCo 3 test-disk recipe for cmoc_os9.

CMOC_OS9_RECIPE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CMOC_OS9_DIR ?= $(abspath $(CMOC_OS9_RECIPE_DIR)/../..)
NITROS9DIR ?= $(abspath $(CMOC_OS9_DIR)/../nitros9)

PORT ?= coco3
LEVEL ?= 2
CPU ?= 6809
MACHINE ?= Tandy Color Computer 3

include $(NITROS9DIR)/recipes/rules.mak

RECIPE ?= coco3
-include recipe.mak
vpath %.asm $(LEVEL1)/coco1/modules

ifeq ($(CPU),6309)
AFLAGS += -DH6309=1
COCO3_LIB = libcoco3_6309.a
NOS9_LIB = libnos96309l2.a
COCO3_LFLAG = -lcoco3_6309
else ifeq ($(CPU),6809)
AFLAGS += -DH6309=0
COCO3_LIB = libcoco3.a
NOS9_LIB = libnos96809l2.a
COCO3_LFLAG = -lcoco3
else
$(error Unsupported CPU "$(CPU)"; use CPU=6809 or CPU=6309)
endif

TERM_COLS ?= 80
TERM_ALTCOLOR ?= 0
REL = rel_$(TERM_COLS)
ifeq ($(TERM_COLS),32)
TERM_WIN_DT = term_vdg.dt
TERM_IO = covdg.io
else
TERM_WIN_DT = term_win$(TERM_COLS).dt
TERM_IO = cowin.io
endif
ifeq ($(TERM_ALTCOLOR),1)
TERM_ALTCOLOR_FLAGS = -DALTCOLOR=1
else
TERM_ALTCOLOR_FLAGS =
endif

DSKIMAGE ?= l$(LEVEL)_$(RECIPE).dsk
OS9FORMAT_CMD ?= $(OS9FORMAT_DS40)

AFLAGS += -I.
AFLAGS += -I$(L2MD)/kernel -I$(L2PMD)
AFLAGS += -I$(L1MD)/kernel -I$(L1MD)
AFLAGS += $(AFLAGS_EXTRA)
LFLAGS += -L $(LIBDIR) $(COCO3_LFLAG) -lnet -lalib
LFLAGS += $(LFLAGS_EXTRA)

RBF ?= rbf.mn rb1773.dr ddd0_40d.dd d0_40d.dd d1_40d.dd d2_40d.dd
SCF ?= scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb $(TERM_IO) \
	$(TERM_WIN_DT) w.dw w1.dw w2.dw w3.dw w4.dw w5.dw w6.dw w7.dw \
	w8.dw w9.dw w10.dw w11.dw w12.dw w13.dw w14.dw w15.dw
PIPE ?= pipeman.mn piper.dr pipe.dd
CLOCK ?= clock_60hz clock2_soft
KERNEL_TRACK ?= $(REL) boot_1773_6ms krn
KERNELFILE = kerneltrack
STARTUP ?= $(NITROS9DIR)/level2/$(PORT)/startup

BOOTMODS ?= krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	sysgo_dd shell_21 \
	$(BOOTMODS_EXTRA)

SHELLMODS = shellplus date deiniz echo iniz link load save unlink
UTILPAK1 = attr build copy del deldir dir display list makdir mdir merge mfree procs rename tmode

CMDS_BASE ?= $(STDCMDS) grfdrv shell utilpak1
CMDS += $(CMDS_BASE) \
	$(CMDS_EXTRA)

LIB_NAMES = $(NOS9_LIB) libnet.a libalib.a $(COCO3_LIB)
include $(NITROS9DIR)/recipes/libs.mak

all: libs $(DSKIMAGE)

kernelfile: $(addprefix $(MODDIR)/,$(KERNEL_TRACK))
	$(MERGE) $(addprefix $(MODDIR)/,$(KERNEL_TRACK)) >$(KERNELFILE)

bootfile: $(addprefix $(MODDIR)/,$(BOOTMODS))
	$(MERGE) $(addprefix $(MODDIR)/,$(BOOTMODS)) >$@

include nitros9.mak

$(MODDIR)/term_win40.dt: term_win40.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(TERM_ALTCOLOR_FLAGS)

$(MODDIR)/term_win80.dt: term_win80.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(TERM_ALTCOLOR_FLAGS)

$(MODDIR)/covdg.io: covdg.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DCOCO2=1

$(MODDIR)/pwd: pd.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

$(MODDIR)/pxd: pd.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1

$(MODDIR)/xmode: xmode.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1

$(MODDIR)/tmode: xmode.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

$(MODDIR)/shell: $(addprefix $(MODDIR)/,$(SHELLMODS)) | $(MODDIR)
	$(MERGE) $(addprefix $(MODDIR)/,$(SHELLMODS)) >$@

$(MODDIR)/utilpak1: $(addprefix $(MODDIR)/,$(UTILPAK1)) | $(MODDIR)
	$(MERGE) $(addprefix $(MODDIR)/,$(UTILPAK1)) >$@

$(MODDIR)/boot_1773_6ms: boot_1773.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DSTEP=0

$(MODDIR)/sysgo_dd: sysgo.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDD=1

$(MODDIR)/clock_60hz: clock.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPwrLnFrq=60

$(MODDIR)/clock_50hz: clock.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPwrLnFrq=50

$(MODDIR)/rel_32: rel.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DWidth=32

$(MODDIR)/rel_40: rel.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DWidth=40

$(MODDIR)/rel_80: rel.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DWidth=80

DSDD40 = -DCyls=40 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1

$(MODDIR)/ddd0_40d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD40) -DDNum=0 -DDD=1

$(MODDIR)/d0_40d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD40) -DDNum=0

$(MODDIR)/d1_40d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD40) -DDNum=1

$(MODDIR)/d2_40d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD40) -DDNum=2

clean:
	$(RM) *.list *.map bootfile $(KERNELFILE) *.dsk buildinfo
	-rm -rf $(OBJDIR) $(LIBDIR) $(MODDIR)

.PHONY: all clean libs run
