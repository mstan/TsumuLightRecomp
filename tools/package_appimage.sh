#!/usr/bin/env bash
# Stage an existing native Linux build, then use the shared pinned AppImage tool.
set -euo pipefail
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
fw=${PSXRECOMP_ROOT:-"$root/psxrecomp-v4"}
build_dir=${BUILD_DIR:-"$root/build-appimage"}
recompiler_build=${PSXRECOMP_BIOS_BUILD:-"$fw/recompiler/build-linux"}
out_dir="$root/release-linux"
version=""; jobs=2
while [[ $# -gt 0 ]]; do
    case "$1" in
        --build-dir) build_dir=${2:?}; shift 2;;
        --recompiler-build) recompiler_build=${2:?}; shift 2;;
        --version) version=${2:?}; shift 2;;
        --out) out_dir=${2:?}; shift 2;;
        --jobs) jobs=${2:?}; shift 2;;
        --skip-build) shift;; # retained compatibility; packaging always uses existing builds
        -h|--help)
            echo "Usage: tools/package_appimage.sh --build-dir DIR [--recompiler-build DIR] [--version VERSION] [--out DIR] [--jobs N]"
            echo "Native Linux x86_64 only. Build/codegen separately; no build or AOT generation runs here."
            exit 0;;
        *) echo "unknown argument: $1" >&2; exit 2;;
    esac
done
[[ $(uname -s) == Linux && $(uname -m) == x86_64 ]] || { echo "AppImage packaging requires native Linux x86_64" >&2; exit 1; }
[[ "$jobs" =~ ^[1-9][0-9]*$ ]] || { echo "invalid jobs" >&2; exit 2; }
[[ -f "$fw/tools/package_appimage.sh" ]] || { echo "shared AppImage packager missing: $fw" >&2; exit 1; }
[[ -z "$version" ]] || export RELEASE_VERSION="$version"
export PSXRECOMP_ROOT="$fw"
bash "$root/tools/package_release.sh" --build-dir "$build_dir" \
    --artifact linux-x64 --recompiler-build "$recompiler_build" --stage-only
version=$(tr -d ' \t\r\n' < "$root/VERSION")
metadata=$(mktemp -d "${TMPDIR:-/tmp}/tsumu-appimage-meta.XXXXXXXX")
cleanup() {
    case "$metadata" in "${TMPDIR:-/tmp}"/tsumu-appimage-meta.*) rm -rf -- "$metadata";; esac
}
trap cleanup EXIT
# Constant title identities, fully rendered metadata supplied to the shared tool.
. "$root/packaging/release/app.conf"
sed -e "s|@VERSION@|$version|g" -e "s|@APP_NAME@|$APP_NAME|g" \
    -e "s|@EXE_NAME@|$EXE_NAME|g" -e "s|@PAYLOAD_DIR@|$PAYLOAD_DIR|g" \
    -e "s|@ENV_PREFIX@|$ENV_PREFIX|g" -e "s|@ARTIFACT_NAME@|$ARTIFACT_NAME|g" \
    "$root/packaging/linux/AppRun" > "$metadata/AppRun"
if command -v magick >/dev/null 2>&1; then image_tool=magick
elif command -v convert >/dev/null 2>&1; then image_tool=convert
else echo "ImageMagick is required for the AppImage icon" >&2; exit 1; fi
"$image_tool" "$root/$ICON_SOURCE" -resize 240x240 -background transparent \
    -gravity center -extent 256x256 "$metadata/icon.png"
mkdir -p "$out_dir"
bash "$fw/tools/package_appimage.sh" \
    --payload "$root/dist/stage-game-linux-x64" --exe-name "$EXE_NAME" \
    --payload-name "$PAYLOAD_DIR" --app-run "$metadata/AppRun" \
    --desktop-file "$root/packaging/linux/$DESKTOP_ID.desktop" \
    --icon "$metadata/icon.png" --output "$out_dir/$ARTIFACT_NAME-$version-linux-x86_64.AppImage" \
    --framework "$fw" --jobs "$jobs"
