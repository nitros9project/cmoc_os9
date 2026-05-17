CC = cmoc
OS9FLAGS = --os9 -nodefaultlibs
OPT = -O0
LFLAGS = -I../include -I../cgfx/include $(OS9FLAGS)
CMOC_BIN ?= $(shell command -v cmoc)
CMOC_FLOAT_LIB_DIR ?= $(abspath $(dir $(CMOC_BIN))../share/cmoc/lib)
GRAPHICS_TEST_DIR = ../graphictest

%: %.c
	$(CC) $(LFLAGS) $^ $(OBJS) -L../lib -lc -L../cgfx -lcgfx

hello: hello.c
	$(CC) -I../include -I../cgfx/include --os9 -nodefaultlibs --add-os9-stack-space=512 \
		$^ $(OBJS) -L../lib -lc -L../cgfx -lcgfx

maze: $(GRAPHICS_TEST_DIR)/maze.c
	$(CC) -I../include -I../cgfx/include --os9 -nodefaultlibs --add-os9-stack-space=5518 \
		$^ $(OBJS) -L../lib -lc -L../cgfx -lcgfx

wintest: $(GRAPHICS_TEST_DIR)/wintest.c
	$(CC) $(LFLAGS) $^ $(OBJS) -L../lib -lc -L../cgfx -lcgfx

floattest: floattest.c
	$(CC) -I../include -I../cgfx/include --os9 --mc6839 -nodefaultlibs \
		$^ $(OBJS) -L../lib -lcf -L../cgfx -lcgfx \
		-L$(CMOC_FLOAT_LIB_DIR) -lcmoc-float-mc6839_os9 -L../lib -lcf

floatfmttest: floatfmttest.c
	$(CC) -I../include -I../cgfx/include --os9 --mc6839 -nodefaultlibs \
		$^ $(OBJS) -L../lib -lcf -L../cgfx -lcgfx \
		-L$(CMOC_FLOAT_LIB_DIR) -lcmoc-float-mc6839_os9 -L../lib -lcf


GRAPHICS_TESTS = wintest maze
TESTS	= hello noop timetest fiotest iotest osiotest osopenerrtest syscalltest memtest forktest forkhellotest forknowaittest forknooptest printtest osgstattest utimetest ctype string floattest floatfmttest getopttest popentest pwenttest defdrivetest pwcryptest errmsgtest stdlibtest streamiotest searchtest stringexttest filelayout setjmptest systemtest setstest dirtest compat3test signaltest intercepttest dirapitest misctest datmodstest attrwraptest abortchild aborttest
ALL_TESTS = $(TESTS) $(GRAPHICS_TESTS)

all:	$(ALL_TESTS)

dsk:	all
	os9 format -e -q -ds -dd -t80 test.dsk
	os9 makdir test.dsk,CMDS
	os9 copy $(ALL_TESTS) test.dsk,CMDS
	$(foreach file, $(ALL_TESTS), os9 attr -q -epe test.dsk,CMDS/$(file);)
	echo "chx /d1/cmds; chd /d1" > go
	$(foreach file, $(TESTS), echo $(file) >> go;)
	os9 copy -l go test.dsk,


run:	dsk
	mame64 -inipath ~/Documents/mame -video opengl -window coco3 -flop1 nos9.dsk -flop2 test.dsk -speed 4 &

clean:
	-rm $(ALL_TESTS) test.dsk go
