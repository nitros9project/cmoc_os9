* Disassembly by Os9disasm of utime.r


__os_getime         EXTERNAL  ;         import external symbol
_flacc              EXTERNAL  ;         CMOC floating/long accumulator storage
_sprintf            EXTERNAL  ;         formatted string builder used by legacy asctime
_DEBUG              EXTERNAL  ;         debugger hook retained for legacy object compatibility

_time               EXPORT    ;         export Unix-style time() helper
_o2utime            EXPORT    ;         export OS-9 packet to Unix time conversion
_u2otime            EXPORT    ;         export struct tm to OS-9 packet conversion

                    section   bss       ; begin bss section

* Uninitialized data (class B)
_tm                 rmb       16        ; static legacy struct tm result buffer
_datebuf            rmb       26        ; static legacy asctime output buffer

                    endsection ;         end current section

                    section   rwdata    ; begin rwdata section

*
* static int   monsiz[] = {31,28,31,30,31,30,31,31,30,31,30,31};
monsiz
                    fdb       31,28,31,30,31,30,31,31,30,31,30,31 ; month lengths, February patched for leap years

                    endsect   ;         end current section

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

_time:
stk_time_ret        equ       0         ; caller return address
stk_time_result     equ       2         ; hidden CMOC long-return destination
stk_time_arg        equ       4         ; optional caller destination for returned time_t
                    pshs      u         ; preserve caller's U register
                    leas      -6,s      ; allocate local OS-9 time packet
                    leau      ,s        ; point U at local packet storage
                    pshs      u         ; pass local packet pointer to _os_getime()
                    lbsr      __os_getime ; fill local packet with current OS-9 time
                    stu       ,s        ; reuse argument slot as _o2utime packet pointer
                    ldx       stk_time_result+10,s ; load hidden long-return destination through saved/local frame
                    pshs      x         ; pass _o2utime hidden return destination
                    bsr       _o2utime  ; convert OS-9 packet to Unix seconds
                    ldu       stk_time_arg+12,s ; load optional time_t * argument after nested call frame
                    beq       noarg     ; skip store when caller passed NULL
                    ldd       ,x        ; copy high word of converted time_t
                    std       ,u        ; store high word through caller pointer
                    ldd       2,x       ; copy low word of converted time_t
                    std       2,u       ; store low word through caller pointer
noarg               leas      10,s      ; discard _o2utime args and local packet
                    puls      u,pc      ; restore U and return hidden long result


