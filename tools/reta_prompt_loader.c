#define _POSIX_C_SOURCE 200809L
#define _XOPEN_SOURCE 700

#include <dlfcn.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#ifndef PATH_MAX
#define PATH_MAX 4096
#endif

#define RETA_STALE_STATUS 78
#define RETA_PROMPT_ABI_VERSION 1

struct prompt_command {
    const char *name;
    const char *profile;
    const char *library_name;
    const char *library_env;
    const char *version_symbol;
    const char *entry_symbol;
    int interactive;
};

typedef int (*prompt_entry_fn)(int, char **);
typedef int (*prompt_version_fn)(void);

static const struct prompt_command COMMANDS[] = {
    {"rpb", "rpb", "libreta-prompt.so", "RETA_PROMPT_LIBRARY",
     "reta_prompt_abi_version", "reta_prompt_entry", 0},
    {"rp", "rp", "libreta-prompt-interactive.so", "RETA_PROMPT_INTERACTIVE_LIBRARY",
     "reta_prompt_interactive_abi_version", "reta_prompt_interactive_entry", 1},
    {"rpl", "rpl", "libreta-prompt-interactive.so", "RETA_PROMPT_INTERACTIVE_LIBRARY",
     "reta_prompt_interactive_abi_version", "reta_prompt_interactive_entry", 1},
    {"rpe", "rpe", "libreta-prompt-interactive.so", "RETA_PROMPT_INTERACTIVE_LIBRARY",
     "reta_prompt_interactive_abi_version", "reta_prompt_interactive_entry", 1},
    {"retaPrompt", "retaPrompt", "libreta-prompt-interactive.so",
     "RETA_PROMPT_INTERACTIVE_LIBRARY", "reta_prompt_interactive_abi_version",
     "reta_prompt_interactive_entry", 1},
    {"retaPrompt.english", "retaPrompt.english", "libreta-prompt-interactive.so",
     "RETA_PROMPT_INTERACTIVE_LIBRARY", "reta_prompt_interactive_abi_version",
     "reta_prompt_interactive_entry", 1},
};

static const struct prompt_command COMMON_PROMPT_LIBRARY = {
    "rpb", "rpb", "libreta-prompt.so", "RETA_PROMPT_LIBRARY",
    "reta_prompt_abi_version", "reta_prompt_entry", 0,
};

static const char *base_name(const char *path) {
    const char *slash = strrchr(path, '/');
    return slash ? slash + 1 : path;
}

static const struct prompt_command *find_command(const char *value) {
    size_t count = sizeof(COMMANDS) / sizeof(COMMANDS[0]);
    for (size_t i = 0; i < count; ++i) {
        if (strcmp(value, COMMANDS[i].name) == 0) {
            return &COMMANDS[i];
        }
    }
    return NULL;
}

static void usage(FILE *stream) {
    fprintf(stream,
            "reta-prompt-loader COMMAND [ARGUMENTS...]\n"
            "COMMAND: rp | rpl | rpe | rpb | retaPrompt | retaPrompt.english\n");
}

static int executable_path(char *buffer, size_t size, const char *argv0) {
#if defined(__linux__)
    ssize_t length = readlink("/proc/self/exe", buffer, size - 1);
    if (length >= 0) {
        buffer[length] = '\0';
        return 0;
    }
#endif
    if (argv0 == NULL || argv0[0] == '\0') {
        return -1;
    }
    if (realpath(argv0, buffer) != NULL) {
        return 0;
    }
    if (strlen(argv0) + 1 > size) {
        return -1;
    }
    memcpy(buffer, argv0, strlen(argv0) + 1);
    return 0;
}

static int library_path(
    char *buffer,
    size_t size,
    const char *argv0,
    const struct prompt_command *command
) {
    const char *override = getenv(command->library_env);
    if (override != NULL && override[0] != '\0') {
        if (strlen(override) + 1 > size) {
            return -1;
        }
        memcpy(buffer, override, strlen(override) + 1);
        return 0;
    }

    char executable[PATH_MAX];
    if (executable_path(executable, sizeof(executable), argv0) != 0) {
        return -1;
    }
    char *slash = strrchr(executable, '/');
    if (slash == NULL) {
        return -1;
    }
    *slash = '\0';

#if defined(__APPLE__)
    const char *extension = ".dylib";
#elif defined(_WIN32)
    const char *extension = ".dll";
#else
    const char *extension = ".so";
#endif

    char library_name[128];
    if (strcmp(extension, ".so") == 0) {
        if (snprintf(library_name, sizeof(library_name), "%s", command->library_name) >=
            (int)sizeof(library_name)) {
            return -1;
        }
    } else if (strcmp(command->library_name, "libreta-prompt.so") == 0) {
        if (snprintf(library_name, sizeof(library_name), "libreta-prompt%s", extension) >=
            (int)sizeof(library_name)) {
            return -1;
        }
    } else {
        if (snprintf(library_name, sizeof(library_name), "libreta-prompt-interactive%s", extension) >=
            (int)sizeof(library_name)) {
            return -1;
        }
    }

    int written = snprintf(buffer, size, "%s/../lib/reta/%s", executable, library_name);
    return written < 0 || (size_t)written >= size ? -1 : 0;
}

