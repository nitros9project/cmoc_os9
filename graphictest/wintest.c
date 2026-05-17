/* MAZE.C                             */
/* */
/* Generates a random binary tree maze,  draws it and solves it  */
/* graphically. The Solution employs a simple depth first search  */
/* algorithm.                                                     */
/* */
/* This program was adapted for the HP workstation from one       */
/* provided with the Sun 3 software release version ???.          */
/* */
/* Converted to OS-9 and the Color Computer 3 by Brian C. White   */
/* (Requires the truely wonderful Kreider C library)              */
/* */
/* expanded to cover a 25 line screen and two minor bugs fixed   */
/* bug one is our "200" line screen, its actually 199 lines     */
/* The other was screen edge overflow in all directions causeing  */
/* draws to miss-fire and skip drawing the entrance marker often */
/* enough to get my attention. On 11/18/93,  Delphi "WOAY"       */

#define BACKPAL 00   /* Background color (black)           */
#define WRNGPAL 07   /* Wrong path color (dark grey)       */
#define PATHPAL 63   /* Correct path color (white)         */
#define MAZEPAL 63   /* Maze wall color (white)            */
#define ENDPAUSE 180 /* Ticks to wait between mazes (3*60) */

#define XSQ_SIZE 16
#define YSQ_SIZE 8
#define XPATH_SIZE 8
#define YPATH_SIZE 4
#define XDIFF 8
#define YDIFF 4
#define XOFFSET 4
#define YOFFSET 2
#define XINCR_OFFSET 5
#define YINCR_OFFSET 1
#define XWOBBLE 16 /* added to control placement better, WOAY */
#define YWOBBLE 7  /* ditto */
#define X_MAZE_SIZE 39
#define Y_MAZE_SIZE                               \
     24 /* up one line for modern screen drivers, \
         * WOAY */
#define MAZE_X_LESS_1 (X_MAZE_SIZE - 1)
#define MAZE_Y_LESS_1 (Y_MAZE_SIZE - 1)
#define MOVE_LIST_SIZE (X_MAZE_SIZE * Y_MAZE_SIZE)

#define TOP (unsigned)0x8880
#define RIGHT (unsigned)0x4440
#define BOTTOM (unsigned)0x2220
#define LEFT (unsigned)0x1110

#define WALL_TOP (unsigned)0x8000
#define WALL_RIGHT (unsigned)0x4000
#define WALL_BOTTOM (unsigned)0x2000
#define WALL_LEFT (unsigned)0x1000

#define TOP_IN_DOOR (unsigned)0x800
#define RIGHT_IN_DOOR (unsigned)0x400
#define BOT_IN_DOOR (unsigned)0x200
#define LEFT_IN_DOOR (unsigned)0x100
#define ANY_IN_DOOR (unsigned)0xF00

#define TOP_OUT_DOOR (unsigned)0x80
#define RIGHT_OUT_DOOR (unsigned)0x40
#define BOT_OUT_DOOR (unsigned)0x20
#define LEFT_OUT_DOOR (unsigned)0x10

#define START_SQUARE (unsigned)0x2
#define END_SQUARE (unsigned)0x1

#define MAZEGROUND 0
#define PATHGROUND 1
#define WRNGGROUND 2
#define BACKGROUND 3

#include <cgfx.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
//
#include <utime.h>

static unsigned /* short */ maze[X_MAZE_SIZE][Y_MAZE_SIZE];
static struct {
     /* unsigned */ int x;
     /* unsigned */ int y;
     /* unsigned */ int dir;
} move_list[MOVE_LIST_SIZE], save_path[MOVE_LIST_SIZE], path[MOVE_LIST_SIZE];

static unsigned int sqnum, cur_sq_x, cur_sq_y, path_length;
static unsigned int start_x, start_y, start_dir, end_x, end_y, end_dir;
static path_id outpath;
static unsigned int xoffset_count, yoffset_count;
static long rndseed;

int time() { return 0; }

void XDrawLine(unsigned int sx, unsigned int sy, unsigned int ex,
               unsigned int ey) {
     _cgfx_setdptr(outpath, sx, sy);
     _cgfx_line(outpath, ex, ey);
}

void XFillRectangle(unsigned int sx, unsigned int sy, unsigned int ex,
                    unsigned int ey) {
     _cgfx_setdptr(outpath, sx, sy);
     _cgfx_rbar(outpath, ex, ey);
}

