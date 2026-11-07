#!/usr/bin/env python3
"""Check Quiver Dance's two boosts, caps, status penalties, AI, PP and saves."""
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
        assert MOVES['QUIVER_DANCE']==222 and MOVES['STRUGGLE']==165
        b,a=syms['Moves'];assert list(game.memory[b,a+221*6:a+222*6])==[222,EFFECTS['COMPOUND_STATUS_EFFECT'],0,7,255,10]
        b,a=syms['MoveAnimationMap'];assert game.memory[b,a+221]==MOVES['AGILITY']
        def stat(stage):return 100*(stage-5)//2 if stage>=7 else 200//(9-stage)
        cases=0
        for turn in (0,1):
            for special,speed in ((7,7),(13,7),(7,13),(13,13),(3,4),(12,12)):
                actor,target,ap,tp=init('QUIVER_DANCE',turn)
                game.memory[addr(f'w{actor}MonStatMods')+3]=special
                game.memory[addr(f'w{actor}MonStatMods')+2]=speed
                put('wCustomSide',turn);call('CustomRecalculate');effect()
                expected=[7]*6;expected[3]=min(13,special+1);expected[2]=min(13,speed+1)
                assert mods(actor)==expected,(turn,special,speed,mods(actor))
                assert mods(target)==[7]*6
                assert readword(ap+'Special')==stat(expected[3])
                assert readword(ap+'Speed')==stat(expected[2])
                cases+=1
            for status in (8,16,64):
                actor,target,ap,tp=init('QUIVER_DANCE',turn);put(ap+'Status',status)
                effect();assert get(ap+'Status')==status and readword(ap+'Special')==150
                assert readword(ap+'Speed')==(37 if status==64 else 150)
                assert readword(ap+'Attack')==(50 if status==16 else 100)
                cases+=1
            # This is self setup: opposing Mist/Substitute/invulnerability
            # and the user's own Substitute do not block either boost.
            actor,target,ap,tp=init('QUIVER_DANCE',turn)
            put(f'w{target}BattleStatus2',18);put(f'w{target}BattleStatus1',64)
            put(f'w{actor}BattleStatus2',16);effect()
            assert mods(actor)==[7,7,8,8,7,7];cases+=1
            # Real actor move path consumes PP and applies both boosts once.
            actor,target,ap,tp=init('QUIVER_DANCE',turn)
            put(ap+'PP',10);put('wPartyMon1PP',10)
            call('EnemyCanExecuteMove' if turn else 'PlayerCanExecuteMove')
            assert mods(actor)==[7,7,8,8,7,7]
            assert readword(ap+'Special')==150 and readword(ap+'Speed')==150
            if not turn:assert get('wBattleMonPP')==9 and get('wPartyMon1PP')==9
            cases+=1
        for special,speed,useless in ((7,7,0),(13,7,0),(7,13,0),(13,13,1)):
            init('QUIVER_DANCE',1)
            put('wEnemyMonSpecialMod',special);put('wEnemyMonSpeedMod',speed)
            call('CustomAIStatusScore');assert get('wCustomRandomValue')==useless
            cases+=1
        put('wPartyCount',0);put('wMonDataLocation',0x80);put('wIsInBattle',0);put('wCurEnemyLVL',60)
        b,a=syms['PokedexOrder'];put('wcf91',list(game.memory[b,a:a+190]).index(49)+1)
        call('AddPartyMon');moves=list(game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]);slot=moves.index(222)
        assert game.memory[addr('wPartyMon1PP')+slot]==10
        game.memory[addr('wPartyMon1PP')+slot]=0xd0
        put('wNumBagItems',0);put('wBagItems',255);call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2')
        game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[0]*4
        game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4]=[0]*4
        call('LoadSAV0');call('LoadSAV2');assert not(game.register_file.F&16)
        assert list(game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4])==moves
        assert game.memory[addr('wPartyMon1PP')+slot]==0xd0
        print(f'{version}: Quiver Dance222; {cases} boost/cap/status/self-gate/pipeline/AI cases, generated PP and SRAM passed')
    finally:game.stop(save=False)


if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
