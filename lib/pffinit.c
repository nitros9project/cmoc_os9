/*
     Modification history:
          20-May-83 Fixed rounding problem causeing numbers to
                    print with colons.
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>

static char *_ftoa(double *np0, int prec, int format, int c);
int _abnorm(double *d);
static int _outdig(double *np, double **conptr);
extern double scale(double n, int power, int esign);
extern double ftoatbl[], *ftblend;
static char buf[30];

int pffinit()
{
	return 0;
}

char *pffloat(int c, int prec, double **args)
{
        int format;

        switch(c) {
                case 'f':
                        format = 1;
                        break;
                case 'e':
                case 'E':
                        format = -1;
                        break;
                case 'g':
                case 'G':
                        format = 0;
        }
        return _ftoa((*args)++,prec,format,isupper(c));
}

static char *_ftoa(double *np0, int prec, int format, int c)    /* double to ascii conversion */
{
       register char *np,*p,*mark;
       int sign,esign,exp,power,dppos,sciflag;
       double *conptr;
       int ldigit,chopflag,roundflag=1;
       double n;

       n = *np0;
       /* scale into range 1.0 <= n < 10.0 */

       np = (char *)&n;        /* so we can get at the exponent */

#if FLOATING_POINT_SUPPORTED
       /* remove bias and test for neg */
       if(np[7]==0) {
               dppos=sign=esign=0;
               goto choose;
       }
       else if((exp = (np[7] & 0xff) - 0x80) < 0) {
               exp = -exp;     /* reverse sign */
               esign = 1;      /* flag negative */
       }
       else esign = 0;         /* flag positive */

       /* find power of ten for scaling */
       power = ((exp * 78) >> 8);     /* == int((exp * 78)/256) */

       /* preset decimal point */
       dppos = (esign ? -power : power) + 1;

       if (*np < 0) { /* same as if (n < 0) */
               *np &= 0x7f;   /* same as  n = -n; */
               sign=1;
       }
       else sign=0;

#ifdef DEBUG
       printf("before scale\n");
       dumpf(&n);
#endif

       /* perform gross scale */
       n = scale(n,power,esign);

#ifdef DEBUG
       printf("after scale (ddpos=%d)\n",dppos);
       dumpf(&n);
#endif

       /* finish off */
       while ( n < 1. ) {
               n *= 10.0;        /* multiply up */
#ifdef DEBUG
          printf("after mul up\n");
          dumpf(&n);
#endif
               dppos--;        /* dec count */
       }
       while ( n >= 10. ) {
               n /= 10.0;        /* divide down */
#ifdef DEBUG
          printf("after div dn\n");
          dumpf(&n);
#endif
               dppos++;        /* bump count */
       }

#ifdef DEBUG
       printf("after ranging\n");
       dumpf(&n);
#endif

       /* now 1.0 <= n < 10.0 , down to business */

choose: p = buf;
        *p++ = '0';             /* preset for rounding */
        if(sign)
                *p++ = '-';
        if(prec > 16)
                prec = 16;      /* get precision in sensible range */
        else if(prec < 0)
                prec = 0;

        chopflag = 0;
        if(format == 0) {         /* select shortest */
                chopflag = 1;             /* trailing zeroes chopped */
                if(dppos > 5)
                        goto dosci;
                else
                        goto dof;
        }
        else if(format < 0 ) {          /* scientific */
        dosci:  sciflag = 1;
                ldigit = 1;
                if(n == 0)
                        dppos = 1;      /* make positive exponent */
        }
        else {                          /* f format */
        dof:    sciflag = 0;
                if((ldigit = dppos) < 0){
                        if(ldigit + prec >= 0)
                                prec += ldigit;
                        else {
                                ldigit = -prec;
                                prec = 0;
                                roundflag = 0;
                        }
                }
                else if(ldigit + prec > 25)
                        goto dosci;
        }

        conptr = ftoatbl;

        _abnorm(&n); /* de-normalize number */
#endif
#ifdef DEBUG
        printf("after de-normalizing\n");
        dumpf(&n);
#endif

        if(ldigit < 0) {
                *p++ = '0';
                mark = p;
                *p++ = '.';
                while(ldigit++)
                        *p++ = '0';
        }
        else {
                if(ldigit == 0)
                        *p++ = '0';
                while (ldigit--) {
                        *p++ = _outdig(&n,&conptr);
#ifdef DEBUG
                        printf("after outdig(1)\n");
                        dumpf(&n);
#endif
                }

                mark = p;               /* mark for chop */
                if(prec)
                        *p++ = '.';     /* no dp if no digits after */
        }

        while (prec-->0) {
                *p++ = _outdig(&n,&conptr);
#ifdef DEBUG
                printf("after outdig(2)\n");
                dumpf(&n);
#endif
        }

#ifdef DEBUG
     *p='\0';
     printf("\n buffer is %s\n",buf);
#endif

        if(roundflag) {       /* round off */
                int carry;
                char *p1;

                *(p1 = p) = _outdig(&n,&conptr); /* put in another digit */

                for(carry = 5; ; p1--) {
                        switch (*p1) {
                                case '.':
                                        p1--;
                                        break;
                                case '-':
                                        p1[-1] = '-';
                                        *p1 = '0';
                        }

                        if(carry = ((*p1 += carry) > '9'))
                                *p1 -= 10;
                        else
                                break;
                }
        }

        if(sciflag) {
                *p++ = c ? 'E' : 'e';
                if (--dppos <0 ) {
                        dppos = -dppos;
                        *p++ = '-';
                }
                else
                        *p++ = '+';

                *p++ = (dppos/10)+'0';
                *p++ = (dppos%10)+'0';
        }
        else if(chopflag && p != mark) {      /* remove trailing zeroes & dp */
                while(--p != mark){
                        if (*p != '0') {
                                ++p;
                                break;
                        }
                }
        }

        *p = '\0';
        if(p >= &buf[30]) {
                fprintf(stderr,"pffinit buffer overflow\n");
                exit(1);
        }

        return (buf[0] == '0' ? &buf[1] : buf);
}


