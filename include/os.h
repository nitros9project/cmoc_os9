#ifndef _OS9_H
#define _OS9_H

/*
 * os.h - OS-9/NitrOS-9 Definitions
 */

/**
 * @file os.h
 * @brief Core OS-9 and NitrOS-9 constants, types, and low-level syscall helpers.
 */

/**
 * @brief Last OS-9 or library error code observed by the runtime.
 */
extern int errno;

/**
 * @brief Numeric OS-9 error-code type.
 */
typedef int error_code;

/* These probably need to go into cmoc.h */
/**
 * @brief Unsigned 8-bit byte type used by OS-9 interfaces.
 */
typedef unsigned char byte;
/**
 * @brief Legacy boolean type used by older interfaces.
 */
typedef byte BOOL;

/* System calls */
#define F$Link          0x00
#define F$Load          0x01
#define F$UnLink        0x02
#define F$Fork          0x03
#define F$Wait          0x04
#define F$Chain         0x05
#define F$Exit          0x06
#define F$Mem           0x07
#define F$Send          0x08
#define F$Icpt          0x09
#define F$Sleep         0x0A
#define F$SSpd          0x0B
#define F$ID            0x0C
#define F$SPrior        0x0D
#define F$SSWI          0x0E
#define F$PErr          0x0F
#define F$PrsNam        0x10
#define F$CmpNam        0x11
#define F$SchBit        0x12
#define F$AllBit        0x13
#define F$DelBit        0x14
#define F$Time          0x15
#define F$STime         0x16
#define F$CRC           0x17

/* Level 2 system calls */
#define F$GPrDsc        0x18        // Get Process Descriptor copy
#define F$GBlkMp        0x19        // Get System Block Map copy
#define F$GModDr        0x1A        // Get Module Directory copy
#define F$CpyMem        0x1B        // Copy External Memory
#define F$SUser         0x1C        // Set User ID number
#define F$UnLoad        0x1D        // Unlink Module by name
#define F$Alarm         0x1E        // Color Computer 3 Alarm Call
                                    // Reserved - For overlap of other systems
#define F$NMLink        0x21        // Color Computer 3 Non-Mapping Link
#define F$NMLoad        0x22        // Color Computer 3 Non-Mapping Load

/* I/O system calls */
#define	I$Attach	    0x80
#define	I$Detach	    0x81
#define	I$Dup		    0x82
#define	I$Create	    0x83
#define	I$Open		    0x84
#define	I$MakDir	    0x85
#define	I$ChgDir	    0x86
#define	I$Delete	    0x87
#define	I$Seek		    0x88
#define	I$Read		    0x89
#define	I$Write		    0x8A
#define	I$ReadLn	    0x8B
#define	I$WritLn	    0x8C
#define	I$GetStt	    0x8D
#define	I$SetStt	    0x8E
#define	I$Close		    0x8F
#define	I$DeletX	    0x90

/* Error codes */
#define	E$PthFul        0xC8
#define	E$BPNum         0xC9
#define	E$Poll          0xCA
#define	E$BMode         0xCB
#define	E$DevOvf        0xCC
#define	E$BMID          0xCD
#define	E$DirFul        0xCE
#define	E$MemFul        0xCF
#define	E$UnkSvc        0xD0
#define	E$ModBsy        0xD1
#define	E$BPAddr        0xD2
#define	E$EOF           0xD3
#define	E$NES           0xD5
#define	E$FNA           0xD6
#define	E$BPNam         0xD7
#define	E$PNNF          0xD8
#define	E$SLF           0xD9
#define	E$CEF           0xDA
#define	E$IBA           0xDB
#define	E$HangUp        0xDC
#define	E$MNF           0xDD
#define	E$DelSP         0xDF
#define	E$IPrcID        0xE0
#define	E$BPrcID        E$IPrcID
#define	E$NoChld        0xE2
#define	E$ISWI          0xE3
#define	E$PrcAbt        0xE4
#define	E$PrcFul        0xE5
#define	E$IForkP        0xE6
#define	E$KwnMod        0xE7
#define	E$BMCRC         0xE8
#define	E$USigP         0xE9
#define	E$NEMod         0xEA
#define	E$BNam          0xEB
#define	E$BMHP          0xEC
#define	E$NoRAM         0xED
#define	E$DNE           0xEE
#define	E$NoTask        0xEF
#define	E$Unit          0xF0
#define	E$Sect          0xF1
#define	E$WP            0xF2
#define	E$CRC           0xF3
#define	E$Read          0xF4
#define	E$Write         0xF5
#define	E$NotRdy        0xF6
#define	E$Seek          0xF7
#define	E$Full          0xF8
#define	E$BTyp          0xF9
#define	E$DevBsy        0xFA
#define	E$DIDC          0xFB
#define	E$Lock          0xFC
#define	E$Share         0xFD
#define	E$DeadLk        0xFE

