#!/usr/bin/env python3
"""Load every trainer party and verify regular rosters and protected boss sets."""
import re
import json
import hashlib
from pyboy import PyBoy
from test_unique_species import ROOT, TUNING, symbols
from test_move_patch_3 import MOVES, constants

TRAINERS = {name: i for i, name in enumerate(re.findall(r'^\s*trainer_const (\w+)', (ROOT/'constants/trainer_constants.asm').read_text(), re.M), 1)}


def validate(version):
    syms = symbols(ROOT/(version+'.sym'))
    game = PyBoy(str(ROOT/(version+'.gbc')), window='null', sound_emulated=False)
    game.set_emulation_speed(0)
    game.tick(90, False)
    def addr(name): return syms[name][1]
    def put(name, value): game.memory[addr(name)] = value
    def get(name, count=1): return bytes(game.memory[addr(name):addr(name)+count])
    def call(name):
        bank, target = syms[name]
        game.memory[0x2000] = game.memory[0xffb8] = bank or 1
        game.memory[0, 0x100:0x108] = [0xf3, 0xcd, target & 255, target >> 8, 0xc3, 4, 1, 0]
        game.memory[0xffff] = game.memory[0xff0f] = 0
        game.register_file.SP = 0xdffe
        game.register_file.PC = 0x100
        for _ in range(120):
            game.tick(1, False)
            if game.register_file.PC in (0x104, 0x105, 0x106): return
        raise AssertionError((version, name, hex(game.register_file.PC)))
    def load(trainer, number):
        # Default, unscaled battles; execute ReadTrainer and all of its
        # party generation and additional-move writes without stubbing them.
        game.memory[addr('wEventFlags'):addr('wEventFlags')+320] = [0]*320
        put('wLinkState', 0)
        put('wIsInBattle', 2)
        put('wPartyCount', 0)
        put('wTrainerClass', TRAINERS[trainer])
        put('wTrainerNo', number)
        game.memory[addr('wTrainerBaseMoney'):addr('wTrainerBaseMoney')+3] = [0, 0, 0x50]
        call('ReadTrainer')
    try:
        plan=json.loads((ROOT/'data/trainer_review.json').read_text())
        regular=json.loads((ROOT/'data/regular_trainer_review.json').read_text())
        gym=json.loads((ROOT/'data/gym_leader_review.json').read_text())
        leaders={(d['trainer'],d['number']):d for d in gym['records']}
        assert len(leaders)==7 and set(leaders)<set((d['trainer'],d['number']) for d in regular['protected'])
        elite=json.loads((ROOT/'data/blaine_elite_review.json').read_text())
        additions={(d['trainer'],d['number']):d for d in elite['records']}
        assert set(additions)=={(c,1) for c in ('BLAINE','LORELEI','BRUNO','AGATHA','LANCE')}
        assert set(leaders).isdisjoint(additions)
        assert all(len(d['after'])==6 for d in additions.values())
        leaders.update(additions)
        rematch=json.loads((ROOT/'data/gym_rematch_review.json').read_text())
        rematches={(d['trainer'],d['number']):d for d in rematch['records']}
        aces=json.loads((ROOT/'data/postgame_ace_review.json').read_text())
        revised_aces={(d['trainer'],d['number']):d for d in aces['records']}
        assert set(revised_aces)==set(rematches)
        for key,d in revised_aces.items():
            assert d['before']==rematches[key]['after'] and d['after'][-1][1]==70
            assert sorted(s for s,lv in d['before'])==sorted(s for s,lv in d['after'])
            ace=d['after'][-1][0]
            assert ace=={'BROCK':'ONIX','MISTY':'STARMIE','LT_SURGE':'UNIQUE_RAICHU_UNIQUE','ERIKA':'UNIQUE_VENUSAUR_ERIKA','KOGA':'ARBOK','SABRINA':'ALAKAZAM','BLAINE':'MAGMAR'}[key[0]]
            assert [p for p in d['after'] if p[0]!=ace]==[p for p in d['before'] if p[0]!=ace]
        rematches.update(revised_aces)
        assert len(rematches)==7 and all(n==2 for c,n in rematches)
        assert all(len(d['after'])==5 for d in rematches.values())
        assert set(leaders).isdisjoint(rematches)
        leaders.update(rematches)
        league=json.loads((ROOT/'data/league_rematch_review.json').read_text())
        league_rematches={(d['trainer'],d['number']):d for d in league['records']}
        for d in aces['league_adjustments']:
            key=d['trainer'],d['number']
            assert d['before']==league_rematches[key]['after']
            assert [s for s,lv in d['before']]==[s for s,lv in d['after']]
            league_rematches[key]=d
        assert len(league_rematches)==7 and all(len(d['after'])==6 for d in league_rematches.values())
        assert set(leaders).isdisjoint(league_rematches)
        leaders.update(league_rematches)
        source=(ROOT/'data/trainer_parties.asm').read_text()
        assert hashlib.sha256((ROOT/'data/trainer_parties.asm').read_bytes()).hexdigest()==plan['trainer_parties_sha256']
        rom=(ROOT/(version+'.gbc')).read_bytes()
        def data(label):
            bank,a=syms[label];offset=bank*16384+a-16384 if bank else a
            return rom[offset:]
        labels=re.findall(r'^\s*dw (\w+)',source.split('TrainerDataPointers:',1)[1].split('YoungsterData:',1)[0],re.M)
        sections={}
        matches=list(re.finditer(r'^(\w+):[^\n]*\n',source,re.M))
        for i,m in enumerate(matches):
            sections[m[1]]=source[m.end():matches[i+1].start() if i+1<len(matches) else len(source)]
        records={}
        for trainer,label in zip(TRAINERS,labels):
            raw=data(label);pos=0
            count=len(re.findall(r'^\s*db\s+',sections[label],re.M))
            for number in range(1,count+1):
                level=raw[pos];pos+=1;party=[]
                if level==255:
                    while raw[pos]:
                        party.append((raw[pos+1],raw[pos]));pos+=2
                else:
                    while raw[pos]:
                        party.append((raw[pos],level));pos+=1
                pos+=1;records[trainer,number]=party
        indexes=constants(ROOT/'constants/pokemon_constants.asm')
        revised={(d['trainer'],d['number']):d for d in regular['records']}
        protected={(d['trainer'],d['number']):d for d in regular['protected']}
        assert len(revised)==313 and len(protected)==48
        assert set(revised).isdisjoint(protected)
        assert (set(revised)|set(protected)).isdisjoint(rematches)
        assert (set(revised)|set(protected)|set(rematches)).isdisjoint(league_rematches)
        assert set(revised)|set(protected)|set(rematches)|set(league_rematches)==set(records)
        assert sum(d['before']!=d['after'] for d in revised.values())==281
        assert sum(len(d['after'])>len(d['before']) for d in revised.values())==183
        assert sum(len(d['after'])<=2 for d in revised.values())==17
        for key,d in revised.items():
            assert records[key]==[(indexes[s],lv) for s,lv in d['after']],key
            added=max(0,len(d['after'])-len(d['before']))
            assert max(lv for s,lv in d['after'])==max(lv for s,lv in d['before'])-added,key
            assert 1<=len(d['after'])<=6
        for key,d in protected.items():
            roster=leaders[key]['after'] if key in leaders else d['before']
            assert records[key]==[(indexes[s],lv) for s,lv in roster],('protected/leader',key)
        for key,d in rematches.items():
            assert records[key]==[(indexes[s],lv) for s,lv in d['after']],('rematch',key)
        for key,d in league_rematches.items():
            assert records[key]==[(indexes[s],lv) for s,lv in d['after']],('League rematch',key)
        assert regular['trainer_parties_sha256']==gym['previous_trainer_parties_sha256']
        assert gym['trainer_parties_sha256']==elite['previous_trainer_parties_sha256']
        assert elite['trainer_parties_sha256']==rematch['previous_trainer_parties_sha256']
        assert rematch['trainer_parties_sha256']==league['previous_trainer_parties_sha256']
        assert league['trainer_parties_sha256']==aces['previous_trainer_parties_sha256']
        assert aces['trainer_parties_sha256']==plan['trainer_parties_sha256']
        assert regular['previous_trainer_parties_sha256']==plan['previous_trainer_parties_sha256']
        assert regular['expected_roster_entries']==1178
        assert gym['expected_roster_entries']==1187
        assert elite['expected_roster_entries']==1193
        assert rematch['expected_roster_entries']==1228
        assert league['expected_roster_entries']==plan['expected_roster_entries']==1270
        # Every override record, including Red's final record, must end before
        # the outer FF sentinel. Never interpret FF as a party slot.
        raw=data('SpecialTrainerMoves');pos=0
        byclass={v:k for k,v in TRAINERS.items()}
        while raw[pos]!=255:
            trainer=byclass[raw[pos]];number=raw[pos+1];pos+=2
            party=records[trainer,number];writes=set()
            while raw[pos]:
                slot,move_slot,move=raw[pos:pos+3];pos+=3
                assert 1<=slot<=len(party),(trainer,number,slot)
                assert 1<=move_slot<=4 and 1<=move<=max(MOVES.values())
                assert (slot,move_slot) not in writes,(trainer,number,slot,move_slot)
                writes.add((slot,move_slot))
            pos+=1
        dexorder=data('PokedexOrder')[:190]
        tune={d['dex']:d for d in TUNING.values()}
        tmplan=json.loads((ROOT/'data/tm_distribution.json').read_text())
        tms={d['dex']:d for d in tmplan['entries']}
        extraplan=json.loads((ROOT/'data/new_tms.json').read_text())
        extras={d['dex']:d for d in extraplan['entries']}
        machines=data('TechnicalMachines')[:55+len(extraplan['new_tms'])]
        move_data=data('Moves')[:max(MOVES.values())*6]
        expected={(d['trainer'],d['number'],d['slot']):d for d in plan['changes']+plan['preserved']}
        rematch_moves=json.loads((ROOT/'data/rematch_moveset_review.json').read_text())['records']
        assert len(rematch_moves)==77 and sum(d['changed'] for d in rematch_moves)==37
        for d in rematch_moves:
            key=d['trainer'],d['number'],d['slot']
            assert expected[key]['moves']==d['proposed'],('approved rematch moves',key)
            assert d['changed']==(d['moves']!=d['proposed'])
            if d['trainer']=='SONY3':
                assert not d['changed'],('Champion moves preserved',key)
        seen=set();entries=0;special=0
        for (trainer,number),party in records.items():
            load(trainer,number)
            assert get('wEnemyPartyCount')[0]==len(party),(trainer,number)
            for slot,(index,level) in enumerate(party,1):
                assert get(f'wEnemyMon{slot}')[0]==index,(trainer,number,slot)
                assert get(f'wEnemyMon{slot}Level')[0]==level,(trainer,number,slot)
                entries+=1;dex=dexorder[index-1]
                moves=list(get(f'wEnemyMon{slot}Moves',4));key=trainer,number,slot
                if key in expected:
                    d=expected[key];seen.add(key)
                    assert dex==d['dex'] and level==d['level'],key
                    pinned=[MOVES[m] if m!='0' else 0 for m in d['moves']]
                    assert moves==pinned+[0]*(4-len(pinned)),(key,moves,d['moves'])
                if not dex:
                    assert key==('CHIEF',2,1) and index==182 and level==128
                    special+=1;continue
                nonzero=[m for m in moves if m]
                assert len(nonzero)==len(set(nonzero)),('duplicate',key,moves)
                if (trainer,number) in revised:
                    pp=list(get(f'wEnemyMon{slot}PP',4))
                    assert pp==[move_data[(m-1)*6+5] if m else 0 for m in moves],('PP',key,moves,pp)
                    # Ditto's automatic transformation supplies its offense.
                    assert index==indexes['DITTO'] or any(move_data[(m-1)*6+2]>0 for m in nonzero),('no attack',key,moves)
                d=tune[dex]
                allowed={MOVES[m] for m in d['start']}|{MOVES[m] for lv,m in d['learn'] if lv<=level}
                allowed|={machines[n-1] for n in tms[dex]['new'] if n<=55}
                allowed|={machines[55+n-51] for n in extras[dex]['tms']}
                assert set(nonzero)<=allowed,('outside reviewed lists',key,set(nonzero)-allowed)
                if (trainer,number) in leaders:
                    put('wWhichPokemon',slot-1);put('wEnemyMonPartyPos',slot-1)
                    put('wEnemyMonSpecies2',index);put('wCurEnemyLVL',level)
                    for n in ('wEnemyBattleStatus3','wFontLoaded','wOptions'):put(n,0)
                    call('LoadEnemyMonData')
                    assert get('wEnemyMonSpecies')[0]==index and get('wEnemyMonLevel')[0]==level,key
                    assert list(get('wEnemyMonMoves',4))==moves,('send-out moves',key)
                    assert list(get('wEnemyMonPP',4))==[move_data[(m-1)*6+5] if m else 0 for m in moves],('send-out PP',key)
        assert len(records)==plan['expected_teams'] and entries==plan['expected_roster_entries']
        assert seen==set(expected) and special==1
        for title in ('ReviewedNidoranMUnique','ReviewedOmanyteUnique','ReviewedOnixBrock','ReviewedRaichuUnique','ReviewedSquirtleUnique','ReviewedTangelaErika','ReviewedTentacoolBig','ReviewedVenusaurErika'):
            bank,a=syms[title+'EvosMoves'];assert game.memory[bank,a]==0
        print(f'{version}: {len(records)} teams/{entries} entries, 313 unchanged regular rosters, 12 base Gym/Elite, seven Gym and seven League rematch teams/send-outs/PP, 36 unchanged other boss rosters, {len(expected)} exact boss sets and bounded overrides passed')
    finally:
        game.stop(save=False)


if __name__ == '__main__':
    for version in ('pokered','pokeblue'):validate(version)
