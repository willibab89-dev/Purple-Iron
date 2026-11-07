#!/usr/bin/env python3
"""Validate appended Moonlight through loading, healing, party PP and saves."""
import json
from pyboy import PyBoy
from test_unique_species import ROOT, symbols
from test_move_patch_1 import EFFECTS, TYPES
from test_move_patch_3 import MOVES


def validate(version):
    syms=symbols(ROOT/(version+'.sym'));rom=(ROOT/(version+'.gbc')).read_bytes()
    def addr(n):return syms[n][1]
    def data(n,size,offset=0):
        b,a=syms[n];p=(b*0x4000+a-0x4000 if b else a)+offset;return rom[p:p+size]
    entry=json.loads((ROOT/'data/additional_moves.json').read_text())[0]
    assert entry['symbol']=='MOONLIGHT' and MOVES['MOONLIGHT']==220 and MOVES['STRUGGLE']==165
    assert data('Moves',6,219*6)==bytes([220,EFFECTS['HEAL_EFFECT'],0,TYPES['NORMAL'],255,10])
    assert syms['BaseStats'][1]-addr('Moves')==220*6
    assert data('MoveAnimationMap',1,219)==bytes([MOVES['RECOVER']])
    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def put(n,v):game.memory[addr(n)]=v
    def get(n,size=1):return bytes(game.memory[addr(n):addr(n)+size])
    def word(n,v):game.memory[addr(n):addr(n)+2]=[v>>8,v&255]
    def readword(n):return int.from_bytes(get(n,2),'big')
    def patch(n):
        b,a=syms[n];game.memory[b,a]=0xc9
    def call(n):
        b,a=syms[n];game.memory[0x2000]=game.memory[0xffb8]=b or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,a&255,a>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0
        game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for _ in range(120):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):return
        raise AssertionError((version,n,hex(game.register_file.PC)))
    failures={'count':0}
    def failed(s):s['count']+=1
    try:
        # Stub presentation only. Public move loading, bank dispatch, HP logic
        # and animation-ID mapping remain active.
        for n in ('PrintText','DelayFrames','MoveAnimation','Delay3','Func_78e98','UpdateHPBar2','DrawHUDsAndHPBars'):
            patch(n)
        b,a=syms['PrintButItFailedText_'];game.hook_register(b,a,failed,failures)
        cases=0
        for turn,side,prefix,other in [(0,'Player','wBattleMon','wEnemyMon'),(1,'Enemy','wEnemyMon','wBattleMon')]:
            game.memory[0xfff3]=turn;put('wFlags_D733',0);put('wIsInBattle',2)
            put(f'w{side}SelectedMove',220);call('GetCurrentMove')
            assert get(f'w{side}MoveNum',6)==data('Moves',6,219*6)
            for maximum,current in [(100,1),(101,20),(101,100),(255,1),(300,45),(511,256),(511,1),(100,100)]:
                for status in (0,8,16,64):
                    word(prefix+'MaxHP',maximum);word(prefix+'HP',current);put(prefix+'Status',status)
                    word(other+'MaxHP',200);word(other+'HP',123);put('wAnimationID',0)
                    failures['count']=0;call('HealEffect')
                    assert readword(prefix+'HP')==min(maximum,current+maximum//2),(turn,maximum,current,status)
                    assert get(prefix+'Status')[0]==status
                    assert readword(other+'HP')==123
                    assert failures['count']==int(current==maximum)
                    assert get('wAnimationID')[0]==(0 if current==maximum else MOVES['RECOVER'])
                    cases+=1
        # A genuinely generated Clefable has move220 and its PP, and SRAM
        # round-tripping preserves the high ID and PP-Up bits.
        put('wPartyCount',0);put('wMonDataLocation',0x80);put('wIsInBattle',0)
        put('wCurEnemyLVL',60);put('wcf91',data('PokedexOrder',190).index(36)+1);call('AddPartyMon')
        moves=get('wPartyMon1Moves',4);slot=moves.index(220)
        assert get('wPartyMon1PP',4)[slot]==10
        game.memory[addr('wPartyMon1PP')+slot]=0xc0|16
        put('wNumBagItems',0);put('wBagItems',255)
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2')
        game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
        game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4]=[0]*4
        call('LoadSAV0');call('LoadSAV2');assert not(game.register_file.F&16)
        assert get('wPartyMon1Moves',4)==moves and get('wPartyMon1PP',4)[slot]==0xd0
        print(f'{version}: Moonlight220 loading, {cases} actor/heal/status/full-HP cases, Recover animation, generated PP and SRAM/PP-Up round-trip passed')
    finally:game.stop(save=False)


if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
