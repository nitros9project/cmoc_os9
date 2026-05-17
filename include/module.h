#include <sys/types.h>

#ifndef _MODULE_H
#define _MODULE_H

/**
 * @file module.h
 * @brief OS-9 module header layouts and data-module helper routines.
 */

/**
 * @brief Executable module header layout.
 */
typedef struct
{
	unsigned m_sync;
	unsigned m_size;
	unsigned m_name;
	char m_tylan;
	char m_attrev;
	char m_parity;
	unsigned m_exec;
	unsigned m_store;
} mod_exec;

/**
 * @brief Device descriptor module header layout.
 */
typedef struct
{
	unsigned m_sync;
	unsigned m_size;
	unsigned m_name;
	char m_tylan;
	char m_attrev;
	char m_parity;
	unsigned m_fmname;
	unsigned m_ddname;
	char m_mode;
	char m_control[3];
	char m_tabsize;
} mod_dev;

/**
 * @brief System configuration module header layout.
 */
typedef struct
{
	unsigned m_sync;
	unsigned m_size;
	unsigned m_name;
	char m_tylan;
	char m_attrev;
	char m_parity;
	char m_ramtop[3];
	char m_irqno;
	char m_devno;
	unsigned m_startup;
	unsigned m_sysdrive;
	unsigned m_boot;
} mod_config;

/**
 * @brief Data module header layout.
 */
typedef struct
{
	unsigned m_sync;
	unsigned m_size;
	unsigned m_name;
	char m_tylan;
	char m_attrev;
	char m_parity;
	unsigned m_data;
	unsigned m_dsize;
} mod_data;

/**
 * @brief Return the current OS-9 default drive name.
 *
 * @return Pointer to a static drive-name string.
 */
char *getdrive(void);

/**
 * @brief Link to a named data module and return its data area.
 *
 * @param name Module name to link.
 * @param datptr Receives the module data pointer.
 * @param space Receives the module data size.
 * @return `0` on success, or an OS-9 error code.
 */
int datlink(const char *name, char **datptr, int *space);

/**
 * @brief Unlink a previously linked data module.
 *
 * @param datptr Data-module pointer returned by `datlink()`.
 * @return `0` on success, or an OS-9 error code.
 */
int dunlink(char *datptr);

/**
 * @brief Lock a data module in memory.
 *
 * @param datptr Data-module pointer to lock.
 * @return `0` on success, or an OS-9 error code.
 */
int lockdata(char *datptr);

/**
 * @brief Unlock a previously locked data module.
 *
 * @param datptr Data-module pointer to unlock.
 * @return `0` on success, or an OS-9 error code.
 */
int unlkdata(char *datptr);

/**
 * @brief Update a running CRC over a block of bytes.
 *
 * @param start First byte to include.
 * @param count Number of bytes to process.
 * @param accum CRC accumulator buffer.
 * @return `0` on success, or an error/status code as defined by the implementation.
 */
int crc(void *start, size_t count, void *accum);

#endif
