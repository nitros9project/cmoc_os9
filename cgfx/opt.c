#include <cgfx.h>


asm error_code
_cgfx_ss_opt(path_id path, const SCF_OPT *opts)
{
    asm
    {
_sysret EXTERNAL
		pshs 	y
		ldx		2+2+2,s		get options
		lda		2+2+1,s		get path
		ldb		#SS_Opt
		os9		I$SetStt
        puls    y

os9err0 lbra	_sysret
	}
}

asm error_code
_cgfx_gs_opt(path_id path, SCF_OPT *opts)
{
    asm
    {
		pshs 	y
		ldx		2+2+2,s		get signal number
		lda		2+2+1,s		get path
		ldb 	#SS_Opt
		os9 	I$GetStt
		puls	y
		bra 	os9err0
	}
}