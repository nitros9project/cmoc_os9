#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

static const char rw_tmp[] = "streamio_rw.tmp";
static const char fgets_tmp[] = "streamio_fgets.tmp";
static const char append_tmp[] = "streamio_append.tmp";
static int failed;

static void check_true(const char *name, int condition)
{
	if (condition)
		printf("%s [PASS]\n", name);
	else {
		printf("%s [FAIL]\n", name);
		failed = 1;
	}
}

void test_fread_fwrite(void)
{
	FILE *fp;
	char out[] = "alpha\nbeta\n";
	char in[16];
	size_t n;
	unlink(rw_tmp);
	fp = fopen(rw_tmp, "w");
	if (fp == 0) {
		printf("%s [FAIL] fopen(write)\n", __func__);
		return;
	}

	n = fwrite(out, 1, strlen(out), fp);
	fclose(fp);
	if (n != strlen(out)) {
		printf("%s [FAIL] fwrite(): got %d\n", __func__, (int) n);
		unlink(rw_tmp);
		return;
	}

	fp = fopen(rw_tmp, "r");
	if (fp == 0) {
		printf("%s [FAIL] fopen(read)\n", __func__);
		unlink(rw_tmp);
		return;
	}

	memset(in, 0, sizeof(in));
	n = fread(in, 1, strlen(out), fp);
	check_true("test_fread_fwrite fread(count)", n == strlen(out));
	check_true("test_fread_fwrite ferror(clear)", ferror(fp) == 0);
	check_true("test_fread_fwrite fread(eof)", fread(in, 1, 1, fp) == 0 && feof(fp));
	fclose(fp);
	unlink(rw_tmp);

	check_true("test_fread_fwrite fread()/fwrite()",
		   n == strlen(out) && strcmp(in, out) == 0);
}

void test_fgets(void)
{
	FILE *fp;
	char line[16];
	unlink(fgets_tmp);
	fp = fopen(fgets_tmp, "w");
	if (fp == 0) {
		printf("%s [FAIL] fopen(write)\n", __func__);
		return;
	}
	fwrite("line1\rline2\r", 1, 12, fp);
	fclose(fp);

	fp = fopen(fgets_tmp, "r");
	if (fp == 0) {
		printf("%s [FAIL] fopen(read)\n", __func__);
		unlink(fgets_tmp);
		failed = 1;
		return;
	}

	check_true("test_fgets fgets(first)",
		   fgets(line, sizeof(line), fp) != 0 && strcmp(line, "line1\r") == 0);
	check_true("test_fgets fgets(second)",
		   fgets(line, sizeof(line), fp) != 0 && strcmp(line, "line2\r") == 0);
	check_true("test_fgets fgets(eof)", fgets(line, sizeof(line), fp) == 0 && feof(fp));
	clearerr(fp);
	check_true("test_fgets clearerr()", feof(fp) == 0 && ferror(fp) == 0);

	fclose(fp);
	unlink(fgets_tmp);
}

void test_fseek_ftell(void)
{
	FILE *fp;
	char out[] = "0123456789";
	char buf[5];
	size_t n;

	unlink(rw_tmp);
	fp = fopen(rw_tmp, "w+");
	if (fp == 0) {
		printf("%s [FAIL] fopen(w+)\n", __func__);
		failed = 1;
		return;
	}

	n = fwrite(out, 1, strlen(out), fp);
	check_true("test_fseek_ftell fwrite()", n == strlen(out));
	check_true("test_fseek_ftell ftell(end)", ftell(fp) == (long) strlen(out));

	check_true("test_fseek_ftell fseek(set)", fseek(fp, 3L, SEEK_SET) == 0);
	check_true("test_fseek_ftell ftell(set)", ftell(fp) == 3L);

	check_true("test_fseek_ftell fseek(end)", fseek(fp, 0L, SEEK_END) == 0);
	check_true("test_fseek_ftell ftell(end seek)", ftell(fp) == (long) strlen(out));
	check_true("test_fseek_ftell fseek(reset)", fseek(fp, 3L, SEEK_SET) == 0);

	memset(buf, 0, sizeof(buf));
	n = fread(buf, 1, 4, fp);
	if (n == 4 && strcmp(buf, "3456") == 0)
		printf("%s [PASS]\n", "test_fseek_ftell fread(mid)");
	else {
		printf("%s [FAIL] n=%d buf=\"%s\"\n", "test_fseek_ftell fread(mid)", (int) n, buf);
		failed = 1;
	}
	check_true("test_fseek_ftell ftell(after read)", ftell(fp) == 7L);

	check_true("test_fseek_ftell fseek(cur)", fseek(fp, -2L, SEEK_CUR) == 0);
	check_true("test_fseek_ftell ftell(cur)", ftell(fp) == 5L);

	memset(buf, 0, sizeof(buf));
	n = fread(buf, 1, 4, fp);
	if (n == 4 && strcmp(buf, "5678") == 0)
		printf("%s [PASS]\n", "test_fseek_ftell fread(cur)");
	else {
		printf("%s [FAIL] n=%d buf=\"%s\"\n", "test_fseek_ftell fread(cur)", (int) n, buf);
		failed = 1;
	}

	check_true("test_fseek_ftell rewind", (rewind(fp), ftell(fp) == 0L));
	check_true("test_fseek_ftell feof(after rewind)", feof(fp) == 0);
	memset(buf, 0, sizeof(buf));
	n = fread(buf, 1, 4, fp);
	if (n == 4 && strcmp(buf, "0123") == 0)
		printf("%s [PASS]\n", "test_fseek_ftell fread(after rewind)");
	else {
		printf("%s [FAIL] n=%d buf=\"%s\"\n", "test_fseek_ftell fread(after rewind)", (int) n, buf);
		failed = 1;
	}

	fclose(fp);
	unlink(rw_tmp);
}

