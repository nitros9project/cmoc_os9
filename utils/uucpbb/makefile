RM	= rm -f
CP	= cp
CD	= cd
ECHO	= echo
CMOC	= cmoc
CMOC_OS9_DIR ?= /Users/boisy/Projects/coco-shelf/cmoc_os9
CPP	= cpp -Wno-builtin-macro-redefined
CMOCFLAGS = --cpp="$(CPP)" --os9 -I$(CMOC_OS9_DIR)/include -I$(CMOC_SRCDIR) \
	-DOS9 -DSHELLPLUS -DNEWCLIB -D_VOID_ -DCMOC_KR_COMPAT -DUSE_C_G_CHKSUM \
	-Waccept-word-sized-return-type-mismatch -Wno-const
CMOC_BASELIB = $(CMOC_OS9_DIR)/lib/libc.a
CMOCLIB = $(CMOC_OUTDIR)/libc-uucpbb.a
SRCDIR	= src
BUILDDIR = build
CMOC_OUTDIR = $(BUILDDIR)
CMOC_SRCDIR = $(BUILDDIR)/src

DISK68	= uucpbb21_6809.dsk
DISK63	= uucpbb21_6309.dsk
CONFIG	= Devices FileServ.help Systems bin.list Dialers Parameters active distributions
DOCS	= adduser.man aliases.doc chown.man cnvrtmail.man fileserv.man fixtext.man login.man mailrc.doc mailx.man parameters.doc postnews.man profile.doc readnews.man rmail.man rnews.man signature.doc subscribe.man uucico.man uuclean.man uucp.man uucpbb.doc uulog.man uuxqt.man whoami.man

DSKS	= $(DISK68) $(DISK63)

SRC_CMDS = uucico mailx dotilde rmail rnews uuxqt readnews postnews expire \
	subscribe unsubscribe uulog uuclean uuencode uudecode uucp chown \
	whoami fixtext adduser fileserv uuname login cnvrtmail
CMOC_TARGETS = $(addprefix $(CMOC_OUTDIR)/,$(SRC_CMDS))
CMOC_OBJECTS = $(sort $(foreach cmd,$(SRC_CMDS),$(addprefix $(CMOC_OUTDIR)/,$($(cmd)_OBJS))))
CMOC_INTDIR = $(CMOC_OUTDIR)/int
CMOC_NEEDS_PWENT = rnews uuxqt expire uulog fileserv

uucico_OBJS = uucico.o getopt.o getparam.o findmach.o chksched.o findline.o \
	findent.o finddev.o connect.o openport.o openuucp.o findwork.o \
	filexfer.o gproto.o dumpcode.o filemove.o fixperms.o closeuucp.o \
	parse.o docmd.o gtime.o mfgets.o strdetab.o getenv.o strdup.o \
	getdirs.o strstr.o pwent.o
mailx_OBJS = mail.o recvmail.o sendmail.o getuser.o docmd.o parse.o fixline.o \
	filemove.o maketemp.o getseq.o getval.o fixperms.o getparam.o \
	userparam.o t2test.o date822.o gtime.o doalias.o forkshell.o \
	strdup.o mfgets.o strdetab.o getenv.o termio.o nmload.o getdirs.o \
	pwent.o
dotilde_OBJS = dotilde.o docmd.o fixline.o parse.o forkshell.o getenv.o \
	mfgets.o strdetab.o strdup.o gtime.o filemove.o termio.o pwent.o
rmail_OBJS = rmail.o getline.o getuser.o validuser.o setuser.o parse.o \
	genseq.o findent.o getparam.o getval.o maketemp.o gtime.o fixperms.o \
	date822.o filemove.o doalias.o mfgets.o getenv.o strdup.o getdirs.o \
	termio.o docmd.o pwent.o
rnews_OBJS = rnews.o getline.o groups.o procbatch.o mbuf.o xatol.o getdirs.o \
	getparam.o parse.o strdup.o mfgets.o openarts.o makepath.o strupr.o \
	procart.o getopt.o fixref.o gtime.o log.o getenv.o
uuxqt_OBJS = uuxqt.o findxwork.o getline.o parse.o docmd.o gtime.o filemove.o \
	mfgets.o getopt.o strdetab.o strdup.o getdirs.o strupr.o nmload.o \
	getenv.o
