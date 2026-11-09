#!/usr/bin/env python3
"""Movement cadence and paralysis/poison stat penalties in both ROMs."""
from collections import Counter
from pathlib import Path
from pyboy import PyBoy
from generate_natures import definitions,render,ROOT,ATTRIBUTES
import os
from test_unique_species import symbols,TYPES
from test_move_patch_3 import constants,MOVES


def validate(version):
    assert (ROOT/'data/natures.asm').read_text()==render()
    syms=symbols(ROOT/(version+'.sym'));ids=constants(ROOT/'constants/pokemon_constants.asm')
    rom=(ROOT/(version+'.gbc')).read_bytes()
    def data(n,size):
        b,a=syms[n];start=b*16384+a-16384 if b else a
        return rom[start:start+size]
    table=definitions();assert data('NatureDefinitions',392)==bytes(v for pair in table for v in pair)
    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return 0xfff3 if n=='turn' else syms[n][1]
    def put(n,v):game.memory[addr(n)]=v
    def get(n):return game.memory[addr(n)]
    def word(n,v):game.memory[addr(n):addr(n)+2]=[v>>8,v&255]
    def readword(n):return get(n)*256+game.memory[addr(n)+1]
    def patch(n,code):
        b,a=syms[n];game.memory[b,a:a+len(code)]=code
    def call(n,**regs):
        b,a=syms[n];game.memory[0x2000]=game.memory[0xffb8]=b or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,a&255,a>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0;game.register_file.SP=0xdffe;game.register_file.PC=0x100
        game.memory[0xdf42:0xdf62]=[0xa5]*32
        for k,v in regs.items():
            if k in ('BC','DE'):
                setattr(game.register_file,k[0],v>>8);setattr(game.register_file,k[1],v&255)
            else:setattr(game.register_file,k,v)
        for _ in range(180):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):
                assert bytes(game.memory[0xdf42:0xdf62])==bytes([0xa5]*32),('stack guard',n)
                return
        raise AssertionError((version,n,hex(game.register_file.PC),hex(game.register_file.SP)))
    state={'values':[0],'index':0}
    def rng(*values):state.update(values=list(values),index=0)
    def on_rng(s):
        i=s['index'];s['index']+=1;game.register_file.A=s['values'][min(i,len(s['values'])-1)]
    patch('Random',[0xc9]);b,a=syms['Random'];game.hook_register(b,a,on_rng,state)
    def source(label):word('wNatureInputHL',addr(label))
    def stored(label,id,slot=1,t1=0,t2=0):
        put(label+'Species',ids['BULBASAUR']);put(label+'Type1',t1|(slot<<5));put(label+'Type2',t2|224);put(label+'CatchRate',id)
    def inspect(label):
        source(label);call('NatureEnsureMon');return get('wNatureID'),get('wNatureSlot')
    try:
        for n in ('PrintText','CustomPrintStatName','PlayCurrentMoveAnimation','PlayCurrentMoveAnimation2','DelayFrames','DelayFrame','PlayBattleAnimation2','PlayBattleAnimation','DrawHUDsAndHPBars'):
            patch(n,[0xc9])
        def init(side=0,status=0):
            put('turn',1-side);put('wCustomSide',side);put('wIsInBattle',2);put('wLinkState',0);put('wOptions',0);put('wObtainedBadges',0)
            put('wPlayerMonNumber',0);put('wEnemyMonPartyPos',0)
            for name,prefix in (('Player','wBattleMon'),('Enemy','wEnemyMon')):
                for i in (1,2,3):put('w'+name+'BattleStatus'+str(i),0)
                put('w'+name+'DisabledMove',0);put('w'+name+'DisabledMoveNumber',0)
                put('w'+name+'SelectedMove',MOVES['TACKLE']);put('w'+name+'UsedMove',MOVES['TACKLE'])
                for i,stat in enumerate(('Attack','Defense','Speed','Special')):
                    word(prefix+stat,101)
                    game.memory[addr('w'+name+'MonUnmodifiedAttack')+i*2:addr('w'+name+'MonUnmodifiedAttack')+i*2+2]=[0,101]
                game.memory[addr('w'+name+'MonStatMods'):addr('w'+name+'MonStatMods')+6]=[7]*6
                put(prefix+'Status',0)
            prefix='wEnemyMon' if side else 'wBattleMon';put(prefix+'Status',status)
            return prefix
        for side in (0,1):
            for value in (1,2,3,4,5,101,999):
                pref=init(side,64);word(pref+'Speed',value);call('QuarterSpeedDueToParalysis');assert readword(pref+'Speed')==max(1,value//2)
                pref=init(side,8);word(pref+'Special',value);call('PoisonSpecialPenalty');assert readword(pref+'Special')==max(1,value//4)
            # Nature-adjusted underlying values are rebuilt before penalties.
            for status in (8,64,0x58):
                pref=init(side,status)
                for _ in range(3):
                    call('CustomRecalculate');assert readword(pref+'Special')==(25 if status&8 else 101)
                    assert readword(pref+'Speed')==(50 if status&64 else 101)
                    assert readword(pref+'Attack')==(50 if status&16 else 101)
                put('turn',side);call('UndoBurnParStats')
                assert get(pref+'Status')==status
                assert [readword(pref+n) for n in ('Attack','Defense','Speed','Special')]==[101]*4
            # Stat-stage boosts still apply before the poison/paralysis multiplier.
            pref=init(side,8);put('w'+('Enemy' if side else 'Player')+'MonSpecialMod',9)
            for _ in range(2):call('CustomRecalculate');assert readword(pref+'Special')==50
            # Actual action-time checks: exactly 50 of 250 accepted RNG values.
            count=0;patch('BattleRandom',[0xc9]);rb,ra=syms['BattleRandom'];game.hook_register(rb,ra,on_rng,state)
            for byte in range(250):
                pref=init(side,64);put('turn',side);rng(byte)
                call('CheckEnemyStatusConditions' if side else 'CheckPlayerStatusConditions')
                blocked=bool(game.register_file.F&128);assert blocked==(byte<50),(side,byte,blocked)
                count+=blocked
            assert count==50
            rng(250,255,49);call('TwentyPercentBattleRoll');assert game.register_file.F&16 and state['index']==3
            game.hook_deregister(rb,ra)
        # Native poison infliction immediately changes the target's Special.
        for turn in (0,1):
            target=1-turn;pref=init(target,0);put('turn',turn)
            put('wEnemyMonType1',0);put('wEnemyMonType2',0);put('wBattleMonType1',0);put('wBattleMonType2',0)
            put('wCustomTargetHadSub',0);put('wMoveMissed',0)
            for n in ('Player','Enemy'):put('w'+n+'MoveEffect',3);put('w'+n+'MoveNum',MOVES['POISONPOWDER']);put('w'+n+'MoveAccuracy',255)
            patch('MoveHitTest',[0xc9]);call('PoisonEffect');assert get(pref+'Status')==8 and readword(pref+'Special')==25
        # Legacy single-stat effects also retain one poison penalty.
        for turn in (0,1):
            pref=init(turn,8);put('turn',turn)
            put('w'+('Enemy' if turn else 'Player')+'MoveEffect',13)
            call('StatModifierUpEffect');assert readword(pref+'Special')==37
            put('w'+('Enemy' if turn else 'Player')+'MoveEffect',13)
            call('StatModifierUpEffect');assert readword(pref+'Special')==50
        # Full Restore on a reserve must not clear the active poison penalty.
        for n in ('PlaySoundWaitForCurrent','UpdateHPBar2','WaitForTextScrollButtonPress',
                  'ClearScreen','RedrawPartyMenu','GBPalWhiteOut','RunDefaultPaletteCommand','RemoveUsedItem'):
            patch(n,[0xc9])
        for selected,item in ((1,16),(0,16),(0,11)):
            pref=init(0,8);put('turn',0);put('wCustomSide',0);call('CustomRecalculate')
            put('wPartyCount',2);put('wPseudoItemID',0);put('wWhichPokemon',0);put('wcf91',item)
            put('wPlayerBattleStatus3',1);put('wPlayerToxicCounter',9)
            for party in ('wPartyMon1','wPartyMon2'):
                word(party+'HP',50);word(party+'MaxHP',200);put(party+'Status',8)
            word('wBattleMonHP',50);word('wBattleMonMaxHP',200)
            q=addr('wWhichPokemon');patch('DisplayPartyMenu',[0x3e,selected,0xea,q&255,q>>8,0xaf,0xc9])
            call('ItemUseMedicine')
            assert get('wUsedItemOnWhichPokemon')==selected
            assert get('wBattleMonStatus')==(8 if selected else 0)
            assert readword('wBattleMonSpecial')==(25 if selected else 101)
            assert get('wPlayerToxicCounter')==(9 if selected else 0)
            assert get('wPartyMon2Status' if selected else 'wPartyMon1Status')==0
        # Use the real speed-selector: 80 two-frame ticks cover 11 tiles,
        # versus 88 ticks at normal speed. Every tile event still occurs once.
        put('wWalkBikeSurfState',0);put('wd730',0);put('wd736',0);put('wNPCMovementScriptPointerTableNum',0);put('wCurMap',0)
        game.memory[0xffb4]=0;put('wWalkSpeedPhase',0)
        counter=8;tiles=0;advances=0
        for _ in range(80):
            put('wWalkCounter',counter);call('TrackRunBikeSpeed');speed=get('wUnusedD119')
            assert speed in (1,2) and speed<=counter
            counter-=speed;advances+=speed
            if counter==0:tiles+=1;counter=8
        assert advances==88 and tiles==11 and get('wWalkSpeedPhase')==0
        # A pending boost at the last movement update is deferred safely.
        put('wWalkSpeedPhase',9);put('wWalkCounter',1);call('TrackRunBikeSpeed')
        assert get('wUnusedD119')==1 and get('wWalkSpeedPhase')==10
        put('wWalkCounter',8);call('TrackRunBikeSpeed')
        assert get('wUnusedD119')==2 and get('wWalkSpeedPhase')==1
        for guard in ('idle','bike','surf','run','script','ledge','spinner','npc'):
            put('wWalkCounter',7);put('wWalkBikeSurfState',0);put('wd730',0);put('wd736',0);put('wNPCMovementScriptPointerTableNum',0);game.memory[0xffb4]=0
            if guard=='idle':put('wWalkCounter',0)
            if guard=='bike':put('wWalkBikeSurfState',1)
            if guard=='surf':put('wWalkBikeSurfState',2)
            if guard=='run':game.memory[0xffb4]=2
            if guard=='script':put('wd730',128)
            if guard=='ledge':put('wd736',64)
            if guard=='spinner':put('wd736',128)
            if guard=='npc':put('wNPCMovementScriptPointerTableNum',1)
            before=get('wWalkSpeedPhase');call('TrackRunBikeSpeed')
            assert get('wWalkSpeedPhase')==before,guard
        print(f'{version}: 10% walking cadence/guards, both-side Speed/Special floors, nonstacking stage rebuild/cures, exact 20% paralysis and native poison application passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for v in ('pokered','pokeblue'):validate(v)
