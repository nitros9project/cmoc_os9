        section code

* global error entry point for _os_xxxx calls
_oserr  EXPORT
_oserr
        clra
_errno  EXTERNAL
        std     _errno,y
        rts

* global return entry point for _os_xxxx calls
_osret  EXPORT
_osret
        bcs     _oserr
        clra
        clrb
        rts

* global error entry point for traditional calls
_os9err EXPORT
_os9err
        clra
        std   _errno,y
        ldd   #-1
        rts

* global return entry point for traditional calls
_sysret EXPORT
_sysret
        bcs   _os9err
        clra
        clrb
        rts

        endsect

