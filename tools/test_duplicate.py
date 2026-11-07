#!/usr/bin/env python3
"""Exercise Duplicate copying, Dittwo entry behavior and restoration on both battle sides."""
from pyboy import PyBoy
from test_unique_species import ROOT,symbols
from test_move_patch_3 import MOVES

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
        assert MOVES['DUPLICATE']==233
        patch('MoveSelectionMenu',[0x3e,2,0xea,addr('wCurrentMenuItem')&255,addr('wCurrentMenuItem')>>8,0xc9])
        patch('LoadScreenTilesFromBuffer1',[0xc9])
        for turn in (0,1):
            actor,target,ap,tp=init('DUPLICATE',turn);put(ap+'Species',159);put(f'w{actor}MoveListIndex',0)
            game.memory[addr(ap+'Moves'):addr(ap+'Moves')+4]=[233,3,4,5]
            game.memory[addr(tp+'Moves'):addr(tp+'Moves')+4]=[MOVES['TACKLE'],MOVES['FLAMETHROWER'],MOVES['ICE_BEAM'],0]
            party='wEnemyMon1' if turn else 'wPartyMon1'
            game.memory[addr(party+'Moves'):addr(party+'Moves')+4]=[233,3,4,5]
            put(ap+'PP',10);put(party+'PP',10)
            identity=(get(ap+'Species'),readword(ap+'HP'),readword(ap+'MaxHP'),readword(ap+'Type'),readword(ap+'Attack'))
            before=bytes(game.memory[addr(party+'Moves'):addr(party+'Moves')+4])
            call('EntryAutoBoth');assert not(get(f'w{actor}BattleStatus3')&8) and get(ap+'Species')==159
            rng(0);execute(turn)
            expected=MOVES['TACKLE'] if turn else MOVES['ICE_BEAM']
            assert get(ap+'Moves')==expected,(turn,get(ap+'Moves'))
            assert bytes(game.memory[addr(party+'Moves'):addr(party+'Moves')+4])==before
            assert get(ap+'Species')==159 and readword(ap+'HP')==identity[1] and readword(ap+'MaxHP')==identity[2]
            assert readword(ap+'Type')==identity[3]
            assert readword(ap+'Attack')==identity[4] and not(get(f'w{actor}BattleStatus3')&8)
            if not turn:
                assert get('wBattleMonPP')==9 and get('wPartyMon1PP')==9
                put('wWhichPokemon',0);put('wBattleMonSpecies2',159);call('LoadBattleMonFromParty')
                assert get('wBattleMonMoves')==233 and get('wBattleMonPP')==9
            # A failed copy leaves the original move intact.
            actor,target,ap,tp=init('DUPLICATE',turn);put(ap+'Moves',233);put(f'w{actor}MoveListIndex',0)
            put(f'w{target}BattleStatus1',64);put(f'w{target}MoveNum',MOVES['FLY']);rng(0);execute(turn)
            assert get(ap+'Moves')==233
            # Ditto can now copy Dittwo; Dittwo itself never auto-transforms.
            actor,target,ap,tp=init('TACKLE',turn);put(ap+'Species',76);put(tp+'Species',159)
            game.memory[addr(tp+'Moves'):addr(tp+'Moves')+4]=[233,3,4,5]
            call('EntryAutoBoth');assert get(f'w{actor}BattleStatus3')&8 and get(ap+'Species')==159
            assert not(get(f'w{target}BattleStatus3')&8)
        # Test actual damage effectiveness for the approved new typings.
        for turn in (0,1):
            for types,checks in [([26,26],[(25,200),(26,200),(4,100),(5,100),(23,50)]),([5,26],[(25,200),(1,200),(4,200),(26,200),(21,100),(22,100),(23,50)]),([5,4],[(21,400),(22,400),(23,0)])]:
                for attack,expected in checks:
                    actor,target,ap,tp=init('TACKLE',turn)
                    game.memory[addr(ap+'Type'):addr(ap+'Type')+2]=[0,0]
                    game.memory[addr(tp+'Type'):addr(tp+'Type')+2]=types
                    put(f'w{actor}MoveType',attack);put('wDamageMultipliers',10);word('wDamage',100)
                    call('AdjustDamageForMoveType');assert readword('wDamage')==expected,(turn,types,attack,readword('wDamage'))
        put('wPartyMon1Moves',233);put('wPartyMon1PP',10)
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2');put('wPartyMon1Moves',0);put('wPartyMon1PP',0)
        call('LoadSAV0');call('LoadSAV2');assert get('wPartyMon1Moves')==233 and get('wPartyMon1PP')==10
        print(f'{version}: player choice/enemy random Duplicate; identity/party preservation, PP, switch restoration, failure, entry exclusion, Ditto copying Dittwo and saves passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for name in ('pokered','pokeblue'):validate(name)
