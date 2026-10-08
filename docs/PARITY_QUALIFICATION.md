# Tsumu adaptive renderer review, 2026-10-08

Enhanced native-wide rendering follows the live window aspect. Adaptive View
and Stable World Textures default on; OpenGL/1080p, exact projection transport,
English localization and locked digital reporting are retained. Guest projection,
simulation and audio remain native. Screen-space UI uses shared in-place layout;
world horizontal rejection uses shared native-wide culling substitutions.

Interpolation is archived, uncompiled and unavailable. Older interpolation
receipts are historical. Generic CD/host timing controls remain retired; no
Tsumu-specific loader speedup is claimed.

Both BIOS backends are freshly emitted; the local launcher selects bundled
OpenBIOS. Shared framework bf4246f2 includes current master cbfd24fd.

Review: Play-Tsumu.ps1. Check a course at4:3,16:9 and a resized ultrawide window:
puzzle shape, player/blocks/edges, English prompts, score/timer HUD, pause/retry.
At the name screen enter a character, then choose END. Final owner gameplay,
course transitions and audio acceptance remain pending (beads-njks).