/* GetStat/SetStat calls */
#define	SS_Opt          0x00
#define	SS_Ready        0x01
#define	SS_Size         0x02
#define	SS_Reset        0x03
#define	SS_WTrk         0x04
#define	SS_Pos          0x05
#define	SS_EOF          0x06
#define	SS_Link         0x07
#define	SS_ULink        0x08
#define	SS_Feed         0x09
#define	SS_Frz          0x0A
#define	SS_SPT          0x0B
#define	SS_SQD          0x0C
#define	SS_DCmd         0x0D
#define	SS_DevNm        0x0E
#define	SS_FD           0x0F
#define	SS_Ticks        0x10
#define	SS_Lock         0x11
#define	SS_DStat        0x12
#define	SS_Joy          0x13
#define	SS_BlkRd        0x14
#define	SS_BlkWr        0x15
#define	SS_Reten        0x16
#define	SS_WFM          0x17
#define	SS_RFM          0x18
#define	SS_ELog         0x19
#define	SS_SSig         0x1A
#define	SS_Relea        0x1B
#define	SS_AlfaS        0x1C
#define	SS_Attr         SS_AlfaS
#define	SS_Break        0x1D
#define	SS_RsBit        0x0E
#define	SS_FDInf        0x20
#define	SS_DirEnt       SD.FDInf
#define	SS_SetMF        0x24
#define	SS_Cursr        0x25
#define	SS_ScSiz        0x26
#define	SS_KySns        0x27
#define	SS_ComSt        0x28
#define	SS_Open         0x29
#define	SS_Close        0x2A
#define	SS_HngUp        0x2B
#define	SS_FSig         0x2C
#define	SS_DSize        SS_ScSiz
#define	SS_VarSect      SS_DStat

/* System Specific and User Defined Codes */
#define	SS_AAGBf        0x80
#define	SS_SLGBf        0x81
#define	SS_Mount        0x82
#define	SS_RdNet        0x83
#define	SS_MpGPB        0x84
#define	SS_Slots        0x85

/* Level 2 Windowing Codes */
#define	SS_WnSet        0x86	// Set up High Level Windowing Information
#define	SS_MnSel        0x87	// Request High level Menu Handler take determine next event
#define	SS_SBar         0x88	// SetStat to set position block on Window scroll bars
#define	SS_Mouse        0x89	// Return Mouse information packet (COCO)
#define	SS_MsSig        0x8A	// SetStat to tell driver to send signal on mouse event
#define	SS_AScrn        0x8B	// Allocate a screen for application poking
#define	SS_DScrn        0x8C	// Display a screen allocated by SS_AScrn
#define	SS_FScrn        0x8D	// Free a screen allocated by SS_AScrn
#define	SS_PScrn        0x8E	// Polymorph Screen into different screen type
#define	SS_ScInf        0x8F	// Get Current screen info for direct writes
#define	SS_Palet        0x91	// Return palette information
#define	SS_Montr        0x92	// Get and Set Monitor Type
#define	SS_ScTyp        0x93	// Get screen type information
#define	SS_GIP          0x94	// Global Input Parameters (SetStat)
#define	SS_UMBar        0x95	// update menu bar (SetStat)
#define	SS_FBRgs        0x96	// return color registers (GetStat)
#define	SS_DfPal        0x97	// set/return default palette registers (Getstat/Setstat)
#define	SS_Tone         0x98	// Generate a tone using 6 bit sound
#define	SS_GIP2         0x99	// Global Input Params #2 (L2V3)
#define	SS_AnPal        0x9A	// Animate palettes (L2V3)
#define	SS_FndBf        0x9B	// Find named buffer (L2V3)


/**************************
 * Module Field Definitions
 *
 * ID Field - First two bytes of a NitrOS-9 module
 */
