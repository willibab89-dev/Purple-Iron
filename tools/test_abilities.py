#!/usr/bin/env python3
"""Starter ability engine, persistence, both battle sides and inspection panel."""
from collections import Counter
import os
from pyboy import PyBoy
from test_unique_species import ROOT,symbols,TYPES
from test_move_patch_3 import MOVES,constants


def validate(version):
    syms=symbols(ROOT/(version+'.sym'));ids=constants(ROOT/'constants/pokemon_constants.asm')
    game=PyBoy(str(ROOT/(version+'.gbc')),window='null',sound_emulated=False)
    game.set_emulation_speed(0);game.tick(90,False)
    def addr(n):return syms[n][1] if n!='turn' else 0xfff3
    def put(n,v):game.memory[addr(n)]=v
    def get(n):return game.memory[addr(n)]
    def word(n,v):game.memory[addr(n):addr(n)+2]=[v>>8,v&255]
    def readword(n):return get(n)*256+game.memory[addr(n)+1]
    def patch(n,code):
        b,a=syms[n];game.memory[b,a:a+len(code)]=code
    def call(n,**regs):
        b,a=syms[n];game.memory[0x2000]=game.memory[0xffb8]=b or 1
        game.memory[0,0x100:0x108]=[0xf3,0xcd,a&255,a>>8,0xc3,4,1,0]
        game.memory[0xffff]=game.memory[0xff0f]=0
        game.memory[0xdf22:0xdf42]=[0xa5]*32
        game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for k,v in regs.items():
            if k in ('BC','DE'):
                setattr(game.register_file,k[0],v>>8);setattr(game.register_file,k[1],v&255)
            else:setattr(game.register_file,k,v)
        for _ in range(150):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):
                assert bytes(game.memory[0xdf22:0xdf42])==bytes([0xa5]*32),('stack guard',n)
                return
        raise AssertionError((version,n,hex(game.register_file.PC),hex(game.register_file.SP)))
    state={'values':[0],'index':0}
    def rng(*v):state.update(values=list(v),index=0)
    def on_rng(s):
        i=s['index'];game.register_file.A=s['values'][min(i,len(s['values'])-1)];s['index']+=1
    for n in ('Random','BattleRandom'):
        patch(n,[0xc9]);b,a=syms[n];game.hook_register(b,a,on_rng,state)
    for n in ('PrintText','CustomPrintStatName','DrawHUDsAndHPBars'):
        patch(n,[0xc9])
    def init(turn=0):
        call('AbilityResetBattle');put('turn',turn);put('wLinkState',0);put('wIsInBattle',2)
        put('wPlayerMonNumber',0);put('wWhichPokemon',0);put('wEnemyMonPartyPos',0)
        put('wUnusedC000',0);put('wCustomTargetHadSub',0);put('wCriticalHitOrOHKO',0)
        put('wOptions',0);put('wObtainedBadges',0)
        for side,prefix,party in (('Player','wBattleMon','wPartyMon1'),('Enemy','wEnemyMon','wEnemyMon1')):
            for n in ('HP','MaxHP','Attack','Defense','Speed','Special'):
                word(prefix+n,160 if n in ('HP','MaxHP') else 100);word(party+n,160 if n in ('HP','MaxHP') else 100)
            for i in (1,2,3):put('w'+side+'BattleStatus'+str(i),0)
            for n in ('Status',):put(prefix+n,0);put(party+n,0)
            for i in range(6):game.memory[addr('w'+side+'MonStatMods')+i]=7
            for i in range(4):game.memory[addr('w'+side+'MonUnmodifiedAttack')+2*i:addr('w'+side+'MonUnmodifiedAttack')+2*i+2]=[0,100]
            put('w'+side+'MovePower',40);put('w'+side+'MoveType',TYPES['NORMAL']);put('w'+side+'MoveNum',MOVES['TACKLE'])
        put('wBattleMonType1',0);put('wBattleMonType2',0);put('wEnemyMonType1',0);put('wEnemyMonType2',0)
        word('wDamage',40);put('wDamageMultipliers',10);put('wMoveMissed',0);rng(0)
        return ('wEnemyMon','wBattleMon') if turn else ('wBattleMon','wEnemyMon')
    def ability(side,id):game.memory[addr('wActiveAbilities')+side]=id
    try:
        # Exact equal buckets and rejection at 255.
        counts=Counter()
        for n in range(255):
            rng(n);call('AbilityRollSlot');counts[game.register_file.A]+=1
        assert counts=={n:51 for n in range(249,254)},counts
        rng(255,4);call('AbilityRollSlot');assert game.register_file.A==253 and state['index']==2
        # Saved slot survives species changes; unrelated species are untouched.
        for slot in range(5):
            for species,base in [('BULBASAUR',1),('IVYSAUR',1),('VENUSAUR',1),('CHARMANDER',6),('CHARMELEON',6),('CHARIZARD',6)]:
                put('wPartyMon1Species',ids[species]);put('wPartyMon1CatchRate',249+slot)
                call('AbilityEnsureMon',HL=addr('wPartyMon1'));assert game.register_file.A==base+slot
                assert get('wPartyMon1CatchRate')==249+slot
        put('wPartyMon1Species',ids['SQUIRTLE']);put('wPartyMon1CatchRate',45)
        call('AbilityEnsureMon',HL=addr('wPartyMon1'));assert game.register_file.A==0 and get('wPartyMon1CatchRate')==45
        put('wPartyMon1Species',ids['BULBASAUR']);rng(3)
        call('AbilityEnsureMon',HL=addr('wPartyMon1'));assert get('wPartyMon1CatchRate')==252
        # Player load resolves original party identity, including after Transform.
        put('wWhichPokemon',0);put('wLinkState',0);call('AbilityLoadPlayer');assert get('wActiveAbilities')==4
        put('wBattleMonSpecies',ids['CHARIZARD']);assert get('wActiveAbilities')==4
        # Trainer load resolves its own party tag; no reroll on switching.
        put('wEnemyMon1Species',ids['CHARMANDER']);put('wEnemyMon1CatchRate',251);put('wIsInBattle',2);put('wEnemyMonPartyPos',0)
        put('wAbilityTemp',45);call('AbilityLoadEnemy');assert get('wAbilityTemp')==251 and game.memory[addr('wActiveAbilities')+1]==8
        for turn in (0,1):
            # Dynamic damage: no stage replacement, correct types/full HP/thresholds.
            ap,tp=init(turn)
            for id,typ,hp,expected in [(3,'GRASS',160,125),(3,'GRASS',159,100),(3,'NORMAL',160,100),
                                      (5,'NORMAL',160,120),(5,'GRASS',160,100),(6,'FIRE',53,125),(6,'FIRE',54,100)]:
                ability(turn,id);put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES[typ]);word(ap+'HP',hp);word('wDamage',100)
                call('AbilityDamageBoost');assert readword('wDamage')==expected,(id,typ,hp,readword('wDamage'))
            put('wUnusedC000',16);word('wDamage',100);call('AbilityDamageBoost');assert readword('wDamage')==100
            # Grass poison and non-Fire burn chances with exact RNG boundaries.
            for id,typ,status,threshold in [(1,'GRASS',8,64),(7,'NORMAL',16,38)]:
                for value,want in [(0,status),(threshold-1,status),(threshold,0),(255,0)]:
                    ap,tp=init(turn);ability(turn,id);put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES[typ]);rng(value)
                    call('AbilityAfterHit');assert get(tp+'Status')==want,(id,value,get(tp+'Status'))
                for block in ('sub','status','immune','fainted'):
                    ap,tp=init(turn);ability(turn,id);put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES[typ])
                    if block=='sub':put('wCustomTargetHadSub',1)
                    if block=='status':put(tp+'Status',64)
                    if block=='immune':put(tp+'Type1',TYPES['POISON' if status==8 else 'FIRE'])
                    if block=='fainted':word(tp+'HP',0)
                    call('AbilityAfterHit');assert get(tp+'Status')==(64 if block=='status' else 0),(id,block)
            # Once per battle, not once per entry; physical damage only, no Substitute.
            ap,tp=init(turn);ability(1-turn,9);call('AbilityAfterHit')
            mod='w'+('Player' if turn else 'Enemy')+'MonSpecialMod'
            assert get(mod)==8,(turn,'Hot Temper',get(mod))
            call('AbilityAfterHit');assert get(mod)==8
            assert game.memory[addr('wAbilityFlags')+(0 if turn else 6)]&1
            # Wildfire sees a newly inflicted burn, not an already burned target.
            ap,tp=init(turn);ability(turn,8);call('AbilityBeforeAction');put(tp+'Status',16);call('AbilityAfterAction')
            mod='w'+('Enemy' if turn else 'Player')+'MonAttackMod';assert get(mod)==8
            call('AbilityBeforeAction');call('AbilityAfterAction');assert get(mod)==8
            # Confident only once, accuracy misses not type immunity.
            ap,tp=init(turn);ability(turn,10);call('AbilityBeforeAction');put('wMoveMissed',1);call('AbilityAfterAction')
            mod='w'+('Enemy' if turn else 'Player')+'MonAccuracyMod';assert get(mod)==8
            call('AbilityAfterAction');assert get(mod)==8
            # Photosynthesis >half, capped at max, no resurrection or duplicate tick.
            for hp,want in [(0,0),(79,79),(80,80),(81,91),(155,160),(160,160)]:
                ap,tp=init(turn);ability(turn,4);word(ap+'HP',hp);put('wResidualRoundDone',0)
                call('AbilityEndRound');assert readword(ap+'HP')==want,(turn,hp,readword(ap+'HP'))
            # Conditional speed turns off after healing and never compounds.
            ap,tp=init(turn);ability(turn,2);word(ap+'HP',53)
            call('AbilityPrepareSpeeds');n='wAbilityEnemySpeed' if turn else 'wAbilityPlayerSpeed';assert readword(n)==150
            call('AbilityPrepareSpeeds');assert readword(n)==150 and readword(ap+'Speed')==100
            word(ap+'HP',54);call('AbilityPrepareSpeeds');assert readword(n)==100
        # Actual move execution exercises the inserted hooks, not only helpers.
        for n in ('PrintText','PrintMonName1Text','PlayMoveAnimation','PlayCurrentMoveAnimation',
                  'PlayCurrentMoveAnimation2','PrintCriticalOHKOText','DisplayEffectiveness',
                  'CriticalHitTest','RandomizeDamage','DelayFrames','Delay3','Func_78e98',
                  'DrawPlayerHUDAndHPBar','DrawEnemyHUDAndHPBar','UpdateHPBar2','MoveAnimation',
                  'HideSubstituteShowMonAnim','ReshowSubstituteAnim'):
            patch(n,[0xc9])
        def execute(move,turn,id=0,target_id=0,r=0):
            ap,tp=init(turn)
            put('wActionResultOrTookBattleTurn',0);put('wMonIsDisobedient',0)
            for side in ('Player','Enemy'):
                put('w'+side+'SelectedMove',MOVES[move]);put('w'+side+'MoveListIndex',0)
                put('w'+side+'DisabledMove',0);put('w'+side+'DisabledMoveNumber',0)
                put('w'+side+'NumAttacksLeft',0);put('w'+side+'NumHits',0)
            for pref in ('wBattleMon','wPartyMon1','wEnemyMon','wEnemyMon1'):
                put(pref+'Species',ids['BULBASAUR'] if pref in ('wBattleMon','wPartyMon1') else ids['CHARMANDER'])
                put(pref+'Level',50);put(pref+'PP',20);put(pref+'Moves',MOVES[move])
            ability(turn,id);ability(1-turn,target_id);rng(r)
            call('ExecuteEnemyMove' if turn else 'ExecutePlayerMove')
            return ap,tp
        for turn in (0,1):
            ap,tp=execute('VINE_WHIP',turn);normal=160-readword(tp+'HP')
            ap,tp=execute('VINE_WHIP',turn,3);boosted=160-readword(tp+'HP')
            assert boosted>normal>0,('live damage',turn,normal,boosted)
            ap,tp=execute('VINE_WHIP',turn,1);assert get(tp+'Status')==8,('live poison',turn)
            ap,tp=execute('TACKLE',turn,7);assert get(tp+'Status')==16,('live combustion',turn)
            ap,tp=execute('EMBER',turn,8);assert get(tp+'Status')==16
            assert get('w'+('Enemy' if turn else 'Player')+'MonAttackMod')==8,('live Wildfire',turn)
            ap,tp=execute('TACKLE',turn,0,9)
            assert get('w'+('Player' if turn else 'Enemy')+'MonSpecialMod')==8,('live Hot Temper',turn)
            ap,tp=execute('TACKLE',turn,10,r=255)
            assert get('w'+('Enemy' if turn else 'Player')+'MonAccuracyMod')==8,('live Confident',turn)
        # New gifts use the real party-generation entry; the rival has Charmander.
        put('wPartyCount',0);put('wMonDataLocation',0x80);put('wIsInBattle',0)
        put('wCurEnemyLVL',5);put('wcf91',ids['BULBASAUR']);rng(2)
        call('AddPartyMon');assert get('wPartyMon1Species')==ids['BULBASAUR'] and get('wPartyMon1CatchRate')==251
        put('wWhichPokemon',0);put('wPlayerMonNumber',0);put('wBattleMonSpecies2',ids['BULBASAUR'])
        call('LoadBattleMonFromParty');assert get('wActiveAbilities')==3
        from test_reviewed_trainers import TRAINERS
        put('wLinkState',0);put('wIsInBattle',2);put('wTrainerClass',TRAINERS['SONY1']);put('wTrainerNo',3)
        call('ReadTrainer');assert get('wEnemyMon1Species')==ids['CHARMANDER']
        assert 249<=get('wEnemyMon1CatchRate')<=253
        put('wWhichPokemon',0);put('wEnemyMonPartyPos',0);put('wEnemyMonSpecies2',ids['CHARMANDER']);put('wCurEnemyLVL',5)
        for n in ('wEnemyBattleStatus3','wFontLoaded','wOptions'):put(n,0)
        call('LoadEnemyMonData');assert 6<=game.memory[addr('wActiveAbilities')+1]<=10
        # Ability panel shows both IDs, closes without spending a turn, and restores tiles.
        patch('DelayFrame',[0xc9])
        patch('JoypadLowSensitivity',[0xc9]);b,a=syms['JoypadLowSensitivity']
        keys={'index':0};pages=[];snapshots=[]
        def panel_keys(state):
            i=state['index'];state['index']+=1
            game.memory[0xffb5]=16 if i==0 else 2
            pages.append(get('wAbilityPanelSide'))
            snapshots.append(bytes(game.memory[addr('wTileMap'):addr('wTileMap')+360]))
        game.hook_register(b,a,panel_keys,keys)
        before=bytes(game.memory[addr('wTileMap'):addr('wTileMap')+360])
        call('AbilityPanel');assert pages==[0,1],pages
        assert bytes(game.memory[addr('wTileMap'):addr('wTileMap')+360])==before
        assert get('wActionResultOrTookBattleTurn')==0
        game.hook_deregister(b,a)
        # Outside battle, inspect the selected party member rather than the active one.
        put('wWhichPokemon',1);put('wPartyMon2Species',ids['CHARMANDER']);put('wPartyMon2CatchRate',253)
        def encoded(text):return bytes(0x80+ord(c)-ord('A') for c in text)+bytes([0x50])
        nick=encoded('CHARMANDER')
        game.memory[addr('wPartyMonNicks')+11:addr('wPartyMonNicks')+11+len(nick)]=nick
        active=bytes(game.memory[addr('wActiveAbilities'):addr('wActiveAbilities')+2])
        saved_map=bytes(game.memory[addr('wTileMap'):addr('wTileMap')+360])
        game.memory[addr('wTileMapBackup2'):addr('wTileMapBackup2')+360]=[0x66]*360
        party_snapshots=[]
        def party_keys(state):
            party_snapshots.append(bytes(game.memory[addr('wTileMap'):addr('wTileMap')+360]))
            game.memory[0xffb5]=state['key']
        for key in (1,2,4):
            game.hook_register(b,a,party_keys,{'key':key})
            call('PartyAbilityPanel');game.hook_deregister(b,a)
            assert get('wWhichPokemon')==1 and get('wAbilityID')==10
            assert bytes(game.memory[addr('wActiveAbilities'):addr('wActiveAbilities')+2])==active
            assert bytes(game.memory[addr('wTileMap'):addr('wTileMap')+360])==saved_map
            assert bytes(game.memory[addr('wTileMapBackup2'):addr('wTileMapBackup2')+360])==bytes([0x66]*360)
        assert party_snapshots[0][42:42+len(nick)-1]==nick[:-1]
        # Render zero through four field moves. ABILITY must fit inside the box,
        # and every menu action/field move keeps its two-row cursor spacing.
        patch('UpdateSprites',[0xc9]);menus=[]
        for count in range(5):
            put('wWhichPokemon',1)
            moves=[MOVES[m] for m in ('CUT','SURF','STRENGTH','SOFTBOILED')][:count]
            game.memory[addr('wPartyMon2Moves'):addr('wPartyMon2Moves')+4]=moves+[MOVES['TACKLE']]*(4-count)
            game.memory[addr('wTileMap'):addr('wTileMap')+360]=[0x7f]*360
            call('DisplayFieldMoveMonMenu')
            tiles=bytes(game.memory[addr('wTileMap'):addr('wTileMap')+360]);menus.append(tiles)
            x=game.memory[0xfff7]+1
            for row,text in ((10,'STATS'),(12,'SWITCH'),(14,'ABILITY'),(16,'CANCEL')):
                assert tiles[row*20+x:row*20+x+len(text)]==encoded(text)[:-1],(count,row,x)
            assert 10-2*count>=2 and 3+count<=7
        snapshots.extend([party_snapshots[0],menus[0],menus[4]])
        # Exercise the real action dispatcher with each possible field-move count.
        for n in ('DisplayPartyMenu','DisplayTextBoxID','GBPalWhiteOutWithDelay3',
                  'RestoreScreenTilesAndReloadTilePatterns','LoadGBPal','RedisplayStartMenu'):
            patch(n,[0xc9])
        patch('GoBackToPartyMenu',[0x37,0xc9])
        patch('HandleMenuInput',[0xc9]);mb,ma=syms['HandleMenuInput']
        choice={'index':0}
        def choose(s):
            put('wCurrentMenuItem',s['index']);game.register_file.A=1
        game.hook_register(mb,ma,choose,choice)
        seen=[]
        # This RGBDS version omits labels referenced only by relative jumps.
        bank,start=syms['StartMenu_Pokemon']
        raw=bytes(game.memory[bank,start:start+180])
        jumps=[i for i in range(len(raw)-3) if raw[i:i+3]==bytes([5,0xb8,0x28])]
        assert len(jumps)==2
        for label,i in zip(('choseAbility','choseSwitch'),jumps):
            offset=raw[i+3] if raw[i+3]<128 else raw[i+3]-256
            syms['StartMenu_Pokemon.'+label]=(bank,start+i+4+offset)
        labels=('choseStats','choseSwitch','choseAbility','choseOutOfBattleMove')
        for label in labels:
            full='StartMenu_Pokemon.'+label
            if label!='choseAbility':patch(full,[0xc9])
            bank,pos=syms[full]
            game.hook_register(bank,pos,lambda label:seen.append(label),label)
        game.hook_register(b,a,party_keys,{'key':2})
        put('wPartyCount',2)
        for count in range(5):
            put('wWhichPokemon',1)
            game.memory[addr('wFieldMoves'):addr('wFieldMoves')+4]=list(range(1,count+1))+[0]*(4-count)
            for offset,label in ((0,'choseStats'),(1,'choseSwitch'),(2,'choseAbility')):
                seen.clear();choice['index']=count+offset;call('StartMenu_Pokemon')
                assert seen==[label],(count,offset,seen)
            for index in range(count):
                seen.clear();choice['index']=index;call('StartMenu_Pokemon')
                assert seen==['choseOutOfBattleMove'],(count,index,seen)
            seen.clear();choice['index']=count+3;call('StartMenu_Pokemon');assert not seen
        game.hook_deregister(b,a);game.hook_deregister(mb,ma)
        # Ordinary save routines retain the tag without changing party layouts.
        put('wPartyMon1Species',ids['BULBASAUR']);put('wPartyMon1CatchRate',253)
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2');put('wPartyMon1CatchRate',45)
        call('LoadSAV0');call('LoadSAV2');assert get('wPartyMon1CatchRate')==253
        assert addr('wPartyMon2')-addr('wPartyMon1')==44
        if os.environ.get('ABILITY_SCREENSHOTS') and version=='pokered':
            from pathlib import Path
            out=Path(os.environ['ABILITY_SCREENSHOTS']);out.mkdir(parents=True,exist_ok=True)
            game.memory[0xff40]=0
            call('LoadFontTilePatterns');call('LoadTextBoxTilePatterns')
            for label,tiles in zip(('player','enemy','party','party-menu','party-menu-four-field-moves'),snapshots):
                game.memory[0xff40]=0
                for row in range(18):game.memory[0x9800+32*row:0x9800+32*row+20]=tiles[row*20:row*20+20]
                game.memory[0xff4f]=1;game.memory[0x9800:0x9c00]=[0]*1024;game.memory[0xff4f]=0
                game.memory[0xff68]=0x80
                for c in [255,127,181,86,74,41,0,0]:game.memory[0xff69]=c
                game.memory[0xff47]=0xe4;game.memory[0xff42]=game.memory[0xff43]=0
                game.memory[0xff40]=0x81;game.tick(3,True)
                game.screen.image.save(out/f'ability-panel-{label}.png')
        print(f'{version}: ten abilities, both sides, weighted-slot foundation, thresholds, immunities, once-per-battle flags, speed, healing, party identity, party action menu/selected ability/field-move layout/screen restoration and save passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