int random(unsigned int num) { return (abs(rand() % num)); }

/* draw a solid circle in a square */
void circle_draw_solid(unsigned int i, unsigned int j, unsigned int dir) {
     unsigned int tempx, tempy;
     tempx = xoffset_count + 2 + XSQ_SIZE * i;
     tempy = yoffset_count + 2 + YSQ_SIZE * j;
     //_cgfx_setdptr(outpath, tempx + (int)(XOFFSET * 1.5), tempy + YOFFSET);
     _cgfx_setdptr(outpath, tempx + (int)(XOFFSET * 1), tempy + YOFFSET);
     _cgfx_circle(outpath, YPATH_SIZE);
     _cgfx_ffill(outpath);
} /* end of circle_draw_solid() */

/* draw a solid square in a square */
void square_draw_solid(unsigned int i, unsigned int j, unsigned int dir) {
     unsigned int tempx, tempy;
     tempx = xoffset_count + XOFFSET + XSQ_SIZE * i;
     tempy = yoffset_count + YOFFSET + YSQ_SIZE * j;
     switch (dir) {
     case 0: /* up */
          if (tempy > YDIFF)
               XFillRectangle(tempx, tempy - YDIFF, XPATH_SIZE, YPATH_SIZE + YDIFF);
          else
               XFillRectangle(tempx, 0, XPATH_SIZE,
                              YPATH_SIZE + YDIFF + (tempy - YDIFF));
          break;
     case 1: /* right */
          if (tempx < 623)
               XFillRectangle(tempx, tempy, XPATH_SIZE + XDIFF, YPATH_SIZE);
          else
               XFillRectangle(tempx, tempy, XPATH_SIZE + XDIFF - 4, YPATH_SIZE);
          break;
     case 2: /* down */
          if ((tempy + YPATH_SIZE + YDIFF) < 200)
               XFillRectangle(tempx, tempy, XPATH_SIZE, YPATH_SIZE + YDIFF);
          else
               XFillRectangle(tempx, tempy, XPATH_SIZE,
                              YPATH_SIZE + (199 - YPATH_SIZE) - tempy);
          break;
     case 3: /* left */
          if (tempx > XDIFF)
               XFillRectangle(tempx - XDIFF, tempy, XPATH_SIZE + XDIFF, YPATH_SIZE);
          else
               XFillRectangle(0, tempy, XPATH_SIZE + XDIFF - (XDIFF - tempx),
                              YPATH_SIZE);
          break;
     }
} /* end of square_draw_solid() */

int backup() { /* back up a move */
     sqnum--;
     cur_sq_x = move_list[sqnum].x;
     cur_sq_y = move_list[sqnum].y;
     return (sqnum);
} /* end of backup() */

