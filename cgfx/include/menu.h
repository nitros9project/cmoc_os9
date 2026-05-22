#ifndef _CGFX_MENU_H
#define _CGFX_MENU_H

#ifndef _CGFX_ITEM_DEFINED
#define _CGFX_ITEM_DEFINED
typedef struct {
 char *i_name; /* name of this menu item */
 char i_enabled; /* TRUE if this item is enabled */
 char (*i_func)(); /* pointer to function to call if this item selected */
 } ITEM;
#endif

int Menu(int path, char *title, ITEM itemptr[], int fg, int bg);
int MenuXY(int path, char *title, ITEM itemptr[], int column, int row, int fg, int bg);
int MVMenu(int path, char *title, ITEM itemptr[], int fg, int bg);
int MVMenuXY(int path, char *title, ITEM itemptr[], int column, int row, int fg, int bg);

#define MN_DSBL 0
#define MN_ENBL 1
#define MN_FUNC 1 /* call a function */
#define MN_SUBMN 2 /* sub-menu */

#endif
