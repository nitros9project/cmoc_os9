#include <dir.h>
#include <stdio.h>
#include <string.h>

int main(void)
{
    DIR *dirp;
    DIRECT *first;
    DIRECT *second;
    DIRECT *again;
    char second_name[32];
    long pos;

    dirp = opendir("no_such_directory");
    if (dirp != 0) {
        printf("dirtest [FAIL] opendir nonexistent\n");
        closedir(dirp);
        return 1;
    }
    printf("dirtest [PASS] opendir nonexistent\n");

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
    strcpy(second_name, second->d_name);

    seekdir(dirp, pos);
    again = readdir(dirp);
    if (again == 0) {
        printf("dirtest [FAIL] readdir after seekdir\n");
        closedir(dirp);
        return 1;
    }
    if (strcmp(second_name, again->d_name) != 0) {
        printf("dirtest [FAIL] seekdir mismatch %s != %s\n", second_name, again->d_name);
        closedir(dirp);
        return 1;
    }

    printf("dirtest [PASS] seekdir=%s\n", again->d_name);
    closedir(dirp);
    return 0;
}