/* draw the surrounding wall and start/end squares */
void initialize_maze() {
     register unsigned int i;
     unsigned int j, wall;
     unsigned int tempx, tempy;
     /* initialize all squares */
     _cgfx_fcolor(outpath, MAZEGROUND);
     for (i = 0; i < X_MAZE_SIZE; i++) {
          for (j = 0; j < Y_MAZE_SIZE; j++) {
               maze[i][j] = 0;
          }
     }
     /* top wall */
     for (i = 0; i < X_MAZE_SIZE; i++) {
          maze[i][0] = maze[i][0] | WALL_TOP;
     }
     /* right wall */
     for (j = 0; j < Y_MAZE_SIZE; j++) {
          maze[MAZE_X_LESS_1][j] = maze[MAZE_X_LESS_1][j] | WALL_RIGHT;
     }
     /* bottom wall */
     for (i = 0; i < X_MAZE_SIZE; i++) {
          maze[i][MAZE_Y_LESS_1] = maze[i][MAZE_Y_LESS_1] | WALL_BOTTOM;
     }
     /* left wall */
     for (j = 0; j < Y_MAZE_SIZE; j++) {
          maze[0][j] = maze[0][j] | WALL_LEFT;
     }
     /* set start square */
     wall = random(4);
     switch (wall) {
     case 0:
          i = random(X_MAZE_SIZE);
          j = 0;
          break;
     case 1:
          i = MAZE_X_LESS_1;
          j = random(Y_MAZE_SIZE);
          break;
     case 2:
          i = random(X_MAZE_SIZE);
          j = MAZE_Y_LESS_1;
          break;
     case 3:
          i = 0;
          j = random(Y_MAZE_SIZE);
          break;
     }
     maze[i][j] = maze[i][j] | START_SQUARE;
     maze[i][j] = maze[i][j] | (TOP_IN_DOOR >> wall);
     maze[i][j] = maze[i][j] & ~(WALL_TOP >> wall);
     cur_sq_x = i;
     cur_sq_y = j;
     start_x = i;
     start_y = j;
     start_dir = wall;
     sqnum = 0;
     /* set end square */
     wall = (wall + 2) % 4;
     switch (wall) {
     case 0:
          i = random(X_MAZE_SIZE);
          j = 0;
          break;
     case 1:
          i = MAZE_X_LESS_1;
          j = random(Y_MAZE_SIZE);
          break;
     case 2:
          i = random(X_MAZE_SIZE);
          j = MAZE_Y_LESS_1;
          break;
     case 3:
          i = 0;
          j = random(Y_MAZE_SIZE);
          break;
     }
     maze[i][j] = maze[i][j] | END_SQUARE;
     maze[i][j] = maze[i][j] | (TOP_OUT_DOOR >> wall);
     maze[i][j] = maze[i][j] & ~(WALL_TOP >> wall);
     end_x = i;
     end_y = j;
     end_dir = wall;
     /* draw the border */
     for (i = 0; i < X_MAZE_SIZE; i++) {
          if (maze[i][0] & WALL_TOP) {
               tempx = xoffset_count + XSQ_SIZE * i;
               tempy = yoffset_count;
               XDrawLine(tempx, tempy, tempx + XSQ_SIZE, tempy);
          }
          if ((maze[i][MAZE_Y_LESS_1] & WALL_BOTTOM)) {
               tempx = xoffset_count + XSQ_SIZE * i;
               tempy = yoffset_count + Y_MAZE_SIZE * YSQ_SIZE;
               XDrawLine(tempx, tempy, tempx + XSQ_SIZE, tempy);
          }
     }
     for (j = 0; j < Y_MAZE_SIZE; j++) {
          if (maze[MAZE_X_LESS_1][j] & WALL_RIGHT) {
               tempx = xoffset_count + X_MAZE_SIZE * XSQ_SIZE;
               tempy = yoffset_count + YSQ_SIZE * j;
               XDrawLine(tempx, tempy, tempx, tempy + YSQ_SIZE);
          }
          if (maze[0][j] & WALL_LEFT) {
               tempx = xoffset_count;
               tempy = yoffset_count + YSQ_SIZE * j;
               XDrawLine(tempx, tempy, tempx, tempy + YSQ_SIZE);
          }
     }
     circle_draw_solid(start_x, start_y, start_dir);
     square_draw_solid(end_x, end_y, end_dir);
} /* end of initialize_maze() */

/* draw a single wall */
void draw_wall(unsigned int i, unsigned int j, unsigned int dir) {
     unsigned int tempx, tempy;
     switch (dir) {
     case 0: /* top */
          tempx = xoffset_count + XSQ_SIZE * i;
          tempy = yoffset_count + YSQ_SIZE * j;
          XDrawLine(tempx, tempy, tempx + XSQ_SIZE, tempy);
          break;
     case 1: /* right */
          tempx = xoffset_count + XSQ_SIZE * (i + 1);
          tempy = yoffset_count + YSQ_SIZE * j;
          XDrawLine(tempx, tempy, tempx, tempy + YSQ_SIZE);
          break;
     case 2: /* bottom */
          tempx = xoffset_count + XSQ_SIZE * i;
          tempy = yoffset_count + YSQ_SIZE * (j + 1);
          XDrawLine(tempx, tempy, tempx + XSQ_SIZE, tempy);
          break;
     case 3: /* left */
          tempx = xoffset_count + XSQ_SIZE * i;
          tempy = yoffset_count + YSQ_SIZE * j;
          XDrawLine(tempx, tempy, tempx, tempy + YSQ_SIZE);
          break;
     }
} /* end of draw_wall */

