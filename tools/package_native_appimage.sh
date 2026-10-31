#!/usr/bin/env bash
# Native Linux release entrypoint; profiles and packaging belong to the framework.
set -euo pipefail
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
exec bash "$root/tools/package_release.sh" --platform linux "$@"
