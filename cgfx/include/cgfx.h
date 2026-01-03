
#ifndef _CGFX_H
#define _CGFX_H

#include <fcntl.h>

/**** TEXT FUNCTIONS ****/

/**
 * @brief Home the text cursor.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_curhome(path_id path);

/**
 * @brief Turn on the text cursor.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_curon(path_id path);

/**
 * @brief Turn off the text cursor.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_curoff(path_id path);

/**
 * @brief Move the text cursor left.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_curlft(path_id path);

/**
 * @brief Move the text cursor right.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_currght(path_id path);

/**
 * @brief Move the text cursor up.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_curup(path_id path);

/**
 * @brief Move the text cursor down.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_curdwn(path_id path);

/**
 * @brief Erase the line the text cursor is on.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_erline(path_id path);

/**
 * @brief Erase from the text cursor to the end of the line.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ereoline(path_id path);

/**
 * @brief Erase from the text cursor to the end of the screen.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ereoscrn(path_id path);

/**
 * @brief Clear the screen and home the text cursor.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_clear(path_id path);

/**
 * @brief Play the system bell sound.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_bell(path_id path);

/**
 * @brief Write a carriage return.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_crrtn(path_id path);

/**
 * @brief Turn on reverse text highlighting.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_revon(path_id path);

/**
 * @brief Turn off reverse text highlighting.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_revoff(path_id path);

/**
 * @brief Turn on text underlining.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_undlnon(path_id path);

/**
 * @brief Turn off text underlining.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_undlnoff(path_id path);

/**
 * @brief Turn on text blinking.
 *
 * Blinking only works on type 1 or 2 screens. Graphic screens do not support blinking.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_blnkon(path_id path);

/**
 * @brief Turn off text blinking.
 *
 * Blinking only works on type 1 or 2 screens. Graphic screens do not support blinking.
  *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_blnkoff(path_id path);

/**
 * @brief Insert a blank line at the text cursor's line.
 *
 * Lines below the current one are moved downard.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_insline(path_id path);

/**
 * @brief Delete the contents of the line at the text cursor's line.
 *
 * Lines below the deleted line are moved up. The last line on the screen is blanked.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_delline(path_id path);

/**
 * @brief Position the text cursor at the X and Y coordinates on the screen.
 *
 * @param path_id The path to the window device.
 * @param x The X coordinate to position the text cursor.
 * @param y The Y coordinate to position the text cursor.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_curxy(path_id path, int x, int y);


/**** BUFFER FUNCTIONS ****/

/* buffer group numbers */
#define GRP_FONT 	200 /* Font group */
#define GRP_CLIP 	201 /* Clipboard group (usage not standardized) */
#define GRP_PTR 	202 /* Pointer group */
#define GRP_PAT2 	203 /* Two color patterns */
#define GRP_PAT4 	204 /* Four color patterns */
#define GRP_PAT6 	205 /* Sixteen color patterns */

/* font buffers */
#define FNT_S8X8 	1 /* Standard 8x8 font (default) */
#define FNT_S6X8 	2 /* Standard 6x8 font */
#define FNT_G8X8 	3 /* Standard graphics character font */

/* mouse pointer buffers */
#define PTR_ARR 	1 /* Arrow */
#define PTR_PEN 	2 /* Pencil */
#define PTR_LCH 	3 /* Large Cross Hairs */
#define PTR_SLP 	4 /* Hourglass (sleep) */
#define PTR_ILL 	5 /* Illegal (circle with a slash) */
#define PTR_TXT 	6 /* Text */
#define PTR_SCH 	7 /* Small Cross Hairs */

/* pattern buffers */
#define PAT_SLD 	0 /* Solid (default) */
#define PAT_DOT 	1 /* Dots */
#define PAT_VRT 	2 /* Vertical lines */
#define PAT_HRZ 	3 /* Horizontal lines */
#define PAT_XHTC 	4 /* Crosshatch */
#define PAT_LSNT 	5 /* Left slanted lines */
#define PAT_RSNT 	6 /* Right slanted lines */
#define PAT_SDOT	7 /* Small dots */
#define PAT_BDOT 	8 /* BIG dots */