void test_fread_fwrite_objects(void)
{
	FILE *fp;
	unsigned short out[] = { 0x1111, 0x2222, 0x3333 };
	unsigned short in[3];
	size_t n;

	unlink(rw_tmp);
	fp = fopen(rw_tmp, "w");
	if (fp == 0) {
		printf("%s [FAIL] fopen(write)\n", __func__);
		failed = 1;
		return;
	}

	n = fwrite(out, sizeof(out[0]), 3, fp);
	check_true("test_fread_fwrite_objects fwrite()", n == 3);
	fclose(fp);

	fp = fopen(rw_tmp, "r");
	if (fp == 0) {
		printf("%s [FAIL] fopen(read)\n", __func__);
		unlink(rw_tmp);
		failed = 1;
		return;
	}

	memset(in, 0, sizeof(in));
	n = fread(in, sizeof(in[0]), 3, fp);
	check_true("test_fread_fwrite_objects fread()", n == 3);
	check_true("test_fread_fwrite_objects content",
	           in[0] == out[0] && in[1] == out[1] && in[2] == out[2]);

	fclose(fp);
	unlink(rw_tmp);
}

void test_append_mode(void)
{
	FILE *fp;
	char buf[16];
	size_t n;

	unlink(append_tmp);
	fp = fopen(append_tmp, "w");
	if (fp == 0) {
		printf("%s [FAIL] fopen(write)\n", __func__);
		failed = 1;
		return;
	}
	fwrite("abc", 1, 3, fp);
	fclose(fp);

	fp = fopen(append_tmp, "a+");
	if (fp == 0) {
		printf("%s [FAIL] fopen(a+)\n", __func__);
		unlink(append_tmp);
		failed = 1;
		return;
	}

	check_true("test_append_mode fseek(start)", fseek(fp, 0L, SEEK_SET) == 0);
	check_true("test_append_mode fwrite()", fwrite("XYZ", 1, 3, fp) == 3);
	check_true("test_append_mode fflush()", fflush(fp) == 0);
	check_true("test_append_mode rewind", (rewind(fp), ftell(fp) == 0L));
	check_true("test_append_mode ftell(after rewind)", ftell(fp) == 0L);

	memset(buf, 0, sizeof(buf));
	n = fread(buf, 1, 6, fp);
	if (n == 6)
		printf("%s [PASS]\n", "test_append_mode fread()");
	else {
		printf("%s [FAIL] n=%d ftell=%ld buf=\"%s\"\n",
		       "test_append_mode fread()", (int) n, ftell(fp), buf);
		failed = 1;
	}
	if (strcmp(buf, "abcXYZ") == 0)
		printf("%s [PASS]\n", "test_append_mode content");
	else {
		printf("%s [FAIL] buf=\"%s\"\n", "test_append_mode content", buf);
		failed = 1;
	}

	fclose(fp);
	unlink(append_tmp);
}

int main(void)
{
	test_fread_fwrite();
	test_fread_fwrite_objects();
	test_fgets();
	test_fseek_ftell();
	test_append_mode();
	return failed;
}
