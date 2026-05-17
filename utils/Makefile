CC = cmoc
OS9FLAGS = --os9 -nodefaultlibs
LFLAGS = -I../include -I../cgfx/include $(OS9FLAGS)

%: %.c
	$(CC) $(LFLAGS) $^ -L../lib -lc -L../cgfx -lcgfx

UTILS = wc cat head cmp tr cut

all: $(UTILS)

clean:
	-rm -f $(UTILS)
