CC = cmoc
CMOC_CPP = --cpp="cpp -Wno-builtin-macro-redefined"
OS9FLAGS = --os9 -nodefaultlibs
LFLAGS = $(CMOC_CPP) -I../include -I../cgfx/include $(OS9FLAGS)
SUBDIRS = uemacs ed

%: %.c
	$(CC) $(LFLAGS) $^ -L../lib -lc -L../cgfx -lcgfx

UTILS = wc cat head cmp tr cut echo sleep tee rev strings cksum uniq comm split paste seq basename dirname true false yes tail sync tty mkdir rmdir cal fold nl expand unexpand od sort touch uuencode uudecode

.PHONY: all clean help $(SUBDIRS)

# Build all utility binaries and subdirectory utils (default target)
all: $(UTILS) $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

# Remove built utility binaries and clean each subdirectory
clean:
	-rm -f $(UTILS)
	-rm -f *.s.list *.s.map
	$(foreach dir,$(SUBDIRS),$(MAKE) -C $(dir) clean;)

# Display this help message listing available phony targets
help:
	@echo "Available targets:"
	@awk 'BEGIN{c=""} /^# /{c=substr($$0,3); next} /^[a-zA-Z_][a-zA-Z0-9_.-]*:/{if(c!=""){t=$$1; sub(/:.*/,"",t); printf "  %-20s %s\n", t, c}; c=""; next} {c=""}' $(MAKEFILE_LIST)
