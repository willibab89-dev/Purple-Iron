#!/usr/bin/env python3
"""Exercise Zap Cannon accuracy and Triple Kick execution on both battle sides."""
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
        assert MOVES['ZAP_CANNON']==223 and MOVES['TRIPLE_KICK']==224
        cases=0
        for turn in (0,1):
            for status in (0,1,8,16,32,64):
                for roll in range(256):
                    actor,target,ap,tp=init('ZAP_CANNON',turn)
                    put(tp+'Status',status);rng(roll);call('MoveHitTest')
                    assert bool(get('wMoveMissed')) == (not(status&64) and roll>127),(turn,status,roll)
                    cases+=1
            for seq,hits in [((0,),3),((255,),0),((0,255),1),((0,0,255),2)]:
                actor,target,ap,tp=init('TRIPLE_KICK',turn);rng(*seq);execute(turn)
                assert len(applied)==hits,(turn,seq,applied)
                assert get('wBattleMonPP')==(19 if turn==0 else 20)
                if hits<3 and hits:assert get(f'w{actor}NumAttacksLeft')==0 and not(get(f'w{actor}BattleStatus1')&4)
                cases+=1
            # A broken Substitute does not suppress the remaining kicks.
            actor,target,ap,tp=init('TRIPLE_KICK',turn)
            put(f'w{target}BattleStatus2',16);put(f'w{target}SubstituteHP',1);rng(0);execute(turn)
            assert len(applied)==3 and readword(tp+'HP')<200
            # A knockout stops the sequence immediately.
            actor,target,ap,tp=init('TRIPLE_KICK',turn);word(tp+'HP',1);rng(0);execute(turn)
            assert len(applied)==1
            # Fighting and Electric immunity and airborne targets remain protected.
            for move,immune in [('TRIPLE_KICK',8),('ZAP_CANNON',4)]:
                actor,target,ap,tp=init(move,turn);put(tp+'Status',64)
                game.memory[addr(tp+'Type'):addr(tp+'Type')+2]=[immune,immune];rng(0);execute(turn)
                assert readword(tp+'HP')==200
                actor,target,ap,tp=init(move,turn);put(tp+'Status',64);put(f'w{target}BattleStatus1',64);put(f'w{target}MoveNum',MOVES['FLY']);rng(0);execute(turn)
                assert readword(tp+'HP')==200
        for turn in (0,1):
            actor,target,ap,tp=init('ZAP_CANNON',turn);put(tp+'Status',64)
            put(f'w{actor}MonAccuracyMod',1);put(f'w{target}MonEvasionMod',13);rng(255);call('MoveHitTest')
            assert not get('wMoveMissed')
            actor,target,ap,tp=init('ZAP_CANNON',turn);put(tp+'Status',64)
            put(f'w{target}BattleStatus1',64);put(f'w{target}MoveNum',MOVES['DIG']);rng(0);execute(turn)
            assert readword(tp+'HP')==200
        # New IDs/PP survive the existing SRAM layout.
        for move in ('ZAP_CANNON','TRIPLE_KICK'):
            put('wPartyMon1Moves',MOVES[move]);put('wPartyMon1PP',5)
            call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2')
            put('wPartyMon1Moves',0);put('wPartyMon1PP',0)
            call('LoadSAV0');call('LoadSAV2')
            assert get('wPartyMon1Moves')==MOVES[move] and get('wPartyMon1PP')==5
        print(f'{version}: {cases} Zap accuracy and Triple Kick sequences; separate misses, PP, Substitute, KO, immunity and Fly passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for name in ('pokered','pokeblue'):validate(name)
