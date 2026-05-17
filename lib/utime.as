* Disassembly by Os9disasm of utime.r


__os_getime         EXTERNAL            ; import external symbol
_flacc              EXTERNAL            ; import external symbol
_sprintf            EXTERNAL            ; import external symbol
_DEBUG              EXTERNAL            ; import external symbol

_time               EXPORT              ; export this symbol
_o2utime            EXPORT              ; export this symbol
_u2otime            EXPORT              ; export this symbol

                    section   bss       ; begin bss section

* Uninitialized data (class B)
_tm                 rmb       16        ; reserve 16 bytes
_datebuf            rmb       26        ; reserve 26 bytes

                    endsection           ; end current section

                    section   rwdata    ; begin rwdata section

*
* static int   monsiz[] = {31,28,31,30,31,30,31,31,30,31,30,31};
monsiz
                    fdb       31,28,31,30,31,30,31,31,30,31,30,31 ; define word data 31,28,31,30,31,30,31,31,30,31,30,31

                    endsect             ; end current section

                    section   code      ; begin code section

* long
* time(arg)
* long  *arg;
*    {
*    _os_time tbuf;
*    long  result, o2utime();
*
*    getime(tbuf);
*    result = o2utime(tbuf);
*    if (arg)
*       *arg = result;
*    return (result);
*    }

* CMOC adds an hidden argument
* long time(long *return, long *arg)
*
* _os_getime
* |    _o2utime
* V    s    hidden long * to _o2utime
* s    s+2  &tbuf - arg to os_getime and o2utime
* s+2  s+4  _os_time tbuf
* s+8  s+10 saved U
* s+10 s+12 return addr
* s+12 s+14 hidden long * to _time
* s+14 s+16 long *arg

_time
                    pshs      u         ; save U on the hardware stack
                    leas      -6,s      ; tbuf
                    leau      ,s        ; address of tbuf
                    pshs      u         ; save U on the hardware stack
                    lbsr      __os_getime ; get system time
                    stu       ,s        ; still &tbuf
                    ldx       12,s      ; argument to time
                    pshs      x         ; argument to o2utime
                    bsr       _o2utime  ; convert unix style
                    ldu       16,s      ; check arg
                    beq       noarg     ; branch if equal/zero to noarg
                    ldd       ,x        ; so copy over
                    std       ,u        ; store D to memory pointed to by U
                    ldd       2,x       ; load D from indexed value 2,x
                    std       2,u       ; store D to indexed value 2,u
noarg               leas      10,s      ; adjust S using 10,s
                    puls      u,pc      ; restore registers and return


