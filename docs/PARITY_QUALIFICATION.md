# Tsumu Light source qualification, 2026-10-06

This is a bounded source milestone, not a completed enhancement port or a
release qualification. Beads `beads-njks` remains open for compilation, actual
adapter implementation, title gameplay evidence, native Linux packaging and
the owner's final playtest. No compiler, game, AOT generator, media extraction,
media hash or download ran during this source phase. No title speed or coverage
claim is supported by this milestone.

## Source identity and boundaries

- Recomp source base: `9fa07da37e40bfe4b519eff4b77e267801d1af77`, the latest
  merged release-staging source present in `TsumuRecomp`. The owner's active
  older checkout and processes were preserved. July integration commit
  `41628d0` is older and adds no native title adapters.
- `F:/Projects/TsumuGame/v2` is a separate Godot port, not this recomp.
- Campaign branch: `codex/tsumu-parity-hle-20261006`; isolated worktree:
  `F:/Projects/psxrecomp/_wt-tsumu-parity-hle-20261006`.
- Frozen shared framework: `e5e2dca85c2e7c1758c6de27870599103a1f8bfc` at
  `F:/Projects/psxrecomp/_wt-parity-hle-20261006`. The submodule gitlink records
  it. The secondary unpromoted DMA change is excluded. Codegen 18 / `d1867bb4`
  is the campaign generation baseline; generation remains pending here.
- First-review UI pin: `03d58aa0`, shared with the current campaign runtime.
  The owner's resumed instruction prioritizes the ENHANCED Windows build and
  a short tutorial/puzzle playtest. The broader qualification matrix below is
  deferred; native interpolation, wider view and title loading HLE remain open.
- English defaults, translation records, controller reporting, stage rules,
  battery/puzzle progression, saves and the explicit 4:3 world scope are kept.

## Existing coverage and bounded changes

The shared runtime creates one `psx_execution_profile` binding per target with
ENHANCED as its default. This title appends its presentation source, source
configuration, manifest and CMake recipe to the existing contract property,
then refreshes the stamp. It does not call the profile function a second time:
that function would return before accepting more contract files. The final
receipt distinguishes selected profile and binds the actual executable bytes.
There are **zero title HLE families**. The presentation plugin is not mislabeled
as a loader or geometry HLE implementation.

| Area | Source coverage / selected behavior | Qualification gap |
|---|---|---|
| Renderer/resolution | Explicit OpenGL and 1080p target in ENHANCED; reference lines 240; shared driver/budget scale clamps remain active | Native frame height and exact effective scale need title measurement; no verified 1080p screenshot |
| PGXP | ENHANCED compiles hook propagation and requests geometry/perspective correction, half-pixel tolerance, exact projection preservation and no position-only fallback; no precise-culling request | Boot generated C is old ignored monolithic output; regenerate with codegen 18 and check packet provenance / shared edges |
| Stable texture filtering | Trusted default-enabled title presentation plugin calls `psx_mod_set_texture_filter(2)` at activation and state restore; tracked 3D gets bounded OpenGL filtering; untracked UI stays nearest | World coverage is conditional on exact provenance; other backends use bilinear and do not promise sharp UI under this plugin |
| REFERENCE | Stages native resolution, no PGXP correction or title stable-filter catalog, `bios_hle=false`; original generated guest bodies retained | Build and boot pending; authentic Japanese disc boot with a retail BIOS may require Japanese BIOS; existing shared low-level inaccuracies are not disproved |
| Localization/HUD | Same English tables and default, nearest untracked UI, authentic 4:3 layout | Check translated prompts, save menu, course/rank UI and tutorial at 1080p |
| Aspect | `[widescreen] offer=false` retained | No world cull envelope, projection scaling or HUD anchoring contract exists; 16:9/21:9/32:9 world scope is not implemented |
| Native interpolation | None; no title draw-span callback or intermediate scene images | Blend presentation does not qualify. Need new scene images targeting Display, proven draw-only state and restoration |
| Draw distance | None; no ordering-table clamp sites or world cull metadata | Identify actual depth rejection and ordering-table bounds before widening |
| Loader/decompression | Shared CD/BIOS/native overlay infrastructure only; no title loader HLE | No loader entry/result/callback contract or decompression format fixtures in committed title source |
| Linux packaging | Title wrappers use shared `package_game_release.sh` and `package_appimage.sh`; no implicit build/generator run | Fresh native Linux build, dependencies/toolchain and actual package smoke remain pending |

