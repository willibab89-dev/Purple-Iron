#!/usr/bin/env python3
"""Exercise Wake-Up Slap power, actual hit/wake gates, party sync and saves."""
from pyboy import PyBoy
from test_unique_species import ROOT,symbols
from test_move_patch_1 import EFFECTS
from test_move_patch_3 import MOVES

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
        for n in ('GetMonHeader','PrintText','PrintButItFailedText_','DelayFrames','PrintMonName1Text',
                  'PlayMoveAnimation','PrintCriticalOHKOText','DisplayEffectiveness','CriticalHitTest',
                  'RandomizeDamage','Delay3','Func_78e98','MoveAnimation','DrawPlayerHUDAndHPBar',
                  'DrawEnemyHUDAndHPBar','DrawHUDsAndHPBars','UpdateHPBar2',
                  'HideSubstituteShowMonAnim','ReshowSubstituteAnim'):
            patch(n,[0xc9])
        assert MOVES['WAKE_UP_SLAP']==221 and MOVES['STRUGGLE']==165
        cases=0
        for turn in (0,1):
            for status in (0,1,2,3,4,5,6,7,8,16,32,64):
                actor,target,ap,tp=init('WAKE_UP_SLAP',turn);put(tp+'Status',status)
                assert variables(turn)[2]==(120 if status&7 else 60),(turn,status,output())
                assert get(f'w{actor}MovePower')==60
                # Direct public effect dispatcher with actual HP-damage evidence.
                word('wDamage',10);put('wCustomTargetHadSub',0)
                party='wPartyMon1' if turn else 'wEnemyMon1'
                put(party+'Status',status);call('JumpMoveEffect')
                assert get(tp+'Status')==(status&0xf8 if status&7 else status)
                assert get(party+'Status')==(status&0xf8 if status&7 else status)
                cases+=1
            for gate in ('miss','sub','zero'):
                actor,target,ap,tp=init('WAKE_UP_SLAP',turn);put(tp+'Status',3);word('wDamage',10)
                if gate=='miss':put('wMoveMissed',1)
                if gate=='sub':put('wCustomTargetHadSub',1)
                if gate=='zero':word('wDamage',0)
                call('JumpMoveEffect');assert get(tp+'Status')==3,(turn,gate)
                cases+=1
            # Complete public attack pipeline: presentation and random crit/
            # damage variance are stubbed; hit tests, typing, Substitute,
            # damage, waking, PP and party status synchronization are real.
            for condition in ('sleep','awake','poison','miss','ghost','fly','sub','break_sub','ko'):
                actor,target,ap,tp=init('WAKE_UP_SLAP',turn)
                patch('BattleRandom',[0x3e,255 if condition=='miss' else 0,0xc9])
                status=0 if condition=='awake' else 8 if condition=='poison' else 3
                put(tp+'Status',status)
                party='wPartyMon1' if turn else 'wEnemyMon1';put(party+'Status',status)
                if condition=='miss':put(f'w{actor}MonAccuracyMod',1)
                if condition=='ghost':game.memory[addr(tp+'Type'):addr(tp+'Type')+2]=[8,8]
                if condition=='fly':put(f'w{target}BattleStatus1',64)
                if condition in ('sub','break_sub'):
                    put(f'w{target}BattleStatus2',16)
                    put(f'w{target}SubstituteHP',1 if condition=='break_sub' else 200)
                if condition=='ko':word(tp+'HP',1)
                put(f'w{target}MoveNum',1);put(f'w{target}MoveEffect',0);put(f'w{target}MovePower',40)
                put(ap+'PP',15);put('wPartyMon1PP',15)
                before=readword(tp+'HP')
                call('EnemyCanExecuteMove' if turn else 'PlayerCanExecuteMove')
                blocked=condition in ('miss','ghost','fly','sub','break_sub')
                assert (readword(tp+'HP')==before)==blocked,(version,turn,condition,readword(tp+'HP'),before)
                expected=status if blocked or status&7==0 else 0
                assert get(tp+'Status')==expected,(version,turn,condition,get(tp+'Status'))
                if status&7 and not blocked:assert get(party+'Status')==0,(turn,condition)
                if condition=='break_sub':assert not(get(f'w{target}BattleStatus2')&16)
                if not turn:assert get('wBattleMonPP')==14 and get('wPartyMon1PP')==14
                cases+=1
        restore('GetMonHeader')
        # Generated Wigglytuff has the high move ID and correct PP. SRAM keeps
        # the move and PP-Up bits without changing the existing save layout.
        put('wPartyCount',0);put('wMonDataLocation',0x80);put('wIsInBattle',0);put('wCurEnemyLVL',60)
        b,a=syms['PokedexOrder'];order=list(game.memory[b,a:a+190]);put('wcf91',order.index(40)+1)
        call('AddPartyMon');moves=list(game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]);slot=moves.index(221)
        assert game.memory[addr('wPartyMon1PP')+slot]==15
        game.memory[addr('wPartyMon1PP')+slot]=0xd8
        put('wNumBagItems',0);put('wBagItems',255);call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2')
        game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
        game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4]=[0]*4
        call('LoadSAV0');call('LoadSAV2');assert not(game.register_file.F&16)
        assert list(game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4])==moves
        assert game.memory[addr('wPartyMon1PP')+slot]==0xd8
        print(f'{version}: Wake-Up Slap221; {cases} power/wake/pipeline gates, both actors, Substitute break, immunity, PP, party status and SRAM passed')
    finally:game.stop(save=False)


if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
