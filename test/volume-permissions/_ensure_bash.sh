# POSIX shell snippet — source it as the FIRST command in every test script:
#
#     . "$(dirname "$0")/_ensure_bash.sh"
if [ -z "${_VP_ENSURE_BASH:-}" ]; then
    if ! command -v bash >/dev/null 2>&1; then
        echo "bash not found — installing it so the devcontainer test library can run..."
        _eb_sudo=""
        if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
            _eb_sudo="sudo"
        fi
        if command -v apk >/dev/null 2>&1; then
            $_eb_sudo apk add --no-cache bash
        elif command -v apt-get >/dev/null 2>&1; then
            $_eb_sudo apt-get update && $_eb_sudo apt-get install -y --no-install-recommends bash
        elif command -v dnf >/dev/null 2>&1; then
            $_eb_sudo dnf install -y bash
        elif command -v yum >/dev/null 2>&1; then
            $_eb_sudo yum install -y bash
        else
            echo "No supported package manager found to install bash." >&2
            exit 1
        fi
    fi
    _VP_ENSURE_BASH=1
    export _VP_ENSURE_BASH
    exec bash "$0" "$@"
fi
