#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <string.h>
#include <fcntl.h>

void test_create_and_delete_file()
{
	char *file = "existentfile";
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
				printf("%s [FAIL] unlink(\"%s\") = %d, errno = %d\n", __func__, file, result, errno);
			}
		}
		else
		{
			printf("%s [FAIL] close(%d) = %d, errno = %d\n", __func__, path, result, errno);
		}
	}
	else
	{
		printf("%s [FAIL] create(\"%s\", %d, %x) = %d, errno = %d\n", __func__, file, mode, perms, path, errno);
	}
}

void test_open_nonexistent_file()
{
	char *file = "nonexistentfile";

	int mode = FAM_READ;
	int path = open(file, mode);
	if (path == -1)
	{
		printf("%s [PASS] open(\"%s\", %x) = %d\n", __func__, file, mode, path);
	}
	else
	{
		printf("%s [FAIL] open(\"%s\", %x) = %d\n", __func__, file, mode, path);
	}
}

void test_delete_nonexistent_file()
{
	char *file = "deletenonexistentfile";
	
	int result = unlink(file);
	if (result == -1)
	{
		printf("%s [PASS] unlink(\"%s\") = %d\n", __func__, file, result);
	}
	else
	{
		printf("%s [FAIL] unlink(\"%s\") = %d\n", __func__, file, result);
	}
}

/* test creation of a small file and seeking from various directions (start, current, end)
   coverage of this test is currently weak. A good test would be to add a large content file
   and seek within that.
   */
void test_create_and_seek()
{
	char *file = "text.txt";
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
		char *message = "this is a line of text\n";
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
					printf("%s [FAIL] read(%d, expected \"is\", %d) = %d got=\"%c%c\"\n",
					       __func__, path, readsize, result, buf[0], buf[1]);
				}
			}
			else
			{
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
					printf("%s [FAIL] read(%d, expected \"text\", %d) = %d got=\"%s\"\n",
					       __func__, path, readsize, result, buf);
				}
			}
			else
			{
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
					printf("%s [FAIL] read(%d, expected \"xt\", %d) = %d got=\"%c%c\"\n",
					       __func__, path, readsize, result, buf[0], buf[1]);
				}
			}
			else
			{
				printf("%s [FAIL] lseek(%d, %ld, %d) = %ld\n", __func__, path, offset, whence, seek_result);
			}
			close(path);
			unlink(file);
		}
		else
		{
			printf("%s [FAIL] writeln(%d, \"%s\", %d) = %d\n", __func__, path, message, length, result);
		}
	}
	else
	{
		printf("%s [FAIL] create(\"%s\", %x, %d) = %d\n", __func__, file, mode, perms, path);
	}
}

void test_make_directory()
{
	char *file = "newdirectory";

	int perm = FAP_DIR | FAP_READ | FAP_WRITE | FAP_PREAD;
	int result = mknod(file, perm);
	if (result == 0)
	{
		printf("%s [PASS] mknod(\"%s\", %d) = %d\n", __func__, file, perm, result);
	}
	else
	{
		printf("%s [FAIL] mknod(\"%s\", %d) = %d\n", __func__, file, perm, result);
	}
}

void test_make_and_attr_file()
{
	char *file = "newfile";

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
			printf("%s [FAIL] _os_ss_attr(\"%s\", %d) = %d\n", __func__, file, perm, result);
		}
#endif
		unlink(file);
	}
	else
	{
		printf("%s [FAIL] create(\"%s\", %x, %d) = %d\n", __func__, file, mode, perm, path);
	}
}

void test_access_dup_unlinkx()
{
	char *file = "access.tmp";
	int mode = FAM_READ | FAM_WRITE;
	int perms = FAP_READ | FAP_WRITE;
	int path;
	int dup_path;
	int result;

	unlink(file);

	path = create(file, mode, perms);
	if (path == -1)
	{
		printf("%s [FAIL] create(\"%s\", %x, %d) = %d, errno = %d\n", __func__, file, mode, perms, path, errno);
		return;
	}
	printf("%s [PASS] create(\"%s\", %x, %d) = %d\n", __func__, file, mode, perms, path);
	close(path);

	result = access(file, FAM_READ);
	if (result == 0)
		printf("%s [PASS] access(\"%s\", %x) = %d\n", __func__, file, FAM_READ, result);
	else
		printf("%s [FAIL] access(\"%s\", %x) = %d, errno = %d\n", __func__, file, FAM_READ, result, errno);

	result = access("missing.tmp", FAM_READ);
	if (result == -1)
		printf("%s [PASS] access(\"missing.tmp\", %x) = %d\n", __func__, FAM_READ, result);
	else
		printf("%s [FAIL] access(\"missing.tmp\", %x) = %d\n", __func__, FAM_READ, result);

	path = open(file, FAM_READ);
	if (path == -1)
	{
		printf("%s [FAIL] open(\"%s\", %x) = %d, errno = %d\n", __func__, file, FAM_READ, path, errno);
		unlink(file);
		return;
	}
	printf("%s [PASS] open(\"%s\", %x) = %d\n", __func__, file, FAM_READ, path);

	dup_path = dup(path);
	if (dup_path != -1)
	{
		printf("%s [PASS] dup(%d) = %d\n", __func__, path, dup_path);
		close(dup_path);
	}
	else
	{
		printf("%s [FAIL] dup(%d) = %d, errno = %d\n", __func__, path, dup_path, errno);
	}
	close(path);

	result = unlinkx(file, FAM_WRITE);
	if (result == 0)
		printf("%s [PASS] unlinkx(\"%s\", %x) = %d\n", __func__, file, FAM_WRITE, result);
	else
		printf("%s [FAIL] unlinkx(\"%s\", %x) = %d, errno = %d\n", __func__, file, FAM_WRITE, result, errno);
}

int main()
{
	test_create_and_delete_file();
	test_open_nonexistent_file();
	test_delete_nonexistent_file();
	test_create_and_seek();
	test_make_directory();
	test_make_and_attr_file();
	test_access_dup_unlinkx();

	return 0;
}