* long
* o2utime(tp)
* _os_time  *tp;
*    {
*    int   j, leap;
*    long  accum = 0;
*
* CMOC adds an extra parameter
* long o2utime(long *return, _os_time *tp)
_o2utime:
stk_o2utime_ret     equ       0         ; caller return address
stk_o2utime_result  equ       2         ; hidden CMOC long-return destination
stk_o2utime_packet  equ       4         ; source OS-9 time packet pointer
stk_o2utime_accum_high equ       0         ; high word once local accumulator is allocated
stk_o2utime_accum_high_lo equ       1         ; low byte of accumulator high word
stk_o2utime_accum_low equ       2         ; low word once local accumulator is allocated
stk_o2utime_month_counter equ       4         ; scratch month counter byte in saved-D slot
                    pshs      d,u       ; preserve working registers used during conversion
                    ldu       stk_o2utime_packet+4,s ; load source packet after saved D/U
                    clra                ; prepare zero high word of 32-bit accumulator
                    clrb                ; prepare zero low word of 32-bit accumulator
                    pshs      d         ; allocate accumulator high word
                    pshs      d         ; allocate accumulator low word

*    for (j = 70; j < *tp; ++j)         /* total up days in years past */
*       accum += ((j & 3) ? 365 : 366);     /* don't forget leap years */
                    ldb       #70-1     ; seed year counter just before epoch year 70
                    ldx       #0        ; accumulate elapsed days in X
                    bra       o2ut2     ; enter loop through counter increment

o2ut1               leax      365,x     ; add a normal year to elapsed-day count
                    bitb      #3        ; test low year bits for simple OS-9 leap-year rule
                    bne       o2ut2     ; skip leap-day adjustment for non-leap years
                    leax      1,x       ; add February 29 for leap year
o2ut2               incb                ; advance to next year offset
                    cmpb      ,u        ; compare against packet year
                    blt       o2ut1     ; continue until all prior years are counted
                    stx       stk_o2utime_accum_low,s ; store elapsed days in accumulator low word
*
*    monsiz[1] = (*tp++ & 3) ? 28 : 29;           /* fix for leap year */
                    leax      monsiz,y  ; point at mutable month-size table
                    lda       #29       ; assume February has leap-day
                    ldb       ,u+       ; consume packet year
                    andb      #3        ; apply same four-year leap test
                    beq       o2ut3     ; keep 29 days for leap year
                    lda       #28       ; otherwise use normal February length
o2ut3               sta       3,x       ; patch February entry low byte

*
*    for (j = 0; j < *tp; ++j)             /* add day1 for months past */
*       accum += monsiz[j];
                    ldb       #1        ; month counter starts at January

                    bra       o2ut5     ; test before adding first month

o2ut4               ldd       ,x++      ; fetch month length and advance table pointer
                    addd      stk_o2utime_accum_low,s ; add month length to accumulator days
                    std       stk_o2utime_accum_low,s ; keep updated day count

                    ldb       stk_o2utime_month_counter,s ; reload current month counter
                    incb                ; advance to next month
o2ut5               stb       stk_o2utime_month_counter,s ; save current month counter in scratch byte
                    cmpb      ,u        ; compare with packet month
                    blt       o2ut4     ; add each full month before target month

*
*    ++tp;
                    leau      1,u       ; skip packet month byte

*    accum += (*tp++ - 1);                      /* add days this month */
                    ldb       ,u+       ; consume day-of-month
                    decb                ; convert 1-based day to zero-based offset
                    clra                ; widen day offset to 16 bits
                    addd      stk_o2utime_accum_low,s ; add day offset to elapsed days
                    std       stk_o2utime_accum_low,s ; update accumulator low word

*    accum *= 24;                                  /* convert to hours */
                    lslb                ; multiply low word by 2
                    rola                ; propagate shift through high byte
                    addd      stk_o2utime_accum_low,s ; form days * 3
                    lslb                ; double to days * 6
                    rola                ; propagate shift through high byte
                    rol       stk_o2utime_accum_high_lo,s ; propagate carry into accumulator high word
                    lslb                ; double to days * 12
                    rola                ; propagate shift through high byte
                    rol       stk_o2utime_accum_high_lo,s ; propagate carry into accumulator high word
                    lslb                ; double to days * 24
                    rola                ; propagate shift through high byte
                    rol       stk_o2utime_accum_high_lo,s ; propagate carry into accumulator high word
                    std       stk_o2utime_accum_low,s ; store low word of elapsed hours

*
*    accum += *tp++;                                /* add hours today */
                    ldb       ,u+       ; consume packet hour
                    clra                ; widen hour to 16 bits
                    addd      stk_o2utime_accum_low,s ; add hour to elapsed hours
                    std       stk_o2utime_accum_low,s ; update accumulator low word
                    ldb       stk_o2utime_accum_high_lo,s ; reload accumulator high byte
                    adcb      #0        ; fold carry from low-word addition
                    stb       stk_o2utime_accum_high_lo,s ; store updated accumulator high byte

*    accum *= 60;                                /* convert to minutes */
                    bsr       mul60     ; scale 32-bit accumulator by 60
*
*    accum += *tp++;                              /* add minutes today */
                    ldb       ,u+       ; consume packet minutes
                    clra                ; widen minutes to 16 bits
                    addd      stk_o2utime_accum_low,s ; add minutes to accumulator low word
                    std       stk_o2utime_accum_low,s ; store updated low word
                    ldd       stk_o2utime_accum_high,s ; reload high word
                    adcb      #0        ; propagate low-word carry into high word
                    adca      #0        ; propagate carry through full high word
                    std       stk_o2utime_accum_high,s ; store updated high word

*    accum *= 60;                                /* convert to seconds */
                    bsr       mul60     ; scale 32-bit accumulator by 60

*
*    accum += *tp;                                /* add seconds today */
                    ldb       ,u+       ; consume packet seconds
                    clra                ; widen seconds to 16 bits
                    addd      stk_o2utime_accum_low,s ; add seconds to accumulator low word
                    std       stk_o2utime_accum_low,s ; store updated low word
                    ldd       stk_o2utime_accum_high,s ; reload high word
                    adcb      #0        ; propagate low-word carry into high word
                    adca      #0        ; propagate carry through full high word
                    std       stk_o2utime_accum_high,s ; store updated high word

*
* return (accum);
                    leau      stk_o2utime_accum_high,s ; point U at 32-bit accumulator
                    ldx       stk_o2utime_result+8,s ; load hidden return destination after locals
                    ldd       ,u        ; copy accumulator high word
                    std       ,x        ; store high word to return destination
                    ldd       2,u       ; copy accumulator low word
                    std       2,x       ; store low word to return destination
                    leas      6,s       ; discard accumulator and saved D
                    puls      u,pc      ; restore U and return

*    }
mul60
stk_mul60_ret       equ       0         ; return address from helper call
stk_mul60_high      equ       2         ; accumulator high word in caller frame
stk_mul60_low       equ       4         ; accumulator low word in caller frame
                    ldx       stk_mul60_high,s ; load high word into X
                    ldd       stk_mul60_low,s ; load low word into D
                    bsr       shift16   ; multiply accumulator by 2
                    bsr       shift16   ; multiply accumulator by 4
                    addd      stk_mul60_low,s ; add original low word for partial *5
                    exg       d,x       ; move high word into D for carry propagation
                    adcb      stk_mul60_high+1,s ; add original high low byte plus carry
                    adca      stk_mul60_high,s ; add original high high byte plus carry
                    exg       d,x       ; restore X:D as 32-bit accumulator
                    stx       stk_mul60_high,s ; save partial high word
                    std       stk_mul60_low,s ; save partial low word
                    bsr       shift16   ; multiply partial by 2
                    addd      stk_mul60_low,s ; add saved partial low word for *15
                    exg       d,x       ; move high word into D for carry propagation
                    adcb      stk_mul60_high+1,s ; add saved high low byte plus carry
                    adca      stk_mul60_high,s ; add saved high high byte plus carry
                    exg       d,x       ; restore X:D as 32-bit accumulator
                    bsr       shift16   ; multiply by 2
                    bsr       shift16   ; multiply by 4, yielding *60 overall
                    stx       stk_mul60_high,s ; store scaled high word
                    std       stk_mul60_low,s ; store scaled low word
                    rts                 ; return with accumulator updated in caller frame

