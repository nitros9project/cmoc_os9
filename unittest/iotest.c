#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <string.h>
#include <fcntl.h>
#include <os.h>

static int failed;

void test_create_and_delete_file()
{
	const char *file = "existentfile";
	char buf[256];

    unlink(file);

	/* open file for reading and writing, with owner read/write permissions */
	int mode = FAM_READ | FAM_WRITE;
	int perms = FAP_READ | FAP_WRITE;
	int path = create(file, mode, perms);
	if (path != -1)
	{
		printf("%s [PASS] create(\"%s\", %d, %x) = %d\n", __func__, file, mode, perms, path);
		int result = close(path);
		if (result != -1)
		{
			printf("%s [PASS] close(%d) = %d\n", __func__, path, result);
			result = unlink(file);
			if (result != -1)
			{
				printf("%s [PASS] unlink(\"%s\") = %d\n", __func__, file, result);
			}
			else
			{
				failed = 1;
				printf("%s [FAIL] unlink(\"%s\") = %d, errno = %d\n", __func__, file, result, errno);
			}
		}
		else
		{
			failed = 1;
			printf("%s [FAIL] close(%d) = %d, errno = %d\n", __func__, path, result, errno);
		}
	}
	else
	{
		failed = 1;
		printf("%s [FAIL] create(\"%s\", %d, %x) = %d, errno = %d\n", __func__, file, mode, perms, path, errno);
	}
}

void test_open_nonexistent_file()
{
	const char *file = "nonexistentfile";

	int mode = FAM_READ;
	int path = open(file, mode);
	if (path == -1 && (errno == E$PNNF || errno == E$MNF))
	{
		printf("%s [PASS] open(\"%s\", %x) = %d errno=%d\n", __func__, file, mode, path, errno);
	}
	else
	{
		failed = 1;
		printf("%s [FAIL] open(\"%s\", %x) = %d errno=%d\n", __func__, file, mode, path, errno);
	}
}

void test_open_read_close_existing_file()
{
	const char *file = "openread.tmp";
	const char *message = "open wrapper\n";
	char buf[32];
	int mode = FAM_READ | FAM_WRITE;
	int perms = FAP_READ | FAP_WRITE;
	int path;
	int result;

	unlink(file);

	path = create(file, mode, perms);
	if (path == -1)
	{
		failed = 1;
		printf("%s [FAIL] create(\"%s\", %x, %d) = %d, errno = %d\n", __func__, file, mode, perms, path, errno);
		return;
	}

	result = write(path, message, strlen(message));
	if (result != strlen(message))
	{
		failed = 1;
		printf("%s [FAIL] write(%d, \"%s\") = %d, errno = %d\n", __func__, path, message, result, errno);
		close(path);
		unlink(file);
		return;
	}
	printf("%s [PASS] write(%d, \"%s\") = %d\n", __func__, path, message, result);

	result = close(path);
	if (result == -1)
	{
		failed = 1;
		printf("%s [FAIL] close(%d) = %d, errno = %d\n", __func__, path, result, errno);
		unlink(file);
		return;
	}
	printf("%s [PASS] close(%d) = %d\n", __func__, path, result);

	path = open(file, FAM_READ);
	if (path == -1)
	{
		failed = 1;
		printf("%s [FAIL] open(\"%s\", %x) = %d, errno = %d\n", __func__, file, FAM_READ, path, errno);
		unlink(file);
		return;
	}
	printf("%s [PASS] open(\"%s\", %x) = %d\n", __func__, file, FAM_READ, path);

	memset(buf, 0, sizeof(buf));
	result = read(path, buf, strlen(message));
	if (result == strlen(message) && strcmp(buf, message) == 0)
		printf("%s [PASS] read(%d, \"%s\") = %d\n", __func__, path, buf, result);
	else
	{
		failed = 1;
		printf("%s [FAIL] read(%d) = %d got=\"%s\", errno = %d\n", __func__, path, result, buf, errno);
	}

	result = close(path);
	if (result == 0)
		printf("%s [PASS] close(%d) = %d\n", __func__, path, result);
	else
	{
		failed = 1;
		printf("%s [FAIL] close(%d) = %d, errno = %d\n", __func__, path, result, errno);
	}

	result = close(path);
	if (result == -1)
		printf("%s [PASS] close(%d again) = %d\n", __func__, path, result);
	else
	{
		failed = 1;
		printf("%s [FAIL] close(%d again) = %d\n", __func__, path, result);
	}

	result = unlink(file);
	if (result == -1)
	{
		failed = 1;
		printf("%s [FAIL] unlink(\"%s\") = %d, errno = %d\n", __func__, file, result, errno);
	}
	else
		printf("%s [PASS] unlink(\"%s\") = %d\n", __func__, file, result);
}

