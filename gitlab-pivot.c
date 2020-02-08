#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/**
 * The compiled code must be owned by the gitlab user and gitlab group.
 * Furthermore, it must have its setuid and setgid bits set. The system user
 * that invokes this program is granted the rights of the gitlab user with the
 * same username.
 *
 * It must be impossible for a normal user to get this code to spawn, say,
 * /bin/bash. Therefore, we do not get the path to gitlab-shell from an
 * environment variable and we do not search PATH for its full path.
 */

#ifndef GITLAB_SHELL
#error "Set GITLAB_SHELL to the full path to gitlab-shell"
#endif

#define _Q(value) #value
#define STR(token) _Q(token)


int main(int argc, char *argv[])
{
    struct passwd *real_pw;
    char *name_arg;

    if (argc != 3 || strcmp(argv[1], "-c"))
    {
        fputs("Usage: gitlab-pivot -c COMMAND\n", stderr);
        return 1;
    }

    real_pw = getpwuid(getuid());
    if (!real_pw || !real_pw->pw_name)
    {
        fputs("Could not determine the username of the real user\n", stderr);
        return 1;
    }
    name_arg = malloc((strlen(real_pw->pw_name) + 10) * sizeof(char));
    if (!name_arg)
    {
        fputs("Out of memory\n", stderr);
        return 1;
    }
    sprintf(name_arg, "username-%s", real_pw->pw_name);

    setenv("SSH_ORIGINAL_COMMAND", argv[2], 1);
    return execl(STR(GITLAB_SHELL), STR(GITLAB_SHELL), name_arg, (char *) NULL);
}
