#!/usr/bin/env bash
# Shared release workflow; --channel public|playtest is required.
set -euo pipefail
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
fw=${PSXRECOMP_ROOT:-"$root/psxrecomp-v4"}
exec bash "$fw/tools/package_title_release.sh" --root "$root" --jobs 2 "$@"