#define	M$ID1           0x87    // Module ID code byte one
#define	M$ID2           0xCD    // Module ID code byte two
#define	M$ID12         M$ID1*256+M$ID2

/*
 * Module Type/Language Field Masks
 */
#define	TypeMask        0b11110000  // Type Field
#define	LangMask        0b00001111  // Language Field

/*
 * Module Type Values
 */
#define	Devic           0xF0    // Device Descriptor Module
#define	Drivr           0xE0    // Physical Device Driver
#define	FlMgr           0xD0    // File Manager
#define	Systm           0xC0    // System Module
#define	ShellSub        0x50    // Shell+ shell sub module
#define	Data            0x40    // Data Module
#define	Multi           0x30    // Multi-Module
#define	Sbrtn           0x20    // Subroutine Module
#define	Prgrm           0x10    // Program Module

/*
 * Module Language Values
 */
#define	Objct           0x01    // 6809 Object Code Module
#define	ICode           0x02    // Basic09 I-code
#define	PCode           0x03    // Pascal P-code
#define	CCode           0x04    // C I-code
#define	CblCode         0x05    // Cobol I-code
#define	FrtnCode        0x06    // Fortran I-code
#define	Obj6309         0x07    // 6309 object code

/*
 * Module Attributes / Revision byte
 *
 * Field Masks
 */
#define	AttrMask        0b11110000  // Attributes Field
#define	RevsMask        0b00001111  // Revision Level Field

/*
 * Attribute Flags
 */
#define	ReEnt           0b10000000  // Re-Entrant Module
#define	ModProt         0b01000000  // Gimix Module protect bit (0=protected, 1=write enable)
#define	ModNat          0b00100000  // 6309 native mode attribute

/********************
 * Device Type Values
 *
 * These values define various classes of devices, which are
 * managed by a file manager module.  The Device Type is embedded
 * in a device's device descriptor.
 */
#define	DT_SCF          0x00    // Sequential Character File Manager
#define	DT_RBF          0x01    // Random Block File Manager
#define	DT_Pipe         0x02    // Pipe File Manager
#define	DT_SBF          0x03    // Sequential Block File Manager
#define	DT_NFM          0x04    // Network File Manager
#define	DT_CDFM         0x05    // CD-ROM File Manager
#define	DT_RFM          0x06    // Remote File Manager

/*********************
 * CRC Result Constant
 */
#define	CRCCon1         0x0080
#define	CRCCon23        0x0FE3


/**
 * @brief Put the process to sleep.
 *
 * @param ticks Address of the variable containing the number of ticks to sleep.
 * This is an in/out parameter. The value of the variable must be set to the number of
 * ticks to sleep. Upon return, the number of ticks left is placed in that same location.
 * @return 0 if successful, otherwise the error code.
 */
error_code _os9_sleep(int *ticks);


typedef struct _registers_6809 {
    char cc, a, b, dp;
    int  x, y, u, s;
} registers_6809;

/**
 * @brief Perform a system call.
 *
 * @param callcode 
 * @param registers Address of the structure containing the 6809 registers. 
 * @return 0 if successful, otherwise the error code.
 */
error_code _os_syscall(int callcode, registers_6809 *registers);

/* Small GetStat/SetStat helpers used by the old Kreider CGfx code. */
/**
 * @brief Return the object size reported by `SS_Size`.
 *
 * @param path Open path descriptor.
 * @return Size value, or a negative result on failure.
 */
long _gs_size(int path);

/**
 * @brief Return the current file position reported by `SS_Pos`.
 *
 * @param path Open path descriptor.
 * @return Current position, or a negative result on failure.
 */
long _gs_pos(int path);

/**
 * @brief Query readiness using `SS_Ready`.
 *
 * @param path Open path descriptor.
 * @return Ready status, or a negative result on failure.
 */
int _gs_rdy(int path);

/**
 * @brief Query end-of-file state using `SS_EOF`.
 *
 * @param path Open path descriptor.
 * @return EOF status, or a negative result on failure.
 */
int _gs_eof(int path);