readnews_OBJS = readnews.o getuser.o makepath.o parse.o filemove.o fixline.o \
	docmd.o newsutils.o getval.o getparam.o userparam.o gtime.o t2test.o \
	forkshell.o mfgets.o strupr.o strdetab.o getenv.o strdup.o getdirs.o \
	termio.o pwent.o
postnews_OBJS = postnews.o getuser.o maketemp.o getseq.o findent.o getsys.o \
	docmd.o fixline.o filemove.o genseq.o getparam.o userparam.o parse.o \
	t2test.o fixperms.o gtime.o date822.o mfgets.o strdetab.o getenv.o \
	strdup.o getdirs.o getopt.o termio.o nmload.o pwent.o
expire_OBJS = expire.o expgroup.o makepath.o parse.o newsutils.o gtime.o \
	filemove.o strupr.o mfgets.o strdetab.o strdup.o getdirs.o getopt.o \
	getenv.o
subscribe_OBJS = subscribe.o filemove.o mfgets.o getenv.o pwent.o strdup.o
unsubscribe_OBJS = unsubscribe.o filemove.o mfgets.o getenv.o pwent.o strdup.o
uulog_OBJS = uulog.o getopt.o getenv.o strdup.o mfgets.o
uuclean_OBJS = uuclean.o getparam.o parse.o docmd.o maketemp.o mfgets.o \
	gtime.o filemove.o date822.o setuser.o getval.o getenv.o strdup.o \
	getdirs.o getopt.o pwent.o
uucp_OBJS = uucp.o getuser.o getparam.o parse.o genseq.o fixperms.o maketemp.o \
	docmd.o mfgets.o gtime.o getenv.o strdup.o getdirs.o pwent.o
uudecode_OBJS = uudecode.o
uuencode_OBJS = uuencode.o
chown_OBJS = chown.o pwent.o
whoami_OBJS = whoami.o pwent.o
fixtext_OBJS = fixtext.o fixline.o strdetab.o mfgets.o
adduser_OBJS = adduser.o strdetab.o getenv.o strdup.o termio.o mfgets.o pwent.o
fileserv_OBJS = fileserv.o getparam.o getdirs.o strdup.o mfgets.o getval.o \
	maketemp.o filemove.o docmd.o gtime.o date822.o getseq.o fixperms.o \
	parse.o getenv.o
uuname_OBJS = uuname.o parse.o mfgets.o
login_OBJS = login.o parse.o fixperms.o pwent.o getenv.o strdup.o
cnvrtmail_OBJS = cnvrtmail.o docmd.o fixperms.o gtime.o strupr.o getval.o \
	mfgets.o filemove.o getenv.o parse.o pwent.o strdup.o

.PHONY: all cmoc-all sizes banner clean dsk dskcopy dskclean info help

# Build all UUCPbb commands (default target)
all: cmoc-all

# Build the cmoc-compiled UUCPbb commands
cmoc-all: $(CMOC_TARGETS)

# Print the size in bytes of each built UUCPbb command
sizes: cmoc-all
	@printf "%-16s %10s\n" "command" "cmoc"
	@for cmd in $(SRC_CMDS); do \
		printf "%-16s %10s\n" "$$cmd" \
			"`wc -c < $(CMOC_OUTDIR)/$$cmd`"; \
	done

# Print the UUCPbb banner
banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*                   UUCPbb v2.1                  *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

# Remove the build directory, disk images, and intermediate artifacts
clean:	dskclean
	$(RM) -r $(BUILDDIR)
	$(RM) c.errors *.list *.map cstr.* ctmp.*

# Build the 6809 and 6309 UUCPbb disk images
dsk: $(DSKS)

