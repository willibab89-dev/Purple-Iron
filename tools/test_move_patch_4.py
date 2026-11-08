#!/usr/bin/env python3
"""Validate conditional power, hybrid stats, crit/accuracy gates and migration ABI."""
import hashlib
import json
from pyboy import PyBoy
from test_unique_species import ROOT, symbols, TUNING
from test_move_patch_1 import EFFECTS, TYPES
from test_move_patch_3 import MOVES

PLAN=json.loads((ROOT/'data/move_patch_4.json').read_text())
NEW={d['symbol']:d for d in PLAN['new_moves']}
CUSTOM={'STOMP','TAKE_DOWN','DRILL_PECK','WATERFALL',*NEW}


def validate(version):
    syms=symbols(ROOT/(version+'.sym'));game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return syms[n][1]
    def put(n,v):game.memory[addr(n)]=v
    def get(n):return game.memory[addr(n)]
    def word(n,v):game.memory[addr(n):addr(n)+2]=[v>>8,v&255]
    def readword(n):return get(n)*256+game.memory[addr(n)+1]
    saved={}
    def patch(n,code):
        b,a=syms[n];saved.setdefault(n,list(game.memory[b,a:a+len(code)]));game.memory[b,a:a+len(code)]=code
    def restore(n):
        b,a=syms[n];code=saved.pop(n);game.memory[b,a:a+len(code)]=code
    def call(n,**regs):
        b,a=syms[n];game.memory[0x2000]=game.memory[0xffb8]=b or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,a&255,a>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0;game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for k,v in regs.items():
            if k in ('BC','DE'):
                setattr(game.register_file,k[0],v>>8);setattr(game.register_file,k[1],v&255)
            else:setattr(game.register_file,k,v)
        for _ in range(120):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):return
        raise AssertionError((version,n,hex(game.register_file.PC),game.memory[0xffb8],get('wPlayerMoveNum'),get('wEnemyMoveNum')))
    def output():return tuple(getattr(game.register_file,k) for k in ('B','C','D','E'))
    def init(move,turn=0):
        game.memory[0xfff3]=turn
        for n in ('wMoveMissed','wFlags_D733','wCriticalHitOrOHKO','wObtainedBadges','wOptions','wUnusedC000','wPlayerMonNumber','wEnemyMonPartyPos','wPlayerMoveListIndex'):
            put(n,0)
        put('wIsInBattle',2);put('wLinkState',4);put('wMonHBaseSpeed',100)
        for side,prefix,party in (('Player','wBattleMon','wPartyMon1'),('Enemy','wEnemyMon','wEnemyMon1')):
            for i in (1,2,3):put(f'w{side}BattleStatus{i}',0)
            game.memory[addr(f'w{side}MonStatMods'):addr(f'w{side}MonStatMods')+6]=[7]*6
            for i,stat in enumerate(('Attack','Defense','Speed','Special')):
                word(prefix+stat,100);word(party+stat,100)
                game.memory[addr(f'w{side}MonUnmodifiedAttack')+i*2:addr(f'w{side}MonUnmodifiedAttack')+i*2+2]=[0,100]
            word(prefix+'HP',200);word(prefix+'MaxHP',200);put(prefix+'Status',0);put(prefix+'Level',50);put(prefix+'Species',153)
            game.memory[addr(prefix+'Type'):addr(prefix+'Type')+2]=[22,22]
        actor='Enemy' if turn else 'Player';target='Player' if turn else 'Enemy'
        put(f'w{actor}SelectedMove',MOVES[move]);call('GetCurrentMove')
        patch('BattleRandom',[0x3e,255,0xc9])
        return actor,target,('wEnemyMon' if turn else 'wBattleMon'),('wBattleMon' if turn else 'wEnemyMon')
    def variables(turn):
        call('GetDamageVarsForEnemyAttack' if turn else 'GetDamageVarsForPlayerAttack');return output()
    def power(move,turn):init(move,turn);return variables(turn)[2]
    try:
        assert hashlib.sha256((ROOT/'engine/battle/legacy_damage_vars.asm').read_bytes()).hexdigest()==PLAN['legacy_damage_source_sha256']
        # Full move-table delta, including unchanged legacy moves/new patch-3 IDs.
        bank,start=syms['Moves'];updates={x['id']:x['after'] for x in PLAN['existing_changes']}
        patch5=json.loads((ROOT/'data/move_patch_5.json').read_text())
        updates.update({x['id']:x['after'] for x in patch5['existing_changes']})
        patch6=json.loads((ROOT/'data/move_patch_6.json').read_text())
        updates.update({x['id']:x['after'] for x in patch6['existing_changes']})
        patch7=json.loads((ROOT/'data/move_patch_7.json').read_text())
        updates.update({x['id']:x['after'] for x in patch7['existing_changes']})
        patch8=json.loads((ROOT/'data/move_patch_8.json').read_text())
        updates.update({x['id']:x['after'] for x in patch8['existing_changes']})
        entries=[updates.get(x['id'],x) for x in PLAN['baseline_moves']]+PLAN['new_moves']
        assert len(entries)==191
        for d in entries:
            expected=[d['id'],EFFECTS[d['effect']],d['power'],TYPES[d['type']],d['accuracy']*255//100,d['pp']]
            assert list(game.memory[bank,start+(d['id']-1)*6:start+d['id']*6])==expected,d['symbol']
        for n in ('GetMonHeader','PrintText','PrintButItFailedText_','DelayFrames'):
            patch(n,[0xc9])
        for turn in (0,1):
            for move in ('STOMP','TAKE_DOWN','BRINE','INCINERATE','VENOSHOCK','POLLUTION','FACADE','ICE_SHARD'):
                actor,target,ap,tp=init(move,turn);base=variables(turn)[2]
                # Each condition is evaluated using the current action-time state.
                if move=='STOMP':put(f'w{target}BattleStatus1',128)
                elif move in ('TAKE_DOWN','BRINE'):word(tp+'HP',99)
                elif move=='INCINERATE':put(tp+'Status',16)
                elif move=='VENOSHOCK':put(tp+'Status',8)
                elif move=='POLLUTION':game.memory[addr(tp+'Type')+1]=21
                elif move=='FACADE':put(ap+'Status',64)
                elif move=='ICE_SHARD':put(tp+'Status',32)
                assert variables(turn)[2]==base*2,(move,turn,base,output())
                assert get(f'w{actor}MovePower')==next(d['power'] for d in entries if d['symbol']==move)
            # Exact half boundaries, including odd HP maxima.
            for move in ('TAKE_DOWN','BRINE'):
                for maximum in (199,200,201,999):
                    for hp in (maximum//2-1,maximum//2,maximum//2+1):
                        actor,target,ap,tp=init(move,turn);word(tp+'MaxHP',maximum);word(tp+'HP',hp)
                        qualifies=hp*2<maximum if move=='TAKE_DOWN' else hp*2<=maximum
                        assert variables(turn)[2]==(60 if move=='TAKE_DOWN' else 50)*(2 if qualifies else 1),(move,maximum,hp,output())
            # Flail boundaries and full-width HP arithmetic (no eight-bit divisor).
            for maximum in (1,48,100,255,256,511,999,65535):
                for hp in sorted({1,maximum,*[max(1,min(maximum,(maximum*k)//48+j)) for k in (2,5,10,17,33) for j in (-1,0,1)]}):
                    actor,target,ap,tp=init('FLAIL',turn);word(ap+'HP',hp);word(ap+'MaxHP',maximum)
                    r=max(1,hp*48//maximum)
                    expected=200 if r<2 else 150 if r<5 else 100 if r<10 else 80 if r<17 else 40 if r<33 else 20
                    assert variables(turn)[2]==expected,('Flail',maximum,hp,r,output())
            for stages in ([7]*6,[8,7,7,7,7,7],[6,9,5,7,8,7],[13]*6):
                actor,target,ap,tp=init('PUNISHMENT',turn)
                game.memory[addr(f'w{target}MonStatMods'):addr(f'w{target}MonStatMods')+6]=stages
                assert variables(turn)[2]==min(160,40+20*sum(max(0,x-7) for x in stages))
            # Defensive bypass preserves negative stages and screens.
            for move,stat,index in (('DRILL_PECK','Defense',1),('PIERCE','Defense',1),('WATERFALL','Special',3)):
                for stage,value,expected in ((9,200,100),(7,100,100),(5,50,50)):
                    actor,target,ap,tp=init(move,turn);word(tp+stat,value);game.memory[addr(f'w{target}MonStatMods')+index]=stage
                    assert variables(turn)[1]==expected,(move,stage,output())
                    put(f'w{target}BattleStatus3',4 if stat=='Defense' else 2)
                    assert variables(turn)[1]==expected*2,(move,'screen',output())
            # Stage bypass preserves the target player's independent badge boost.
            if turn:
                for move,stat,index,badge in (('DRILL_PECK','Defense',1,4),('WATERFALL','Special',3,64)):
                    actor,target,ap,tp=init(move,turn);put('wLinkState',0);put('wObtainedBadges',badge)
                    word(tp+stat,210);game.memory[addr(f'w{target}MonStatMods')+index]=9
                    assert variables(turn)[1]==105,(move,'badge bypass',output())
                    put('wCriticalHitOrOHKO',1);assert variables(turn)[1]==100
            # Hybrid stats and screen category, then Gen 1 crit behavior.
            for move,offense in (('STONE_PRESS','Defense'),('PSYSHOCK','Special')):
                actor,target,ap,tp=init(move,turn)
                word(ap+'Attack',10);word(ap+offense,200);word(tp+'Defense',50);word(tp+'Special',250)
                b,c,d,e=variables(turn);assert (b,c)==(200,50),(move,output())
                put(f'w{target}BattleStatus3',2);assert variables(turn)[:2]==(200,50) # Light Screen ignored
                put(f'w{target}BattleStatus3',4);assert variables(turn)[:2]==(200,100)
                put('wCriticalHitOrOHKO',1);assert variables(turn)[:2]==(100,100)
            # Facade reconstructs odd burnt Attack exactly, and leaves it stored.
            actor,target,ap,tp=init('FACADE',turn);put(ap+'Status',16);word(ap+'Attack',50)
            game.memory[addr(f'w{actor}MonUnmodifiedAttack'):addr(f'w{actor}MonUnmodifiedAttack')+2]=[0,101]
            assert variables(turn)[0]==101 and readword(ap+'Attack')==50
            put(f'w{actor}MonAttackMod',8);word(ap+'Attack',75);assert variables(turn)[0]==151
            put('wCriticalHitOrOHKO',1);assert variables(turn)[0]==101
            if not turn:
                actor,target,ap,tp=init('FACADE',turn);put('wLinkState',0);put('wObtainedBadges',1)
                put(ap+'Status',16);put(f'w{actor}MonAttackMod',8);word(ap+'Attack',79)
                game.memory[addr('wPlayerMonUnmodifiedAttack'):addr('wPlayerMonUnmodifiedAttack')+2]=[0,101]
                assert variables(turn)[0]==158 and readword(ap+'Attack')==79
                put('wOptions',64);assert variables(turn)[0]==151
                put('wIsInBattle',1);assert variables(turn)[0]==158
            # Guaranteed crits work at every RNG byte; false conditions retain normal crits.
            for move,status in (('SHOCK_WAVE',64),('POISON_TAIL',8),('FROST_BREATH',0)):
                actor,target,ap,tp=init(move,turn)
                call('CriticalHitTest');assert get('wCriticalHitOrOHKO')==0
                patch('BattleRandom',[0x3e,0,0xc9]);call('CriticalHitTest');assert get('wCriticalHitOrOHKO')==1
                put(tp+'Status',status)
                if move=='FROST_BREATH':put(f'w{target}MonSpeedMod',6)
                for roll in range(256):
                    patch('BattleRandom',[0x3e,roll,0xc9]);call('CriticalHitTest');assert get('wCriticalHitOrOHKO')==1,(move,roll)
                if move=='FROST_BREATH':
                    put(f'w{target}MonSpeedMod',7);put(tp+'Status',64);patch('BattleRandom',[0x3e,255,0xc9]);call('CriticalHitTest');assert get('wCriticalHitOrOHKO')==0
            # Accuracy bypass still respects Fly/Dig and earlier immunity failures.
            for move in ('THUNDER','SNIPE_SHOT','AERIAL_ACE'):
                actor,target,ap,tp=init(move,turn)
                put(f'w{actor}MonAccuracyMod',1);put(f'w{target}MonEvasionMod',13)
                if move=='THUNDER':put(tp+'Status',8)
                call('MoveHitTest');assert get('wMoveMissed')==0,move
                put(f'w{target}BattleStatus1',64);call('MoveHitTest');assert get('wMoveMissed')==1
            actor,target,ap,tp=init('THUNDER',turn);call('MoveHitTest');assert get('wMoveMissed')==1
            init('THUNDER',turn);put(tp+'Status',8);game.memory[addr(tp+'Type'):addr(tp+'Type')+2]=[4,4]
            word('wDamage',100);call('AdjustDamageForMoveType');call('MoveHitTest');assert get('wMoveMissed')==1
            # Confusion's temporary typeless 40-power attack must bypass new hooks.
            actor,target,ap,tp=init('FACADE',turn);put(ap+'Status',16);put(f'w{actor}MovePower',40);put(f'w{actor}MoveType',0)
            assert variables(turn)[2]==40
        # Same-bank legacy outputs equal the public far-call ABI for all unaffected damaging moves.
        differential=0
        for turn in (0,1):
            for d in PLAN['baseline_moves']:
                if d['symbol'] in CUSTOM or d['symbol']=='THUNDER' or not d['power']:continue
                for crit in (0,1):
                    actor,target,ap,tp=init(d['symbol'],turn);put('wCriticalHitOrOHKO',crit)
                    word(ap+'Attack',350);word(ap+'Special',350);word(tp+'Defense',2);word(tp+'Special',2)
                    call('LegacyEnemyDamageVars' if turn else 'LegacyPlayerDamageVars');expected=output()
                    assert variables(turn)==expected,(d['symbol'],turn,crit,expected,output())
                    differential+=1
        # The four existing stat-selected moves match legacy behavior when their
        # bonus/bypass condition is inactive, including crits and both screens.
        for turn in (0,1):
            for move in ('STOMP','TAKE_DOWN','DRILL_PECK','WATERFALL'):
                for crit in (0,1):
                    for screen in (0,6):
                        actor,target,ap,tp=init(move,turn);put('wCriticalHitOrOHKO',crit)
                        put(f'w{target}BattleStatus3',screen)
                        word(ap+'Attack',231);word(ap+'Special',231);word(tp+'Defense',120);word(tp+'Special',120)
                        call('LegacyEnemyDamageVars' if turn else 'LegacyPlayerDamageVars');expected=output()
                        assert variables(turn)==expected,(move,crit,screen,expected,output())
                        differential+=1
        # AI uses predicted power, while action loading resets the table power.
        for move,expected in (('FLAIL',200),('BRINE',100),('PUNISHMENT',160)):
            actor,target,ap,tp=init(move,1)
            if move=='FLAIL':word(ap+'HP',1)
            if move=='BRINE':word(tp+'HP',100)
            if move=='PUNISHMENT':game.memory[addr('wPlayerMonStatMods'):addr('wPlayerMonStatMods')+6]=[13]*6
            game.memory[0xfff3]=0;call('ReadMove',A=MOVES[move]);assert get('wEnemyMovePower')==expected
            assert game.memory[0xfff3]==0
            game.memory[0xfff3]=1;call('GetCurrentMove');assert get('wEnemyMovePower')==NEW[move]['power']
        # Run complete damage/application/effect routing, retaining recoil/flinch.
        for n in ('PrintMonName1Text','PlayMoveAnimation','PrintCriticalOHKOText',
                  'DisplayEffectiveness','CriticalHitTest','RandomizeDamage','Delay3','Func_78e98','MoveAnimation',
                  'DrawPlayerHUDAndHPBar','DrawEnemyHUDAndHPBar','DrawHUDsAndHPBars','UpdateHPBar2',
                  'HideSubstituteShowMonAnim','ReshowSubstituteAnim'):
            patch(n,[0xc9])
        for turn in (0,1):
            for move in sorted(CUSTOM|{'THUNDER'}):
                actor,target,ap,tp=init(move,turn);patch('BattleRandom',[0x3e,0,0xc9])
                if move=='STOMP':put(f'w{target}BattleStatus1',128)
                if move in ('TAKE_DOWN','BRINE'):word(tp+'HP',99)
                if move=='INCINERATE':put(tp+'Status',16)
                if move=='VENOSHOCK':put(tp+'Status',8)
                if move=='FACADE':put(ap+'Status',16);word(ap+'Attack',50)
                if move=='POLLUTION':game.memory[addr(tp+'Type')+1]=21
                if move=='ICE_SHARD':put(tp+'Status',32)
                if move=='PUNISHMENT':game.memory[addr(f'w{target}MonStatMods'):addr(f'w{target}MonStatMods')+6]=[13]*6
                put(f'w{target}MoveNum',1);put(f'w{target}MoveEffect',0);put(f'w{target}MovePower',40)
                base=next(d for d in entries if d['symbol']==move)
                put('wBattleMonPP',base['pp']);put('wPartyMon1PP',base['pp'])
                b,c,d,e=variables(turn)
                expected_damage=min(999,((2*e//5+2)*d*b//c)//50+2)
                call('CalculateDamage')
                assert readword('wDamage')==expected_damage,('damage formula',move,output(),readword('wDamage'),expected_damage)
                before=readword(tp+'HP')
                call('EnemyCanExecuteMove' if turn else 'PlayerCanExecuteMove')
                assert readword(tp+'HP')<before,('pipeline damage',turn,move,readword(tp+'HP'))
                if move=='STOMP':assert get(f'w{target}BattleStatus1')&8
                if move=='TAKE_DOWN':assert readword(ap+'HP')<200
                if move=='ICE_SHARD':assert get(tp+'Status')&32
                if not turn:
                    assert get('wBattleMonPP')==base['pp']-1
                    assert get('wPartyMon1PP')==base['pp']-1
            # Substitute breaking must not leak Flail's temporary HP scratch into a hit.
            actor,target,ap,tp=init('FLAIL',turn);patch('BattleRandom',[0x3e,0,0xc9])
            word(ap+'HP',1);put(f'w{target}BattleStatus2',16);put(f'w{target}SubstituteHP',1)
            call('EnemyCanExecuteMove' if turn else 'PlayerCanExecuteMove')
            assert readword(tp+'HP')==200
            assert get(f'w{target}BattleStatus2')&16==0
        # Actual learning/relearning and PP for every patch-4 assignment.
        restore('GetMonHeader');patch('GetPredefRegisters',[0xc9])
        bank,table=syms['EvosMovesPointerTable']
        dex_bank,dex_addr=syms['PokedexOrder']
        species_ids={}
        for addition in [x for x in PLAN['learnset_additions'] if x['species'].lower() not in TUNING]:
            species=addition['species'];level=addition['level'];move=MOVES[addition['move']]
            if species not in species_ids:
                pointer=addr(species+'EvosMoves')
                species_ids[species]=next(i+1 for i in range(190) if 1<=game.memory[dex_bank,dex_addr+i]<=151 and int.from_bytes(bytes(game.memory[bank,table+2*i:table+2*i+2]),'little')==pointer)
            index=species_ids[species]
            put('wcf91',index);put('wCurEnemyLVL',level);put('wLearningMovesFromDayCare',1);put('wDayCareStartLevel',level-1)
            game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
            call('WriteMonMoves',DE=addr('wPartyMon1Moves'))
            assert get('wPartyMon1Moves')==move,addition
            assert get('wPartyMon1PP')==NEW[addition['move']]['pp']
            put('wPartyCount',1);put('wPartySpecies',index);put('wWhichPokemon',0);put('wPartyMon1Level',level)
            game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
            call('PrepareRelearnableMoveList')
            assert move in list(game.memory[addr('wMoveBuffer')+1:addr('wMoveBuffer')+1+get('wMoveBuffer')]),addition
        game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[176,182,188,191]
        game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4]=[20,10,10,15]
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2')
        game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
        call('LoadSAV0');call('LoadSAV2')
        assert not(game.register_file.F&16)
        assert list(game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4])==[176,182,188,191]
        assert list(game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4])==[20,10,10,15]
        print(f'{version}: 191 records; conditional/Flail/Punishment boundaries; hybrid stats, screens, burn, 1536 guaranteed-crit rolls; accuracy/immunity gates; {differential} legacy ABI comparisons; AI reload passed')
    finally:game.stop(save=False)


if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
