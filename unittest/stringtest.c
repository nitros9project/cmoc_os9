#include <stdio.h>
#include <string.h>
#include <unistd.h>

#define PLEN 11
#define BUFLEN 12
const char *p = "cat bat dog";
const char *p1 = "catbatdog";
const char *pu = "CAT BAT DOG";
const char *pr = "god tab tac";
const char *sep = " ";
static int failed;

#ifndef NULL
#define NULL 0
#endif

void test_strcat(void)
{
	char buf[BUFLEN];
	buf[0] = 0; // initialize
	strcat(buf, "cat ");
	strcat(buf, "bat ");
	strcat(buf, "dog");
	if (strcmp(buf, p)==0)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected '%s' got '%s'\n",__func__,p,buf);
	}
}

void test_strncat(void)
{
	char buf[BUFLEN];
	buf[0] = 0; // initialize
	strncat(buf, "cat ", 4);
	strncat(buf, "bat ", 4);
	strncat(buf, "dog", 3);
	if (strcmp(buf, p)==0)
	{
		printf("%s [PASS] with spc\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL] with spc, expected '%s' got '%s'\n",__func__,p,buf);
	}

	buf[0] = 0; // initialize
	strncat(buf, "cat ", 3);
	strncat(buf, "bat ", 3);
	strncat(buf, "dog", 3);
	if (strcmp(buf, p1)==0)
	{
		printf("%s [PASS] without spc\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL] without spc, expected '%s' got '%s'\n",__func__,p1,buf);
	}
}

void test_strncat_edges(void)
{
	char buf[BUFLEN];

	strcpy(buf, "cat");
	strncat(buf, "dog", 0);
	if (strcmp(buf, "cat") == 0)
	{
		printf("%s [PASS] zero count\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL] zero count, expected 'cat' got '%s'\n",__func__,buf);
	}

	strcpy(buf, "cat");
	strncat(buf, "dog", 2);
	if (strcmp(buf, "catdo") == 0)
	{
		printf("%s [PASS] partial count\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL] partial count, expected 'catdo' got '%s'\n",__func__,buf);
	}
}

#ifdef _CMOC_VERSION_
void test_strhcpy(void)
{
	char buf[BUFLEN], ph[BUFLEN];
	strtohstr(ph, p);
	strhcpy(buf, ph);
	if (strcmp(buf, p)==0)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected '%s' got '%s'\n",__func__,p,buf);
	}
}
#endif


void test_strcpy(void)
{
	char buf[BUFLEN];
	strcpy(buf, p);
	if (strcmp(buf, p)==0)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected '%s' got '%s'\n",__func__,p,buf);
	}
}

void test_strncpy(void)
{
	char buf[BUFLEN];
	strncpy(buf, p, PLEN+1);
	if (strcmp(buf, p)==0)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected '%s' got '%s'\n",__func__,p,buf);
	}
}

void test_strncpy_edges(void)
{
	char buf[8];
	char expect[] = {'c','a','t',0,0,0};

	memset(buf, 'X', sizeof(buf));
	strncpy(buf, "cat", 0);
	if (buf[0] == 'X')
	{
		printf("%s [PASS] zero count\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL] zero count, expected X got %02x\n",__func__,(unsigned char)buf[0]);
	}

	memset(buf, 'X', sizeof(buf));
	strncpy(buf, "cat", 6);
	if (memcmp(buf, expect, sizeof(expect)) == 0 && buf[6] == 'X')
	{
		printf("%s [PASS] nul padding\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL] nul padding, bytes=%02x,%02x,%02x,%02x,%02x,%02x,%02x\n",
			__func__,
			(unsigned char)buf[0],
			(unsigned char)buf[1],
			(unsigned char)buf[2],
			(unsigned char)buf[3],
			(unsigned char)buf[4],
			(unsigned char)buf[5],
			(unsigned char)buf[6]);
	}
}


