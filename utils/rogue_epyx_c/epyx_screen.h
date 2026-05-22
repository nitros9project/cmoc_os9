#ifndef EPYX_SCREEN_H
#define EPYX_SCREEN_H

int epyx_screen_init();
void epyx_write_char(int ch);
void epyx_write_string(const char *text);
void epyx_move_cursor(int x, int y);
void epyx_clear_window();
void epyx_clear_to_eol();
void epyx_cursor_on();
void epyx_cursor_off();
void epyx_reverse_on();
void epyx_reverse_off();

#endif