/* logic modes */
#define LOG_NONE 	0 /* no logic - just put it there (default) */
#define LOG_AND 	1  /* AND the contents of the screen with the data */
#define LOG_OR 		2   /* OR the contents of the screen with the data */
#define LOG_XOR 	3  /* XOR the contents of the screen with the data */

/* special characters for font FNT_G8X8 */
#define CHR_RGT 	0xC1 /* right arrow */
#define CHR_LFT 	0xC2 /* left arrow */
#define CHR_DN 		0xC3  /* down arrow */
#define CHR_UP 		0xC4  /* up arrow */
#define CHR_TRI 	0xC5 /* triple bar (for title bar) */
#define CHR_RSZ 	0xC6 /* resize box (not used) */
#define CHR_CLZ 	0xC7 /* close box */
#define CHR_MOV 	0xC8 /* move box */
#define CHR_VBX 	0xC9 /* vertical box (for scroll markers) */
#define CHR_HBX 	0xCA /* horizontal box (for scroll markers) */
#define CHR_HRG 	0xCB /* hourglass (Tandy menu) */
#define CHR_TRR 	0xCC /* triple bar with open right side */
#define CHR_TRL 	0xCD /* triple bar with open left side */


/**
 * @brief Flush queued up drawing commands.
 */
void Flush(void);


/**
 * @brief Set the drawing pattern to be used.
 *
 * @param path_id The path to the window device.
 * @param grp The group number.
 * @param buf The buffer number.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_pset(path_id path, int grp, int buf);

/**
 * @brief Set the logic point for the window.
 *
 * @param path_id The path to the window device.
 * @param lfag The logic mode.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_lset(path_id path, int mode);

/**
 * @brief Restore the default palette settings for the window.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_defcolr(path_id path);

/**
 * @brief Set the palette register to a color number.
 *
 * @param path_id The path to the window device.
 * @param prn The palette register number (0 - 15).
 * @param colno The color number (least significant 6 bits: X-X-R-G-B-R-G-B).
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_palette(path_id path, int prn, int colno);

/**
 * @brief Set the foreground color to the palette register.
 *
 * @param path_id The path to the window device.
 * @param prn The palette register number (0 - 15).
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_fcolor(path_id path, int prn);

/**
 * @brief Set the background color to the palette register.
 *
 * @param path_id The path to the window device.
 * @param prn The palette register number (0 - 15).
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_bcolor(path_id path, int prn);

/**
 * @brief Set the border color to the palette register.
 *
 * @param path_id The path to the window device.
 * @param prn The palette register number (0 - 15).
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_border(path_id path, int brn);

/**
 * @brief Toggle the scale switch for the window.
 *
 * @param path_id The path to the window device.
 * @param bsw The binary switch (0/1).
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_scalesw(path_id path, int bsw);

/**
 * @brief Set the graphic cursor for the window.
 *
 * @param path_id The path to the window device.
 * @param grp The group number.
 * @param buf The buffer number.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_setgc(path_id path, int grp, int buf);


/**** WINDOW FUNCTIONS ****/

