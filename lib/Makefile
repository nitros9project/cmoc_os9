# Makefile to create assembler library

STRING = strlen.o strcmp.o strpbrk.o strtok.o strspn.o patmatch.o strucmp.o \
	reverse.o index.o stringsu.o strhcpy.o strclr.o strass.o strings.o \
	case.o strncat.o hstrings.o strncmp.o strncpy.o strnucmp.o
MEM = mem.o memory.o memchr.o memccpy.o memcmp.o memset.o memcpy.o memchr.o \
	memncmp.o
SYS = sleep.o
IO = printf.o pffinit.o pflinit.o pfldummy.o putc.o puts.o iob_data.o setbase.o fseek.o fopen.o
LOW_IO = access.o create.o open.o read.o write.o
MISC = rpterr.o chcodes.o htoi.o htol.o rand.o prof.o minmax.o
MATH_SUPPORT = ccmult.o ccdiv.o ccmod.o atoi.o abs.o
FLOAT_SUPPORT = fcommon.o cfloats.o atof.o scale.o
LONG_SUPPORT = clcommon.o clcompare.o clconvert.o claddsub.o clbits.o cldiv.o clmove.o clnegcompl.o clincdec.o clmul.o clshifts.o atol.o
FILE_SUPPORT = attr.o io.o
OS = stat.o id.o mod.o process.o cfinish.o tidyup.o
DEBUG = debug.o
TIME = time.o utime.o
MODS = $(STRING) $(OS) $(IO) $(LOW_IO) $(MEM) $(SYS) $(MISC) $(MATH_SUPPORT) $(FLOAT_SUPPORT) $(LONG_SUPPORT) $(FILE_SUPPORT) $(DEBUG) $(TIME) syscall.o syscommon.o
CC = cmoc
ASM = lwasm
CFLAGS = --os9 -I../include
ASOUT = --obj -o

%.o: %.as
	$(ASM) $(AFLAGS) $< $(ASOUT)$@

%.o: %.asm
	$(ASM) $(AFLAGS) $< $(ASOUT)$@

all:	libc.a

libc.a: $(MODS)
	lwar -c $@ $(MODS)

dskclean: clean

clean:
	$(RM) *.o libc.a
