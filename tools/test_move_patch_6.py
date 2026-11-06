#!/usr/bin/env python3
"""Exercise priority, timed Rage, fixed Bide, charge effects and multi-strike paths."""
import json
from pyboy import PyBoy
from test_unique_species import ROOT,symbols,TUNING
from test_move_patch_1 import EFFECTS,TYPES
from test_move_patch_3 import MOVES

PLAN=json.loads((ROOT/'data/move_patch_6.json').read_text())
NEW={x['symbol']:x for x in PLAN['new_moves']}


def validate(version):
    syms=symbols(ROOT/(version+'.sym'));game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return syms[n][1]
    def put(n,v):game.memory[addr(n)]=v
    def get(n):return game.memory[addr(n)]
    def word(n,v):game.memory[addr(n):addr(n)+2]=[v>>8,v&255]
    def readword(n):return get(n)*256+game.memory[addr(n)+1]
    saved={};state={'values':[0],'index':0};applied=[]
    def patch(n,code):
        b,a=syms[n];saved.setdefault(n,list(game.memory[b,a:a+len(code)]));game.memory[b,a:a+len(code)]=code
    def restore(n):
        b,a=syms[n];c=saved.pop(n);game.memory[b,a:a+len(c)]=c
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
        raise AssertionError((version,n,hex(game.register_file.PC),game.memory[0xffb8]))
    def rng(*v):state.update(values=list(v),index=0)
    def on_rng(s):
        i=s['index'];game.register_file.A=s['values'][min(i,len(s['values'])-1)];s['index']+=1
    def init(move,turn=0):
        game.memory[0xfff3]=turn
        for n in ('wFlags_D733','wMoveMissed','wCriticalHitOrOHKO','wObtainedBadges','wOptions','wUnusedC000','wPlayerMonNumber','wEnemyMonPartyPos','wPlayerMoveListIndex','wCustomTargetHadSub','wActionResultOrTookBattleTurn','wPlayerDisabledMoveNumber','wEnemyDisabledMoveNumber','wPlayerDisabledMove','wEnemyDisabledMove'):
            put(n,0)
        put('wIsInBattle',2);put('wLinkState',0);put('wCurMap',0)
        call('ClearCounterRecord')
        for side,prefix,party in (('Player','wBattleMon','wPartyMon1'),('Enemy','wEnemyMon','wEnemyMon1')):
            for i in (1,2,3):put(f'w{side}BattleStatus{i}',0)
            put(f'w{side}NumAttacksLeft',0);put(f'w{side}NumHits',0);put(f'w{side}SelectedMove',MOVES['TACKLE']);put(f'w{side}MoveNum',MOVES['TACKLE']);put(f'w{side}MovePower',40);put(f'w{side}MoveType',0)
            word(f'w{side}BideAccumulatedDamage',0)
            game.memory[addr(f'w{side}MonStatMods'):addr(f'w{side}MonStatMods')+6]=[7]*6
            for i,stat in enumerate(('Attack','Defense','Speed','Special')):
                word(prefix+stat,100);word(party+stat,100)
                game.memory[addr(f'w{side}MonUnmodifiedAttack')+i*2:addr(f'w{side}MonUnmodifiedAttack')+i*2+2]=[0,100]
            word(prefix+'HP',200);word(prefix+'MaxHP',200);put(prefix+'Status',0);put(prefix+'Level',50);put(prefix+'Species',153)
            game.memory[addr(prefix+'Type'):addr(prefix+'Type')+2]=[22,22]
        actor='Enemy' if turn else 'Player';target='Player' if turn else 'Enemy'
        put(f'w{actor}SelectedMove',MOVES[move]);call('GetCurrentMove')
        put('wBattleMonPP',20);put('wPartyMon1PP',20);rng(0);applied.clear()
        return actor,target,('wEnemyMon' if turn else 'wBattleMon'),('wBattleMon' if turn else 'wEnemyMon')
    def execute(turn):call('ExecuteEnemyMove' if turn else 'ExecutePlayerMove')
    try:
        for n in ('PrintText','PrintButItFailedText_','PrintMonName1Text','PlayMoveAnimation','PlayCurrentMoveAnimation',
                  'PlayCurrentMoveAnimation2','PrintCriticalOHKOText','DisplayEffectiveness','CriticalHitTest','RandomizeDamage',
                  'DelayFrames','Delay3','Func_78e98','DrawHUDsAndHPBars','DrawPlayerHUDAndHPBar','DrawEnemyHUDAndHPBar','UpdateHPBar2',
                  'MoveAnimation','HideSubstituteShowMonAnim','ReshowSubstituteAnim'):
            patch(n,[0xc9])
        patch('BattleRandom',[0xc9]);b,a=syms['BattleRandom'];game.hook_register(b,a,on_rng,state)
        for label in ('ApplyAttackToPlayerPokemon','ApplyAttackToEnemyPokemon'):
            b,a=syms[label];game.hook_register(b,a,lambda label:applied.append(label),label)
        # Approve only the cumulative move delta; names/animations also have prior tests.
        b,start=syms['Moves'];updates={x['id']:x['after'] for x in PLAN['existing_changes']}
        patch7=json.loads((ROOT/'data/move_patch_7.json').read_text())
        updates.update({x['id']:x['after'] for x in patch7['existing_changes']})
        patch8=json.loads((ROOT/'data/move_patch_8.json').read_text())
        updates.update({x['id']:x['after'] for x in patch8['existing_changes']})
        entries=[updates.get(x['id'],x) for x in PLAN['baseline_moves']]+PLAN['new_moves'];assert len(entries)==216
        for d in entries:
            expected=[d['id'],EFFECTS[d['effect']],d['power'],TYPES[d['type']],d['accuracy']*255//100,d['pp']]
            assert list(game.memory[b,start+(d['id']-1)*6:start+d['id']*6])==expected,d['symbol']
        for turn in (0,1):
            for move in ('QUICK_ATTACK','AQUA_JET','THUNDERCLAP','AMBUSH','TACKLE'):
                actor,target,ap,tp=init(move,turn)
                entry='CheckHigherEnemyPriority' if turn else 'CheckHigherPlayerPriority'
                for maximum in (199,200,201,65535):
                    word(tp+'MaxHP',maximum)
                    for hp in (maximum//2,maximum//2+1,maximum):
                        word(tp+'HP',hp);call(entry)
                        expected=move in ('QUICK_ATTACK','AQUA_JET','THUNDERCLAP') or (move=='AMBUSH' and hp*2<maximum)
                        assert bool(game.register_file.F&0x80)==expected,(move,turn,maximum,hp)
                        if move=='AMBUSH':
                            call('GetDamageVarsForEnemyAttack' if turn else 'GetDamageVarsForPlayerAttack')
                            assert game.register_file.D==(80 if hp*2<maximum else 50)
            # Rage: two/three full turns, one initial PP, reload accuracy, late hit boosts.
            for first_roll,length in ((0,2),(1,3)):
                actor,target,ap,tp=init('RAGE',turn);rng(first_roll);execute(turn)
                assert get(f'w{actor}BattleStatus2')&64
                assert get(f'w{actor}NumAttacksLeft')==length-1
                if not turn:assert get('wBattleMonPP')==19
                for remaining in range(length-2,-1,-1):
                    call('SequenceNewRound');put(f'w{actor}MoveAccuracy',1);rng(0);execute(turn)
                    assert get(f'w{actor}NumAttacksLeft')==remaining
                    assert get(f'w{actor}MoveAccuracy')==95*255//100
                    if not turn:assert get('wBattleMonPP')==19
                assert get(f'w{actor}BattleStatus2')&64 # active for late opponent hit
                game.memory[0xfff3]=1-turn;put('wCustomTargetHadSub',0);put('wMoveMissed',0);word('wDamage',10)
                before=get(f'w{actor}MonAttackMod');call('HandleBuildingRage');assert get(f'w{actor}MonAttackMod')==before+1
                game.memory[0xfff3]=turn;call('SequenceNewRound');assert not(get(f'w{actor}BattleStatus2')&64)
            # An interrupted locked turn still counts, but the initial blocked use does not lock.
            actor,target,ap,tp=init('RAGE',turn);put(f'w{actor}BattleStatus1',8);execute(turn);assert not(get(f'w{actor}BattleStatus2')&64)
            init('RAGE',turn);rng(0);execute(turn);call('SequenceNewRound');put(ap+'Status',64);rng(0);execute(turn)
            assert get(f'w{actor}NumAttacksLeft')==0;call('SequenceNewRound');assert not(get(f'w{actor}BattleStatus2')&64)
            actor,target,ap,tp=init('TACKLE',1-turn);put(f'w{target}BattleStatus2',64);put(f'w{target}NumAttacksLeft',2)
            for sub,miss,damage in ((0,0,10),(1,0,10),(0,1,10),(0,0,0)):
                put('wCustomTargetHadSub',sub);put('wMoveMissed',miss);word('wDamage',damage);put(f'w{target}MonAttackMod',7)
                call('HandleBuildingRage');assert get(f'w{target}MonAttackMod')==(8 if not sub and not miss and damage else 7)
            # Fixed Bide duration, accumulation, release, and reset.
            actor,target,ap,tp=init('BIDE',turn);rng(0);execute(turn)
            assert get(f'w{actor}BattleStatus1')&1 and get(f'w{actor}NumAttacksLeft')==2
            word('wDamage',10);call('PlayerBideAccum' if turn==0 else 'EnemyBideAccum')
            call('SequenceNewRound');execute(turn);assert get(f'w{actor}NumAttacksLeft')==1 and readword(tp+'HP')==200
            word('wDamage',15);call('PlayerBideAccum' if turn==0 else 'EnemyBideAccum')
            call('SequenceNewRound');execute(turn);assert not(get(f'w{actor}BattleStatus1')&1) and readword(tp+'HP')==150
            assert readword(f'w{actor}BideAccumulatedDamage')==0
            if not turn:assert get('wBattleMonPP')==19
            # Sleep can delay release, but never extends the two-turn collection window.
            actor,target,ap,tp=init('BIDE',turn);execute(turn);put(ap+'Status',3)
            call('SequenceNewRound');execute(turn);word('wDamage',10)
            call('PlayerBideAccum' if turn==0 else 'EnemyBideAccum')
            call('SequenceNewRound');word('wDamage',50);call('PlayerBideAccum' if turn==0 else 'EnemyBideAccum')
            assert readword(f'w{actor}BideAccumulatedDamage')==10
            put(ap+'Status',0);execute(turn);assert readword(tp+'HP')==180
            # Skull Bash boosts once on charge, retains boost on release/interruption.
            actor,target,ap,tp=init('SKULL_BASH',turn);execute(turn)
            assert get(f'w{actor}MonDefenseMod')==9 and get(f'w{actor}BattleStatus1')&16
            execute(turn);assert get(f'w{actor}MonDefenseMod')==9 and not(get(f'w{actor}BattleStatus1')&16)
            assert readword(tp+'HP')<200
            actor,target,ap,tp=init('SKULL_BASH',turn);execute(turn);put(f'w{actor}BattleStatus1',get(f'w{actor}BattleStatus1')|8);execute(turn)
            assert not(get(f'w{actor}BattleStatus1')&80) and get(f'w{actor}MonDefenseMod')==9
            # Fury Swipes: one accuracy gate, exactly two strikes, no bonus for immunity/invulnerability.
            actor,target,ap,tp=init('FURY_SWIPES',turn);rng(0);execute(turn)
            assert len(applied)==2 and get(f'w{actor}MonAttackMod')==7,(turn,applied)
            actor,target,ap,tp=init('FURY_SWIPES',turn);rng(255);execute(turn)
            assert len(applied)==0 and get(f'w{actor}MonAttackMod')==8
            actor,target,ap,tp=init('FURY_SWIPES',turn);game.memory[addr(tp+'Type'):addr(tp+'Type')+2]=[8,8];rng(255);execute(turn)
            assert get(f'w{actor}MonAttackMod')==7 and len(applied)==0
            actor,target,ap,tp=init('FURY_SWIPES',turn);put(f'w{target}BattleStatus1',80);rng(255);execute(turn)
            assert get(f'w{actor}MonAttackMod')==7 and len(applied)==0
            actor,target,ap,tp=init('FURY_SWIPES',turn);put(f'w{target}BattleStatus2',16);put(f'w{target}SubstituteHP',1);rng(0);execute(turn)
            assert len(applied)==2 and readword(tp+'HP')<200
            # Icicle Spear uses the existing 2..5 distribution, with no thaw effect.
            for values,count in (((0,),2),((1,),3),((2,2),4),((3,3),5)):
                actor,target,ap,tp=init('ICICLE_SPEAR',turn);rng(*values);call('TwoToFiveAttacksEffect')
                assert get(f'w{actor}NumHits')==count
            actor,target,ap,tp=init('ICICLE_SPEAR',turn);put(tp+'Status',32);rng(0);execute(turn)
            assert len(applied)==2 and get(tp+'Status')==32
            # Twister reaches/doubles against Fly, never Dig, and respects Substitute flinch blocking.
            for move,in_air,expected_power,hits in (('FLY',True,80,True),('DIG',True,40,False),('FLY',False,40,True)):
                actor,target,ap,tp=init('RAZOR_WIND',turn);put(f'w{target}MoveNum',MOVES[move]);put(f'w{target}BattleStatus1',80 if in_air else 0)
                call('GetDamageVarsForEnemyAttack' if turn else 'GetDamageVarsForPlayerAttack');assert game.register_file.D==expected_power
                rng(0);execute(turn);assert (readword(tp+'HP')<200)==hits
                assert not(get(f'w{actor}BattleStatus1')&16)
            actor,target,ap,tp=init('THUNDERCLAP',turn);put(f'w{target}BattleStatus2',16);put(f'w{target}SubstituteHP',1);rng(0);execute(turn)
            assert not(get(f'w{target}BattleStatus1')&8)
        # Learn/relearn every addition and preserve all four new IDs/PP in saves.
        patch('GetPredefRegisters',[0xc9]);bank,table=syms['EvosMovesPointerTable'];db,da=syms['PokedexOrder'];ids={}
        for addition in [x for x in PLAN['learnset_additions'] if x['species'].lower() not in TUNING]:
            name=addition['species'];level=addition['level'];move=MOVES[addition['move']]
            if name not in ids:
                pointer=addr(name+'EvosMoves')
                ids[name]=next(i+1 for i in range(190) if 1<=game.memory[db,da+i]<=151 and int.from_bytes(bytes(game.memory[bank,table+2*i:table+2*i+2]),'little')==pointer)
            index=ids[name];put('wcf91',index);put('wCurEnemyLVL',level);put('wLearningMovesFromDayCare',1);put('wDayCareStartLevel',level-1)
            game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
            call('WriteMonMoves',DE=addr('wPartyMon1Moves'));assert get('wPartyMon1Moves')==move
            assert get('wPartyMon1PP')==NEW[addition['move']]['pp']
            put('wPartyCount',1);put('wPartySpecies',index);put('wWhichPokemon',0);put('wPartyMon1Level',level)
            game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
            call('PrepareRelearnableMoveList')
            assert move in list(game.memory[addr('wMoveBuffer')+1:addr('wMoveBuffer')+1+get('wMoveBuffer')])
        values=[213,214,215,216];pps=[10,20,5,15]
        game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=values
        game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4]=pps
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2');game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
        call('LoadSAV0');call('LoadSAV2');assert not(game.register_file.F&16)
        assert list(game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4])==values
        assert list(game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4])==pps
        from test_move_patch_1 import CHARMAP
        put('wNameListType',4);put('wd0b5',202);put('wPredefBank',syms['ItemNames'][0]);call('GetName')
        encoded=bytes(CHARMAP[c] for c in 'TM02 TWISTER@')
        assert bytes(game.memory[addr('wcd6d'):addr('wcd6d')+len(encoded)])==encoded
        print(f'{version}: 216 records; priority/HP boundaries; timed Rage/PP/interruption; fixed Bide; Skull Bash; Fury miss gates/two hits; multihit Substitute; Icicle/no-thaw; Twister Fly/Dig and flinch passed')
    finally:game.stop(save=False)


if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
