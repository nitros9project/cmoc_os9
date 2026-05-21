DCC = cmoc
CPP = cpp -Wno-builtin-macro-redefined
DCCFLAGS = --cpp="$(CPP)" --os9 -nodefaultlibs -I../../include
LFLAGS = -L../../lib -lc

OFILES = amatch.o append.o bitmap.o catsub.o ckglob.o deflt.o del.o docmd.o \
	dodash.o doglob.o doprnt.o doread.o dowrite.o ed.o egets.o esc.o \
	find.o getfn.o getlst.o getnum.o getone.o getpat.o getptr.o getrhs.o \
	gettxt.o ins.o join.o makepat.o maksub.o matchs.o move.o omatch.o \
	optpat.o set.o setbuf.o subst.o unmkpat.o

all: ed

ed: $(OFILES)
	$(DCC) $(DCCFLAGS) -o $@ $(OFILES) $(LFLAGS)

%.o: %.c
	$(DCC) $(DCCFLAGS) --compile -o $@ $<

clean:
	rm -f ed $(OFILES) *.list *.map
