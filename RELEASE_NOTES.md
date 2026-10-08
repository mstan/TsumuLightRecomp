# Tsumu Light Recompiled v0.1.0 - 2026-10-08

- Adaptive native widescreen follows the window aspect, replacing the old fixed view.
- OpenGL with 1080p internal resolution, exact projection, and Stable World Textures default on.
- Puzzle, block and attract-demo world polygons use adaptive horizontal culling.
- The stage/battery HUD anchors top left and the complete rotating block preview anchors top right.
- English localization and bundled OpenBIOS default on.
- Interpolation is unavailable and generic CD/host timing options are retired. No Tsumu-specific loading speedup is claimed.
- Windows x64 ZIP and native Linux x86_64 AppImage use the shared release packaging gates.

The owner approved the adaptive view, culling and HUD gameplay candidate.
Release checks cover package versions, profiles, defaults, translation resources,
dependencies and bounded OpenGL startup; complete course and audio coverage
are not claimed.

Production release packaging: tools/package_release.sh for Windows and
tools/package_native_appimage.sh for Linux, after building the runtime.
Both delegate staging and executable-contract checks to the pinned framework.

---

# Tsumu Light Recomp — Release Notes

## v0.0.2 — 2026-07-10

### 🛠️ Critical boot fix

- **The v0.0.1 zip could fail to start on user machines.** It relied on a
  reference copy of the game's boot executable that only exists in a
  development checkout (it is game data, so it is never shipped in the zip).
  Without it the runtime's text-integrity guard never armed — the guard that,
  among other things, the English-translation layer depends on. The runtime
  now extracts that reference directly from **your disc image** — the same
  bytes the BIOS boots — so it works on every install.
- **The package is now self-contained.** v0.0.1 shipped loose MinGW runtime
  DLLs (`SDL2.dll`, `libgcc_s_seh-1.dll`, …) which could collide with copies
  elsewhere on the DLL search path (`0xc000007b` on launch). v0.0.2 is a
  single statically-linked executable importing only Windows system DLLs.
- The package now also ships `game.toml`, the English `translations/` tables,
  release notes, and a `START_HERE.txt`.

## v0.0.1 — 2026-07-06

First public release. Tsumu Light (Japan, SLPS-02253) statically recompiled to a
native Windows executable on the [PSXRecomp](https://github.com/mstan/psxrecomp)
framework.

### Highlights
- **Playable end to end** — boots via instant HLE boot straight into the game.
- **English fan-translation** applied at runtime: HUD, menus, stage names, and
  the memory-card save/format/quit dialogs. Selectable in the launcher
  (Settings → Localization: **English** default, or **Default** for the
  untranslated original).
- **Integrated Dear ImGui launcher** for video, audio, controller, memory-card, and
  localization settings. Digital-pad only (Tsumu is a digital game), so the
  pad-mode picker is hidden.
- **Controller support** — keyboard or a DualShock/DualSense, chosen in the
  launcher's device dropdown.

### Notes
- Requires your own legally obtained Tsumu Light disc and a PS1 BIOS
  (`SCPH1001.BIN`); NTSC-J region. Neither is distributed here.
- Generated recomp C, the disc image, BIOS, memory cards, and launcher cover art
  are produced/supplied locally and are not part of this repository.