* long
* o2utime(tp)
* _os_time  *tp;
*    {
*    int   j, leap;
*    long  accum = 0;
*
* CMOC adds an extra parameter
* long o2utime(long *return, _os_time *tp)
_o2utime
                    pshs      D,U       ; save D,U on the hardware stack
                    ldu       8,s       ; get tp
                    clra                ; clear A
                    clrb                ; clear B
                    pshs      d         ; save D on the hardware stack
                    pshs      d         ; save D on the hardware stack

*    for (j = 70; j < *tp; ++j)         /* total up days in years past */
*       accum += ((j & 3) ? 365 : 366);     /* don't forget leap years */
                    ldb       #70-1     ; load B from immediate value 70-1
                    ldx       #0        ; load X from immediate value 0
                    bra       o2ut2     ; branch unconditionally to o2ut2

o2ut1               leax      365,x     ; compute effective address into X from 365,x
                    bitb      #3        ; test bits in B against immediate value 3
                    bne       o2ut2     ; branch if not equal to o2ut2
                    leax      1,x       ; compute effective address into X from 1,x
o2ut2               incb                ; increment B
                    cmpb      ,u        ; year
                    blt       o2ut1     ; branch if less than to o2ut1
                    stx       2,s       ; store X to stack-relative value 2,s
*
*    monsiz[1] = (*tp++ & 3) ? 28 : 29;           /* fix for leap year */
                    leax      monsiz,y  ; compute effective address into X from monsiz,y
                    lda       #29       ; assume leap year
                    ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    andb      #3        ; AND B with immediate value 3
                    beq       o2ut3     ; it is a leap year
                    lda       #28       ; load A from immediate value 28
o2ut3               sta       3,x       ; fix up February in table

*
*    for (j = 0; j < *tp; ++j)             /* add day1 for months past */
*       accum += monsiz[j];
                    ldb       #1        ; load B from immediate value 1
                    bra       o2ut5     ; branch unconditionally to o2ut5

o2ut4               ldd       ,x++      ; load D from memory pointed to by X+, then advance X+
                    addd      2,s       ; add stack-relative value 2,s into D
                    std       2,s       ; store D to stack-relative value 2,s

                    ldb       4,s       ; load B from stack-relative value 4,s
                    incb                ; increment B
o2ut5               stb       4,s       ; store B to stack-relative value 4,s
                    cmpb      ,u        ; compare B against memory pointed to by U
                    blt       o2ut4     ; branch if less than to o2ut4

*
*    ++tp;
                    leau      1,u       ; compute effective address into U from 1,u

*    accum += (*tp++ - 1);                      /* add days this month */
                    ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    decb                ; decrement B
                    clra                ; clear A
                    addd      2,s       ; add stack-relative value 2,s into D
                    std       2,s       ; store D to stack-relative value 2,s

*    accum *= 24;                                  /* convert to hours */
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    addd      2,s       ; 3
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    rol       1,s       ; 6
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    rol       1,s       ; 12
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    rol       1,s       ; 24
                    std       2,s       ; store D to stack-relative value 2,s

*
*    accum += *tp++;                                /* add hours today */
                    ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    clra                ; clear A
                    addd      2,s       ; add stack-relative value 2,s into D
                    std       2,s       ; store D to stack-relative value 2,s
                    ldb       1,s       ; load B from stack-relative value 1,s
                    adcb      #0        ; add immediate value 0 into B
                    stb       1,s       ; store B to stack-relative value 1,s

*    accum *= 60;                                /* convert to minutes */
                    bsr       mul60     ; branch to subroutine to mul60
*
*    accum += *tp++;                              /* add minutes today */
                    ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    clra                ; clear A
                    addd      2,s       ; add stack-relative value 2,s into D
                    std       2,s       ; store D to stack-relative value 2,s
                    ldd       ,s        ; load D from memory pointed to by S
                    adcb      #0        ; add immediate value 0 into B
                    adca      #0        ; add immediate value 0 into A
                    std       ,s        ; store D to memory pointed to by S

*    accum *= 60;                                /* convert to seconds */
                    bsr       mul60     ; branch to subroutine to mul60

*
*    accum += *tp;                                /* add seconds today */
                    ldb       ,u+       ; load B from memory pointed to by U, then advance U
                    clra                ; clear A
                    addd      2,s       ; add stack-relative value 2,s into D
                    std       2,s       ; store D to stack-relative value 2,s
                    ldd       ,s        ; load D from memory pointed to by S
                    adcb      #0        ; add immediate value 0 into B
                    adca      #0        ; add immediate value 0 into A
                    std       ,s        ; store D to memory pointed to by S

*
* return (accum);
                    leau      ,s        ; compute effective address into U from ,s
                    ldx       10,s      ; leax  _flacc,y
                    ldd       ,u        ; load D from memory pointed to by U
                    std       ,x        ; store D to memory pointed to by X
                    ldd       2,u       ; load D from indexed value 2,u
                    std       2,x       ; store D to indexed value 2,x
                    leas      6,s       ; adjust S using 6,s
                    puls      u,pc      ; restore registers and return

*    }
mul60               ldx       2,s       ; load X from stack-relative value 2,s
                    ldd       4,s       ; load D from stack-relative value 4,s
                    bsr       shift16   ; branch to subroutine to shift16
                    bsr       shift16   ; branch to subroutine to shift16
                    addd      4,s       ; add stack-relative value 4,s into D
                    exg       d,x       ; exchange D,X
                    adcb      3,s       ; add stack-relative value 3,s into B
                    adca      2,s       ; add stack-relative value 2,s into A
                    exg       d,x       ; exchange D,X
                    stx       2,s       ; store X to stack-relative value 2,s
                    std       4,s       ; store D to stack-relative value 4,s
                    bsr       shift16   ; branch to subroutine to shift16
                    addd      4,s       ; add stack-relative value 4,s into D
                    exg       d,x       ; exchange D,X
                    adcb      3,s       ; add stack-relative value 3,s into B
                    adca      2,s       ; add stack-relative value 2,s into A
                    exg       d,x       ; exchange D,X
                    bsr       shift16   ; branch to subroutine to shift16
                    bsr       shift16   ; branch to subroutine to shift16
                    stx       2,s       ; store X to stack-relative value 2,s
                    std       4,s       ; store D to stack-relative value 4,s
                    rts                 ; return to caller