void test_readln_existing_file()
{
	char file[] = "readln.tmp";
	char message[] = "first\rsecond\r";
	char buf[16];
	int mode = FAM_READ | FAM_WRITE;
	int perms = FAP_READ | FAP_WRITE;
	int path;
	int result;

	unlink(file);

	path = create(file, mode, perms);
	if (path == -1)
	{
		failed = 1;
		printf("%s [FAIL] create(\"%s\", %x, %d) = %d, errno = %d\n", __func__, file, mode, perms, path, errno);
		return;
	}

	result = write(path, message, strlen(message));
	if (result != strlen(message))
	{
		failed = 1;
		printf("%s [FAIL] write(%d, \"%s\") = %d, errno = %d\n", __func__, path, message, result, errno);
		close(path);
		unlink(file);
		return;
	}
	close(path);

	path = open(file, FAM_READ);
	if (path == -1)
	{
		failed = 1;
		printf("%s [FAIL] open(\"%s\", %x) = %d, errno = %d\n", __func__, file, FAM_READ, path, errno);
		unlink(file);
		return;
	}

	memset(buf, 0, sizeof(buf));
	result = readln(path, buf, sizeof(buf));
	if (result == 6 && strcmp(buf, "first\r") == 0)
		printf("%s [PASS] readln(first) = %d\n", __func__, result);
	else
	{
		failed = 1;
		printf("%s [FAIL] readln(first) = %d got=\"%s\", errno = %d\n", __func__, result, buf, errno);
	}

	memset(buf, 0, sizeof(buf));
	result = readln(path, buf, sizeof(buf));
	if (result == 7 && strcmp(buf, "second\r") == 0)
		printf("%s [PASS] readln(second) = %d\n", __func__, result);
	else
	{
		failed = 1;
		printf("%s [FAIL] readln(second) = %d got=\"%s\", errno = %d\n", __func__, result, buf, errno);
	}

	memset(buf, 0, sizeof(buf));
	result = readln(path, buf, sizeof(buf));
	if (result == 0)
		printf("%s [PASS] readln(eof) = %d\n", __func__, result);
	else
	{
		failed = 1;
		printf("%s [FAIL] readln(eof) = %d, errno = %d\n", __func__, result, errno);
	}

	close(path);
	unlink(file);
}

void test_write_zero_count(void)
{
	const char *file = "writezero.tmp";
	const char *message = "ignored";
	int mode = FAM_READ | FAM_WRITE;
	int perms = FAP_READ | FAP_WRITE;
	int path;
	int result;

	unlink(file);

	path = create(file, mode, perms);
	if (path == -1)
	{
		failed = 1;
		printf("%s [FAIL] create(\"%s\", %x, %d) = %d, errno = %d\n", __func__, file, mode, perms, path, errno);
		return;
	}

	result = write(path, message, 0);
	if (result == 0)
		printf("%s [PASS] write(%d, zero count) = %d\n", __func__, path, result);
	else {
		failed = 1;
		printf("%s [FAIL] write(%d, zero count) = %d, errno = %d\n", __func__, path, result, errno);
	}

	result = writeln(path, message, 0);
	if (result == 0)
		printf("%s [PASS] writeln(%d, zero count) = %d\n", __func__, path, result);
	else {
		failed = 1;
		printf("%s [FAIL] writeln(%d, zero count) = %d, errno = %d\n", __func__, path, result, errno);
	}

	close(path);
	unlink(file);
}

void test_delete_nonexistent_file()
{
	const char *file = "deletenonexistentfile";
	
	int result = unlink(file);
	if (result == -1 && (errno == E$PNNF || errno == E$MNF))
	{
		printf("%s [PASS] unlink(\"%s\") = %d errno=%d\n", __func__, file, result, errno);
	}
	else
	{
		failed = 1;
		printf("%s [FAIL] unlink(\"%s\") = %d errno=%d\n", __func__, file, result, errno);
	}
}

/* test creation of a small file and seeking from various directions (start, current, end)
   coverage of this test is currently weak. A good test would be to add a large content file
   and seek within that.
   */
