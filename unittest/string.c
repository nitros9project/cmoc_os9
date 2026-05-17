#include <stdio.h>
#include <string.h>
#include <unistd.h>

#define PLEN 11
#define BUFLEN 12
char *p = "cat bat dog";
char *p1 = "catbatdog";
char *pu = "CAT BAT DOG";
char *pr = "god tab tac";
char *sep = " ";
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
	char *myend = p + strlen(p);
	char *end = strend(p);
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
	char *tst = "cat ?at dog";
	int r = patmatch(tst, p, 0);
	if (r)
	{
		printf("%s [PASS]\n",__func__);
	} else {
		failed = 1;
		printf("%s [FAIL], expected 1 got %d, %s, %s\n",__func__,r,tst,p);
	}
	char *tstu = "CAT BAT D?G";
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


int main()
{
	test_strcat();
	test_strncat();
	test_strcpy();
	test_strncpy();
	test_index();
	test_rindex();
	test_strcmp();
	test_strncmp();
	test_strcmp_ordering();
	test_strlen();
	test_strchr();
	test_strchr_miss();
	test_strrchr();
	test_strspn();
	test_strcspn();
	test_strtok();
	test_strpbrk();
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
#endif
	return failed;
}
