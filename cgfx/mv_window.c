#include <cgfx.h>

asm error_code
_cgfx_ss_wnset(path_id path, int wintype, WNDSCR *windat)
{
    asm
    {
_Flush	EXTERNAL
		pshs	y
		lbsr	_Flush
		lda		2+2+1,s			get path
		ldb		#SS_WnSet
		ldx		2+2+4,s			get WNDSCR ptr
		ldy		2+2+2,s			get window type
		os9		I$SetStt
		puls	y
		bra		os9err0
	}
}

asm error_code
_cgfx_gs_mnsel(path_id path, int *itemno, int *menuid)
{
    asm
    {
		lda		2+1,s			get path
		ldb		#SS_MnSel
		os9		I$GetStt
		bcs		os9err0
		pshs	a
		clra
		std		[2+1+2,s]		save into item no pointer
		puls	b
		std		[2+4,s]			save into menu id pointer
	}
}

asm error_code
_cgfx_ss_umbar(path_id path)
{
    asm
    {
_sysret	EXTERNAL
		lda		2+1,s			get path
		ldb		#SS_UMBar
		os9		I$SetStt
os9err0	lbra	_sysret
	}
}

asm error_code
_cgfx_ss_sbar(path_id path, int horbar, int verbar)
{
    asm
    {
		pshs	y
		lda		2+2+1,s		get path
		ldx		2+2+2,s		get horizontal bar
		ldy		2+2+4,s		get veritcal bar
		ldb		#SS_SBar
		os9		I$SetStt
		puls	y
		bra 	os9err0
	}
}
