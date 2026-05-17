#include <stdio.h>

int main(void)
{
    char buf[BUFSIZ];
    char buf2[BUFSIZ];

    setbuf(stdout, buf);
    if (stdout->_base != buf || stdout->_ptr != stdout->_end || stdout->_bufsiz != BUFSIZ) {
        printf("%s [FAIL] setbuf(buffered)\n", __func__);
        return 1;
    }
    printf("%s [PASS] setbuf(buffered)\n", __func__);

    setbuf(stdout, 0);
    if ((stdout->_flag & _UNBUF) == 0) {
        printf("%s [FAIL] setbuf(unbuffered)\n", __func__);
        return 1;
    } else
        printf("%s [PASS] setbuf(unbuffered)\n", __func__);

    setbuf(stdout, buf2);
    if (stdout->_base != buf2 || stdout->_ptr != stdout->_end || stdout->_bufsiz != BUFSIZ) {
        printf("%s [FAIL] setbuf(rebuffered)\n", __func__);
        return 1;
    }
    printf("%s [PASS] setbuf(rebuffered)\n", __func__);

    return 0;
}
