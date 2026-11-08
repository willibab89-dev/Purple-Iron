#!/usr/bin/env python3
"""Exercise real Gym party selection, post-League gates and existing options."""
import json
from pyboy import PyBoy
from test_unique_species import ROOT, symbols
from test_move_patch_3 import constants
from test_reviewed_trainers import TRAINERS


def validate(version):
    syms=symbols(ROOT/(version+'.sym'))
    rematch=json.loads((ROOT/'data/gym_rematch_review.json').read_text())
    rows={d['trainer']:d for d in rematch['records']}
    base={}
    for file in ('gym_leader_review','blaine_elite_review'):
        for d in json.loads((ROOT/f'data/{file}.json').read_text())['records']:
            base[d['trainer']]=d['after']
    indexes=constants(ROOT/'constants/pokemon_constants.asm')
    events=constants(ROOT/'constants/event_constants.asm')
    assert events['EVENT_908']==0x908
    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return syms[n][1]
    def put(n,v):game.memory[addr(n)]=v
    def get(n):return game.memory[addr(n)]
    def event(n):
        value=events[n];a=addr('wEventFlags')+value//8
        game.memory[a]|=1<<(value%8)
    def call(n):
        b,a=syms[n];game.memory[0x2000]=game.memory[0xffb8]=b or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,a&255,a>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0
        game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for _ in range(120):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):return
        raise AssertionError((version,n,hex(game.register_file.PC)))
    def init(cls):
        game.memory[addr('wEventFlags'):addr('wEventFlags')+320]=[0]*320
        for n,v in [('wLinkState',0),('wIsInBattle',2),('wPartyCount',1),('wPartyMon1Level',80),('wTrainerClass',TRAINERS[cls]),('wTrainerNo',1),('wGymLeaderNo',1),('wOptions',0),('wFontLoaded',0)]:put(n,v)
        put('wStartBattleLevels',80)
        game.memory[addr('wTrainerBaseMoney'):addr('wTrainerBaseMoney')+3]=[0,0,0x50]
    def party():
        return [[get(f'wEnemyMon{i}'),get(f'wEnemyMon{i}Level')] for i in range(1,get('wEnemyPartyCount')+1)]
    def expect(roster):return [[indexes[s],lv] for s,lv in roster]
    try:
        b,a=syms['Random'];game.memory[b,a:a+2]=[0xaf,0xc9]
        for cls,row in rows.items():
            own=row['defeat_event']
            for hof,beaten in ((False,False),(False,True),(True,False),(True,True)):
                init(cls)
                if hof:event('EVENT_908')
                if beaten:event(own)
                call('ReadTrainer')
                selected=2 if hof and beaten else 1
                assert get('wTrainerNo')==selected,(version,cls,hof,beaten)
                assert party()==expect(row['after'] if selected==2 else base[cls]),(version,cls,hof,beaten,party())
            # Beating the Champion alone is not the persistent Hall-of-Fame flag.
            init(cls);event('EVENT_BEAT_CHAMPION_RIVAL');event(own);call('ReadTrainer')
            assert get('wTrainerNo')==1 and party()==expect(base[cls])
            # Another leader's defeat must not unlock this one's rematch.
            other=next(d['defeat_event'] for c,d in rows.items() if c!=cls)
            init(cls);event('EVENT_908');event(other);call('ReadTrainer')
            assert get('wTrainerNo')==1 and party()==expect(base[cls])
            # Real engagement initialization restores record 1 on each talk;
            # ReadTrainer then selects the unlocked record 2 again.
            init(cls);event('EVENT_908');event(own)
            put('wEngagedTrainerClass',TRAINERS[cls]+200)
            put('wEngagedTrainerSet',1);put('wTrainerNo',99)
            call('InitBattleEnemyParameters');assert get('wTrainerNo')==1
            call('ReadTrainer');assert get('wTrainerNo')==2 and party()==expect(row['after'])
            # Optional scaling still applies; zero RNG gives deterministic level 80.
            init(cls);event('EVENT_908');event(own);event('EVENT_90C');call('ReadTrainer')
            assert get('wTrainerNo')==2
            assert party()==[[indexes[s],80] for s,lv in row['after']],(cls,'scaled',party())
        # Every other class retains its requested record after all seven victories.
        for cls in TRAINERS:
            if cls in rows:continue
            init(cls);event('EVENT_908')
            for d in rows.values():event(d['defeat_event'])
            call('SelectPostLeagueGymRematch')
            assert get('wTrainerNo')==1,(cls,'unexpected rematch')
        # Existing link-battle guard returns before selection or party mutation.
        for link in (1,4):
            init('BROCK');event('EVENT_908');event('EVENT_BEAT_BROCK')
            put('wLinkState',link);put('wEnemyPartyCount',6);call('ReadTrainer')
            assert get('wTrainerNo')==1 and get('wEnemyPartyCount')==6
        # Random roster options retain their old 6/3-party behavior and skip overrides.
        for flag,size in (('EVENT_90A',6),('EVENT_90D',3)):
            init('BROCK');event('EVENT_908');event('EVENT_BEAT_BROCK');event(flag);call('ReadTrainer')
            assert get('wEnemyPartyCount')==size,(flag,party())
        init('GIOVANNI');event('EVENT_908');event('EVENT_BEAT_VIRIDIAN_GYM_GIOVANNI')
        put('wTrainerNo',3);call('ReadTrainer')
        assert get('wTrainerNo')==3 and party()==expect(base['GIOVANNI'])
    finally:game.stop(save=False)
    print(f'{version}: seven Hall-of-Fame/individual-defeat gates, exact base/rematch parties, class whitelist, link guard, scaling, random options and unchanged Giovanni passed')


if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
