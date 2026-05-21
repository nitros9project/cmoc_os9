#include <os.h>
#include <os9abi.h>

#include "epyx_arena.h"
#include "epyx_screen.h"

int write();

static int string_length(text)
const char *text;
{
  int len;

  len = 0;
  while (text[len]) len++;
  return len;
}

static void write_bytes(data, count)
char *data;
int count;
{
  write(1, data, count);
}

static void set_screen_size(width, height)
int width;
int height;
{
  rogue_put8(OFF_SCREEN_WIDTH, width);
  rogue_put8(OFF_SCREEN_HEIGHT, height);
  rogue_put8(OFF_SCREEN_MAX_X, width - 1);
  rogue_put8(OFF_SCREEN_MAX_Y, height - 1);
}

static void compute_status_layout()
{
  int width;
  int index;
  int adjust;

  width = rogue_get8(OFF_SCREEN_WIDTH);
  index = 0;
  while (rogue_get8(OFF_MIN_WINDOW_WIDTHS + index) != 0 &&
         width >= rogue_get8(OFF_MIN_WINDOW_WIDTHS + index)) {
    index++;
  }
  if (index > 0) index--;

  adjust = rogue_get8(OFF_MIN_WINDOW_WIDTHS + 7 + index);
  rogue_put8(OFF_STATUS_HEIGHT_ADJUST, adjust);
  rogue_put16(OFF_STATUS_TABLE_OFFSET, index * 8);
  rogue_put8(OFF_STATUS_USABLE_HEIGHT,
             rogue_get8(OFF_SCREEN_HEIGHT) - adjust);
}

int epyx_screen_init()
{
  registers_6809 regs;

  regs.a = 0;
  regs.b = SS_ScSiz;
  regs.x = 0;
  regs.y = 0;
  if (_os_syscall(I$GetStt, &regs) == 0) {
    set_screen_size(regs.x, regs.y);
  } else {
    set_screen_size(80, 24);
  }

  compute_status_layout();
  epyx_clear_window();
  epyx_cursor_off();
  epyx_move_cursor(0, 0);
  return 0;
}

void epyx_write_char(ch)
int ch;
{
  rogue_put8(OFF_CHAR_BUFFER, ch);
  write_bytes(rogue_ptr(OFF_CHAR_BUFFER), 1);
}

void epyx_write_string(text)
const char *text;
{
  write(1, text, string_length(text));
}

void epyx_move_cursor(x, y)
int x;
int y;
{
  rogue_put8(OFF_CURSOR_XY_BUFFER, 2);
  rogue_put8(OFF_CURSOR_XY_BUFFER + 1, x + 32);
  rogue_put8(OFF_CURSOR_XY_BUFFER + 2, y + 32);
  write_bytes(rogue_ptr(OFF_CURSOR_XY_BUFFER), 3);
}

void epyx_clear_window()
{
  epyx_write_char(12);
}

void epyx_clear_to_eol()
{
  epyx_write_char(4);
}

void epyx_cursor_on()
{
  write_bytes(rogue_ptr(OFF_CURSOR_ON), 2);
}

void epyx_cursor_off()
{
  write_bytes(rogue_ptr(OFF_CURSOR_OFF), 2);
}

void epyx_reverse_on()
{
  write_bytes(rogue_ptr(OFF_REVERSE_ON), 2);
}

void epyx_reverse_off()
{
  write_bytes(rogue_ptr(OFF_REVERSE_OFF), 2);
}
