CMOC_OS9_RECIPE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

RECIPE = coco3_cmoc_os9
TERM_COLS = 80
STARTUP = $(CMOC_OS9_RECIPE_DIR)startup
CMOC_OS9_TESTSCRIPT = $(CMOC_OS9_RECIPE_DIR)test
OS9FORMAT_CMD = $(OS9FORMAT_DS80)
AFLAGS_EXTRA += -DINIT_KEYRPTSTART=0 -DINIT_KEYRPTDELAY=0
RBF = rbf.mn rb1773.dr ddd0_80d.dd
SCF = scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb $(TERM_IO) $(TERM_WIN_DT) \
	w.dw w1.dw w2.dw w3.dw w4.dw w5.dw w6.dw w7.dw
PIPE = pipeman.mn piper.dr pipe.dd
BOOTMODS = krnp2 ioman init $(RBF) $(SCF) $(PIPE) $(CLOCK)
CMDS_BASE = shell grfdrv utilpak1 dump free ident
CMOC_OS9_GRAPHICS_TESTS = wintest maze
CMOC_OS9_UTILITIES = wc cat head cmp tr cut
CMOC_OS9_TESTS = hello noop timetest fiotest iotest osiotest osopenerrtest syscalltest memtest forktest forkhellotest forknowaittest forknooptest printtest osgstattest utimetest ctypetest stringtest floattest floatfmttest getopttest popentest pwenttest defdrivetest pwcryptest errmsgtest stdlibtest setbuftest stdioedgetest streamiotest searchtest stringexttest randtest filelayout setjmptest systemtest setstest dirtest compat3test signaltest intercepttest dirapitest misctest datmodstest attrwraptest abortchild aborttest
CMOC_OS9_ALL_TESTS = $(CMOC_OS9_TESTS) $(CMOC_OS9_GRAPHICS_TESTS)
CMDS_EXTRA += $(CMOC_OS9_ALL_TESTS) $(CMOC_OS9_UTILITIES)
