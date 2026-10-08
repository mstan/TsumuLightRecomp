#!/usr/bin/env bash
# Wrap an already-built production runtime using the shared release gates.
set -euo pipefail
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
fw=${PSXRECOMP_ROOT:-"$root/psxrecomp-v4"}
build=; emitter=; output=; jobs=2
while [ "$#" -gt 0 ]; do
    case "$1" in
        --build-dir) build=$2; shift 2 ;;
        --recompiler-build) emitter=$2; shift 2 ;;
        --output) output=$2; shift 2 ;;
        --jobs) jobs=$2; shift 2 ;;
        *) echo "usage: $0 --build-dir DIR --recompiler-build DIR --output FILE.AppImage [--jobs N]" >&2; exit 2 ;;
    esac
done
[ -n "$build" ] && [ -n "$emitter" ] && [ -n "$output" ]
version=$(tr -d '[:space:]' < "$root/VERSION")
RELEASE_VERSION="$version" bash "$root/tools/package_release.sh" \
    --build-dir "$build" --recompiler-build "$emitter" --artifact linux-x64 \
    --stage-only --exclude-dev-mods
metadata=$build/appimage-metadata
mkdir -p "$metadata"
sed -e "s/@VERSION@/$version/g" -e 's/@APP_NAME@/Tsumu Light Recompiled/g' \
    -e 's/@EXE_NAME@/Tsumu_Light_Recompiled/g' -e 's/@ARTIFACT_NAME@/TsumuLightRecomp/g' \
    -e 's/@PAYLOAD_DIR@/tsumulightrecomp/g' -e 's/@ENV_PREFIX@/TSUMU_RECOMP/g' \
    "$root/packaging/linux/AppRun" > "$metadata/AppRun"
convert "$root/recomp/launcher/boxart.tga" -resize 240x240 -background transparent \
    -gravity center -extent 256x256 "$metadata/icon.png"
exec bash "$fw/tools/package_appimage.sh" \
    --payload "$root/dist/stage-game-linux-x64" --exe-name Tsumu_Light_Recompiled \
    --payload-name tsumulightrecomp --app-run "$metadata/AppRun" \
    --desktop-file "$root/packaging/linux/io.github.mstan.TsumuLightRecomp.desktop" \
    --icon "$metadata/icon.png" --output "$output" --jobs "$jobs"
