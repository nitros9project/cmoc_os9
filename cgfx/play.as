* Adapted from cmoc_os9/cgfx/todo/play.a for the live cmoc_os9 ABI.

        section bss
_play_tempo             rmb     1 * reserve 1 bytes
_play_length            rmb     1 * reserve 1 bytes
_play_dots              rmb     1 * reserve 1 bytes
_play_style             rmb     1 * reserve 1 bytes
_play_octave            rmb     1 * reserve 1 bytes
_play_volume            rmb     1 * reserve 1 bytes
_play_remainder         rmb     2 * reserve 2 bytes
_play_curdots           rmb     1 * reserve 1 bytes
_play_path              rmb     1 * reserve 1 bytes
_play_strings           rmb     2 * reserve 2 bytes
        endsect * end current section

        section code

_Play                   EXPORT * export this symbol

_Flush                  EXTERNAL * import external symbol
_cgfx_write             EXTERNAL * import external symbol

_play_notes
        fdb     3038,2871,2707,2554,2411,2273,2150,2027,1914,1806,1704,1610 * define word data 3038,2871,2707,2554,2411,2273,2150,2027,1914,1806,1704,1610
_play_notetbl
        fcb     9,11,0,2,4,5,7 * define byte data 9,11,0,2,4,5,7

_Play
        pshs    u
        lbsr    _Flush * flush pending screen or sound output before starting playback
        lda     #100 * load the default tempo
        sta     _play_tempo,y * store the initial tempo for this score
        lda     #4 * load the default note length
        sta     _play_length,y * store the initial note length
        clr     _play_dots,y * clear the default dotted-note count
        clr     _play_style,y * clear the articulation style to normal
        lda     #3 * load the default octave
        sta     _play_octave,y * store the initial octave
        lda     #32 * load the default volume
        sta     _play_volume,y * store the initial volume
        clr     _play_remainder,y * clear the low byte of the note-length remainder accumulator
        clr     _play_remainder+1,y * clear the high byte of the note-length remainder accumulator
        lda     5,s * load the destination path for note output
        sta     _play_path,y * remember the active output path
        leax    6,s * point at the caller's string-vector argument list
        stx     _play_strings,y * remember the current %S/%D string-expansion cursor
        ldx     ,x * load the first music-string pointer
        leau    _play_notetbl,pcr * point U at the note-name to semitone lookup table
        bsr     parse * parse and play the first music string
        puls    u,pc

parse   lda     ,x+ * fetch the next command character from the score string
        cmpa    #$20 * compare A against immediate value $20
        beq     parse * ignore spaces between music tokens
        cmpa    #$3b * compare A against immediate value $3b
        beq     parse * ignore semicolon separators
        cmpa    #$5f * compare A against immediate value $5f
        bls     p00 * keep ASCII punctuation and digits unchanged
        anda    #$5f * fold lowercase note commands to uppercase

p00     cmpa    #$41 * compare A against immediate value $41
        blo     p10
        cmpa    #$47 * compare A against immediate value $47
        bhi     p10 * branch when the token is not a note letter
        suba    #$41 * convert A-G into a zero-based note index
        lda     a,u * translate the note letter through the semitone lookup table
        pshs    a
p01     lda     ,x+ * fetch the next modifier after the note letter
        cmpa    #$2f * compare A against immediate value $2f
        bhi     p03 * stop treating punctuation as accidental/octave modifiers
        cmpa    #$2d * compare A against immediate value $2d
        bne     p02
        dec     ,s * flatten the current note by one semitone
        bra     p01 * keep scanning note modifiers
p02     anda    #$03 * AND A with immediate value $03
        cmpa    #3 * compare A against immediate value 3
        bne     p05
        inc     ,s * sharpen the current note by one semitone
        bra     p01 * keep scanning note modifiers
p03     cmpa    #$3c * compare A against immediate value $3c
        bne     p04
        lda     ,s * load A from memory pointed to by S
        suba    #12 * transpose the note down one octave
        sta     ,s * store the transposed note value back on the stack
        bra     p01
p04     cmpa    #$3e * compare A against immediate value $3e
        bne     p05
        lda     ,s * load A from memory pointed to by S
        adda    #12 * transpose the note up one octave
        sta     ,s * store the transposed note value back on the stack
        bra     p01
p05     leax    -1,x * push the non-modifier character back for the next parser stage
        ldb     _play_dots,y * load the default dotted-note count
        stb     _play_curdots,y * copy the default dots into the current-note state
        ldb     _play_length,y * load the default note length
        cmpa    #$30 * compare A against immediate value $30
        blo     p08
        cmpa    #$39 * compare A against immediate value $39
        bhi     p08 * branch when no explicit note length follows
        clr     _play_curdots,y * explicit note lengths reset the dotted-note count
        lbsr    getnum * parse the explicit note length into B
p06     lda     ,x+ * scan for trailing dots after an explicit note length
        cmpa    #$2e * compare A against immediate value $2e
        bne     p07
        inc     _play_curdots,y * add one dotted-note extension
        bra     p06
