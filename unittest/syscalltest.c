#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <os.h>
#include <time.h>

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

static void check_int_equal(const char *name, int actual, int expected)
{
	if (actual == expected)
		printf("%s [PASS]\n", name);
	else {
		printf("%s [FAIL] actual=%d expected=%d\n", name, actual, expected);
		failed = 1;
	}
}

static error_code call_suser(int uid)
{
	registers_6809 regs;

	memset(&regs, 0, sizeof(regs));
	regs.y = uid;
	return _os_syscall(F$SUser, &regs);
}

static void test_writeln_syscall(void)
{
	const char *message = "print this!\n";
	registers_6809 regs;
	error_code result;

	memset(&regs, 0, sizeof(regs));
	regs.a = 1;
	regs.x = (int) message;
	regs.y = strlen(message);

	result = _os_syscall(I$WritLn, &regs);
	check_true("test_writeln_syscall _os_syscall(I$WritLn)", result == 0);
}

static void test_id_syscall(void)
{
	registers_6809 regs;
	error_code result;
	int pid = -1;
	int uid = -1;
	error_code wrapper_result;
	error_code uid_result;
	error_code null_result;
	error_code direct_suser_result;
	error_code asetuid_result;
	error_code setuid_result;

	memset(&regs, 0, sizeof(regs));
	result = _os_syscall(F$ID, &regs);
	check_true("test_id_syscall _os_syscall(F$ID)", result == 0);

	wrapper_result = _os_getpid(&pid);
	check_true("test_id_syscall _os_getpid()", wrapper_result == 0);
	if (result == 0 && wrapper_result == 0)
		check_true("test_id_syscall pid", regs.a == pid);

	uid_result = _os_getuid(&uid);
	check_true("test_id_syscall _os_getuid()", uid_result == 0);
	if (result == 0 && uid_result == 0)
		check_int_equal("test_id_syscall uid", uid, regs.y);

	null_result = _os_getpid((int *) 0);
	check_int_equal("test_id_syscall _os_getpid(NULL)", null_result, 0);

	null_result = _os_getuid((int *) 0);
	check_int_equal("test_id_syscall _os_getuid(NULL)", null_result, 0);

	if (uid_result == 0) {
		direct_suser_result = call_suser(uid);
		asetuid_result = _os_asetuid(uid);
		check_int_equal("test_id_syscall _os_asetuid(current)",
		                asetuid_result, direct_suser_result);

		setuid_result = _os_setuid(uid);
		if (uid == 0)
			check_int_equal("test_id_syscall _os_setuid(root current)",
			                setuid_result, direct_suser_result);
		else
			check_int_equal("test_id_syscall _os_setuid(non-root)",
			                setuid_result, E$FNA);
	}
}

static void test_time_syscall(void)
{
	registers_6809 regs;
	error_code result;
	struct _os_time via_wrapper;
	struct _os_time via_syscall;
	error_code wrapper_result;

	memset(&regs, 0, sizeof(regs));
	memset(&via_syscall, 0, sizeof(via_syscall));
	regs.x = (int) &via_syscall;

	result = _os_syscall(F$Time, &regs);
	check_true("test_time_syscall _os_syscall(F$Time)", result == 0);

	wrapper_result = _os_getime(&via_wrapper);
	check_true("test_time_syscall _os_getime()", wrapper_result == 0);
	if (result == 0 && wrapper_result == 0) {
		check_true("test_time_syscall year", via_syscall.year == via_wrapper.year);
		check_true("test_time_syscall month", via_syscall.month == via_wrapper.month);
		check_true("test_time_syscall day", via_syscall.day == via_wrapper.day);
	}
}

int main(void)
{
	test_writeln_syscall();
	test_id_syscall();
	test_time_syscall();
	return failed;
}
