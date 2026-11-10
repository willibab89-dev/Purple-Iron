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
        game.memory[0xdf42:0xdf62]=[0xa5]*32
        game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for k,v in regs.items():
            if k in ('BC','DE'):
                setattr(game.register_file,k[0],v>>8);setattr(game.register_file,k[1],v&255)
            else:setattr(game.register_file,k,v)
        for _ in range(150):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):
                assert bytes(game.memory[0xdf42:0xdf62])==bytes([0xa5]*32),('stack guard',n)
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
    import re
    from generate_ability_moves import render,CONTACT
    ab={n:int(v) for n,v in re.findall(r'^AB_(\w+) EQU (\d+)',(ROOT/'constants/ability_constants.asm').read_text(),re.M)}
    def aid(side,name):ability(side,ab[name] if name else 0)
    def move(side,name):
        b,a=syms['Moves'];m=MOVES[name];record=bytes(game.memory[b,a+(m-1)*6:a+m*6]);prefix='wEnemy' if side else 'wPlayer'
        put(prefix+'MoveNum',m);put(prefix+'SelectedMove',m)
        for n,v in zip(('Effect','Power','Type','Accuracy'),record[1:5]):put(prefix+'Move'+n,v)
        put(prefix+'MoveListIndex',0)
    def source(root):word('wNatureInputHL',addr(root))
    def metadata(root,species,slot,nature=0):
        put(root+'Species',ids[species]);put(root+'Type1',slot<<5);put(root+'Type2',224);put(root+'CatchRate',nature)
    try:
        assert (ROOT/'data/ability_move_metadata.asm').read_text()==render()
        # All five evolution slots, including noncontiguous ability IDs.
        pools={'BULBASAUR':['POISON_LEAF','CHLOROPHYLL','OVERGROWTH','PHOTOSYNTHESIS','VINE_GUARD'],
               'CHARMANDER':['BLAZE','COMBUSTION','WILDFIRE','HOT_TEMPER','CONFIDENT'],
               'SQUIRTLE':['WATER_PRESSURE','SHELL_GUARD','ANCIENT','WATER_VEIL','SHELL_ARMOR'],
               'CATERPIE':['RUN_AWAY','REPULSIVE','SURVIVAL_INSTINCTS','QUICK_REFLEXES','SHIELD_DUST'],
               'METAPOD':['HARD_SHELL','FORTIFY','REGENERATION','QUICK_REFLEXES','BATTLE_ARMOR'],
               'BUTTERFREE':['COMPOUND_EYES','PSIONIC','DUST_CLOUD','QUICK_REFLEXES','WONDER_SKIN'],
               'WEEDLE':['POISON_POINT','REPULSIVE','VENOMOUS','PIERCING_STING','SHIELD_DUST'],
               'KAKUNA':['HARD_SHELL','FORTIFY','TOXIC_SHELL','PIERCING_STING','BATTLE_ARMOR'],
               'BEEDRILL':['RUTHLESS','FRENZY','VENOMOUS','PIERCING_STING','QUICK_REFLEXES']}
        for stages,root in [(('IVYSAUR','VENUSAUR'),'BULBASAUR'),(('CHARMELEON','CHARIZARD'),'CHARMANDER'),(('WARTORTLE','BLASTOISE'),'SQUIRTLE')]:
            for s in stages:pools[s]=pools[root]
        for species,pool in pools.items():
            for slot,name in enumerate(pool,1):
                metadata('wPartyMon1',species,slot,17);call('AbilityEnsureMon',HL=addr('wPartyMon1'))
                assert game.register_file.A==ab[name],(species,slot,name,game.register_file.A)
                assert get('wPartyMon1CatchRate')==17
                put('wEnemyMonSpecies2',ids[species]);put('wNatureEnemySlot',slot);game.memory[addr('wNatureIDs')+1]=17
                call('AbilityLoadEnemy');assert game.memory[addr('wActiveAbilities')+1]==ab[name]
        for turn in (0,1):
            for attack,defend,typ,status,pp,want in [
                ('WATER_PRESSURE',None,'WATER',0,0,100),('WATER_PRESSURE',None,'WATER',0,15,130),('WATER_PRESSURE',None,'WATER',0,40,150),
                ('PSIONIC',None,'PSYCHIC',0,5,120),('VENOMOUS',None,'NORMAL',8,5,125),('VENOMOUS',None,'NORMAL',0,5,100),
                (None,'VINE_GUARD','FLYING',0,5,50),(None,'VINE_GUARD','NORMAL',0,5,100),
                (None,'WATER_VEIL','FIRE',0,5,50),(None,'HARD_SHELL','NORMAL',0,5,75),(None,'HARD_SHELL','FIRE',0,5,100)]:
                ap,tp=init(turn);aid(turn,attack);aid(1-turn,defend);put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES[typ]);put(tp+'Status',status);put('wAbilityPPLeft',pp);word('wDamage',100)
                call('AbilityDamageBoost');assert readword('wDamage')==want,(turn,attack,defend,readword('wDamage'))
            # Poison/Bug override is a single extra type-chart factor.
            ap,tp=init(turn);aid(turn,'PIERCING_STING');put(tp+'Type1',TYPES['BUG']);put(tp+'Type2',TYPES['GRASS']);put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES['POISON']);word('wDamage',100)
            call('AbilityDamageBoost');assert readword('wDamage')==200 and get('wDamageMultipliers')==20
            # Crit blockers run before guaranteed crit checks; Ruthless doubles final odds.
            for name in ('SHELL_ARMOR','BATTLE_ARMOR'):
                init(turn);aid(1-turn,name);call('NatureCriticalHitTest');assert get('wCriticalHitOrOHKO')==0
            ap,tp=init(turn);aid(turn,'RUTHLESS');put(tp+'Status',8);put('wNatureResult',150);call('AbilityRuthless');assert get('wNatureResult')==255
            for attack,status in [('SHOCK_WAVE',64),('POISON_TAIL',8)]:
                ap,tp=init(turn);move(turn,attack);put(tp+'Status',status);rng(199);call('NatureCriticalHitTest');assert get('wCriticalHitOrOHKO')==1
                for armor in ('SHELL_ARMOR','BATTLE_ARMOR'):
                    aid(1-turn,armor);call('NatureCriticalHitTest');assert get('wCriticalHitOrOHKO')==0
            # Contact reactions distinguish Tackle from Earthquake; once per move.
            for name in ('POISON_POINT','TOXIC_SHELL'):
                for attack,want in [('TACKLE',8),('EARTHQUAKE',0)]:
                    ap,tp=init(turn);move(turn,attack);aid(1-turn,name);rng(0);call('AbilityAfterHit');assert get(ap+'Status')==want,(name,attack,get(ap+'Status'))
                    if want:assert not(get('w'+('Enemy' if turn else 'Player')+'BattleStatus3')&1)
            ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'DUST_CLOUD');rng(0);call('AbilityAfterHit')
            mod='w'+('Enemy' if turn else 'Player')+'MonAccuracyMod';assert get(mod)==6
            call('AbilityAfterHit');assert get(mod)==6
            ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'POISON_POINT');put(ap+'Status',8)
            actor_flags='w'+('Enemy' if turn else 'Player')+'BattleStatus3';put(actor_flags,1);call('AbilityAfterHit');assert get(actor_flags)&1
            # Low-HP stage triggers and switch persistence, strict one-third boundary.
            for name,stat in [('FORTIFY','Defense'),('SURVIVAL_INSTINCTS','Speed')]:
                ap,tp=init(turn);aid(turn,name);word(ap+'HP',54);call('AbilityLowHPBoth');mod='w'+('Enemy' if turn else 'Player')+'Mon'+stat+'Mod';assert get(mod)==7
                word(ap+'HP',53);call('AbilityLowHPBoth');assert get(mod)==8
                call('AbilityLowHPBoth');assert get(mod)==8
                put('wAbilitySide',turn);call('AbilityEntry');assert get(mod)==8
            # Regeneration works below half HP, never revives, caps at maximum.
            ap,tp=init(turn);aid(turn,'REGENERATION');put('wResidualRoundDone',0)
            for hp,want in [(0,0),(1,11),(80,90),(159,160),(160,160)]:
                word(ap+'HP',hp);call('AbilityEndRound');assert readword(ap+'HP')==want,(turn,'regen',hp,readword(ap+'HP'))
            # Shell Guard procs once for one critical multi-hit action.
            ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'SHELL_GUARD');put('wCriticalHitOrOHKO',1);call('AbilityAfterHit')
            mod='w'+('Player' if turn else 'Enemy')+'MonDefenseMod';assert get(mod)==8
            call('AbilityAfterHit');assert get(mod)==9
            # Frenzy counts a direct KO but not residual fainting or an existing faint.
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'FRENZY');word(tp+'HP',0);call('AbilityAfterHit');call('AbilityAfterAction')
            mod='w'+('Enemy' if turn else 'Player')+'MonAttackMod';assert get(mod)==8
            ap,tp=init(turn);aid(turn,'FRENZY');word(tp+'HP',0);call('AbilityAfterAction');assert get(mod)==7
            # Secondary-effect gates keep primary/multi-hit/draining mechanics.
            for attack,blocked in [('SLUDGE',True),('VINE_WHIP',True),('FLASH',True),('SCALD',True),('TWINEEDLE',False),('DOUBLESLAP',False),('DRAIN_PUNCH',False),('BRICK_BREAK',False),('TOXIC',False)]:
                init(turn);move(turn,attack);aid(1-turn,'SHIELD_DUST');call('AbilityEffectGate');assert bool(get('wAbilityCheckResult'))==blocked,(attack,get('wAbilityCheckResult'))
            # Shield Dust also blocks ability-granted added poison/burn/flinch.
            ap,tp=init(turn);move(turn,'VINE_WHIP');aid(turn,'POISON_LEAF');aid(1-turn,'SHIELD_DUST');rng(0);call('AbilityAfterHit');assert get(tp+'Status')==0
            # Direct and secondary burns are blocked by the Water Veil status gate.
            ap,tp=init(turn);aid(1-turn,'WATER_VEIL');put('wCustomSide',1-turn);put('wCustomDelta',16);call('UtilityInflictStatus');assert get(tp+'Status')==0
            # Accuracy effects, including simultaneous Compound Eyes / Wonder Skin.
            for actor,target,attack,want in [('COMPOUND_EYES',None,'SLEEP_POWDER',130),(None,'WONDER_SKIN','SLEEP_POWDER',50),('COMPOUND_EYES','WONDER_SKIN','SLEEP_POWDER',65),(None,'WONDER_SKIN','TACKLE',100)]:
                init(turn);move(turn,attack);aid(turn,actor);aid(1-turn,target);game.memory[0xff97:0xff99]=[0,100]
                call('AbilityAccuracy');assert bytes(game.memory[0xff97:0xff99])==bytes([0,want]),(actor,target,attack,bytes(game.memory[0xff97:0xff99]))
        # Exact 10%, 15%, 25% rolls, including high-byte rejection.
        for percent in (10,15,25):
            success=0
            for value in range(200):rng(value);call('AbilityRoll',BC=percent<<8);success+=bool(game.register_file.F&16)
            assert success==2*percent
            rng(255,200,0);call('AbilityRoll',BC=percent<<8);assert game.register_file.F&16 and state['index']==3
        # Priority includes +2 versus +1 and Counter's -1 becoming 0.
        for player,enemy,quick_side,want in [('TACKLE','QUICK_ATTACK',0,0),('QUICK_ATTACK','QUICK_ATTACK',0,1),('COUNTER','TACKLE',0,0),('TACKLE','COUNTER',1,0),('GROWL','TACKLE',0,0),('TACKLE','TACKLE',1,2)]:
            init();move(0,player);move(1,enemy);aid(quick_side,'QUICK_REFLEXES');call('AbilityPriority');assert get('wAbilityCheckResult')==want,(player,enemy,quick_side,get('wAbilityCheckResult'))
        init();move(0,'TACKLE');move(1,'TACKLE');aid(0,'QUICK_REFLEXES');call('AbilityPriority');assert get('wAbilityCheckResult')==1
        call('AbilityAttempt');call('AbilityPriority');assert get('wAbilityCheckResult')==0
        put('wAbilitySide',0);call('AbilityEntry');call('AbilityPriority');assert get('wAbilityCheckResult')==1
        for hp,quick,want in [(79,False,0),(80,False,2),(79,True,1),(80,True,0)]:
            init();move(0,'AMBUSH');move(1,'QUICK_ATTACK');word('wEnemyMonHP',hp)
            if quick:aid(0,'QUICK_REFLEXES')
            call('AbilityPriority');assert get('wAbilityCheckResult')==want,('Ambush priority',hp,quick)
        for invalid in (0,237,255):
            call('AbilityMoveFlags',A=invalid);assert game.register_file.A==0
        # All 34 descriptions render without changing the active ability IDs.
        game.memory[0xff40]=0
        for n in range(1,35):
            active=bytes(game.memory[addr('wActiveAbilities'):addr('wActiveAbilities')+2]);game.memory[addr('wTileMap'):addr('wTileMap')+360]=[0x7f]*360;call('AbilityDrawDescription',A=n)
            assert bytes(game.memory[addr('wActiveAbilities'):addr('wActiveAbilities')+2])==active
            assert game.memory[addr('wTileMap')+4*20+2]!=0x7f,n
        # AI avoids selecting a guaranteed-failing Will-O-Wisp against Water Veil.
        init();move(1,'WILL_O_WISP');aid(0,'WATER_VEIL');call('UtilityAIStatusScore');assert get('wCustomRandomValue')==1
        # Ancient is persistent stat scaling; nature remains independent.
        for species in ('SQUIRTLE','WARTORTLE','BLASTOISE'):
            for nature in (0,33,195):
                root='wPartyMon1';game.memory[addr(root):addr(root)+44]=[0]*44;metadata(root,species,1,nature);put(root+'Level',50);word(root+'HP',100);word(root+'MaxHP',100);word('wNatureMonPtr',addr(root));call('NatureMigrateOne');base=readword(root+'MaxHP')
                metadata(root,species,3,nature);call('NatureMigrateOne');assert readword(root+'MaxHP')==base*120//100,(species,nature,base,readword(root+'MaxHP'))
                expected=readword(root+'MaxHP');word(root+'HP',expected-20);call('NatureMigrateOne');assert readword(root+'HP')==expected-20
                word(root+'HP',0);call('NatureMigrateOne');assert readword(root+'HP')==0
                # Capsule leaving Ancient removes HP bonus without reviving or changing nature.
                rng(0);call('AbilityCapsuleApply');assert readword(root+'MaxHP')==base and readword(root+'HP')==0 and get(root+'CatchRate')==nature
        # Native wild creation and capture agree on Ancient's maximum HP.
        maxima=[]
        for slot in (1,3):
            put('wEnemyMonSpecies2',ids['SQUIRTLE']);put('wCurEnemyLVL',20);put('wIsInBattle',1);put('wNatureMode',2);put('wNatureEnemySlot',slot)
            game.memory[addr('wNatureIDs')+1]=0;game.memory[addr('wNatureStatSources')+1]=0;rng(0)
            call('LoadEnemyMonData');maxima.append(readword('wEnemyMonMaxHP'))
        assert maxima[1]==maxima[0]*120//100,('wild Ancient',maxima)
        put('wPartyCount',0);put('wMonDataLocation',0x80);put('wcf91',ids['SQUIRTLE']);put('wCurEnemyLVL',20);call('AddPartyMon')
        assert get('wPartyMon1Type1')>>5==3 and readword('wPartyMon1MaxHP')==maxima[1]
        # Actual PC and daycare round trips preserve Ancient without stacking HP.
        put('wPartyCount',0);put('wMonDataLocation',0x80);put('wIsInBattle',0);put('wCurEnemyLVL',20);put('wcf91',ids['SQUIRTLE']);rng(2,0,0,0)
        call('AddPartyMon');assert get('wPartyMon1Type1')>>5==3
        maximum=readword('wPartyMon1MaxHP');word('wPartyMon1HP',maximum-10)
        put('wNumInBox',0);put('wWhichPokemon',0);put('wMoveMonType',1);call('MoveMon')
        assert get('wBoxMon1Type1')>>5==3
        put('wRemoveMonFromBox',0);call('RemovePokemon');assert get('wPartyCount')==0
        put('wMoveMonType',0);put('wWhichPokemon',0);put('wcf91',ids['SQUIRTLE']);call('MoveMon')
        assert readword('wPartyMon1MaxHP')==maximum and readword('wPartyMon1HP')==maximum-10
        put('wRemoveMonFromBox',1);call('RemovePokemon')
        put('wMoveMonType',3);put('wWhichPokemon',0);put('wcf91',ids['SQUIRTLE']);call('MoveMon')
        assert get('wDayCareMonType1')>>5==3
        put('wRemoveMonFromBox',0);call('RemovePokemon');put('wDayCareInUse',1)
        put('wMoveMonType',2);put('wWhichPokemon',0);put('wcf91',ids['SQUIRTLE']);call('MoveMon')
        assert get('wPartyMon1Type1')>>5==3 and readword('wPartyMon1MaxHP')==maximum
        before=bytes(game.memory[addr('wPartyMon1'):addr('wPartyMon1')+44])
        call('SaveSAVtoSRAM0');call('SaveSAVtoSRAM2');game.memory[addr('wPartyMon1'):addr('wPartyMon1')+44]=[0]*44
        call('LoadSAV0');call('LoadSAV2');assert bytes(game.memory[addr('wPartyMon1'):addr('wPartyMon1')+44])==before
        # Execute complete native move flows; only presentation is stubbed.
        for n in ('PrintText','PrintMonName1Text','PlayMoveAnimation','PlayCurrentMoveAnimation',
                  'PlayCurrentMoveAnimation2','PrintCriticalOHKOText','DisplayEffectiveness',
                  'RandomizeDamage','DelayFrames','Delay3','Func_78e98','PlayBattleAnimation',
                  'DrawPlayerHUDAndHPBar','DrawEnemyHUDAndHPBar','UpdateHPBar2','MoveAnimation',
                  'HideSubstituteShowMonAnim','ReshowSubstituteAnim','DrawHUDsAndHPBars'):
            patch(n,[0xc9])
        def execute(attack,turn,actor=None,target=None,pp=20,status=0,hp=160):
            ap,tp=init(turn)
            put('wActionResultOrTookBattleTurn',0);put('wMonIsDisobedient',0)
            for side in (0,1):
                prefix='wEnemy' if side else 'wPlayer';move(side,attack)
                for n in ('DisabledMove','DisabledMoveNumber','NumAttacksLeft','NumHits'):put(prefix+n,0)
            for pref in ('wBattleMon','wPartyMon1','wEnemyMon','wEnemyMon1'):
                put(pref+'Species',ids['BULBASAUR'] if pref in ('wBattleMon','wPartyMon1') else ids['CHARMANDER'])
                put(pref+'Level',50);put(pref+'PP',pp);put(pref+'Moves',MOVES[attack])
            aid(turn,actor);aid(1-turn,target);put(tp+'Status',status);word(tp+'HP',hp);rng(0)
            call('ExecuteEnemyMove' if turn else 'ExecutePlayerMove')
            return ap,tp
        for turn in (0,1):
            ap,tp=execute('SLUDGE',turn,target='SHIELD_DUST');assert get(tp+'Status')==0 and readword(tp+'HP')<160
            ap,tp=execute('FLASH',turn,target='SHIELD_DUST');assert get('w'+('Player' if turn else 'Enemy')+'MonAccuracyMod')==7 and readword(tp+'HP')<160
            ap,tp=execute('EMBER',turn,target='WATER_VEIL');assert get(tp+'Status')==0
            ap,tp=execute('WILL_O_WISP',turn,target='WATER_VEIL');assert get(tp+'Status')==0
            ap,tp=execute('SCALD',turn,target='WATER_VEIL');assert get(tp+'Status')==0
            ap,tp=execute('EMBER',turn,target='WATER_VEIL',status=32);assert get(tp+'Status')==0,('Veil still thaws',turn)
            ap,tp=execute('TACKLE',turn,actor='REPULSIVE');assert get('w'+('Player' if turn else 'Enemy')+'BattleStatus1')&8
            ap,tp=execute('TACKLE',turn,target='POISON_POINT');assert get(ap+'Status')==8 and not(get('w'+('Enemy' if turn else 'Player')+'BattleStatus3')&1)
            ap,tp=execute('VINE_WHIP',turn,actor='POISON_LEAF');assert get(tp+'Status')==8 and not(get('w'+('Player' if turn else 'Enemy')+'BattleStatus3')&1)
            ap,tp=execute('TACKLE',turn,target='POISON_POINT',hp=1);assert readword(tp+'HP')==0 and get(ap+'Status')==8
            ap,tp=execute('WATER_GUN',turn,pp=15);normal=160-readword(tp+'HP')
            ap,tp=execute('WATER_GUN',turn,actor='WATER_PRESSURE',pp=15);assert 160-readword(tp+'HP')>normal
            assert get('wAbilityPPLeft')==15,('before-deduction PP',turn,get('wAbilityPPLeft'))
            ap,tp=execute('TWINEEDLE',turn,target='SHIELD_DUST');blocked_hp=readword(tp+'HP');assert get(tp+'Status')==0
            ap,tp=execute('TWINEEDLE',turn);assert get(tp+'Status')==8 and readword(tp+'HP')==blocked_hp
            ap,tp=execute('TWINEEDLE',turn,target='SHELL_GUARD');assert get('w'+('Player' if turn else 'Enemy')+'MonDefenseMod')==9
            ap,tp=execute('TACKLE',turn,actor='FRENZY',hp=1);assert readword(tp+'HP')==0 and get('w'+('Enemy' if turn else 'Player')+'MonAttackMod')==8
        # Run Away guarantees escape from wild battles, never trainer battles.
        for n in ('PlaySoundWaitForCurrent','WaitForSoundToFinish','SaveScreenTilesToBuffer1','LoadScreenTilesFromBuffer1'):patch(n,[0xc9])
        for battle,want in [(1,True),(2,False)]:
            init();aid(0,'RUN_AWAY');put('wBattleType',0);put('wIsInBattle',battle);put('wEnemyMonSpecies',ids['PIDGEY']);call('TryRunningFromBattle')
            assert bool(game.register_file.F&16)==want,('Run Away',battle)
        # A new player's entry resets the NEW party member's entry flag only.
        metadata('wPartyMon2','CATERPIE',4);put('wWhichPokemon',1);put('wPlayerMonNumber',0)
        game.memory[addr('wAbilityFlags')]=8;game.memory[addr('wAbilityFlags')+1]=8
        call('AbilityLoadPlayer');assert game.memory[addr('wAbilityFlags')]==8 and game.memory[addr('wAbilityFlags')+1]==0
        print(f'{version}: all 15 species / 75 slots, damage/contact/status/crit/priority/accuracy/threshold/KO/healing effects, exact proc odds and Ancient/capsule HP scaling passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
