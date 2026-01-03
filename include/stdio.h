#ifndef _STDIO_H
#define _STDIO_H

#define BUFSIZ  256
#define _NFILE  16
typedef struct _iobuf {
       char *_ptr,   	/* buffer pointer */
            *_base,  	/* buffer base address */
            *_end;  	/* buffer end address */
       int _flag;      	/* file status */
       int _fd;        	/* file path number */
       char _save;     	/* for 'ungetc' when unbuffered */
       int _bufsiz;    	/* size of data buffer */
} FILE;

extern FILE _iob[_NFILE];

#define _READ       1
#define _WRITE      2
#define _UNBUF      4
#define _BIGBUF     8
#define _EOF        0x10
#define _ERR        0x20
#define _SCF        0x40
#define _RBF        0x80
#define _DEVMASK    0xc0
#define _WRITTEN    0x0100    /* buffer written in update mode */
#define _INIT       0x8000    /* _iob initialized */

#define EOF 		(-1)
#define EOL 		13

#define stdin 		_iob
#define stdout 		(&_iob[1])
#define stderr 		(&_iob[2])

#define PMODE  		0xb   /* r/w for owner, r for others */

int getc(FILE *stream);
int putc(int c, FILE *stream);
int putw(int w, FILE *stream);
int puts(int c);
int fputs(int c, FILE *stream);

#define fgetc      	getc
#define putchar(c) 	putc(c,stdout)
#define getchar()  	getc(stdin)
#define ferror(p)  	((p)->_flag&_ERR)
#define feof(p)    	((p)->_flag&_EOF)
#define clearerr(p)	((p)->_flag&=~_ERR)
#define fileno(p)   ((p)->_fd)

int printf(const char *fmt, ...);
int fprintf(FILE *fp, const char *fmt, ...);
int sprintf(char *str, const char *fmt, ...);
char *fgets(char *str, int size, FILE *stream);

FILE *fopen(char *path, char *mode);
int fclose(FILE *fp);
int fflush(FILE *fp);

long fseek(FILE *fp, long pos, int whence);
long ftell(FILE *fp);
void rewind(FILE *fp);

#define	TRUE		(1)
#define	FALSE		(0)

#endif
