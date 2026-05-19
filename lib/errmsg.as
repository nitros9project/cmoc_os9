                    section   code      ; begin code section

__prgname           EXTERN    ;         import current program-name helper
__iob               EXTERN    ;         import static FILE table
_fprintf            EXTERN    ;         import formatted stream output

__errmsg            EXPORT    ;         export this symbol

FILE_SIZE           equ       13        ; bytes in one FILE table entry
STDERR_INDEX        equ       2         ; stderr is _iob[2]
STDERR_OFFSET       equ       FILE_SIZE*STDERR_INDEX ; byte offset of stderr in _iob
ERRMSG_PREFIX_ARGS  equ       6         ; FILE *, format, and program name staged for fprintf()
ERRMSG_MESSAGE_ARGS equ       10        ; FILE *, format, and three copied variadic args

__errmsg:
stk_errmsg_ret      equ       0         ; caller return address
stk_errmsg_nerr     equ       2         ; OS-9 error code argument, preserved for return
stk_errmsg_msg      equ       4         ; caller's message format string
stk_errmsg_arg1     equ       6         ; first optional printf-style argument
stk_errmsg_arg2     equ       8         ; second optional printf-style argument
stk_errmsg_arg3     equ       10        ; third optional printf-style argument
                    pshs      u         ; preserve caller U while using it for format pointers
                    lbsr      __prgname ; return current program name pointer in D
                    pshs      d         ; stage program name as fprintf's first variadic argument
                    leau      errmsg_prefix,pcr ; point U at "%s: " prefix format
                    leax      __iob+STDERR_OFFSET,y ; point X at stderr FILE entry
                    pshs      x,u       ; pass stderr and prefix format to fprintf()
                    lbsr      _fprintf  ; emit "program: " prefix on stderr
                    leas      ERRMSG_PREFIX_ARGS,s ; discard prefix fprintf arguments
                    ldu       stk_errmsg_arg3+2,s ; saved U shifts caller arg3 by two bytes
                    ldx       stk_errmsg_arg2+2,s ; saved U shifts caller arg2 by two bytes
                    ldd       stk_errmsg_arg1+2,s ; saved U shifts caller arg1 by two bytes
                    pshs      d,x,u     ; copy up to three caller variadic arguments for fprintf()
                    ldu       stk_errmsg_msg+8,s ; saved U plus copied args shift format pointer
                    leax      __iob+STDERR_OFFSET,y ; point X at stderr FILE entry
                    pshs      x,u       ; pass stderr and caller message format to fprintf()
                    lbsr      _fprintf  ; emit caller's formatted error detail
                    leas      ERRMSG_MESSAGE_ARGS,s ; discard message fprintf arguments
                    ldd       stk_errmsg_nerr+2,s ; return the original error code
                    puls      u,pc      ; restore caller U and return

errmsg_prefix
* Prefix format printed before the caller's error detail.
                    fcc       "%s:      ; "
                    fcb       0         ; terminate prefix format string

                    endsect   ;         end current section
