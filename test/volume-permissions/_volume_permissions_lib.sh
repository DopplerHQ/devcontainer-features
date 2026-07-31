#!/usr/bin/env bash
# Shared assertions for the volume-permissions feature tests.
# Source this *after* dev-container-features-test-lib so `check` and `echoStderr`
# are available.

EXPECTED_USER="$(id -un)"

# The writability assertions below are meaningless as root, which can write
# anywhere regardless of ownership.
running_as_non_root() {
    if [ "$(id -u)" -eq 0 ]; then
        echoStderr "Tests are running as root; ownership checks would pass trivially."
        return 1
    fi
}

dir_exists() {
    [ -d "$1" ]
}

# Confirms the volume really landed on this path. Without it, a chown of a plain
# directory baked into the image would be enough to pass every other assertion.
is_mountpoint() {
    awk -v target="$1" '$5 == target { found = 1 } END { exit !found }' /proc/self/mountinfo
}

owned_by_remote_user() {
    local owner
    owner="$(stat -c '%U' "$1")"
    if [ "$owner" != "$EXPECTED_USER" ]; then
        echoStderr "Expected '$1' to be owned by '$EXPECTED_USER', got '$owner'."
        return 1
    fi
}

writable_by_remote_user() {
    local probe="$1/.volume-permissions-probe"
    touch "$probe" && rm "$probe"
}

# Runs every per-directory assertion against a path that should be a prepped volume.
check_prepped_volume() {
    local path="$1"
    check "'$path' exists" dir_exists "$path"
    check "'$path' is a mount point" is_mountpoint "$path"
    check "'$path' is owned by $EXPECTED_USER" owned_by_remote_user "$path"
    check "'$path' is writable by $EXPECTED_USER" writable_by_remote_user "$path"
}

# Same assertions minus the mount point check, for directories the feature
# created inside a volume rather than at its root.
check_prepped_dir() {
    local path="$1"
    check "'$path' exists" dir_exists "$path"
    check "'$path' is owned by $EXPECTED_USER" owned_by_remote_user "$path"
    check "'$path' is writable by $EXPECTED_USER" writable_by_remote_user "$path"
}
