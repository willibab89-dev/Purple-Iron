#!/usr/bin/env python3
"""Exercise new move effects and machine mappings on both battle sides."""
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
                  'MoveAnimation','HideSubstituteShowMonAnim','ReshowSubstituteAnim','SaveScreenTilesToBuffer1'):
            patch(n,[0xc9])
        patch('BattleRandom',[0xc9]);b,a=syms['BattleRandom'];game.hook_register(b,a,on_rng,state)
        for label in ('ApplyAttackToPlayerPokemon','ApplyAttackToEnemyPokemon'):
            b,a=syms[label];game.hook_register(b,a,lambda label:applied.append(label),label)
        for turn in (0,1):
            actor,target,ap,tp=init('HEAD_SMASH',turn)
            for damage in (1,2,3,100,255,600):
                word(ap+'HP',1000);word(ap+'MaxHP',1000);word('wDamage',damage)
                call('RecoilEffect_')
                assert readword(ap+'HP')==1000-max(1,damage//3),(turn,damage,readword(ap+'HP'))
            for stage in (7,11,12):
                actor,target,ap,tp=init('COTTON_GUARD',turn)
                put(f'w{actor}MonDefenseMod',stage);call('StatModifierUpEffect')
                assert get(f'w{actor}MonDefenseMod')==min(13,stage+3),(turn,stage,get(f'w{actor}MonDefenseMod'))
            actor,target,ap,tp=init('COTTON_SPORE',turn)
            call('StatModifierDownEffect')
            assert get(f'w{target}MonSpeedMod')==5,(turn,'cotton spore',get(f'w{target}MonSpeedMod'))
            actor,target,ap,tp=init('MAGICAL_LEAF',turn)
            put(f'w{actor}MonAccuracyMod',1);put(f'w{target}MonEvasionMod',13);rng(255)
            call('MoveHitTest');assert get('wMoveMissed')==0,(turn,'magical leaf')
            put(f'w{target}BattleStatus1',64);call('MoveHitTest');assert get('wMoveMissed')==1,(turn,'magical leaf vs Fly')
            actor,target,ap,tp=init('MEAN_LOOK',turn)
            call('ResidualClearAll');rng(0);call('JumpMoveEffect')
            assert get(f'w{target}MonSpeedMod')==6,(turn,'mean look speed')
            assert get('wPlayerResidual' if turn else 'wEnemyResidual') & 16,(turn,'mean look trap')
            if turn:
                put('wIsInBattle',1);put('wBattleType',0);put('wLinkState',0)
                call('TryRunningFromBattle');assert get('wActionResultOrTookBattleTurn')==1,(turn,'escape blocked')
            call('ResidualPlayerSwitchBlocked' if turn else 'ResidualEnemySwitchBlocked')
            assert not (game.register_file.F & 0x80),(turn,'mean look prevents switching')
            call('ResidualClearPlayer' if turn == 0 else 'ResidualClearEnemy')
            assert not (get('wPlayerResidual' if turn else 'wEnemyResidual') & 16),(turn,'trap clears')
            actor,target,ap,tp=init('LAST_STING',turn)
            execute(turn)
            assert readword(ap+'HP')==0 and readword(tp+'HP')<200,(turn,'last sting',readword(ap+'HP'),readword(tp+'HP'))
        # The item IDs are separate from the earlier contiguous TM block.
        for item,internal,move in ((114,69,'HEAD_SMASH'),(115,70,'MAGICAL_LEAF'),(116,71,'MEAN_LOOK')):
            put('wcf91',item);call('DecodeMachineItem');assert get('wd11e')==internal
            call('TMToMove');assert get('wd11e')==MOVES[move]
        for mon,move,expected in ((34,'HEAD_SMASH',True),(194,'HEAD_SMASH',True),(193,'HEAD_SMASH',False),(153,'MAGICAL_LEAF',True),(36,'HEAD_SMASH',False)):
            put('wcf91',mon);put('wMoveNum',MOVES[move]);call('CanLearnTM');assert bool(game.register_file.C)==expected,(mon,move)
        print(f'{version}: new move effects, recoil, accuracy, stat caps and TM mappings passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for name in ('pokered','pokeblue'):validate(name)
