#!/usr/bin/env python3
"""Exercise priority, timed Rage, fixed Bide, charge effects and multi-strike paths."""
import json
from pyboy import PyBoy
from test_unique_species import ROOT,symbols
from test_move_patch_1 import EFFECTS,TYPES
from test_move_patch_3 import MOVES

PLAN=json.loads((ROOT/'data/move_patch_7.json').read_text())
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
        call('ClearCounterRecord');call('ResidualClearAll')
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
    def endround():
        put('wResidualRoundDone',0);call('ResidualEndRound')
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
        bank,start=syms['Moves'];updates={d['id']:d['after'] for d in PLAN['existing_changes']}
        patch8=json.loads((ROOT/'data/move_patch_8.json').read_text())
        updates.update({x['id']:x['after'] for x in patch8['existing_changes']})
        entries=[updates.get(d['id'],d) for d in PLAN['baseline_moves']]+PLAN['new_moves'];assert len(entries)==219
        for d in entries:
            actual=list(game.memory[bank,start+(d['id']-1)*6:start+d['id']*6])
            assert actual==[d['id'],EFFECTS[d['effect']],d['power'],TYPES[d['type']],d['accuracy']*255//100,d['pp']],d['symbol']
        for turn in (0,1):
            actor,target,ap,tp=init('INGRAIN',turn)
            execute(turn);assert get(f'w{actor}Residual')&1
            word(ap+'HP',100);endround();assert readword(ap+'HP')==112
            call('ResidualEnemySwitchBlocked' if turn else 'ResidualPlayerSwitchBlocked');assert not(game.register_file.F&128)
            word(ap+'HP',199);endround();assert readword(ap+'HP')==200
            call('ResidualClearEnemy' if turn else 'ResidualClearPlayer');assert get(f'w{actor}Residual')==0
            # Curse has independent max-HP damage, immediate application-round tick.
            actor,target,ap,tp=init('CURSE',turn);execute(turn)
            assert get(f'w{target}Residual')&2
            endround();assert readword(tp+'HP')==175
            endround();assert readword(tp+'HP')==150
            assert readword(('wEnemyMon1' if turn==0 else 'wPartyMon1')+'HP')==150
            for kind in ('normal1','normal2','poison','seed','sub','curse','miss','fly'):
                actor,target,ap,tp=init('CURSE',turn)
                if kind.startswith('normal'):put(tp+'Type'+('1' if kind=='normal1' else '2'),0)
                if kind=='poison':put(tp+'Status',8)
                if kind=='seed':put(f'w{target}BattleStatus2',128)
                if kind=='sub':put(f'w{target}BattleStatus2',16)
                if kind=='curse':put(f'w{target}Residual',2)
                if kind=='miss':rng(255)
                if kind=='fly':put(f'w{target}BattleStatus1',64);put(f'w{target}MoveNum',MOVES['FLY'])
                execute(turn)
                assert bool(get(f'w{target}Residual')&2)==(kind=='curse'),(turn,kind)
            # Sleep, burn and paralysis may coexist with a curse.
            for status in (3,16,64):
                actor,target,ap,tp=init('CURSE',turn);put(tp+'Status',status);execute(turn);assert get(f'w{target}Residual')&2
            # Reciprocal non-stacking, through the real seed/poison handlers.
            for move in ('LEECH_SEED','TOXIC','POISONPOWDER','POISON_FANG'):
                actor,target,ap,tp=init(move,turn);put(f'w{target}Residual',2);execute(turn)
                assert get(tp+'Status')==0 and not(get(f'w{target}BattleStatus2')&128),(turn,move)
            for move in ('WILL_O_WISP','SCALD'):
                actor,target,ap,tp=init(move,turn);put(f'w{target}Residual',2);execute(turn)
                assert get(tp+'Status')==16,(turn,move,get(tp+'Status'))
            # Damaging persistent effects do not apply through Substitute or on a miss.
            for move in ('WRAP','FIRE_SPIN'):
                for kind in ('sub','miss','immune'):
                    actor,target,ap,tp=init(move,turn)
                    if kind=='sub':put(f'w{target}BattleStatus2',16);put(f'w{target}SubstituteHP',100)
                    if kind=='miss':rng(255)
                    if kind=='immune':
                        # Wrap has Ghost immunity; Fire Spin has no type immunity.
                        if move=='FIRE_SPIN':continue
                        put(tp+'Type1',8);put(tp+'Type2',8)
                    execute(turn);ptr=addr(f'w{target}Residual')
                    assert game.memory[ptr+1]==game.memory[ptr+2]==0,(move,turn,kind)
            # Fire Spin deals a single normal attack, followed by exactly 3 ticks.
            actor,target,ap,tp=init('FIRE_SPIN',turn);execute(turn);initial=readword(tp+'HP')
            assert game.memory[addr(f'w{target}Residual')+1]==3
            for i in range(1,5):
                endround();assert readword(tp+'HP')==initial-12*min(i,3),(turn,i,initial,readword(tp+'HP'))
            call('ResidualEnemySwitchBlocked' if turn==0 else 'ResidualPlayerSwitchBlocked');assert game.register_file.F&128
            # Wrap: 2–3 total hits, fixed initial damage, no action locks or refresh.
            for roll,later in ((0,1),(1,2)):
                actor,target,ap,tp=init('WRAP',turn);rng(0,roll);execute(turn)
                # Draw order can include accuracy first; set duration directly after checking range.
                ptr=addr(f'w{target}Residual');count=game.memory[ptr+2];assert count in (1,2)
                initial=readword(tp+'HP');damage=200-initial
                assert damage and game.memory[ptr+3]*256+game.memory[ptr+4]==damage
                assert not(get(f'w{actor}BattleStatus1')&32)
                assert not(get(f'w{target}BattleStatus1')&32)
                endround();assert readword(tp+'HP')==initial
                for i in range(count):endround()
                assert readword(tp+'HP')==max(0,initial-count*damage)
                assert game.memory[ptr+2]==0
            actor,target,ap,tp=init('WRAP',turn);execute(turn);ptr=addr(f'w{target}Residual')
            call('ResidualEnemySwitchBlocked' if turn==0 else 'ResidualPlayerSwitchBlocked');assert not(game.register_file.F&128)
            count=game.memory[ptr+2];execute(turn);assert game.memory[ptr+2]==count
            call('ResidualClearPlayer');assert game.memory[addr('wPlayerResidual')+2]==game.memory[addr('wEnemyResidual')+2]==0
            # A later Substitute absorbs cached ticks, without spill to real HP.
            actor,target,ap,tp=init('WRAP',turn);execute(turn);initial=readword(tp+'HP');endround()
            put(f'w{target}BattleStatus2',16);put(f'w{target}SubstituteHP',1);endround()
            assert readword(tp+'HP')==initial and not(get(f'w{target}BattleStatus2')&16)
            # Shadow Leech heals 50% or 100% of actual HP damage.
            for condition in ('none','sleep','curse'):
                actor,target,ap,tp=init('SHADOW_LEECH',turn);word(ap+'HP',50)
                if condition=='sleep':put(tp+'Status',3)
                if condition=='curse':put(f'w{target}Residual',2)
                execute(turn);damage=200-readword(tp+'HP')
                assert damage>0 and readword(ap+'HP')==50+(damage if condition!='none' else max(1,damage//2)),(turn,condition,damage,readword(ap+'HP'))
            actor,target,ap,tp=init('SHADOW_LEECH',turn);word(ap+'HP',50);word(tp+'HP',1);put(tp+'Status',3);execute(turn)
            assert readword(ap+'HP')==51 and readword(tp+'HP')==0
            actor,target,ap,tp=init('SHADOW_LEECH',turn);word(ap+'HP',50);put(f'w{target}BattleStatus2',16);put(f'w{target}SubstituteHP',100);execute(turn)
            assert readword(ap+'HP')==50
            # Fractional effects use full-width HP, floor/minimum one, cap, no revival.
            for maximum in (1,15,16,17,255,256,65535):
                actor,target,ap,tp=init('TACKLE',turn);word(ap+'MaxHP',maximum);word(ap+'HP',maximum);put(f'w{actor}Residual',2)
                endround();assert readword(ap+'HP')==maximum-max(1,maximum//8)
                word(ap+'HP',0);put(f'w{actor}Residual',1);endround();assert readword(ap+'HP')==0
            # Re-entering residual processing in a faint handler cannot tick twice.
            actor,target,ap,tp=init('TACKLE',turn);put(f'w{actor}Residual',2);endround();hp=readword(ap+'HP')
            call('ResidualEndRound');assert readword(ap+'HP')==hp
            # Persistent fields occupy audio padding, not saved data or the stack.
            assert addr('wResidualStates')==0xc0f3 and addr('wResidualRoundDone')==0xc0ff
            before=list(game.memory[0xc0f3:0xc100]);call('Audio2_StopAllAudio');assert list(game.memory[0xc0f3:0xc100])==before
        # Faint-handler paths end the round exactly once, before replacement.
        for side in ('Player','Enemy'):
            init('TACKLE',0);dead='wBattleMon' if side=='Player' else 'wEnemyMon';live='wEnemyMon' if side=='Player' else 'wBattleMon'
            word(dead+'HP',0);ptr=addr('wEnemyResidual' if side=='Player' else 'wPlayerResidual');game.memory[ptr+1]=3
            stopper='RemoveFaintedPlayerMon' if side=='Player' else 'FaintEnemyPokemon'
            patch(stopper,[0xc3,4,1]);call('Handle'+side+'MonFainted');restore(stopper)
            assert readword(live+'HP')==188 and game.memory[ptr+1]==2
            call('ResidualEndRound');assert readword(live+'HP')==188
        # A Wrap source fainting from residual damage releases the opposite trap immediately.
        init('TACKLE',0);word('wBattleMonHP',1);put('wPlayerResidual',2)
        ptr=addr('wEnemyResidual');game.memory[ptr+2:ptr+5]=[1,0,30]
        endround();assert readword('wBattleMonHP')==0 and readword('wEnemyMonHP')==200
        for move in ('INGRAIN','CURSE'):
            for blocked in (False,True):
                actor,target,ap,tp=init(move,1)
                if blocked:put('wEnemyResidual' if move=='INGRAIN' else 'wPlayerResidual',1 if move=='INGRAIN' else 2)
                call('ResidualAIStatusScore');assert get('wCustomRandomValue')==int(blocked)
        # Every added entry learns/relearns with its correct PP.
        patch('GetPredefRegisters',[0xc9])
        bank=syms['EvosMovesPointerTable'][0];start=syms['EvosMovesPointerTable'][1]
        for d in PLAN['learnset_additions']:
            pointer=syms[d['species']+'EvosMoves'][1]
            species=next(i+1 for i in range(190) if game.memory[bank,start+i*2]+256*game.memory[bank,start+i*2+1]==pointer)
            move=MOVES[d['move']];level=d['level']
            put('wcf91',species);put('wCurEnemyLVL',level);put('wLearningMovesFromDayCare',1);put('wDayCareStartLevel',level-1)
            game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
            game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4]=[0]*4
            call('WriteMonMoves',DE=addr('wPartyMon1Moves'))
            assert get('wPartyMon1Moves')==move and get('wPartyMon1PP')==10,d
            put('wPartyCount',1);put('wPartySpecies',species);put('wWhichPokemon',0);put('wPartyMon1Level',level)
            game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
            call('PrepareRelearnableMoveList');length=get('wMoveBuffer')
            assert move in list(game.memory[addr('wMoveBuffer')+1:addr('wMoveBuffer')+1+length]),d
        values=[217,218,219,165]
        game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=values
        call('LoadMovePPs',HL=addr('wPartyMon1Moves'),DE=addr('wPartyMon1PP')-1)
        pps=list(game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4]);assert pps[:3]==[10]*3
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2')
        game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
        call('LoadSAV0');call('LoadSAV2');assert not(game.register_file.F&16)
        assert list(game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4])==values
        assert list(game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4])==pps
        print(f'{version}: residual timing, reciprocal Curse gates, switch blocking, Wrap cache/Substitute, Shadow Leech and HP boundaries passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