shift16             lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    exg       d,x       ; exchange D,X
                    rolb                ; rotate B left through carry
                    rola                ; rotate A left through carry
                    exg       d,x       ; exchange D,X
                    rts                 ; return to caller

* /*
* ** function to convert a 'tm' style time to os9 time
* */
*
* u2otime(otime, tmp)
* char        *otime
* struct tm   *tmp;
*    {
*    otime->t_year = tmp->tm_year;
*    otime->t_month = tmp->tm_mon;
*    otime->t_day   = tmp->tm_mday;
*    otime->t_hour  = tmp->tm_hour;
*    otime->t_minute = tmp->tm_min;
*    otime->t_second = tmp->tm_sec;
*    }
_u2otime
                    pshs      u         ; save U on the hardware stack
                    ldu       6,s       ; tmp
                    ldx       4,s       ; otime
                    leax      6,x       ; get to end
                    lda       #6        ; bytes to copy
u2o1                ldb       ,u+       ; dummy
                    ldb       ,u+       ; get data
                    stb       ,-x       ; stash away
                    deca                ; decrement A
                    bne       u2o1      ; branch if not equal to u2o1
                    puls      u,pc      ; restore registers and return

daylight            fdb       0         ; define word data 0
timezone            fdb       0,0       ; define word data 0,0
*
* struct tm *
* localtime(utime)
* long  *utime;
*    {
*    register struct tm *tmp = &_tm;
*    long  ticks = *utime;
*    int   days;
*    int   fac;
*
old_localtime
                    pshs      d,u       ; save U and allocate some scratch
                    leau      _tm,y     ; compute effective address into U from _tm,y

*    tmp->tm_sec = ticks % 60;                      /* split out seconds */
*    ticks /= 60;
                    ldx       6,s       ; point to utime
                    ldd       2,x       ; copy to local storage
                    pshs      d         ; save D on the hardware stack
                    ldd       ,x        ; load D from memory pointed to by X
                    pshs      d         ; save D on the hardware stack
                    leax      ,s        ; point to our copy
                    ldd       #60       ; load D from immediate value 60
                    bsr       div32     ; branch to subroutine to div32
                    std       ,u        ; seconds
*
*    tmp->tm_min = ticks % 60;                      /* split out minutes */
*    ticks /= 60;
                    ldd       #60       ; load D from immediate value 60
                    bsr       div32     ; branch to subroutine to div32
                    std       2,u       ; minutes
*
*    tmp->tm_hr = ticks %24;                          /* split out hours */
*    days = ticks / 24;
                    ldd       #24       ; load D from immediate value 24
                    bsr       div32     ; branch to subroutine to div32
                    std       4,u       ; hours
                    ldd       2,x       ; get days total
                    std       4,s       ; save days for later
*
*    for (tmp->tm_yr = 70; days >= 0; ++tmp->tm_yr)
*       days -= (fac = ((tmp->tm_yr & 3) ? 365 : 366));
*    tmp->tm_yr -= 1;
*    tmp->tm_yday = (days += fac);               /* adjust for overshoot */
                    ldd       #70       ; load D from immediate value 70
                    std       10,u      ; iniz the year
lt1                 leax      yrsiz,pcr ; compute effective address into X from yrsiz,pcr
                    ldb       11,u      ; get current year
                    andb      #3        ; AND B with immediate value 3
                    bne       lt2       ; branch if not equal to lt2
                    leax      2,x       ; use leap size
lt2                 ldd       4,s       ; get saved days
                    subd      ,x        ; one year worth of days
                    inc       11,u      ; bump year
                    std       4,s       ; save remainder
                    bcc       lt1       ; branch if carry is clear to lt1
                    addd      ,x        ; fix up days left
                    std       4,s       ; store D to stack-relative value 4,s
                    dec       11,u      ; unbump year
                    std       14,u      ; day of year
*
*    monsiz[2] = (tmp->tm_yr & 3) ? 28 : 29;
                    ldb       11,u      ; load B from indexed value 11,u
                    leax      monsiz,y  ; compute effective address into X from monsiz,y
                    lda       #29       ; assume leap year
                    andb      #3        ; AND B with immediate value 3
                    beq       lt3       ; branch if equal/zero to lt3
                    lda       #28       ; load A from immediate value 28
lt3                 sta       3,x       ; store A to indexed value 3,x

*    for (tmp->tm_mon = 1; days >= monsiz[tmp->tm_mon]; ++tmp->tm_mon)
*       days -= monsiz[tmp->tm_mon];
                    clra                ; clear A
                    clrb                ; clear B
                    *         ldd
                    std       8,u       ; store D to indexed value 8,u
                    ldd       4,s       ; load D from stack-relative value 4,s
lt4                 inc       9,u       ; increment indexed value 9,u
                    subd      ,x++      ; subtract memory pointed to by X+, then advance X+ from D
                    bcc       lt4       ; branch if carry is clear to lt4
                    addd      -2,x      ; add indexed value -2,x into D
                    addd      #1        ; add immediate value 1 into D
                    std       6,u       ; store D to indexed value 6,u

*    tmp->tm_wday = (days + 4) % 7;           /* extract the day of week */
                    leax      ,s        ; point to utime again
                    ldd       2,x       ; load D from indexed value 2,x
                    addd      #4        ; add immediate value 4 into D
                    std       2,x       ; store D to indexed value 2,x
                    ldd       #7        ; load D from immediate value 7
                    bsr       div32     ; branch to subroutine to div32
                    std       12,u      ; day of week
*
*    return (tmp);
                    tfr       u,d       ; transfer U,D
                    leas      6,s       ; adjust S using 6,s
                    stu       4,s       ; store U to stack-relative value 4,s
                    puls      u,pc      ; restore registers and return
* }