#ifdef _CMOC_VERSION_
void test_strclr(void)
{
	char buf[BUFLEN], buf2[BUFLEN];
	strclr(buf, BUFLEN);
	memset(buf2, 0, BUFLEN);
	if (memncmp(buf, buf2, BUFLEN)==0)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected all 0 got 0x",__func__);
		int i, *ptr;
		for (i=0, ptr=(int *)buf; i<3; i++, ptr++)
			printf("%04x", *ptr);
		printf("\n");
	}
}
#endif


#ifdef _CMOC_VERSION_
void test_strucpy(void)
{
	char buf[BUFLEN];
	strucpy(buf, p);
	if (strcmp(buf, pu)==0)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected '%s' got '%s'\n",__func__,pu,buf);
	}
}
#endif

void test_index(void)
{
	char *ptr;
	ptr = index(p, 'a');
	if (ptr == p+1)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected %04x got %04x\n",__func__,p+1,ptr);
	}
	ptr = index(p, 'd');
	if (ptr == p+8)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected %04x got %04x\n",__func__,p+8,ptr);
	}
}

void test_rindex(void)
{
	char *ptr;
	ptr = rindex(p, 'a');
	if (ptr == p+5)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected %04x got %04x\n",__func__,p+5,ptr);
	}
	ptr = rindex(p, 'g');
	if (ptr == p+10)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected %04x got %04x\n",__func__,p+10,ptr);
	}
}


#ifdef _CMOC_VERSION_
void test_reverse(void)
{
	char buf[BUFLEN];
	strcpy(buf, p);
	reverse(buf);
	int r = strcmp(pr, buf);
	if (r==0)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 0 got %d, (%s) (%s)\n",__func__,r,p,buf);
	}
}
#endif


#ifdef _CMOC_VERSION_
void test_strend(void)
{
	const char *myend = p + strlen(p);
	const char *end = strend(p);
	if (end==myend)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected %04x got %04x\n",__func__,myend,end);
	}
}
#endif


void test_strcmp(void)
{
	int r = strcmp(p, p);
	if (r==0)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 0 got %d\n",__func__,r);
	}
}


void test_strncmp(void)
{
	int r = strncmp(p, p, strlen(p));
	if (r==0)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 0 got %d\n",__func__,r);
	}
}


void test_strncmp_edges(void)
{
	int ok = 1;

	if (strncmp("cat", "dog", 0) != 0)
		ok = 0;
	if (strncmp("cat", "car", 2) != 0)
		ok = 0;
	if (strncmp("cat", "car", 3) <= 0)
		ok = 0;

	if (ok)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL]\n",__func__);
	}
}


void test_strlen(void)
{
	int r = strlen(p);
	if (r==PLEN)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected %d got %d\n",__func__,PLEN,r);
	}
}


#ifdef _CMOC_VERSION_
void test_strucmp(void)
{
	int r = strucmp(p, pu);
	if (r==0)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 0 got %d\n",__func__,r);
	}
}
#endif


#ifdef _CMOC_VERSION_
void test_strnucmp(void)
{
	int r = strnucmp(p, pu, strlen(p));
	if (r==0)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 0 got %d\n",__func__,r);
	}
}
#endif


#ifdef _CMOC_VERSION_
void test_patmatch_questionmark(void)
{
	const char *tst = "cat ?at dog";
	int r = patmatch(tst, p, 0);
	if (r)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 1 got %d, %s, %s\n",__func__,r,tst,p);
	}
	const char *tstu = "CAT BAT D?G";
	r = patmatch(tstu, pu, 1);
	if (r)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 1 got %d, %s, %s\n",__func__,r,tstu,pu);
	}
}
#endif


#ifdef _CMOC_VERSION_
void test_patmatch_asterix(void)
{
	int r = patmatch("*dog", p, 0);
	if (r)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 1 got %d\n",__func__,r);
	}
	r = patmatch("*DOG", pu, 1);
	if (r)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 1 got %d\n",__func__,r);
	}
}
#endif


void test_strchr(void)
{
	char *ptr = strchr(p, 'd');
	if (ptr==p+8)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 'd' got %c\n",__func__,*ptr);
	}
}


