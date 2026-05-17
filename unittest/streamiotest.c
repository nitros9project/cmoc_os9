#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

static const char rw_tmp[] = "streamio_rw.tmp";
static const char fgets_tmp[] = "streamio_fgets.tmp";

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

	if (n == strlen(out) && strcmp(in, out) == 0)
		printf("%s [PASS] fread()/fwrite()\n", __func__);
	else
		printf("%s [FAIL] fread()/fwrite(): n=%d text=%s\n", __func__, (int) n, in);
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
		return;
	}

	if (fgets(line, sizeof(line), fp) != 0 && strcmp(line, "line1\r") == 0)
		printf("%s [PASS] fgets()\n", __func__);
	else
		printf("%s [FAIL] fgets(): got %s\n", __func__, line);

	fclose(fp);
	unlink(fgets_tmp);
}

int main(void)
{
	test_fread_fwrite();
	test_fgets();
	return 0;
}
