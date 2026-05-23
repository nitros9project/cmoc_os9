# Makefile to create assembler library

STRING = strlen.o strcmp.o strpbrk.o strtok.o strspn.o patmatch.o strucmp.o \
	reverse.o index.o stringsu.o strhcpy.o strclr.o strass.o strings.o \
	case.o ctypefn.o strncat.o hstrings.o strncmp.o strncpy.o strnucmp.o xtoa.o \
	ltoa.o findstr.o swab.o
MEM = mem.o sbrk.o ibrk.o brk.o memory.o memchr.o memccpy.o memcmp.o memset.o memcpy.o \
	memncmp.o calloc.o realloc.o
SYS = sleep.o
LOW_IO = access.o chmod.o chown.o dir.o create.o open.o read.o write.o
MISC = rpterr.o chcodes.o htoi.o htol.o rand.o prof.o getopt.o popen.o adump.o pwent.o defdrive.o pwcryp.o errmsg.o prgname.o mktemp.o setbuf.o minmax.o uminmax.o bsearch.o qsort.o tidyup.o system.o setjmp.o devtyp.o sets.o dirutil.o dirseek.o datmods.o misc.o skip.o gs.o ss.o os_gs_ss.o getsp.o intercept.o signal.o strtol.o
MATH_SUPPORT = ccmult.o ccdiv.o ccmod.o cshifts.o mu168.o atoi.o abs.o
LONG_SUPPORT = clcommon.o clcompare.o clconvert.o claddsub.o clbits.o cldiv.o cludiv.o clmove.o clnegcompl.o clincdec.o clmul.o clshifts.o l3tol.o ltol3.o ltoc3tol.o atol.o
FILE_SUPPORT = attr.o io.o
OS = abort.o stat.o id.o getpid.o uid.o kill.o mod.o process.o proccompat.o cfinish.o
DEBUG = debug.o
TIME = time.o utime.o mktime.o timevars.o isleap.o localtime.o asctime.o ctime.o
COMMON_IO = getc.o printf.o putc.o putw.o fclose.o fflush.o puts.o fputs.o setbase.o fseek.o fopen.o fread.o fwrite.o gets.o fgets.o stdiofn.o iob_data.o
NONFLOAT_IO = $(COMMON_IO) pfldummy.o pffdummy.o
FLOAT_IO = $(COMMON_IO) pflinit.o pffinit.o
COMMON_MODS = $(STRING) $(OS) $(MEM) $(SYS) $(MISC) $(MATH_SUPPORT) \
	$(LONG_SUPPORT) $(DEBUG) $(TIME) $(COMMON_IO) $(LOW_IO) $(FILE_SUPPORT) \
	syscall.o syscommon.o
FLOAT_SUPPORT = fcommon.o scale.o atof.o frexp.o ldexp.o

CC = cmoc
ASM = lwasm
AR = lwar
INCLUDE_DIR = $(abspath ../include)
CMOC_CPP = --cpp="cpp -Wno-builtin-macro-redefined"
BASE_CFLAGS = $(CMOC_CPP) --os9 -I$(INCLUDE_DIR)
FLOAT_CFLAGS = $(BASE_CFLAGS) --mc6839
ASOUT = --obj -o
OBJDIR_BASE = obj_base
OBJDIR_FLOAT = obj_float

BASE_MODS = $(COMMON_MODS) pflinit.o pffdummy.o fcommon.o
FLOAT_MODS = $(COMMON_MODS) pflinit.o pffinit.o $(FLOAT_SUPPORT)
BASE_OBJS = $(addprefix $(OBJDIR_BASE)/,$(BASE_MODS))
FLOAT_OBJS = $(addprefix $(OBJDIR_FLOAT)/,$(FLOAT_MODS))

.PHONY: all dskclean clean help

# Build libc.a and libcf.a (default target)
all: libc.a libcf.a

libc.a: $(BASE_OBJS)
	$(AR) -c $@ $(BASE_OBJS)

libcf.a: $(FLOAT_OBJS)
	$(AR) -c $@ $(FLOAT_OBJS)

$(OBJDIR_BASE):
	mkdir -p $@

$(OBJDIR_FLOAT):
	mkdir -p $@

$(OBJDIR_BASE)/%.o: %.c | $(OBJDIR_BASE)
	cd $(OBJDIR_BASE) && $(CC) $(BASE_CFLAGS) -c ../$< -o$(@F)

$(OBJDIR_FLOAT)/%.o: %.c | $(OBJDIR_FLOAT)
	cd $(OBJDIR_FLOAT) && $(CC) $(FLOAT_CFLAGS) -c ../$< -o$(@F)

$(OBJDIR_BASE)/%.o: %.as | $(OBJDIR_BASE)
	cd $(OBJDIR_BASE) && $(ASM) $(AFLAGS) ../$< $(ASOUT)$(@F)

$(OBJDIR_FLOAT)/%.o: %.as | $(OBJDIR_FLOAT)
	cd $(OBJDIR_FLOAT) && $(ASM) $(AFLAGS) ../$< $(ASOUT)$(@F)

$(OBJDIR_BASE)/%.o: %.asm | $(OBJDIR_BASE)
	cd $(OBJDIR_BASE) && $(ASM) $(AFLAGS) ../$< $(ASOUT)$(@F)

$(OBJDIR_FLOAT)/%.o: %.asm | $(OBJDIR_FLOAT)
	cd $(OBJDIR_FLOAT) && $(ASM) $(AFLAGS) ../$< $(ASOUT)$(@F)

# Alias for clean (removes build artifacts including disk images)
dskclean: clean

# Remove build artifacts
clean:
	$(RM) -r $(OBJDIR_BASE) $(OBJDIR_FLOAT)
	$(RM) *.o *.list *.map libc.a libcf.a

# Display this help message listing available phony targets
help:
	@echo "Available targets:"
	@awk 'BEGIN{c=""} /^# /{c=substr($$0,3); next} /^[a-zA-Z_][a-zA-Z0-9_.-]*:/{if(c!=""){t=$$1; sub(/:.*/,"",t); printf "  %-20s %s\n", t, c}; c=""; next} {c=""}' $(MAKEFILE_LIST)
