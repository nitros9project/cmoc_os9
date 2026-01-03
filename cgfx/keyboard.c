#include <cgfx.h>

asm error_code
_cgfx_ss_ssig(path_id path, int signo)
{
    asm
    {
_sysret	EXTERNAL
		ldx		2+2,s		get signal number
		lda		2+1,s		get path
		ldb		#SS_SSig
		os9		I$SetStt
os9err0
		lbra	_sysret
	}
}

