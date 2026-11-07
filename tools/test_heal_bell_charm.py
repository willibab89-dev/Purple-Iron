#!/usr/bin/env python3
"""Exercise Heal Bell party curing, Charm and independent variant evolution on both battle sides."""
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
        assert MOVES['HEAL_BELL']==234 and MOVES['CHARM']==235
        cases=0
        for turn in (0,1):
            for status in (0,3,8,16,32,64):
                actor,target,ap,tp=init('HEAL_BELL',turn)
                put(ap+'Status',status);put(f'w{actor}MonAttackMod',9);put(f'w{actor}MonSpeedMod',8)
                put('wCustomSide',turn);call('CustomRecalculate')
                count='wEnemyPartyCount' if turn else 'wPartyCount';party='wEnemyMon1' if turn else 'wPartyMon1'
                put(count,6);put(f'w{actor}ToxicCounter',5);put(f'w{actor}BattleStatus3',1)
                # Confusion and residual Curse must remain; only major status cures.
                put(f'w{actor}BattleStatus1',128);put('wEnemyResidual' if turn else 'wPlayerResidual',2)
                bank,a=syms['wEnemyMon2' if turn else 'wPartyMon2'];stride=a-addr(party)
                for i,st in enumerate((status,3,16,64,32,8)):
                    word_at=addr(party+'HP')+i*stride
                    game.memory[word_at:word_at+2]=[0,0 if i==5 else 200]
                    game.memory[addr(party+'Status')+i*stride]=(8 if i==0 and status==0 else st)
                put(ap+'PP',5);put(party+'PP',5)
                call('JumpMoveEffect')
                assert get(ap+'Status')==0 and readword(ap+'HP')==200
                assert readword(ap+'Attack')==200 and readword(ap+'Speed')==150
                assert get(f'w{actor}MonAttackMod')==9 and get(f'w{actor}MonSpeedMod')==8
                assert get(f'w{actor}BattleStatus1')&128
                assert get('wEnemyResidual' if turn else 'wPlayerResidual')==2
                for i in range(6):
                    assert game.memory[addr(party+'Status')+i*stride]==(8 if i==5 else 0),(turn,status,i)
                    assert list(game.memory[addr(party+'HP')+i*stride:addr(party+'HP')+i*stride+2])==[0,0 if i==5 else 200]
                if status:
                    assert not(get(f'w{actor}BattleStatus3')&1) and get(f'w{actor}ToxicCounter')==0
                cases+=1
            # A healthy party (including a statused fainted member) has no target.
            actor,target,ap,tp=init('HEAL_BELL',turn);put('wEnemyPartyCount' if turn else 'wPartyCount',2)
            party='wEnemyMon1' if turn else 'wPartyMon1';stride=addr('wEnemyMon2' if turn else 'wPartyMon2')-addr(party)
            game.memory[addr(party+'HP')+stride:addr(party+'HP')+stride+2]=[0,0]
            game.memory[addr(party+'Status')+stride]=8
            call('JumpMoveEffect');assert get('wCustomChanged')==0
            # Real execution consumes one PP, even if the party is healthy.
            actor,target,ap,tp=init('HEAL_BELL',turn);put('wEnemyPartyCount' if turn else 'wPartyCount',1)
            put(ap+'Status',8);execute(turn);assert get(ap+'Status')==0
            if not turn:assert get('wBattleMonPP')==19
            # Charm accuracy boundary and independent stage clamping.
            for stage,roll,expected in [(7,0,5),(2,0,1),(1,0,1),(7,229,5),(7,230,7)]:
                actor,target,ap,tp=init('CHARM',turn);put(f'w{target}MonAttackMod',stage);rng(roll);execute(turn)
                assert get(f'w{target}MonAttackMod')==expected,(turn,stage,roll,get(f'w{target}MonAttackMod'))
                cases+=1
            for protection in (2,16):
                actor,target,ap,tp=init('CHARM',turn);put(f'w{target}BattleStatus2',protection);rng(0);execute(turn)
                assert get(f'w{target}MonAttackMod')==7
        # Wild enemies cure themselves but must not touch stale trainer party RAM.
        init('HEAL_BELL',1);put('wIsInBattle',1);put('wEnemyMonStatus',8);put('wEnemyPartyCount',6)
        snap=bytes(game.memory[addr('wEnemyMons'):addr('wEnemyMons')+6*(addr('wEnemyMon2')-addr('wEnemyMon1'))])
        call('JumpMoveEffect');assert get('wEnemyMonStatus')==0
        assert bytes(game.memory[addr('wEnemyMons'):addr('wEnemyMons')+len(snap)])==snap
        # AI recognizes a living reserve's status but ignores fainted reserves.
        init('HEAL_BELL',1);put('wEnemyPartyCount',2);stride=addr('wEnemyMon2')-addr('wEnemyMon1')
        for hp,status,expected in [(200,8,0),(0,8,1),(200,0,1)]:
            word('wEnemyMon2HP',hp);put('wEnemyMon2Status',status);call('UtilityAIStatusScore')
            assert get('wCustomRandomValue')==expected
        for title in ('ReviewedBlastoiseUnique','ReviewedBulbasaurUnique','ReviewedChanseyUnique','ReviewedCharmanderUnique'):
            b,a=syms[title+'EvosMoves'];assert game.memory[b,a]==0
        for move,pp in [('HEAL_BELL',5),('CHARM',20)]:
            put('wPartyMon1Moves',MOVES[move]);put('wPartyMon1PP',pp)
            call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2');put('wPartyMon1Moves',0);put('wPartyMon1PP',0)
            call('LoadSAV0');call('LoadSAV2');assert get('wPartyMon1Moves')==MOVES[move] and get('wPartyMon1PP')==pp
        print(f'{version}: {cases} party/status/Charm boundaries; stat penalties, fainted reserves, PP, wild RAM, AI, independent no-evolution tables and saves passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for name in ('pokered','pokeblue'):validate(name)
