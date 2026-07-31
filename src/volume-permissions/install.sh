#!/bin/sh
set -eu

PATHS="${PATHS:-}"
BASE_DIR="${BASEPATH:-}"

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Strip trailing slashes from the base directory so joining it with a subpath
# never produces a doubled slash.
while [ "$BASE_DIR" != "${BASE_DIR%/}" ]; do
    BASE_DIR="${BASE_DIR%/}"
done

# Split PATHS on commas. Set IFS for the loop only, and disable globbing so a
# subpath containing a glob character is not expanded against the filesystem.
OLD_IFS="$IFS"
IFS=','
set -f
for SUBPATH in $PATHS; do
    [ -n "$SUBPATH" ] || continue
    VOLPATH="${BASE_DIR}${BASE_DIR:+/}$SUBPATH"
    echo "mkdir + chown on: $VOLPATH"
    mkdir -p "$VOLPATH"
    chown -R "$_REMOTE_USER:$_REMOTE_USER" "$VOLPATH"
done
set +f
IFS="$OLD_IFS"
