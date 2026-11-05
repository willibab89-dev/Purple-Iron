#!/usr/bin/env python3
"""Exercise new-move boundaries, presentation, learning, PP, effects and saves."""
import json
import re
from collections import Counter
from pyboy import PyBoy
from test_unique_species import ROOT, symbols
from test_move_patch_1 import EFFECTS, TYPES, CHARMAP

PLAN = json.loads((ROOT / 'data/move_patch_3.json').read_text())
NEW = PLAN['new_moves']
PATCH4 = json.loads((ROOT / 'data/move_patch_4.json').read_text())
PATCH5 = json.loads((ROOT / 'data/move_patch_5.json').read_text())
ALL_NEW = NEW + PATCH4['new_moves'] + PATCH5['new_moves']
ALL_ADDITIONS = PLAN['learnset_additions'] + PATCH4['learnset_additions'] + PATCH5['learnset_additions']
MAX_MOVE = max(d['id'] for d in ALL_NEW)


def constants(path):
    result, value = {}, 0
    for line in path.read_text().splitlines():
        m = re.match(r'const_value = (\d+)', line)
        if m: value = int(m[1])
        m = re.match(r'\s*const (\w+)', line)
        if m: result[m[1]] = value; value += 1
    return result


MOVES = constants(ROOT / 'constants/move_constants.asm')