/* pick a new path */
int choose_door() {
     unsigned int candidates[3];
     register unsigned int num_candidates;
     num_candidates = 0;
topwall:
     /* top wall */
     if (maze[cur_sq_x][cur_sq_y] & TOP)
          goto rightwall;
     if (maze[cur_sq_x][cur_sq_y - 1] & ANY_IN_DOOR) {
          maze[cur_sq_x][cur_sq_y] = maze[cur_sq_x][cur_sq_y] | WALL_TOP;
          maze[cur_sq_x][cur_sq_y - 1] = maze[cur_sq_x][cur_sq_y - 1] | WALL_BOTTOM;
          draw_wall(cur_sq_x, cur_sq_y, 0);
          goto rightwall;
     }
     candidates[num_candidates++] = 0;
rightwall:
     /* right wall */
     if (maze[cur_sq_x][cur_sq_y] & RIGHT)
          goto bottomwall;
     if (maze[cur_sq_x + 1][cur_sq_y] & ANY_IN_DOOR) {
          maze[cur_sq_x][cur_sq_y] = maze[cur_sq_x][cur_sq_y] | WALL_RIGHT;
          maze[cur_sq_x + 1][cur_sq_y] = maze[cur_sq_x + 1][cur_sq_y] | WALL_LEFT;
          draw_wall(cur_sq_x, cur_sq_y, 1);
          goto bottomwall;
     }
     candidates[num_candidates++] = 1;
bottomwall:
     /* bottom wall */
     if (maze[cur_sq_x][cur_sq_y] & BOTTOM)
          goto leftwall;
     if (maze[cur_sq_x][cur_sq_y + 1] & ANY_IN_DOOR) {
          maze[cur_sq_x][cur_sq_y] = maze[cur_sq_x][cur_sq_y] | WALL_BOTTOM;
          maze[cur_sq_x][cur_sq_y + 1] = maze[cur_sq_x][cur_sq_y + 1] | WALL_TOP;
          draw_wall(cur_sq_x, cur_sq_y, 2);
          goto leftwall;
     }
     candidates[num_candidates++] = 2;
leftwall:
     /* left wall */
     if (maze[cur_sq_x][cur_sq_y] & LEFT)
          goto donewall;
     if (maze[cur_sq_x - 1][cur_sq_y] & ANY_IN_DOOR) {
          maze[cur_sq_x][cur_sq_y] = maze[cur_sq_x][cur_sq_y] | WALL_LEFT;
          maze[cur_sq_x - 1][cur_sq_y] = maze[cur_sq_x - 1][cur_sq_y] | WALL_RIGHT;
          draw_wall(cur_sq_x, cur_sq_y, 3);
          goto donewall;
     }
     candidates[num_candidates++] = 3;
donewall:
     if (num_candidates == 0)
          return (-1);
     if (num_candidates == 1)
          return (candidates[0]);
     return (candidates[random(num_candidates)]);
} /* end of choose_door() */

/* create a maze layout given the intiialized maze */
void create_maze() {
     register unsigned int i;
     unsigned int newdoor;
     _cgfx_fcolor(outpath, MAZEGROUND);
     do {
          move_list[sqnum].x = cur_sq_x;
          move_list[sqnum].y = cur_sq_y;
          move_list[sqnum].dir = newdoor;
          /* pick a door */
          while ((newdoor = choose_door()) == -1) {
               /* no more doors ... backup */
               if (backup() == -1) {
                    /* done ... return */
                    return;
               }
          }
          /* mark the out door */
          maze[cur_sq_x][cur_sq_y] =
               maze[cur_sq_x][cur_sq_y] | (TOP_OUT_DOOR >> newdoor);
          switch (newdoor) {
          case 0:
               cur_sq_y--;
               break;
          case 1:
               cur_sq_x++;
               break;
          case 2:
               cur_sq_y++;
               break;
          case 3:
               cur_sq_x--;
               break;
          }
          sqnum++;
          /* mark the in door */
          maze[cur_sq_x][cur_sq_y] =
               maze[cur_sq_x][cur_sq_y] | (TOP_IN_DOOR >> ((newdoor + 2) % 4));
          /* if end square set path length and save path */
          if (maze[cur_sq_x][cur_sq_y] & END_SQUARE) {
               path_length = sqnum;
               for (i = 0; i < path_length; i++) {
                    save_path[i].x = move_list[i].x;
                    save_path[i].y = move_list[i].y;
                    save_path[i].dir = move_list[i].dir;
               }
          }
     } while (1);
} /* end of create_maze() */

