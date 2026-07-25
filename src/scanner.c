#define _GNU_SOURCE
#define _DEFAULT_SOURCE
#define _POSIX_C_SOURCE 200809L
#include "scanner.h"

static const char *KNOWN_TOOLS[] = {
    "starship", "fastfetch", "fzf", "eza", "bat", "fd", "rg", "kitty", "tmux",
    "nvim", "hyprland", "uwsm", "noctalia", "mpv", "grim", "slurp", "wl-clipboard",
    "git", "stow", "curl", "htop", "btop", "lazygit", NULL
};

static void scan_dir_recursive(const char *dir_path, StringArray *shebangs, StringArray *invocations) {
    DIR *dir = opendir(dir_path);
    if (!dir) return;

    struct dirent *entry;
    char path[PATH_MAX * 2];

    while ((entry = readdir(dir)) != NULL) {
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) continue;

        snprintf(path, sizeof(path), "%s/%s", dir_path, entry->d_name);

        if (is_dir(path)) {
            scan_dir_recursive(path, shebangs, invocations);
        } else if (file_exists(path) && !is_symlink(path)) {
            FILE *fp = fopen(path, "r");
            if (fp) {
                char first_line[256];
                if (fgets(first_line, sizeof(first_line), fp)) {
                    if (strncmp(first_line, "#!", 2) == 0) {
                        char *last_space = strrchr(first_line, ' ');
                        char *bin = last_space ? last_space + 1 : first_line + 2;
                        char *trimmed = trim_whitespace(bin);
                        char *base = strrchr(trimmed, '/');
                        if (base) trimmed = base + 1;
                        if (strlen(trimmed) > 0 && strcmp(trimmed, "env") != 0 && strcmp(trimmed, "sh") != 0) {
                            if (!str_array_contains(shebangs, trimmed)) {
                                str_array_append(shebangs, trimmed);
                            }
                        }
                    }
                }
                fclose(fp);

                for (int i = 0; KNOWN_TOOLS[i] != NULL; i++) {
                    const char *tool = KNOWN_TOOLS[i];
                    char grep_cmd[PATH_MAX * 2 + 128];
                    snprintf(grep_cmd, sizeof(grep_cmd), "grep -q -E \"(command -v %s|exec %s|alias .*=%s|%s init|%s -c)\" \"%s\" 2>/dev/null",
                             tool, tool, tool, tool, tool, path);
                    if (system(grep_cmd) == 0) {
                        if (!str_array_contains(invocations, tool)) {
                            str_array_append(invocations, tool);
                        }
                    }
                }
            }
        }
    }

    closedir(dir);
}

void scan_package(const char *dotfiles_dir, const char *pkg_name) {
    char pkg_dir[PATH_MAX * 2];
    snprintf(pkg_dir, sizeof(pkg_dir), "%s/%s", dotfiles_dir, pkg_name);

    if (!file_exists(pkg_dir)) {
        log_error("Package directory '%s' does not exist!", pkg_name);
        return;
    }

    log_info("Recursively scanning package content in '%s' for dependencies...", pkg_name);

    StringArray shebangs, invocations;
    str_array_init(&shebangs);
    str_array_init(&invocations);

    scan_dir_recursive(pkg_dir, &shebangs, &invocations);

    printf("  %sScan Results for package '%s':%s\n", COLOR_BOLD, pkg_name, COLOR_RESET);
    printf("    %sDetected Shebangs (Required):%s ", COLOR_BOLD, COLOR_RESET);
    if (shebangs.count > 0) {
        for (size_t i = 0; i < shebangs.count; i++) printf("%s ", shebangs.items[i]);
    } else {
        printf("none");
    }
    printf("\n");

    printf("    %sDetected Invocations (Optional):%s ", COLOR_BOLD, COLOR_RESET);
    if (invocations.count > 0) {
        for (size_t i = 0; i < invocations.count; i++) printf("%s ", invocations.items[i]);
    } else {
        printf("none");
    }
    printf("\n\n");

    char manifest_path[PATH_MAX * 2];
    snprintf(manifest_path, sizeof(manifest_path), "%s/.stowdeps", pkg_dir);
    if (!file_exists(manifest_path)) {
        log_info("Auto-generating '.stowdeps' manifest for '%s'...", pkg_name);
        PackageManifest manifest;
        manifest_init(&manifest, pkg_name);
        manifest.required = shebangs;
        manifest.optional = invocations;
        manifest_save(&manifest, dotfiles_dir);
        log_success("Generated '%s'", manifest_path);
    } else {
        str_array_free(&shebangs);
        str_array_free(&invocations);
    }
}