REFERENCE means a maintained source configuration, not a second implementation
carried in the enhanced executable. Existing shared BIOS environment controls
were not expanded; use a separate reference build for qualification. Run from
the build directory so its staged `game.toml` applies, and use fresh settings
for both profiles when comparing visuals.

## Concrete interface inventory

No guessed game addresses are installed. The only committed guest seed is
the EXE entry `0x800691F0`: load base `0x80010000`, text extent `0x80000`, stack
`0x801FFFF0`, initial GP documented as zero. This is a boot entry, not a callable
draw/loader/decompression ABI. The local old generated dispatcher provides
function address coverage but no semantic ABI annotations. Its 274 MB body
was not broadly scanned or rewritten.

| Actual boundary | Inputs / continuation | Required outputs and effects | Current blocker for title replacement |
|---|---|---|---|
| GPU GP0 `0x1F801810`, GP1/GPUSTAT `0x1F801814` through shared `gpu_write_gp0/gpu_write_gp1` | Command word, primitive packets, source-word provenance and existing DMA order; return to MMIO caller | VRAM, CRTC state, GPUREAD/GPUSTAT, ordering, completion and GPU interrupt effects | Guest transform-and-submit entry, packet arena ownership and safe replay span unidentified |
| GTE `gte_execute(CPUState*, command)` | GTE data/control registers and encoded command; return to compiled COP2 caller | Integer FIFOs, MAC/IR/FLAG, latency and projection/PGXP side effects | No operation-level title batch adapter; `psx_hle_gte_execute` alone is not a replacement for an unknown title pipeline |
| CD `cdrom_read(addr)`, `cdrom_write(addr,value)`, `cdrom_dma_read()` | Indexed command/parameter/status/data registers at `0x1F801800..803`; DMA3 guest destination and sector order | Exact bytes visible before done flags, FIFO/status/IRQ order, XA/FMV continuity | Title caller registers, LBA/file mapping, buffer lifetime, callbacks, cancellation and decompression boundaries unidentified |
| Overlay loader `overlay_loader_init(cache_dir,game_id,config_hash)` / native dispatch | Host-native OS/architecture/backend flavor, bytes/code-range and segment identity; guest continuation through the existing dispatcher | Native callable ranges only for matching image/segment; invalidation after guest writes | No qualified Tsumu overlay capture or static inventory; Windows DLLs cannot qualify Linux coverage |
| English translation records `translations/tsumu.toml` | Exact source record bytes and terminators; source-language selector remains `off` | Localized text and prompt/page control behavior | No replacement here; preserve hashes, terminators, message lifetime and menu behavior |

The legacy BIOS service tier handles B0 event operations with image-specific
callback/return anchors. OpenBIOS can structurally deny unsupported call-HLE.
It is shared boot/service behavior, not proof of a Tsumu loader adapter.

To implement a title draw adapter, identify all actual entries/interior entries,
register/stack requirements, camera/object snapshots, packet arena, globals read
outside the routine, and its sole draw completion. To implement a title loader,
identify returned bytes/length/status, when executable bytes become visible,
callback ordering and real decompression inputs/results. Preserve gameplay and
localization; do not report synthetic successful completion.

## Pending focused build and package commands

These commands are plans; none was run in this phase. Keep generated game C
local and use the campaign coordinator's approved compiler slots. Regenerate
from lawful local media with codegen 18 before compiling. Do not reuse or
change the active owner's generated tree or build directories.

Windows, explicit native executable paths:

```powershell
$fw = 'F:/Projects/psxrecomp/_wt-parity-hle-20261006'
$cmake = 'C:/msys64/mingw64/bin/cmake.exe'
# Prepare this worktree's own generated/ via the codegen-18 psxrecomp-game --config game.toml.
& $cmake -S . -B build-parity-enhanced -G Ninja -DPSXRECOMP_ROOT=$fw -DPSX_EXECUTION_PROFILE=ENHANCED -DPSXRECOMP_REQUIRE_GAME_C=ON -DPSX_DEBUG_TOOLS=OFF -DCMAKE_BUILD_TYPE=Release
& $cmake --build build-parity-enhanced --target psx-runtime -j 2
& $cmake -S . -B build-parity-reference -G Ninja -DPSXRECOMP_ROOT=$fw -DPSX_EXECUTION_PROFILE=REFERENCE -DPSXRECOMP_REQUIRE_GAME_C=ON -DPSX_DEBUG_TOOLS=OFF -DCMAKE_BUILD_TYPE=Release
& $cmake --build build-parity-reference --target psx-runtime -j 2
```

Native Linux, separate generated sources and native shared dependencies:

```bash
export PSXRECOMP_ROOT=/path/to/frozen/psxrecomp
cmake -S . -B build-linux-enhanced -G Ninja -DPSXRECOMP_ROOT="$PSXRECOMP_ROOT" -DPSX_EXECUTION_PROFILE=ENHANCED -DPSXRECOMP_REQUIRE_GAME_C=ON -DPSX_DEBUG_TOOLS=OFF -DCMAKE_BUILD_TYPE=Release
cmake --build build-linux-enhanced --target psx-runtime -j 2
bash tools/package_release.sh --build-dir build-linux-enhanced --artifact linux-x64 --recompiler-build "$PSXRECOMP_ROOT/recompiler/build-linux" --stage-only
bash tools/package_appimage.sh --build-dir build-linux-enhanced --recompiler-build "$PSXRECOMP_ROOT/recompiler/build-linux" --out release-linux --jobs 2
bash tools/test_appimage_layout.sh release-linux/TsumuLightRecomp-0.0.2-linux-x86_64.AppImage
```

The shared package stage checks game-linked build flags, version, declared mod
catalog, native toolchain and the embedded execution identity. Linux AppImage
packaging rejects PE/DLL payloads and puts final `binary_sha256` in the ELF's
execution receipt after linuxdeploy may rewrite RPATH. The shared versioned
linuxdeploy/appimagetool pins own downloads; no title continuous URL pins remain.
The explicit no-overlay-cache reasons are qualification gaps, not evidence that
all Tsumu executable ranges are native or that loads are seamless.

The old `tools/package_release.ps1` is a legacy build-and-stage path. It does
not provide these campaign execution receipts and must not be used for campaign
release qualification. `tools/package_release.sh` is the selected shared stage
wrapper for both native Windows builds and native Linux builds.

## Remaining validation and acceptance

Source-only checks completed: the actual `cmake/tsumu_profile.cmake` recipe ran
under `cmake -P` for both profiles and produced valid TOML. Assertions checked
BIOS/PGXP/resolution selection, no audit table in staged config, unchanged
controller/localization/4:3 scope, and false turbo defaults. Both new shell
wrappers passed `bash -n` and their help paths. Title manifest and English
translation TOML parsed. `git diff --check` passed. These are configuration and
syntax results, not compiler, gameplay or package results.

1. Build both profiles from codegen-18 source; confirm profile names/digests,
   default PGXP flag selection, plugin audit and staged configuration. No C/C++
   compiler ran here.
2. Boot and tutorial-to-puzzle progress, crate pickup/orientation, battery/course
   progression, save/load, English/Japanese prompts and audio/FMV continuity.
   Inspect UI/world sharpness and exact-projection coverage at effective 1080p.
3. Implement/prove a draw-only replay boundary and actual world/HUD aspect
   participation before offering Display interpolation or wider viewports.
4. Record actual loader/decompress/draw ABI evidence, implement substantial
   native services with build-selected reference bodies, validate required
   outputs/completion, then measure host cost against the same scenario.
5. Produce and extract a native Linux AppImage; verify final ELF digest/identity,
   untouched player input/cards/cache on reseeding and package launch.
6. Owner final playtest. Keep the Bead open until the requested outcome passes.
