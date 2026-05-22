#  makefile for Micro emacs for OS-9/6809

DCC     = cmoc
CMOC_OS9_DIR ?= $(abspath ../..)
RM      = rm -f

CMOC_CPP = --cpp="cpp -Wno-builtin-macro-redefined"
DCCFLAGS = $(CMOC_CPP) --os9 --add-os9-stack-space=2048 -w -I. -I$(CMOC_OS9_DIR)/include -DOS9 -DNULL=0
LDFLAGS = -L$(CMOC_OS9_DIR)/lib -lc
CMOC_INTDIR = .cmoc-int

MAINO  = uemain1.o uemain2.o uemain3.o uemain4.o uemaintable.o
DISPO  = uedisplay1.o uedisplay2.o uedisplay3.o
RESTO  = uebasic.o uebuffer1.o uebuffer2.o uefile1.o uefile2.o uefileio.o \
  ueline1.o ueline2.o uerandom1.o uerandom2.o ueregion.o uesearch.o uespawn.o \
  uetermio.o uecoco.o uewindow.o ueword.o
OFILES = $(MAINO) $(DISPO) $(RESTO)

all: umacs

# use cio libarary
umacs: $(OFILES)
	$(DCC) $(DCCFLAGS) -o $@ $^ $(LDFLAGS)

$(MAINO): ueed.h uemain.h
$(DISPO): ueed.h uedisplay.h
$(RESTO): ueed.h

%.o: %.c
	@mkdir -p $(CMOC_INTDIR)/$*
	$(DCC) $(DCCFLAGS) --intermediate --intdir=$(CMOC_INTDIR)/$* --compile -o $@ $<

clean:
	$(RM) -r $(CMOC_INTDIR)
	$(RM) $(OFILES) umacs *.list *.map c.errors cstr.* ctmp.*
