PROGRAM = roguec
CMOC ?= cmoc
LWASM ?= lwasm
CFLAGS = --os9 -O2 --function-stack=0 --add-os9-stack-space=256 -I. -I../../include
ASFLAGS = --obj
LDLIBS = -L../../lib -lc
ROGUE_DAT_SRC ?= ../../../nitros9/3rdparty/packages/rogue/rogue.dat
ROGUE_HLP_SRC ?= ../../../nitros9/3rdparty/packages/rogue/rogue.hlp
ROGUE_CHR_SRC ?= ../../../nitros9/3rdparty/packages/rogue/rogue.chr
ROGUE_SCR_SRC ?= ../../../nitros9/3rdparty/packages/rogue/rogue.scr

SRCS = main.c epyx_arena.c epyx_format.c epyx_screen.c rogue_game.c
ASRCS = rogue_signal.as
OBJS = $(SRCS:.c=.o) $(ASRCS:.as=.o)

.PHONY: all clean help

# Build the rogue executable along with its data files (default target)
all: $(PROGRAM) rogue.dat rogue.hlp rogue.chr rogue.scr

$(PROGRAM): $(OBJS)
	$(CMOC) $(CFLAGS) -o $@ $(OBJS) $(LDLIBS)

rogue.dat: $(ROGUE_DAT_SRC)
	cp $< $@

rogue.hlp: $(ROGUE_HLP_SRC)
	cp $< $@

rogue.chr: $(ROGUE_CHR_SRC)
	cp $< $@

rogue.scr: $(ROGUE_SCR_SRC)
	cp $< $@

%.o: %.c
	$(CMOC) $(CFLAGS) -c $<

%.o: %.as
	$(LWASM) $(ASFLAGS) -o$@ $<

# Remove the executable, data files, and intermediate artifacts
clean:
	rm -f $(PROGRAM) rogue.dat rogue.hlp rogue.chr rogue.scr *.o *.s *.list *.map

# Display this help message listing available phony targets
help:
	@echo "Available targets:"
	@awk 'BEGIN{c=""} /^# /{c=substr($$0,3); next} /^[a-zA-Z_][a-zA-Z0-9_.-]*:/{if(c!=""){t=$$1; sub(/:.*/,"",t); printf "  %-20s %s\n", t, c}; c=""; next} {c=""}' $(MAKEFILE_LIST)
