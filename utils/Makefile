CC = cmoc
OS9FLAGS = --os9 -nodefaultlibs
LFLAGS = -I../include -I../cgfx/include $(OS9FLAGS)
SUBDIRS = uemacs

%: %.c
	$(CC) $(LFLAGS) $^ -L../lib -lc -L../cgfx -lcgfx

UTILS = wc cat head cmp tr cut echo sleep tee rev strings cksum uniq comm split paste seq basename dirname true false yes tail sync tty mkdir rmdir

.PHONY: all clean $(SUBDIRS)

all: $(UTILS) $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

clean:
	-rm -f $(UTILS)
	-rm -f *.s.list *.s.map
	$(foreach dir,$(SUBDIRS),$(MAKE) -C $(dir) clean;)