void test_create_and_seek()
{
	const char *file = "text.txt";
	char buf[32];

	// delete the file if it exists, we don't care if we error here
	unlink(file);

	/* open file for reading and writing, with owner read/write permissions */
	int mode = FAM_READ | FAM_WRITE;
	int perms = FAP_READ | FAP_WRITE;
	int path = create(file, mode, perms);
	if (path != -1)
	{
		printf("%s [PASS] create(\"%s\", %x, %d) = %d\n", __func__, file, mode, perms, path);
		const char *message = "this is a line of text\n";
		int length = strlen(message);
		int result = writeln(path, message, length);
		if (result == length)
		{
			printf("%s [PASS] writeln(%d, \"%s\", %d) = %d\n", __func__, path, message, length, result);
			long offset = 5;
			int whence = 0;
			long seek_result = lseek(path, offset, whence);
			if (seek_result == offset)
			{
				int readsize = 2;
				memset(buf, 0, sizeof(buf));
				printf("%s [PASS] lseek(%d, %ld, %d) = %ld\n", __func__, path, offset, whence, seek_result);
				result = read(path, buf, readsize);
				if (readsize == result && buf[0] == 'i' && buf[1] == 's')
				{
					printf("%s [PASS] read(%d, \"is\", %d) = %d\n", __func__, path, readsize, result);
				}
				else
				{
					failed = 1;
					printf("%s [FAIL] read(%d, expected \"is\", %d) = %d got=\"%c%c\"\n",
					       __func__, path, readsize, result, buf[0], buf[1]);
				}
			}
			else
			{
				failed = 1;
				printf("%s [FAIL] lseek(%d, %ld, %d) = %ld\n", __func__, path, offset, whence, seek_result);
			}

			offset = -5;
			whence = 2;
			seek_result = lseek(path, offset, whence);
			if (seek_result == (long) length - 5)
			{
				int readsize = 4;
				memset(buf, 0, sizeof(buf));
				printf("%s [PASS] lseek(%d, %ld, %d) = %ld\n", __func__, path, offset, whence, seek_result);
				result = read(path, buf, readsize);
				if (readsize == result && strncmp(buf, "text", 4) == 0)
				{
					printf("%s [PASS] read(%d, \"text\", %d) = %d\n", __func__, path, readsize, result);
				}
				else
				{
					failed = 1;
					printf("%s [FAIL] read(%d, expected \"text\", %d) = %d got=\"%s\"\n",
					       __func__, path, readsize, result, buf);
				}
			}
			else
			{
				failed = 1;
				printf("%s [FAIL] lseek(%d, %ld, %d) = %ld\n", __func__, path, offset, whence, seek_result);
			}

			offset = -2;
			whence = 1;
			seek_result = lseek(path, offset, whence);
			if (seek_result == (long) length - 3)
			{
				int readsize = 2;
				memset(buf, 0, sizeof(buf));
				printf("%s [PASS] lseek(%d, %ld, %d) = %ld\n", __func__, path, offset, whence, seek_result);
				result = read(path, buf, readsize);
				if (readsize == result && strncmp(buf, "xt", 2) == 0)
				{
					printf("%s [PASS] read(%d, \"xt\", %d) = %d\n", __func__, path, readsize, result);
				}
				else
				{
					failed = 1;
					printf("%s [FAIL] read(%d, expected \"xt\", %d) = %d got=\"%c%c\"\n",
					       __func__, path, readsize, result, buf[0], buf[1]);
				}
			}
			else
			{
				failed = 1;
				printf("%s [FAIL] lseek(%d, %ld, %d) = %ld\n", __func__, path, offset, whence, seek_result);
			}
			close(path);
			unlink(file);
		}
		else
		{
			failed = 1;
			printf("%s [FAIL] writeln(%d, \"%s\", %d) = %d\n", __func__, path, message, length, result);
		}
	}
	else
	{
		failed = 1;
		printf("%s [FAIL] create(\"%s\", %x, %d) = %d\n", __func__, file, mode, perms, path);
	}
}

void test_make_directory()
{
	const char *file = "newdirectory";

	int perm = FAP_DIR | FAP_READ | FAP_WRITE | FAP_PREAD;
	int result = mknod(file, perm);
	if (result == 0)
	{
		printf("%s [PASS] mknod(\"%s\", %d) = %d\n", __func__, file, perm, result);
	}
	else
	{
		failed = 1;
		printf("%s [FAIL] mknod(\"%s\", %d) = %d\n", __func__, file, perm, result);
	}
}

