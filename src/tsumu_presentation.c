#include "execution_profile.h"
#include "mod_plugins.h"

/* Presentation only. No guest ABI, timing, simulation or packet edits. Mode 2
 * filters provenance-qualified world polygons and leaves untracked UI nearest.
 * Other backends use the shared documented bilinear fallback. */
#if PSX_EXECUTION_ENHANCED
static void tsumu_stable_textures(void) {
    psx_mod_set_texture_filter(2);
}

PSX_MOD_CONSTRUCTOR(tsumu_register_presentation) {
    (void)psx_mod_register_activation_plugin(
        "tsumu.presentation.stable-textures", tsumu_stable_textures);
    (void)psx_mod_register_savestate_plugin(
        "tsumu.presentation.stable-textures", tsumu_stable_textures);
}
#endif