/**
 * @brief Set the window to a type, size, and color.
 *
 * @param path_id The path to the window device.
 * @param sty The window type.
 * @param cpx The upper left window X coordinate in characters.
 * @param cpy The upper left window Y coordinate in characters.
 * @param szx The window width in characters.
 * @param szy The window height in characters.
 * @param fprn The foreground palette register.
 * @param bprn The background palette register.
 * @param bdprn The border palette register.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_dwset(path_id path, int sty, int cpx, int cpy, int szx, int szy, int fprn, int bprn, int bdprn);

/**
 * @brief End the window.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_dwend(path_id path);

/**
 * @brief Toggle window creation ability.
 *
 * @param path_id The path to the window device.
 * @param bsw The binary swtich (0/1).
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_dwprotsw(path_id path, int bsw);

/**
 * @brief Create an overlay window with a type, size, and color.
 *
 * @param path_id The path to the window device.
 * @param svs The window creation flag.
 * @param cpx The upper left window X coordinate in characters.
 * @param cpy The upper left window Y coordinate in characters.
 * @param szx The window width in characters.
 * @param szy The window height in characters.
 * @param fprn The foreground palette register.
 * @param bprn The background palette register.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_owset(path_id path, int svs, int cpx, int cpy, int szx, int szy, int fprn, int bprn);

/**
 * @brief End a Multi-Vue type overlay window.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_mvowend(path_id path);

/**
 * @brief End an overlay window.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_owend(path_id path);

/**
 * @brief Select a window.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_select(path_id path);

/**
 * @brief Change the working area of a window.
 *
 * @param path_id The path to the window device.
 * @param cpx The new upper left window X coordinate in characters.
 * @param cpy The new upper left window Y coordinate in characters.
 * @param szx The new window width in characters.
 * @param szy The new window height in characters.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_cwarea(path_id path, int cpx, int cpy, int szx, int szy);


/**** DRAW FUNCTIONS ****/

/**
 * @brief Move the draw pointer.
 *
 * @param path_id The path to the window device.
 * @param x The X position of the draw pointer.
 * @param y The Y position of the draw pointer.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_setdptr(path_id path, int x, int y);

/**
 * @brief Move the draw pointer relative to the current position.
 *
 * @param path_id The path to the window device.
 * @param x The relative X position of the draw pointer.
 * @param y The relative Y position of the draw pointer.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_rsetdptr(path_id path, int xo, int yo);

/**
 * @brief Draw a point.
 *
 * @param path_id The path to the window device.
 * @param x The X position of the point.
 * @param y The Y position of the point.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_point(path_id path, int x, int y);

/**
 * @brief Draw a point relative to the current position.
 *
 * @param path_id The path to the window device.
 * @param xo The X offset from the draw pointer to the point.
 * @param yo The Y offset from the draw pointer to the point.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_rpoint(path_id path, int xo, int yo);

/**
 * @brief Draw a line.
 *
 * @param path_id The path to the window device.
 * @param x The destination X position of the line.
 * @param y The destination Y position of the line.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_line(path_id path, int x, int y);

/**
 * @brief Draw a line relative to the current position.
 *
 * @param path_id The path to the window device.
 * @param xo The relative destination X position of the line.
 * @param yo The relative destination Y position of the line.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_rline(path_id path, int xo, int yo);

/**
 * @brief Draw a line and move the draw position.
 *
 * @param path_id The path to the window device.
 * @param x The destination X position of the line.
 * @param y The destination Y position of the line.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_linem(path_id path, int x, int y);

/**
 * @brief Draw a line relative to the current position and move.
 *
 * @param path_id The path to the window device.
 * @param xo The relative destination X position of the line.
 * @param yo The relative destination Y position of the line.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_rlinem(path_id path, int xo, int yo);

/**
 * @brief Draw a box.
 *
 * @param path_id The path to the window device.
 * @param x The destination X position of the box.
 * @param y The destination Y position of the box.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_box(path_id path, int x, int y);

/**
 * @brief Draw a box relative to the draw position.
 *
 * @param path_id The path to the window device.
 * @param x The relative destination X position of the box.
 * @param y The relative destination Y position of the box.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_rbox(path_id path, int xo, int yo);

/**
 * @brief Draw a bar.
 *
 * @param path_id The path to the window device.
 * @param x The destination X position of the bar.
 * @param y The destination Y position of the bar.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_bar(path_id path, int x, int y);

/**
 * @brief Draw a bar relative to the draw position.
 *
 * @param path_id The path to the window device.
 * @param x The relative destination X position of the bar.
 * @param y The relative destination Y position of the bar.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_rbar(path_id path, int xo, int yo);

/**
 * @brief Fill a closed region.
 *
 * @param path_id The path to the window device.
 * @param x The X position to start the fill.
 * @param y The Y position to start the fill.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ffill(path_id path);

/**
 * @brief Draw a circle.
 *
 * @param path_id The path to the window device.
 * @param radius The radius of the circle.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_circle(path_id path, int radius);

/**
 * @brief Draw an ellipse.
 *
 * @param path_id The path to the window device.
 * @param xrad The radius of the X-axis.
 * @param yrad The radius of the Y-axis.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ellipse(path_id path, int xrad, int yrad);

/**
 * @brief Draw an arc.
 *
 * @param path_id The path to the window device.
 * @param xrad The radius of the X-axis.
 * @param yrad The radius of the Y-axis.
 * @param xo1 The first X offset.
 * @param xo2 The second X offset.
 * @param yo1 The first Y offset.
 * @param yo2 The second Y offset.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_arc(path_id path, int xrad, int yrad, int xo1, int yo1, int xo2, int yo2);

/**
 * @brief Places the graphic cursor at a specific position.
 *
 * This function is not compatible with the mouse in auto-follow mode.
 *
 * @param path_id The path to the window device.
 * @param x The X position of the graphic cursor.
 * @param y The Y position of the graphic cursor.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_putgc(path_id path, int x, int y);


/**** FONT FUNCTIONS ****/

