#!/bin/sh
#
# Scenario "Basic Usage": one dedicated volume per path, every path relative to the
# container workspace folder.
#
# The workspace folder is itself a bind mount, so these volumes are nested
# inside it, the same shape a real project gets for node_modules.

# Deliberately no `set -e`: every check should run so a failure report lists all
# the problems, not just the first one.

# Must be the first command: on alpine this installs bash and re-execs under it.
. "$(dirname "$0")/_ensure_bash.sh"

source dev-container-features-test-lib
source "$(dirname "$0")/_volume_permissions_lib.sh"

WORKSPACE="$(cd "$(dirname "$0")" && pwd)"
PNPM_STORE="$WORKSPACE/.pnpm-store"
NODE_MODULES="$WORKSPACE/node_modules"

check "tests run as a non-root remote user" running_as_non_root

check_prepped_volume "$PNPM_STORE"
check_prepped_volume "$NODE_MODULES"

# Each path is a distinct volume: content written to one must not show up in the
# other. Guards against both mounts resolving to the same source.
separate_volumes() {
    local marker="$PNPM_STORE/.separate-volumes-marker"
    touch "$marker" || return 1
    if [ -e "$NODE_MODULES/.separate-volumes-marker" ]; then
        echoStderr "'$PNPM_STORE' and '$NODE_MODULES' share the same backing volume."
        rm -f "$marker"
        return 1
    fi
    rm -f "$marker"
}
check "each path is backed by its own volume" separate_volumes

# The point of the feature: the remote user owns the volume, so a tool running
# as that user can populate it. Emulate an install writing a nested tree.
nested_writes_succeed() {
    mkdir -p "$NODE_MODULES/.bin/nested" &&
        touch "$NODE_MODULES/.bin/nested/file" &&
        rm -rf "$NODE_MODULES/.bin"
}
check "remote user can create nested trees in the volume" nested_writes_succeed

reportResults
