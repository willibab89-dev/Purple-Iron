#!/usr/bin/env python3
"""Exercise League rematch gating, every Champion branch and nonstacking levels."""
import json
from pyboy import PyBoy
from test_unique_species import ROOT,symbols
from test_move_patch_3 import constants
from test_reviewed_trainers import TRAINERS


def validate(version):
    syms=symbols(ROOT/(version+'.sym'))
    plan=json.loads((ROOT/'data/league_rematch_review.json').read_text())
    rematches={(d['trainer'],d['number']):d['after'] for d in plan['records']}
    base={(d['trainer'],d['number']):d['after'] for d in json.loads((ROOT/'data/blaine_elite_review.json').read_text())['records'] if d['trainer']!='BLAINE'}
    base.update({('SONY3',d['number']):d['after'] for d in plan['champion_base']})
    assert set(rematches)=={(c,2) for c in ('LORELEI','BRUNO','AGATHA','LANCE')}|{('SONY3',n) for n in (4,5,6)}
    indexes=constants(ROOT/'constants/pokemon_constants.asm');events=constants(ROOT/'constants/event_constants.asm')
    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return syms[n][1]
    def put(n,v):game.memory[addr(n)]=v
    def get(n):return game.memory[addr(n)]
    def event(n):
        value=events[n];a=addr('wEventFlags')+value//8;game.memory[a]|=1<<(value%8)
    def call(n):
        b,a=syms[n];game.memory[0x2000]=game.memory[0xffb8]=b or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,a&255,a>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0
        game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for _ in range(120):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):return
        raise AssertionError((version,n,hex(game.register_file.PC)))
    def init(cls,n=1):
        game.memory[addr('wEventFlags'):addr('wEventFlags')+320]=[0]*320
        for name,v in [('wLinkState',0),('wIsInBattle',2),('wPartyCount',1),('wPartyMon1Level',100),('wStartBattleLevels',100),('wTrainerClass',TRAINERS[cls]),('wTrainerNo',n),('wGymLeaderNo',0),('wOptions',0),('wFontLoaded',0)]:put(name,v)
        game.memory[addr('wTrainerBaseMoney'):addr('wTrainerBaseMoney')+3]=[0,0,0x50]
    def party():return [[get(f'wEnemyMon{i}'),get(f'wEnemyMon{i}Level')] for i in range(1,get('wEnemyPartyCount')+1)]
    def moves():return [list(game.memory[addr(f'wEnemyMon{i}Moves'):addr(f'wEnemyMon{i}Moves')+4]) for i in range(1,7)]
    def expected(rows):return [[indexes[s],lv] for s,lv in rows]
    try:
        b,a=syms['Random'];game.memory[b,a:a+2]=[0xaf,0xc9]
        for (cls,n),first in base.items():
            selected=n+3 if cls=='SONY3' else 2
            init(cls,n);call('ReadTrainer')
            assert get('wTrainerNo')==n and party()==expected(first)
            first_moves=moves()
            # A Champion victory flag alone does not unlock the second clear.
            init(cls,n);event('EVENT_BEAT_CHAMPION_RIVAL');call('ReadTrainer')
            assert get('wTrainerNo')==n and party()==expected(first)
            init(cls,n);event('EVENT_908');call('ReadTrainer')
            second=rematches[cls,selected]
            assert get('wTrainerNo')==selected and party()==expected(second),(version,cls,n,party())
            if cls=='SONY3':
                assert second==[[s,lv+25] for s,lv in first]
                assert [lv for s,lv in second]==[84,86,86,86,88,90]
                assert moves()==first_moves,(version,cls,n,'changed Champion moves',first_moves,moves())
            # Repeated selector/loader calls must not upgrade again or add levels.
            call('SelectLeagueRematch');assert get('wTrainerNo')==selected
            call('ReadTrainer');assert get('wTrainerNo')==selected and party()==expected(second)
        for cls in TRAINERS:
            if cls in ('LORELEI','BRUNO','AGATHA','LANCE','SONY3'):continue
            init(cls);event('EVENT_908');call('SelectLeagueRematch')
            assert get('wTrainerNo')==1,(cls,'unexpected League selection')
        for n in (0,4,5,6,7,255):
            init('SONY3',n);event('EVENT_908');call('SelectLeagueRematch');assert get('wTrainerNo')==n
        for cls in ('BRUNO','SONY3'):
            for link in (1,4):
                init(cls);event('EVENT_908');put('wLinkState',link);put('wEnemyPartyCount',5)
                call('ReadTrainer');assert get('wTrainerNo')==1 and get('wEnemyPartyCount')==5
            # Existing optional scaling uses the selected team, with zero RNG.
            init(cls);event('EVENT_908');event('EVENT_90C');call('ReadTrainer')
            number=4 if cls=='SONY3' else 2
            assert party()==[[indexes[s],100] for s,lv in rematches[cls,number]]
        for flag,size in (('EVENT_90A',6),('EVENT_90D',3)):
            init('LORELEI');event('EVENT_908');event(flag);call('ReadTrainer')
            assert get('wEnemyPartyCount')==size
    finally:game.stop(save=False)
    print(f'{version}: unchanged first clear, four second-clear Elite teams, all three Champion +25 branches/identical moves, persistent nonstacking selection, class/link guards and existing options passed')


if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
