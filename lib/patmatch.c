#include <ctype.h>

/* This is from the C3 Project
   https://github.com/boisy/toolshed/blob/master/c3/lib/lib.a/patmatch.c */

int patmatch(const char *pattern, const char *str, char forceCase)
{
	char   pc;                    /* a single character from pattern */

	while (pc = ((forceCase && islower(*pattern)) ? _toupper(*pattern++) : *pattern++))
	{
		if (pc == '*')
		{
			do
			{
				if (patmatch (pattern, str, forceCase))
					return (1);
			}
            while (*str++);

            return 0;
		}
         else
            if (!*str)
            	return (0);
			else if (pc == '?')
				str++;
			else if (pc != ((forceCase && islower(*str)) ? _toupper(*str++) : *str++))
				return 0;
	}

	return !*str;
}