div32
                    clr       ,-s       ; set up remainder
                    clr       ,-s       ; and clear carry
                    pshs      d         ; dave dsor
                    ldb       #33       ; loop count
                    pshs      b         ; save B on the hardware stack
                    bra       div32b    ; branch unconditionally to div32b
div32a              ldd       3,s       ; load D from stack-relative value 3,s
                    subd      1,s       ; subtract dsor
                    bcs       div32b    ; underflow
                    std       3,s       ; update remainder
div32b              rol       3,x       ; shoft ddend
                    rol       2,x       ; rotate indexed value 2,x left through carry
                    rol       1,x       ; rotate indexed value 1,x left through carry
                    rol       ,x        ; rotate memory pointed to by X left through carry
                    rol       4,s       ; shift remainder
                    rol       3,s       ; rotate stack-relative value 3,s left through carry
                    dec       ,s        ; count off
                    bne       div32a    ; branch if not equal to div32a
                    com       3,x       ; fix up dsor
                    com       2,x
                    com       1,x
                    com       ,x
                    lsr       3,s       ; fix up remainder
                    ror       4,s       ; rotate stack-relative value 4,s right through carry
                    leas      3,s       ; clean off counter and dsor
                    puls      d,pc      ; get remainder and return

*
*
* char   *
* asctime(tmp)
* struct tm *tmp;
*    {
*    sprintf(xx, "%s %s %2d %02d:%02d:%02d %04d\n",
*       days[tmp->tm_wday], months[tmp->tm_mon - 1], tmp->tm_day,
*       tmp->tm_hr, tmp->tm_min, tmp->tm_sec, tmp->tm_yr+1900);
*    return (xx);
*    }

old_asctime         pshs      u         ; save U on the hardware stack
                    ldu       4,s       ; load U from stack-relative value 4,s
                    ldd       10,u      ; tm_yr
                    addd      #1900     ; add immediate value 1900 into D
                    pshs      d         ; save D on the hardware stack
                    ldd       ,u        ; tm_sec
                    pshs      d         ; save D on the hardware stack
                    ldd       2,u       ; tm_min
                    pshs      d         ; save D on the hardware stack
                    ldd       4,u       ; tm_hr
                    pshs      d         ; save D on the hardware stack
                    ldd       6,u       ; tm_day
                    pshs      d         ; save D on the hardware stack
                    ldd       8,u       ; tm_mon
