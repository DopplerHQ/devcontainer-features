#!/bin/sh
#
# A bare base image has no non-root user, so the remote user is root. Ownership
# is trivially correct here; the value of this scenario is that install.sh does
# not fail when `_REMOTE_USER` is root and the base image lacks the tooling the
# devcontainer images provide.

# Deliberately no `set -e`: every check should run so a failure report lists all
# the problems, not just the first one.

# Must be the first command: on alpine this installs bash and re-execs under it.
. "$(dirname "$0")/_ensure_bash.sh"

source dev-container-features-test-lib
source "$(dirname "$0")/_volume_permissions_lib.sh"

check "tests run as root in this scenario" bash -c '[ "$(id -u)" -eq 0 ]'

check_prepped_volume "/root/caches/one"
check_prepped_volume "/root/caches/two"

# basePath itself is created by mkdir -p even though nothing is mounted there.
check "'/root/caches' exists" dir_exists "/root/caches"

reportResults
