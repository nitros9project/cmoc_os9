# Makefile to create assembler library
#include $(NITROS9DIR)/rules.mak

MODS = window.o cbuffer.o draw.o config.o text.o keysense.o sound.o mouse.o mousexy.o getput.o mv_window.o status.o movemem.o font.o shadow.o crw.o drawfunc.o play.o sinecosine.o polyline.o polyfunc.o polyfill.o mousekey.o settype.o button.o radio.o alarm.o menu.o menuxy.o mvmenu.o mvmenuxy.o getstr.o dialog.o object.o fname.o mvfname.o tandy.o
CC = cmoc
ASM = lwasm
CMOC_CPP = --cpp="cpp -Wno-builtin-macro-redefined"
CFLAGS = $(CMOC_CPP) --os9 -I../include -I./include
ASOUT = --obj -o

%.o: %.as
	$(ASM) $(AFLAGS) $< $(ASOUT)$@

all:	libcgfx.a

libcgfx.a: $(MODS)
	lwar -c $@ $(MODS)

dskclean: clean

clean:
	$(RM) *.o *.list *.map libcgfx.a
