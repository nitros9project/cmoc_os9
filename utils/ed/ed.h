/*      ed.h    */
#define FATAL   (ERR-1)
struct line {
  int l_stat;                   /* empty, mark */
  struct line *l_prev;
  struct line *l_next;
  char l_buff[1];
};

typedef struct line LINE;

#define LINFREE 1               /* entry not in use */
#define LGLOB   2               /* line marked global */

                                /* max number of chars per line */
#define MAXLINE 256
#define MAXPAT  256             /* max number of chars per replacement
                                 * pattern */
                                /* max file name size */
#define MAXFNAME 256

extern LINE line0;
extern int curln, lastln, line1, line2, nlines;
extern int nflg;                /* print line number flag */
extern int lflg;                /* print line in verbose mode */
extern char *inptr;             /* tty input buffer */
extern char linbuf[], *linptr;  /* current line */
extern int truncflg;            /* truncate long line flag */
extern int eightbit;            /* save eighth bit */
extern int nonascii;            /* count of non-ascii chars read */
extern int nullchar;            /* count of null chars read */
extern int truncated;           /* count of lines truncated */
extern int fchanged;            /* file changed */

LINE *getptr(int num);
char *getfn(void);
char *gettxt(int num);

int append(int line, int glob);
int ckglob(void);
int deflt(int def1, int def2);
int del(int from, int to);
int docmd(int glob);
int doglob(void);
int dolst(int from, int to);
int doprnt(int from, int to);
int doread(int lin, char *fname);
int dowrite(int from, int to, char *fname, int apflg);
int egets(char *str, int size, FILE *stream);
int find(TOKEN *pat, int dir);
int getlst(void);
int getnum(int first);
int getone(void);
int getrhs(char *sub);
int ins(char *str);
int join(int first, int last);
int move(int num);
int set(void);
int show(void);
int subst(TOKEN *pat, char *sub, int gflg, int pflag);
int transfer(int num);
void clrbuf(void);
void relink(LINE *a, LINE *x, LINE *y, LINE *b);
void set_buf(void);

#define nextln(l)       ((l)+1 > lastln ? 0 : (l)+1)
#define prevln(l)       ((l)-1 < 0 ? lastln : (l)-1)
