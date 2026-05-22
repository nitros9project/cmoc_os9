                    use       ../../include/os9.d

                    section   code

_rogue_ignore_signals EXPORT
_sysret               EXTERNAL

_rogue_ignore_signals
                    pshs      u
                    ldu       #0
                    leax      ignore_signal,pcr
                    os9       F_Icpt
                    puls      u
                    lbra      _sysret

ignore_signal
                    rti

                    endsect