static int read_stamp(const char *path, char *buffer, size_t size) {
    FILE *file = fopen(path, "r");
    if (file == NULL) {
        return -1;
    }
    if (fgets(buffer, (int)size, file) == NULL) {
        fclose(file);
        return -1;
    }
    fclose(file);
    buffer[strcspn(buffer, "\r\n")] = '\0';
    return buffer[0] == '\0' ? -1 : 0;
}

static int verify_matching_stamps(const char *argv0, const char *library) {
    char executable[PATH_MAX];
    char executable_stamp[PATH_MAX];
    char library_stamp[PATH_MAX];
    char executable_id[128];
    char library_id[128];

    if (executable_path(executable, sizeof(executable), argv0) != 0) {
        return RETA_STALE_STATUS;
    }
    if (snprintf(executable_stamp, sizeof(executable_stamp), "%s.reta-source-id", executable) >=
            (int)sizeof(executable_stamp) ||
        snprintf(library_stamp, sizeof(library_stamp), "%s.reta-source-id", library) >=
            (int)sizeof(library_stamp)) {
        return RETA_STALE_STATUS;
    }
    if (read_stamp(executable_stamp, executable_id, sizeof(executable_id)) != 0 ||
        read_stamp(library_stamp, library_id, sizeof(library_id)) != 0 ||
        strcmp(executable_id, library_id) != 0) {
        fprintf(stderr,
                "Prompt-Starter und Shared Library stammen nicht aus demselben Quellstand.\n"
                "Bitte neu kompilieren: scripts/build_prompt_shared.sh\n");
        return RETA_STALE_STATUS;
    }
    return 0;
}

static char **forwarded_arguments(
    int argc,
    char **argv,
    const struct prompt_command *command,
    int skip_command
) {
    int tail_start = skip_command ? 2 : 1;
    int tail_count = argc > tail_start ? argc - tail_start : 0;
    char **result = calloc((size_t)tail_count + 2, sizeof(char *));
    if (result == NULL) {
        return NULL;
    }
    result[0] = (char *)command->profile;
    for (int i = 0; i < tail_count; ++i) {
        result[i + 1] = argv[tail_start + i];
    }
    return result;
}

static int open_prompt_library(
    const char *argv0,
    const struct prompt_command *library_command,
    int dlopen_flags,
    void **handle_out
) {
    char library[PATH_MAX];
    if (library_path(library, sizeof(library), argv0, library_command) != 0) {
        fprintf(stderr, "Pfad der Prompt-Bibliothek konnte nicht bestimmt werden.\n");
        return 127;
    }

    int stamp_status = verify_matching_stamps(argv0, library);
    if (stamp_status != 0) {
        return stamp_status;
    }

    void *handle = dlopen(library, dlopen_flags);
    if (handle == NULL) {
        fprintf(stderr, "Prompt-Bibliothek konnte nicht geladen werden: %s\n", dlerror());
        return 127;
    }

    dlerror();
    prompt_version_fn version =
        (prompt_version_fn)dlsym(handle, library_command->version_symbol);
    const char *symbol_error = dlerror();
    if (symbol_error != NULL || version == NULL ||
        version() != RETA_PROMPT_ABI_VERSION) {
        fprintf(stderr, "Unpassende Prompt-Bibliothek-ABI.\n");
        return 78;
    }

    *handle_out = handle;
    return 0;
}

int main(int argc, char **argv) {
    const char *invoked_as = base_name(argc > 0 ? argv[0] : "");
    const struct prompt_command *command = find_command(invoked_as);
    int skip_command = 0;

    if (command == NULL) {
        if (argc < 2) {
            usage(stderr);
            return 2;
        }
        command = find_command(argv[1]);
        if (command == NULL) {
            usage(stderr);
            return 2;
        }
        skip_command = 1;
    }

    int forwarded_argc = argc - (skip_command ? 1 : 0);
    if (forwarded_argc < 1) {
        forwarded_argc = 1;
    }
    char **forwarded_argv = forwarded_arguments(argc, argv, command, skip_command);
    if (forwarded_argv == NULL) {
        fprintf(stderr, "Nicht genug Speicher für Prompt-Argumentweitergabe.\n");
        return 70;
    }

    void *prompt_handle = NULL;
    if (command->interactive) {
        int prompt_status = open_prompt_library(
            argc > 0 ? argv[0] : NULL,
            &COMMON_PROMPT_LIBRARY,
            RTLD_NOW | RTLD_GLOBAL,
            &prompt_handle
        );
        if (prompt_status != 0) {
            free(forwarded_argv);
            return prompt_status;
        }
    }

    void *handle = NULL;
    int open_status = open_prompt_library(
        argc > 0 ? argv[0] : NULL,
        command,
        RTLD_NOW | RTLD_LOCAL,
        &handle
    );
    if (open_status != 0) {
        free(forwarded_argv);
        return open_status;
    }

    dlerror();
    prompt_entry_fn entry = (prompt_entry_fn)dlsym(handle, command->entry_symbol);
    const char *symbol_error = dlerror();
    if (symbol_error != NULL || entry == NULL) {
        fprintf(stderr, "Prompt-Einstieg fehlt: %s\n", command->entry_symbol);
        free(forwarded_argv);
        return 127;
    }

    int status = entry(forwarded_argc, forwarded_argv);
    free(forwarded_argv);
    return status;
}