void test_make_and_attr_file()
{
	const char *file = "newfile";

	int mode = FAM_READ | FAM_WRITE;
	int perm = FAP_READ | FAP_WRITE;
	int path = create(file, mode, perm);
	if (path != -1)
	{
		printf("%s [PASS] create(\"%s\", %x, %d) = %d\n", __func__, file, mode, perm, path);
		close(path);
#if 0
		perm = FAP_READ | FAP_WRITE | FAP_PREAD | FAP_PWRITE;
		int result = _os_ss_attr(file, perm);
		if (result == 0)
		{
		printf("%s [PASS] _os_ss_attr(\"%s\", %x, %d) = %d\n", __func__, file, mode, perm, path);
		}
		else
		{
			failed = 1;
			printf("%s [FAIL] _os_ss_attr(\"%s\", %d) = %d\n", __func__, file, perm, result);
		}
#endif
		unlink(file);
	}
	else
	{
		failed = 1;
		printf("%s [FAIL] create(\"%s\", %x, %d) = %d\n", __func__, file, mode, perm, path);
	}
}

void test_access_dup_unlinkx()
{
	const char *file = "access.tmp";
	int mode = FAM_READ | FAM_WRITE;
	int perms = FAP_READ | FAP_WRITE;
	const char *payload = "dup-check";
	char buf[16];
	int path;
	int dup_path;
	int result;

	unlink(file);

	path = create(file, mode, perms);
	if (path == -1)
	{
		failed = 1;
		printf("%s [FAIL] create(\"%s\", %x, %d) = %d, errno = %d\n", __func__, file, mode, perms, path, errno);
		return;
	}
	printf("%s [PASS] create(\"%s\", %x, %d) = %d\n", __func__, file, mode, perms, path);
	result = write(path, payload, strlen(payload));
	if (result == strlen(payload))
		printf("%s [PASS] write(\"%s\") = %d\n", __func__, payload, result);
	else {
		failed = 1;
		printf("%s [FAIL] write(\"%s\") = %d, errno = %d\n", __func__, payload, result, errno);
		close(path);
		unlink(file);
		return;
	}
	close(path);

	result = access(file, FAM_READ);
	if (result == 0)
		printf("%s [PASS] access(\"%s\", %x) = %d\n", __func__, file, FAM_READ, result);
	else {
		failed = 1;
		printf("%s [FAIL] access(\"%s\", %x) = %d, errno = %d\n", __func__, file, FAM_READ, result, errno);
	}

	result = access("missing.tmp", FAM_READ);
	if (result == -1)
		printf("%s [PASS] access(\"missing.tmp\", %x) = %d\n", __func__, FAM_READ, result);
	else {
		failed = 1;
		printf("%s [FAIL] access(\"missing.tmp\", %x) = %d\n", __func__, FAM_READ, result);
	}

	path = open(file, FAM_READ);
	if (path == -1)
	{
		failed = 1;
		printf("%s [FAIL] open(\"%s\", %x) = %d, errno = %d\n", __func__, file, FAM_READ, path, errno);
		unlink(file);
		return;
	}
	printf("%s [PASS] open(\"%s\", %x) = %d\n", __func__, file, FAM_READ, path);

	dup_path = dup(path);
	if (dup_path != -1)
	{
		printf("%s [PASS] dup(%d) = %d\n", __func__, path, dup_path);
		close(path);
		memset(buf, 0, sizeof(buf));
		result = read(dup_path, buf, strlen(payload));
		if (result == strlen(payload) && strcmp(buf, payload) == 0)
			printf("%s [PASS] read(dup path) = %d\n", __func__, result);
		else {
			failed = 1;
			printf("%s [FAIL] read(dup path) = %d got=\"%s\" errno=%d\n", __func__, result, buf, errno);
		}
		close(dup_path);
	}
	else
	{
		failed = 1;
		printf("%s [FAIL] dup(%d) = %d, errno = %d\n", __func__, path, dup_path, errno);
		close(path);
	}

	result = unlinkx(file, FAM_WRITE);
	if (result == 0)
		printf("%s [PASS] unlinkx(\"%s\", %x) = %d\n", __func__, file, FAM_WRITE, result);
	else {
		failed = 1;
		printf("%s [FAIL] unlinkx(\"%s\", %x) = %d, errno = %d\n", __func__, file, FAM_WRITE, result, errno);
	}
}

int main()
{
	test_create_and_delete_file();
	test_open_nonexistent_file();
	test_open_read_close_existing_file();
	test_readln_existing_file();
	test_write_zero_count();
	test_delete_nonexistent_file();
	test_create_and_seek();
	test_make_directory();
	test_make_and_attr_file();
	test_access_dup_unlinkx();

	return failed;
}
