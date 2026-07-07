# TsumuLightRecomp

Tsumu Light (Japan, SLPS-02253) statically recompiled to a native PC executable
with [PSXRecomp](https://github.com/mstan/psxrecomp) — the same framework behind
[MegaManX6Recomp](https://github.com/mstan/MegaManX6Recomp) and
[TombaRecomp](https://github.com/mstan/TombaRecomp) — **with a built-in English
fan-translation**.

> **Tsumu Light** (つむ LIGHT) is a charming, hamster-themed falling/stacking
> puzzle game that only ever released in Japan. This project makes it playable on
> PC **in English** — no emulator, no disc-swapping menus, no Japanese required.

## Community

Part of the **R.A.I.D.** recompilation community. Come chat, get help, or follow
development: **https://discord.gg/Ad9BwSzctP**

## English Translation

The headline feature. Tsumu Light never left Japan, so this build ships a runtime
English localization layer that translates the game's on-screen text — the HUD,
the menus, the stage-select names and high-score labels, and the memory-card
save / format / quit dialogs — with no changes to the disc. You pick the language
right in the launcher:

- **Settings → Localization → Language: English** (default) — the translated text.
- **Language: Default** — the original untranslated Japanese.

The translation data lives entirely in `translations/tsumu.toml` and is applied
at runtime; the game's own assets are never modified.

## What This Is

This repository contains the game-specific configuration, seeds, translation
data, and build glue for running Tsumu Light on the PSXRecomp framework. The
game's MIPS code is machine-translated ("recompiled") ahead of time into native
C, then compiled into a real Windows program that runs the game's own logic on a
faithful simulation of the PS1 hardware (GPU, SPU, GTE, memory cards) plus the
real, recompiled PS1 BIOS.

It does **not** contain the Tsumu Light disc image, the PS1 BIOS, generated game
code, or any decompiled game C. Those are produced locally from your own legally
obtained assets.

Important files:

- `game.toml` — runtime / recompiler / controller / localization config.
- `translations/tsumu.toml` — the English translation data.
- `seeds/` — Ghidra-derived function starts and game-specific seed data.
- `psxrecomp-v4.pin` — framework commit this project is known-good against.
- `DISC.md` — source-disc identity and verification notes.
- `launcher_art/img/disc.png` — the cover art shown in the launcher.

## Status

**Playable — `v0.0.1`.** Tsumu Light **boots and plays** in English — through the
title, into the puzzle stages, with working input and memory-card **save/load**.
It boots instantly via HLE boot-skip.

| Area | State |
|---|---|
| Boot | Instant HLE boot-skip (default); real LLE BIOS boot available |
| Gameplay | Works — puzzle stages play start to finish |
| English translation | HUD, menus, stage names, card dialogs (selectable in launcher) |
| Controller | Keyboard **and** DualShock/DualSense (digital pad — Tsumu is a digital game) |
| Memory-card save / load | Works (standard PS1 `.mcd`, emulator-compatible) |
| Renderer | Software rasterizer (default) |

## Features

- **English localization, selectable in the launcher.** Runtime text translation
  (HUD / menus / stage names / card dialogs) with an in-launcher language picker
  — English or the original Japanese. See above.
- **Graphical launcher.** Pick your BIOS, disc, and memory cards; verify the
  disc; choose your language and controller — then press Launch. Choices persist
  to `settings.toml` next to the exe.
- **Instant boot.** HLE boot-skip synthesizes the post-boot kernel state and
  jumps straight into the game (on by default). Opt out for an authentic BIOS
  intro with `[runtime] bios_hle = false` or `PSX_BIOS_HLE=0`.
- **Controller support.** Keyboard or a DualShock/DualSense (or any SDL pad),
  selectable in the launcher. Tsumu is a digital game, so the pad reports as a
  digital controller and the analog/hybrid pad-mode picker is hidden.

## Setup

### Release Package (recommended)

1. Download the release from [Releases](https://github.com/mstan/TsumuLightRecomp/releases)
   and extract it.
2. Run `Tsumu_Light_Recompiled.exe`. A **launcher window** opens.
3. Set your PlayStation **BIOS**: select your legally obtained **`SCPH1001.BIN`**
   (the standard NTSC-U 512 KB BIOS — see the BIOS note below).
4. Set the game **disc**: select your legally obtained Tsumu Light (Japan,
   SLPS-02253) `.cue` / `.bin`.
5. Under **Settings → Localization**, pick **English** (default) or **Default**
   (Japanese). Adjust controller / memory cards if you like, then press
   **Launch**. Your choices are remembered.

**BIOS note.** Tsumu Light is a Japanese (SLPS) disc, but with the default HLE
boot the console region/license check never runs, so the standard **NTSC-U
`SCPH1001.BIN`** is what you want — no Japanese BIOS needed. (A Japanese BIOS is
only relevant if you force the authentic LLE boot with `bios_hle = false`.)

Accepted disc formats: `.cue` + `.bin` (pick the `.cue`) and `.bin`. Do not
convert to a 2048-byte "cooked" `.iso` — that discards the XA sectors the game
streams audio from.

### Building From Source

Builds on **Windows (MSYS2 / MinGW)**.

Requirements:

- A C/C++ toolchain (MSYS2 `mingw-w64-x86_64`) and CMake 3.20+.
- Tsumu Light (Japan, SLPS-02253) disc image (`.cue` + `.bin`). Not included.
- An NTSC-U `SCPH1001.BIN` BIOS ROM. Not included.
- The `psxrecomp` framework linked in as the `psxrecomp-v4` junction at the
  `psxrecomp-v4.pin` SHA, plus a recompiled BIOS in `psxrecomp/generated/`.

```sh
# Regenerate generated/SLPS_022.53_{full,dispatch}.c from the disc/EXE:
../psxrecomp/recompiler/build/psxrecomp-game.exe --config game.toml

cmake -S . -B build -G Ninja -DPSX_LAUNCHER=ON
cmake --build build -j8
./build/Tsumu_Light_Recompiled.exe
```

## Controls

| PSX button | Keyboard |
|---|---|
| D-Pad Up / Down / Left / Right | Arrow keys |
| Cross | X |
| Circle | S |
| Square | Z |
| Triangle | A |
| Start | Enter |
| Select | Right Shift |
| Fullscreen | F11 / Alt+Enter |

A DualShock / DualSense (or any SDL-recognized pad) works when connected —
select it as the Player 1 device in the launcher.

## Memory Cards

Save and load work. The runtime uses standard PS1 memory-card images (`.mcd`)
compatible with DuckStation, PCSX-Redux, Mednafen, and similar emulators. Cards
live in the `saves` directory and are managed in the launcher's memory-card UI.
Memory-card files are local artifacts and are not committed.

## Development Rules

- Use the real recompiled BIOS and real hardware simulation in PSXRecomp.
- No HLE BIOS shims, no stubs, no fake events, no hand-edited generated files.
  (HLE boot-skip is a QoL layer on top; LLE remains the reference and oracle.)
- Framework changes go in `mstan/psxrecomp`, not here.
- Game binaries, generated code, memory cards, and build outputs stay local.
- See `CLAUDE.md` for project-specific rules.

## License

PolyForm Noncommercial 1.0.0. See `LICENSE`.

Tsumu Light is copyright its respective owners. This repository contains none of
the game's original binaries or assets — no disc data and no BIOS image; those
are always read from files you supply. The English translation is an original
fan work applied at runtime.
