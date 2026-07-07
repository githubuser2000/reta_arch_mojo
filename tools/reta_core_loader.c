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
#define RETA_CORE_ABI_VERSION 1

typedef int (*reta_entry_fn)(int, char **);
typedef int (*reta_version_fn)(void);

struct command_spec {
    const char *name;
    const char *executable;
    const char *symbol;
};

static const struct command_spec COMMANDS[] = {
    {"reta", "reta", "reta_core_reta_entry"},
    {"grundStrukHtml", "grundStrukHtml", "reta_core_grundstrukhtml_entry"},
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
            "reta-core-loader COMMAND [ARGUMENTS...]\n"
            "COMMAND: reta | grundStrukHtml\n");
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

static int readable_path(const char *path) {
    return access(path, R_OK) == 0;
}

static int format_library_path(
    char *buffer,
    size_t size,
    const char *directory,
    const char *relative,
    const char *library_name
) {
    int written;
    if (relative == NULL || relative[0] == '\0') {
        written = snprintf(buffer, size, "%s/%s", directory, library_name);
    } else {
        written = snprintf(buffer, size, "%s/%s/%s", directory, relative, library_name);
    }
    return written < 0 || (size_t)written >= size ? -1 : 0;
}


static int environment_is_set(const char *name) {
    const char *value = getenv(name);
    return value != NULL && value[0] != '\0';
}

static void set_environment_if_unset(const char *name, const char *value) {
    if (!environment_is_set(name) && value != NULL && value[0] != '\0') {
        setenv(name, value, 1);
    }
}

static int join_path(char *buffer, size_t size, const char *left, const char *right) {
    int written;
    if (left[0] == '\0' || strcmp(left, "/") == 0) {
        written = snprintf(buffer, size, "/%s", right);
    } else if (left[strlen(left) - 1] == '/') {
        written = snprintf(buffer, size, "%s%s", left, right);
    } else {
        written = snprintf(buffer, size, "%s/%s", left, right);
    }
    return written < 0 || (size_t)written >= size ? -1 : 0;
}

static int parent_directory(char *path) {
    char *slash = strrchr(path, '/');
    if (slash == NULL) {
        return -1;
    }
    if (slash == path) {
        slash[1] = '\0';
    } else {
        *slash = '\0';
    }
    return 0;
}

static int strip_suffix(char *path, const char *suffix) {
    size_t path_length = strlen(path);
    size_t suffix_length = strlen(suffix);
    if (path_length < suffix_length) {
        return -1;
    }
    if (strcmp(path + path_length - suffix_length, suffix) != 0) {
        return -1;
    }
    path[path_length - suffix_length] = '\0';
    if (path[0] == '\0') {
        strcpy(path, "/");
    }
    return 0;
}

static int directory_exists(const char *path) {
    return access(path, F_OK) == 0;
}