/**
 * @brief Set the font.
 *
 * @param path_id The path to the window device.
 * @param grp The group number.
 * @param buf The buffer number.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_font(path_id path, int grp, int buf);

/**
 * @brief Set transparent character switch.
 *
 * @param path_id The path to the window device.
 * @param sw The switch value (0 = off, 1 = on).
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_tcharsw(path_id path, int sw);

/**
 * @brief Set bold character switch.
 *
 * @param path_id The path to the window device.
 * @param sw The switch value (0 = off, 1 = on).
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_boldsw(path_id path, int sw);

/**
 * @brief Set proportional width character switch.
 *
 * @param path_id The path to the window device.
 * @param sw The switch value (0 = off, 1 = on).
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_propsw(path_id path, int sw);


/* definitions for _os_gs_keysense() bits */
#define	_SS_KEYSENSE_SHIFT	(1<<0)
#define	_SS_KEYSENSE_CTRL	(1<<1)
#define	_SS_KEYSENSE_ALT	(1<<2)
#define	_SS_KEYSENSE_UP		(1<<3)
#define	_SS_KEYSENSE_DOWN	(1<<4)
#define	_SS_KEYSENSE_LEFT	(1<<5)
#define	_SS_KEYSENSE_RIGHT	(1<<6)
#define	_SS_KEYSENSE_SPACE	(1<<7)

/**
 * @brief Get the state of the modifier keys.
 *
 * @param path_id The path to the window device.
 * @param keys Address of the modifier key flags which contain the state upon return.
 * @return 0 if successful, otherwise the error code.
 */
error_code _os_gs_keysense(path_id path, int *keys);

/**
 * @brief Set the modifier keys to sense.
 *
 * @param path_id The path to the window device.
 * @param keys Flags indicating which keys to sense (0 = none).
 * @return 0 if successful, otherwise the error code.
 */
error_code _os_ss_keysense(path_id path, int keys);

/**
 * @brief Play a tone.
 *
 * @param path_id The path to the window device.
 * @param duration The duration of the tone in 1/60ths of a second.
 * @param volume The amplitude of the tone (0 = silence, 63 = maximum).
 * @param frequency The frequency of the tone (0 - 4095).
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ss_tone(path_id path, int duration, int volume, int frequency);



/**** MOUSE FUNCTIONS ****/

