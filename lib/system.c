#include <stdlib.h>
#include <string.h>
#include <os.h>

static char *build_module_name(const char *command)
{
    const char *end = command;
    char *module;
    int len;

    while (*end != ' ' && *end != '\0')
        ++end;

    len = end - command;
    if (len == 0)
        return 0;

    module = (char *) malloc(len + 1);
    if (module == 0)
        return 0;

    memcpy(module, command, len);
    module[len] = '\0';
    return module;
}

static char *build_parameter_string(const char *command, int *param_size)
{
    char *params;
    int arg_len;

    arg_len = strlen(command);
    params = (char *) malloc(arg_len + 2);
    if (params == 0)
        return 0;

    strcpy(params, command);
    strcat(params, "\n");
    *param_size = arg_len + 1;
    return params;
}

int system(const char *command)
{
    char *module;
    char *parameter;
    int param_size;
    int pid;
    int waited_pid;
    int status;

    if (command == 0)
        return 1;

    module = build_module_name(command);
    if (module == 0)
        return -1;

    parameter = build_parameter_string(command, &param_size);
    if (parameter == 0) {
        free(module);
        return -1;
    }

    if (_os_fork(module, param_size, parameter, Objct, Prgrm, 0, &pid) != 0) {
        free(module);
        if (parameter != 0)
            free(parameter);
        return -1;
    }

    free(module);
    if (parameter != 0)
        free(parameter);

    while ((waited_pid = _os_wait(&status)) >= 0) {
        if (waited_pid == pid)
            return status;
    }

    return -1;
}
