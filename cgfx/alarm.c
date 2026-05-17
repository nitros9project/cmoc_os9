#include <cgfx.h>
#include <os.h>

/************************************
 * Alarm Functions                  *
 * Copyright (c) 1989 by Mike Sweet *
 ************************************/

asm error_code
_cgfx_alarm_set(void *time_buffer)
{
    asm
    {
_sysret EXTERNAL
_os9err EXTERNAL
        ldx 2,s
        ldd #1
        os9 F$Alarm
        lbcs _os9err
        lbra _sysret
    }
}

asm error_code
_cgfx_alarm_get(void *time_buffer)
{
    asm
    {
_sysret EXTERNAL
_os9err EXTERNAL
        ldx 2,s
        ldd #2
        os9 F$Alarm
        lbcs _os9err
        lbra _sysret
    }
}

asm error_code
_cgfx_alarm_clear(void)
{
    asm
    {
_sysret EXTERNAL
_os9err EXTERNAL
        clra
        clrb
        os9 F$Alarm
        lbcs _os9err
        lbra _sysret
    }
}

asm error_code
_cgfx_alarm_signal(void *time_buffer, int signo)
{
    asm
    {
_sysret EXTERNAL
_os9err EXTERNAL
        pshs y
        os9 F$ID
        puls y
        lbcs _os9err
        ldx 2,s
        ldb 5,s
        os9 F$Alarm
        lbcs _os9err
        lbra _sysret
    }
}
