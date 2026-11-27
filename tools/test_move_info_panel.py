#!/usr/bin/env python3
"""Battle move information panel: visible values and side-effect-free accuracy."""
import re
from pyboy import PyBoy
from test_unique_species import ROOT, symbols
from test_move_patch_3 import MOVES, constants


def validate(version):
    syms = symbols(ROOT / (version + '.sym'))
    game = PyBoy(str(ROOT / (version + '.gbc')), window='null', sound_emulated=False)
    game.set_emulation_speed(0); game.tick(90, False)
    def addr(name): return syms[name][1]
    def put(name, value): game.memory[addr(name)] = value
    def get(name): return game.memory[addr(name)]
    def call(name):
        bank, target = syms[name]
        game.memory[0x2000] = game.memory[0xffb8] = bank or 1
        game.memory[0,0x100:0x108] = [0xf3,0xcd,target & 255,target >> 8,0xc3,4,1,0]
        game.memory[0xffff] = game.memory[0xff0f] = 0
        game.register_file.SP = 0xdffe; game.register_file.PC = 0x100
        for _ in range(150):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106): return
        raise AssertionError((version, name, hex(game.register_file.PC)))
    def text(x,y,n):
        raw=game.memory[addr('wTileMap')+y*20+x:addr('wTileMap')+y*20+x+n]
        return ''.join(str(c-0xf6) if c>=0xf6 else ' ' if c==0x7f else chr(c-0x80+65) if 0x80<=c<=0x99 else '/' if c==0xf3 else f'[{c:02x}]' for c in raw)
    try:
        bank, position = syms['Delay3']; game.memory[bank,position]=0xc9
        call('AbilityResetBattle')
        put('wIsInBattle',2); put('wLinkState',0); put('wPlayerMonNumber',0); put('wEnemyMonPartyPos',0)
        put('wCurrentMenuItem',1); put('wPlayerDisabledMove',0)
        put('wPlayerBattleStatus2',0); put('wPlayerBattleStatus3',0); put('wEnemyBattleStatus3',0)
        put('wPlayerMonAccuracyMod',7); put('wEnemyMonEvasionMod',7)
        put('wNatureMode',1); put('wNatureIDs',0); game.memory[addr('wNatureIDs')+1]=0
        put('wBattleMonMoves',MOVES['TACKLE']); put('wBattleMonPP',20)
        call('PrintMenuItem')
        assert text(5,9,3).strip()=='35', (version,'power',text(5,9,3))
        assert text(5,10,3).strip()=='95', (version,'accuracy',text(5,10,3))
        assert text(3,11,2).strip()=='20' and text(6,11,2).strip()=='35', (version,'pp',text(1,11,9))
        assert text(1,8,6)=='NORMAL', (version,'type',text(1,8,6))
        assert get('wPlayerMoveAccuracy')==242 and get('wCurrentMenuItem')==1
        put('wBattleMonPP',20 | 0x40); call('PrintMenuItem')
        assert text(3,11,2).strip()=='20' and text(6,11,2).strip()=='42', (version,'PP Up',text(1,11,9))
        put('wBattleMonPP',20)
        species=constants(ROOT/'constants/pokemon_constants.asm')
        put('wPartyMon1Species',species['MEOWTH']); put('wPartyMon1Type1',3 << 5); put('wPartyMon1Type2',224)
        call('PrintMenuItem'); assert text(6,11,2).strip()=='40', (version,'Resourceful',text(1,11,9))
        put('wPartyMon1Species',species['PIDGEY'])
        abilities=dict((n,int(v)) for n,v in re.findall(r'^AB_(\w+) EQU (\d+)',(ROOT/'constants/ability_constants.asm').read_text(),re.M))
        put('wActiveAbilities',abilities['HUSTLE']); call('PrintMenuItem')
        assert text(5,10,3).strip()=='80', (version,'Hustle',text(5,10,3))
        assert get('wPlayerMoveAccuracy')==242, (version,'accuracy was mutated')
        put('wActiveAbilities',0); put('wNatureIDs',35); call('PrintMenuItem')
        assert text(5,10,3).strip()=='100', (version,'accuracy nature',text(5,10,3))
        put('wNatureIDs',0); put('wBattleMonMoves',MOVES['SWIFT']); put('wBattleMonPP',20)
        put('wPlayerMonAccuracyMod',1); call('PrintMenuItem')
        assert text(5,10,3).strip()=='100', (version,'Swift always hits')
        put('wPlayerMonAccuracyMod',7); put('wBattleMonMoves',MOVES['GROWL']); put('wBattleMonPP',40); call('PrintMenuItem')
        assert get('wTileMap') is not None and get('wPlayerMovePower')==0
        assert text(3,11,2).strip()=='40' and text(6,11,2).strip()=='40'
        put('wBattleMonMoves',MOVES['SEISMIC_TOSS']); put('wBattleMonPP',20); call('PrintMenuItem')
        assert get('wPlayerMovePower') == 1 and list(game.memory[addr('wTileMap')+9*20+5:addr('wTileMap')+9*20+7]) == [0xe3,0xe3]
        print(f'{version}: move panel power, PP, ability/nature accuracy, and state restoration passed')
    finally: game.stop(save=False)

if __name__=='__main__':
    for version in ('pokered','pokeblue'): validate(version)
