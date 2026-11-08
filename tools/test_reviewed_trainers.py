#!/usr/bin/env python3
"""Verify final Gym parties after natural learnsets and special-move overrides."""
import re
import json
import hashlib
from pyboy import PyBoy
from test_unique_species import ROOT, TUNING, symbols
from test_move_patch_3 import MOVES

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
        expected={(d['trainer'],d['number'],d['slot']):d for d in plan['changes']+plan['preserved']}
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
                    assert moves==[MOVES[m] for m in d['moves']],(key,moves,d['moves'])
                if not dex:
                    assert key==('CHIEF',2,1) and index==182 and level==128
                    special+=1;continue
                nonzero=[m for m in moves if m]
                assert len(nonzero)==len(set(nonzero)),('duplicate',key,moves)
                d=tune[dex]
                allowed={MOVES[m] for m in d['start']}|{MOVES[m] for lv,m in d['learn'] if lv<=level}
                allowed|={machines[n-1] for n in tms[dex]['new'] if n<=55}
                allowed|={machines[55+n-51] for n in extras[dex]['tms']}
                assert set(nonzero)<=allowed,('outside reviewed lists',key,set(nonzero)-allowed)
        assert len(records)==plan['expected_teams'] and entries==plan['expected_roster_entries']
        assert seen==set(expected) and special==1
        for title in ('ReviewedNidoranMUnique','ReviewedOmanyteUnique','ReviewedOnixBrock','ReviewedRaichuUnique','ReviewedSquirtleUnique','ReviewedTangelaErika','ReviewedTentacoolBig','ReviewedVenusaurErika'):
            bank,a=syms[title+'EvosMoves'];assert game.memory[bank,a]==0
        print(f'{version}: {len(records)} final teams/{entries} entries, {len(expected)} exact reviewed sets, zero regular-species duplicates or coverage violations, unchanged rosters/levels, bounded override records and preserved special encounter passed')
    finally:
        game.stop(save=False)


if __name__ == '__main__':
    for version in ('pokered','pokeblue'):validate(version)
