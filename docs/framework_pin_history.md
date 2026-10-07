# Framework pin history (historical)

2026-10-06 source campaign: the isolated Tsumu parity branch pins
`8f95b599997399a476062e99634ddbb67e5c8731`. Compilation and owner playtest are
pending; this is not a released-build qualification. See
[PARITY_QUALIFICATION.md](PARITY_QUALIFICATION.md) for exact source scope.

The `psxrecomp` framework used to be pinned via this hand-maintained
`psxrecomp-v4.pin` file. That mechanism has been **replaced by a real git
submodule**: the framework commit this repo builds against is now recorded as
the `psxrecomp-v4` submodule pointer (see `.gitmodules`). Bump it the normal
way:

    git -C psxrecomp-v4 fetch && git -C psxrecomp-v4 checkout <new-sha>
    git add psxrecomp-v4 && git commit -m "bump psxrecomp-v4 to <new-sha>"

At migration time the pointer moved to master `d2006e0`, superseding the pin
recorded below.

The notes below are kept only as a historical changelog of which framework
build each release was cut against.

---

# 2026-07-10 (v0.0.2): pin bumped to master e5a958f — the CRITICAL
# release-install boot fix: the dirty-RAM text-image guard now arms from the
# boot EXE extracted off the user's DISC image when no local EXE file exists
# (main.cpp arm_text_image_guard). Release zips whose pin contained 685f38d
# (the Jul 4 text-divergence guard) could fail to boot outside a dev checkout
# because the guard only armed from a repo-local EXE found via a marker walk;
# v0.0.1's pin (864ac40) contained it, so v0.0.1 was at risk on user machines.
# NB: Tsumu's translation layer leans on this guard (byte-compare +
# dirty_ram_text_bless), so arming it on END-USER installs matters doubly here.
# Also inherited since 864ac40: L3/R3 stick-click binds (f1afc7f), the former
# launcher restored on master (f36b458), MMX6 mirrored-UV rect fix, MMX4/5
# true-wide merges.
#
# CODEGEN note: no regen for v0.0.2 (runtime-only changes since 864ac40 for
# this title; the packager builds the validated generated/ as-is).
#
# RELEASE GATE: before publishing, extract the packaged zip to a directory
# OUTSIDE any git checkout and verify it boots to gameplay visually.
# Prev pin: 864ac40 (master, wt/tsumu merge + HLE-boot-default).
branch=master
sha=e5a958f