p07     leax    -1,x * push the first non-dot character back into the stream
p08     puls    a * recover the final semitone value for the note
        lbsr    playnote * synthesize the note using the current tempo, octave, and style
        bra     parse * continue parsing the rest of the score

p10     cmpa    #$25 * compare A against immediate value $25
        bne     p20
        lda     ,x+ * load A from memory pointed to by X, then advance X
        anda    #$5f * AND A with immediate value $5f
        cmpa    #$53 * compare A against immediate value $53
        lbne    parse
        pshs    x
        ldx     _play_strings,y * load X from indexed value _play_strings,y
        leax    2,x * compute effective address into X from 2,x
        stx     _play_strings,y * store X to indexed value _play_strings,y
        ldx     ,x * load X from memory pointed to by X
        lbsr    parse
        puls    x
        lbra    parse

p20     cmpa    #$54 * compare A against immediate value $54
        bne     p30
        ldb     _play_tempo,y * load B from indexed value _play_tempo,y
        lbsr    getnum
        stb     _play_tempo,y * store B to indexed value _play_tempo,y
        lbra    parse

p30     cmpa    #$4c * compare A against immediate value $4c
        bne     p40
        ldb     _play_length,y * load B from indexed value _play_length,y
        lbsr    getnum
        stb     _play_length,y * store B to indexed value _play_length,y
        clr     _play_dots,y * clear indexed value _play_dots,y
p31     lda     ,x+ * load A from memory pointed to by X, then advance X
        cmpa    #$2e * compare A against immediate value $2e
        bne     p32
        inc     _play_dots,y * increment indexed value _play_dots,y
        bra     p31
p32     leax    -1,x * compute effective address into X from -1,x
        lbra    parse

p40     cmpa    #$4f * compare A against immediate value $4f
        bne     p50
        ldb     _play_octave,y * load B from indexed value _play_octave,y
        lbsr    getnum
        stb     _play_octave,y * store B to indexed value _play_octave,y
        lbra    parse

p50     cmpa    #$56 * compare A against immediate value $56
        bne     p60
        ldb     _play_volume,y * load B from indexed value _play_volume,y
        bsr     getnum
        stb     _play_volume,y * store B to indexed value _play_volume,y
        lbra    parse

p60     cmpa    #$50 * compare A against immediate value $50
        bne     p70
        ldb     _play_dots,y * load B from indexed value _play_dots,y
        stb     _play_curdots,y * store B to indexed value _play_curdots,y
        ldb     _play_length,y * load B from indexed value _play_length,y
        lda     ,x+ * load A from memory pointed to by X, then advance X
        cmpa    #$30 * compare A against immediate value $30
        blo     p62
        cmpa    #$39 * compare A against immediate value $39
        bhi     p62
        bsr     getnum
        clr     _play_curdots,y * clear indexed value _play_curdots,y
p61     cmpa    #$2e * compare A against immediate value $2e
        bne     p62
        inc     _play_curdots,y * increment indexed value _play_curdots,y
        lda     ,x+ * load A from memory pointed to by X, then advance X
        bra     p61
p62     leax    -1,x * compute effective address into X from -1,x
        lbsr    playrest
        lbra    parse

p70     cmpa    #$5d * compare A against immediate value $5d
        bne     prts
        lda     ,x+ * load A from memory pointed to by X, then advance X
        anda    #$5f * AND A with immediate value $5f
        cmpa    #$53 * compare A against immediate value $53
        bne     p71
        lda     #-1 * load A from immediate value -1
        sta     _play_style,y * store A to indexed value _play_style,y
        lbra    parse
p71     cmpa    #$4e * compare A against immediate value $4e
        bne     p72
        clr     _play_style,y * clear indexed value _play_style,y
        lbra    parse
p72     cmpa    #$4c * compare A against immediate value $4c
        lbne    parse
        lda     #1 * load A from immediate value 1
        sta     _play_style,y * store A to indexed value _play_style,y
        lbra    parse

prts    rts * return to caller

getnum  lda     ,x+ * load A from memory pointed to by X, then advance X
        cmpa    #$20 * compare A against immediate value $20
        beq     getnum
        cmpa    #$30 * compare A against immediate value $30
        blo     g00
        cmpa    #$39 * compare A against immediate value $39
        bhi     g00
        suba    #$30 * subtract immediate value $30 from A
        tfr     a,b
gloop0  lda     ,x+ * load A from memory pointed to by X, then advance X
        cmpa    #$30 * compare A against immediate value $30
        blo     gnext0
        cmpa    #$39 * compare A against immediate value $39
        bhi     gnext0
        suba    #$30 * subtract immediate value $30 from A
        pshs    a
        lda     #10 * load A from immediate value 10
        mul * multiply A by B and leave the product in D
        addb    ,s+ * add memory pointed to by S, then advance S into B
        bra     gloop0
gnext0  leax    -1,x * compute effective address into X from -1,x
grts    rts * return to caller

g00     cmpa    #$25 * compare A against immediate value $25
        bne     g10
        lda     ,x+ * load A from memory pointed to by X, then advance X
        anda    #$5f * AND A with immediate value $5f
        cmpa    #$44 * compare A against immediate value $44
        bne     g01
        pshs    x
        ldx     _play_strings,y * load X from indexed value _play_strings,y
        leax    2,x * compute effective address into X from 2,x
        ldd     ,x * load D from memory pointed to by X
        stx     _play_strings,y * store X to indexed value _play_strings,y
        puls    x,pc
