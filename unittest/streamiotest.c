#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

static const char rw_tmp[] = "streamio_rw.tmp";
static const char fgets_tmp[] = "streamio_fgets.tmp";
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

	fclose(fp);
	unlink(rw_tmp);
}

int main(void)
{
	test_fread_fwrite();
	test_fgets();
	test_fseek_ftell();
	return failed;
}
