#!/usr/bin/env python3
"""Execute Giovanni's talk script before victory, while TM is owed, and afterward."""
from pyboy import PyBoy
from test_unique_species import ROOT, symbols


def validate(version):
    syms=symbols(ROOT/(version+'.sym'))
    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return syms[n][1]
    def put(n,v):game.memory[addr(n)]=v
    def get(n):return game.memory[addr(n)]
    def patch(n,code):
        b,a=syms[n];game.memory[b,a:a+len(code)]=code
    def marker(n,value):
        a=addr('wCustomChance');patch(n,[0x3e,value,0xea,a&255,a>>8,0xc9])
    def call_script():
        b,a=syms['ViridianGymText1'];a+=1 # skip the TX_ASM text opcode
        game.memory[0x2000]=game.memory[0xffb8]=b or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,a&255,a>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0
        game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for _ in range(120):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):return
        raise AssertionError((version,hex(game.register_file.PC)))
    try:
        # Stub text/rendering and the final battle/reward/hide operations;
        # real event checks and the entire talk-script control flow execute.
        for n in ('PrintText','DisableWaitingAfterTextDisplay','GBFadeOutToBlack','UpdateSprites','Delay3','GBFadeInFromBlack','SaveEndBattleTextPointers','EngageMapTrainer','TextScriptEnd'):
            patch(n,[0xc9])
        marker('InitBattleEnemyParameters',1)
        marker('ViridianGymScript3_74995',2)
        marker('HideObject',3)
        marker('NoYesChoice',0xee)
        for flags,expected in ((0,1),(2,2),(3,3)):
            game.memory[addr('wEventFlags'):addr('wEventFlags')+320]=[0]*320
            # EVENT_GOT_TM27=0x50; EVENT_BEAT_VIRIDIAN_GYM_GIOVANNI=0x51.
            game.memory[addr('wEventFlags')+0x50//8]=flags
            put('wCustomChance',0);put('wGymLeaderNo',0)
            call_script()
            assert get('wCustomChance')==expected,(version,flags,get('wCustomChance'))
            if flags==0:assert get('wGymLeaderNo')==8
        assert 'RematchTrainerText' not in (ROOT/'scripts/viridiangym.asm').read_text()
    finally:game.stop(save=False)
    print(f'{version}: first Giovanni challenge, pending TM collection and post-reward departure/no rematch passed')


if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
