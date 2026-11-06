#!/usr/bin/env python3
"""Exercise utility/status rules, actual Counter records, learning and save compatibility."""
import json
from pyboy import PyBoy
from test_unique_species import ROOT,symbols
from test_move_patch_1 import EFFECTS,TYPES
from test_move_patch_3 import MOVES

PLAN=json.loads((ROOT/'data/move_patch_5.json').read_text())
NEW={x['symbol']:x for x in PLAN['new_moves']}
DROPS={'TONGUE_LASH':3,'LUNGE':0,'SHELL_BREAK':1,'WAILING_CRY':3,'ROCK_TOMB':2,'ICY_WIND':2}
BOOSTS={'STOCKPILE':(1,3),'BULK_UP':(0,1),'CHARGE':(3,4),'DRAGON_DANCE':(0,2),'COIL':(0,1,4)}


def validate(version):
    syms=symbols(ROOT/(version+'.sym'));game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return syms[n][1]
    def put(n,v):game.memory[addr(n)]=v
    def get(n):return game.memory[addr(n)]
    def word(n,v):game.memory[addr(n):addr(n)+2]=[v>>8,v&255]
    def readword(n):return get(n)*256+game.memory[addr(n)+1]
    saved={};rng_state={'values':[0],'index':0}
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
        raise AssertionError((version,n,hex(game.register_file.PC),game.memory[0xffb8]))
    def rng(*values):rng_state.update(values=list(values),index=0)
    def on_rng(state):
        i=state['index'];game.register_file.A=state['values'][min(i,len(state['values'])-1)];state['index']+=1
    def mods(side):return list(game.memory[addr(f'w{side}MonStatMods'):addr(f'w{side}MonStatMods')+6])
    def init(move,turn=0):
        game.memory[0xfff3]=turn
        for n in ('wFlags_D733','wMoveMissed','wCriticalHitOrOHKO','wObtainedBadges','wOptions','wUnusedC000','wPlayerMonNumber','wEnemyMonPartyPos','wPlayerMoveListIndex','wCustomTargetHadSub'):
            put(n,0)
        put('wIsInBattle',2);put('wLinkState',4)
        call('ClearCounterRecord')
        for side,prefix,party in (('Player','wBattleMon','wPartyMon1'),('Enemy','wEnemyMon','wEnemyMon1')):
            for i in (1,2,3):put(f'w{side}BattleStatus{i}',0)
            put(f'w{side}ToxicCounter',0)
            game.memory[addr(f'w{side}MonStatMods'):addr(f'w{side}MonStatMods')+6]=[7]*6
            for i,stat in enumerate(('Attack','Defense','Speed','Special')):
                word(prefix+stat,100);word(party+stat,100)
                game.memory[addr(f'w{side}MonUnmodifiedAttack')+i*2:addr(f'w{side}MonUnmodifiedAttack')+i*2+2]=[0,100]
            word(prefix+'HP',200);word(prefix+'MaxHP',200);put(prefix+'Status',0);put(prefix+'Level',50);put(prefix+'Species',153)
            word(party+'HP',200);put(party+'Status',0)
            game.memory[addr(prefix+'Type'):addr(prefix+'Type')+2]=[22,22]
        actor='Enemy' if turn else 'Player';target='Player' if turn else 'Enemy'
        put(f'w{actor}SelectedMove',MOVES[move]);call('GetCurrentMove');rng(0)
        return actor,target,('wEnemyMon' if turn else 'wBattleMon'),('wBattleMon' if turn else 'wEnemyMon')
    def effect():call('JumpMoveEffect')
    try:
        for n in ('PrintText','PrintButItFailedText_','PlayCurrentMoveAnimation','PlayCurrentMoveAnimation2','DelayFrames',
                  'DrawHUDsAndHPBars','DrawPlayerHUDAndHPBar','DrawEnemyHUDAndHPBar','UpdateHPBar2'):
            patch(n,[0xc9])
        patch('BattleRandom',[0xc9]);b,a=syms['BattleRandom'];game.hook_register(b,a,on_rng,rng_state)
        # All 212 data records are exactly the approved cumulative delta.
        b,start=syms['Moves'];updates={x['id']:x['after'] for x in PLAN['existing_changes']}
        patch6=json.loads((ROOT/'data/move_patch_6.json').read_text())
        updates.update({x['id']:x['after'] for x in patch6['existing_changes']})
        patch7=json.loads((ROOT/'data/move_patch_7.json').read_text())
        updates.update({x['id']:x['after'] for x in patch7['existing_changes']})
        entries=[updates.get(x['id'],x) for x in PLAN['baseline_moves']]+PLAN['new_moves'];assert len(entries)==212
        for d in entries:
            expected=[d['id'],EFFECTS[d['effect']],d['power'],TYPES[d['type']],d['accuracy']*255//100,d['pp']]
            assert list(game.memory[b,start+(d['id']-1)*6:start+d['id']*6])==expected,d['symbol']
        for turn in (0,1):
            for move,stat in DROPS.items():
                actor,target,ap,tp=init(move,turn);effect();expected=[7]*6;expected[stat]=6
                assert mods(target)==expected,(move,turn,mods(target))
                for blocked in ('sub','mist','miss','ko'):
                    init(move,turn)
                    if blocked=='sub':put('wCustomTargetHadSub',1)
                    if blocked=='mist':put(f'w{target}BattleStatus2',2)
                    if blocked=='miss':put('wMoveMissed',1)
                    if blocked=='ko':word(tp+'HP',0)
                    effect();assert mods(target)==[7]*6,(move,blocked)
            for move,stats in BOOSTS.items():
                actor,target,ap,tp=init(move,turn);effect();expected=[7]*6
                for stat in stats:expected[stat]=8
                assert mods(actor)==expected,(move,mods(actor))
                init(move,turn);game.memory[addr(f'w{actor}MonStatMods')+stats[0]]=13;effect()
                assert mods(actor)[stats[-1]]==8
            for move,stat in (('MIND_BREAK',3),('GALE_WIND',5)):
                for stage,expected in ((13,7),(8,7),(7,7),(3,3)):
                    actor,target,ap,tp=init(move,turn);game.memory[addr(f'w{target}MonStatMods')+stat]=stage
                    put(f'w{target}BattleStatus2',2);effect() # positive resets ignore Mist
                    assert mods(target)[stat]==expected,(move,stage,mods(target))
                init(move,turn);game.memory[addr(f'w{target}MonStatMods')+stat]=13;put('wCustomTargetHadSub',1);effect();assert mods(target)[stat]==13
            for move in ('EGG_BOMB','BRICK_BREAK'):
                actor,target,ap,tp=init(move,turn);put(f'w{target}BattleStatus3',0x3f);effect()
                assert get(f'w{target}BattleStatus3')==0x39
                for blocked in ('sub','miss','ko'):
                    init(move,turn);put(f'w{target}BattleStatus3',6)
                    if blocked=='sub':put('wCustomTargetHadSub',1)
                    if blocked=='miss':put('wMoveMissed',1)
                    if blocked=='ko':word(tp+'HP',0)
                    effect();assert get(f'w{target}BattleStatus3')==6
                init(move,turn);put(f'w{target}BattleStatus3',6)
                call('GetDamageVarsForEnemyAttack' if turn else 'GetDamageVarsForPlayerAttack');assert game.register_file.C==100
                put(f'w{target}BattleStatus2',16)
                call('GetDamageVarsForEnemyAttack' if turn else 'GetDamageVarsForPlayerAttack');assert game.register_file.C==200
            # One global chance gate; status type is independent of move typing.
            for choice,mask in ((0,16),(1,32),(2,64)):
                actor,target,ap,tp=init('TRI_ATTACK',turn);rng(0,choice);effect()
                assert get(tp+'Status')==mask,('Tri',turn,choice,get(tp+'Status'))
                party='wPartyMon1' if target=='Player' else 'wEnemyMon1'
                assert get(party+'Status')==mask
                if mask==16:assert readword(tp+'Attack')==50
                if mask==64:assert readword(tp+'Speed')==25
                assert rng_state['index']==2
            for move,threshold,mask in (('TRI_ATTACK',51,16),('SCALD',77,16),('POISON_FANG',51,8)):
                for roll in range(256):
                    actor,target,ap,tp=init(move,turn);rng(roll,0);effect()
                    assert get(tp+'Status')==(mask if roll<threshold else 0),(move,roll,get(tp+'Status'))
            for choice,immune in ((0,20),(1,25),(2,23)):
                actor,target,ap,tp=init('TRI_ATTACK',turn);game.memory[addr(tp+'Type')+1]=immune;rng(0,choice,2);effect()
                assert get(tp+'Status')==0 and rng_state['index']==2
            actor,target,ap,tp=init('TRI_ATTACK',turn);rng(0,255,2);effect();assert get(tp+'Status')==64 and rng_state['index']==3
            actor,target,ap,tp=init('POISON_FANG',turn);put(tp+'Status',8);effect()
            assert get(f'w{target}BattleStatus3')&1 and get(f'w{target}ToxicCounter')==0
            put(f'w{target}ToxicCounter',5);effect();assert get(f'w{target}ToxicCounter')==5
            for status in (1,16,32,64):
                actor,target,ap,tp=init('POISON_FANG',turn);put(tp+'Status',status);effect();assert get(tp+'Status')==status and not(get(f'w{target}BattleStatus3')&1)
            for move,mask,immune in (('WILL_O_WISP',16,20),('FLASH_FREEZE',32,25)):
                actor,target,ap,tp=init(move,turn);effect();assert get(tp+'Status')==mask
                for blocked in ('sub','invulnerable','major','immune','miss'):
                    init(move,turn)
                    if blocked=='sub':put(f'w{target}BattleStatus2',16)
                    if blocked=='invulnerable':put(f'w{target}BattleStatus1',64)
                    if blocked=='major':put(tp+'Status',8)
                    if blocked=='immune':game.memory[addr(tp+'Type')]=immune
                    if blocked=='miss':rng(255)
                    effect();assert get(tp+'Status')==(8 if blocked=='major' else 0),(move,blocked,get(tp+'Status'))
            # Cauterize restores exact staged stats and clears only major conditions.
            for status in (0,1,8,16,32,64):
                actor,target,ap,tp=init('CAUTERIZE',turn);word(ap+'HP',100);put(ap+'Status',status)
                game.memory[addr(f'w{actor}MonStatMods'):addr(f'w{actor}MonStatMods')+6]=[8,6,5,10,9,4]
                put(f'w{actor}BattleStatus1',128);put(f'w{actor}BattleStatus2',0x84);put(f'w{actor}BattleStatus3',0x37);put(f'w{actor}ToxicCounter',6)
                effect();assert get(ap+'Status')==0 and readword(ap+'HP')==150
                assert get(f'w{actor}BattleStatus1')==128 and get(f'w{actor}BattleStatus2')==0x84
                assert get(f'w{actor}BattleStatus3')==0x36 and get(f'w{actor}ToxicCounter')==0
                assert [readword(ap+x) for x in ('Attack','Defense','Speed','Special')]==[150,66,50,250]
                party='wEnemyMon1' if turn else 'wPartyMon1';assert get(party+'Status')==0 and readword(party+'HP')==150
            for maximum,hp,expected in ((199,100,149),(255,1,64),(511,1,128),(1,1,1),(65535,65530,65535),(200,200,200)):
                actor,target,ap,tp=init('CAUTERIZE',turn);word(ap+'HP',hp);word(ap+'MaxHP',maximum);effect();assert readword(ap+'HP')==expected,(maximum,hp,readword(ap+'HP'))
            actor,target,ap,tp=init('PSYCH_UP',turn)
            stages=[9,5,7,11,3,13];game.memory[addr(f'w{target}MonStatMods'):addr(f'w{target}MonStatMods')+6]=stages
            put(f'w{target}BattleStatus2',18);put(ap+'Status',16);effect();assert mods(actor)==stages and readword(ap+'Attack')==100
            init('PSYCH_UP',turn);put(f'w{target}BattleStatus1',64);game.memory[addr(f'w{target}MonStatMods')]=13;effect();assert mods(actor)==[7]*6
            for condition in ('normal','ko','sub','miss'):
                actor,target,ap,tp=init('FLAME_CHARGE',turn)
                if condition=='ko':word(tp+'HP',0)
                if condition=='sub':put('wCustomTargetHadSub',1)
                if condition=='miss':put('wMoveMissed',1)
                effect();assert mods(actor)[2]==(7 if condition=='miss' else 8)
            # Counter reflects received physical HP damage, never shared wDamage.
            actor,target,ap,tp=init('COUNTER',turn);word('wDamage',999);call('HandleCounterMove');assert get('wMoveMissed')==1
            for incoming_type in (0,1,2,3,4,5,6,7,8,20,21,22,23,24,25,26):
                init('TACKLE',1-turn);put(f'w{target}MoveType',incoming_type);word('wDamage',37)
                call('RecordCounterHit')
                game.memory[0xfff3]=turn;put(f'w{actor}SelectedMove',MOVES['COUNTER']);call('GetCurrentMove');rng(0)
                call('HandleCounterMove')
                assert get('wMoveMissed')==(0 if incoming_type<20 else 1),('Counter type',turn,incoming_type)
                assert readword('wDamage')==(74 if incoming_type<20 else 0)
            init('COUNTER',turn);put('wCounterRecipient',turn);word('wCounterDamage',37)
            for immune in (8,):
                game.memory[addr(tp+'Type')]=immune;call('HandleCounterMove');assert get('wMoveMissed')==1
            init('COUNTER',turn);put('wCounterRecipient',turn);word('wCounterDamage',40000);call('HandleCounterMove');assert readword('wDamage')==65535
            call('ClearCounterRecord');assert readword('wCounterDamage')==0 and get('wCounterRecipient')==255
            # Psywave keeps Shin's positive random range; level one now terminates.
            actor,target,ap,tp=init('PSYWAVE',turn);put(ap+'Level',1);rng(1)
            call('ApplyAttackToPlayerPokemon' if turn else 'ApplyAttackToEnemyPokemon');assert readword(tp+'HP')==199
        # Actual move execution, including independent Counter bookkeeping.
        for n in ('PrintMonName1Text','PlayMoveAnimation','PrintCriticalOHKOText','DisplayEffectiveness',
                  'CriticalHitTest','RandomizeDamage','Delay3','Func_78e98','MoveAnimation',
                  'HideSubstituteShowMonAnim','ReshowSubstituteAnim'):
            patch(n,[0xc9])
        for turn in (0,1):
            for move in NEW:
                actor,target,ap,tp=init(move,turn);rng(0)
                if move=='CAUTERIZE':word(ap+'HP',100);put(ap+'Status',16)
                if move=='PSYCH_UP':put(f'w{target}MonAttackMod',9)
                if move=='MIND_BREAK':put(f'w{target}MonSpecialMod',13)
                if move=='GALE_WIND':put(f'w{target}MonEvasionMod',13);rng(0)
                put(f'w{target}MoveNum',1);put(f'w{target}MoveEffect',0);put(f'w{target}MovePower',40)
                put('wBattleMonPP',NEW[move]['pp']);put('wPartyMon1PP',NEW[move]['pp'])
                call('EnemyCanExecuteMove' if turn else 'PlayerCanExecuteMove')
                if NEW[move]['power']:assert readword(tp+'HP')<200,('pipeline',move,turn,readword(tp+'HP'))
                if not turn:
                    assert get('wBattleMonPP')==NEW[move]['pp']-1
                    assert get('wPartyMon1PP')==NEW[move]['pp']-1
            # Counter only sees real incoming physical HP damage from this turn.
            for incoming in ('ROCK_THROW','WATER_GUN','SEISMIC_TOSS','PSYSHOCK'):
                attacker,defender,attp,defp=init(incoming,1-turn);rng(0)
                call('PlayerCanExecuteMove' if turn else 'EnemyCanExecuteMove')
                received=200-readword(defp+'HP');assert received>0
                eligible=incoming in ('ROCK_THROW','SEISMIC_TOSS')
                assert readword('wCounterDamage')==(received if eligible else 0),(incoming,received,readword('wCounterDamage'))
                game.memory[0xfff3]=turn;put(f'w{defender}SelectedMove',MOVES['COUNTER']);call('GetCurrentMove');put('wMoveMissed',0)
                put('wBattleMonPP',20);put('wPartyMon1PP',20)
                call('EnemyCanExecuteMove' if turn else 'PlayerCanExecuteMove')
                assert readword(attp+'HP')==200-(received*2 if eligible else 0),(incoming,turn,readword(attp+'HP'),received)
            attacker,defender,attp,defp=init('ROCK_THROW',1-turn);put(f'w{defender}BattleStatus2',16);put(f'w{defender}SubstituteHP',1);rng(0)
            call('PlayerCanExecuteMove' if turn else 'EnemyCanExecuteMove');assert readword('wCounterDamage')==0
            attacker,defender,attp,defp=init('ROCK_THROW',1-turn);word(defp+'HP',5);rng(0)
            call('PlayerCanExecuteMove' if turn else 'EnemyCanExecuteMove');assert readword('wCounterDamage')==5
            actor,target,ap,tp=init('FLAME_CHARGE',turn);put(f'w{target}BattleStatus2',16);put(f'w{target}SubstituteHP',1);rng(0)
            call('EnemyCanExecuteMove' if turn else 'PlayerCanExecuteMove');assert mods(actor)[2]==8
        # Full-health Cauterize is intentionally legal and spends PP.
        actor,target,ap,tp=init('CAUTERIZE',0);put('wBattleMonPP',10);put('wPartyMon1PP',10);rng(0)
        call('PlayerCanExecuteMove');assert readword(ap+'HP')==200 and get(ap+'Status')==0
        assert get('wBattleMonPP')==9 and get('wPartyMon1PP')==9
        # No trainer-party writes when the affected opponent is wild.
        actor,target,ap,tp=init('WILL_O_WISP',0);put('wIsInBattle',1);put('wEnemyMon1Status',0x55);effect()
        assert get(tp+'Status')==16 and get('wEnemyMon1Status')==0x55
        actor,target,ap,tp=init('POISON_FANG',0);game.memory[addr(tp+'Type')+1]=3;effect()
        assert get(tp+'Status')==0
        actor,target,ap,tp=init('SCALD',0);put(tp+'Status',32);effect();assert get(tp+'Status')==32
        # Every new learning entry, its PP, and high-ID party save/load.
        patch('GetPredefRegisters',[0xc9]);b,table=syms['EvosMovesPointerTable'];db,da=syms['PokedexOrder'];ids={}
        for addition in PLAN['learnset_additions']:
            species=addition['species'];level=addition['level'];move=MOVES[addition['move']]
            if species not in ids:
                pointer=addr(species+'EvosMoves')
                ids[species]=next(i+1 for i in range(190) if 1<=game.memory[db,da+i]<=151 and int.from_bytes(bytes(game.memory[b,table+2*i:table+2*i+2]),'little')==pointer)
            index=ids[species]
            put('wcf91',index);put('wCurEnemyLVL',level);put('wLearningMovesFromDayCare',1);put('wDayCareStartLevel',level-1)
            game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
            call('WriteMonMoves',DE=addr('wPartyMon1Moves'));assert get('wPartyMon1Moves')==move
            assert get('wPartyMon1PP')==NEW[addition['move']]['pp']
            put('wPartyCount',1);put('wPartySpecies',index);put('wWhichPokemon',0);put('wPartyMon1Level',level)
            game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
            call('PrepareRelearnableMoveList')
            assert move in list(game.memory[addr('wMoveBuffer')+1:addr('wMoveBuffer')+1+get('wMoveBuffer')]),addition
        values=[192,196,204,212];pps=[15,15,10,10]
        game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=values
        game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4]=pps
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2');game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
        call('LoadSAV0');call('LoadSAV2');assert not(game.register_file.F&16)
        assert list(game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4])==values
        assert list(game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4])==pps
        # Utility AI rejects wholly useless actions, including full-health cures.
        for move in ('CAUTERIZE','COIL','PSYCH_UP','WILL_O_WISP','FLASH_FREEZE'):
            actor,target,ap,tp=init(move,1)
            if move=='COIL':game.memory[addr('wEnemyMonStatMods'):addr('wEnemyMonStatMods')+6]=[13]*6
            if move in ('WILL_O_WISP','FLASH_FREEZE'):put(tp+'Status',8)
            call('UtilityAIStatusScore');assert get('wCustomRandomValue')==1,move
        print(f'{version}: 212 records; drops/boosts/resets/screens; exhaustive status chance gates; poison upgrade; Cauterize/Psych Up; physical Counter records and Psywave level-one range passed')
    finally:game.stop(save=False)


if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