void test_strrchr(void)
{
	char *ptr = strrchr(p, 'd');
	if (ptr==p+8)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 'd' got %d\n",__func__,*ptr);
	}
}


void test_strspn(void)
{
	size_t idx = strspn(p, " abct");
	if (p[idx]=='d')
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 'd' got p[%d]\n",__func__,idx);
	}
}

void test_strspn_edges(void)
{
	int ok = 1;

	if (strspn("", "abc") != 0)
		ok = 0;
	if (strspn("abc", "abc") != 3)
		ok = 0;
	if (strspn("abc", "") != 0)
		ok = 0;

	if (ok)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL]\n",__func__);
	}
}

void test_strcspn(void)
{
	size_t idx = strcspn(p, "dog");
	if (p[idx]=='d')
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 'd' got p[%d]\n",__func__,idx);
	}
}

void test_strcspn_edges(void)
{
	int ok = 1;

	if (strcspn("", "abc") != 0)
		ok = 0;
	if (strcspn("abc", "x") != 3)
		ok = 0;
	if (strcspn("abc", "a") != 0)
		ok = 0;

	if (ok)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL]\n",__func__);
	}
}


void test_strtok(void)
{
	char *token;
	int rr, r;
	char buf[BUFLEN];

	rr = 0;
	strcpy(buf, p);
	token = strtok(buf, sep);
	r = strcmp(token, "cat");
	if ( r != 0 )
	{
		failed = 1;
		printf("%s [FAIL], expected 'cat' got %s\n",__func__,token);
		rr = r;
	}

	token = strtok(NULL, sep);
	r = strcmp(token, "bat");
	if ( r != 0 )
	{
		failed = 1;
		printf("%s [FAIL], expected 'bat' got %s\n",__func__,token);
		rr = r;
	}

	token = strtok(NULL, sep);
	r = strcmp(token, "dog");
	if ( r != 0 )
	{
		failed = 1;
		printf("%s [FAIL], expected 'dog' got %s\n",__func__,token);
		rr = r;
	}

	if ( rr == 0 ) {
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL]\n",__func__);
	}
}

void test_strtok_edges(void)
{
	char buf[BUFLEN];
	char *token;
	int ok = 1;

	strcpy(buf, "  cat");
	token = strtok(buf, sep);
	if (token == NULL || strcmp(token, "cat") != 0)
		ok = 0;
	if (strtok(NULL, sep) != NULL)
		ok = 0;

	strcpy(buf, "   ");
	if (strtok(buf, sep) != NULL)
		ok = 0;

	if (ok)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL]\n",__func__);
	}
}


void test_strpbrk(void)
{
	char *ptr = strpbrk(p, "d");
	if (ptr==p+8)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 'd' got %c\n",__func__,*ptr);
	}
}

void test_strpbrk_miss(void)
{
	char *ptr = strpbrk(p, "xyz");
	if (ptr == NULL)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected NULL got %04x\n",__func__,ptr);
	}
}


#ifdef _CMOC_VERSION_
void test_strass(void)
{
	struct foo {
		int a,b,c;
	};

	struct foo *p;
	struct foo f = {1,2,-3};
	char buf[6];

	_strass(buf, (char *)&f, sizeof(struct foo));
	p = (struct foo *)buf;
	if (
		f.a == p->a &&
		f.b == p->b &&
		f.c == p->c )
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL]\n",__func__);
		printf("  f.a=%d p->a=%d\n",f.a, p->a);
		printf("  f.b=%d p->b=%d\n",f.a, p->b);
		printf("  f.c=%d p->c=%d\n",f.a, p->c);
	}
}

void test_strass_odd(void)
{
	char src[] = {1,2,3,4,5};
	char dst[] = {0,0,0,0,0};

	_strass(dst, src, sizeof(src));
	if (memcmp(dst, src, sizeof(src)) == 0)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], bytes=%02x,%02x,%02x,%02x,%02x\n",
			__func__,
			(unsigned char)dst[0],
			(unsigned char)dst[1],
			(unsigned char)dst[2],
			(unsigned char)dst[3],
			(unsigned char)dst[4]);
	}
}
#endif