$(DISK68): banner all
	$(RM) $@
	$(OS9FORMAT) -l10000 $@ -q -n"UUCPbb v2.1 6809"
	$(MAKDIR) $@,LOG
	$(MAKDIR) $@,UUCP
	$(MAKDIR) $@,UUCP/CMDS_WIN
	$(MAKDIR) $@,UUCP/CMDS_TCAP
	$(MAKDIR) $@,UUCP/DOC
	$(MAKDIR) $@,UUCP/SPOOL
	$(MAKDIR) $@,UUCP/SPOOL/MAIL
	$(MAKDIR) $@,UUCP/SPOOL/NEWS
	$(MAKDIR) $@,UUCP/SPOOL/UUCP
	$(MAKDIR) $@,UUCP/SPOOL/UUCP/REDHAT
	$(MAKDIR) $@,UUCP/SPOOL/UUCPPUBLIC
	$(MAKDIR) $@,UUCP/SPOOL/REDHAT
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,SYS/UUCP
	$(CD) sample_config; $(CPL) $(CONFIG) ../$@,SYS/UUCP
	$(CPL) profile $@,SYS
	$(CD) $(CMOC_OUTDIR); $(OS9COPY) $(SRC_CMDS) ../$@,UUCP/CMDS_TCAP
	$(OS9ATTR_EXEC) $(foreach file,$(SRC_CMDS),$@,UUCP/CMDS_TCAP/$(file))
	$(CD) $(CMOC_OUTDIR); $(OS9COPY) $(SRC_CMDS) ../$@,UUCP/CMDS_WIN
	$(OS9ATTR_EXEC) $(foreach file,$(SRC_CMDS),$@,UUCP/CMDS_WIN/$(file))
	$(CD) doc; $(CPL) $(DOCS) ../$@,UUCP/DOC
	$(CPL) copying readme.first $@,UUCP

$(DISK63): banner all
	$(RM) $@
	$(OS9FORMAT) -l10000 $@ -q -n"UUCPbb v2.1 6309"
	$(MAKDIR) $@,LOG
	$(MAKDIR) $@,UUCP
	$(MAKDIR) $@,UUCP/DOC
	$(MAKDIR) $@,UUCP/CMDS_WIN
	$(MAKDIR) $@,UUCP/CMDS_TCAP
	$(MAKDIR) $@,UUCP/SPOOL
	$(MAKDIR) $@,UUCP/SPOOL/MAIL
	$(MAKDIR) $@,UUCP/SPOOL/NEWS
	$(MAKDIR) $@,UUCP/SPOOL/UUCP
	$(MAKDIR) $@,UUCP/SPOOL/UUCP/REDHAT
	$(MAKDIR) $@,UUCP/SPOOL/UUCPPUBLIC
	$(MAKDIR) $@,UUCP/SPOOL/REDHAT
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,SYS/UUCP
	$(CD) sample_config; $(CPL) $(CONFIG) ../$@,SYS/UUCP
	$(CPL) profile $@,SYS
	$(CD) $(CMOC_OUTDIR); $(OS9COPY) $(SRC_CMDS) ../$@,UUCP/CMDS_TCAP
	$(OS9ATTR_EXEC) $(foreach file,$(SRC_CMDS),$@,UUCP/CMDS_TCAP/$(file))
	$(CD) $(CMOC_OUTDIR); $(OS9COPY) $(SRC_CMDS) ../$@,UUCP/CMDS_WIN
	$(OS9ATTR_EXEC) $(foreach file,$(SRC_CMDS),$@,UUCP/CMDS_WIN/$(file))
	$(CD) doc; $(CPL) $(DOCS) ../$@,UUCP/DOC
	$(CPL) copying readme.first $@,UUCP

# Copy built disk images to $(DSKDIR)
dskcopy: dsk
	$(CP) $(DSKS) $(DSKDIR)

# Remove the built disk images
dskclean:
	$(RM) $(DSKS)

# Display the UUCPbb version and the disk image names
info:
	@$(ECHO) "*** UUCPbb 2.1 ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)

# Display this help message listing available phony targets
help:
	@echo "Available targets:"
	@awk 'BEGIN{c=""} /^# /{c=substr($$0,3); next} /^[a-zA-Z_][a-zA-Z0-9_.-]*:/{if(c!=""){t=$$1; sub(/:.*/,"",t); printf "  %-20s %s\n", t, c}; c=""; next} {c=""}' $(MAKEFILE_LIST)

.SECONDEXPANSION:
$(CMOC_OUTDIR):
	mkdir -p $@

