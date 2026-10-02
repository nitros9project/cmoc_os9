#ifndef CMOC_TEST_IEEEFP_H
#define CMOC_TEST_IEEEFP_H
#undef HUGE
#define __always_inline inline __attribute__((__always_inline__))
#define _IEEE_754_2008_SNAN 1
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define __IEEE_LITTLE_ENDIAN
#else
#define __IEEE_BIG_ENDIAN
#endif
#endif