void test_strcmp_ordering(void)
{
	int r = strcmp("cat", "dog");
	if (r < 0)
		printf("%s [PASS]\n", __func__);
	else {
		failed = 1;
		printf("%s [FAIL], expected negative got %d\n", __func__, r);
	}
}

void test_strchr_miss(void)
{
	char *ptr = strchr(p, 'z');
	if (ptr == NULL)
		printf("%s [PASS]\n", __func__);
	else {
		failed = 1;
		printf("%s [FAIL], expected NULL got %04x\n", __func__, ptr);
	}
}

void test_strtok_single(void)
{
	char buf[BUFLEN];
	char *token;

	strcpy(buf, "solo");
	token = strtok(buf, sep);
	if (token != NULL && strcmp(token, "solo") == 0 && strtok(NULL, sep) == NULL)
		printf("%s [PASS]\n", __func__);
	else {
		failed = 1;
		printf("%s [FAIL]\n", __func__);
	}
}

void test_memcpy_memcmp(void)
{
	char src[] = "abcde";
	char dst[6];
	int r;
	memcpy(dst, src, sizeof(src));
	r = memcmp(dst, src, sizeof(src));
	if (r == 0)
		printf("%s [PASS]\n", __func__);
	else {
		failed = 1;
		printf("%s [FAIL] r=%d dst=\"%s\" src=\"%s\" bytes=%02x,%02x,%02x,%02x,%02x,%02x\n",
			__func__,
			r,
			dst,
			src,
			(unsigned char) dst[0],
			(unsigned char) dst[1],
			(unsigned char) dst[2],
			(unsigned char) dst[3],
			(unsigned char) dst[4],
			(unsigned char) dst[5]);
	}
}

void test_memchr(void)
{
	char data[] = "abcde";
	char *ptr = (char *) memchr(data, 'c', sizeof(data));
	if (ptr == data + 2 && memchr(data, 'z', sizeof(data)) == NULL)
		printf("%s [PASS]\n", __func__);
	else {
		failed = 1;
		printf("%s [FAIL]\n", __func__);
	}
}

void test_memccpy(void)
{
	char src[] = "abcde";
	char dst[8];
	char *end;
	int cmp;

	memset(dst, 0, sizeof(dst));
	end = (char *) memccpy(dst, src, 'c', sizeof(src));
	cmp = memcmp(dst, "abc", 3);
	if (end == dst + 3
	&& cmp == 0
	&& dst[3] == 0)
		printf("%s [PASS]\n", __func__);
	else {
		failed = 1;
		printf("%s [FAIL] end=%04x expect=%04x cmp=%d b3=%02x bytes=%02x,%02x,%02x,%02x\n",
			__func__,
			end,
			dst + 3,
			cmp,
			(unsigned char) dst[3],
			(unsigned char) dst[0],
			(unsigned char) dst[1],
			(unsigned char) dst[2],
			(unsigned char) dst[3]);
	}
}


int main()
{
	test_strcat();
	test_strncat();
	test_strncat_edges();
	test_strcpy();
	test_strncpy();
	test_strncpy_edges();
	test_index();
	test_rindex();
	test_strcmp();
	test_strncmp();
	test_strncmp_edges();
	test_strcmp_ordering();
	test_strlen();
	test_strchr();
	test_strchr_miss();
	test_strrchr();
	test_strspn();
	test_strspn_edges();
	test_strcspn();
	test_strcspn_edges();
	test_strtok();
	test_strtok_single();
	test_strtok_edges();
	test_strpbrk();
	test_strpbrk_miss();
	test_memcpy_memcmp();
	test_memchr();
	test_memccpy();
#ifdef _CMOC_VERSION_
	test_strhcpy();
	test_strclr();
	test_strucpy();
	test_reverse();
	test_strend();
	test_strucmp();
	test_strnucmp();
	test_patmatch_questionmark();
	test_patmatch_asterix();
	test_strass();
	test_strass_odd();
#endif
	return failed;
}
