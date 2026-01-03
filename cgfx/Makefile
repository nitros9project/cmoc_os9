# Makefile to create assembler library
#include $(NITROS9DIR)/rules.mak

MODS = window.o cbuffer.o draw.o config.o text.o keysense.o sound.o mouse.o mousexy.o getput.o mv_window.o status.o gtext.o keyboard.o opt.o
CC = cmoc
ASM = lwasm
CFLAGS = --os9 -I../include -I./include
ASOUT = --obj -o

%.o: %.as
	$(ASM) $(AFLAGS) $< $(ASOUT)$@

all:	libcgfx.a

libcgfx.a: $(MODS)
	lwar -c $@ $(MODS)

dskclean: clean

clean:
	$(RM) *.o libcgfx.a
