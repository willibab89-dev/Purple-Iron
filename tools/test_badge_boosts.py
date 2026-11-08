#!/usr/bin/env python3
"""Exercise shared badge math, badge ownership, selective rebuilding and gating."""
from pyboy import PyBoy
from test_unique_species import ROOT, symbols


def validate(version):
    syms=symbols(ROOT/(version+'.sym'))
    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return syms[n][1]
    def put(n,v):game.memory[addr(n)]=v
    def word(n,v):game.memory[addr(n):addr(n)+2]=[v>>8,v&255]
    def read(n):return game.memory[addr(n)]*256+game.memory[addr(n)+1]
    def call(n,**regs):
        b,a=syms[n];game.memory[0x2000]=game.memory[0xffb8]=b or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,a&255,a>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0
        game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for k,v in regs.items():setattr(game.register_file,k,v)
        for _ in range(120):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):return
        raise AssertionError(n)
    def de():return game.register_file.D*256+game.register_file.E
    def hl():return game.register_file.HL
    stats=['wBattleMon'+s for s in ('Attack','Defense','Speed','Special')]
    def init(badges=0x55,style=0,battle=2,link=0,select=0):
        for n in stats:word(n,100)
        for n,v in [('wObtainedBadges',badges),('wOptions',style),('wIsInBattle',battle),('wLinkState',link),('wUnusedD71B',select)]:put(n,v)
    try:
        for value in range(1000):
            call('BadgeBoostFivePercent',D=value>>8,E=value&255,B=0x12,C=0x34)
            assert de()==min(999,value+value//20),(version,value,de())
            assert (game.register_file.B,game.register_file.C)==(0x12,0x34)
        # Each badge only affects its own stat. The other four badges do not.
        for badges in [0,0x55,0xaa,0xff]+[1<<i for i in range(8)]:
            init(badges);call('ApplyBadgeStatBoosts')
            assert [read(n) for n in stats]==[105 if badges&(1<<(2*i)) else 100 for i in range(4)]
        for select in range(1,5):
            init(select=select);call('ApplyBadgeStatBoosts')
            assert [read(n) for n in stats]==[105 if i==select-1 else 100 for i in range(4)]
            assert game.memory[addr('wUnusedD71B')]==0
        for style,battle,link,allowed in [(0,2,0,True),(64,2,0,False),(64,1,0,True),(0,1,0,True),(0,2,4,False)]:
            init(style=style,battle=battle,link=link);call('ApplyBadgeStatBoosts')
            assert [read(n) for n in stats]==[105 if allowed else 100]*4
            # Rebuilt stats use exactly the same badge math, for the player only.
            for side in (0,1):
                for stat in range(4):
                    call('ConditionalBadgeBoost',HL=101,A=side,C=stat)
                    assert hl()==(106 if allowed and side==0 else 101),(version,style,battle,link,side,stat,hl())
        for value in (1,19,20,99,100,101,255,256,951,952,998,999):
            init()
            for n in stats:word(n,value)
            call('ApplyBadgeStatBoosts')
            assert [read(n) for n in stats]==[min(999,value+value//20)]*4
    finally:game.stop(save=False)
    print(f'{version}: all 0..999 badge results, 999 cap, badge masks, selective boosts, both calculation paths and battle/link gating passed')


if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
