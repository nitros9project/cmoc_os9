CMOC_OS9_RECIPE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

RECIPE = coco3_cmoc_os9
TERM_COLS = 80
STARTUP = $(CMOC_OS9_RECIPE_DIR)startup
CMOC_OS9_TESTSCRIPT = $(CMOC_OS9_RECIPE_DIR)test
OS9FORMAT_CMD = $(OS9FORMAT_DS80)
RBF = rbf.mn rb1773.dr ddd0_80d.dd d1_40d.dd
SCF = scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb $(TERM_IO) $(TERM_WIN_DT) \
	w.dw w1.dw w2.dw w3.dw w4.dw w5.dw w6.dw w7.dw
PIPE = pipeman.mn piper.dr pipe.dd
BOOTMODS = krnp2 ioman init $(RBF) $(SCF) $(PIPE) $(CLOCK)
CMDS_BASE = shell grfdrv utilpak1 dump free ident
CMOC_OS9_GRAPHICS_TESTS = wintest maze text40 text40edit gfx80 gfx80draw gfx40draw
CMOC_OS9_UTILITIES = wc cat head cmp tr cut echo sleep tee rev strings cksum uniq comm split paste seq basename dirname true false yes tail sync tty mkdir rmdir
CMOC_OS9_PACKAGES = umacs
CMOC_OS9_TESTS = hello noop timetest fiotest iotest osiotest osopenerrtest syscalltest fdstreamtest memtest forktest forkhellotest forknowaittest forknooptest printtest osgstattest utimetest ctypetest stringtest floattest floatfmttest getopttest gtest popentest pwenttest defdrivetest pwcryptest errmsgtest stdlibtest setbuftest stdioedgetest streamiotest searchtest stringexttest randtest longtest lmultest intmathtest filelayout setjmptest systemtest setstest dirtest compat3test signaltest skiptest sleeptest intercepttest dirapitest misctest datmodstest attrwraptest abortchild aborttest structcopytest
CMOC_OS9_ALL_TESTS = $(CMOC_OS9_TESTS) $(CMOC_OS9_GRAPHICS_TESTS)
CMDS_EXTRA += $(CMOC_OS9_ALL_TESTS) $(CMOC_OS9_UTILITIES) $(CMOC_OS9_PACKAGES) pmap