/**
 * @brief Read an OS-9 options packet using `SS_Opt`.
 *
 * @param path Open path descriptor.
 * @param opts Destination options buffer.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _gs_opt(int path, void *opts);

/**
 * @brief Read the device name associated with a path.
 *
 * @param path Open path descriptor.
 * @param name Destination buffer.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _gs_devn(int path, char *name);

/**
 * @brief Write an options packet using `SS_Opt`.
 *
 * @param path Open path descriptor.
 * @param opts Source options buffer.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_opt(int path, void *opts);

/**
 * @brief Set attributes using `SS_Attr`.
 *
 * @param path Open path descriptor.
 * @param value Attribute block or value pointer.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_attr(int path, void *value);

/**
 * @brief Set size-related information using `SS_Size`.
 *
 * @param path Open path descriptor.
 * @param value Size block or value pointer.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_size(int path, void *value);

/**
 * @brief Lock a path or resource using `SS_Lock`.
 *
 * @param path Open path descriptor.
 * @param value Lock parameter block.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_lock(int path, void *value);

/**
 * @brief Release a path or resource using the matching SetStat call.
 *
 * @param path Open path descriptor.
 * @param value Release parameter block.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_rel(int path, void *value);

/**
 * @brief Reset a device or stream using `SS_Reset`.
 *
 * @param path Open path descriptor.
 * @param value Reset parameter block.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_rest(int path, void *value);

/**
 * @brief Configure signal-on-status behavior for a path.
 *
 * @param path Open path descriptor.
 * @param value Signal parameter block.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_ssig(int path, void *value);

/**
 * @brief Set or read tick-related status information.
 *
 * @param path Open path descriptor.
 * @param value Tick parameter block.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _ss_tiks(int path, void *value);

/**
 * @brief Return the absolute value of a signed integer.
 *
 * @param value Input value.
 * @return Absolute value of `value`.
 */
int abs(int value);

/**
 * @brief Return the current process identifier through an output pointer.
 *
 * @param pid Receives the process identifier.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_getpid(int *pid);

/**
 * @brief Return the current user identifier through an output pointer.
 *
 * @param uid Receives the user identifier.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_getuid(int *uid);

/**
 * @brief Set the active user identifier using administrative semantics.
 *
 * @param uid New user identifier.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_asetuid(int uid);

/**
 * @brief Set the current user identifier.
 *
 * @param uid New user identifier.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_setuid(int uid);

/**
 * @brief Send a signal to a target process or task.
 *
 * @param pid Target process or task identifier.
 * @param sig Signal number to deliver.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_send(int pid, int sig);

/**
 * @brief Wait for a child process to change state or exit.
 *
 * @param status Receives the child status code when non-`NULL`.
 * @return Child identifier on success, or `-1` on failure.
 */
int _os_wait(int *status);

/**
 * @brief Set the priority of a process or task.
 *
 * @param pid Target process or task identifier.
 * @param priority New priority value.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_setpr(int pid, int priority);

/**
 * @brief Replace the current process image with another module.
 *
 * @param modname Module name to execute.
 * @param paramsize Size of the parameter block.
 * @param paramaddr Address of the parameter block.
 * @param lang Module language code.
 * @param type Module type code.
 * @param datasize Requested data area size.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_chain(const char *modname, int paramsize, void *paramaddr, int lang, int type, int datasize);

/**
 * @brief Start another program module as a child process.
 *
 * @param modname Module name to execute.
 * @param paramsize Size of the parameter block.
 * @param paramaddr Address of the parameter block.
 * @param lang Module language code.
 * @param type Module type code.
 * @param datasize Requested data area size.
 * @param pid Receives the child process identifier.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_fork(const char *modname, int paramsize, void *paramaddr, int lang, int type, int datasize, int *pid);

/**
 * @brief Link to an already-loaded module.
 *
 * @param modname Module name to link.
 * @param lang Module language code.
 * @param type Module type code.
 * @param modaddr Receives the module header address.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_modlink(char *modname, int lang, int type, void **modaddr);

/**
 * @brief Load a module by name and return its header address.
 *
 * @param modname Module name to load.
 * @param lang Module language code.
 * @param type Module type code.
 * @param modaddr Receives the module header address.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_modload(char *modname, int lang, int type, void **modaddr);

/**
 * @brief Unlink a previously linked or loaded module.
 *
 * @param modaddr Module header address to unlink.
 * @return `0` on success, otherwise an OS-9 error code.
 */
error_code _os_modunlink(void *modaddr);

#endif
