#!/usr/bin/env bash
# Package an already built runtime. Compilation/generation are separate steps.
set -euo pipefail
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
fw=${PSXRECOMP_ROOT:-"$root/psxrecomp-v4"}
if [[ ${1:-} == --help || ${1:-} == -h ]]; then
    echo "Usage: tools/package_release.sh --build-dir DIR --artifact linux-x64 [shared packaging options]"
    echo "Set PSXRECOMP_ROOT to use an explicit frozen framework checkout. No build runs here."
    exit 0
fi
[[ -f "$fw/tools/package_game_release.sh" ]] || { echo "shared framework packager missing: $fw" >&2; exit 1; }
exec bash "$fw/tools/package_game_release.sh" --root "$root" \
    --zip-prefix TsumuLightRecomp --exe-name Tsumu_Light_Recompiled \
    --display-name "Tsumu Light Recompiled" --runtime-target psx-runtime \
    --runtime-dir translations --runtime-file input.ini --runtime-file START_HERE.txt \
    --doc README.md --doc LICENSE --doc RELEASE_NOTES.md --doc docs/PARITY_QUALIFICATION.md \
    --ship-without-overlay-cache-key-because "Tsumu has no qualified title overlay-loader adapter or static overlay inventory; native boot C is required and missing-code coverage remains pending." \
    --ship-without-overlay-cache-because "No qualified Tsumu overlay cache has been captured; the bundled native toolchain supplies compilation for uncovered executable ranges." \
    "$@"
