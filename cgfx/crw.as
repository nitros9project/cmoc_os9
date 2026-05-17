* Adapted from cmoc_os9/cgfx/todo/crw.a for the live cmoc_os9 ABI.

        section code

_cread                  EXPORT * export this symbol
_creadln                EXPORT * export this symbol
_cwrite                 EXPORT * export this symbol
_cwriteln               EXPORT * export this symbol

_errno                  EXTERNAL * import external symbol
_Flush                  EXTERNAL * import external symbol
_strlen                 EXTERNAL * import external symbol
_write                  EXTERNAL * import external symbol

_cread
        lbsr    _Flush * flush any pending buffered output before blocking for input
        pshs    y
        lda     5,s * load the input path number
        ldy     8,s * load the maximum byte count for the read
        ldx     6,s * load the caller's destination buffer
        os9     $8B * perform an OS-9 read into the caller's buffer
        bcs     os9err * branch to the shared errno path if OS-9 reports an error
        leay    -1,y * convert the returned byte count to the index of the last byte read
        ldx     6,s * reload the caller's destination buffer
        tfr     y,d * copy the final-byte index into D for address arithmetic
        leax    d,x * point X at the last byte that OS-9 stored
        lda     ,x * load the last character that was read
        cmpa    #13 * test whether the last character is a carriage return
        beq     cread_null * branch if equal/zero to cread_null
        leax    1,x * advance past the last character when no CR stripping is needed
cread_null
        clr     ,x * append a NUL terminator after the returned text
        tfr     y,d * return the character count in D
        puls    y,pc

_creadln
        lbsr    _Flush * flush any pending buffered output before blocking for input
        pshs    y
        lda     5,s * load the input path number
        ldy     8,s * load the maximum byte count for the read
        ldx     6,s * load the caller's destination buffer
        os9     $8B * perform an OS-9 read into the caller's buffer
        bcs     os9err * branch to the shared errno path if OS-9 reports an error
        ldx     6,s * reload the caller's destination buffer
        tfr     y,d * copy the returned byte count into D
        clr     d,x * append a NUL terminator after the received line
        puls    y,pc

os9err
        puls    y
        clra * clear A
        std     _errno,y * preserve the OS-9 error code in errno
        ldd     #-1 * load D from immediate value -1
        rts * return to caller

_cwrite
        pshs    u
        ldx     6,s * load the caller's string pointer
        pshs    x
        lbsr    _strlen * measure the string length before writing it
        leas    2,s * discard the temporary _strlen argument
        cmpd    8,s * compare the string length against the caller's maximum count
        blo     cwrite_len_ok * keep the string length when it is already within the limit
        ldd     8,s * clamp the write length to the caller-supplied maximum
cwrite_len_ok
        tfr     d,u * move the chosen write length into U for _write
        pshs    u
        ldx     8,s * reload the string pointer
        lda     7,s * load the output path number
        lbsr    _write * send the bounded byte count through the buffered writer
        bcs     os9err2 * branch if the write helper returned an error
        puls    d,u,pc * discard the saved length and return the byte count in D

os9err2
        clra * clear A
        std     _errno,y * preserve the write error code in errno
        leas    2,s * discard the saved write length before returning
        ldd     #-1 * load D from immediate value -1
        puls    u,pc

_cwriteln
        lbsr    _Flush * flush any pending buffered output before issuing writeln
        pshs    y
        ldx     6,s * load the caller's string pointer
        pshs    x
        lbsr    _strlen * measure the string length before writing it with a newline
        leas    2,s * discard the temporary _strlen argument
        cmpd    8,s * compare the string length against the caller's maximum count
        blo     cwriteln_len_ok * keep the string length when it already fits
        ldd     8,s * clamp the output length to the caller-supplied maximum
cwriteln_len_ok
        tfr     d,y * move the bounded output length into Y for OS-9 writeln
        ldx     6,s * reload the string pointer
        lda     5,s * load the output path number
        os9     $8C * write the string followed by a carriage return/newline
        bcs     os9err * branch to the shared errno path if OS-9 reports an error
        tfr     y,d * return the number of characters written in D
        puls    y,pc

        endsect * end current section
