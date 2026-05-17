#ifndef _DEBUG_H
#define _DEBUG_H

/**
 * @file debug.h
 * @brief Interactive debugging helpers and emulator break support.
 */

/**
 * @brief Print a pause prompt and wait for Enter.
 */
void PAUSE(void);

/**
 * @brief Print a long value in hexadecimal form.
 *
 * @param value Value to display.
 */
void LPX(long);

/**
 * @brief Print useful CPU register state and wait for Enter.
 */
void DEBUG(void);

/**
 * @brief Dump a block of memory with a banner string.
 *
 * @param string Banner text.
 * @param addr First byte to dump.
 * @param count Number of bytes to show.
 */
void _dump(char *string, char *addr, int count);

/*
BREAK is a pseudo opcode in Mame that causes it to stop the running
emulation and bring up the Mame debugger.  It requires a patch to Mame.  If
mame is unpatched it will be considered an invalid instruction:

Patch for recent versions of Mame:
http://www.ocs.net/~n6il/mame/

The patch is derived from:
https://github.com/milliluk/mame
*/
/** @brief Emit the MAME BREAK pseudo-op when supported by the emulator. */
#define BREAK asm{ fdb $113e }

#endif
