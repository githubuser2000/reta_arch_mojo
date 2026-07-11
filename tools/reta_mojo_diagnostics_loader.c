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
#define RETA_ABI_VERSION 1

typedef int (*reta_entry_fn)(int, char **);
typedef int (*reta_version_fn)(void);

struct command_spec {
    const char *name;
    const char *executable;
    const char *symbol;
};

static const struct command_spec COMMANDS[] = {
    {"table-generation", "reta-mojo-table-generation", "reta_mojo_table_generation_entry"},
    {"output-syntax", "reta-mojo-output-syntax", "reta_mojo_output_syntax_entry"},
    {"console-io", "reta-mojo-console-io", "reta_mojo_console_io_entry"},
    {"table-output", "reta-mojo-table-output", "reta_mojo_table_output_entry"},
};

static const char *base_name(const char *path) {
    const char *slash = strrchr(path, '/');
    return slash ? slash + 1 : path;
}

static const struct command_spec *find_command(const char *value) {
    size_t count = sizeof(COMMANDS) / sizeof(COMMANDS[0]);
    for (size_t i = 0; i < count; ++i) {
        if (strcmp(value, COMMANDS[i].name) == 0 ||
            strcmp(value, COMMANDS[i].executable) == 0) {
            return &COMMANDS[i];
        }
    }
    return NULL;
}

static void usage(FILE *stream) {
    fprintf(stream,
            "reta-mojo-diagnostics COMMAND [ARGUMENTS...]\n"
            "COMMAND: table-generation | output-syntax | console-io | table-output\n");
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

static int library_path(char *buffer, size_t size, const char *argv0) {
    const char *override = getenv("RETA_DIAGNOSTICS_LIBRARY");
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
    const char *library_name = "libreta_diagnostics_mojo.dylib";
#elif defined(_WIN32)
    const char *library_name = "libreta_diagnostics_mojo.dll";
#else
    const char *library_name = "libreta_diagnostics_mojo.so";
#endif

    int written = snprintf(buffer, size, "%s/../lib/reta/%s", executable, library_name);
    if (written >= 0 && (size_t)written < size && access(buffer, R_OK) == 0) {
        return 0;
    }
    written = snprintf(buffer, size, "%s/../lib/%s", executable, library_name);
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
    int executable_stamp_status = read_stamp(executable_stamp, executable_id, sizeof(executable_id));
    int library_stamp_status = read_stamp(library_stamp, library_id, sizeof(library_id));
    if (executable_stamp_status != 0 && library_stamp_status != 0) {
        return 0;
    }
    if (executable_stamp_status != 0 || library_stamp_status != 0 ||
        strcmp(executable_id, library_id) != 0) {
        fprintf(stderr,
                "Diagnose-Loader und Shared Library stammen nicht aus demselben Quellstand.\n"
                "Bitte neu kompilieren: scripts/build.sh\n");
        return RETA_STALE_STATUS;
    }
    return 0;
}

int main(int argc, char **argv) {
    const char *invoked_as = base_name(argc > 0 ? argv[0] : "");
    const struct command_spec *command = find_command(invoked_as);
    int forwarded_argc = argc;
    char **forwarded_argv = argv;
    char **allocated_argv = NULL;

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
        forwarded_argc = argc - 1;
        allocated_argv = calloc((size_t)forwarded_argc + 1, sizeof(char *));
        if (allocated_argv == NULL) {
            fprintf(stderr, "Nicht genug Speicher für Argumentweitergabe.\n");
            return 70;
        }
        allocated_argv[0] = (char *)command->executable;
        for (int i = 2; i < argc; ++i) {
            allocated_argv[i - 1] = argv[i];
        }
        forwarded_argv = allocated_argv;
    }

    char library[PATH_MAX];
    if (library_path(library, sizeof(library), argc > 0 ? argv[0] : NULL) != 0) {
        fprintf(stderr, "Pfad der Diagnosebibliothek konnte nicht bestimmt werden.\n");
        free(allocated_argv);
        return 127;
    }

    int stamp_status = verify_matching_stamps(argc > 0 ? argv[0] : NULL, library);
    if (stamp_status != 0) {
        free(allocated_argv);
        return stamp_status;
    }

    void *handle = dlopen(library, RTLD_NOW | RTLD_LOCAL);
    if (handle == NULL) {
        fprintf(stderr, "Diagnosebibliothek konnte nicht geladen werden: %s\n", dlerror());
        free(allocated_argv);
        return 127;
    }

    dlerror();
    reta_version_fn version = (reta_version_fn)dlsym(handle, "reta_mojo_diagnostics_abi_version");
    const char *symbol_error = dlerror();
    if (symbol_error != NULL || version == NULL || version() != RETA_ABI_VERSION) {
        fprintf(stderr, "Unpassende Diagnosebibliothek-ABI.\n");
        free(allocated_argv);
        return 78;
    }

    dlerror();
    reta_entry_fn entry = (reta_entry_fn)dlsym(handle, command->symbol);
    symbol_error = dlerror();
    if (symbol_error != NULL || entry == NULL) {
        fprintf(stderr, "Diagnoseeinstieg fehlt: %s\n", command->symbol);
        free(allocated_argv);
        return 127;
    }

    int status = entry(forwarded_argc, forwarded_argv);
    /* Keep the Mojo DSO loaded until process teardown.  This avoids running
       its runtime destructors before the process-wide Mojo runtime exits. */
    free(allocated_argv);
    return status;
}
