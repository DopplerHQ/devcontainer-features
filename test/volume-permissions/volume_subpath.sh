#!/bin/sh
#
# Scenario "Volume Subpath Support" a single volume holds every cache directory, 
# and each one is also mounted into the workspace folder via volume-subpath.

# Deliberately no `set -e`: every check should run so a failure report lists all
# the problems, not just the first one.

# Must be the first command: on alpine this installs bash and re-execs under it.
. "$(dirname "$0")/_ensure_bash.sh"

source dev-container-features-test-lib
source "$(dirname "$0")/_volume_permissions_lib.sh"

WORKSPACE="$(cd "$(dirname "$0")" && pwd)"
SHARED_VOLUME="/shared-volume"

check "tests run as a non-root remote user" running_as_non_root

# The feature only chowns the paths themselves, so basePath stays root-owned here.
check "'$SHARED_VOLUME' exists" dir_exists "$SHARED_VOLUME"
check "'$SHARED_VOLUME' is a mount point" is_mountpoint "$SHARED_VOLUME"

# Inside the shared volume, the feature-created subdirectories carry the remote
# user's ownership. These are not mount points themselves.
check_prepped_dir "$SHARED_VOLUME/.pnpm-store"
check_prepped_dir "$SHARED_VOLUME/node_modules"

# The same directories, mounted into the workspace folder by volume-subpath.
check_prepped_volume "$WORKSPACE/.pnpm-store"
check_prepped_volume "$WORKSPACE/node_modules"

# Each subpath mount must expose the matching subdirectory of the shared volume,
# not the volume root and not the wrong subdirectory.
subpath_maps_to_subdirectory() {
    local subpath="$1"
    local marker=".subpath-marker-${subpath#.}"
    touch "$WORKSPACE/$subpath/$marker" || return 1
    local status=0
    if [ ! -e "$SHARED_VOLUME/$subpath/$marker" ]; then
        echoStderr "'$WORKSPACE/$subpath' is not backed by '$SHARED_VOLUME/$subpath'."
        status=1
    fi
    if [ -e "$SHARED_VOLUME/$marker" ]; then
        echoStderr "'$WORKSPACE/$subpath' is mounted at the volume root instead of the subdirectory."
        status=1
    fi
    rm -f "$WORKSPACE/$subpath/$marker"
    return $status
}
check "'.pnpm-store' subpath mount maps to the shared volume subdirectory" subpath_maps_to_subdirectory ".pnpm-store"
check "'node_modules' subpath mount maps to the shared volume subdirectory" subpath_maps_to_subdirectory "node_modules"

reportResults