$(CMOC_SRCDIR)/.prepared: | $(CMOC_OUTDIR)
	$(RM) -r $(CMOC_SRCDIR)
	mkdir -p $(CMOC_SRCDIR)
	cp $(SRCDIR)/*.[ch] $(CMOC_SRCDIR)
	perl -pi -e 's/#define QQ[ \t]+direct/#define QQ/' $(CMOC_SRCDIR)/*.h
	perl -pi -e 's/\binterrupt\b/uucpbb_interrupt/g' $(CMOC_SRCDIR)/*.[ch]
	perl -pi -e 's/, uucpbb_interrupt\(\)//g; s/uucpbb_interrupt\(\), //g' $(CMOC_SRCDIR)/*.[ch]
	perl -pi -e 's/intercept \(([^)]*uucpbb_interrupt[^)]*)\)/intercept ((sighandler_t) $$1)/g' $(CMOC_SRCDIR)/*.[ch]
	perl -0pi -e 's/\n[ \t]+void dowork\(\);\n/\n/' $(CMOC_SRCDIR)/findwork.c
	perl -pi -e 's/char seq\[5\], nextseq\(\);/char seq[5];/' $(CMOC_SRCDIR)/genseq.c
	perl -pi -e 's/unsigned ouid, setnuid\(\);/unsigned ouid;/' $(CMOC_SRCDIR)/getenv.c
	perl -0pi -e 's/\n[ \t]+char \*lookformatch\(\);\n/\n/' $(CMOC_SRCDIR)/getenv.c
	perl -pi -e 's/int option, uucpbb_interrupt\(\);/int option;/' $(CMOC_SRCDIR)/uuxqt.c
	perl -pi -e 's/fprintf \("...error #%d", errno\);/fprintf (log, "...error #%d", errno);/' $(CMOC_SRCDIR)/uuxqt.c
	perl -pi -e 's/\brtime\b/uucpbb_rtime/g; s/uucpbb_rtime \(num_days, def_date\);/uucpbb_rtime (num_days, (struct os_time *)def_date);/; s/time \(\(char \*\)0\)/time ((long *)0)/' $(CMOC_SRCDIR)/uuclean.c
	perl -pi -e 's/FILE \*msg, \*creat_temp\(\);/FILE *msg;/; s/acceptfile \(address, words\[1\], lp\);/acceptfile (address, words[1]);/; s/writeheader \(msg, errorsto, "WARNING--possible misuse of fileserver"\);/writeheader (msg, errorsto, "WARNING--possible misuse of fileserver", FALSE);/; s/writeheader \(msg, sender, "WARNING--attempt to submit a file"\);/writeheader (msg, sender, "WARNING--attempt to submit a file", FALSE);/' $(CMOC_SRCDIR)/fileserv.c
	perl -0pi -e '$$s=$$_; $$p=index($$s, "switch (n = getargs (words, buff, WORDSIZE))"); $$e=index($$s, "          firstcmd = FALSE;", $$p); if ($$p >= 0 && $$e >= 0) { $$b=substr($$s, $$p, $$e - $$p); $$b =~ s/\bcontinue;/goto cmoc_fileserv_next;/g; substr($$s, $$p, $$e - $$p) = $$b; $$s =~ s/(          firstcmd = FALSE;\n)/$$1cmoc_fileserv_next: ;\n/; } $$_=$$s' $(CMOC_SRCDIR)/fileserv.c
	perl -pi -e 's/\bflag\b/newsflag/g' $(CMOC_SRCDIR)/subscribe.c
	perl -pi -e 's/\bflag\b/newsflag/g' $(CMOC_SRCDIR)/unsubscribe.c
	perl -0pi -e 's/char \*curtime\[20\],\n[ \t]+\*p = &os9_time,\n[ \t]+\*words\[3\],/char curtime[20];\n     struct os_time *p = \&os9_time;\n     char *words[3],/' $(CMOC_SRCDIR)/login.c
	perl -pi -e 's/o2utime \(&date\)/o2utime ((struct os_time *)\&date)/; s/fprintf \("can'\''t open mail '\''%s'\'' for reading\\n", oldfilename\);/fprintf (stderr, "can'\''t open mail '\''%s'\'' for reading\\n", oldfilename);/' $(CMOC_SRCDIR)/cnvrtmail.c
	perl -pi -e 's/, \*grabfrom\(\)//' $(CMOC_SRCDIR)/mail.c
	perl -pi -e 's/\\l/\\x0d/g' $(CMOC_SRCDIR)/openarts.c
	perl -0pi -e 's/continue;\n\n([ \t]+case)/goto cmoc_mail_next;\n\n$$1/' $(CMOC_SRCDIR)/mail.c
	perl -0pi -e 's/(\n[ \t]+fprintf \(mtptr, "%s\\n", p\);\n)([ \t]+})/$$1cmoc_mail_next: ;\n$$2/' $(CMOC_SRCDIR)/mail.c
	perl -pi -e 's/r = \(length > BIGBUF\) \? BIGBUF : length;/if (length > BIGBUF) r = BIGBUF; else r = (int) length;/' $(CMOC_SRCDIR)/procbatch.c
	perl -0pi -e 's/\n[ \t]+struct mailbag \*whatnow\(\), \*reverselist\(\), \*gathermail\(\);\n/\n/' $(CMOC_SRCDIR)/recvmail.c
	perl -0pi -e '$$s=$$_; $$s =~ s/\G(.*?int mailcmd \(letter\).*?\n[ \t]+switch \(c\)\n[ \t]+\{)(.*?)(\n[ \t]+\}\n[ \t]+\}\n\})/$$h=$$1; $$b=$$2; $$t=$$3; $$b =~ s|continue;|goto cmoc_recvmail_next;|g; $$h.$$b."\ncmoc_recvmail_next: ;".$$t/se; $$_=$$s' $(CMOC_SRCDIR)/recvmail.c
	perl -pi -e 's/int count, index, j, c, uucpbb_interrupt\(\);/int count, index, j, c;/' $(CMOC_SRCDIR)/readnews.c
	perl -0pi -e 's/\n[ \t]+char dspnews\(\);\n/\n/' $(CMOC_SRCDIR)/readnews.c
	perl -pi -e 's/freearticlepath\(\);/freearticlepath(NULL);/' $(CMOC_SRCDIR)/readnews.c
	perl -0pi -e 's/continue;\n([ \t]+}\n[ \t]+}\n\n[ \t]+\/\* save article with header)/goto cmoc_readnews_next;\n$$1/; s/(\n[ \t]+c = '\''\\0'\'';[^\n]*\n)([ \t]+}\n\})/$$1cmoc_readnews_next: ;\n$$2/' $(CMOC_SRCDIR)/readnews.c
	perl -0pi -e 's/\n[ \t]+int uucpbb_interrupt\(\);\n/\n/' $(CMOC_SRCDIR)/rmail.c
	perl -pi -e 's/long linecount, msgsize, movemail\(\);/long linecount, msgsize;/' $(CMOC_SRCDIR)/rmail.c
	perl -0pi -e 's/\n[ \t]+long movemail\(\);\n/\n/' $(CMOC_SRCDIR)/rmail.c
	perl -pi -e 's/char crlf, \*strpbrk\(\), \*grabfrom\(\);/char crlf;/' $(CMOC_SRCDIR)/rmail.c
	perl -pi -e 's/long linecount, forwardseq\(\);/long linecount;/' $(CMOC_SRCDIR)/rmail.c
	perl -pi -e 's/\? NULL :/\? (char *)0 :/' $(CMOC_SRCDIR)/mfgets.c
	perl -pi -e 's/: NULL/: (char *)0/' $(CMOC_SRCDIR)/dotilde.c
	touch $@

$(CMOCLIB): $(CMOC_BASELIB) | $(CMOC_OUTDIR)
	cd $(CMOC_OS9_DIR)/lib && lwar -c $(abspath $@) `lwar --list libc.a | awk -F: '{print $$1}' | grep -v -E 'obj_base/(getopt|pwent)\\.o'`

$(CMOC_TARGETS): $$(addprefix $$(CMOC_OUTDIR)/,$$($$(@F)_OBJS)) $(CMOCLIB)
	$(CMOC) --os9 -o $@ $(filter %.o,$^) -L$(CMOC_OUTDIR) -lc-uucpbb

$(addprefix $(CMOC_OUTDIR)/,$(CMOC_NEEDS_PWENT)): $(CMOC_OUTDIR)/pwent.o

$(CMOC_OBJECTS): $(CMOC_OUTDIR)/%.o: $(CMOC_SRCDIR)/.prepared | $(CMOC_OUTDIR)
	@mkdir -p $(CMOC_INTDIR)/$*
	$(CMOC) $(CMOCFLAGS) --intermediate --intdir=$(CMOC_INTDIR)/$* --compile -o $@ $(CMOC_SRCDIR)/$*.c || \
		{ test -f $(CMOC_INTDIR)/$*/$*.s && \
		  perl -pe 's/^(\s*)B(EQ|NE|HI|LS|CC|HS|CS|LO|VC|VS|PL|MI|GE|LT|GT|LE)\b/$${1}LB$$2/' \
			$(CMOC_INTDIR)/$*/$*.s > $(CMOC_INTDIR)/$*/$*.long.s && \
		  lwasm -fobj --pragma=forwardrefmax -DOS9 --output=$@ $(CMOC_INTDIR)/$*/$*.long.s; }
