#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <os.h>

#define ERR (-1)

static int popen_pid[_NFILE];

static char *build_parameter_string(const char *command, int *param_size)
{
	char *params;
	char *space;
	int arg_len;

	space = command;
	while (*space != ' ' && *space != '\0')
		++space;
	if (*space == ' ')
		++space;

	arg_len = strlen(space);
	params = (char *) malloc(arg_len + 2);
	if (params == 0)
		return 0;

	strcpy(params, space);
	strcat(params, "\n");
	*param_size = arg_len + 1;
	return params;
}

FILE *popen(const char *command, const char *type)
{
	char *parameter;
	FILE *stream;
	int path;
	int pipefd;
	int param_size;
	int saved_fd;
	int pid;
	int mode;

	path = (*type == 'w') ? STDIN_FILENO : STDOUT_FILENO;
	mode = FAM_READ | FAM_WRITE;

	pipefd = open("/pipe", mode);
	if (pipefd == ERR)
		return 0;

	saved_fd = dup(path);
	if (saved_fd == ERR)
	{
		close(pipefd);
		return 0;
	}

	close(path);
	if (dup(pipefd) == ERR)
	{
		dup(saved_fd);
		close(saved_fd);
		close(pipefd);
		return 0;
	}

	parameter = build_parameter_string(command, &param_size);
	if (parameter == 0)
	{
		close(path);
		dup(saved_fd);
		close(saved_fd);
		close(pipefd);
		return 0;
	}

	if (_os_fork(command, param_size, parameter, Objct, Prgrm, 0, &pid) != 0)
	{
		free(parameter);
		close(path);
		dup(saved_fd);
		close(saved_fd);
		close(pipefd);
		return 0;
	}

	free(parameter);
	close(path);
	dup(saved_fd);
	close(saved_fd);

	stream = fdopen(pipefd, type);
	if (stream == 0)
	{
		int waited_pid;
		int status;

		close(pipefd);
		while ((waited_pid = _os_wait(&status)) >= 0)
		{
			if (waited_pid == pid)
				break;
		}
		return 0;
	}

	if (pipefd >= 0 && pipefd < _NFILE)
		popen_pid[pipefd] = pid;

	return stream;
}

int pclose(FILE *stream)
{
	int fd;
	int pid;
	int waited_pid;
	int status;

	fd = fileno(stream);
	pid = (fd >= 0 && fd < _NFILE) ? popen_pid[fd] : 0;

	fclose(stream);

	if (fd >= 0 && fd < _NFILE)
		popen_pid[fd] = 0;

	if (pid == 0)
		return ERR;

	while ((waited_pid = _os_wait(&status)) >= 0)
	{
		if (waited_pid == pid)
			return status;
	}

	return ERR;
}
