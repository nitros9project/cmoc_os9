#include <stdio.h>

int main(void)
{
    char buf[BUFSIZ];

    setbuf(stdout, buf);
    if (stdout->_base != buf || stdout->_ptr != buf) {
        printf("%s [FAIL] setbuf(buffered)\n", __func__);
        return 0;
    }
    printf("%s [PASS] setbuf(buffered)\n", __func__);

    setbuf(stdout, 0);
    if ((stdout->_flag & _UNBUF) == 0)
        printf("%s [FAIL] setbuf(unbuffered)\n", __func__);
    else
        printf("%s [PASS] setbuf(unbuffered)\n", __func__);

    return 0;
}
