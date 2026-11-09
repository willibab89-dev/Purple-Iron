#!/usr/bin/env python3
"""Nature table, versioned storage, probabilities, battle and menu checks."""
from collections import Counter
from pathlib import Path
from pyboy import PyBoy
from generate_natures import definitions,render,ROOT
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
        for n in range(196):rng(n);call('NatureRoll');assert get('wNatureID')==n
        rng(196,255,37);call('NatureRoll');assert get('wNatureID')==37 and state['index']==3
        for id in range(196):
            for slot in range(1,6):
                stored('wPartyMon1',id,slot,22,3);rng(100)
                assert inspect('wPartyMon1')==(id,slot)
                assert get('wPartyMon1Type1')&31==22 and get('wPartyMon1Type2')&31==3
                assert state['index']==0
        for slot in range(1,6):
            put('wPartyMon1Type1',22);put('wPartyMon1Type2',3);put('wPartyMon1CatchRate',248+slot);rng(42)
            assert inspect('wPartyMon1')==(42,slot)
        # A legacy catch rate within 0..195 must never be accepted as a nature.
        put('wPartyMon1Type1',22);put('wPartyMon1Type2',3);put('wPartyMon1CatchRate',45);rng(4,87)
        assert inspect('wPartyMon1')==(87,5)
        # Generic box/daycare/party copy prefixes retain both IDs.
        stored('wPartyMon1',195,4,22,3)
        prefix=bytes(game.memory[addr('wPartyMon1'):addr('wPartyMon1')+33])
        for label in ('wBoxMon1','wDayCareMon','wPartyMon2'):
            game.memory[addr(label):addr(label)+33]=prefix;assert inspect(label)==(195,4)
        # Real gift creation assigns both fields before stats are generated.
        put('wPartyCount',0);put('wMonDataLocation',0x80);put('wIsInBattle',0);put('wCurEnemyLVL',5);put('wcf91',ids['BULBASAUR']);rng(2,91)
        call('AddPartyMon');assert inspect('wPartyMon1')==(91,3)
        put('wWhichPokemon',0);put('wPlayerMonNumber',0);put('wBattleMonSpecies2',ids['BULBASAUR']);put('wLinkState',0)
        call('LoadBattleMonFromParty');assert get('wBattleMonType1')==22 and get('wBattleMonType2')==3
        assert get('wActiveAbilities')==3 and get('wNatureIDs')==91
        # NPC trade constructor uses AddPartyMon; OT/nickname do not encode nature.
        put('wPartyCount',0);put('wcf91',ids['CHARMANDER']);rng(4,73);call('AddPartyMon')
        assert inspect('wPartyMon1')==(73,5)
        # Trainer parties and switches resolve the same stored nature each time.
        from test_reviewed_trainers import TRAINERS
        put('wIsInBattle',2);put('wTrainerClass',TRAINERS['SONY1']);put('wTrainerNo',3);rng(1,31)
        call('ReadTrainer');nature,slot=inspect('wEnemyMon1');assert nature==31 and slot==2
        for _ in range(2):
            put('wWhichPokemon',0);put('wEnemyMonPartyPos',0);put('wEnemyMonSpecies2',ids['CHARMANDER']);put('wCurEnemyLVL',5)
            for n in ('wEnemyBattleStatus3','wFontLoaded','wOptions'):put(n,0)
            call('LoadEnemyMonData');assert game.memory[addr('wNatureIDs')+1]==nature
            assert get('wEnemyMonType1')==20 and get('wEnemyMonType2')==20
        # Capture initialization copies cached wild identity, not a fresh roll.
        put('wIsInBattle',1);put('wNatureIDs',0);game.memory[addr('wNatureIDs')+1]=195;put('wNatureEnemySlot',5)
        put('wPartyCount',0);put('wMonDataLocation',0x80);put('wcf91',ids['CHARMANDER']);word('wEnemyMonHP',10);put('wEnemyMonSpecies2',ids['CHARMANDER'])
        call('AddPartyMon');assert inspect('wPartyMon1')==(195,5)
        put('wBoxMon1Type1',20);put('wBoxMon1Type2',20);call('NatureInitializeCapturedBox');assert inspect('wBoxMon1')==(195,5)
        # All five underlying stats: original value * ratio, floor, 1..999.
        put('wIsInBattle',0);put('wCurEnemyLVL',50);put('wd0b5',ids['BULBASAUR']);call('GetMonHeader')
        for n in ('HPExp','AttackExp','DefenseExp','SpeedExp','SpecialExp','DVs'):
            word('wPartyMon1'+n,0)
        def stats():
            call('CalcStats',HL=addr('wPartyMon1HPExp')-1,DE=addr('wPartyMon1Stats'),BC=256)
            return [readword('wPartyMon1'+n) for n in ('MaxHP','Attack','Defense','Speed','Special')]
        put('wPartyMon1Type2',0);baseline=stats()
        for id,(up,down) in enumerate(table):
            stored('wPartyMon1',id,3)
            expected=[max(1,min(999,value*(110 if up&(1<<i) else 90 if down&(1<<i) else 100)//100)) for i,value in enumerate(baseline)]
            assert stats()==expected,(id,baseline,stats(),expected)
            assert stats()==expected,('repeated stat calculation',id)
            for stat in range(5):
                for value in (1,9,100,999):
                    word('wNatureInputHL',addr('wPartyMon1HPExp')-1);put('wNatureInputBC',1);put('wNatureInputBC',1)
                    game.memory[addr('wNatureInputBC')+1]=stat+1
                    game.memory[0xff96:0xff99]=[0,value>>8,value&255]
                    call('NatureApplyStat')
                    want=max(1,min(999,value*(110 if up&(1<<stat) else 90 if down&(1<<stat) else 100)//100))
                    got=game.memory[0xff97]*256+game.memory[0xff98]
                    assert got==want,(id,stat,value,got,want)
        # Legacy party conversion preserves missing HP and never revives fainted.
        for hp in (0,1,baseline[0]-5,baseline[0]):
            put('wPartyMon1Type1',22);put('wPartyMon1Type2',3);put('wPartyMon1CatchRate',45)
            put('wPartyMon1Level',50);word('wPartyMon1MaxHP',baseline[0]);word('wPartyMon1HP',hp)
            put('wPartyCount',1);put('wSaveFileStatus',2);put('wDayCareInUse',0);rng(2,0)
            call('NatureMigrateParty');newmax=baseline[0]*110//100
            assert readword('wPartyMon1MaxHP')==newmax
            assert readword('wPartyMon1HP')==(0 if hp==0 else max(1,newmax-(baseline[0]-hp)))
            before=bytes(game.memory[addr('wPartyMon1'):addr('wPartyMon1')+44]);i=state['index']
            call('NatureMigrateParty');assert bytes(game.memory[addr('wPartyMon1'):addr('wPartyMon1')+44])==before and state['index']==i
        # Legacy boxed HP is converted using the deposit-level old maximum.
        for hp in (0,1,baseline[0]-5,baseline[0]):
            prefix=bytes(game.memory[addr('wPartyMon1'):addr('wPartyMon1')+33])
            game.memory[addr('wBoxMon1'):addr('wBoxMon1')+33]=prefix
            put('wBoxMon1Type1',22);put('wBoxMon1Type2',3);put('wBoxMon1CatchRate',45);put('wBoxMon1BoxLevel',50);word('wBoxMon1HP',hp)
            source('wBoxMon1');rng(0,7);call('NaturePrepareOldBox');newmax=baseline[0]*90//100
            assert inspect('wBoxMon1')==(7,1)
            assert readword('wBoxMon1HP')==(0 if hp==0 else max(1,newmax-(baseline[0]-hp)))
        # Accuracy/Evasion are a single multiplicative ratio on the wide chance.
        def ratio(id,attr):
            up,down=table[id];return 110 if up&(1<<attr) else 90 if down&(1<<attr) else 100
        def id_for(attr,r):return next(i for i in range(196) if ratio(i,attr)==r)
        put('wNatureMode',3)
        for turn in (0,1):
            put('turn',turn)
            for ar in (90,100,110):
                for er in (90,100,110):
                    game.memory[addr('wNatureIDs')+turn]=id_for(5,ar)
                    game.memory[addr('wNatureIDs')+1-turn]=id_for(7,er)
                    for chance in (1,80,128,204,255,2000):
                        game.memory[0xff96:0xff99]=[0,chance>>8,chance&255]
                        call('NatureApplyHitChance')
                        got=game.memory[0xff97]*256+game.memory[0xff98]
                        assert got==chance*ar//er,(turn,chance,ar,er,got)
                    for side in ('Player','Enemy'):
                        put('w'+side+'MonAccuracyMod',7);put('w'+side+'MonEvasionMod',7);put('w'+side+'MoveAccuracy',204)
                    call('CalcHitChance')
                    assert get('w'+('Enemy' if turn else 'Player')+'MoveAccuracy')==min(255,204*ar//er)
            for id in range(196):
                game.memory[addr('wNatureIDs')+turn]=id
                for threshold in (0,1,64,128,232,255):
                    call('NatureAdjustCriticalChance',BC=threshold<<8)
                    assert get('wNatureResult')==min(255,threshold*ratio(id,6)//100),(turn,id,threshold)
        # A guaranteed hit still bypasses nature probability changes.
        for turn in (0,1):
            put('turn',turn);put('wMoveMissed',0)
            for side in ('Player','Enemy'):
                put('w'+side+'MoveEffect',17);put('w'+side+'MoveAccuracy',1)
            rng(255);call('MoveHitTest');assert get('wMoveMissed')==0
            for side in ('Player','Enemy'):
                put('w'+side+'MoveEffect',0);put('w'+side+'MoveNum',MOVES['TACKLE']);put('w'+side+'MovePower',40)
                put('w'+side+'MoveAccuracy',255);put('w'+side+'BattleStatus1',0);put('w'+side+'BattleStatus2',0)
                put('w'+side+'MonAccuracyMod',7);put('w'+side+'MonEvasionMod',7)
            game.memory[addr('wNatureIDs'):addr('wNatureIDs')+2]=[0,0]
            put('wMoveMissed',0);rng(255);call('MoveHitTest');assert get('wMoveMissed')==0
            game.memory[addr('wNatureIDs')+turn]=id_for(5,90)
            game.memory[addr('wNatureIDs')+1-turn]=id_for(7,110)
            put('wMoveMissed',0);rng(255);call('MoveHitTest');assert get('wMoveMissed')==1
            actor='Enemy' if turn else 'Player';target='wBattleMon' if turn else 'wEnemyMon'
            game.memory[addr('wNatureIDs')+turn]=id_for(6,90)
            put('w'+actor+'MoveNum',MOVES['SHOCK_WAVE']);put('w'+actor+'MovePower',40);put('w'+actor+'MoveType',TYPES['ELECTRIC'])
            put(target+'Status',64);call('NatureCriticalHitTest');assert get('wCriticalHitOrOHKO')==1
        # Save block sizes/checksums remain native and both fields survive reload.
        stored('wPartyMon1',194,2)
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2');put('wPartyMon1CatchRate',0)
        call('LoadSAV0');call('LoadSAV2');assert inspect('wPartyMon1')==(194,2)
        assert addr('wPartyMon2')-addr('wPartyMon1')==44 and addr('wBoxMon2')-addr('wBoxMon1')==33
        print(f'{version}: nature table/balance, all 980 ID/slot combinations, unbiased rolls, legacy migration, gift/trainer/capture identity, stored copies and save passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for v in ('pokered','pokeblue'):validate(v)