/* move into a neighboring square */
void enter_square(unsigned int n) {
     square_draw_solid((int)path[n].x, (int)path[n].y, (int)path[n].dir);
     path[n + 1].dir = -1;
     switch (path[n].dir) {
     case 0:
          path[n + 1].x = path[n].x;
          path[n + 1].y = path[n].y - 1;
          break;
     case 1:
          path[n + 1].x = path[n].x + 1;
          path[n + 1].y = path[n].y;
          break;
     case 2:
          path[n + 1].x = path[n].x;
          path[n + 1].y = path[n].y + 1;
          break;
     case 3:
          path[n + 1].x = path[n].x - 1;
          path[n + 1].y = path[n].y;
          break;
     }
} /* end of enter_square() */

/* solve it with graphical feedback */
void solve_maze() {
     register unsigned int i;
     _cgfx_fcolor(outpath, PATHGROUND);
     /* plug up the surrounding wall */
     maze[start_x][start_y] = maze[start_x][start_y] | (WALL_TOP >> start_dir);
     maze[end_x][end_y] = maze[end_x][end_y] | (WALL_TOP >> end_dir);
     /* initialize search path */
     i = 0;
     path[i].x = end_x;
     path[i].y = end_y;
     path[i].dir = -1;
     /*
      * Pixmap tile25; tile25 = XwCreateTile ( DefaultScreen( display ),
      * WhitePixel(display, DefaultScreen(display)), BlackPixel(display,
      * DefaultScreen(display)), Xw25_FOREGROUND );
      */
     /* do it */
     while (1) {
          if (++path[i].dir >= 4) {
               /*
                * XSetTile ( display , gc, tile25 ); XSetFillStyle (
                * display , gc, FillTiled );
                */
               _cgfx_fcolor(outpath, WRNGGROUND);
               i--;
               square_draw_solid((int)(path[i].x), (int)(path[i].y), (int)(path[i].dir));
               _cgfx_fcolor(outpath, PATHGROUND);
          } else if (!((maze[path[i].x][path[i].y] & (WALL_TOP >> path[i].dir))) &&
                     ((i == 0) || ((path[i].dir != (path[i - 1].dir + 2) % 4)))) {
               enter_square(i);
               i++;
               if (maze[path[i].x][path[i].y] & START_SQUARE)
                    return;
          }
     }
} /* end of solve_maze() */

int main(int argc, char **argv) {
     xoffset_count = 0;
     yoffset_count = 4;

     if (_os_open("/w", FAM_READ | FAM_WRITE, &outpath) != 0) {
          exit(193);
     }

     _cgfx_dwset(outpath, 6, 0, 0, 40, Y_MAZE_SIZE + 1, BACKGROUND, BACKGROUND,
                 BACKGROUND);
     _cgfx_curoff(outpath);
     _cgfx_scalesw(outpath, 1);
     _cgfx_palette(outpath, BACKGROUND, BACKPAL);
     _cgfx_palette(outpath, WRNGGROUND, WRNGPAL);
     _cgfx_palette(outpath, PATHGROUND, PATHPAL);
     _cgfx_palette(outpath, MAZEGROUND, MAZEPAL);
     _cgfx_select(outpath);

     // turn on key sensing(VTIO supported)
     _os_ss_keysense(outpath, 1);

     // keys are mapped as per https://nitros9.sourceforge.io / wiki / index.php /
     // SS.KySns_Get_Status
     int keys;
     while ((_os_gs_keysense(outpath, &keys) == 0) &&
            ((keys & _SS_KEYSENSE_SPACE) == 0x00) /* spacebar not hit */) {
          rndseed = time();
          srand((unsigned)rndseed);
          _cgfx_clear(outpath);
          _cgfx_fcolor(outpath, MAZEGROUND);
          initialize_maze();
          create_maze();
          solve_maze();
          int timeout = ENDPAUSE;
          _os9_sleep(&timeout);
          xoffset_count = (xoffset_count + XINCR_OFFSET) % XWOBBLE;
          yoffset_count = (yoffset_count + YINCR_OFFSET) % YWOBBLE;
     }

     // turn off key sensing(not really needed since we 're closing outpath)
     _os_ss_keysense(outpath, 0);

     _os_close(outpath);

     return 0;
} /* end of main() */