/* structure for reading mouse info packet */
typedef struct mousin {
 char pt_valid,  	/* is info valid? */
      pt_actv,   	/* active side */
      pt_totm,   	/* timeout initial value */
      pt_rsrv0[2],	/* reserved */
      pt_tto,    	/* time till timeout */
      pt_tsst[2],	/* time since start counter */
      pt_cbsa,   	/* current button state button A */
      pt_cbsb,   	/* current button state button B */
      pt_ccta,   	/* click count button A */
      pt_cctb,   	/* click count button B */
      pt_ttsa,   	/* time this state button A */
      pt_ttsb,   	/* time this state button B */
      pt_tlsa,   	/* time last state button A */
      pt_tlsb,   	/* time last state button B */
      pt_rsrv1[6],	/* reserved */
      pt_stat,   	/* window pointer location type */
      pt_res;    	/* resolution */
 int  pt_acx,    	/* actual x value */
      pt_acy,    	/* actual y value */
      pt_wrx,    	/* window relative x value */
      pt_wry;    	/* window relative y value */
} MSRET;

/* window regions for mouse */
#define WR_CNTNT	0 /* content region */
#define WR_CNTRL	1 /* control region */
#define WR_OFWIN	2 /* off window */

/**
 * @brief Set the mouse parameters.
 *
 * @param path_id The path to the window device.
 * @param sample_rate The number of system ticks to wait between samples (0 = no sampling).
 * @param timeout The number of system ticks between button click timeouts.
 * @param autofollow Turn on or off mouse auto-follow mode.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ss_mouse(path_id path, int sample_rate, int timeout, int autofollow);

/**
 * @brief Send signal upon mouse click.
 *
 * The window manager will send the requested signal when any mouse button is clicked.
 *
 * @param path_id The path to the window device.
 * @param signo The desired signal to receive.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ss_mssig(path_id path, int signo);

/**
 * @brief Set the mouse parameters.
 *
 * @param path_id The path to the window device.
 * @param mpkt The address of the mouse packet to be filled.
 * @param autofollow Turn on or off mouse auto-follow mode.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_gs_mouse(path_id path, MSRET *mpkt);

/**
 * @brief Returns the mouse position.
 *
 * This is a convenience function which returns the mouse coordinates.
 *
 * @param path_id The path to the window device.
 * @param x Address of the X coordinate which will be returned.
 * @param y Address of the Y coordinate which will be returned.
 * @return 0 if successful, -1 if mouse is outside of window, otherwise the error code.
 */
error_code _cgfx_mousexy(path_id path, int *x, int *y);


/**** BUFFER FUNCTIONS ****/

/**
 * @brief Define a Get/Put buffer.
 *
 * If the buffer already exists or not enough memory is free to grant the request, an error is returned.
 *
 * @param path_id The path to the window device.
 * @param grp The group number.
 * @param buf The buffer number.
 * @param bl  The buffer length.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_dfngpbuf(path_id path, int grp, int buf, int bl);

/**
 * @brief Remove a Get/Put buffer.
 *
 * Care should be taken when using this call as no link count is maintained by the system.
 * Deletion of standard get/put buffers is discouraged, and can cause system issues.
 * If the buffer number is 0, then all buffers in group are removed.
 *
 * @param path_id The path to the window device.
 * @param grp The group number.
 * @param buf The buffer number.
 * @param bl  The buffer length.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_kilbuf(path_id path, int grp, int buf);

/**
 * @brief Load a Get/Put buffer.
 *
 * This function will generate the necessary loading header to preload a Get/Put buffer.
 * The path does not have to point to a window device, although no load is done unless it
 * is a window device. A write should directly follow this call to insure the buffer is
 * not loaded with garbage.
 *
 * @param path_id The path to the window device.
 * @param grp The group number.
 * @param buf The buffer number.
 * @param sty The window type of the data (color information).
 * @param sx  The X size of the buffer data.
 * @param sy  The Y size of the buffer data.
 * @param bl  The length of the buffer data.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_gpload(path_id path, int grp, int buf, int sty, int sx, int sy, int bl);

/**
 * @brief Copy a portion of a graphic window.
 *
 * This function will copy the pixel data from a graphic window into a Get/Put buffer.
 *
 * @param path_id The path to the window device.
 * @param grp The group number.
 * @param buf The buffer number.
 * @param sty The window type of the data (color information).
 * @param bx  The X position of the graphic window to start copying.
 * @param by  The Y position of the graphic window to start copying.
 * @param sx  The length of graphic window data to copy.
 * @param sy  The height of the graphic window data to copy.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_getblk(path_id path, int grp, int buf, int bx, int by, int sx, int sy);

/**
 * @brief Draw a Get/Put buffer.
 *
 * This function will draw the pixel data stored in a Get/Put buffer onto a graphic window.
 *
 * @param path_id The path to the window device.
 * @param grp The group number.
 * @param buf The buffer number.
 * @param sty The window type of the data (color information).
 * @param bx  The X position in the graphic window to start drawing.
 * @param bx  The Y position in the graphic window to start drawing.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_putblk(path_id path, int grp, int buf, int bx, int by);


/**** MULTI-VUE FUNCTIONS ****/

