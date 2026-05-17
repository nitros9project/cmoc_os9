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

static void test_writeln_syscall(void)
{
	char *message = "print this!\n";
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
	error_code wrapper_result;

	memset(&regs, 0, sizeof(regs));
	result = _os_syscall(F$ID, &regs);
	check_true("test_id_syscall _os_syscall(F$ID)", result == 0);

	wrapper_result = _os_getpid(&pid);
	check_true("test_id_syscall _os_getpid()", wrapper_result == 0);
	if (result == 0 && wrapper_result == 0)
		check_true("test_id_syscall pid", regs.a == pid);
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