* subd #1 fix the basing *+crk+ this needed fixed too
                    subd      #1        ; subtract immediate value 1 from D
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    leax      >months,pcr ; compute effective address into X from >months,pcr
                    leax      d,x       ; compute effective address into X from d,x
                    pshs      x         ; month string
                    ldd       12,u      ; tm_wday
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    lslb                ; shift B left by one bit
                    rola                ; rotate A left through carry
                    leax      >days,pcr ; compute effective address into X from >days,pcr
                    leax      d,x       ; compute effective address into X from d,x
                    pshs      x         ; day of week string
                    leax      >datefmt,pcr ; compute effective address into X from >datefmt,pcr
                    pshs      x         ; sprintf string spec
                    leax      _datebuf,y ; compute effective address into X from _datebuf,y
                    pshs      x         ; dest buffer
                    lbsr      _sprintf  ; long branch to subroutine to _sprintf
                    leas      18,s      ; adjust S using 18,s
                    leax      _datebuf,y ; compute effective address into X from _datebuf,y
                    tfr       x,d       ; transfer X,D
                    puls      u,pc      ; restore registers and return

*
*
* char  *
* ctime(ticks)
* long   *ticks;
*    {
*    struct tm *tmp;
*
*    return (asctime(localtime(ticks)));
*    }

old_ctime
                    ldd       2,s       ; load D from stack-relative value 2,s
                    pshs      d         ; save D on the hardware stack
                    lbsr      old_localtime ; long branch to subroutine to old_localtime
                    std       ,s        ; store D to memory pointed to by S
                    lbsr      old_asctime ; long branch to subroutine to old_asctime
                    puls      x,pc      ; restore registers and return

                    endsect             ; end current section

                    section   rodata    ; begin rodata section

yrsiz
                    fdb       365,366   ; define word data 365,366

days
                    fcc       /Sun/     ; define string data /Sun/
                    fcb       $00       ; define byte data $00
                    fcc       /Mon/     ; define string data /Mon/
                    fcb       $00       ; define byte data $00
                    fcc       /Tue/     ; define string data /Tue/
                    fcb       $00       ; define byte data $00
                    fcc       /Wed/     ; define string data /Wed/
                    fcb       $00       ; define byte data $00
                    fcc       /Thu/     ; define string data /Thu/
                    fcb       $00       ; define byte data $00
                    fcc       /Fri/     ; define string data /Fri/
                    fcb       $00       ; define byte data $00
                    fcc       /Sat/     ; define string data /Sat/
                    fcb       $00       ; define byte data $00
months
                    fcc       /Jan/     ; define string data /Jan/
                    fcb       $00       ; define byte data $00
                    fcc       /Feb/     ; define string data /Feb/
                    fcb       $00       ; define byte data $00
                    fcc       /Mar/     ; define string data /Mar/
                    fcb       $00       ; define byte data $00
                    fcc       /Apr/     ; define string data /Apr/
                    fcb       $00       ; define byte data $00
                    fcc       /May/     ; define string data /May/
                    fcb       $00       ; define byte data $00
                    fcc       /Jun/     ; define string data /Jun/
                    fcb       $00       ; define byte data $00
                    fcc       /Jul/     ; define string data /Jul/
                    fcb       $00       ; define byte data $00
                    fcc       /Aug/     ; define string data /Aug/
                    fcb       $00       ; define byte data $00
                    fcc       /Sep/     ; define string data /Sep/
                    fcb       $00       ; define byte data $00
                    fcc       /Oct/     ; define string data /Oct/
                    fcb       $00       ; define byte data $00
                    fcc       /Nov/     ; define string data /Nov/
                    fcb       $00       ; define byte data $00
                    fcc       /Dec/     ; define string data /Dec/
                    fcb       $00       ; define byte data $00

datefmt
                    fcc       /%s       ; %s %2d %02d:%02d:%02d %04d/
                    fcb       $00       ; define byte data $00

                    endsect             ; end current section
