PROGRAM = roguec
CMOC ?= cmoc
CFLAGS = --os9 -O2 --function-stack=0 -I. -I../../include
LDLIBS = -L../../lib -lc
ROGUE_DAT_SRC ?= ../../../nitros9/3rdparty/packages/rogue/rogue.dat
ROGUE_HLP_SRC ?= ../../../nitros9/3rdparty/packages/rogue/rogue.hlp
ROGUE_CHR_SRC ?= ../../../nitros9/3rdparty/packages/rogue/rogue.chr

SRCS = main.c epyx_arena.c epyx_format.c epyx_screen.c epyx_startup.c epyx_tables.c rogue_game.c
OBJS = $(SRCS:.c=.o)

all: $(PROGRAM) rogue.dat rogue.hlp rogue.chr

$(PROGRAM): $(OBJS)
	$(CMOC) $(CFLAGS) -o $@ $(OBJS) $(LDLIBS)

rogue.dat: $(ROGUE_DAT_SRC)
	cp $< $@

rogue.hlp: $(ROGUE_HLP_SRC)
	cp $< $@

rogue.chr: $(ROGUE_CHR_SRC)
	cp $< $@

%.o: %.c
	$(CMOC) $(CFLAGS) -c $<

clean:
	rm -f $(PROGRAM) rogue.dat rogue.hlp rogue.chr *.o *.s *.list *.map