g01     cmpa    #$53 * compare A against immediate value $53
        bne     grts
        pshs    x
        ldx     _play_strings,y * load X from indexed value _play_strings,y
        leax    2,x * compute effective address into X from 2,x
        stx     _play_strings,y * store X to indexed value _play_strings,y
        ldx     ,x * load X from memory pointed to by X
        bsr     getnum
        puls    x,pc

g10     cmpa    #$2b * compare A against immediate value $2b
        bne     g20
        incb * increment B
        bra     getnum

g20     cmpa    #$2d * compare A against immediate value $2d
        bne     g30
        decb * decrement B
        bra     getnum

g30     cmpa    #$3c * compare A against immediate value $3c
        bne     g40
        lsrb * logical shift B right by one bit
        bra     getnum

g40     cmpa    #$3e * compare A against immediate value $3e
        bne     gnext0
        lslb * shift B left by one bit
        bra     getnum

calctime
        inc     _play_curdots,y * increment indexed value _play_curdots,y
        lda     _play_tempo,y * load A from indexed value _play_tempo,y
        mul * multiply A by B and leave the product in D
        pshs    d
        ldd     #14400 * load D from immediate value 14400
        addd    _play_remainder,y * add indexed value _play_remainder,y into D
        pshs    d
cloop0  dec     _play_curdots,y * decrement indexed value _play_curdots,y
        bmi     cnext0
        lslb * shift B left by one bit
        rola * rotate A left through carry
        lsl     3,s * shift stack-relative value 3,s left by one bit
        rol     2,s * rotate stack-relative value 2,s left through carry
        bra     cloop0
cnext0  subd    ,s++ * subtract memory pointed to by S+, then advance S+ from D
        ldx     #0 * load X from immediate value 0
cloop1  subd    ,s * subtract memory pointed to by S from D
        bmi     cnext1
        leax    1,x * compute effective address into X from 1,x
        bra     cloop1
cnext1  addd    ,s++ * add memory pointed to by S+, then advance S+ into D
        std     _play_remainder,y * store D to indexed value _play_remainder,y
        rts * return to caller

playnote
        tst     _play_volume,y * test indexed value _play_volume,y and update condition codes
        lbeq    playrest
        pshs    a,x,y
        bsr     calctime
        puls    a
        cmpx    #0 * compare X against immediate value 0
        beq     playret
        ldb     _play_octave,y * load B from indexed value _play_octave,y
        leau    _play_notes,pcr * compute effective address into U from _play_notes,pcr
ploop0  cmpa    #0 * compare A against immediate value 0
        bge     ploop1
        adda    #12 * add immediate value 12 into A
        decb * decrement B
        bra     ploop0
ploop1  cmpa    #12 * compare A against immediate value 12
        blt     pnext1
        suba    #12 * subtract immediate value 12 from A
        incb * increment B
        bra     ploop1
pnext1  lsla * shift A left by one bit
        pshs    b
        suba    #24 * subtract immediate value 24 from A
        ldd     a,u
ploop2  dec     ,s * decrement memory pointed to by S
        bmi     pnext2
        lsra * logical shift A right by one bit
        rorb * rotate B right through carry
        bra     ploop2
pnext2  coma
        comb
        addd    #4097 * add immediate value 4097 into D
        std     ,-s * store D to memory pointed to by -S
        pshs    x
        lda     _play_volume,y * load A from indexed value _play_volume,y
        sta     0,s * store A to stack-relative value 0,s
        ldb     1,s * load B from stack-relative value 1,s
        tst     _play_style,y * test indexed value _play_style,y and update condition codes
        bmi     playstac
        bgt     playleg
playnorm
        lsrb * logical shift B right by one bit
        lsrb * logical shift B right by one bit
        lsrb * logical shift B right by one bit
        pshs    b
        beq     playit
        clra * clear A
        tfr     d,x
        os9     $0A * invoke OS-9 system call $0A
        bra     playit

playstac
        lsrb * logical shift B right by one bit
        lsrb * logical shift B right by one bit
        pshs    b
        beq     playit
        clra * clear A
        tfr     d,x
        os9     $0A * invoke OS-9 system call $0A
        bra     playit

playleg clr     ,-s * clear memory pointed to by -S

playit  puls    b * restore B from the hardware stack
        negb * negate B
        addb    1,s * add stack-relative value 1,s into B
        stb     1,s * store B to stack-relative value 1,s
        lda     _play_path,y * load A from indexed value _play_path,y
        puls    x,y
        ldb     #$98 * load B from immediate value $98
        os9     $8D * invoke OS-9 system call $8D

playret puls    x,y,pc * restore registers and return

playrest
        pshs    x
        lbsr    calctime
        cmpx    #0 * compare X against immediate value 0
        beq     playret2
        os9     $0A * invoke OS-9 system call $0A
playret2
        puls    x,pc

        endsect * end current section
