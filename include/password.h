#ifndef _PASSWORD_H
#define _PASSWORD_H

/**
 * @file password.h
 * @brief Access to the OS-9 password file and parsed password entries.
 */

/** @brief Default OS-9 password file path. */
#define PASSWORD "/DD/SYS/password"

#define PWEMAX 64
#define PWSIZ 132
#define PWNSIZ 32
#define PWPSIZ 32
#define UNXDLM ':'
#define OS9DLM ','

/**
 * @brief Parsed password-file entry fields.
 */
typedef struct
{
	char *unam;
	char *upw;
	char *uid;
	char *upri;
	char *ugcos;
	char *ucmd;
	char *udat;
	char *ujob;
} PWENT;

/**
 * @brief Return the next parsed password entry from the current stream.
 *
 * @return Pointer to a static `PWENT`, or `NULL` on end-of-file or failure.
 */
PWENT *getpwent(void);

/**
 * @brief Look up a password entry by numeric user id.
 *
 * @param uid User identifier to search for.
 * @return Pointer to a static `PWENT`, or `NULL` if not found.
 */
PWENT *getpwuid(int uid);

/**
 * @brief Look up a password entry by user name.
 *
 * @param name User name to search for.
 * @return Pointer to a static `PWENT`, or `NULL` if not found.
 */
PWENT *getpwnam(char *name);

/**
 * @brief Rewind the password-entry stream to the beginning.
 */
void setpwent(void);

/**
 * @brief Close the password-entry stream.
 */
void endpwent(void);

/**
 * @brief Return the active password-field delimiter character.
 *
 * @return Password delimiter character.
 */
int getpwdlm(void);

#endif
