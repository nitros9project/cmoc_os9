#ifndef _ERRNO_H
#define _ERRNO_H

#include <os9abi.h>

extern int errno;

#define E_DCD       0x80

#define E_IWNTYP    0xb7
#define E_WNDEF     0xb8
#define E_FNTNFD    0xb9
#define E_STKOVF    0xba
#define E_ILLARG    0xbb
#define E_ILCOOR    0xbd
#define E_INTGCK    0xbe
#define E_BUFSML    0xbf
#define E_ILLCMD    0xc0
#define E_WINFUL    0xc1
#define E_BADBUF    0xc2
#define E_ILWNDF    0xc3

#define E_PTHFUL    E$PthFul
#define E_BPNUM     E$BPNum
#define E_POLL      E$Poll
#define E_BMODE     E$BMode
#define E_DEVOVF    E$DevOvf
#define E_BMID      E$BMID
#define E_DIRFUL    E$DirFul
#define E_MEMFUL    E$MemFul
#define E_UNKSVC    E$UnkSvc
#define E_MODBSY    E$ModBsy
#define E_BPADDR    E$BPAddr
#define E_EOF       E$EOF
#define E_NES       E$NES
#define E_FNA       E$FNA
#define E_BPNAM     E$BPNam
#define E_PNNF      E$PNNF
#define E_SLF       E$SLF
#define E_CEF       E$CEF
#define E_IBA       E$IBA
#define E_HANGUP    E$HangUp
#define E_MNF       E$MNF
#define E_DELSP     E$DelSP
#define E_IPRCID    E$IPrcID
#define E_NOCHLD    E$NoChld
#define E_ISWI      E$ISWI
#define E_PRCABT    E$PrcAbt
#define E_PRCFUL    E$PrcFul
#define E_IFORKP    E$IForkP
#define E_KWNMOD    E$KwnMod
#define E_BMCRC     E$BMCRC
#define E_USIGP     E$USigP
#define E_NEMOD     E$NEMod
#define E_BNAM      E$BNam
#define E_BMHP      E$BMHP
#define E_NORAM     E$NoRAM
#define E_BPRCID    E$DNE
#define E_NOTASK    E$NoTask
#define E_UNIT      E$Unit
#define E_SECT      E$Sect
#define E_WP        E$WP
#define E_CRC       E$CRC
#define E_READ      E$Read
#define E_WRITE     E$Write
#define E_NOTRDY    E$NotRdy
#define E_SEEK      E$Seek
#define E_FULL      E$Full
#define E_BTYP      E$BTyp
#define E_DEVBSY    E$DevBsy
#define E_DIDC      E$DIDC
#define E_LOCK      E$Lock
#define E_SHARE     E$Share
#define E_DEADLK    E$DeadLk

#define EFPOVR      40
#define EDIVERR     41
#define EINTERR     42
#define EFPUND      43
#define EILLARG     44
#define ERANGE      45

#endif