shift16
stk_shift16_ret     equ       0         ; return address from helper call
                    lslb                ; shift low byte of low word left
                    rola                ; shift high byte of low word through carry
                    exg       d,x       ; switch to high word for carry propagation
                    rolb                ; shift low byte of high word through carry
                    rola                ; shift high byte of high word through carry
                    exg       d,x       ; restore X:D accumulator order
                    rts                 ; return one-bit left shift result

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
_u2otime:
stk_u2otime_ret     equ       0         ; caller return address
stk_u2otime_packet  equ       2         ; destination OS-9 time packet pointer
stk_u2otime_tm      equ       4         ; source struct tm pointer
                    pshs      u         ; preserve U while walking struct tm fields
                    ldu       stk_u2otime_tm+2,s ; load struct tm pointer after saved U
                    ldx       stk_u2otime_packet+2,s ; load OS-9 packet destination after saved U
                    leax      6,x       ; write destination packet from end toward start
                    lda       #6        ; copy six byte-sized fields
u2o1                ldb       ,u+       ; skip high byte of CMOC int field
                    ldb       ,u+       ; take low byte for OS-9 packet field
                    stb       ,-x       ; store packet byte in reverse field order
                    deca                ; count copied packet fields
                    bne       u2o1      ; continue until all six packet bytes are stored
                    puls      u,pc      ; restore U and return