static void set_runtime_environment(const char *argv0) {
    char executable[PATH_MAX];
    char root[PATH_MAX];
    char prefix[PATH_MAX];
    char share[PATH_MAX];
    char csv[PATH_MAX];
    char assets[PATH_MAX];
    char reference[PATH_MAX];

    if (executable_path(executable, sizeof(executable), argv0) != 0) {
        return;
    }
    char *slash = strrchr(executable, '/');
    if (slash == NULL) {
        return;
    }
    *slash = '\0';

    if (strlen(executable) + 1 > sizeof(root)) {
        return;
    }
    memcpy(root, executable, strlen(executable) + 1);

    /* Build tree: target/bin/<starter> -> project root. */
    if (strip_suffix(root, "/target/bin") != 0) {
        /* Installed tree: /usr/lib/reta/<starter> -> private runtime root. */
        memcpy(root, executable, strlen(executable) + 1);
    }

    set_environment_if_unset("RETA_ROOT", root);

    if (join_path(reference, sizeof(reference), root, "python_reference") == 0) {
        set_environment_if_unset("RETA_REFERENCE_DIR", reference);
    }

    if (!environment_is_set("RETA_SHARE_DIR")) {
        if (strlen(root) + 1 <= sizeof(prefix)) {
            memcpy(prefix, root, strlen(root) + 1);
            if (parent_directory(prefix) == 0 && parent_directory(prefix) == 0 &&
                join_path(share, sizeof(share), prefix, "share/reta") == 0 &&
                join_path(csv, sizeof(csv), share, "csv") == 0 &&
                join_path(assets, sizeof(assets), share, "assets") == 0 &&
                directory_exists(csv) && directory_exists(assets)) {
                setenv("RETA_SHARE_DIR", share, 1);
            }
        }
    }

    if (!environment_is_set("RETA_DATA_DIR")) {
        const char *configured_share = getenv("RETA_SHARE_DIR");
        if (configured_share != NULL && configured_share[0] != '\0' &&
            join_path(csv, sizeof(csv), configured_share, "csv") == 0) {
            setenv("RETA_DATA_DIR", csv, 1);
        } else if (join_path(csv, sizeof(csv), root, "python_reference/csv") == 0) {
            setenv("RETA_DATA_DIR", csv, 1);
        }
    }

    if (!environment_is_set("RETA_ASSET_DIR")) {
        const char *configured_share = getenv("RETA_SHARE_DIR");
        if (configured_share != NULL && configured_share[0] != '\0' &&
            join_path(assets, sizeof(assets), configured_share, "assets") == 0) {
            setenv("RETA_ASSET_DIR", assets, 1);
        } else if (join_path(assets, sizeof(assets), root, "assets") == 0) {
            setenv("RETA_ASSET_DIR", assets, 1);
        }
    }
}

static int library_path(char *buffer, size_t size, const char *argv0) {
    const char *override = getenv("RETA_CORE_LIBRARY");
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
    const char *library_name = "libreta-core.dylib";
#elif defined(_WIN32)
    const char *library_name = "libreta-core.dll";
#else
    const char *library_name = "libreta-core.so";
#endif

    if (format_library_path(buffer, size, executable, "", library_name) == 0 &&
        readable_path(buffer)) {
        return 0;
    }
    if (format_library_path(buffer, size, executable, "../lib/reta", library_name) == 0 &&
        readable_path(buffer)) {
        return 0;
    }

    /* Preserve the historic build-tree path in the final error message. */
    return format_library_path(buffer, size, executable, "../lib/reta", library_name);
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
                "Core-Starter und Shared Library stammen nicht aus demselben Quellstand.\n"
                "Bitte neu kompilieren: scripts/build_core_shared.sh\n");
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

    set_runtime_environment(argc > 0 ? argv[0] : NULL);

    char library[PATH_MAX];
    if (library_path(library, sizeof(library), argc > 0 ? argv[0] : NULL) != 0) {
        fprintf(stderr, "Pfad der Core-Bibliothek konnte nicht bestimmt werden.\n");
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
        fprintf(stderr, "Core-Bibliothek konnte nicht geladen werden: %s\n", dlerror());
        free(allocated_argv);
        return 127;
    }

    dlerror();
    reta_version_fn version = (reta_version_fn)dlsym(handle, "reta_core_abi_version");
    const char *symbol_error = dlerror();
    if (symbol_error != NULL || version == NULL || version() != RETA_CORE_ABI_VERSION) {
        fprintf(stderr, "Unpassende Core-Bibliothek-ABI.\n");
        free(allocated_argv);
        return 78;
    }

    dlerror();
    reta_entry_fn entry = (reta_entry_fn)dlsym(handle, command->symbol);
    symbol_error = dlerror();
    if (symbol_error != NULL || entry == NULL) {
        fprintf(stderr, "Core-Einstieg fehlt: %s\n", command->symbol);
        free(allocated_argv);
        return 127;
    }

    int status = entry(forwarded_argc, forwarded_argv);
    free(allocated_argv);
    return status;
}
