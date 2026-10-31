#!/usr/bin/env bash
# Compatibility alias for the maintained Linux release entrypoint.
set -euo pipefail
exec bash "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/package_native_appimage.sh" "$@"