daylight            fdb       0         ; legacy daylight-saving flag storage
timezone            fdb       0,0       ; legacy timezone offset storage
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
stk_old_localtime_ret equ       0         ; caller return address
stk_old_localtime_ticks equ       2         ; source time_t pointer
stk_old_localtime_work_high equ       0         ; local dividend high word after allocation
stk_old_localtime_work_low equ       2         ; local dividend low word after allocation
stk_old_localtime_days equ       4         ; saved remaining day count after allocation
                    pshs      d,u       ; preserve U and reserve a days scratch word
                    leau      _tm,y     ; point U at static struct tm result buffer

*    tmp->tm_sec = ticks % 60;                      /* split out seconds */
*    ticks /= 60;
                    ldx       stk_old_localtime_ticks+4,s ; load source time_t pointer after saved D/U
                    ldd       2,x       ; copy low word of input seconds
                    pshs      d         ; allocate local 32-bit dividend low word
                    ldd       ,x        ; copy high word of input seconds
                    pshs      d         ; allocate local 32-bit dividend high word
                    leax      ,s        ; point X at mutable dividend
                    ldd       #60       ; divide by seconds per minute
                    bsr       div32     ; split seconds from quotient
                    std       ,u        ; store tm_sec remainder
*
*    tmp->tm_min = ticks % 60;                      /* split out minutes */
*    ticks /= 60;
                    ldd       #60       ; divide by minutes per hour
                    bsr       div32     ; split minutes from quotient
                    std       2,u       ; store tm_min remainder
*
*    tmp->tm_hr = ticks %24;                          /* split out hours */
*    days = ticks / 24;
                    ldd       #24       ; divide by hours per day
                    bsr       div32     ; split hours from day count
                    std       4,u       ; store tm_hour remainder
                    ldd       2,x       ; load remaining day count
                    std       stk_old_localtime_days,s ; save days in scratch word
*
*    for (tmp->tm_yr = 70; days >= 0; ++tmp->tm_yr)
*       days -= (fac = ((tmp->tm_yr & 3) ? 365 : 366));
*    tmp->tm_yr -= 1;
*    tmp->tm_yday = (days += fac);               /* adjust for overshoot */
                    ldd       #70       ; initialize tm_year to Unix epoch year offset
                    std       10,u      ; store candidate year
lt1                 leax      yrsiz,pcr ; point at normal/leap year lengths
                    ldb       11,u      ; inspect low byte of current year offset
                    andb      #3        ; apply simple four-year leap test
                    bne       lt2       ; use normal year size when not divisible by four
                    leax      2,x       ; select leap-year size
lt2                 ldd       stk_old_localtime_days,s ; reload remaining day count
                    subd      ,x        ; subtract one candidate year
                    inc       11,u      ; advance candidate year
                    std       stk_old_localtime_days,s ; save remaining day count
                    bcc       lt1       ; keep subtracting while days do not underflow
                    addd      ,x        ; undo final overshoot
                    std       stk_old_localtime_days,s ; keep day-of-year value
                    dec       11,u      ; restore actual year
                    std       14,u      ; store tm_yday
*
*    monsiz[2] = (tmp->tm_yr & 3) ? 28 : 29;
                    ldb       11,u      ; reload final year offset
                    leax      monsiz,y  ; point at mutable month-size table
                    lda       #29       ; assume leap year
                    andb      #3        ; apply simple four-year leap test
                    beq       lt3       ; keep February at 29 days for leap year
                    lda       #28       ; otherwise use normal February length
lt3                 sta       3,x       ; patch February entry low byte

*    for (tmp->tm_mon = 1; days >= monsiz[tmp->tm_mon]; ++tmp->tm_mon)
*       days -= monsiz[tmp->tm_mon];
                    clra                ; initialize month field high byte
                    clrb                ; initialize month field low byte
                    *         ldd
                    std       8,u       ; start tm_mon at zero
                    ldd       stk_old_localtime_days,s ; load remaining days in current year