#define MNENBL 		1
#define MNDSBL 		0
#define WINSYNC 	0xC0C0

/* default menu id's */
#define MN_MOVE 	1
#define MN_CLOS 	2
#define MN_GROW 	3
#define MN_USCRL 	4
#define MN_DSCRL 	5
#define MN_RSCRL 	6
#define MN_LSCRL 	7
#define MN_TNDY 	20
#define MN_FILE 	21
#define MN_EDIT 	22
#define MN_STYL 	23
#define MN_FONT 	24

/* window - menu data structures */
typedef struct mistr {  	/* menu item descriptor */
	char _mittl[15];       	/* name of item */
	char _mienbl;       	/* is item available? */
	char _mires[5];        	/* reserved */
} MIDSCR;              		/* item descriptor */

typedef struct mnstr {
	char _mnttl[15];       	/* name of menu */
	char _mnid,            	/* menu id number */
		_mnxsiz,          	/* width of menu */
		_mnnits,          	/* number of items */
		_mnenabl;         	/* is menu available? */
	char _mnres[2];        	/* reserved bytes */
	struct mistr *_mnitems; /* pointer to items */
} MNDSCR;              		/* menu descriptor */

typedef struct wnstr {  	/* window descriptor */
	char _wnttl[20];       	/* title of window */
	char _nmens;           	/* number of menus on window */
	char _wxmin,           	/* min. window width */
		_wymin;           	/* min. window height */
	short _wnsync;         	/* synch bytes $C0C0 */
	char _wnres[7];        	/* reserved */
	struct mnstr *_wnmen;  	/* pointer to menu descriptor's array */
} WNDSCR;

typedef struct {
	char *i_name; 			/* name of this menu item */
	char i_enabled; 		/* TRUE if this item is enabled */
	char (*i_func)(); 		/* pointer to function to call if this item selected */
} ITEM;

#define MN_DSBL 	0
#define MN_ENBL 	1
#define MN_FUNC 	1 /* call a function */
#define MN_SUBMN 	2 /* sub-menu */

/* window type defs */
#define WT_NBOX		0		/* No box- default window type */
#define WT_FWIN		1		/* Framed window with menus */
#define WT_FSWIN	2		/* Framed window with menus and scroll bars */
#define WT_SBOX		3		/* Shadowed window- form menus */
#define WT_DBOX		4		/* Double border- for dialog boxes */
#define WT_PBOX		5		/* Plain border- anything */

