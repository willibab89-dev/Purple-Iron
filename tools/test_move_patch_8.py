#!/usr/bin/env python3
"""Exercise priority, timed Rage, fixed Bide, charge effects and multi-strike paths."""
import json
from pyboy import PyBoy
from test_unique_species import ROOT,symbols
from test_move_patch_1 import EFFECTS,TYPES
from test_move_patch_3 import MOVES

PLAN=json.loads((ROOT/'data/move_patch_8.json').read_text())
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
        for n in ('wEscapedFromBattle','wFlags_D733','wMoveMissed','wCriticalHitOrOHKO','wObtainedBadges','wOptions','wUnusedC000','wPlayerMonNumber','wEnemyMonPartyPos','wPlayerMoveListIndex','wCustomTargetHadSub','wActionResultOrTookBattleTurn','wPlayerDisabledMoveNumber','wEnemyDisabledMoveNumber','wPlayerDisabledMove','wEnemyDisabledMove'):
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
        for d in PLAN['baseline_moves']:
            d=updates.get(d['id'],d)
            assert list(game.memory[bank,start+(d['id']-1)*6:start+d['id']*6])==[d['id'],EFFECTS[d['effect']],d['power'],TYPES[d['type']],d['accuracy']*255//100,d['pp']]
        for turn in (0,1):
            for ditto in (76,56,159):
                for status in (0,3,8,16,32,64):
                    actor,target,ap,tp=init('TACKLE',turn);put(ap+'Species',ditto)
                    word(ap+'HP',47);word(ap+'MaxHP',123);put(ap+'Status',status)
                    game.memory[addr(ap+'DVs'):addr(ap+'DVs')+2]=[171,205]
                    game.memory[addr(tp+'DVs'):addr(tp+'DVs')+2]=[18,52]
                    game.memory[addr(tp+'Moves'):addr(tp+'Moves')+4]=[213,218,219,144]
                    game.memory[addr(tp+'Type'):addr(tp+'Type')+2]=[20,2]
                    game.memory[addr(f'w{target}MonStatMods'):addr(f'w{target}MonStatMods')+8]=[7]*8
                    for i,stat in enumerate(('Attack','Defense','Speed','Special')):
                        value=120+i*30;word(tp+stat,value)
                        word(f'w{target}MonUnmodified'+stat,value)
                    party='wEnemyMon1' if turn else 'wPartyMon1'
                    game.memory[addr(party+'Moves'):addr(party+'Moves')+4]=[144,0,0,0]
                    before=bytes(game.memory[addr(party):addr(party)+44]);selected=get(f'w{actor}SelectedMove');moveno=get(f'w{actor}MoveNum')
                    call('EntryAutoBoth')
                    assert get(f'w{actor}BattleStatus3')&8,(version,turn,ditto,status)
                    assert readword(ap+'HP')==47 and readword(ap+'MaxHP')==123 and get(ap+'Status')==status
                    assert list(game.memory[addr(ap+'Moves'):addr(ap+'Moves')+4])==[213,218,219,165]
                    assert list(game.memory[addr(ap+'PP'):addr(ap+'PP')+4])==[5]*4
                    assert list(game.memory[addr(ap+'Type'):addr(ap+'Type')+2])==[20,2]
                    assert readword(ap+'Attack')==(60 if status==16 else 120)
                    assert readword(ap+'Speed')==(45 if status==64 else 180)
                    assert get(f'w{actor}SelectedMove')==selected and get(f'w{actor}MoveNum')==moveno
                    assert bytes(game.memory[addr(party):addr(party)+44])==before
                    if turn:assert list(game.memory[addr('wTransformedEnemyMonOriginalDVs'):addr('wTransformedEnemyMonOriginalDVs')+2])==[171,205]
                    # A new opponent never re-triggers this entry.
                    put(tp+'Species',1);call('EntryAutoBoth');assert get(ap+'Species')==153
            for blocker in ('sub','fly','transformed','ditto','happy','dittwo'):
                actor,target,ap,tp=init('TACKLE',turn);put(ap+'Species',76)
                if blocker=='sub':put(f'w{target}BattleStatus2',16)
                if blocker=='fly':put(f'w{target}BattleStatus1',64)
                if blocker=='transformed':put(f'w{target}BattleStatus3',8)
                if blocker=='ditto':put(tp+'Species',76)
                if blocker=='happy':put(tp+'Species',56)
                if blocker=='dittwo':put(tp+'Species',159)
                call('EntryAutoBoth');assert not(get(f'w{actor}BattleStatus3')&8),(turn,blocker)
                assert get(f'w{actor}Residual')&8
                put(f'w{target}BattleStatus1',0);put(f'w{target}BattleStatus2',0);put(f'w{target}BattleStatus3',0);put(tp+'Species',153)
                call('EntryAutoBoth');assert not(get(f'w{actor}BattleStatus3')&8)
                call('ResidualClearEnemy' if turn else 'ResidualClearPlayer');call('EntryAutoBoth');assert get(f'w{actor}BattleStatus3')&8
            # Shared manual Transform retains original enemy DVs across re-transforms.
            actor,target,ap,tp=init('TRANSFORM',turn)
            game.memory[addr(ap+'DVs'):addr(ap+'DVs')+2]=[171,205]
            game.memory[addr(tp+'DVs'):addr(tp+'DVs')+2]=[18,52]
            call('TransformEffect_');word(tp+'DVs',0x5678);call('TransformEffect_')
            if turn:assert list(game.memory[addr('wTransformedEnemyMonOriginalDVs'):addr('wTransformedEnemyMonOriginalDVs')+2])==[171,205]
            actor,target,ap,tp=init('TRANSFORM',turn);put(f'w{target}BattleStatus1',64);call('TransformEffect_');assert not(get(f'w{actor}BattleStatus3')&8)
        # Real roster loading, resets and incoming entry hooks; only presentation is stubbed.
        for turn in (0,1):
            actor,target,ap,tp=init('TACKLE',turn);put(ap+'Species',76)
            mods=[9,5,8,6,10,3,7,7]
            game.memory[addr(f'w{target}MonStatMods'):addr(f'w{target}MonStatMods')+8]=mods
            for i,stat in enumerate(('Attack','Defense','Speed','Special')):word(f'w{target}MonUnmodified'+stat,120+i*30)
            call('EntryAutoBoth');assert game.memory[0xfff3]==turn
            assert list(game.memory[addr(f'w{actor}MonStatMods'):addr(f'w{actor}MonStatMods')+8])==mods
            assert readword(ap+'Attack')==240 and readword(ap+'Defense')==75
            assert readword(ap+'Speed')==270 and readword(ap+'Special')==138,(readword(ap+'Speed'),readword(ap+'Special'))
        for n in ('GBPalWhiteOut','GBPalNormal','ClearSprites','LoadHudTilePatterns','LoadScreenTilesFromBuffer1',
                  'RunDefaultPaletteCommand','AnimateRetreatingPlayerMon','RetreatMon','SaveScreenTilesToBuffer1',
                  'ShinyPlayerAnimation','ShinyEnemyAnimation','PlayCry','SlideTrainerPicOffScreen','PrintEmptyString',
                  'RunPaletteCommand','ClearScreenArea','LoadMonFrontSprite','AnimateSendingOutMon','LoadMonBackPic',
                  'PrintSendOutMonMessage','DoPlayerShinybit','DoEnemyShinybit'):
            if n in syms:patch(n,[0xc9])
        def roster(turn,count=3):
            actor,target,ap,tp=init('ROAR',turn)
            party='wPartyMon1' if turn else 'wEnemyMon1'
            stride=addr('wPartyMon2')-addr('wPartyMon1')
            put('wPartyCount' if turn else 'wEnemyPartyCount',count)
            specieslist='wPartySpecies' if turn else 'wEnemyPartyMons'
            for i in range(count):
                base=addr(party)+i*stride
                game.memory[base:base+stride]=[0]*stride
                game.memory[base]=153
                game.memory[base+1:base+3]=[0,100]
                game.memory[base+addr('wPartyMon1Level')-addr('wPartyMon1')]=30
                game.memory[addr(specieslist)+i]=153
                for stat in ('MaxHP','Attack','Defense','Speed','Special'):
                    off=addr('wPartyMon1'+stat)-addr('wPartyMon1');game.memory[base+off:base+off+2]=[0,100]
                off=addr('wPartyMon1Moves')-addr('wPartyMon1');game.memory[base+off:base+off+4]=[33,0,0,0]
                off=addr('wPartyMon1PP')-addr('wPartyMon1');game.memory[base+off:base+off+4]=[35,0,0,0]
            put('wBattleMonSpecies2',153);put('wFirstMonsNotOutYet',0)
            return actor,target,ap,tp,party,stride
        for turn in (0,1):
            for move in ('ROAR','WHIRLWIND'):
                actor,target,ap,tp,party,stride=roster(turn)
                put(f'w{actor}SelectedMove',MOVES[move]);call('GetCurrentMove');rng(0)
                # Rooted/cursed/trapped targets are forcefully replaced and cleared.
                put(f'w{target}Residual',3);game.memory[addr(f'w{target}Residual')+1:addr(f'w{target}Residual')+5]=[3,2,0,20]
                call('EntryTryPhaze')
                assert get('wPlayerMonNumber' if turn else 'wEnemyMonPartyPos')==1,(version,turn,move)
                assert get(f'w{target}SelectedMove')==255
                assert get(f'w{target}Residual')&7==0
                assert get('wEscapedFromBattle')==0
                assert game.memory[addr(party)+1:addr(party)+3]==[0,200]
            for blocker in ('alone','dead','sub','fly','miss','link'):
                actor,target,ap,tp,party,stride=roster(turn,1 if blocker=='alone' else 2)
                if blocker=='dead':game.memory[addr(party)+stride+1:addr(party)+stride+3]=[0,0]
                if blocker=='sub':put(f'w{target}BattleStatus2',16)
                if blocker=='fly':put(f'w{target}BattleStatus1',64)
                if blocker=='miss':
                    put(f'w{actor}SelectedMove',MOVES['WHIRLWIND']);call('GetCurrentMove');rng(255)
                if blocker=='link':put('wLinkState',4)
                call('EntryTryPhaze');assert get('wPlayerMonNumber' if turn else 'wEnemyMonPartyPos')==0,(turn,blocker)
        # Public execution spends the actor's turn/PP and skips the forced-in
        # target's pending action, without reporting a knockout or ending battle.
        for turn in (0,1):
            actor,target,ap,tp,party,stride=roster(turn,2);rng(0);execute(turn)
            assert game.register_file.B==1 and get(f'w{target}SelectedMove')==255
            if turn==0:assert get('wPartyMon1PP')==19
            before=readword(ap+'HP');game.memory[0xfff3]=1-turn;execute(1-turn)
            assert readword(ap+'HP')==before and game.register_file.B==1
        for turn in (0,1):
            actor,target,ap,tp=init('ROAR',turn);put('wIsInBattle',1);put('wCurEnemyLVL',50)
            execute(turn);assert get('wEscapedFromBattle')==1
            actor,target,ap,tp=init('TELEPORT',turn);execute(turn);assert get('wEscapedFromBattle')==0
        actor,target,ap,tp=init('TRANSFORM',0);execute(0)
        assert get('wPartyMon1PP')==19 and get('wPlayerBattleStatus3')&8
        # Incoming Ditto transforms during the actual forced replacement path.
        for turn in (0,1):
            actor,target,ap,tp,party,stride=roster(turn,2)
            game.memory[addr(party)+stride]=76
            game.memory[addr('wPartySpecies' if turn else 'wEnemyPartyMons')+1]=76
            call('EntryTryPhaze')
            assert get(f'w{target}BattleStatus3')&8 and get(tp+'Species')==get(ap+'Species')
            assert get(f'w{target}SelectedMove')==255
        # The catch-data reconstruction used by successful ball captures restores
        # the original Ditto identity and its pre-transform DVs.
        for ditto in (76,56,159):
            actor,target,ap,tp=init('TACKLE',1);put('wIsInBattle',1);put(ap+'Species',ditto);put('wEnemyMonSpecies2',ditto)
            game.memory[addr(ap+'DVs'):addr(ap+'DVs')+2]=[171,205]
            game.memory[addr(tp+'DVs'):addr(tp+'DVs')+2]=[18,52]
            call('EntryAutoBoth');assert get('wEnemyBattleStatus3')&8
            put('wCurEnemyLVL',50);call('LoadEnemyMonData')
            assert get('wEnemyMonSpecies')==ditto
            assert list(game.memory[addr('wEnemyMonDVs'):addr('wEnemyMonDVs')+2])==[171,205]
        for count,useless in ((1,1),(2,0)):
            roster(1,count);put('wEnemyMoveNum',MOVES['ROAR']);call('EntryAIPhazeScore');assert get('wCustomRandomValue')==useless
        # Uniform ordinal selection covers only healthy inactive slots.
        roster(1,4);put('wCustomSide',0)
        game.memory[addr('wPartyMon1HP')+stride:addr('wPartyMon1HP')+stride+2]=[0,0]
        call('EntryCountReserves');assert get('wCustomChanged')==2
        for roll,slot in ((0,2),(1,3)):
            rng(7,roll);call('EntryChooseReserve');assert get('wResidualSavedEffect')==slot
        print(f'{version}: automatic entry gates, original HP/status/party/PP, conditional penalties, five-PP copies, capture DVs, real forced replacements, reserve selection and phazing AI passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