lt4                 inc       9,u       ; advance month number
                    subd      ,x++      ; subtract current month length
                    bcc       lt4       ; continue until month subtraction underflows
                    addd      -2,x      ; restore days within final month
                    addd      #1        ; convert zero-based day to 1-based day-of-month
                    std       6,u       ; store tm_mday

*    tmp->tm_wday = (days + 4) % 7;           /* extract the day of week */
                    leax      stk_old_localtime_work_high,s ; point X at local dividend storage
                    ldd       2,x       ; load total day count
                    addd      #4        ; offset because epoch day was Thursday
                    std       2,x       ; store dividend for modulo seven
                    ldd       #7        ; divide by days per week
                    bsr       div32     ; get weekday remainder
                    std       12,u      ; store tm_wday
*
*    return (tmp);
                    tfr       u,d       ; return static struct tm pointer in D
                    leas      6,s       ; discard local dividend and days scratch
                    stu       stk_old_localtime_days,s ; preserve return pointer through U restore slot
                    puls      u,pc      ; restore U and return
* }

div32
stk_div32_ret       equ       0         ; return address from helper call
stk_div32_dividend  equ       2         ; caller's mutable 32-bit dividend pointer in X
stk_div32_count     equ       0         ; loop counter after local division frame allocation
stk_div32_divisor   equ       1         ; 16-bit divisor after local division frame allocation
stk_div32_remainder equ       3         ; 16-bit remainder after local division frame allocation
stk_div32_remainder_low equ       4         ; low byte of remainder after allocation
                    clr       ,-s       ; allocate and clear remainder low byte
                    clr       ,-s       ; allocate and clear remainder high byte
                    pshs      d         ; save 16-bit divisor
                    ldb       #33       ; run one extra shift to finish quotient/remainder
                    pshs      b         ; allocate loop counter
                    bra       div32b    ; enter division loop with initial shift
div32a              ldd       stk_div32_remainder,s ; load current 16-bit remainder
                    subd      stk_div32_divisor,s ; try subtracting divisor
                    bcs       div32b    ; leave quotient bit clear on underflow
                    std       stk_div32_remainder,s ; keep reduced remainder and set quotient bit via carry state
div32b              rol       3,x       ; shift dividend/quotient low byte through carry
                    rol       2,x       ; shift next dividend byte through carry
                    rol       1,x       ; shift next dividend byte through carry
                    rol       ,x        ; shift high dividend byte through carry
                    rol       stk_div32_remainder_low,s ; shift remainder low byte through carry
                    rol       stk_div32_remainder,s ; shift remainder high byte through carry
                    dec       stk_div32_count,s ; consume one division bit
                    bne       div32a    ; continue until all quotient bits are produced
                    com       3,x       ; convert quotient bits into final quotient
                    com       2,x       ; complement quotient byte
                    com       1,x       ; complement quotient byte
                    com       ,x        ; complement quotient high byte
                    lsr       stk_div32_remainder,s ; align remainder high byte
                    ror       stk_div32_remainder_low,s ; align remainder low byte
                    leas      3,s       ; discard counter and divisor
                    puls      d,pc      ; return remainder in D

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

old_asctime
stk_old_asctime_ret equ       0         ; caller return address
stk_old_asctime_tm  equ       2         ; source struct tm pointer
                    pshs      u         ; preserve U while staging sprintf arguments
                    ldu       stk_old_asctime_tm+2,s ; load struct tm pointer after saved U
                    ldd       10,u      ; load tm_year
                    addd      #1900     ; convert year offset to full calendar year
                    pshs      d         ; push sprintf year argument
                    ldd       ,u        ; load tm_sec
                    pshs      d         ; push sprintf seconds argument
                    ldd       2,u       ; load tm_min
                    pshs      d         ; push sprintf minutes argument
                    ldd       4,u       ; load tm_hour
                    pshs      d         ; push sprintf hours argument
                    ldd       6,u       ; load tm_mday
                    pshs      d         ; push sprintf day-of-month argument
                    ldd       8,u       ; load tm_mon
