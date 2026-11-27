#!/usr/bin/env python3
"""Shock Fang is an Electric contact/bite attack using physical stats."""
import re
from pyboy import PyBoy
from test_unique_species import ROOT, symbols, TYPES
from test_move_patch_3 import MOVES


def validate(version):
    syms=symbols(ROOT/(version+'.sym'));game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return syms[n][1]
    def put(n,v):game.memory[addr(n)]=v
    def word(n,v):game.memory[addr(n):addr(n)+2]=[v>>8,v&255]
    def call(n):
        bank,entry=syms[n];game.memory[0x2000]=game.memory[0xffb8]=bank or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,entry&255,entry>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0;game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for _ in range(150):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):return
        raise AssertionError((version,n,hex(game.register_file.PC)))
    try:
        bank,start=syms['Moves'];record=bytes(game.memory[bank,start+(MOVES['SHOCK_FANG']-1)*6:start+MOVES['SHOCK_FANG']*6])
        assert record[2:6]==bytes([65,TYPES['ELECTRIC'],95*255//100,15]), (version,record)
        mb,ma=syms['AbilityMoveMetadata']; assert game.memory[mb,ma+MOVES['SHOCK_FANG']-1] & 3 == 3
        ability={n:int(v) for n,v in re.findall(r'^AB_(\w+) EQU (\d+)',(ROOT/'constants/ability_constants.asm').read_text(),re.M)}
        for turn in (0,1):
            call('AbilityResetBattle');game.memory[0xfff3]=turn;put('wIsInBattle',2);put('wLinkState',0);put('wNatureMode',0);put('wUnusedC000',0);put('wCriticalHitOrOHKO',0)
            actor='wEnemyMon' if turn else 'wBattleMon';target='wBattleMon' if turn else 'wEnemyMon';who='wEnemy' if turn else 'wPlayer'
            for side in ('Player','Enemy'):
                for status in (1,2,3):put('w'+side+'BattleStatus'+str(status),0)
                for mod in ('Attack','Defense','Speed','Special','Accuracy','Evasion'):put('w'+side+'Mon'+mod+'Mod',7)
            for prefix in (actor,target):
                for stat,val in [('HP',160),('MaxHP',160),('Attack',180),('Defense',90),('Speed',80),('Special',25)]:word(prefix+stat,val)
                put(prefix+'Status',0)
            for n,val in zip(('MoveNum','MoveEffect','MovePower','MoveType','MoveAccuracy'),record[:5]):put(who+n,val)
            put(who+'SelectedMove',MOVES['SHOCK_FANG'])
            call('BankedEnemyDamageVars' if turn else 'BankedPlayerDamageVars')
            assert (game.memory[0xff97],game.memory[0xff98])==(180,90), (version,turn,'physical stats',game.memory[0xff97],game.memory[0xff98])
            assert game.register_file.D==65, (version,turn,'power',game.register_file.D)
            game.memory[addr('wActiveAbilities')+turn]=255
            game.memory[addr('wActiveAbilityExtended')+turn]=ability['SAVAGE_JAWS']-255
            word('wDamage',100);call('AbilityGyaradosFixedDamage')
            assert game.memory[addr('wDamage')]*256+game.memory[addr('wDamage')+1]==130,(version,turn,'bite bonus')
        print(f'{version}: Shock Fang Electric/contact/bite metadata and both-side physical damage passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for v in ('pokered','pokeblue'):validate(v)
