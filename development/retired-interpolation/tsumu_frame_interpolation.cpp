#include "execution_profile.h"
#include "render_pass_ot.hpp"

#if PSX_EXECUTION_ENHANCED
namespace {
constexpr uint32_t SceneA=0x800182A4,EndA=0x8001847C;
constexpr uint32_t SceneB=0x800184EC,EndB=0x800189F8;
constexpr uint32_t DrawEnv=0x8014F108,DispEnv=0x8015AE88,OT=0x80110BA0;
PSXDrawReplay replay;
PSXOTReplay ot;
uint32_t ticks=0,captured_tick=0,scene=0,bank=0,gp=0;
bool capturing=false,ready=false;
uint32_t rd(uint32_t p){return psx_mod_read_word(p);}
uint16_t rh(uint32_t p){return psx_mod_read_half(p);}
void reset(){capturing=ready=false;scene=0;replay.invalidate();ot.reset();}
void tick(){if(!g_psx_render_pass_active){++ticks;if(ticks-captured_tick>8 && (capturing||ready))reset();}}
void begin(CPUState* cpu,uint32_t address) {
    if(g_psx_render_pass_active)return;
    const uint32_t next=rd(cpu->gpr[28]+0x140);
    if(!psx_mod_game_started() || next>1 || rd(SceneA)!=0x27BDFFD0 ||
       rd(0x80042E90)!=0x0C0170F8){reset();return;}
    if(capturing || (scene && scene!=address))reset();
    scene=address;bank=next;gp=cpu->gpr[28];captured_tick=ticks;
    capturing=true;ready=false;
    replay.capture(cpu,scene,scene==SceneA?EndA:EndB);
}
void end(CPUState*,uint32_t) {
    if(g_psx_render_pass_active || !capturing)return;
    capturing=false;
    ready=replay.prepare(captured_tick) && ot.capture(OT+bank*0x2000,2048);
    psx_mod_counter_add("tsumu.fr.frames",1);
    psx_mod_counter_add("tsumu.fr.projections",replay.stats.changed);
}
int pass(CPUState* cpu,void*,uint32_t alpha) {
    if(!replay.restore(cpu,alpha))return 0;
    const uint32_t dest=DrawEnv+bank*0x5C,normal=DrawEnv+(1-bank)*0x5C;
    const int from=rh(normal+2),to=rh(dest+2),height=rh(dest+6);
    PSXDrawReplay::call(cpu,0x80052D60,dest);
    if(!replay.draw(cpu)){psx_mod_counter_add("tsumu.fr.draw_failed",1);return 0;}
    ot.apply_late();
    const uint32_t tail=OT+bank*0x2000+0x1FFC;
    if(!PSXOTReplay::retarget_y(tail,from,to,height)){
        psx_mod_counter_add("tsumu.fr.environment_rejected",1);return 0;
    }
    PSXDrawReplay::call(cpu,0x80052CF0,tail);
    PSXDrawReplay::call(cpu,0x800526FC,0);
    return 1;
}
void finish(CPUState* cpu,uint32_t) {
    // The submit wrapper toggles its bank, waits, then installs DRAWENV before
    // this PutDispEnv call. Never repeat its VSync or the input/audio poll.
    if(g_psx_render_pass_active || cpu->gpr[31]!=0x80042EEC || !ready)return;
    ready=false;
    const uint32_t disp=DispEnv+(1-bank)*0x14,draw=DrawEnv+bank*0x5C;
    if(rd(gp+0x140)!=1-bank || cpu->gpr[4]!=disp || rd(disp)!=rd(draw) || rd(disp+4)!=rd(draw+4))return;
    if(!ot.preserve_late()){psx_mod_counter_add("tsumu.fr.overlay_rejected",1);return;}
    PSXModRenderPassFrame frame{};frame.struct_size=sizeof frame;
    frame.period_vblanks=replay.ticks;frame.shown_after_vblanks=0;
    frame.x=rh(disp);frame.y=rh(disp+2);frame.w=rh(disp+4);frame.h=rh(disp+6);
    psx_mod_counter_add("tsumu.fr.passes",psx_mod_render_pass_frame(cpu,&frame,pass,nullptr));
}
void activate(){reset();ticks=0;psx_mod_activate_render_pass_rate(
    "tsumu.enhancement.frame-interpolation","frame-interpolation","rate",PSX_MOD_RENDER_PASS_FLIP_PENDING);}
}
PSX_MOD_CONSTRUCTOR(tsumu_register_frame_interpolation) {
    const char* id="tsumu.frame-interpolation";
    psx_mod_register_activation_plugin(id,activate);
    psx_mod_register_vblank_plugin(id,tick);
    psx_mod_register_savestate_plugin(id,reset);
    psx_mod_register_function_entry_plugin(id,SceneA,begin);
    psx_mod_register_function_entry_plugin(id,SceneB,begin);
    psx_mod_register_instruction_plugin(id,EndA,0x8F8203F0,end);
    psx_mod_register_instruction_plugin(id,EndB,0x8F8203F0,end);
    psx_mod_register_function_entry_plugin(id,0x80052F2C,finish);
}
#endif
