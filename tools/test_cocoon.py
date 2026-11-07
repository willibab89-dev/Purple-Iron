#!/usr/bin/env python3
"""Validate Cocoon, draining synergy, physical damage and boss learnsets."""
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
        assert MOVES['COCOON']==236 and MOVES['STRUGGLE']==165
        b,a=syms['MoveAnimationMap'];assert game.memory[b,a+235]==MOVES['HARDEN']
        for turn in (0,1):
            actor='Enemy' if turn else 'Player'
            for stage,expected in ((7,9),(11,13),(12,13),(13,13)):
                actor,target,ap,tp=init('COCOON',turn)
                put(f'w{actor}MonSpecialMod',stage)
                execute(turn)
                assert get(f'w{actor}MonSpecialMod')==expected,(turn,stage)
                assert [get(f'w{actor}Mon{s}Mod') for s in ('Attack','Defense','Speed','Accuracy','Evasion')]==[7]*5
                assert readword(ap+'HP')==200 and readword(tp+'HP')==200
                if not turn:assert get('wBattleMonPP')==19
            # Use actual move execution: Cocoon improves Mega Drain, but not
            # Leech Life or Stone Press. No critical hits or random damage.
            for move in ('MEGA_DRAIN','LEECH_LIFE','STONE_PRESS'):
                results=[]
                for boosted in (False,True):
                    actor,target,ap,tp=init('COCOON',turn)
                    if boosted:execute(turn)
                    word(ap+'MaxHP',500);word(ap+'HP',100)
                    word(tp+'MaxHP',1000);word(tp+'HP',1000)
                    game.memory[addr(tp+'Type'):addr(tp+'Type')+2]=[0,0]
                    put(f'w{actor}SelectedMove',MOVES[move]);call('GetCurrentMove');rng(0);execute(turn)
                    dealt=1000-readword(tp+'HP');assert dealt>0,(turn,move)
                    if move!='STONE_PRESS':assert readword(ap+'HP')==100+dealt//2,(turn,move,dealt,readword(ap+'HP'))
                    results.append(dealt)
                assert (results[1]>results[0] if move=='MEGA_DRAIN' else results[1]==results[0]),(turn,move,results)
        # These species remain standalone, and bosses receive the intended sets.
        for title in ('ReviewedGrimerPoison','ReviewedIvysaurErika','ReviewedKakunaRockType'):
            b,a=syms[title+'EvosMoves'];assert game.memory[b,a]==0
        import json
        species=json.loads((ROOT/'data/unique_species.json').read_text())
        for dex,level,expected in ((159,39,['SLUDGE','DISABLE','TOXIC','ACID_ARMOR']),(160,33,['STUN_SPORE','LEECH_SEED','REFLECT','VINE_CRUSH']),(161,25,['HARDEN','ROCK_THROW','LEECH_LIFE','COCOON'])):
            index=next(x['index'] for x in species if x['dex']==dex)
            put('wPartyCount',0);put('wMonDataLocation',0x80);put('wIsInBattle',0)
            put('wCurEnemyLVL',level);put('wcf91',index);call('AddPartyMon')
            assert list(game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4])==[MOVES[m] for m in expected],dex
        put('wPartyMon1Moves',236);put('wPartyMon1PP',15)
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2');put('wPartyMon1Moves',0);put('wPartyMon1PP',0)
        call('LoadSAV0');call('LoadSAV2');assert get('wPartyMon1Moves')==236 and get('wPartyMon1PP')==15
        print(f'{version}: Cocoon both actors, stage caps, PP, drain synergy, physical damage unchanged, boss sets, no evolutions and saves passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for name in ('pokered','pokeblue'):validate(name)
