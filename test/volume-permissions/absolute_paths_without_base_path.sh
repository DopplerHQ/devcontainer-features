#!/bin/sh
#
# `basePath` is optional (it defaults to ""), so absolute entries in `paths` must
# work on their own, that is the form the option's own proposals suggest. Also
# covers a path whose parent does not exist in the base image, which `mkdir -p`
# has to create.

# Deliberately no `set -e`: every check should run so a failure report lists all
# the problems, not just the first one.

# Must be the first command: on alpine this installs bash and re-execs under it.
. "$(dirname "$0")/_ensure_bash.sh"

source dev-container-features-test-lib
source "$(dirname "$0")/_volume_permissions_lib.sh"

check "tests run as a non-root remote user" running_as_non_root

check_prepped_volume "/opt/cache-one"
check_prepped_volume "/opt/nested/cache-two"

reportResults
