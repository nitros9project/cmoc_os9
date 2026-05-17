#include <dir.h>
#include <stdio.h>
#include <string.h>

int main(void)
{
    DIR *dirp;
    DIRECT *first;
    DIRECT *second;
    DIRECT *again;
    long pos;

    dirp = opendir(".");
    if (dirp == 0) {
        printf("dirtest [FAIL] opendir\n");
        return 1;
    }
    first = readdir(dirp);
    if (first == 0) {
        printf("dirtest [FAIL] readdir first\n");
        closedir(dirp);
        return 1;
    }
    printf("dirtest [PASS] first=%s\n", first->d_name);

    pos = telldir(dirp);
    second = readdir(dirp);
    if (second == 0) {
        printf("dirtest [PASS] telldir=%ld end-of-dir\n", pos);
        closedir(dirp);
        return 0;
    }

    seekdir(dirp, pos);
    again = readdir(dirp);
    if (again == 0) {
        printf("dirtest [FAIL] readdir after seekdir\n");
        closedir(dirp);
        return 1;
    }
    if (strcmp(second->d_name, again->d_name) != 0) {
        printf("dirtest [FAIL] seekdir mismatch %s != %s\n", second->d_name, again->d_name);
        closedir(dirp);
        return 1;
    }

    printf("dirtest [PASS] seekdir=%s\n", again->d_name);
    closedir(dirp);
    return 0;
}
