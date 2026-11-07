#!/usr/bin/env python3
"""Exercise Electro Ball ratios, current Speed, AI and battle execution on both battle sides."""
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
        assert MOVES['ELECTRO_BALL']==227
        cases=0
        pairs=[(0,0),(0,1),(1,0),(1,1),(1,2),(99,100),(100,100),(199,100),(200,100),(299,100),(300,100),(399,100),(400,100),(401,100),(65535,65535),(65534,65535),(65535,32768),(65535,32767),(65535,21845),(65535,16384),(65535,16383),(65535,1),(1,65535)]
        def power(u,t):return [40,60,80,120,150][min(4,u//max(1,t))]
        for turn in (0,1):
            for u,t in pairs:
                for crit in (0,1):
                    actor,target,ap,tp=init('ELECTRO_BALL',turn)
                    word(ap+'Speed',u);word(tp+'Speed',t);put('wCriticalHitOrOHKO',crit)
                    call('GetDamageVarsForEnemyAttack' if turn else 'GetDamageVarsForPlayerAttack')
                    assert game.register_file.D==power(u,t),(turn,u,t,crit,game.register_file.D)
                    cases+=1
            # Modified Speed includes stages and paralysis even on critical hits.
            for stage,status,expected in [(9,0,80),(9,64,40),(13,0,150),(13,64,60)]:
                actor,target,ap,tp=init('ELECTRO_BALL',turn);put(f'w{actor}MonSpeedMod',stage);put(ap+'Status',status)
                put('wCustomSide',turn);call('CustomRecalculate');put('wCriticalHitOrOHKO',1)
                call('GetDamageVarsForEnemyAttack' if turn else 'GetDamageVarsForPlayerAttack')
                assert game.register_file.D==expected,(stage,status,readword(ap+'Speed'),game.register_file.D)
            # Re-read conditions at execution, rather than caching menu-time power.
            actor,target,ap,tp=init('ELECTRO_BALL',turn);word(ap+'Speed',400);word(tp+'Speed',100)
            call('GetDamageVarsForEnemyAttack' if turn else 'GetDamageVarsForPlayerAttack');assert game.register_file.D==150
            word(tp+'Speed',401)
            call('GetDamageVarsForEnemyAttack' if turn else 'GetDamageVarsForPlayerAttack');assert game.register_file.D==40
            actor,target,ap,tp=init('ELECTRO_BALL',turn);rng(0);execute(turn)
            assert readword(tp+'HP')<200
            if not turn:assert get('wBattleMonPP')==19
            actor,target,ap,tp=init('ELECTRO_BALL',turn)
            game.memory[addr(tp+'Type'):addr(tp+'Type')+2]=[4,4];rng(0);execute(turn);assert readword(tp+'HP')==200
        for u,t in pairs:
            init('ELECTRO_BALL',1);word('wEnemyMonSpeed',u);word('wBattleMonSpeed',t)
            call('ConditionalAIPower');assert get('wEnemyMovePower')==power(u,t)
        put('wPartyMon1Moves',227);put('wPartyMon1PP',10)
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2');put('wPartyMon1Moves',0);put('wPartyMon1PP',0)
        call('LoadSAV0');call('LoadSAV2');assert get('wPartyMon1Moves')==227 and get('wPartyMon1PP')==10
        print(f'{version}: {cases} ratio/crit boundaries plus stages, paralysis, live changes, AI, execution, PP, immunity and save passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for name in ('pokered','pokeblue'):validate(name)
