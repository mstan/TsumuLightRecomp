# Tsumu Light Recomp — Release Notes

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
- **Integrated launcher** (RmlUi) for video, audio, controller, memory-card, and
  localization settings. Digital-pad only (Tsumu is a digital game), so the
  pad-mode picker is hidden.
- **Controller support** — keyboard or a DualShock/DualSense, chosen in the
  launcher's device dropdown.

### Notes
- Requires your own legally obtained Tsumu Light disc and a PS1 BIOS
  (`SCPH1001.BIN`); NTSC-J region. Neither is distributed here.
- Generated recomp C, the disc image, BIOS, memory cards, and launcher cover art
  are produced/supplied locally and are not part of this repository.
