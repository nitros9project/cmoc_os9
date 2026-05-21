CC = cmoc
OS9FLAGS = --os9 -nodefaultlibs
LFLAGS = -I../include -I../cgfx/include $(OS9FLAGS)

%: %.c
	$(CC) $(LFLAGS) $^ -L../lib -lc -L../cgfx -lcgfx

UTILS = wc cat head cmp tr cut echo sleep tee rev strings cksum uniq comm split paste seq basename dirname true false yes tail sync tty mkdir rmdir

all: $(UTILS)

clean:
	-rm -f $(UTILS)
