#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sets.h>

static int failed;

static void check(int condition, const char *name)
{
    if (condition) {
        printf("%s [PASS]\n", name);
    } else {
        printf("%s [FAIL]\n", name);
        failed = 1;
    }
}

int main(void)
{
    char *set1 = allocset();
    char *set2 = allocset();
    char *copy;

    if (set1 == 0 || set2 == 0) {
        printf("setstest [FAIL] allocset\n");
        return 1;
    }

    memset(set1, 0, 32);
    memset(set2, 0, 32);

    addc2set(set1, 'A');
    adds2set(set1, "BC");
    check(smember(set1, 'A') != 0, "smember A");
    check(smember(set1, 'B') != 0, "smember B");
    check(smember(set1, 'Z') == 0, "smember Z");

    rmfmset(set1, 'B');
    check(smember(set1, 'B') == 0, "rmfmset B");

    addc2set(set2, 'C');
    addc2set(set2, 'D');
    sunion(set1, set2);
    check(smember(set1, 'C') != 0, "sunion C");
    check(smember(set1, 'D') != 0, "sunion D");

    memset(set2, 0, 32);
    addc2set(set2, 'A');
    addc2set(set2, 'D');
    sintersect(set1, set2);
    check(smember(set1, 'A') != 0, "sintersect A");
    check(smember(set1, 'D') != 0, "sintersect D");
    check(smember(set1, 'C') == 0, "sintersect clears C");

    copy = dupset(set1);
    check(copy != 0, "dupset");
    if (copy != 0) {
        check(smember(copy, 'A') != 0, "dupset A");
        check(smember(copy, 'D') != 0, "dupset D");
        free(copy);
    }

    memset(set2, 0, 32);
    addc2set(set2, 'A');
    sdifference(set1, set2);
    check(smember(set1, 'A') == 0, "sdifference xor A");
    check(smember(set1, 'D') != 0, "sdifference keeps D");

    free(set1);
    free(set2);

    return failed;
}
