#include "execution_profile.h"
#include "mod_plugins.h"
#include "gpu.h"
#include <string.h>

/* Presentation only. No guest ABI, timing, simulation or packet edits. Mode 2
 * filters provenance-qualified world polygons and leaves untracked UI nearest.
 * Other backends use the shared documented bilinear fallback. */
#if PSX_EXECUTION_ENHANCED
static void tsumu_stable_textures(void) {
    psx_mod_set_texture_filter(2);
}
/* Only completed opaque, untextured full-width screen panels qualify.
 * Reuse the shared packet-guarded backdrop compositor; never rewrite guest
 * coordinates or apply the background transform to projected puzzle geometry. */
static void tsumu_tag_backdrop(CPUState* cpu,uint32_t address) {
    (void)address;
    uint32_t packet=cpu->gpr[4]&0x1FFFFFFFu;
    for(unsigned n=0;n<8192 && packet!=0x00FFFFFFu;++n) {
        if((packet&3u)||packet>0x1FFFFCu)return;
        uint32_t tag=psx_mod_read_word(0x80000000u|packet);
        unsigned len=tag>>24;
        if(len>=5 && packet+4u*(len+1u)<=0x200000u) {
            uint32_t p=0x80000000u|packet;
            unsigned op=psx_mod_read_word(p+4)>>24;
            if((op==0x28u && len==5)||(op==0x38u && len==8)) {
                unsigned stride=op==0x38u?8u:4u;
                uint32_t xy[4];
                for(unsigned i=0;i<4;++i)xy[i]=psx_mod_read_word(p+8+i*stride);
                int x0=(int16_t)xy[0],x1=(int16_t)xy[1];
                int x2=(int16_t)xy[2],x3=(int16_t)xy[3];
                int y0=(int16_t)(xy[0]>>16),y1=(int16_t)(xy[1]>>16);
                int y2=(int16_t)(xy[2]>>16),y3=(int16_t)(xy[3]>>16);
                if(x0==0 && x2==0 && x1==320 && x3==320 &&
                   y0==y1 && y2==y3 && y0>=0 && y2<=240 && y2>y0) {
                    gpu_ws_tag_background_prim(p);
                    psx_mod_counter_add("tsumu.wide.background",1);
                }
            }
        }
        uint32_t next=tag&0x00FFFFFFu;
        if(next==packet)return;
        packet=next;
    }
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
    (void)psx_mod_register_function_entry_plugin("tsumu.adaptive-view",0x80052CF0,tsumu_tag_backdrop);
    (void)psx_mod_register_activation_plugin(
        "tsumu.presentation.stable-textures", tsumu_stable_textures);
    (void)psx_mod_register_savestate_plugin(
        "tsumu.presentation.stable-textures", tsumu_stable_textures);
}
#endif