static int _outdig(double *np, double **conptr)
{
       int count;
       double con;

       count = 0;
       if (*conptr != ftblend) {
               con = **conptr;
               while ( *np >= con) {
                       count++;
                       *np -= con;
               }
               (*conptr)++;
       }
     return count+'0';
}

double ftoatbl[] = {
#if FLOATING_POINT_SUPPORTED
     1.0e-0,
     1.0e-1,
     1.0e-2,
     1.0e-3,
     1.0e-4,
     1.0e-5,
     1.0e-6,
     1.0e-7,
     1.0e-8,
     1.0e-9,
     1.0e-10,
     1.0e-11,
     1.0e-12,
     1.0e-13,
     1.0e-14,
     1.0e-15,
     1.0e-16,
     1.0e-17
#endif
};
double *ftblend = ftoatbl + (sizeof ftoatbl)/(sizeof(double));

#ifdef DEBUG
dumpf(s)
register char *s;
{
     int i;

     for(i=0; i<8; ++i)
          printf("%02x ",*s++ & 0xff);
     printf("\n");
}
#endif

char bytcnt; // significant byte count

__norts__ asm int _abnorm(double *d)
{
asm
{
 nam Float-ASCII Conversion Support
 ttl De-normalize floating point number

*
*    abnorm
*         in:  Reg d- ptr to double
*         out: d    - 0
*
 pshs u save register
 tfr d,x get float ptr
 lda 7,x get exponent
 suba #128 remove bias
 bcs abnd branch if out of range
 ldb 0,x set implied bit
 orb #$80
 stb 0,x
 clr 7,x
 suba #4 need shifting?
 beq abnb branch if not
abna lsr 0,x shift mantissa
 ror 1,x
 ror 2,x
 ror 3,x
 ror 4,x
 ror 5,x
 ror 6,x
 ror 7,x
 inca count shift
 bne abna branch if more
abnb lda #8 get max bytes
abnc deca count bytes
 bmi abnd branch if zero
 ldb a,x is byte significant?
 beq abnc branch if not
abnd sta <bytcnt save for 'outdig'
 clra
 clrb
 puls u,pc
}
}

#if 0
*
*    outdig
*         in:  reg d  - ptr to abnormal float
*         out: d      - next digit
*
_outdig tfr d,x get float ptr
 clra
 ldb 0,x get next digit
 lsrb
 lsrb
 lsrb
 lsrb
 addb #'0'
 pshs d,u save registers
 ldb 0,x clear new digit
 andb #$0F
 stb 0,x
 bsr shift get float * 2
 lda <bytcnt get byte count
 bmi outde branch if none
outda ldb a,x get next byte
 bne outdb branch if significant
 deca count byte
 bpl outda branch if more
outdb sta <bytcnt update byte count
 bmi outde
 leas -8,s get scratch
outdc ldb a,x copy float * 2
 stb a,s
 deca count byte
 bpl outdc branch if more
 bsr shift get float * 4
 bsr shift get float * 8
 lda <bytcnt get byte count
 clrb clear carry
outdd ldb a,x
 adcb a,s
 stb a,x
 deca count byte
 bpl outdd branch if more
 leas 8,s return scratch
outde puls d,u,pc

shift lda <bytcnt
 bmi shiftc
 asl a,x
 bra shiftb
shifta rol a,x
shiftb deca count byte
 bpl shifta
shiftc rts
#endif