* subd #1 fix the basing *+crk+ this needed fixed too
                    subd      #1        ; convert one-based month to zero-based table index
                    lslb                ; multiply month index by two
                    rola                ; propagate shift through high byte
                    lslb                ; multiply month index by four-byte string slot
                    rola                ; propagate shift through high byte
                    leax      >months,pcr ; point at month-name table
                    leax      d,x       ; select month string
                    pshs      x         ; push sprintf month string argument
                    ldd       12,u      ; load tm_wday
                    lslb                ; multiply weekday index by two
                    rola                ; propagate shift through high byte
                    lslb                ; multiply weekday index by four-byte string slot
                    rola                ; propagate shift through high byte
                    leax      >days,pcr ; point at weekday-name table
                    leax      d,x       ; select weekday string
                    pshs      x         ; push sprintf weekday string argument
                    leax      >datefmt,pcr ; load legacy format string
                    pshs      x         ; push sprintf format argument
                    leax      _datebuf,y ; load static output buffer
                    pshs      x         ; push sprintf destination argument
                    lbsr      _sprintf  ; build formatted date string
                    leas      18,s      ; discard nine 2-byte sprintf arguments
                    leax      _datebuf,y ; return static date buffer
                    tfr       x,d       ; place return pointer in D
                    puls      u,pc      ; restore U and return

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
stk_old_ctime_ret   equ       0         ; caller return address
stk_old_ctime_ticks equ       2         ; source time_t pointer
                    ldd       stk_old_ctime_ticks,s ; load source time_t pointer
                    pshs      d         ; pass ticks pointer to legacy localtime helper
                    lbsr      old_localtime ; convert ticks to static struct tm
                    std       ,s        ; replace argument with returned struct tm pointer
                    lbsr      old_asctime ; format static struct tm into date string
                    puls      x,pc      ; discard argument and return date string pointer

                    endsect   ;         end current section

                    section   rodata    ; begin rodata section

yrsiz
                    fdb       365,366   ; normal and leap-year day counts

days
                    fcc       /Sun/     ; weekday name slot 0
                    fcb       $00       ; terminate weekday name
                    fcc       /Mon/     ; weekday name slot 1
                    fcb       $00       ; terminate weekday name
                    fcc       /Tue/     ; weekday name slot 2
                    fcb       $00       ; terminate weekday name
                    fcc       /Wed/     ; weekday name slot 3
                    fcb       $00       ; terminate weekday name
                    fcc       /Thu/     ; weekday name slot 4
                    fcb       $00       ; terminate weekday name
                    fcc       /Fri/     ; weekday name slot 5
                    fcb       $00       ; terminate weekday name
                    fcc       /Sat/     ; weekday name slot 6
                    fcb       $00       ; terminate weekday name
months
                    fcc       /Jan/     ; month name slot 1
                    fcb       $00       ; terminate month name
                    fcc       /Feb/     ; month name slot 2
                    fcb       $00       ; terminate month name
                    fcc       /Mar/     ; month name slot 3
                    fcb       $00       ; terminate month name
                    fcc       /Apr/     ; month name slot 4
                    fcb       $00       ; terminate month name
                    fcc       /May/     ; month name slot 5
                    fcb       $00       ; terminate month name
                    fcc       /Jun/     ; month name slot 6
                    fcb       $00       ; terminate month name
                    fcc       /Jul/     ; month name slot 7
                    fcb       $00       ; terminate month name
                    fcc       /Aug/     ; month name slot 8
                    fcb       $00       ; terminate month name
                    fcc       /Sep/     ; month name slot 9
                    fcb       $00       ; terminate month name
                    fcc       /Oct/     ; month name slot 10
                    fcb       $00       ; terminate month name
                    fcc       /Nov/     ; month name slot 11
                    fcb       $00       ; terminate month name
                    fcc       /Dec/     ; month name slot 12
                    fcb       $00       ; terminate month name

datefmt
                    fcc       /%s       ; %s %2d %02d:%02d:%02d %04d/
                    fcb       $00       ; terminate legacy asctime format string

                    endsect   ;         end current section