def validate(version):
    syms = symbols(ROOT / (version + '.sym'))
    rom = (ROOT / (version + '.gbc')).read_bytes()
    def data(n, size, offset=0):
        b, a = syms[n]; start = (b*0x4000+a-0x4000 if b else a)+offset
        return rom[start:start+size]
    def addr(n): return syms[n][1]
    def encode(s): return bytes(CHARMAP[c] for c in s+'@')
    assert MOVES['STRUGGLE'] == 165
    assert MOVES['SHOWPIC_ANIM'] == 166 and MOVES['BAIT_ANIM'] == 202
    assert [x['id'] for x in NEW] == list(range(166, 176))
    for d in NEW:
        expected = bytes([d['id'], EFFECTS[d['effect']], d['power'], TYPES[d['type']], d['accuracy']*255//100, d['pp']])
        assert data('Moves', 6, (d['id']-1)*6) == expected
        assert MOVES[d['symbol']] == d['id']
    animation_map = list(range(1,166))+[MOVES[x['animation']] for x in ALL_NEW]
    assert list(data('MoveAnimationMap', MAX_MOVE)) == animation_map
    raw_names = data('MoveNames', 2400).split(b'\x50')
    for d in NEW: assert raw_names[d['id']-1]+b'\x50' == encode(d['name'])
    game = PyBoy(str(ROOT / (version+'.gbc')), window='null', sound_emulated=False)
    game.set_emulation_speed(0); game.tick(90, False)
    originals, visits = {}, Counter()
    def put(n,v): game.memory[addr(n)] = v
    def get(n): return game.memory[addr(n)]
    def word(n,v): game.memory[addr(n):addr(n)+2] = [v>>8,v&255]
    def readword(n): return (get(n)<<8)|game.memory[addr(n)+1]
    def patch(n, code):
        bank,a=syms[n]; originals.setdefault(n,list(game.memory[bank,a:a+len(code)]));game.memory[bank,a:a+len(code)]=code
    def restore(n):
        bank,a=syms[n]; code=originals.pop(n);game.memory[bank,a:a+len(code)]=code
    def call(n, **regs):
        bank,a=syms[n]; game.memory[0x2000]=game.memory[0xffb8]=bank or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,a&255,a>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0
        game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for k,v in regs.items():
            if k in ('BC','DE'):
                setattr(game.register_file,k[0],v>>8);setattr(game.register_file,k[1],v&255)
            else:setattr(game.register_file,k,v)
        for _ in range(120):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):return
        raise AssertionError((version,n,hex(game.register_file.PC),game.memory[0xffb8]))
    def init(d,turn=0):
        game.memory[0xfff3]=turn
        for n in ('wFlags_D733','wMoveMissed','wObtainedBadges','wLinkState','wOptions','wCustomTargetHadSub','wPlayerMonNumber','wEnemyMonPartyPos'):
            put(n,0)
        put('wIsInBattle',2)
        for side in ('Player','Enemy'):
            for i in range(1,4):put(f'w{side}BattleStatus{i}',0)
            game.memory[addr(f'w{side}MonStatMods'):addr(f'w{side}MonStatMods')+6]=[7]*6
            for i in range(4):game.memory[addr(f'w{side}MonUnmodifiedAttack')+i*2:addr(f'w{side}MonUnmodifiedAttack')+i*2+2]=[0,100]
        for prefix in ('wBattleMon','wEnemyMon'):
            word(prefix+'HP',50);word(prefix+'MaxHP',200);put(prefix+'Status',0)
            put(prefix+'Species',153);put(prefix+'Level',50)
            game.memory[addr(prefix+'Type'):addr(prefix+'Type')+2]=[0,0]
            for stat in ('Attack','Defense','Speed','Special'):word(prefix+stat,100)
        actor='Enemy' if turn else 'Player'
        put(f'w{actor}SelectedMove',d['id']);call('GetCurrentMove')
        return actor,'Player' if turn else 'Enemy'
    try:
        # All move names through the real home-bank lookup, retaining move IDs.
        for i in range(1,MAX_MOVE+1):
            put('wd11e',i);call('GetMoveName')
            expected=raw_names[i-1]+b'\x50'
            assert bytes(game.memory[addr('wcd6d'):addr('wcd6d')+len(expected)])==expected,i
            assert get('wd0b5')==i and get('wNameListType')==2
        # Future high move IDs must never be treated as machine-item names.
        for kind in (1,2,3,4,7):
            for i in range(190,255):
                put('wNameListType',kind);put('wd0b5',i);call('ClassifyMachineName')
                machine=kind==4 and i>=196
                assert get('wNameListType')==(3 if machine else kind)
                assert get('wd0b5')==(i-195 if machine else i)
        put('wNameListType',4);put('wd0b5',1);put('wPredefBank',syms['ItemNames'][0]);call('GetName',HL=0xc100,BC=0x1234)
        assert bytes(game.memory[addr('wcd6d'):addr('wcd6d')+12])==encode('MASTER BALL')
        assert game.register_file.HL==0xc100 and (game.register_file.B<<8|game.register_file.C)==0x1234
        for item_id,name in ((196,'HM01 CUT'),(201,'TM01 MEGPNCH')):
            put('wNameListType',4);put('wd0b5',item_id);put('wPredefBank',syms['ItemNames'][0]);call('GetName')
            assert bytes(game.memory[addr('wcd6d'):addr('wcd6d')+len(name)+1])==encode(name)
            assert get('wNameListType')==4
        # Every mapped ID including zero/invalid inputs; raw IDs are separate.
        for i in range(256):
            put('wAnimationID',i);call('MapMoveAnimation')
            assert get('wAnimationID')==(animation_map[i-1] if 1<=i<=MAX_MOVE else 0)
        for n in ('MoveAnimation','Delay3','Func_78e98','DelayFrames','PrintText'):
            patch(n,[0xc9])
        for turn in (0,1):
            for d in NEW:
                actor,target=init(d,turn)
                base=addr(f'w{actor}MoveNum')
                assert bytes(game.memory[base:base+6])==data('Moves',6,(d['id']-1)*6)
                for entry in ('PlayCurrentMoveAnimation','PlayCurrentMoveAnimation2'):
                    call(entry,HL=0xc100,BC=0x1234)
                    assert get('wAnimationID')==MOVES[d['animation']],(entry,d)
                    assert get(f'w{actor}MoveNum')==d['id']
                    assert game.register_file.HL==0xc100
                call('PlayMappedMoveAnimation',A=d['id'])
                assert get('wAnimationID')==MOVES[d['animation']]
            for i in range(166,203):
                for entry in ('PlayMoveAnimation','PlayBattleAnimation','PlayBattleAnimation2'):
                    call(entry,A=i);assert get('wAnimationID')==i,(entry,i)
        # Metronome rejects holes/sentinels/itself/Struggle, accepts all 10 new IDs.
        patch('IncrementMovePP',[0xc9])
        for turn in (0,1):
            for candidate in range(256):
                game.memory[0xfff3]=turn;put('wUnusedD119',candidate)
                # First RNG byte is candidate, then a valid new move (Giga Drain).
                patch('BattleRandom',[0xfa,addr('wUnusedD119')&255,addr('wUnusedD119')>>8,0xf5,0x3e,166,0xea,addr('wUnusedD119')&255,addr('wUnusedD119')>>8,0xf1,0xc9])
                call('MetronomePickMove')
                expected=candidate if 1<=candidate<=MAX_MOVE and candidate not in (118,165) else 166
                actor='Enemy' if turn else 'Player'
                assert get(f'w{actor}SelectedMove')==expected,(turn,candidate)
                assert get(f'w{actor}MoveNum')==expected
        restore('BattleRandom');restore('IncrementMovePP')
        # Check every original learnset plus additions, including inherited variants.
        evo_bank=syms['EvosMovesPointerTable'][0]
        pointers=data('EvosMovesPointerTable',190*2)
        dex=data('PokedexOrder',190)
        species_ids={}
        for species,old in PLAN['learnset_baseline'].items():
            if species+'EvosMoves' not in syms:
                assert not old and species.startswith('MissingNo')
                continue
            ptr=syms[species+'EvosMoves'][1]
            pos=ptr
            while game.memory[evo_bank,pos]:pos+=1
            pos+=1;actual=[]
            while game.memory[evo_bank,pos]:
                actual.append((game.memory[evo_bank,pos],game.memory[evo_bank,pos+1]));pos+=2
            extra=[(x['level'],MOVES[x['move']]) for x in ALL_ADDITIONS if x['species']==species]
            expected=sorted([(level,MOVES[move]) for level,move in old]+extra)
            assert actual==expected,(species,actual,expected)
            assert len(actual)+4<48 # existing relearner buffer capacity
            if extra:
                for i in range(190):
                    if 1<=dex[i]<=151 and int.from_bytes(pointers[2*i:2*i+2],'little')==ptr:
                        species_ids[species]=i+1;break
                assert species in species_ids,species
        # Wild/daycare generation and relearner expose every new learnset entry.
        patch('GetPredefRegisters',[0xc9])
        for addition in PLAN['learnset_additions']:
            species,level=addition['species'],addition['level'];species_id=species_ids[species];move=MOVES[addition['move']]
            put('wcf91',species_id);put('wCurEnemyLVL',level);put('wLearningMovesFromDayCare',1);put('wDayCareStartLevel',level-1)
            game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
            game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4]=[0]*4
            call('WriteMonMoves',DE=addr('wPartyMon1Moves'))
            assert get('wPartyMon1Moves')==move,(addition,get('wPartyMon1Moves'))
            assert get('wPartyMon1PP')==next(x['pp'] for x in NEW if x['id']==move)
            put('wPartyCount',1);put('wPartySpecies',species_id);put('wWhichPokemon',0);put('wPartyMon1Level',level)
            game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
            call('PrepareRelearnableMoveList')
            length=get('wMoveBuffer');buf=list(game.memory[addr('wMoveBuffer')+1:addr('wMoveBuffer')+1+length])
            assert move in buf,addition
        # New move PP values pass through the ordinary PP-table reader.
        game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[166,169,172,175]
        call('LoadMovePPs',HL=addr('wPartyMon1Moves'),DE=addr('wPartyMon1PP')-1)
        assert list(game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4])==[10,15,15,10]
        # Real save/load preserves high move IDs and PP using the existing layout.
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2')
        game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
        call('LoadSAV0');call('LoadSAV2');assert not(game.register_file.F&0x10)
        assert list(game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4])==[166,169,172,175]
        assert list(game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4])==[10,15,15,10]
        # Reused handlers still use actual move IDs, not their mapped animation IDs.
        for n in ('PlayCurrentMoveAnimation','PlayCurrentMoveAnimation2','UpdateHPBar2','DrawPlayerHUDAndHPBar','DrawEnemyHUDAndHPBar','DrawHUDsAndHPBars','PrintButItFailedText_'):
            patch(n,[0xc9])
        for turn in (0,1):
            for d in NEW:
                actor,target=init(d,turn)
                prefix='wEnemyMon' if turn else 'wBattleMon'
                if d['effect']=='DRAIN_HP_EFFECT':word('wDamage',100)
                patch('BattleRandom',[0x3e,0,0xc9])
                call('JumpMoveEffect')
                if d['effect'] in ('DRAIN_HP_EFFECT','HEAL_EFFECT'):
                    assert readword(prefix+'HP')==(100 if d['effect']=='DRAIN_HP_EFFECT' else 150),(turn,d)
                    assert get(prefix+'Status')==0 # recovery clones must not invoke Rest
                if d['effect']=='SPEED_UP2_EFFECT':assert get(f'w{actor}MonSpeedMod')==9
                if d['effect']=='DEFENSE_UP2_EFFECT':assert get(f'w{actor}MonDefenseMod')==9
                if d['effect']=='FLINCH_SIDE_EFFECT2':assert get(f'w{target}BattleStatus1')&8
        # Full damage/application routing for every new move on both actors.
        for n in ('PrintMonName1Text','PlayMoveAnimation','PrintCriticalOHKOText',
                  'DisplayEffectiveness','CriticalHitTest','RandomizeDamage'):
            patch(n,[0xc9])
        for turn in (0,1):
            for d in NEW:
                actor,target=init(d,turn)
                actor_prefix='wEnemyMon' if turn else 'wBattleMon'
                target_prefix='wBattleMon' if turn else 'wEnemyMon'
                word(target_prefix+'HP',200)
                game.memory[addr(target_prefix+'Type'):addr(target_prefix+'Type')+2]=[22,22] # Grass; no immunity
                put('wCriticalHitOrOHKO',0);put('wUnusedC000',0)
                put(f'w{target}MoveNum',1);put(f'w{target}MoveEffect',0);put(f'w{target}MovePower',40)
                put('wPlayerMoveListIndex',0)
                put('wBattleMonPP',d['pp']);put('wPartyMon1PP',d['pp'])
                call('EnemyCanExecuteMove' if turn else 'PlayerCanExecuteMove')
                if d['power']:
                    assert readword(target_prefix+'HP')<200,('damage',turn,d)
                else:assert readword(target_prefix+'HP')==200
                if d['effect']=='DRAIN_HP_EFFECT':assert readword(actor_prefix+'HP')>50
                if d['effect']=='HEAL_EFFECT':assert readword(actor_prefix+'HP')==150
                if not turn:
                    assert get('wBattleMonPP')==d['pp']-1
                    assert get('wPartyMon1PP')==d['pp']-1
        print(f'{version}: 10 new records/names; all animation boundaries/raw IDs; all 256 Metronome inputs both sides; 95 learnset additions/relearner/PP; high-ID save round-trip; reused effects passed')
    finally:game.stop(save=False)


if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