/**
 * @brief Sets the current window type.
 *
 * Consult the programmer's guide in the Multi-Vue manual for details on framed window menus.
 *
 * @param path_id The path to the window device.
 * @param wintype The window type to set.
 * @param windat  The window data buffer.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ss_wnset(path_id path, int wintype, WNDSCR *windat);

/**
 * @brief Get a menu selection.
 *
 * This function will attempt to get a menu selection from the user. If the user makes a
 * valid selection, then the item number is placed in the itemno location and the menu id
 * is returned in menuid.
 *
 * @param path_id The path to the window device.
 * @param itemno The address of the menu item number selected by the user.
 * @param menuid The address of the menu id selected by the user.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_gs_mnsel(path_id path, int *itemno, int *menuid);

/**
 * @brief Update menus.
 *
 * This function informs the window manager to update the menus.
 *
 * @param path_id The path to the window device.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ss_umbar(path_id path);

/**
 * @brief Set scroll bar positions.
 *
 * @param path_id The path to the window device.
 * @param horbar The position of the horizontal scroll bar.
 * @param verbar The position of the vertical scroll bar.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ss_sbar(path_id path, int horbar, int verbar);


/**** STATUS FUNCTIONS ****/

/**
 * @brief Get the text cursor position.
 *
 * @param path_id The path to the window device.
 * @param x The address of the X position to be filled.
 * @param y The address of the Y position to be filled.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_gs_crsr(path_id path, int *x, int *y);

/**
 * @brief Get the screen size.
 *
 * This function returns the size (in characters) of the window at the path.
 *
 * @param path_id The path to the window device.
 * @param sx The address of the screen width to be filled.
 * @param sy The address of the screen height to be filled.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_gs_scsz(path_id path, int *sx, int *sy);

/**
 * @brief Get the current palette register settings.
 *
 * This function returns the 16 palette register settings of the window at the path.
 *
 * @param path_id The path to the window device.
 * @param palbuf The address of a 16 byte array to be filled.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_gs_palt(path_id path, char *palbuf);

/**
 * @brief Map the Get/Put buffer.
 *
 * This function will map the specified get/put buffer into/out of the calling process's
 * address space. The direction of mapping is controlled by the mapsw variable. If it
 * is 0, then the buffer is mapped out; otherwise the buffer is mapped in.
 *
 * @param path_id The path to the window device.
 * @param grp The group number.
 * @param buf The buffer number.
 * @param mapsw The map switch (0 = map out, 1 = map in).
 * @param size The address of the size of the buffer (in/out parameter, returned to caller when mapsw = 1).
 * @param bufaddr The address of the buffer (in/out parameter, returned to caller with mapsw = 1).
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ss_mgpb(path_id path, int grp, int buf, int mapsw, int *size, char *bufaddr);

/**
 * @brief Get the window type.
 *
 * @param path_id The path to the window device.
 * @param type The address of the type  (out parameter, value returned to the caller).
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_gs_styp(path_id path, int *type);

/**
 * @brief Get the window palette registers.
 *
 * @param path_id The path to the window device.
 * @param fore The address of the foreground color (out parameter, value returned to the caller).
 * @param back The address of the background color (out parameter, value returned to the caller).
 * @param bord The address of the border color (out parameter, value returned to the caller).
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_gs_fbrg(path_id path, int *fore, int *back, int *bord);

/**
 * @brief Set global information parameters.
 *
 * This function sets global mouse and keyboard parameters that affect the entire system.
 * Use with caution.
 *
 * @param path_id The path to the window device.
 * @param msres The mouse resolution flag (0 = low resolution mouse, 1 = high resolution mouse)
 * @param msport The mouse port (1 = left port, 2 = right port)
 * @param kbdstrt The keyboard repeat start delay in 1/60ths of a second (0 = repeat off)
 * @param kbdrpt The keyboard repeat speed.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ss_gip(path_id path, int msres, int msport, int kbdstrt, int kbdrpt);

/**
 * @brief Set default palette.
 *
 * This function sets the default palette settings for the window at path.
 *
 * @param path_id The path to the window device.
 * @param palbuf The address of a 16 byte buffer provided by the caller containing the desired palette settings.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ss_dfpl(path_id path, char *palbuf);

/**
 * @brief Set the monitor type.
 *
 * This function sets the monitor type of the CoCo 3.
 *
 * @param path_id The path to the window device.
 * @param montype The monitor type (0 = composite monitor or TV, 1 = analog RGB monitor, 2 = monochrome composite monitor).
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ss_mtyp(path_id path, int montype);


/**** ADDED EXTRAS FROM MIKE SWEET ****/

