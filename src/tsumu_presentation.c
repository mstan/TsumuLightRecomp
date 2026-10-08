#include "execution_profile.h"
#include "mod_plugins.h"
#include <string.h>

/* Presentation only. No guest ABI, timing, simulation or packet edits. Mode 2
 * filters provenance-qualified world polygons and leaves untracked UI nearest.
 * Other backends use the shared documented bilinear fallback. */
#if PSX_EXECUTION_ENHANCED
static void tsumu_stable_textures(void) {
    psx_mod_set_texture_filter(2);
}
static void tsumu_adaptive_view(void) {
    char aspect[16];
    if(!psx_mod_option_value("tsumu.enhancement.widescreen","widescreen",
        "aspect",aspect,sizeof aspect))strcpy(aspect,"adaptive");
    if(!strcmp(aspect,"4:3"))(void)psx_mod_set_fixed_display_aspect(4,3);
    else if(!strcmp(aspect,"16:9"))(void)psx_mod_set_fixed_display_aspect(16,9);
    else if(!strcmp(aspect,"21:9"))(void)psx_mod_set_fixed_display_aspect(21,9);
    else if(!strcmp(aspect,"32:9"))(void)psx_mod_set_fixed_display_aspect(32,9);
    else {
        (void)psx_mod_set_fixed_display_aspect(16,9);
        (void)psx_mod_set_adaptive_display_aspect(0,0);
    }
    psx_mod_set_native_wide_projection_correction(1);
}

PSX_MOD_CONSTRUCTOR(tsumu_register_presentation) {
    (void)psx_mod_register_activation_plugin("tsumu.adaptive-view",tsumu_adaptive_view);
    (void)psx_mod_register_activation_plugin(
        "tsumu.presentation.stable-textures", tsumu_stable_textures);
    (void)psx_mod_register_savestate_plugin(
        "tsumu.presentation.stable-textures", tsumu_stable_textures);
}
#endif
