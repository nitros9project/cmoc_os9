DCC = cmoc
CPP = cpp -Wno-builtin-macro-redefined
DCCFLAGS = --cpp="$(CPP)" --os9 -nodefaultlibs -I../../include
LFLAGS = -L../../lib -lc

OFILES = amatch.o append.o bitmap.o catsub.o ckglob.o deflt.o del.o docmd.o \
	dodash.o doglob.o doprnt.o doread.o dowrite.o ed.o egets.o esc.o \
	find.o getfn.o getlst.o getnum.o getone.o getpat.o getptr.o getrhs.o \
	gettxt.o ins.o join.o makepat.o maksub.o matchs.o move.o omatch.o \
	optpat.o set.o setbuf.o subst.o unmkpat.o

.PHONY: all clean help

# Build the ed editor (default target)
all: ed

ed: $(OFILES)
	$(DCC) $(DCCFLAGS) -o $@ $(OFILES) $(LFLAGS)

%.o: %.c
	$(DCC) $(DCCFLAGS) --compile -o $@ $<

# Remove ed binary, object files, and listings
clean:
	rm -f ed $(OFILES) *.list *.map

# Display this help message listing available phony targets
help:
	@echo "Available targets:"
	@awk 'BEGIN{c=""} /^# /{c=substr($$0,3); next} /^[a-zA-Z_][a-zA-Z0-9_.-]*:/{if(c!=""){t=$$1; sub(/:.*/,"",t); printf "  %-20s %s\n", t, c}; c=""; next} {c=""}' $(MAKEFILE_LIST)
