CMOC_OS9_RECIPE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

RECIPE = coco3_cmoc_os9
TERM_COLS = 80
STARTUP = $(CMOC_OS9_RECIPE_DIR)startup
CMOC_OS9_TESTSCRIPT = $(CMOC_OS9_RECIPE_DIR)test
OS9FORMAT_CMD = $(OS9FORMAT_DS40)
RBF = rbf.mn rb1773.dr ddd0_40d.dd
SCF = scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb $(TERM_IO) $(TERM_WIN_DT)
PIPE = pipeman.mn piper.dr pipe.dd
BOOTMODS = krnp2 ioman init $(RBF) $(SCF) $(PIPE) $(CLOCK)
CMDS_BASE = shell grfdrv utilpak1 dump free
CMOC_OS9_TESTS = hello noop timetest fiotest iotest osiotest osopenerrtest syscalltest memtest wintest forktest forkhellotest forknowaittest forknooptest printtest maze utimetest ctype string floattest floatfmttest getopttest popentest pwenttest defdrivetest pwcryptest errmsgtest stdlibtest streamiotest searchtest stringexttest filelayout setjmptest systemtest setstest dirtest compat3test signaltest intercepttest dirapitest misctest datmodstest attrwraptest abortchild aborttest
CMDS_EXTRA += $(CMOC_OS9_TESTS)
