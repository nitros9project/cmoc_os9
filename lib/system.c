#include <stdlib.h>
#include <string.h>
#include <os.h>

static char *build_parameter_string(const char *command, int *param_size)
{
    const char *space = command;
    char *params;
    int arg_len;

    while (*space != ' ' && *space != '\0')
        ++space;
    if (*space == ' ')
        ++space;

    arg_len = strlen(space);
    if (arg_len == 0) {
        params = (char *) malloc(2);
        if (params == 0)
            return 0;
        params[0] = '\n';
        params[1] = '\0';
        *param_size = 1;
        return params;
    }

    params = (char *) malloc(arg_len + 2);
    if (params == 0)
        return 0;

    strcpy(params, space);
    strcat(params, "\n");
    *param_size = arg_len + 1;
    return params;
}

int system(const char *command)
{
    char *parameter;
    int param_size;
    int pid;
    int waited_pid;
    int status;

    if (command == 0)
        return 1;

    parameter = build_parameter_string(command, &param_size);
    if (parameter == 0)
        return -1;

    if (_os_fork(command, param_size, parameter, Objct, Prgrm, 0, &pid) != 0) {
        if (parameter != 0)
            free(parameter);
        return -1;
    }

    if (parameter != 0)
        free(parameter);

    while ((waited_pid = _os_wait(&status)) >= 0) {
        if (waited_pid == pid)
            return status;
    }

    return -1;
}
