#!/usr/bin/env python3
"""Nature table, versioned storage, probabilities, battle and menu checks."""
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
        # Save-load daycare migration must convert HP before setting its marker.
        for hp in (0,baseline[0]):
            prefix=bytes(game.memory[addr('wBoxMon1'):addr('wBoxMon1')+33])
            game.memory[addr('wDayCareMon'):addr('wDayCareMon')+33]=prefix
            put('wDayCareMonType1',22);put('wDayCareMonType2',3);put('wDayCareMonCatchRate',45);word('wDayCareMonHP',hp)
            put('wPartyCount',0);put('wDayCareInUse',1);put('wSaveFileStatus',2);rng(0,7)
            call('NatureMigrateParty');assert inspect('wDayCareMon')==(7,1)
            assert readword('wDayCareMonHP')==(0 if hp==0 else baseline[0]*90//100)
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
                        assert got==max(0,(chance+1)*ar//er-1),(turn,chance,ar,er,got)
                    for side in ('Player','Enemy'):
                        put('w'+side+'MonAccuracyMod',7);put('w'+side+'MonEvasionMod',7);put('w'+side+'MoveAccuracy',204)
                    call('CalcHitChance')
                    assert get('w'+('Enemy' if turn else 'Player')+'MoveAccuracy')==min(255,max(0,205*ar//er-1))
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
        # Every nameless description is generated from the selected mon's masks.
        patch('DelayFrame',[0xc9]);patch('JoypadLowSensitivity',[0xc9]);jb,ja=syms['JoypadLowSensitivity']
        frames=[];ui={'key':2}
        def close_panel(s):
            frames.append(bytes(game.memory[addr('wTileMap'):addr('wTileMap')+360]))
            game.memory[0xffb5]=s['key']
        game.hook_register(jb,ja,close_panel,ui)
        def decode(raw):
            def char(v):
                if 128<=v<=153:return chr(ord('A')+v-128)
                if 160<=v<=185:return chr(ord('a')+v-160)
                if 246<=v<=255:return chr(ord('0')+v-246)
                return {127:' ',243:'/',232:'.'}.get(v,'?')
            return ''.join(char(v) for v in raw).rstrip()
        put('wWhichPokemon',1);put('wIsInBattle',0);put('wActionResultOrTookBattleTurn',0)
        game.memory[addr('wPartyMonNicks')+11:addr('wPartyMonNicks')+21]=[129,148,139,129,128,146,128,148,145,80]
        active=bytes(game.memory[addr('wNatureIDs'):addr('wNatureIDs')+2])
        abilities=bytes(game.memory[addr('wActiveAbilities'):addr('wActiveAbilities')+2])
        game.memory[addr('wTileMapBackup2'):addr('wTileMapBackup2')+360]=[0x66]*360
        examples={}
        for id,(up,down) in enumerate(table):
            stored('wPartyMon2',id,4,22,3);ui['key']=(1,2,4)[id%3]
            before=bytes(game.memory[addr('wTileMap'):addr('wTileMap')+360]);call('PartyNaturePanel')
            frame=frames[-1];pos=[ATTRIBUTES[i] for i in range(8) if up&(1<<i)];neg=[ATTRIBUTES[i] for i in range(8) if down&(1<<i)]
            assert decode(frame[6*20+2:6*20+19])=='Raises '+pos[0],id
            assert decode(frame[10*20+2:10*20+19])=='Lowers '+neg[0],id
            assert decode(frame[8*20+2:8*20+19])==('and '+pos[1] if len(pos)==2 else ''),id
            assert decode(frame[12*20+2:12*20+19])==('and '+neg[1] if len(neg)==2 else ''),id
            assert get('wWhichPokemon')==1 and get('wPartyMon2CatchRate')==id
            assert bytes(game.memory[addr('wNatureIDs'):addr('wNatureIDs')+2])==active
            assert bytes(game.memory[addr('wActiveAbilities'):addr('wActiveAbilities')+2])==abilities
            assert bytes(game.memory[addr('wTileMap'):addr('wTileMap')+360])==before
            assert bytes(game.memory[addr('wTileMapBackup2'):addr('wTileMapBackup2')+360])==bytes([0x66]*360)
            if id==0:examples['simple']=frame
            if len(pos)==2 and 'ACCURACY' in pos and 'EVASION' in neg:examples.setdefault('complex',frame)
        game.hook_deregister(jb,ja)
        if os.environ.get('NATURE_SCREENSHOTS') and version=='pokered':
            out=Path(os.environ['NATURE_SCREENSHOTS']);out.mkdir(parents=True,exist_ok=True)
            game.memory[0xff40]=0;call('LoadFontTilePatterns');call('LoadTextBoxTilePatterns')
            for label,tiles in examples.items():
                game.memory[0xff40]=0
                for row in range(18):game.memory[0x9800+32*row:0x9800+32*row+20]=tiles[row*20:row*20+20]
                game.memory[0xff4f]=1;game.memory[0x9800:0x9c00]=[0]*1024;game.memory[0xff4f]=0
                game.memory[0xff68]=0x80
                for c in [255,127,181,86,74,41,0,0]:game.memory[0xff69]=c
                game.memory[0xff47]=0xe4;game.memory[0xff42]=game.memory[0xff43]=0
                game.memory[0xff40]=0x81;game.tick(3,True)
                game.screen.image.save(out/f'nature-panel-{label}.png')
        # Real party/PC/daycare paths copy the nature together with its Pokémon.
        put('wPartyCount',0);put('wMonDataLocation',0x80);put('wIsInBattle',0);put('wCurEnemyLVL',20);put('wcf91',ids['BULBASAUR']);rng(4,91,2,3)
        call('AddPartyMon');first=inspect('wPartyMon1');initial_max=readword('wPartyMon1MaxHP')
        put('wNumInBox',0);put('wWhichPokemon',0);put('wMoveMonType',1);call('MoveMon')
        assert inspect('wBoxMon1')==first
        put('wRemoveMonFromBox',0);call('RemovePokemon');assert get('wPartyCount')==0
        put('wMoveMonType',0);put('wWhichPokemon',0);put('wcf91',ids['BULBASAUR']);call('MoveMon')
        assert inspect('wPartyMon1')==first and readword('wPartyMon1MaxHP')==initial_max
        put('wRemoveMonFromBox',1);call('RemovePokemon');assert get('wNumInBox')==0
        put('wMoveMonType',3);put('wWhichPokemon',0);put('wcf91',ids['BULBASAUR']);call('MoveMon')
        assert inspect('wDayCareMon')==first
        put('wRemoveMonFromBox',0);call('RemovePokemon');put('wDayCareInUse',1)
        for _ in range(10):call('IncrementDayCareMonExp')
        assert inspect('wDayCareMon')==first
        put('wMoveMonType',2);put('wWhichPokemon',0);put('wcf91',ids['BULBASAUR']);call('MoveMon');assert inspect('wPartyMon1')==first
        # Existing native party swap copies the entire individual prefix.
        put('wMonDataLocation',0x80);put('wIsInBattle',0);put('wCurEnemyLVL',30);put('wcf91',ids['CHARMANDER']);rng(1,137,2,3)
        call('AddPartyMon');second=inspect('wPartyMon2')
        put('wMenuItemToSwap',0);put('wWhichPokemon',0);call('SwitchPartyMon_InitVarOrSwapData')
        put('wCurrentMenuItem',1);call('SwitchPartyMon_InitVarOrSwapData')
        assert inspect('wPartyMon1')==second and inspect('wPartyMon2')==first
        # Wild capture reload must not reroll an existing nature or ability slot.
        put('wNatureMode',0);put('wIsInBattle',1);rng(2,87);call('NatureInitializeEnemy')
        wild=(game.memory[addr('wNatureIDs')+1],get('wNatureEnemySlot'));assert wild==(87,3)
        rng(4,99);call('NatureInitializeEnemy');assert state['index']==0
        assert (game.memory[addr('wNatureIDs')+1],get('wNatureEnemySlot'))==wild
        # Evolution's type refresh preserves both metadata fields.
        stored('wPartyMon1',137,4,22,3);put('wPartyMon1Species',ids['MAROWAK']);put('wd11e',ids['MAROWAK'])
        source('wPartyMon1');call('NatureRefreshEvolvedTypes')
        assert inspect('wPartyMon1')==(137,4) and get('wPartyMon1Type1')&31==4 and get('wPartyMon1Type2')&31==8
        # The NPC trade's OT/nickname copy cannot overwrite the new fields.
        put('wPartyCount',1);before=inspect('wPartyMon1');call('InGameTrade_CopyDataToReceivedMon');assert inspect('wPartyMon1')==before
        # Transform copies already-adjusted underlying stats, not nature identity.
        for n in ('PrintText','PrintButItFailedText_','PlayCurrentMoveAnimation','AnimationTransformMon',
                  'HideSubstituteShowMonAnim','ReshowSubstituteAnim','CustomPrintStatName'):
            patch(n,[0xc9])
        for turn in (0,1):
            put('turn',turn);put('wIsInBattle',1);put('wNatureMode',3);put('wOptions',0);put('wObtainedBadges',0);put('wUnusedC000',0)
            game.memory[addr('wNatureIDs'):addr('wNatureIDs')+2]=[0,7]
            game.memory[addr('wNatureStatSources'):addr('wNatureStatSources')+2]=[0,7]
            game.memory[addr('wActiveAbilities'):addr('wActiveAbilities')+2]=[2,9]
            ap,tp=('wEnemyMon','wBattleMon') if turn else ('wBattleMon','wEnemyMon')
            for side,prefix,party in (('Player','wBattleMon','wPartyMon1'),('Enemy','wEnemyMon','wEnemyMon1')):
                for i in (1,2,3):put('w'+side+'BattleStatus'+str(i),0)
                for i in range(6):game.memory[addr('w'+side+'MonStatMods')+i]=7
                put(prefix+'Species',ids['BULBASAUR'] if side=='Player' else ids['CHARMANDER'])
                put(prefix+'Level',50);put(prefix+'Status',0);word(prefix+'HP',100);word(prefix+'MaxHP',200)
                for i,stat in enumerate(('Attack','Defense','Speed','Special')):
                    value=220 if prefix==tp and stat=='Attack' else 100
                    word(prefix+stat,value);word(party+stat,50 if prefix==ap else value)
                    game.memory[addr('w'+side+'MonUnmodifiedAttack')+2*i:addr('w'+side+'MonUnmodifiedAttack')+2*i+2]=[value>>8,value&255]
                game.memory[addr(prefix+'Moves'):addr(prefix+'Moves')+4]=[MOVES['TACKLE'],MOVES['EMBER'],0,0]
                put('w'+side+'MovePower',40);put('w'+side+'MoveType',TYPES['NORMAL'])
            put('wPlayerMonNumber',0);put('wEnemyMonPartyPos',0)
            call('TransformEffect_');assert readword(ap+'Attack')==220,(turn,'copied nature stat')
            assert bytes(game.memory[addr('wNatureIDs'):addr('wNatureIDs')+2])==bytes([0,7])
            assert bytes(game.memory[addr('wActiveAbilities'):addr('wActiveAbilities')+2])==bytes([2,9])
            put('wCriticalHitOrOHKO',1)
            call('LegacyEnemyDamageVars' if turn else 'LegacyPlayerDamageVars')
            assert game.register_file.B==220,(turn,'transformed critical',game.register_file.B)
        # Healing preserves identity; unsupported external links cannot send records.
        stored('wPartyMon1',194,2);put('wPartyCount',1)
        game.memory[addr('wPartySpecies'):addr('wPartySpecies')+2]=[ids['BULBASAUR'],255]
        word('wPartyMon1HP',0);before=inspect('wPartyMon1');call('HealParty')
        assert inspect('wPartyMon1')==before and readword('wPartyMon1HP')==readword('wPartyMon1MaxHP')
        put('wLinkState',0);snapshot=bytes(game.memory[addr('wPartyMon1'):addr('wPartyMon1')+44])
        call('CableClubNPC');call('CableClub_DoBattleOrTrade')
        assert get('wLinkState')==0 and bytes(game.memory[addr('wPartyMon1'):addr('wPartyMon1')+44])==snapshot
        assert data('Serial_TryEstablishingExternallyClockedConnection',1)==bytes([0xc9])
        # Save block sizes/checksums remain native and both fields survive reload.
        stored('wPartyMon1',194,2)
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2');put('wPartyMon1CatchRate',0)
        call('LoadSAV0');call('LoadSAV2');assert inspect('wPartyMon1')==(194,2)
        assert addr('wPartyMon2')-addr('wPartyMon1')==44 and addr('wBoxMon2')-addr('wBoxMon1')==33
        print(f'{version}: 196 balanced definitions, 980 ID/slot combinations, multiplicative stats/probabilities, migration/HP, gifts/capture/PC/daycare/swaps/evolution/trade/healing/Transform, 196 descriptions, link guards and saves passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for v in ('pokered','pokeblue'):validate(v)