typedef struct { 	/* dialog structure */
	char d_type;    /* type- 0=string, 1=button */
	char d_column;  /* column position within the overlay */
	char d_row;     /* row within the overlay */
	char d_key;     /* key assocated with this button (0 for none) */
	char d_val;     /* value to return to caller */
	char *d_string; /* pointer to actual string to be placed in overlay */
} DIALOG;        	/* call this type DIALOG */


/* now for some define constants for the 'd_type' field... */
#define D_TEXT 		0 	/* ASCII text */
#define D_KEY 		1   /* key-binding */
#define D_STRING 	2 	/* ASCII string box (accepts text) */
#define D_BUTTON 	3 	/* 3-D text button */
#define D_RADIO 	4  	/* Radio button (where d_string should be NULL)*/
#define D_END 		-1  /* End marker of array */


typedef struct OBJSTR {
	char group;          /* G/P group for this object */
	char buffer;         /* G/P buffer for this object */
	int xcor;            /* xcor * 32 */
	int ycor;            /* ycor * 32 */
	int deltax;          /* +/- xcor */
	int deltay;          /* +/- ycor */
	int xaccel;          /* xcor acceleration */
	int yaccel;          /* ycor acceleration */
	int (*border)();     /* function to call to check boundaries */
	struct OBJSTR *next; /* pointer to next object */
	struct OBJSTR *prev; /* pointer to previous object */
} OBJECT;   	         /* call this type OBJECT */

extern OBJECT *Objects; /* pointer to OBJECT list */

/* polygon vertex data structure */
typedef struct {
	int p_xcor;
	int p_ycor;
} VERTEX;

/**
 * @brief Send signal upon key press.
 *
 * The window manager will send the requested signal when any mouse button is clicked.
 *
 * @param path_id The path to the window device.
 * @param signo The desired signal to receive.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ss_ssig(path_id path, int signo);


typedef struct sgbuf { /* structure for 'getstat()' and 'setstat()' */
   char sg_class,       /* device class */

/* The following are for an SCF type device. See below for
 * structure member definitions for an RBF device.
 */
        sg_case,        /* 0 = upper and lower cases, 1 = upper case only */
        sg_backsp,      /* 0 = BSE, 1 = BSE-SP-BSE */
        sg_delete,      /* delete sequence */
        sg_echo,        /* 0 = no echo */
        sg_alf,         /* 0 = no auto line feed */
        sg_nulls,       /* end of line null count */
        sg_pause,       /* 0 = no end of page pause */
        sg_page,        /* lines per page */
        sg_bspch,       /* backspace character */
        sg_dlnch,       /* delete line character */
        sg_eorch,       /* end of record character */
        sg_eofch,       /* end of file character */
        sg_rlnch,       /* reprint line character */
        sg_dulnch,      /* duplicate last line character */
        sg_psch,        /* pause character */
        sg_kbich,       /* keyboard interrupt character */
        sg_kbach,       /* keyboard abort character */
        sg_bsech,       /* backspace echo character */
        sg_bellch,      /* line overflow character (bell) */
        sg_parity,      /* device initialisation (parity) */
        sg_baud;        /* baud rate */
   int  sg_d2p,         /* offset to second device name string */
        sg_stn;         /* offset to status routine name */
   char sg_err;         /* most recent error status */
   char sg_spare[5];    /* spare bytes - necessary for correct sizing */
} SCF_OPT;


/**
 * @brief Gets options for the given path.
 *
 * @param path_id The path to the window device.
 * @param buffer Updated to contain the options set for path.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_gs_opt(path_id path, SCF_OPT *opt);


/**
 * @brief Sets options for the given path.
 *
 * @param path_id The path to the window device.
 * @param buffer Updated to contain the options set for path.
 * @return 0 if successful, otherwise the error code.
 */
error_code _cgfx_ss_opt(path_id path, const SCF_OPT *opt);

#endif /* _CGFX_H */
