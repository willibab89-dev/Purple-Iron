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
        game.memory[0xdf50:0xdf70]=[0xa5]*32
        game.register_file.SP=0xdffe;game.register_file.PC=0x100
        for k,v in regs.items():
            if k in ('BC','DE'):
                setattr(game.register_file,k[0],v>>8);setattr(game.register_file,k[1],v&255)
            else:setattr(game.register_file,k,v)
        for _ in range(150):
            game.tick(1,False)
            if game.register_file.PC in (0x104,0x105,0x106):
                assert bytes(game.memory[0xdf50:0xdf70])==bytes([0xa5]*32),('stack guard',n)
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
        put('wUnusedC000',0);put('wActionResultOrTookBattleTurn',0);put('wCustomTargetHadSub',0);put('wCriticalHitOrOHKO',0)
        put('wOptions',0);put('wObtainedBadges',0);put('wFirstMonsNotOutYet',0);put('wResidualRoundDone',0)
        put('wBattleMonSpecies',ids['PIDGEY']);put('wEnemyMonSpecies',ids['PIDGEY'])
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
    from generate_ability_moves import render,CONTACT,SOUND,POWDER,PUNCH
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
        for name in SOUND:
            call('AbilityMoveFlags',A=MOVES[name]);assert game.register_file.A&16,name
        for name in ('TACKLE','SONICBOOM','METRONOME'):
            call('AbilityMoveFlags',A=MOVES[name]);assert not(game.register_file.A&16),name
        for name in POWDER:
            call('AbilityMoveFlags',A=MOVES[name]);assert game.register_file.A&32,name
        for name in ('TACKLE','SING','POISON_GAS'):
            call('AbilityMoveFlags',A=MOVES[name]);assert not(game.register_file.A&32),name
        for name in PUNCH:
            call('AbilityMoveFlags',A=MOVES[name]);assert game.register_file.A&128,name
        for name in ('TACKLE','KARATE_CHOP','BRICK_BREAK'):
            call('AbilityMoveFlags',A=MOVES[name]);assert not(game.register_file.A&128),name
        # All five evolution slots, including noncontiguous ability IDs.
        pools={'BULBASAUR':['POISON_LEAF','CHLOROPHYLL','OVERGROWTH','PHOTOSYNTHESIS','VINE_GUARD'],
               'CHARMANDER':['BLAZE','COMBUSTION','WILDFIRE','HOT_TEMPER','CONFIDENT'],
               'SQUIRTLE':['WATER_PRESSURE','SHELL_GUARD','ANCIENT','WATER_VEIL','SHELL_ARMOR'],
               'CATERPIE':['RUN_AWAY','REPULSIVE','SURVIVAL_INSTINCTS','QUICK_REFLEXES','SHIELD_DUST'],
               'METAPOD':['HARD_SHELL','FORTIFY','REGENERATION','QUICK_REFLEXES','BATTLE_ARMOR'],
               'BUTTERFREE':['COMPOUND_EYES','PSIONIC','DUST_CLOUD','QUICK_REFLEXES','WONDER_SKIN'],
               'WEEDLE':['POISON_POINT','REPULSIVE','VENOMOUS','PIERCING_STING','SHIELD_DUST'],
               'KAKUNA':['HARD_SHELL','FORTIFY','TOXIC_SHELL','PIERCING_STING','BATTLE_ARMOR'],
               'BEEDRILL':['RUTHLESS','FRENZY','VENOMOUS','PIERCING_STING','QUICK_REFLEXES'],
               'PIDGEY':['TAILWIND','PREDATOR','KEEN_EYE','PIERCING_BEAK','GALE_WINGS'],
               'RATTATA':['SCAVENGER','STRONG_JAW','CORNERED','HUSTLE','POISON_HEAL'],
               'SPEAROW':['RUTHLESS','SHORT_TEMPER','RELENTLESS','PIERCING_BEAK','SNIPER'],
               'EKANS':['INTIMIDATE','SHED_SKIN','VENOMOUS','PREDATOR','CORROSIVE_VENOM'],
               'PIKACHU':['STATIC','VOLTAGE','OVERCHARGE','QUICK_REFLEXES','QUICK_FEET'],
               'SANDSHREW':['ROLLING_DEFENSE','SAND_ARMOR','BURROWER','SHARP_CLAWS','SAND_VEIL'],
               'SANDSLASH':['SPINY_ARMOR','SAND_ARMOR','BURROWER','SHARP_CLAWS','SAND_VEIL'],
               'NIDORAN_F':['PHYSICAL_POISON_POINT','MEASURED','THICK_HIDE','PROTECTIVE_INSTINCT','IRON_WILL'],
               'NIDORAN_M':['PHYSICAL_POISON_POINT','PIERCING_HORN','SHEER_FORCE','BLOODLUST','RAMPAGE'],
               'CLEFAIRY':['LUCKY_STAR','MAGIC_GUARD','MOON_CHILD','UNPREDICTABLE','WONDER_SKIN'],
               'VULPIX':['AFTERMATH','FOXFIRE','NINE_LIVES','FOXS_CUNNING','ILLUSION'],
               'JIGGLYPUFF':['INFLATABLE','PERFORMER','RUBBER_SKIN','SOOTHING_VOICE','THICK_FAT'],
               'ZUBAT':['ECHOLOCATION','BLOODSUCKER','GALE_WINGS','INFILTRATOR','PREDATOR'],
               'ODDISH':['PERFUME','ABSORPTION','POLLEN','EFFECT_SPORE','PHOTOSYNTHESIS'],
               'GLOOM':['STENCH','ABSORPTION','POLLEN','EFFECT_SPORE','TOXIC_WASTE'],
               'PARAS':['EFFECT_SPORE','LEECHING','PARASITE','MYCELIUM','REGROWTH'],
               'PARASECT':['EFFECT_SPORE','LEECHING','PARASITE','MYCELIUM','DEATH_SPORE'],
               'VENONAT':['SHIELD_DUST','TOXIC_SCALES','TINTED_LENS','POISON_ABSORB','VENOMOUS'],
               'DIGLETT':['AMBUSH','SUBTERRANEAN','ELUSIVE','AFTERSHOCK','SAND_RUSH'],
               'MEOWTH':['OPPORTUNIST','GREEDY','RESOURCEFUL','QUICK_REFLEXES','TECHNICIAN'],
               'PSYDUCK':['HEADACHE','PSIONIC','DAMP','CONFOUNDING','UNSTABLE'],
               'GOLDUCK':['CLOUD_NINE','SWIFT_SWIM','DAMP','MIND_READER','WATER_VEIL'],
               'MANKEY':['DEFIANT','SHORT_TEMPER','SCRAPPY','UNSOPHISTICATED','BLOODLUST'],
               'GROWLITHE':['LOYALTY','MOMENTUM','STEADFAST','GROWL_INTIMIDATE','ELEGANT_MANE'],
               'ARCANINE':['LEGENDARY','MOMENTUM','STEADFAST','GROWL_INTIMIDATE','ELEGANT_MANE'],
               'POLIWAG':['HYPNOTIC','SLIPPERY','SWIFT_SWIM','HYDRATION','WATER_VEIL'],
               'POLIWRATH':['WRESTLER','SLIPPERY','SWIFT_SWIM','POWER_SWIM','IRON_FIST'],
               'ABRA':['RUN_AWAY','MENTAL_SHIELD','TELEPATHY','GENIUS','MAGIC_BOUNCE'],
               'KADABRA':['SPOON_BENDER','MAGIC_GUARD','MIND_READER','GENIUS','MAGIC_BOUNCE'],
               'MACHOP':['NO_GUARD','GUTS','IRON_GRIP','GRAPPLER','BODYBUILDER'],
               'MACHAMP':['NO_GUARD','GUTS','FOUR_ARMS','GRAPPLER','BODYBUILDER'],
               'BELLSPROUT':['ACIDIC','CARNIVOROUS','STICKY_TRAP','CHLOROPHYLL','DIGESTIVE_ACID'],
               'TENTACOOL':['CLEAR_BODY','LIQUID_OOZE','STINGING_SKIN','JELLY_BODY','VENOMOUS'],
               'GEODUDE':['LEVITATE','IMMUNITY','STURDY','ROLLOUT','HEAVYWEIGHT'],
               'GRAVELER':['DIGGER','IMMUNITY','STURDY','ROLLOUT','HEAVYWEIGHT'],
               'PONYTA':['FLAME_BODY','COMPETITIVE','BLAZING_TRAIL','WILD_CHARGE','STAMINA'],
               'SLOWPOKE':['SHELL_ARMOR','OBLIVIOUS','UNAWARE','PATIENT','SIMPLE'],
               'MAGNEMITE':['LEVITATE','BATTERY','OVERLOAD','CHAIN_REACTION','MAGNETIC_FIELD'],
               'FARFETCHD':['UNDERDOG','UNYIELDING','TASTY_LEEK','PRECISION','RAZOR_EDGE'],
               'DODUO':['TWIN_BEAKS','STAMPEDE','QUICK_FEET','BIRD_RELENTLESS','HEADSTRONG'],
               'DODRIO':['TRIPLE_THREAT','STAMPEDE','QUICK_FEET','BIRD_RELENTLESS','HEADSTRONG'],
               'SEEL':['BLUBBER','HYDRATION','REFRIGERATE','ICEBREAKER','SNOW_VEIL'],
               'GRIMER':['CONTAMINATION','GRIMER_TOXIC_WASTE','STICKY_BODY','LIQUID_OOZE','SOFT_BODY'],
               'SHELLDER':['SHELL_ARMOR','SKILL_LINK','SPIKED_SHELL','DEEPSEA_PEARL','LIQUIDATE']}
        for stages,root in [(('IVYSAUR','VENUSAUR'),'BULBASAUR'),(('CHARMELEON','CHARIZARD'),'CHARMANDER'),(('WARTORTLE','BLASTOISE'),'SQUIRTLE'),(('PIDGEOTTO','PIDGEOT'),'PIDGEY'),(('RATICATE',),'RATTATA'),(('FEAROW',),'SPEAROW'),(('ARBOK',),'EKANS'),(('RAICHU',),'PIKACHU'),(('NIDORINA','NIDOQUEEN'),'NIDORAN_F'),(('NIDORINO','NIDOKING'),'NIDORAN_M'),(('CLEFABLE',),'CLEFAIRY'),(('NINETALES',),'VULPIX'),(('WIGGLYTUFF',),'JIGGLYPUFF'),(('GOLBAT','CROBAT'),'ZUBAT'),(('VILEPLUME',),'ODDISH'),(('VENOMOTH',),'VENONAT'),(('DUGTRIO',),'DIGLETT'),(('PERSIAN',),'MEOWTH'),(('PRIMEAPE',),'MANKEY'),(('POLIWHIRL',),'POLIWAG'),(('ALAKAZAM',),'KADABRA'),(('MACHOKE',),'MACHOP'),(('WEEPINBELL','VICTREEBEL'),'BELLSPROUT'),(('TENTACRUEL',),'TENTACOOL'),(('GOLEM',),'GRAVELER'),(('RAPIDASH',),'PONYTA'),(('SLOWBRO',),'SLOWPOKE'),(('MAGNETON',),'MAGNEMITE'),(('DEWGONG',),'SEEL'),(('MUK',),'GRIMER'),(('CLOYSTER',),'SHELLDER')]:
            for s in stages:pools[s]=pools[root]
        for species,pool in pools.items():
            for slot,name in enumerate(pool,1):
                metadata('wPartyMon1',species,slot,17);call('AbilityEnsureMon',HL=addr('wPartyMon1'))
                assert game.register_file.A==ab[name],(species,slot,name,game.register_file.A)
                assert get('wPartyMon1CatchRate')==17
                put('wEnemyMonSpecies2',ids[species]);put('wNatureEnemySlot',slot);game.memory[addr('wNatureIDs')+1]=17
                call('AbilityLoadEnemy');assert game.memory[addr('wActiveAbilities')+1]==ab[name]
        # Pool 60 starts beyond byte 255: offsets must not wrap.
        pool_bank,pool_base=syms['AbilityPoolIds'];old=game.memory[pool_bank,pool_base+295];game.memory[pool_bank,pool_base+295]=0xa5
        call('AbilityResolvePoolId',BC=(1<<8)|60);assert game.register_file.A==0xa5,(version,'extended pool')
        game.memory[pool_bank,pool_base+295]=old
        # Load a real party member and ensure entry occurs after stage reset.
        init();metadata('wPartyMon1','PIDGEY',1,0);put('wBattleMonSpecies2',ids['PIDGEY'])
        call('LoadBattleMonFromParty')
        assert get('wActiveAbilities')==ab['TAILWIND'] and get('wPlayerMonSpeedMod')==8,(get('wActiveAbilities'),get('wPlayerMonSpeedMod'))
        init();metadata('wPartyMon1','PIKACHU',5,0);put('wPartyMon1Status',64);put('wBattleMonSpecies2',ids['PIKACHU'])
        call('LoadBattleMonFromParty')
        assert get('wActiveAbilities')==ab['QUICK_FEET'] and get('wPlayerMonSpeedMod')==8 and readword('wBattleMonSpeed')==75
        init();put('wEnemyMonSpecies2',ids['PIDGEY']);put('wCurEnemyLVL',20);put('wIsInBattle',1)
        put('wNatureMode',2);put('wNatureEnemySlot',1);game.memory[addr('wNatureIDs')+1]=0
        game.memory[addr('wNatureStatSources')+1]=0;rng(0);call('LoadEnemyMonData')
        assert game.memory[addr('wActiveAbilities')+1]==ab['TAILWIND'] and get('wEnemyMonSpeedMod')==8
        # At battle start the enemy loads first; its effect waits for the player.
        init();aid(0,'INTIMIDATE');aid(1,'INTIMIDATE');put('wFirstMonsNotOutYet',1)
        put('wAbilitySide',1);call('AbilityEntrySpeed')
        assert get('wPlayerMonSpeedMod')==7 and get('wEnemyMonSpeedMod')==7
        put('wAbilitySide',0);call('AbilityEntrySpeed')
        assert get('wPlayerMonSpeedMod')==6 and get('wEnemyMonSpeedMod')==6
        # Wild foes load before StartBattle even sets the first-mon flag.
        init();aid(1,'INTIMIDATE');put('wBattleMonSpecies',0);put('wAbilitySide',1)
        call('AbilityEntrySpeed');assert get('wPlayerMonSpeedMod')==7 and not(game.memory[addr('wAbilityFlags')+6]&64)
        put('wBattleMonSpecies',ids['PIDGEY']);put('wFirstMonsNotOutYet',1);put('wAbilitySide',0);call('AbilityEntrySpeed')
        assert get('wPlayerMonSpeedMod')==6
        # Exercise the real wild-enemy then first-player load ordering.
        init();put('wBattleMonSpecies',0);put('wEnemyMonSpecies2',ids['EKANS']);put('wCurEnemyLVL',20)
        put('wIsInBattle',1);put('wEnemyMonPartyPos',255);put('wNatureMode',2);put('wNatureEnemySlot',1)
        game.memory[addr('wNatureIDs')+1]=0;game.memory[addr('wNatureStatSources')+1]=0;rng(0)
        call('LoadEnemyMonData');assert game.memory[addr('wActiveAbilities')+1]==ab['INTIMIDATE']
        assert not(game.memory[addr('wAbilityFlags')+6]&64)
        metadata('wPartyMon1','BULBASAUR',1,0);put('wBattleMonSpecies2',ids['BULBASAUR']);put('wFirstMonsNotOutYet',1)
        call('LoadBattleMonFromParty');assert get('wPlayerMonSpeedMod')==6
        for turn in (0,1):
            # Nidoran's Poison Point reacts to physical rather than contact moves.
            for attack,roll,sub,holder_hp,actor_type,want in [('TACKLE',0,0,160,'NORMAL',8),('EARTHQUAKE',49,0,160,'NORMAL',8),('TACKLE',50,0,160,'NORMAL',0),('EMBER',0,0,160,'NORMAL',0),('TACKLE',0,1,160,'NORMAL',0),('TACKLE',0,0,0,'NORMAL',8),('TACKLE',0,0,160,'POISON',0)]:
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'PHYSICAL_POISON_POINT');put('wCustomTargetHadSub',sub);word(tp+'HP',holder_hp)
                put(ap+'Type1',TYPES[actor_type]);put(ap+'Type2',TYPES[actor_type]);rng(roll);call('AbilityAfterHit')
                assert get(ap+'Status')==want,(turn,attack,roll,sub,holder_hp,actor_type,get(ap+'Status'))
            # Existing Weedle Poison Point retains its contact-only behavior.
            ap,tp=init(turn);move(turn,'EARTHQUAKE');aid(1-turn,'POISON_POINT');rng(0);call('AbilityAfterHit');assert get(ap+'Status')==0
            # Damage reductions apply independently and stack, with a 1 HP floor.
            for actor,target,typ,damage,want in [('MEASURED',None,'NORMAL',100,80),('MEASURED',None,'FIRE',100,80),('MEASURED',None,'NORMAL',1,1),(None,'THICK_HIDE','NORMAL',100,85),(None,'THICK_HIDE','FIRE',100,100),('MEASURED','THICK_HIDE','NORMAL',100,68)]:
                init(turn);aid(turn,actor);aid(1-turn,target);put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES[typ]);word('wDamage',damage)
                call('AbilityDamageBoost');assert readword('wDamage')==want,(turn,actor,target,typ,damage,readword('wDamage'))
            init(turn);move(turn,'BIDE');aid(turn,'MEASURED');aid(1-turn,'THICK_HIDE');word('wDamage',20)
            call('AbilityFixedDamageModifiers');assert readword('wDamage')==13
            for actor,target,typ,damage,want in [('MEASURED',None,'NORMAL',100,80),(None,'THICK_HIDE','NORMAL',100,85),('MEASURED','THICK_HIDE','NORMAL',100,68),('MEASURED','THICK_HIDE','NORMAL',1,1),('MEASURED','THICK_HIDE','NORMAL',0,0),(None,'THICK_HIDE','FIRE',100,100)]:
                init(turn);aid(turn,actor);aid(1-turn,target);put('wUnusedC000',16);put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES[typ]);word('wDamage',damage)
                call('AbilityFixedDamageModifiers');assert readword('wDamage')==want,(turn,actor,target,typ,damage,readword('wDamage'))
            # Protective Instinct is strict below half and once per Pokémon/battle.
            for hp,want in [(81,7),(80,7),(79,8),(0,7)]:
                ap,tp=init(turn);aid(turn,'PROTECTIVE_INSTINCT');word(ap+'HP',hp);call('AbilityLowHPBoth')
                mod='w'+('Enemy' if turn else 'Player')+'MonDefenseMod';assert get(mod)==want,(turn,hp,get(mod))
                call('AbilityLowHPBoth');put('wAbilitySide',turn);call('AbilityEntry');call('AbilityLowHPBoth');assert get(mod)==want
            # One RNG draw is reused; halving it doubles any secondary gate,
            # including guaranteeing an original 50% chance.
            for value in range(256):
                init(turn);aid(turn,'MEASURED');rng(value);call('MeasuredEffectRandom')
                assert game.register_file.A==value//2 and state['index']==1
            for value in (0,51,52,127,128,254,255):
                init(turn);rng(value);call('MeasuredEffectRandom');assert game.register_file.A==value
            init(turn);move(turn,'TACKLE');aid(turn,'MEASURED');accuracy='w'+('Enemy' if turn else 'Player')+'MoveAccuracy'
            before=get(accuracy);call('CalcHitChance');assert get(accuracy)==before
            # Custom attack secondary and utility status secondary hit exact boundaries.
            for attack,entry,roll,changed in [('CRUNCH','CustomAttackEffect',101,True),('CRUNCH','CustomAttackEffect',102,False),('SCALD','UtilityHitEffect',153,True),('SCALD','UtilityHitEffect',154,False)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'MEASURED');rng(roll);call(entry)
                if attack=='CRUNCH':assert (get('w'+('Player' if turn else 'Enemy')+'MonDefenseMod')==6)==changed,(turn,attack,roll)
                else:assert bool(get(tp+'Status')&16)==changed,(turn,attack,roll)
            ap,tp=init(turn);move(turn,'FLASH');aid(turn,'MEASURED');rng(255);call('CustomAttackEffect')
            assert get('w'+('Player' if turn else 'Enemy')+'MonAccuracyMod')==6
            ap,tp=init(turn);move(turn,'TRI_ATTACK');aid(turn,'MEASURED');rng(101,254);call('UtilityHitEffect')
            assert get(tp+'Status')==64 and state['index']==2 # the three-way selection is not modified
            # Test the actual legacy secondary-effect handlers at their boundaries.
            saved=[]
            for label in ('PlayBattleAnimation','PlayBattleAnimation2','UpdateLoweredStatDone'):
                bank,address=syms[label];saved.append((bank,address,game.memory[bank,address]));patch(label,[0xc9])
            for attack,entry,roll,changed in [('POISON_STING','PoisonEffect',103,True),('POISON_STING','PoisonEffect',104,False),('EMBER','FreezeBurnParalyzeEffect',51,True),('EMBER','FreezeBurnParalyzeEffect',52,False),('BITE','FlinchSideEffect',51,True),('BITE','FlinchSideEffect',52,False),('HORN_ATTACK','StatModifierDownEffect',169,True),('HORN_ATTACK','StatModifierDownEffect',170,False)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'MEASURED');rng(roll);call(entry)
                if attack=='POISON_STING':actual=bool(get(tp+'Status')&8)
                elif attack=='EMBER':actual=bool(get(tp+'Status')&16)
                elif attack=='BITE':actual=bool(get('w'+('Player' if turn else 'Enemy')+'BattleStatus1')&8)
                else:actual=get('w'+('Player' if turn else 'Enemy')+'MonDefenseMod')==6
                assert actual==changed,(turn,attack,roll,actual)
            for bank,address,value in saved:game.memory[bank,address]=value
            # Normal and Ground triggers require an executed move and fire once.
            for name,attack,stat in [('ROLLING_DEFENSE','GROWL','Defense'),('SAND_VEIL','EARTHQUAKE','Evasion')]:
                ap,tp=init(turn);move(turn,attack);aid(turn,name);mod='w'+('Enemy' if turn else 'Player')+'Mon'+stat+'Mod'
                call('AbilityAfterAction');assert get(mod)==7
                call('AbilityAttempt');put('wMoveMissed',1);call('AbilityAfterAction');assert get(mod)==8
                call('AbilityAfterAction');put('wAbilitySide',turn);call('AbilityEntry');call('AbilityAfterAction');assert get(mod)==8
            for name,attack,stat in [('ROLLING_DEFENSE','EARTHQUAKE','Defense'),('SAND_VEIL','TACKLE','Evasion')]:
                init(turn);move(turn,attack);aid(turn,name);call('AbilityAttempt');call('AbilityAfterAction')
                assert get('w'+('Enemy' if turn else 'Player')+'Mon'+stat+'Mod')==7
            # Burrower heals living users for 1/8, capped, only on Ground moves.
            for attack,hp,used,want in [('EARTHQUAKE',80,True,100),('EARTHQUAKE',150,True,160),('EARTHQUAKE',0,True,0),('EARTHQUAKE',80,False,80),('TACKLE',80,True,80)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'BURROWER');word(ap+'HP',hp)
                if used:call('AbilityAttempt')
                call('AbilityAfterAction');assert readword(ap+'HP')==want,(turn,attack,hp,used,readword(ap+'HP'))
                if used and hp and attack=='EARTHQUAKE':
                    party='wEnemyMon1' if turn else 'wPartyMon1';assert readword(party+'HP')==want
            init(turn);aid(turn,'PERFUME');put('wAbilitySide',turn);call('AbilityEntrySpeed')
            assert get('w'+('Enemy' if turn else 'Player')+'MonEvasionMod')==8
            for targethp,targetstatus,hp,want in [(160,8,80,90),(160,0,80,80),(0,8,80,80),(160,8,0,0),(160,8,155,160)]:
                ap,tp=init(turn);aid(turn,'TOXIC_WASTE');word(ap+'HP',hp);word(tp+'HP',targethp);put(tp+'Status',targetstatus);put('wResidualRoundDone',0)
                call('AbilityEndRound');assert readword(ap+'HP')==want,(turn,targethp,targetstatus,hp,readword(ap+'HP'))
            for attack,attacker_status,want in [('TACKLE',8,75),('TACKLE',0,100),('EMBER',8,75)]:
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'STENCH');put(ap+'Status',attacker_status);word('wDamage',100)
                call('AbilityDamageBoost');assert readword('wDamage')==want,(turn,attack,attacker_status,readword('wDamage'))
            ap,tp=init(turn);move(turn,'SEISMIC_TOSS');aid(1-turn,'STENCH');put(ap+'Status',8);put('wUnusedC000',16);word('wDamage',100)
            call('AbilityFixedDamageModifiers');assert readword('wDamage')==75
            for choice,status in [(0,8),(1,64),(2,2)]:
                ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'EFFECT_SPORE');rng(0,choice,2);call('AbilityAfterHit')
                assert get(ap+'Status')==status,(turn,choice,get(ap+'Status'))
                party='wEnemyMon1' if turn else 'wPartyMon1';assert get(party+'Status')==status
            ap,tp=init(turn);move(turn,'EARTHQUAKE');aid(1-turn,'EFFECT_SPORE');rng(0,0);call('AbilityAfterHit');assert get(ap+'Status')==8
            ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'EFFECT_SPORE');rng(0,3,2,1,7);call('AbilityAfterHit');assert get(ap+'Status')==7
            ap,tp=init(turn);move(turn,'DOUBLESLAP');aid(1-turn,'EFFECT_SPORE')
            actorname='Enemy' if turn else 'Player';put('w'+actorname+'BattleStatus1',4);put('w'+actorname+'NumAttacksLeft',3);rng(0,2,2)
            call('AbilityAfterHit');assert get(ap+'Status')==2 and get('w'+actorname+'NumAttacksLeft')==1
            for attack,sub,actorhp,oldstatus in [('EMBER',0,160,0),('TACKLE',1,160,0),('TACKLE',0,0,0),('TACKLE',0,160,16)]:
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'EFFECT_SPORE');put('wCustomTargetHadSub',sub);word(ap+'HP',actorhp);put(ap+'Status',oldstatus);rng(0,0,2)
                call('AbilityAfterHit');assert get(ap+'Status')==oldstatus,(turn,attack,sub,actorhp,get(ap+'Status'))
            for choice,immune_type in [(0,'POISON'),(1,'ELECTRIC')]:
                ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'EFFECT_SPORE');put(ap+'Type1',TYPES[immune_type]);rng(0,choice,2)
                call('AbilityAfterHit');assert get(ap+'Status')==0,(turn,choice,immune_type)
            ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'EFFECT_SPORE');success=0
            for value in range(200):
                put(ap+'Status',0);put('wAbilityHit',0);word('wDamage',40);rng(value,0,2);call('AbilityAfterHit');success+=bool(get(ap+'Status'))
            assert success==40,(turn,success)
            for hp,want in [(0,0),(1,11),(80,90),(159,160),(160,160)]:
                ap,tp=init(turn);aid(turn,'REGROWTH');word(ap+'HP',hp);put('wResidualRoundDone',0)
                call('AbilityEndRound');assert readword(ap+'HP')==want,(turn,hp,readword(ap+'HP'))
            for attack,damage,hp,want in [('TACKLE',40,80,84),('EARTHQUAKE',5,80,81),('EMBER',40,80,80),('TACKLE',40,159,160),('TACKLE',40,0,0)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'LEECHING');word(ap+'HP',hp);word('wDamage',damage)
                call('AbilityAfterHit');assert readword(ap+'HP')==want,(turn,attack,damage,hp,readword(ap+'HP'))
            for damage,subhp,want in [(80,25,82),(8,25,81),(300,25,82)]:
                ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'LEECHING');word(ap+'HP',80);put('wCustomTargetHadSub',1)
                put('w'+('Player' if turn else 'Enemy')+'SubstituteHP',subhp);call('AbilityCaptureRampageSubHP');word('wDamage',damage)
                call('AbilityAfterHit');assert readword(ap+'HP')==want,(turn,damage,subhp,readword(ap+'HP'))
            for attack,sub,should in [('TACKLE',0,True),('WATERFALL',0,True),('EARTHQUAKE',0,False),('TACKLE',1,False)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'BLAZE');aid(1-turn,'PARASITE');put('wCustomTargetHadSub',sub)
                before=bytes(game.memory[addr('wPartyMon1'):addr('wPartyMon1')+44]);call('AbilityAfterHit')
                assert game.memory[addr('wActiveAbilities')+turn]==ab['PARASITE' if should else 'BLAZE'],(turn,attack,sub)
                assert bytes(game.memory[addr('wPartyMon1'):addr('wPartyMon1')+44])==before
            # Infection is temporary: reloading the original party slot restores it.
            ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'PARASITE')
            if turn:
                put('wEnemyMonSpecies2',ids['CHARMANDER']);put('wNatureEnemySlot',1);call('AbilityLoadEnemy')
            else:
                metadata('wPartyMon1','CHARMANDER',1);put('wWhichPokemon',0);call('AbilityLoadPlayer')
            assert game.memory[addr('wActiveAbilities')+turn]==ab['BLAZE']
            call('AbilityAfterHit');assert game.memory[addr('wActiveAbilities')+turn]==ab['PARASITE']
            call('AbilityLoadEnemy' if turn else 'AbilityLoadPlayer');assert game.memory[addr('wActiveAbilities')+turn]==ab['BLAZE']
            ap,tp=init(turn);move(turn,'SING');aid(turn,'MYCELIUM');put('w'+('Player' if turn else 'Enemy')+'BattleStatus1',64)
            call('MoveHitTest');assert get('wMoveMissed')==1
            for targethp,targetstatus,hp,want in [(160,8,80,100),(160,0,80,80),(0,8,80,80),(160,8,0,0),(160,8,1,21),(160,8,155,160)]:
                ap,tp=init(turn);aid(turn,'POISON_ABSORB');word(ap+'HP',hp);word(tp+'HP',targethp);put(tp+'Status',targetstatus);put('wResidualRoundDone',0)
                call('AbilityEndRound');assert readword(ap+'HP')==want,(turn,targethp,targetstatus,hp,readword(ap+'HP'))
                if hp and targethp and targetstatus:
                    party='wEnemyMon1' if turn else 'wPartyMon1';assert readword(party+'HP')==want
            for multiplier,want in [(0,100),(2,200),(5,200),(10,100),(20,100),(40,100),(130,200),(133,200),(138,100)]:
                init(turn);move(turn,'TACKLE');aid(turn,'TINTED_LENS');word('wDamage',100);put('wDamageMultipliers',multiplier)
                call('AbilityDamageBoost');assert readword('wDamage')==want and get('wDamageMultipliers')==multiplier,(turn,multiplier,readword('wDamage'))
            init(turn);aid(turn,'TINTED_LENS');put('wDamageMultipliers',5);word('wDamage',0);call('AbilityDamageBoost');assert readword('wDamage')==0
            for actor,target,status,want in [('VENOMOUS',None,8,125),('VENOMOUS',None,0,100),('VENOMOUS','THICK_HIDE',8,106)]:
                ap,tp=init(turn);move(turn,'SEISMIC_TOSS');aid(turn,actor);aid(1-turn,target);put(tp+'Status',status);put('wUnusedC000',16);word('wDamage',100)
                call('AbilityFixedDamageModifiers');assert readword('wDamage')==want,(turn,actor,target,status,readword('wDamage'))
            for attack,sub,targethp,oldstatus,targetability in [('EMBER',0,160,0,None),('TACKLE',1,160,0,None),('TACKLE',0,0,0,None),('TACKLE',0,160,16,None),('TACKLE',0,160,0,'SHIELD_DUST')]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'TOXIC_SCALES');aid(1-turn,targetability);put('wCustomTargetHadSub',sub);word(tp+'HP',targethp);put(tp+'Status',oldstatus);rng(0)
                call('AbilityAfterHit');assert get(tp+'Status')==oldstatus,(turn,attack,sub,targethp,oldstatus,get(tp+'Status'))
            ap,tp=init(turn);move(turn,'EARTHQUAKE');aid(turn,'TOXIC_SCALES');rng(0);call('AbilityAfterHit');assert get(tp+'Status')==8
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'TOXIC_SCALES');put(tp+'Type1',TYPES['POISON']);rng(0);call('AbilityAfterHit');assert get(tp+'Status')==0
            ap,tp=init(turn);move(turn,'DOUBLESLAP');aid(turn,'TOXIC_SCALES');rng(100,0)
            call('AbilityAfterHit');assert get(tp+'Status')==0
            call('AbilityAfterHit');assert get(tp+'Status')==8
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'TOXIC_SCALES');success=0
            for value in range(200):
                put(tp+'Status',0);put('wAbilityHit',0);word('wDamage',40);rng(value);call('AbilityAfterHit');success+=bool(get(tp+'Status'))
            assert success==60,(turn,success)
            # A status move does not spend Ambush; all hits of the first attack benefit.
            ap,tp=init(turn);aid(turn,'AMBUSH');move(turn,'GROWL');call('AbilityAttempt')
            call('AbilityBeforeAction');move(turn,'TACKLE');call('AbilityAttempt');word('wDamage',100);call('AbilityDamageBoost');assert readword('wDamage')==125
            word('wDamage',100);call('AbilityDamageBoost');assert readword('wDamage')==125
            call('AbilityBeforeAction');move(turn,'TACKLE');call('AbilityAttempt');word('wDamage',100);call('AbilityDamageBoost');assert readword('wDamage')==100
            # Metronome cannot revive a spent Ambush; switching in resets it.
            call('AbilityBeforeAction');move(turn,'METRONOME');call('AbilityAttempt');move(turn,'TACKLE');call('AbilityAttempt');word('wDamage',100);call('AbilityDamageBoost');assert readword('wDamage')==100
            put('wAbilitySide',turn);call('AbilityEntry');call('AbilityBeforeAction');move(turn,'SEISMIC_TOSS');call('AbilityAttempt');put('wUnusedC000',16);word('wDamage',100)
            call('AbilityFixedDamageModifiers');assert readword('wDamage')==125
            ap,tp=init(turn);aid(turn,'AMBUSH');move(turn,'BIDE');put('w'+('Enemy' if turn else 'Player')+'MovePower',1);put('wAbilityHit',32);word('wDamage',40)
            call('AbilityFixedDamageModifiers');assert readword('wDamage')==50 and get('wAbilityHit')&8
            for multiplier,damage,want in [(0,100,100),(5,100,100),(10,100,100),(20,100,75),(40,100,75),(148,100,75),(20,1,1)]:
                init(turn);aid(1-turn,'SUBTERRANEAN');put('wDamageMultipliers',multiplier);word('wDamage',damage)
                call('AbilityDamageBoost');assert readword('wDamage')==want,(turn,multiplier,damage,readword('wDamage'))
            # Elusive persists through status moves, and expires after a missed attack.
            ap,tp=init(turn);aid(1-turn,'ELUSIVE');put('wAbilitySide',1-turn);call('AbilityEntry');call('AbilityEntrySpeed')
            mod='w'+('Player' if turn else 'Enemy')+'MonEvasionMod';assert get(mod)==8
            move(turn,'GROWL');call('AbilityAttempt');call('AbilityAfterAction');assert get(mod)==8
            call('AbilityBeforeAction');move(turn,'TACKLE');call('AbilityAttempt');put('wMoveMissed',1);word('wDamage',0);call('AbilityAfterAction');assert get(mod)==7
            call('AbilityAfterAction');assert get(mod)==7
            put('wAbilitySide',1-turn);call('AbilityEntry');call('AbilityEntrySpeed');assert get(mod)==8
            # Starting to store Bide is not an incoming attack, even with stale damage.
            call('AbilityBeforeAction');move(turn,'BIDE');call('AbilityAttempt');put('w'+('Enemy' if turn else 'Player')+'BattleStatus1',1);word('wDamage',40);call('AbilityAfterAction');assert get(mod)==8
            for attack,sub,targethp,oldstatus,targetability in [('TACKLE',0,160,0,None),('EARTHQUAKE',1,160,0,None),('EARTHQUAKE',0,0,0,None),('EARTHQUAKE',0,160,8,None),('EARTHQUAKE',0,160,0,'SHIELD_DUST')]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'AFTERSHOCK');aid(1-turn,targetability);put('wCustomTargetHadSub',sub);word(tp+'HP',targethp);put(tp+'Status',oldstatus);rng(0)
                call('AbilityAfterHit');assert get(tp+'Status')==oldstatus,(turn,attack,sub,targethp,oldstatus,get(tp+'Status'))
            ap,tp=init(turn);move(turn,'EARTHQUAKE');aid(turn,'AFTERSHOCK');put(tp+'Type1',TYPES['ELECTRIC']);rng(0);call('AbilityAfterHit');assert get(tp+'Status')==0
            ap,tp=init(turn);move(turn,'EARTHQUAKE');aid(turn,'AFTERSHOCK');success=0
            for value in range(200):
                put(tp+'Status',0);put('wAbilityHit',0);word('wDamage',40);rng(value);call('AbilityAfterHit');success+=bool(get(tp+'Status'))
            assert success==40,(turn,success)
            for attack,want in [('EARTHQUAKE',8),('TACKLE',7)]:
                init(turn);move(turn,attack);aid(turn,'SAND_RUSH');call('AbilityAttempt');put('wMoveMissed',1);call('AbilityAfterAction')
                mod='w'+('Enemy' if turn else 'Player')+'MonSpeedMod';assert get(mod)==want
                call('AbilityAfterAction');put('wAbilitySide',turn);call('AbilityEntry');call('AbilityAfterAction');assert get(mod)==want
            for index in range(6):
                ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'OPPORTUNIST');game.memory[addr('w'+('Player' if turn else 'Enemy')+'MonStatMods')+index]=6;word('wDamage',100)
                call('AbilityDamageBoost');assert readword('wDamage')==120,(turn,index,readword('wDamage'))
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'OPPORTUNIST');word('wDamage',100);call('AbilityDamageBoost');assert readword('wDamage')==100
            ap,tp=init(turn);move(turn,'SEISMIC_TOSS');aid(turn,'OPPORTUNIST');game.memory[addr('w'+('Player' if turn else 'Enemy')+'MonStatMods')]=6;put('wUnusedC000',16);word('wDamage',100)
            call('AbilityFixedDamageModifiers');assert readword('wDamage')==120
            for attack,want in [('TACKLE',150),('MEGA_DRAIN',150),('EARTHQUAKE',100),('GROWL',100)]:
                init(turn);move(turn,attack);aid(turn,'TECHNICIAN');word('wDamage',100);call('AbilityDamageBoost')
                assert readword('wDamage')==want,(turn,attack,readword('wDamage'))
            # Sound heals after an executed move, including misses, but not before use.
            for attack,hp,used,want in [('SING',80,True,100),('SNARL',80,True,100),('HEAL_BELL',150,True,160),('SING',0,True,0),('SING',80,False,80),('TACKLE',80,True,80)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'SOOTHING_VOICE');word(ap+'HP',hp)
                if used:call('AbilityAttempt')
                put('wMoveMissed',1);call('AbilitySoothingVoice');assert readword(ap+'HP')==want,(turn,attack,hp,readword(ap+'HP'))
            # Spiny Armor damages every physical hit, including ranged and KO hits.
            for attack,sub,holder_hp,actor_hp,maxhp,want in [('TACKLE',0,160,80,160,70),('EARTHQUAKE',0,160,80,160,70),('EMBER',0,160,80,160,80),('TACKLE',1,160,80,160,80),('TACKLE',0,0,80,160,70),('TACKLE',0,160,5,160,0),('TACKLE',0,160,5,10,4)]:
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'SPINY_ARMOR');word(ap+'HP',actor_hp);word(ap+'MaxHP',maxhp);word(tp+'HP',holder_hp);put('wCustomTargetHadSub',sub)
                before=readword('wDamage');call('AbilityAfterHit');assert readword(ap+'HP')==want and readword('wDamage')==before,(turn,attack,sub,holder_hp,actor_hp,maxhp,readword(ap+'HP'))
                if want!=actor_hp:
                    party='wEnemyMon1' if turn else 'wPartyMon1';assert readword(party+'HP')==want
            ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'SPINY_ARMOR');word(ap+'HP',80)
            call('AbilityAfterHit');call('AbilityAfterHit');assert readword(ap+'HP')==60
            # Static responds to physical attacks, not just contact, and rolls once.
            for attack,roll,sub,holder_hp,actor_type,want in [
                ('TACKLE',0,0,160,'NORMAL',64),('EARTHQUAKE',39,0,160,'NORMAL',64),
                ('TACKLE',40,0,160,'NORMAL',0),('EMBER',0,0,160,'NORMAL',0),
                ('TACKLE',0,1,160,'NORMAL',0),('TACKLE',0,0,0,'NORMAL',64),
                ('TACKLE',0,0,160,'ELECTRIC',0)]:
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'STATIC');put('wCustomTargetHadSub',sub);word(tp+'HP',holder_hp)
                put(ap+'Type1',TYPES[actor_type]);put(ap+'Type2',TYPES[actor_type]);rng(roll);call('AbilityAfterHit')
                assert get(ap+'Status')==want,(turn,attack,roll,sub,holder_hp,actor_type,get(ap+'Status'))
            ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'STATIC');rng(199,0)
            call('AbilityAfterHit');call('AbilityAfterHit');assert get(ap+'Status')==0 and state['index']==1
            ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'STATIC');put(ap+'Status',8);rng(0)
            call('AbilityAfterHit');assert get(ap+'Status')==8
            # Overcharge requires a critical hit, triggers on a Substitute, and persists across entry.
            for crit,damage,sub,want in [(1,40,0,8),(1,40,1,8),(0,40,0,7),(2,40,0,7),(1,0,0,7)]:
                ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'OVERCHARGE');put('wCriticalHitOrOHKO',crit);put('wCustomTargetHadSub',sub);word('wDamage',damage)
                call('AbilityAfterHit');mod='w'+('Enemy' if turn else 'Player')+'MonSpecialMod';assert get(mod)==want,(turn,crit,damage,sub)
                if want==8:
                    call('AbilityAfterHit');put('wAbilitySide',turn);call('AbilityEntry');call('AbilityAfterHit');assert get(mod)==8
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'OVERCHARGE');put('wCriticalHitOrOHKO',1);word(tp+'HP',0)
            call('AbilityAfterHit');assert get('w'+('Enemy' if turn else 'Player')+'MonSpecialMod')==8
            # Quick Feet raises Speed once per status episode and reapplies on entry.
            for status in (1,8,16,32,64):
                ap,tp=init(turn);aid(turn,'QUICK_FEET');put(ap+'Status',status);put('wAbilitySide',turn);call('AbilityEntrySpeed')
                mod='w'+('Enemy' if turn else 'Player')+'MonSpeedMod';assert get(mod)==8,(turn,status)
                call('AbilityQuickFeetBoth');assert get(mod)==8
                put(ap+'Status',0);call('AbilityQuickFeetBoth');put(ap+'Status',status);call('AbilityQuickFeetBoth');assert get(mod)==9
                put(mod,7);put('wAbilitySide',turn);call('AbilityEntrySpeed');assert get(mod)==8
            ap,tp=init(turn);aid(turn,'QUICK_FEET');put(ap+'Status',8);call('AbilityAfterAction')
            assert get('w'+('Enemy' if turn else 'Player')+'MonSpeedMod')==8
            # A normal move inflicts paralysis; Quick Feet applies its stage
            # afterwards while retaining this game's paralysis Speed penalty.
            ap,tp=init(turn);aid(1-turn,'QUICK_FEET');put('wCustomSide',1-turn);put('wCustomDelta',64)
            call('UtilityInflictStatus');assert get(tp+'Status')==64 and readword(tp+'Speed')==50
            call('AbilityAfterAction');assert get('w'+('Player' if turn else 'Enemy')+'MonSpeedMod')==8 and readword(tp+'Speed')==75
            # Static on a defender can activate the attacker's Quick Feet.
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'QUICK_FEET');aid(1-turn,'STATIC');rng(0)
            call('AbilityAfterHit');assert get(ap+'Status')==64
            call('AbilityAfterAction');assert get('w'+('Enemy' if turn else 'Player')+'MonSpeedMod')==8 and readword(ap+'Speed')==75
            # Intimidate fires once per holder and does not stack on a target.
            ap,tp=init(turn);aid(turn,'INTIMIDATE');put('wAbilitySide',turn);call('AbilityEntrySpeed')
            mod='w'+('Player' if turn else 'Enemy')+'MonSpeedMod';assert get(mod)==6
            put('wAbilitySide',turn);call('AbilityEntrySpeed');assert get(mod)==6
            put('wEnemyMonPartyPos' if turn else 'wPlayerMonNumber',1);put('wAbilitySide',turn)
            call('AbilityEntrySpeed');assert get(mod)==6
            # Shed Skin uses exact 30% rolls, clears major status/Toxic and syncs party.
            for status,roll,cured in [(8,0,True),(8,59,True),(8,60,False),(16,0,True),(32,0,True),(64,0,True),(1,0,True)]:
                ap,tp=init(turn);aid(turn,'SHED_SKIN');put(ap+'Status',status)
                party='wEnemyMon1' if turn else 'wPartyMon1';put(party+'Status',status)
                battle3='w'+('Enemy' if turn else 'Player')+'BattleStatus3';counter='w'+('Enemy' if turn else 'Player')+'ToxicCounter'
                put(battle3,1);put(counter,3);put('wAbilitySide',turn);rng(roll);call('AbilityShedSkin')
                assert get(ap+'Status')==(0 if cured else status),(turn,status,roll)
                assert get(party+'Status')==(0 if cured else status)
                assert bool(get(battle3)&1)!=cured and get(counter)==(0 if cured else 3)
            ap,tp=init(turn);aid(turn,'SHED_SKIN');put(ap+'Status',8);word(ap+'HP',0);put('wAbilitySide',turn);rng(0);call('AbilityShedSkin');assert get(ap+'Status')==8
            for status,stat in [(16,'Attack'),(64,'Speed'),(8,'Special')]:
                ap,tp=init(turn);aid(turn,'SHED_SKIN');put(ap+'Status',status);word(ap+stat,50)
                put('wAbilitySide',turn);rng(0);call('AbilityShedSkin');assert readword(ap+stat)==100,(turn,status,stat,readword(ap+stat))
            ap,tp=init(turn);aid(turn,'SHED_SKIN');put(ap+'Status',8);rng(0);call('AbilityEndRound');assert get(ap+'Status')==0
            ap,tp=init(turn);aid(turn,'SHED_SKIN');put(ap+'Status',8);put('wResidualRoundDone',1);rng(0);call('AbilityEndRound');assert get(ap+'Status')==8
            # Corrosive Venom changes only Poison vs Rock, including AI scoring.
            for attack,t1,t2,enabled,want in [('POISON','ROCK','ROCK',True,20),('POISON','ROCK','GROUND',True,10),('POISON','ROCK','GRASS',True,40),('POISON','POISON','ROCK',True,10),('POISON','ROCK','ROCK',False,5),('FIRE','ROCK','ROCK',True,5)]:
                ap,tp=init(turn);aid(turn,'CORROSIVE_VENOM' if enabled else None);put(tp+'Type1',TYPES[t1]);put(tp+'Type2',TYPES[t2])
                put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES[attack]);word('wDamage',100);call('AdjustDamageForMoveType')
                assert readword('wDamage')==want*10 and get('wDamageMultipliers')==want,(turn,attack,t1,t2,enabled,readword('wDamage'),get('wDamageMultipliers'))
                put('wUnusedC000',8 if turn==0 else 0);call('AIGetTypeEffectiveness');assert get('wTypeEffectiveness')==want,(turn,attack,t1,t2,enabled,get('wTypeEffectiveness'))
            ap,tp=init(turn);aid(turn,'CORROSIVE_VENOM');put(ap+'Type1',TYPES['POISON']);put(ap+'Type2',TYPES['POISON'])
            put(tp+'Type1',TYPES['ROCK']);put(tp+'Type2',TYPES['ROCK']);put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES['POISON'])
            word('wDamage',100);call('AdjustDamageForMoveType');assert readword('wDamage')==300 and get('wDamageMultipliers')==0x94
            # Scrappy removes only Ghost immunity; retain the other type's multiplier and AI assessment.
            for attack,t1,t2,enabled,want in [('NORMAL','GHOST','GHOST',True,10),('FIGHTING','GHOST','GHOST',True,10),('NORMAL','GHOST','ROCK',True,5),('FIGHTING','GHOST','ROCK',True,20),('NORMAL','GHOST','GHOST',False,0),('FIGHTING','GHOST','GHOST',False,0),('NORMAL','ROCK','ROCK',True,5)]:
                ap,tp=init(turn);put(ap+'Type1',TYPES['FIRE']);put(ap+'Type2',TYPES['FIRE']);aid(turn,'SCRAPPY' if enabled else None);put(tp+'Type1',TYPES[t1]);put(tp+'Type2',TYPES[t2]);put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES[attack]);word('wDamage',100)
                call('AdjustDamageForMoveType');assert readword('wDamage')==want*10 and get('wDamageMultipliers')==want,(turn,attack,t1,t2,enabled,readword('wDamage'),get('wDamageMultipliers'))
                put('wUnusedC000',8 if turn==0 else 0);call('AIGetTypeEffectiveness');assert get('wTypeEffectiveness')==want,(turn,'scrappy AI',attack,t1,t2,want,get('wTypeEffectiveness'))
            # Defiant suppresses only the stat penalties, not the conditions.
            for status,stat,routine in [(16,'Attack','StatusHalveAttackDueToBurn'),(64,'Speed','HalveSpeedDueToParalysis'),(8,'Special','PoisonSpecialPenalty')]:
                for active in (False,True):
                    ap,tp=init(turn);aid(1-turn,'DEFIANT' if active else None);put(tp+'Status',status);word(tp+stat,100);call(routine)
                    assert readword(tp+stat)==(100 if active else 25 if status==8 else 50),(turn,status,active,readword(tp+stat))
                    assert get(tp+'Status')==status
            # The base move table, not its current accuracy, controls the bonus.
            for attack,want in [('POUND',125),('TACKLE',100),('FIRE_BLAST',100)]:
                init(turn);move(turn,attack);aid(turn,'UNSOPHISTICATED');word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,readword('wDamage'))
            for attack,want in [('POUND',230),('TACKLE',242),('FIRE_BLAST',229)]:
                init(turn);move(turn,attack);aid(turn,'UNSOPHISTICATED');call('AbilityHustleAccuracy');assert get('w'+('Enemy' if turn else 'Player')+'MoveAccuracy')==want,(turn,attack)
            init(turn);move(turn,'SEISMIC_TOSS');aid(turn,'UNSOPHISTICATED');put('wUnusedC000',16);word('wDamage',100);call('AbilityExistingFixedDamageModifiers');assert readword('wDamage')==125
            # Short Temper responds to misses, including status moves, but not immunities.
            for attack,miss,multiplier,hp,want in [('TACKLE',1,10,160,8),('GROWL',1,10,160,8),('TACKLE',0,10,160,7),('TACKLE',1,0,160,7),('TACKLE',1,10,0,7)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'SHORT_TEMPER');put('wMoveMissed',miss);put('wDamageMultipliers',multiplier);word(ap+'HP',hp)
                call('AbilityAfterAction');assert get('w'+('Enemy' if turn else 'Player')+'MonAttackMod')==want,(turn,attack,miss,multiplier,hp)
            init(turn);move(turn,'TACKLE');aid(turn,'SHORT_TEMPER');put('wMoveMissed',1)
            call('AbilityAfterAction');call('AbilityAfterAction')
            assert get('w'+('Enemy' if turn else 'Player')+'MonAttackMod')==9
            # Relentless grows once per successful strike, including Substitute,
            # caps at 30%, and clears on status moves or either side switching.
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'RELENTLESS')
            for hit,expected in enumerate((100,110,120,130,130)):
                word('wDamage',100);call('AbilityDamageBoost');assert readword('wDamage')==expected,(turn,hit,readword('wDamage'))
                put('wCustomTargetHadSub',int(hit==1));call('AbilityAfterHit')
            move(turn,'GROWL');call('AbilityAttempt');move(turn,'TACKLE');word('wDamage',100);call('AbilityDamageBoost');assert readword('wDamage')==100
            call('AbilityAfterHit');put('wAbilitySide',1-turn);call('AbilityEntry');word('wDamage',100);call('AbilityDamageBoost');assert readword('wDamage')==100
            # Tailwind applies after stat setup; other species are unaffected.
            init(turn);aid(turn,'TAILWIND');put('wAbilitySide',turn);call('AbilityEntrySpeed')
            assert get('w'+('Enemy' if turn else 'Player')+'MonSpeedMod')==8
            init(turn);put('wAbilitySide',turn);call('AbilityEntrySpeed')
            assert get('w'+('Enemy' if turn else 'Player')+'MonSpeedMod')==7
            # Full-HP Flying moves gain priority; status moves count too.
            for attack,hp,want in [('WING_ATTACK',160,True),('WHIRLWIND',160,True),('WING_ATTACK',159,False),('TACKLE',160,False)]:
                ap,tp=init(turn);move(turn,attack);move(1-turn,'TACKLE');aid(turn,'GALE_WINGS');word(ap+'HP',hp)
                put('wAbilitySide',turn);call('AbilityPriorityOne')
                assert bool(game.register_file.A)==want,(turn,attack,hp,game.register_file.A)
            # Apply the defense reduction before Gen 1 stat scaling.
            for typ,defense,want in [('FLYING',100,75),('FLYING',3,3),('NORMAL',100,100)]:
                init(turn);aid(turn,'PIERCING_BEAK');put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES[typ])
                call('AdjustPiercingBeakDefense',BC=defense)
                got=game.register_file.B*256+game.register_file.C
                assert got==want,(turn,typ,defense,got)
            for typ,defense,want in [('NORMAL',100,80),('NORMAL',99,80),('NORMAL',3,3),('FIRE',100,100)]:
                init(turn);aid(turn,'PIERCING_HORN');put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES[typ])
                call('AdjustPiercingBeakDefense',BC=defense)
                assert game.register_file.B*256+game.register_file.C==want,(turn,typ,defense,game.register_file.B,game.register_file.C)
            for attack in ('TACKLE','EARTHQUAKE'):
                init(turn);move(turn,attack);aid(turn,'PIERCING_HORN')
                call('GetDamageVarsForEnemyAttack' if turn else 'GetDamageVarsForPlayerAttack')
                assert game.memory[0xff98]==80,(turn,attack,game.memory[0xff98])
            for ability_name,attack,hp,want in [('BLOODLUST','TACKLE',79,125),('BLOODLUST','TACKLE',80,100),('BLOODLUST','EMBER',79,100),('RAMPAGE','TACKLE',160,125),('RAMPAGE','EMBER',160,100),('SHEER_FORCE','SLUDGE',160,120),('SHEER_FORCE','TWINEEDLE',160,120),('SHEER_FORCE','TACKLE',160,100)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,ability_name);word(tp+'HP',hp);word('wDamage',100)
                call('AbilityDamageBoost');assert readword('wDamage')==want,(turn,ability_name,attack,hp,readword('wDamage'))
            for roll,want in [(0,150),(19,150),(20,100),(199,100)]:
                init(turn);move(turn,'TACKLE');aid(turn,'LUCKY_STAR');word('wDamage',100);rng(roll)
                call('AbilityDamageBoost');assert readword('wDamage')==want,(turn,roll,readword('wDamage'))
            init(turn);move(turn,'METRONOME');aid(turn,'UNPREDICTABLE');call('AbilityAttempt');move(turn,'TACKLE');word('wDamage',100)
            call('AbilityDamageBoost');assert readword('wDamage')==130,(turn,readword('wDamage'))
            init(turn);move(turn,'TACKLE');aid(turn,'UNPREDICTABLE');word('wDamage',100)
            call('AbilityDamageBoost');assert readword('wDamage')==100
            # Direct, fixed, exact lethal and already-at-1 HP; then spent.
            for hp,damage,want in [(300,299,299),(300,300,299),(160,500,159),(1,10,0)]:
                ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'NINE_LIVES');word(tp+'HP',hp);word('wDamage',damage)
                call('AbilityMarkDirectHit');call('AbilityFixedDamageModifiers');assert readword('wDamage')==want,(turn,hp,damage,readword('wDamage'))
                if damage>=hp:
                    word('wDamage',damage);call('AbilityMarkDirectHit');call('AbilityFixedDamageModifiers');assert readword('wDamage')==damage
            ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'NINE_LIVES');put('wCustomTargetHadSub',1);word(tp+'HP',1);word('wDamage',40)
            call('AbilityMarkDirectHit');call('AbilityFixedDamageModifiers');assert readword('wDamage')==40
            put('wCustomTargetHadSub',0);call('AbilityMarkDirectHit');call('AbilityFixedDamageModifiers');assert readword('wDamage')==0
            ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'ILLUSION');put('wCustomTargetHadSub',1);word('wDamage',100)
            call('AbilityMarkDirectHit');call('AbilityFixedDamageModifiers');assert readword('wDamage')==100
            put('wCustomTargetHadSub',0);word('wDamage',100)
            call('AbilityMarkDirectHit');call('AbilityFixedDamageModifiers');assert readword('wDamage')==50
            word('wDamage',100);call('AbilityMarkDirectHit');call('AbilityFixedDamageModifiers');assert readword('wDamage')==50
            put('wAbilityHit',0);word('wDamage',100);call('AbilityMarkDirectHit');call('AbilityFixedDamageModifiers');assert readword('wDamage')==100
            put('wAbilitySide',1-turn);call('AbilityEntry');put('wAbilityHit',0);word('wDamage',100);call('AbilityMarkDirectHit');call('AbilityFixedDamageModifiers');assert readword('wDamage')==50
            ap,tp=init(turn);move(turn,'FISSURE');aid(1-turn,'ILLUSION');word(tp+'HP',160);word('wDamage',65535);put('wCriticalHitOrOHKO',2)
            call('AbilityMarkDirectHit');call('AbilityFixedDamageModifiers');assert readword('wDamage')==80 and get('wCriticalHitOrOHKO')==0
            for attack,want in [('EMBER',50),('ICE_BEAM',50),('WATER_GUN',100),('TACKLE',100)]:
                init(turn);move(turn,attack);aid(1-turn,'THICK_FAT');word('wDamage',100);call('AbilityDamageBoost')
                assert readword('wDamage')==want,(turn,attack,readword('wDamage'))
            for attack in ('WING_ATTACK','AERIAL_ACE'):
                init(turn);move(turn,attack);aid(turn,'PIERCING_BEAK')
                call('GetDamageVarsForEnemyAttack' if turn else 'GetDamageVarsForPlayerAttack')
                assert game.memory[0xff98]==75,(turn,attack,game.memory[0xff98])
            for attack,defend,typ,status,pp,want in [
                ('WATER_PRESSURE',None,'WATER',0,0,100),('WATER_PRESSURE',None,'WATER',0,15,130),('WATER_PRESSURE',None,'WATER',0,40,150),
                ('PSIONIC',None,'PSYCHIC',0,5,120),('VENOMOUS',None,'NORMAL',8,5,125),('VENOMOUS',None,'NORMAL',0,5,100),
                (None,'VINE_GUARD','FLYING',0,5,50),(None,'VINE_GUARD','NORMAL',0,5,100),
                (None,'WATER_VEIL','FIRE',0,5,50),(None,'HARD_SHELL','NORMAL',0,5,75),(None,'HARD_SHELL','FIRE',0,5,100)]:
                ap,tp=init(turn);aid(turn,attack);aid(1-turn,defend);put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES[typ]);put(tp+'Status',status);put('wAbilityPPLeft',pp);word('wDamage',100)
                call('AbilityDamageBoost');assert readword('wDamage')==want,(turn,attack,defend,readword('wDamage'))
            # Unassigned mechanics for the next species pools, on either side.
            for name,typ,status,critical,want in [
                ('STRONG_JAW','NORMAL',0,0,115),('STRONG_JAW','FIRE',0,0,100),('HUSTLE','NORMAL',0,0,125),('HUSTLE','FIRE',0,0,100),
                ('VOLTAGE','ELECTRIC',64,0,120),('VOLTAGE','ELECTRIC',0,0,100),
                ('VOLTAGE','NORMAL',64,0,100),('SNIPER','NORMAL',0,1,150),
                ('SNIPER','NORMAL',0,0,100)]:
                ap,tp=init(turn);aid(turn,name);put(tp+'Status',status);put('wCriticalHitOrOHKO',critical)
                put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES[typ]);word('wDamage',100)
                call('AbilityDamageBoost');assert readword('wDamage')==want,(turn,name,typ,status,critical,readword('wDamage'))
            for multiplier,want in [(5,100),(10,100),(20,75)]:
                init(turn);aid(1-turn,'SAND_ARMOR');put('wDamageMultipliers',multiplier);word('wDamage',100)
                call('AbilityDamageBoost');assert readword('wDamage')==want,(turn,multiplier,readword('wDamage'))
            for actor_speed,target_speed,typ,want in [(101,100,'NORMAL',120),(100,100,'NORMAL',100),(99,100,'NORMAL',100),(101,100,'FIRE',100)]:
                ap,tp=init(turn);aid(turn,'PREDATOR');word(ap+'Speed',actor_speed);word(tp+'Speed',target_speed)
                put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES[typ]);word('wDamage',100)
                call('AbilityDamageBoost');assert readword('wDamage')==want,(turn,actor_speed,target_speed,typ,readword('wDamage'))
            # Poison/Bug override is a single extra type-chart factor.
            ap,tp=init(turn);aid(turn,'PIERCING_STING');put(tp+'Type1',TYPES['BUG']);put(tp+'Type2',TYPES['GRASS']);put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES['POISON']);word('wDamage',100)
            call('AbilityDamageBoost');assert readword('wDamage')==200 and get('wDamageMultipliers')==20
            # Crit blockers run before guaranteed crit checks; Ruthless doubles final odds.
            for name in ('SHELL_ARMOR','BATTLE_ARMOR','IRON_WILL'):
                init(turn);aid(1-turn,name);call('NatureCriticalHitTest');assert get('wCriticalHitOrOHKO')==0
            ap,tp=init(turn);aid(turn,'RUTHLESS');put(tp+'Status',8);put('wNatureResult',150);call('AbilityRuthless');assert get('wNatureResult')==255
            for typ,base,want in [('NORMAL',100,150),('NORMAL',200,255),('FIRE',100,100)]:
                init(turn);aid(turn,'SHARP_CLAWS');put('w'+('Enemy' if turn else 'Player')+'MoveType',TYPES[typ]);put('wNatureResult',base)
                call('AbilityRuthless');assert get('wNatureResult')==want,(turn,typ,base,get('wNatureResult'))
            for attack,status in [('SHOCK_WAVE',64),('POISON_TAIL',8)]:
                ap,tp=init(turn);move(turn,attack);put(tp+'Status',status);rng(199);call('NatureCriticalHitTest');assert get('wCriticalHitOrOHKO')==1
                for armor in ('SHELL_ARMOR','BATTLE_ARMOR','IRON_WILL'):
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
            for name,stat in [('FORTIFY','Defense'),('SURVIVAL_INSTINCTS','Speed'),('CORNERED','Attack')]:
                ap,tp=init(turn);aid(turn,name);word(ap+'HP',54);call('AbilityLowHPBoth');mod='w'+('Enemy' if turn else 'Player')+'Mon'+stat+'Mod';assert get(mod)==7
                word(ap+'HP',53);call('AbilityLowHPBoth');assert get(mod)==8
                call('AbilityLowHPBoth');assert get(mod)==8
                put('wAbilitySide',turn);call('AbilityEntry');assert get(mod)==8
            # Direct KO healing only, capped and synchronized with the party.
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'SCAVENGER');word(ap+'HP',80);word(tp+'HP',0)
            call('AbilityAfterHit');call('AbilityAfterAction');assert readword(ap+'HP')==120
            party='wEnemyMon1' if turn else 'wPartyMon1';assert readword(party+'HP')==120
            ap,tp=init(turn);aid(turn,'SCAVENGER');word(ap+'HP',80);word(tp+'HP',0);call('AbilityAfterAction');assert readword(ap+'HP')==80
            # Actual poison-tick routine heals instead of inflicting poison damage.
            for hp,want in [(80,100),(150,160),(0,0)]:
                ap,tp=init(turn);aid(turn,'POISON_HEAL');word(ap+'HP',hp);put(ap+'Status',8)
                if hp: call('HandlePoisonBurnLeechSeed');assert readword(ap+'HP')==want,(turn,hp,readword(ap+'HP'))
                else: call('AbilityPoisonHeal');assert readword(ap+'HP')==0
                assert get(ap+'Status')==8
            ap,tp=init(turn);aid(turn,'POISON_HEAL');word(ap+'HP',80);put(ap+'Status',16);call('AbilityPoisonHeal');assert get('wAbilityCheckResult')==0 and readword(ap+'HP')==80
            for attack,penalty in [('TACKLE',38),('EMBER',0),('GROWL',0)]:
                init(turn);move(turn,attack);aid(turn,'HUSTLE');accuracy='w'+('Enemy' if turn else 'Player')+'MoveAccuracy'
                expected=get(accuracy)-penalty;call('CalcHitChance')
                assert get(accuracy)==expected,(turn,attack,get(accuracy),expected)
            ap,tp=init(turn);aid(turn,'POISON_HEAL');word(ap+'HP',80);put(ap+'Status',8)
            put('w'+('Enemy' if turn else 'Player')+'BattleStatus3',1)
            counter='w'+('Enemy' if turn else 'Player')+'ToxicCounter';put(counter,3)
            call('HandlePoisonBurnLeechSeed');assert readword(ap+'HP')==100 and get(counter)==3
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
            for attack,blocked in [('SLUDGE',True),('FLASH',True),('SCALD',True),('TWINEEDLE',False),('DOUBLESLAP',False),('DRAIN_PUNCH',False),('TOXIC',False)]:
                init(turn);move(turn,attack);aid(turn,'SHEER_FORCE');call('AbilityEffectGate');assert bool(get('wAbilityCheckResult'))==blocked,(turn,attack,get('wAbilityCheckResult'))
            # Recoil uses actual damage to a substitute, including on its breaking hit.
            for damage,subhp,want in [(80,25,158),(8,25,159),(300,25,158)]:
                ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'RAMPAGE');put('wCustomTargetHadSub',1)
                put('w'+('Player' if turn else 'Enemy')+'SubstituteHP',subhp);call('AbilityCaptureRampageSubHP');word('wDamage',damage)
                call('AbilityRampage');assert readword(ap+'HP')==want,(turn,damage,subhp,readword(ap+'HP'))
            # Shield Dust also blocks ability-granted added poison/burn/flinch.
            ap,tp=init(turn);move(turn,'VINE_WHIP');aid(turn,'POISON_LEAF');aid(1-turn,'SHIELD_DUST');rng(0);call('AbilityAfterHit');assert get(tp+'Status')==0
            # Direct and secondary burns are blocked by the Water Veil status gate.
            ap,tp=init(turn);aid(1-turn,'WATER_VEIL');put('wCustomSide',1-turn);put('wCustomDelta',16);call('UtilityInflictStatus');assert get(tp+'Status')==0
            # Accuracy effects, including simultaneous Compound Eyes / Wonder Skin.
            for stat,delta,blocked in [(4,255,True),(4,1,False),(1,255,False)]:
                init(turn);aid(1-turn,'KEEN_EYE');put('wCustomSide',1-turn);put('wCustomStat',stat);put('wCustomDelta',delta)
                call('AbilityKeenEyeCustom');assert bool(get('wAbilityCheckResult'))==blocked,(turn,stat,delta)
            init(turn);aid(1-turn,'KEEN_EYE');put('wCustomStat',4);call('AbilityKeenEyeTarget');assert get('wAbilityCheckResult')==1
            # Exercise the actual legacy accuracy-drop routine as well.
            bank,address=syms['MoveHitTest'];original=game.memory[bank,address]
            patch('MoveHitTest',[0xc9])
            delay_bank,delay_address=syms['DelayFrames'];original_delay=game.memory[delay_bank,delay_address]
            patch('DelayFrames',[0xc9])
            frame_bank,frame_address=syms['DelayFrame'];original_frame=game.memory[frame_bank,frame_address]
            patch('DelayFrame',[0xc9])
            done_bank,done_address=syms['UpdateLoweredStatDone'];original_done=game.memory[done_bank,done_address]
            patch('UpdateLoweredStatDone',[0xc9])
            for target_ability,attack,stat,want in [('KEEN_EYE','SMOKESCREEN','Accuracy',7),(None,'SMOKESCREEN','Accuracy',6),('MIND_READER','SMOKESCREEN','Accuracy',7),('CLOUD_NINE','SMOKESCREEN','Accuracy',7),('CLOUD_NINE','GROWL','Attack',7),('CLEAR_BODY','GROWL','Attack',7),('MIND_READER','GROWL','Attack',6)]:
                init(turn);move(turn,attack);aid(1-turn,target_ability)
                call('StatModifierDownEffect')
                assert get('w'+('Player' if turn else 'Enemy')+'Mon'+stat+'Mod')==want,(turn,target_ability,attack)
            game.memory[bank,address]=original
            game.memory[delay_bank,delay_address]=original_delay
            game.memory[frame_bank,frame_address]=original_frame
            game.memory[done_bank,done_address]=original_done
            for actor,target,attack,want in [('MYCELIUM',None,'SING',255),('MYCELIUM','WONDER_SKIN','SING',255),('MYCELIUM',None,'TACKLE',100),('POLLEN',None,'SLEEP_POWDER',151),('POLLEN','WONDER_SKIN','SPORE',75),('POLLEN',None,'POISON_GAS',100),('ECHOLOCATION',None,'SING',151),('ECHOLOCATION','WONDER_SKIN','SING',75),('ECHOLOCATION',None,'TACKLE',151),('PERFORMER',None,'SING',120),('PERFORMER','WONDER_SKIN','SING',60),('PERFORMER',None,'SNARL',120),('PERFORMER',None,'TACKLE',100),('COMPOUND_EYES',None,'SLEEP_POWDER',130),(None,'WONDER_SKIN','SLEEP_POWDER',50),('COMPOUND_EYES','WONDER_SKIN','SLEEP_POWDER',65),(None,'WONDER_SKIN','TACKLE',100)]:
                init(turn);move(turn,attack);aid(turn,actor);aid(1-turn,target);game.memory[0xff97:0xff99]=[0,100]
                call('AbilityAccuracy');assert bytes(game.memory[0xff97:0xff99])==bytes([0,want]),(actor,target,attack,bytes(game.memory[0xff97:0xff99]))
        # Psyduck and Golduck: damage, reactive boosts, stat protection and confusion.
        for turn in (0,1):
            for attack,want in [('FLAMETHROWER',20),('TACKLE',40)]:
                init(turn);move(turn,attack);aid(1-turn,'DAMP');call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,readword('wDamage'))
            for attack,blocked in [('EXPLOSION',True),('SELFDESTRUCT',True),('TACKLE',False)]:
                init(turn);move(turn,attack);aid(1-turn,'DAMP');call('AbilityDampCheck');assert bool(get('wAbilityCheckResult'))==blocked,(turn,attack)
            for attack,blocked in [('EXPLOSION',True),('SELFDESTRUCT',True),('TACKLE',False)]:
                init(turn);move(turn,attack);aid(1-turn,'DAMP');rng(0);call('MoveHitTest');assert bool(get('wMoveMissed'))==blocked,(turn,attack,'actual hit check')
            for attack,want in [('PSYCHIC_M',8),('TACKLE',7)]:
                init(turn);move(turn,attack);aid(1-turn,'HEADACHE');call('AbilityAfterHit');assert get('w'+('Player' if turn else 'Enemy')+'MonSpecialMod')==want,(turn,attack,'headache')
                call('AbilityAfterHit');assert get('w'+('Player' if turn else 'Enemy')+'MonSpecialMod')==want
            for attack,want in [('WATER_GUN',9),('TACKLE',7)]:
                init(turn);move(turn,attack);aid(1-turn,'SWIFT_SWIM');call('AbilityAfterHit');assert get('w'+('Player' if turn else 'Enemy')+'MonSpeedMod')==want,(turn,attack,'swift swim')
            for stat in range(6):
                init(turn);aid(1-turn,'CLOUD_NINE');put('wCustomSide',1-turn);put('wCustomStat',stat);put('wCustomDelta',255);call('AbilityKeenEyeCustom');assert get('wAbilityCheckResult')==1,(turn,stat)
                put('wCustomSide',turn);aid(turn,'CLOUD_NINE');call('AbilityKeenEyeCustom');assert get('wAbilityCheckResult')==0,(turn,'self',stat)
                put('wCustomStat',stat);call('AbilityKeenEyeTarget');assert get('wAbilityCheckResult')==1,(turn,'legacy',stat)
            for stat in (0,4):
                init(turn);aid(1-turn,'MIND_READER');put('wCustomStat',stat);call('AbilityKeenEyeTarget');assert bool(get('wAbilityCheckResult'))==(stat==4)
            for target_ability,attack,roll,want in [(None,'PSYCHIC_M',0,True),(None,'PSYCHIC_M',40,False),('SHIELD_DUST','PSYCHIC_M',0,False),(None,'TACKLE',0,False)]:
                init(turn);move(turn,attack);aid(turn,'CONFOUNDING');aid(1-turn,target_ability);rng(roll,0);call('AbilityAfterHit')
                assert bool(get('w'+('Player' if turn else 'Enemy')+'BattleStatus1')&128)==want,(turn,target_ability,attack,roll)
            for chosen in range(6):
                init(turn);aid(turn,'UNSTABLE');word(('wEnemyMon' if turn else 'wBattleMon')+'HP',79);put('wAbilitySide',turn);rng(chosen);call('AbilityLowHP')
                assert game.memory[addr('w'+('Enemy' if turn else 'Player')+'MonStatMods')+chosen]==8,(turn,chosen,'unstable')
                call('AbilityLowHP');assert game.memory[addr('w'+('Enemy' if turn else 'Player')+'MonStatMods')+chosen]==8
        # Growlithe/Arcanine abilities on both sides, including PP-Up boundaries.
        for turn in (0,1):
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'LOYALTY');word(ap+'HP',80);word(tp+'HP',0);call('AbilityAfterHit');call('AbilityAfterAction');assert readword(ap+'HP')==112,(turn,'loyalty',readword(ap+'HP'))
            party='wEnemyMon1' if turn else 'wPartyMon1';assert readword(party+'HP')==112
            ap,tp=init(turn);aid(turn,'LOYALTY');word(ap+'HP',80);word(tp+'HP',0);call('AbilityAfterAction');assert readword(ap+'HP')==80
            for hp,want in [(1,33),(150,160),(0,0)]:
                ap,tp=init(turn);aid(turn,'LOYALTY');put('wAbilitySide',turn);word(ap+'HP',hp)
                if hp:call('AbilityHealFifth');assert readword(ap+'HP')==want,(turn,hp,readword(ap+'HP'))
            for attack,ups,want in [('DOUBLE_EDGE',0,125),('DOUBLE_EDGE',1,100),('FIRE_BLAST',3,125),('FLAMETHROWER',0,100)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'LEGENDARY');put(ap+'PP',(ups<<6)|1);word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,ups,readword('wDamage'))
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'LEGENDARY');put('w'+('Enemy' if turn else 'Player')+'BattleStatus3',8);word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==125
            for attack,want in [('DOUBLE_EDGE',8),('TACKLE',7)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'MOMENTUM');put('wAbilityHit',8);call('AbilitySandAfterAction');mod='w'+('Enemy' if turn else 'Player')+'MonSpeedMod';assert get(mod)==want,(turn,attack,get(mod));call('AbilitySandAfterAction');assert get(mod)==want
            ap,tp=init(turn);aid(turn,'LOYALTY');put('wAbilitySide',turn);word(ap+'HP',80);word(ap+'MaxHP',157);call('AbilityHealFifth');assert readword(ap+'HP')==111
            for attack,want in [('FLAMETHROWER',80),('TACKLE',100)]:
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'ELEGANT_MANE');word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,readword('wDamage'))
            ap,tp=init(turn);move(turn,'PSYCHIC_M');aid(1-turn,'ELEGANT_MANE');put('wUnusedC000',16);word('wDamage',100);call('AbilityExistingFixedDamageModifiers');assert readword('wDamage')==80
            for attack,blocked in [('CONFUSE_RAY',True),('SUPERSONIC',True),('GROWL',False)]:
                init(turn);move(turn,attack);aid(1-turn,'STEADFAST');rng(0);call('MoveHitTest');assert bool(get('wMoveMissed'))==blocked,(turn,attack,'steadfast')
            for attack,blocked in [('PSYBEAM',True),('BITE',True),('FLAMETHROWER',False)]:
                init(turn);move(turn,attack);aid(1-turn,'STEADFAST');call('AbilityEffectGate');assert bool(get('wAbilityCheckResult'))==blocked,(turn,attack,'secondary')
            init(turn);aid(turn,'STEADFAST');n='w'+('Enemy' if turn else 'Player')+'BattleStatus1';put(n,136);call('AbilityBeforeAction');assert get(n)&136==0
            init(turn);aid(1-turn,'STEADFAST');put('wCustomSide',1-turn);call('CustomConfuse');assert not(get('w'+('Player' if turn else 'Enemy')+'BattleStatus1')&128)
            init(turn);move(turn,'PSYCHIC_M');aid(turn,'CONFOUNDING');aid(1-turn,'STEADFAST');rng(0);call('AbilityAfterHit');assert not(get('w'+('Player' if turn else 'Enemy')+'BattleStatus1')&128)
            # The canine Intimidate can affect a target already intimidated, once per holder.
            init(turn);aid(turn,'GROWL_INTIMIDATE');put('wAbilitySide',turn);game.memory[addr('wAbilityFlags')+(0 if turn else 6)]|=128;call('AbilityIntimidate');mod='w'+('Player' if turn else 'Enemy')+'MonSpeedMod';assert get(mod)==6,(turn,'intimidate',get(mod));put('wAbilitySide',turn);call('AbilityIntimidate');assert get(mod)==6
        # Poliwag family: sleep accuracy, reactive evasion, Water triggers, paralysis and punches.
        for turn in (0,1):
            for attack,want in [('SING',138),('HYPNOSIS',138),('SLEEP_POWDER',138),('SPORE',138),('TACKLE',100),('REST',100)]:
                init(turn);move(turn,attack);aid(turn,'HYPNOTIC');game.memory[0xff97:0xff99]=[0,100];call('AbilityAccuracy');assert bytes(game.memory[0xff97:0xff99])==bytes([0,want]),(turn,attack,'hypnotic')
            for attack,want in [('TACKLE',8),('FLAMETHROWER',7)]:
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'SLIPPERY');call('AbilityAfterHit');mod='w'+('Player' if turn else 'Enemy')+'MonEvasionMod';assert get(mod)==want,(turn,attack,'slippery',get(mod));call('AbilityAfterHit');assert get(mod)==want
            ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'SLIPPERY');put('wCustomTargetHadSub',1);call('AbilityAfterHit');assert get('w'+('Player' if turn else 'Enemy')+'MonEvasionMod')==7
            for attack,hp,want in [('WATER_GUN',80,100),('WATER_GUN',150,160),('TACKLE',80,80)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'HYDRATION');word(ap+'HP',hp);put('wAbilityHit',8);call('AbilitySandAfterAction');assert readword(ap+'HP')==want,(turn,attack,'hydration',readword(ap+'HP'))
                party='wEnemyMon1' if turn else 'wPartyMon1'
                if want!=hp:assert readword(party+'HP')==want
            for attack,want in [('WATER_GUN',8),('TACKLE',7)]:
                init(turn);move(turn,attack);aid(turn,'POWER_SWIM');put('wAbilityHit',8);call('AbilitySandAfterAction');mod='w'+('Enemy' if turn else 'Player')+'MonAttackMod';assert get(mod)==want;(call('AbilitySandAfterAction'));assert get(mod)==want
            for attack,roll,target_ability,sub,want in [('MEGA_PUNCH',0,None,0,64),('MEGA_PUNCH',39,None,0,64),('MEGA_PUNCH',40,None,0,0),('TACKLE',0,None,0,0),('MEGA_PUNCH',0,'SHIELD_DUST',0,0),('MEGA_PUNCH',0,None,1,0)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'WRESTLER');aid(1-turn,target_ability);put('wCustomTargetHadSub',sub);rng(roll);call('AbilityAfterHit');assert get(tp+'Status')==want,(turn,attack,roll,target_ability,sub,get(tp+'Status'))
            for attack,want in [('MEGA_PUNCH',125),('FIRE_PUNCH',125),('DRAIN_PUNCH',125),('KARATE_CHOP',100),('TACKLE',100)]:
                init(turn);move(turn,attack);aid(turn,'IRON_FIST');word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,'iron fist',readword('wDamage'))
        # Abra family: special protection, Psychic move trigger, status accuracy and defense bypass.
        bounce_patches={}
        for n in ('PlayCurrentMoveAnimation','PlayCurrentMoveAnimation2','DelayFrames'):
            b,a=syms[n];bounce_patches[n]=game.memory[b,a];patch(n,[0xc9])
        for turn in (0,1):
            for attack,want in [('FLAMETHROWER',80),('TACKLE',100)]:
                init(turn);move(turn,attack);aid(1-turn,'MENTAL_SHIELD');word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,'mental shield')
            init(turn);move(turn,'FLAMETHROWER');aid(1-turn,'MENTAL_SHIELD');put('wUnusedC000',16);word('wDamage',100);call('AbilityExistingFixedDamageModifiers');assert readword('wDamage')==80
            for attack,want in [('PSYCHIC_M',8),('TACKLE',7)]:
                init(turn);move(turn,attack);aid(turn,'TELEPATHY');put('wAbilityHit',8);call('AbilitySandAfterAction');mod='w'+('Enemy' if turn else 'Player')+'MonEvasionMod';assert get(mod)==want;(call('AbilitySandAfterAction'));assert get(mod)==want
            for attack,want in [('SING',138),('SWORDS_DANCE',138),('PSYCHIC_M',100),('TACKLE',100)]:
                init(turn);move(turn,attack);aid(turn,'GENIUS');game.memory[0xff97:0xff99]=[0,100];call('AbilityAccuracy');assert bytes(game.memory[0xff97:0xff99])==bytes([0,want]),(turn,attack,'genius')
            for attack,want in [('PSYCHIC_M',80),('TACKLE',100),('CONFUSION',80)]:
                init(turn);move(turn,attack);aid(turn,'SPOON_BENDER');call('AdjustPiercingBeakDefense',BC=100);assert game.register_file.B*256+game.register_file.C==want,(turn,attack,'spoon')
            # Actual effect dispatch reflects target status and stat drops exactly once.
            for attack in ('SING','POISONPOWDER','THUNDER_WAVE','WILL_O_WISP'):
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'MAGIC_BOUNCE');rng(0,2);before=bytes(game.memory[addr('w'+('Player' if turn else 'Enemy')+'MoveNum'):addr('w'+('Player' if turn else 'Enemy')+'MoveNum')+6]);call('_JumpMoveEffect')
                assert get(ap+'Status')!=0 and get(tp+'Status')==0,(turn,attack,'bounce',get(ap+'Status'),get(tp+'Status'))
                assert get('turn')==turn and bytes(game.memory[addr('w'+('Player' if turn else 'Enemy')+'MoveNum'):addr('w'+('Player' if turn else 'Enemy')+'MoveNum')+6])==before,(turn,attack,'restore')
            ap,tp=init(turn);move(turn,'GROWL');aid(1-turn,'MAGIC_BOUNCE');rng(0);call('_JumpMoveEffect');assert get('w'+('Enemy' if turn else 'Player')+'MonAttackMod')==6 and get('w'+('Player' if turn else 'Enemy')+'MonAttackMod')==7,(turn,'growl')
            ap,tp=init(turn);move(turn,'LEECH_SEED');aid(1-turn,'MAGIC_BOUNCE');rng(0);call('_JumpMoveEffect');assert get('w'+('Enemy' if turn else 'Player')+'BattleStatus2')&128 and not(get('w'+('Player' if turn else 'Enemy')+'BattleStatus2')&128),(turn,'leech seed')
            ap,tp=init(turn);move(turn,'DISABLE');aid(1-turn,'MAGIC_BOUNCE');put(ap+'Moves',MOVES['TACKLE']);put(ap+'PP',20);put('wPlayerDisabledMove',0);put('wEnemyDisabledMove',0);rng(0);call('_JumpMoveEffect');assert get('w'+('Enemy' if turn else 'Player')+'DisabledMove')!=0 and get('w'+('Player' if turn else 'Enemy')+'DisabledMove')==0,(turn,'disable')
            for attack in ('KINESIS','SPLASH'):
                init(turn);move(turn,attack);aid(1-turn,'MAGIC_BOUNCE');rng(0);call('_JumpMoveEffect');assert get('w'+('Enemy' if turn else 'Player')+'MonAccuracyMod')==6,(turn,attack,'bounce custom')
            init(turn);move(turn,'SWORDS_DANCE');aid(1-turn,'MAGIC_BOUNCE');rng(0);call('_JumpMoveEffect');assert get('w'+('Enemy' if turn else 'Player')+'MonAttackMod')==9
            ap,tp=init(turn);move(turn,'POISONPOWDER');aid(turn,'MAGIC_BOUNCE');aid(1-turn,'MAGIC_BOUNCE');rng(0);call('_JumpMoveEffect');assert get(ap+'Status')==8 and get(tp+'Status')==0,(turn,'double bounce')
        for n,original in bounce_patches.items():
            b,a=syms[n];game.memory[b,a]=original
        # Machop family: sure hits, status-dependent Attack, damage and hit count.
        for turn in (0,1):
            for no_guard_side in (turn,1-turn):
                for airborne in (False,True):
                    ap,tp=init(turn);move(turn,'TACKLE');aid(no_guard_side,'NO_GUARD');put('w'+('Player' if turn else 'Enemy')+'BattleStatus1',64 if airborne else 0);rng(255);call('MoveHitTest');assert get('wMoveMissed')==0,(turn,no_guard_side,airborne)
            init(turn);move(turn,'TACKLE');aid(turn,'NO_GUARD');put('wMoveMissed',1);rng(255);call('MoveHitTest');assert get('wMoveMissed')==1,(turn,'immunity preserved')
            for status in (8,16,32,64,1):
                ap,tp=init(turn);aid(turn,'GUTS');put(ap+'Status',status);put('wAbilitySide',turn);call('AbilityGuts');mod='w'+('Enemy' if turn else 'Player')+'MonAttackMod';assert get(mod)==8,(turn,status,'guts');call('AbilityGuts');assert get(mod)==8;put(ap+'Status',0);call('AbilityGuts');assert get(mod)==7,(turn,status,'guts cure')
            ap,tp=init(turn);aid(turn,'GUTS');put(ap+'Status',16);put('wAbilitySide',turn);call('AbilityGuts')
            animation_bank,animation_address=syms['PlayCurrentMoveAnimation'];animation_original=game.memory[animation_bank,animation_address];patch('PlayCurrentMoveAnimation',[0xc9])
            call('HazeEffect_');call('AbilityQuickFeetBoth');assert get('w'+('Enemy' if turn else 'Player')+'MonAttackMod')==7,(turn,'guts haze')
            game.memory[animation_bank,animation_address]=animation_original
            for attack,offense,defense,want in [('TACKLE',100,101,120),('TACKLE',101,101,100),('TACKLE',256,255,100),('FLAMETHROWER',100,200,100)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'IRON_GRIP');word(ap+'Attack',offense);word(tp+'Defense',defense);word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,offense,defense,readword('wDamage'))
            for attack,ability_name,roll,want in [('BARRAGE','FOUR_ARMS',0,5),('BARRAGE',None,0,2),('DOUBLESLAP','FOUR_ARMS',0,2),('TRIPLE_KICK','FOUR_ARMS',0,3)]:
                init(turn);move(turn,attack);aid(turn,ability_name);rng(roll);call('TwoToFiveAttacksEffect');assert get('w'+('Enemy' if turn else 'Player')+'NumHits')==want,(turn,attack,ability_name,get('w'+('Enemy' if turn else 'Player')+'NumHits'))
            for active,want in [(True,0),(False,1)]:
                init(turn);move(turn,'TRIPLE_KICK');aid(turn,'FOUR_ARMS' if active else None);rng(255);call('SequenceTripleAccuracy');assert get('wMoveMissed')==want,(turn,'triple kick',active)
            for attack,roll,target,sub,want in [('TACKLE',0,None,0,6),('TACKLE',19,None,0,6),('TACKLE',20,None,0,7),('FLAMETHROWER',0,None,0,7),('TACKLE',0,'SHIELD_DUST',0,7),('TACKLE',0,None,1,7)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'GRAPPLER');aid(1-turn,target);put('wCustomTargetHadSub',sub);rng(roll);call('AbilityAfterHit');mod='w'+('Player' if turn else 'Enemy')+'MonDefenseMod';assert get(mod)==want,(turn,attack,roll,target,sub,get(mod))
            for attack,want in [('LOW_KICK',8),('TACKLE',7)]:
                init(turn);move(turn,attack);aid(turn,'BODYBUILDER');put('wAbilityHit',8);call('AbilitySandAfterAction');mod='w'+('Enemy' if turn else 'Player')+'MonDefenseMod';assert get(mod)==want;call('AbilitySandAfterAction');assert get(mod)==want
        # Bellsprout family: Poison attacks, knockouts, contact reactions and stat comparison.
        for turn in (0,1):
            for attack,roll,target,sub,want in [('POISON_STING',0,None,0,6),('POISON_STING',49,None,0,6),('POISON_STING',50,None,0,7),('TACKLE',0,None,0,7),('POISON_STING',0,'SHIELD_DUST',0,7),('POISON_STING',0,None,1,7)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'ACIDIC');aid(1-turn,target);put('wCustomTargetHadSub',sub);rng(roll);call('AbilityAfterHit');mod='w'+('Player' if turn else 'Enemy')+'MonDefenseMod';assert get(mod)==want,(turn,attack,roll,target,sub,'acidic',get(mod))
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'CARNIVOROUS');word(ap+'HP',80);word(tp+'HP',0);call('AbilityAfterHit');call('AbilityAfterAction');assert readword(ap+'HP')==112,(turn,'carnivorous',readword(ap+'HP'))
            party='wEnemyMon1' if turn else 'wPartyMon1';assert readword(party+'HP')==112
            ap,tp=init(turn);aid(turn,'CARNIVOROUS');word(ap+'HP',80);word(tp+'HP',0);call('AbilityAfterAction');assert readword(ap+'HP')==80
            for attack,roll,sub,holder_hp,want in [('TACKLE',0,0,160,6),('TACKLE',39,0,160,6),('TACKLE',40,0,160,7),('FLAMETHROWER',0,0,160,7),('TACKLE',0,1,160,7),('TACKLE',0,0,0,6)]:
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'STICKY_TRAP');put('wCustomTargetHadSub',sub);word(tp+'HP',holder_hp);rng(roll);call('AbilityAfterHit');mod='w'+('Enemy' if turn else 'Player')+'MonSpeedMod';assert get(mod)==want,(turn,attack,roll,sub,holder_hp,'sticky trap',get(mod))
            for attack,defense,special,want in [('POISON_STING',101,100,125),('POISON_STING',100,100,100),('POISON_STING',255,256,100),('POISON_STING',256,255,125),('TACKLE',200,100,100)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'DIGESTIVE_ACID');word(tp+'Defense',defense);word(tp+'Special',special);word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,defense,special,readword('wDamage'))
        # Tentacool family: stat protection, reactive poison, physical defense and draining moves.
        for turn in (0,1):
            for stat in range(6):
                init(turn);aid(1-turn,'CLEAR_BODY');put('wCustomSide',1-turn);put('wCustomStat',stat);put('wCustomDelta',255);call('AbilityKeenEyeCustom');assert get('wAbilityCheckResult')==1,(turn,stat,'clear body')
                call('AbilityKeenEyeTarget');assert get('wAbilityCheckResult')==1
            init(turn);aid(turn,'CLEAR_BODY');put('wCustomSide',turn);put('wCustomStat',0);put('wCustomDelta',255);call('AbilityKeenEyeCustom');assert get('wAbilityCheckResult')==0
            init(turn);aid(turn,'INTIMIDATE');aid(1-turn,'CLEAR_BODY');put('wAbilitySide',turn);call('AbilityIntimidate');assert get('w'+('Player' if turn else 'Enemy')+'MonSpeedMod')==7,(turn,'intimidate')
            for reactive in ('STICKY_TRAP','DUST_CLOUD'):
                init(turn);move(turn,'TACKLE');aid(turn,'CLEAR_BODY');aid(1-turn,reactive);rng(0);call('AbilityAfterHit');assert get('w'+('Enemy' if turn else 'Player')+'Mon'+('Speed' if reactive=='STICKY_TRAP' else 'Accuracy')+'Mod')==7,(turn,reactive,'clear body')
            for attack,roll,sub,want in [('TACKLE',0,0,8),('TACKLE',39,0,8),('TACKLE',40,0,0),('EARTHQUAKE',0,0,8),('FLAMETHROWER',0,0,0),('TACKLE',0,1,0)]:
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'STINGING_SKIN');put('wCustomTargetHadSub',sub);rng(roll);call('AbilityAfterHit');assert get(ap+'Status')==want,(turn,attack,roll,sub,'stinging skin',get(ap+'Status'))
            for attack,want in [('TACKLE',80),('FLAMETHROWER',100)]:
                init(turn);move(turn,attack);aid(1-turn,'JELLY_BODY');word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,'jelly body')
            init(turn);move(turn,'TACKLE');aid(1-turn,'JELLY_BODY');put('wUnusedC000',16);word('wDamage',100);call('AbilityExistingFixedDamageModifiers');assert readword('wDamage')==80
            for attack in ('ABSORB','MEGA_DRAIN','DRAIN_PUNCH','DREAM_EATER','SHADOW_LEECH'):
                for source,expected in [(None,60),('MAGIC_GUARD',80)]:
                    ap,tp=init(turn);move(turn,attack);aid(turn,source);aid(1-turn,'LIQUID_OOZE');word(ap+'HP',80);word('wDamage',40);call('DrainHPEffect_');assert readword(ap+'HP')==expected,(turn,attack,source,'ooze drain',readword(ap+'HP'))
            ap,tp=init(turn);move(turn,'ABSORB');aid(1-turn,'LIQUID_OOZE');word(ap+'HP',300);word(ap+'MaxHP',400);word('wDamage',400);call('DrainHPEffect_');assert readword(ap+'HP')==100,(turn,'16-bit ooze',readword(ap+'HP'))
            # Leech Seed damages the seeder by the amount it would have healed.
            anim_patches={}
            for n in ('PlayMoveAnimation','UpdateCurMonHPBar'):
                bank,address=syms[n];anim_patches[n]=game.memory[bank,address];patch(n,[0xc9])
            for holder_ability,seeder_ability,seeder_hp,expected in [('LIQUID_OOZE',None,80,70),('LIQUID_OOZE','MAGIC_GUARD',80,80),('LIQUID_OOZE',None,5,0),(None,None,80,90)]:
                holder,seeder=init(turn);aid(turn,holder_ability);aid(1-turn,seeder_ability);word(seeder+'HP',seeder_hp);put('w'+('Enemy' if turn else 'Player')+'BattleStatus2',128);call('HandlePoisonBurnLeechSeed');assert readword(holder+'HP')==150 and readword(seeder+'HP')==expected,(turn,holder_ability,seeder_ability,seeder_hp,readword(holder+'HP'),readword(seeder+'HP'))
            for n,original in anim_patches.items():
                bank,address=syms[n];game.memory[bank,address]=original
        # Geodude family: ground and poison immunity, full-HP survival and streaks.
        for turn in (0,1):
            for attack,blocked in [('EARTHQUAKE',True),('BONE_CLUB',True),('TACKLE',False)]:
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'LEVITATE');rng(0);call('MoveHitTest');assert bool(get('wMoveMissed'))==blocked,(turn,attack,'levitate')
                put('wUnusedC000',8 if turn==0 else 0);call('AIGetTypeEffectiveness');assert bool(get('wTypeEffectiveness')==0)==blocked,(turn,attack,'levitate AI')
            ap,tp=init(turn);move(turn,'EARTHQUAKE');aid(turn,'NO_GUARD');aid(1-turn,'LEVITATE');rng(0);call('MoveHitTest');assert get('wMoveMissed')==1
            for attack in ('POISONPOWDER','TOXIC','POISON_STING'):
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'IMMUNITY');call('AbilityDustOnly');assert get('wAbilityCheckResult')==1,(turn,attack,'immunity legacy')
            for entry in ('AbilityInflictOrdinaryStatus','UtilityInflictStatus'):
                ap,tp=init(turn);aid(1-turn,'IMMUNITY');put('wCustomSide',1-turn);put('wCustomDelta',8);call(entry);assert get(tp+'Status')==0,(turn,entry,'immunity')
            for status,want in [(8,0),(16,16)]:
                ap,tp=init(turn);aid(turn,'IMMUNITY');put(ap+'Status',status);put('wAbilitySide',turn);put('w'+('Enemy' if turn else 'Player')+'BattleStatus3',1);put('w'+('Enemy' if turn else 'Player')+'ToxicCounter',4);call('AbilityEntrySpeed');assert get(ap+'Status')==want,(turn,status,'immunity entry')
                if status==8:assert not(get('w'+('Enemy' if turn else 'Player')+'BattleStatus3')&1) and get('w'+('Enemy' if turn else 'Player')+'ToxicCounter')==0
            for status,want in [(8,0),(16,16)]:
                init();metadata('wPartyMon1','GEODUDE',1);put('wPartyMon1Status',status);word('wNatureMonPtr',addr('wPartyMon1'));rng(1);call('AbilityCapsuleApply');assert get('wPartyMon1Type1')>>5==2 and get('wPartyMon1Status')==want,(turn,status,'immunity capsule')
            for hp,maxhp,damage,ohko,sub,want in [(160,160,160,0,0,159),(160,160,400,0,0,159),(159,160,160,0,0,160),(160,160,159,0,0,159),(1,1,10,0,0,0),(160,160,65535,2,0,159),(160,160,160,0,1,160)]:
                ap,tp=init(turn);aid(1-turn,'STURDY');word(tp+'HP',hp);word(tp+'MaxHP',maxhp);word('wDamage',damage);put('wCriticalHitOrOHKO',ohko);put('wCustomTargetHadSub',sub);put('wAbilityHit',32);call('AbilityIncomingDamage');assert readword('wDamage')==want,(turn,hp,maxhp,damage,ohko,sub,readword('wDamage'))
                if ohko and not sub:assert get('wCriticalHitOrOHKO')==0
            for attack,t1,t2,want in [('TACKLE','GROUND','ROCK',125),('FLAMETHROWER','GROUND','GROUND',125),('TACKLE','ROCK','ROCK',100)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'DIGGER');put(tp+'Type1',TYPES[t1]);put(tp+'Type2',TYPES[t2]);word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,t1,t2,'digger')
            for attack,own,foe,want in [('ROCK_THROW',101,100,120),('ROCK_THROW',100,100,100),('ROCK_THROW',255,256,100),('ROCK_THROW',256,255,120),('TACKLE',200,100,100)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'HEAVYWEIGHT');word(ap+'Defense',own);word(tp+'Defense',foe);word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,own,foe,'heavyweight')
            init(turn);aid(turn,'ROLLOUT');move(turn,'EARTHQUAKE');slot=addr('wRolloutStacks')+turn
            for count in range(4):
                word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==100+count*10,(turn,count,'rollout',readword('wDamage'));put('wAbilityHit',8);call('AbilityRolloutAfterAction');assert game.memory[slot]==count+1
            move(turn,'ROCK_THROW');word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==140
            put('wAbilityHit',8);put('wMoveMissed',1);call('AbilityRolloutAfterAction');assert game.memory[slot]==0
            game.memory[slot]=3;move(turn,'TACKLE');put('wMoveMissed',0);put('wAbilityHit',8);call('AbilityRolloutAfterAction');assert game.memory[slot]==0
            game.memory[slot]=200;move(turn,'EARTHQUAKE');word('wDamage',999);call('AbilityModifyDamage');assert readword('wDamage')==20979,(turn,'rollout 16bit',readword('wDamage'))
            game.memory[slot]=10;word('wDamage',50000);call('AbilityModifyDamage');assert readword('wDamage')==65535,(turn,'rollout cap')
            game.memory[slot]=4;put('wAbilitySide',turn);call('AbilityEntry');assert game.memory[slot]==0
        # Ponyta family: reactive burn, opposing stat changes, speed and hit reactions.
        for turn in (0,1):
            for attack,roll,sub,actor_ability,actor_fire,want in [('TACKLE',0,0,None,False,16),('TACKLE',39,0,None,False,16),('TACKLE',40,0,None,False,0),('EARTHQUAKE',0,0,None,False,16),('FLAMETHROWER',0,0,None,False,0),('TACKLE',0,1,None,False,0),('TACKLE',0,0,'WATER_VEIL',False,0),('TACKLE',0,0,None,True,0)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,actor_ability);aid(1-turn,'FLAME_BODY');put('wCustomTargetHadSub',sub)
                if actor_fire:put(ap+'Type1',TYPES['FIRE']);put(ap+'Type2',TYPES['FIRE'])
                rng(roll);call('AbilityAfterHit');assert get(ap+'Status')==want,(turn,attack,roll,sub,actor_ability,actor_fire,'flame body',get(ap+'Status'))
            for attack,actor_speed,target_speed,want in [('FLAMETHROWER',101,100,120),('FLAMETHROWER',100,100,100),('FLAMETHROWER',255,256,100),('FLAMETHROWER',256,255,120),('TACKLE',200,100,100)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'BLAZING_TRAIL');word(ap+'Speed',actor_speed);word(tp+'Speed',target_speed);word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,actor_speed,target_speed,'blazing trail',readword('wDamage'))
            ap,tp=init(turn);move(turn,'EMBER');aid(turn,'BLAZING_TRAIL');word(ap+'Speed',101);word(tp+'Speed',100);put('wUnusedC000',16);word('wDamage',100);call('AbilityExistingFixedDamageModifiers');assert readword('wDamage')==120,(turn,'fixed blazing trail')
            for attack,want in [('TACKLE',8),('FLAMETHROWER',7),('GROWL',7)]:
                init(turn);move(turn,attack);aid(turn,'WILD_CHARGE');put('wAbilityHit',8);call('AbilitySandAfterAction');mod='w'+('Enemy' if turn else 'Player')+'MonSpeedMod';assert get(mod)==want,(turn,attack,'wild charge');call('AbilitySandAfterAction');assert get(mod)==want
            for attack,sub,want in [('TACKLE',0,8),('FLAMETHROWER',0,8),('TACKLE',1,7)]:
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'STAMINA');put('wCustomTargetHadSub',sub);call('AbilityAfterHit');mod='w'+('Player' if turn else 'Enemy')+'MonDefenseMod';assert get(mod)==want,(turn,attack,sub,'stamina');call('AbilityAfterHit');assert get(mod)==(9 if not sub else 7)
            # A successful opponent stage increase triggers once; decreases and capped increases do not.
            for delta,stage,want in [(1,7,8),(-1,7,7),(1,13,7)]:
                init(turn);aid(1-turn,'COMPETITIVE');put('wCustomSide',turn);put('wCustomStat',1);put('wCustomDelta',delta&255);put('w'+('Enemy' if turn else 'Player')+'MonDefenseMod',stage);call('CustomChangeStage');mod='w'+('Player' if turn else 'Enemy')+'MonAttackMod';assert get(mod)==want,(turn,delta,stage,'competitive',get(mod));call('CustomChangeStage');assert get(mod)==want
            # Both holders may react once without looping or corrupting the original stage change.
            init(turn);aid(turn,'COMPETITIVE');aid(1-turn,'COMPETITIVE');put('wCustomSide',turn);put('wCustomStat',1);put('wCustomDelta',1);call('CustomChangeStage');assert get('wPlayerMonAttackMod')==8 and get('wEnemyMonAttackMod')==8 and get('w'+('Enemy' if turn else 'Player')+'MonDefenseMod')==8,(turn,'double competitive')
            # Entry abilities such as Tailwind also raise a stage.
            init(turn);aid(turn,'TAILWIND');aid(1-turn,'COMPETITIVE');put('wAbilitySide',turn);call('AbilityEntrySpeed');assert get('w'+('Player' if turn else 'Enemy')+'MonAttackMod')==8,(turn,'entry competitive')
            # A defending Stamina holder's increase is visible to opposing Competitive.
            init(turn);move(turn,'TACKLE');aid(turn,'COMPETITIVE');aid(1-turn,'STAMINA');call('AbilityAfterHit');assert get('w'+('Enemy' if turn else 'Player')+'MonAttackMod')==8
            # Real legacy stat-up move and a multi-stat custom move each trigger exactly once.
            patches={}
            for n in ('PlayCurrentMoveAnimation','PrintStatText','DelayFrames'):
                bank,address=syms[n];patches[n]=game.memory[bank,address];patch(n,[0xc9])
            init(turn);move(turn,'SWORDS_DANCE');aid(1-turn,'COMPETITIVE');call('StatModifierUpEffect');assert get('w'+('Player' if turn else 'Enemy')+'MonAttackMod')==8,(turn,'legacy competitive')
            init(turn);move(turn,'SWORDS_DANCE');aid(1-turn,'COMPETITIVE');put('w'+('Enemy' if turn else 'Player')+'MonAttackMod',13);call('StatModifierUpEffect');assert get('w'+('Player' if turn else 'Enemy')+'MonAttackMod')==7,(turn,'capped legacy competitive')
            init(turn);move(turn,'BULK_UP');aid(1-turn,'COMPETITIVE');call('_JumpMoveEffect');assert get('w'+('Player' if turn else 'Enemy')+'MonAttackMod')==8,(turn,'bulk up competitive')
            # Psych Up can raise several stages at once, but Competitive still triggers once.
            init(turn);move(turn,'PSYCH_UP');aid(1-turn,'COMPETITIVE');put('w'+('Player' if turn else 'Enemy')+'MonDefenseMod',9);put('w'+('Player' if turn else 'Enemy')+'MonSpeedMod',9);call('UtilityPsychUp');assert get('w'+('Player' if turn else 'Enemy')+'MonAttackMod')==8,(turn,'psych up competitive')
            for n,original in patches.items():
                bank,address=syms[n];game.memory[bank,address]=original
        # Slowpoke / Slowbro: both sides and ordinary/custom stat changes.
        patches={}
        for n in ('PlayCurrentMoveAnimation','PrintStatText','DelayFrames','MoveHitTest','UpdateLoweredStatDone'):
            bank,address=syms[n];patches[n]=game.memory[bank,address];patch(n,[0xc9])
        for turn in (0,1):
            actor='w'+('Enemy' if turn else 'Player')
            target='w'+('Player' if turn else 'Enemy')
            for delta,stage,want in [(1,7,9),(2,7,11),(-1,7,5),(-2,7,3),(2,12,13),(-2,2,1)]:
                init(turn);aid(turn,'SIMPLE');put('wCustomSide',turn);put('wCustomStat',0);put('wCustomDelta',delta&255);put(actor+'MonAttackMod',stage)
                call('CustomChangeStage');assert get(actor+'MonAttackMod')==want,(turn,delta,stage,get(actor+'MonAttackMod'))
                assert get('wCustomDelta')==delta&255
            for attack,want in [('SWORDS_DANCE',11),('GROWL',5)]:
                init(turn);move(turn,attack);side=turn if attack=='SWORDS_DANCE' else 1-turn;aid(side,'SIMPLE')
                call('StatModifierUpEffect' if attack=='SWORDS_DANCE' else 'StatModifierDownEffect')
                assert get(('wEnemyMonAttackMod' if side else 'wPlayerMonAttackMod'))==want,(turn,attack,get(('wEnemyMonAttackMod' if side else 'wPlayerMonAttackMod')))
            # Patient applies only after the opposing side has completed an action.
            for acted,want in [(0,100),(1<<turn,100),(1<<(1-turn),120)]:
                init(turn);move(turn,'TACKLE');aid(turn,'PATIENT');put('wPatientActed',acted);word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,acted,readword('wDamage'))
            init(turn);aid(turn,'PATIENT');put('wPatientActed',1<<(1-turn));put('wUnusedC000',16);word('wDamage',100);call('AbilityFixedDamageModifiers');assert readword('wDamage')==120
            init(turn);call('AbilityPatientMarkAction');assert get('wPatientActed')==1<<turn;call('SequenceNewRound');assert get('wPatientActed')==0
            if turn:
                init(turn);move(turn,'TACKLE');aid(turn,'PATIENT');put('wActionResultOrTookBattleTurn',1);word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==120
            # Oblivious blocks confusion and flinch on the existing Steadfast paths.
            init(turn);aid(turn,'OBLIVIOUS');put(actor+'BattleStatus1',0x88);call('AbilitySteadfastActor');assert get(actor+'BattleStatus1')&0x88==0
            init(turn);aid(1-turn,'OBLIVIOUS');move(turn,'CONFUSE_RAY');call('AbilitySteadfastDirectCheck');assert get('wAbilityCheckResult')==1
            # Unaware uses neutral offense for positive boosts, but not drops.
            for attack in ('TACKLE','EMBER','PSYSHOCK'):
                for stage,stat in [(7,100),(9,200),(5,50)]:
                    ap,tp=init(turn);move(turn,attack);aid(1-turn,'UNAWARE');put(actor+'MonAttackMod',stage);put(actor+'MonSpecialMod',stage);word(ap+'Attack',stat);word(ap+'Special',stat)
                    call('BankedEnemyDamageVars' if turn else 'BankedPlayerDamageVars')
                    # The exported offense byte is H_MULTIPLICAND+1.
                    offense=game.memory[0xff97]
                    assert offense==(50 if stage==5 else 100),(turn,attack,stage,offense)
                    assert get(actor+'MonAttackMod')==stage and get(actor+'MonSpecialMod')==stage and readword(ap+'Attack')==stat and readword(ap+'Special')==stat
            # A positive Attack stage must not alter a negative Special stage,
            # and burn still halves the neutralized Attack.
            ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'UNAWARE');put(actor+'MonAttackMod',9);put(actor+'MonSpecialMod',5);word(ap+'Attack',100);word(ap+'Special',37);put(ap+'Status',16)
            call('UnawareBegin');assert readword(ap+'Attack')==50 and readword(ap+'Special')==37,(turn,readword(ap+'Attack'),readword(ap+'Special'));call('UnawareEnd')
            assert readword(ap+'Attack')==100 and readword(ap+'Special')==37
        for n,original in patches.items():
            bank,address=syms[n];game.memory[bank,address]=original
        # Magnemite / Magneton abilities on both sides.
        patches={}
        for n in ('PlayCurrentMoveAnimation','PrintStatText','DelayFrames','PrintNothingHappenedText'):
            bank,address=syms[n];patches[n]=game.memory[bank,address];patch(n,[0xc9])
        for turn in (0,1):
            actor='w'+('Enemy' if turn else 'Player')
            target='w'+('Player' if turn else 'Enemy')
            # Thunderbolt has 15 max PP; each PP Up adds 3.
            for ups,pp,want in [(0,7,100),(0,8,120),(1,9,100),(1,10,120),(3,12,100),(3,13,120)]:
                ap,tp=init(turn);move(turn,'THUNDERBOLT');aid(turn,'BATTERY');put(ap+'Moves',MOVES['THUNDERBOLT']);put(ap+'PP',(ups<<6)|pp);put('wAbilityPPLeft',pp);word('wDamage',100)
                call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,ups,pp,readword('wDamage'))
            # A transformed user's copied moves always have maximum 5 PP.
            ap,tp=init(turn);move(turn,'THUNDERBOLT');aid(turn,'BATTERY');put(actor+'BattleStatus3',8)
            for pp,want in [(2,100),(3,120)]:
                put('wAbilityPPLeft',pp);word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,'transformed PP',pp)
            # An Electric attack arms the next; intervening other moves do not consume it.
            ap,tp=init(turn);aid(turn,'CHAIN_REACTION');move(turn,'THUNDERBOLT');put('wAbilityHit',8);word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==100
            call('AbilityRolloutAfterAction');word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==120
            move(turn,'TACKLE');call('AbilityRolloutAfterAction');move(turn,'THUNDERBOLT');word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==120
            put('wAbilitySide',turn);call('AbilityEntry');word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==100
            # Only a surviving target hit by a special attack gets Overload, once per battle.
            for attack,want in [('TACKLE',7),('EMBER',8)]:
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'OVERLOAD');call('AbilityAfterHit');assert get(target+'MonSpecialMod')==want,(turn,attack,get(target+'MonSpecialMod'))
                put('wAbilityHit',0);call('AbilityAfterHit');assert get(target+'MonSpecialMod')==want
            # A fainted field holder cannot prevent stage increases.
            ap,tp=init(turn);aid(1-turn,'MAGNETIC_FIELD');word(tp+'HP',0);put('wCustomSide',turn);put('wCustomStat',2);put('wCustomDelta',1);call('CustomChangeStage');assert get(actor+'MonSpeedMod')==8
            for stat,delta,want in [(2,1,7),(5,1,7),(0,1,8),(2,-1,6),(5,-1,6)]:
                init(turn);aid(1-turn,'MAGNETIC_FIELD');put('wCustomSide',turn);put('wCustomStat',stat);put('wCustomDelta',delta&255);call('CustomChangeStage')
                name=actor+'Mon'+('Attack','Defense','Speed','Special','Accuracy','Evasion')[stat]+'Mod';assert get(name)==want,(turn,stat,delta,get(name))
            for attack,stat in [('AGILITY','Speed'),('MINIMIZE','Evasion')]:
                init(turn);move(turn,attack);aid(1-turn,'MAGNETIC_FIELD');call('StatModifierUpEffect');assert get(actor+'Mon'+stat+'Mod')==7,(turn,attack)
            init(turn);move(turn,'PSYCH_UP');aid(1-turn,'MAGNETIC_FIELD');put(target+'MonSpeedMod',10);put(target+'MonEvasionMod',10);put(target+'MonDefenseMod',9);call('UtilityPsychUp')
            assert get(actor+'MonSpeedMod')==7 and get(actor+'MonEvasionMod')==7 and get(actor+'MonDefenseMod')==9,(turn,'psych up')
        for n,original in patches.items():
            bank,address=syms[n];game.memory[bank,address]=original
        # Farfetch'd's five abilities: both actor sides and exact boundaries.
        move_rows=re.findall(r'^\s*move (\w+),\s*\w+,\s*\d+,\s*\w+,\s*(\d+),',(ROOT/'data/moves.asm').read_text(),re.M)
        precision_names={name for name,accuracy in move_rows if int(accuracy)==95}
        move_list=(ROOT/'data/farfetch_ability_moves.asm').read_text().split('AbilityPrecisionMoves:')[1].split('$ff')[0]
        assert {n.strip() for n in move_list.replace('db','').replace('\n','').split(',') if n.strip()}==precision_names
        far_patches={}
        for n in ('MoveHitTest','CantLowerAnymore','UpdateLoweredStatDone'):
            bank,address=syms[n];far_patches[n]=game.memory[bank,address];patch(n,[0xc9])
        for turn in (0,1):
            actor='w'+('Enemy' if turn else 'Player');target='w'+('Player' if turn else 'Enemy')
            for foe,want in [('PIDGEY',100),('FARFETCHD',100),('PIDGEOT',120)]:
                ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'UNDERDOG');put(ap+'Species',ids['FARFETCHD']);put(tp+'Species',ids[foe]);word('wDamage',100);call('AbilityModifyDamage')
                assert readword('wDamage')==want,(turn,foe,readword('wDamage'))
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'UNDERDOG');put(ap+'Species',ids['FARFETCHD']);put(tp+'Species',ids['PIDGEOT']);put('wUnusedC000',16);word('wDamage',100);call('AbilityFixedDamageModifiers');assert readword('wDamage')==120
            for stat,delta,side,want in [(0,-1,1-turn,7),(1,-1,1-turn,7),(2,-1,1-turn,6),(0,1,1-turn,8),(0,-1,turn,6)]:
                init(turn);aid(side,'UNYIELDING');put('wCustomSide',side);put('wCustomStat',stat);put('wCustomDelta',delta&255);call('CustomChangeStage')
                name=('wEnemy' if side else 'wPlayer')+'Mon'+('Attack','Defense','Speed')[stat]+'Mod';assert get(name)==want,(turn,stat,delta,side,get(name))
            for attack,stat in [('GROWL','Attack'),('LEER','Defense')]:
                init(turn);move(turn,attack);aid(1-turn,'UNYIELDING');call('StatModifierDownEffect');assert get(target+'Mon'+stat+'Mod')==7,(turn,attack)
            for hp,critical,want in [(80,1,96),(155,1,160),(80,0,80),(0,1,0)]:
                ap,tp=init(turn);aid(turn,'TASTY_LEEK');word(ap+'HP',hp);put('wCriticalHitOrOHKO',critical);call('AbilityTastyLeek');assert readword(ap+'HP')==want,(turn,hp,critical,readword(ap+'HP'))
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'TASTY_LEEK');word(ap+'HP',80);put('wCriticalHitOrOHKO',1);call('AbilityAfterHit');assert readword(ap+'HP')==96
            for attack,want in [('TACKLE',120),('CUT',120),('SLASH',100),('CONFUSE_RAY',120)]:
                init(turn);move(turn,attack);aid(turn,'PRECISION');word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,readword('wDamage'))
            init(turn);move(turn,'TACKLE');aid(turn,'PRECISION');call('CalcHitChance');assert get(actor+'MoveAccuracy')==255,(turn,get(actor+'MoveAccuracy'))
            for attack,base,want in [('CUT',20,58),('SLASH',240,255),('TACKLE',20,20)]:
                init(turn);move(turn,attack);aid(turn,'RAZOR_EDGE');put('wNatureResult',base);call('AbilityRuthless');assert get('wNatureResult')==want,(turn,attack,get('wNatureResult'))
        for n,original in far_patches.items():
            bank,address=syms[n];game.memory[bank,address]=original
        # Doduo and Dodrio each have their own first slot.
        for turn in (0,1):
            actor='w'+('Enemy' if turn else 'Player');target='w'+('Player' if turn else 'Enemy')
            for value in (0,51,52,127,128,254,255):
                init(turn);aid(turn,'TWIN_BEAKS');rng(value);call('MeasuredEffectRandom');assert game.register_file.A==value//2,(turn,value,game.register_file.A)
            for roll,changed in [(153,True),(154,False)]:
                ap,tp=init(turn);move(turn,'SCALD');aid(turn,'TWIN_BEAKS');rng(roll);call('UtilityHitEffect');assert bool(get(tp+'Status')&16)==changed,(turn,'twin beaks',roll)
            for attack,roll,want in [('BARRAGE',0,3),('BARRAGE',1,3),('BARRAGE',3,5),('DOUBLESLAP',0,2),('TRIPLE_KICK',0,3)]:
                init(turn);move(turn,attack);aid(turn,'TRIPLE_THREAT');rng(roll);call('TwoToFiveAttacksEffect');assert get(actor+'NumHits')==want,(turn,attack,roll,get(actor+'NumHits'))
            init(turn);move(turn,'TRIPLE_KICK');aid(turn,'TRIPLE_THREAT');rng(255);call('SequenceTripleAccuracy');assert get('wMoveMissed')==0
            for attack,want in [('BITE',0),('PSYBEAM',1)]:
                init(turn);move(turn,attack);aid(1-turn,'HEADSTRONG');call('AbilityEffectGate');assert get('wAbilityCheckResult')==want,(turn,attack)
            for attack,speed,foespeed,want in [('TACKLE',101,100,120),('TACKLE',100,100,100),('TACKLE',99,100,100),('EMBER',200,100,100)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'STAMPEDE');word(ap+'Speed',speed);word(tp+'Speed',foespeed);word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,speed,foespeed,readword('wDamage'))
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'STAMPEDE');word(ap+'Speed',101);word(tp+'Speed',100);put('wUnusedC000',16);word('wDamage',100);call('AbilityFixedDamageModifiers');assert readword('wDamage')==120
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'BIRD_RELENTLESS');slot=addr('wRolloutStacks')+turn
            for count in range(4):
                word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==100+count*10,(turn,count,readword('wDamage'))
                # Multiple hits within one attack do not increase its boost.
                word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==100+count*10
                put('wAbilityHit',8);call('AbilityRolloutAfterAction');assert game.memory[slot]==min(3,count+1)
            put('wAbilitySide',1-turn);call('AbilityEntry');assert game.memory[slot]==3
            put('wAbilityHit',8);move(turn,'GROWL');call('AbilityRolloutAfterAction');assert game.memory[slot]==0
            move(turn,'TACKLE');game.memory[slot]=2;put('wMoveMissed',1);call('AbilityRolloutAfterAction');assert game.memory[slot]==0
            init(turn);aid(turn,'HEADSTRONG');put(actor+'BattleStatus1',0x88);call('AbilitySteadfastActor');assert get(actor+'BattleStatus1')&0x88==8
            init(turn);move(turn,'CONFUSE_RAY');aid(1-turn,'HEADSTRONG');call('AbilitySteadfastDirectCheck');assert get('wAbilityCheckResult')==1
            for attack,want in [('PSYCHIC_M',75),('EMBER',100)]:
                init(turn);move(turn,attack);aid(1-turn,'HEADSTRONG');word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,readword('wDamage'))
                init(turn);move(turn,attack);aid(1-turn,'HEADSTRONG');put('wUnusedC000',16);word('wDamage',100);call('AbilityFixedDamageModifiers');assert readword('wDamage')==want,(turn,attack,'fixed',readword('wDamage'))
        # Seel / Dewgong: normal moves change type before damage and STAB.
        for turn in (0,1):
            actor='w'+('Enemy' if turn else 'Player')
            for attack,expected_type,damage in [('TACKLE','ICE',120),('ICE_BEAM','ICE',100),('GROWL','NORMAL',100),('EMBER','FIRE',100)]:
                init(turn);move(turn,attack);aid(turn,'REFRIGERATE');call('AbilityAttempt');assert get(actor+'MoveType')==TYPES[expected_type],(turn,attack,get(actor+'MoveType'))
                word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==damage,(turn,attack,readword('wDamage'))
            ap,tp=init(turn);move(turn,'FACADE');aid(turn,'REFRIGERATE');call('AbilityAttempt');put(ap+'Status',16);word(ap+'Attack',50);word(ap+'Special',150);put('wCustomSide',turn);put('wCustomMove',MOVES['FACADE']);put('wCustomStat',3);call('ConditionalOffense');assert game.register_file.HL==150,(turn,'ice facade uses Special')
            for attack,want in [('EMBER',50),('ICE_BEAM',100),('TACKLE',100)]:
                init(turn);move(turn,attack);aid(1-turn,'BLUBBER');word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,readword('wDamage'))
                init(turn);move(turn,attack);aid(1-turn,'BLUBBER');put('wUnusedC000',16);word('wDamage',100);call('AbilityFixedDamageModifiers');assert readword('wDamage')==want,(turn,attack,'fixed')
            for attack,t1,t2,want in [('ICE','WATER','WATER',20),('ICE','WATER','GRASS',40),('ICE','WATER','ICE',10),('FIRE','WATER','WATER',5)]:
                ap,tp=init(turn);aid(turn,'ICEBREAKER');put(tp+'Type1',TYPES[t1]);put(tp+'Type2',TYPES[t2]);put(actor+'MoveType',TYPES[attack]);word('wDamage',100);call('AdjustDamageForMoveType')
                assert readword('wDamage')==want*10 and get('wDamageMultipliers')==want,(turn,attack,t1,t2,readword('wDamage'),get('wDamageMultipliers'))
                put('wUnusedC000',8 if turn==0 else 0);call('AIGetTypeEffectiveness');assert get('wTypeEffectiveness')==want,(turn,attack,t1,t2,'AI')
            for attack,want in [('ICE_BEAM',8),('TACKLE',7)]:
                init(turn);move(turn,attack);aid(turn,'SNOW_VEIL');put('wAbilityHit',8);call('AbilitySandAfterAction');assert get(actor+'MonEvasionMod')==want,(turn,attack)
                call('AbilitySandAfterAction');assert get(actor+'MonEvasionMod')==want
        # Blubber HP scaling uses persistent slot 1 and recalculates on capsules.
        for species in ('SEEL','DEWGONG'):
            for nature in (0,33,195):
                root='wPartyMon1';game.memory[addr(root):addr(root)+44]=[0]*44;metadata(root,species,2,nature);put(root+'Level',50);word(root+'HP',100);word(root+'MaxHP',100);word('wNatureMonPtr',addr(root));call('NatureMigrateOne');base=readword(root+'MaxHP')
                metadata(root,species,1,nature);call('NatureMigrateOne');assert readword(root+'MaxHP')==base*120//100,(species,nature,base,readword(root+'MaxHP'))
                expected=readword(root+'MaxHP');word(root+'HP',expected-20);call('NatureMigrateOne');assert readword(root+'HP')==expected-20
                word(root+'HP',0);rng(1);call('AbilityCapsuleApply');assert readword(root+'MaxHP')==base and readword(root+'HP')==0 and get(root+'CatchRate')==nature,(species,nature,'capsule')
                word(root+'HP',base-20);rng(0);call('AbilityCapsuleApply');assert readword(root+'MaxHP')==base*120//100 and readword(root+'HP')==base*120//100-20,(species,nature,'gain blubber')
        maxima=[]
        for slot in (2,1):
            put('wEnemyMonSpecies2',ids['SEEL']);put('wCurEnemyLVL',20);put('wIsInBattle',1);put('wNatureMode',2);put('wNatureEnemySlot',slot)
            game.memory[addr('wNatureIDs')+1]=0;game.memory[addr('wNatureStatSources')+1]=0;rng(0);call('LoadEnemyMonData');maxima.append(readword('wEnemyMonMaxHP'))
        assert maxima[1]==maxima[0]*120//100,('wild Blubber',maxima)
        put('wPartyCount',0);put('wMonDataLocation',0x80);put('wcf91',ids['SEEL']);put('wCurEnemyLVL',20);call('AddPartyMon')
        assert get('wPartyMon1Type1')>>5==1 and readword('wPartyMon1MaxHP')==maxima[1],('caught Blubber',maxima,readword('wPartyMon1MaxHP'))
        # Grimer / Muk: poison rolls, either-side healing, and physical reactions.
        for turn in (0,1):
            actor='w'+('Enemy' if turn else 'Player')
            for attack,roll,sub,target_ability,poison_type,want in [('EARTHQUAKE',0,0,None,False,8),('EARTHQUAKE',59,0,None,False,8),('EARTHQUAKE',60,0,None,False,0),('TACKLE',0,0,None,False,0),('EARTHQUAKE',0,1,None,False,0),('EARTHQUAKE',0,0,'SHIELD_DUST',False,0),('EARTHQUAKE',0,0,'IMMUNITY',False,0),('EARTHQUAKE',0,0,None,True,0)]:
                ap,tp=init(turn);move(turn,attack);aid(turn,'CONTAMINATION');aid(1-turn,target_ability);put('wCustomTargetHadSub',sub)
                if poison_type:put(tp+'Type1',TYPES['POISON']);put(tp+'Type2',TYPES['POISON'])
                rng(roll);call('AbilityAfterHit');assert get(tp+'Status')==want,(turn,attack,roll,sub,target_ability,poison_type,get(tp+'Status'))
            ap,tp=init(turn);move(turn,'BONEMERANG');aid(turn,'CONTAMINATION');rng(60,0);call('AbilityAfterHit');call('AbilityAfterHit');assert get(tp+'Status')==0 and state['index']==1,(turn,'contamination rolls once per move')
            for own,other,foehp,hp,want in [(0,0,160,80,80),(8,0,160,80,90),(0,8,160,80,90),(8,8,160,80,90),(8,0,0,80,90),(0,8,0,80,80),(8,0,160,0,0),(8,0,160,155,160)]:
                ap,tp=init(turn);aid(turn,'GRIMER_TOXIC_WASTE');put(ap+'Status',own);put(tp+'Status',other);word(ap+'HP',hp);word(tp+'HP',foehp);put('wResidualRoundDone',0);call('AbilityEndRound')
                assert readword(ap+'HP')==want,(turn,own,other,foehp,hp,readword(ap+'HP'))
            # The existing Gloom and Venonat variants only check the opponent.
            for old_ability in ('TOXIC_WASTE','POISON_ABSORB'):
                ap,tp=init(turn);aid(turn,old_ability);put(ap+'Status',8);word(ap+'HP',80);put('wResidualRoundDone',0);call('AbilityEndRound');assert readword(ap+'HP')==80,(turn,old_ability)
            for attack,roll,sub,hp,want in [('TACKLE',0,0,160,6),('EARTHQUAKE',39,0,160,6),('TACKLE',40,0,160,7),('EMBER',0,0,160,7),('TACKLE',0,1,160,7),('TACKLE',0,0,0,6)]:
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'STICKY_BODY');put('wCustomTargetHadSub',sub);word(tp+'HP',hp);rng(roll);call('AbilityAfterHit');assert get(actor+'MonSpeedMod')==want,(turn,attack,roll,sub,hp,get(actor+'MonSpeedMod'))
            ap,tp=init(turn);move(turn,'DOUBLESLAP');aid(1-turn,'STICKY_BODY');rng(0,0);call('AbilityAfterHit');call('AbilityAfterHit');assert get(actor+'MonSpeedMod')==5,(turn,'sticky body per hit')
            for attack,want in [('TACKLE',75),('KARATE_CHOP',75),('EMBER',100),('PSYCHIC_M',100)]:
                init(turn);move(turn,attack);aid(1-turn,'SOFT_BODY');word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,'soft body',readword('wDamage'))
                init(turn);move(turn,attack);aid(1-turn,'SOFT_BODY');put('wUnusedC000',16);word('wDamage',100);call('AbilityFixedDamageModifiers');assert readword('wDamage')==want,(turn,attack,'fixed soft body')
        # Shellder and Cloyster use all five ability slots on both sides.
        for turn in (0,1):
            actor='w'+('Enemy' if turn else 'Player')
            for attack,roll,want in [('BARRAGE',0,5),('BARRAGE',1,5),('BARRAGE',255,5),('DOUBLESLAP',0,2),('TWINEEDLE',0,2),('TRIPLE_KICK',0,3)]:
                init(turn);move(turn,attack);aid(turn,'SKILL_LINK');rng(roll);call('TwoToFiveAttacksEffect');assert get(actor+'NumHits')==want,(turn,attack,roll,get(actor+'NumHits'))
            init(turn);move(turn,'TRIPLE_KICK');aid(turn,'SKILL_LINK');rng(255);call('SequenceTripleAccuracy');assert get('wMoveMissed')==0
            for attack,holderhp,sub,actor_ability,actorhp,want in [('TACKLE',160,0,None,80,70),('EARTHQUAKE',160,0,None,80,70),('EMBER',160,0,None,80,80),('TACKLE',0,0,None,80,70),('TACKLE',160,1,None,80,80),('TACKLE',160,0,'MAGIC_GUARD',80,80),('TACKLE',160,0,None,5,0)]:
                ap,tp=init(turn);move(turn,attack);aid(1-turn,'SPIKED_SHELL');aid(turn,actor_ability);put('wCustomTargetHadSub',sub);word(ap+'HP',actorhp);word(tp+'HP',holderhp);call('AbilityAfterHit');assert readword(ap+'HP')==want,(turn,attack,holderhp,sub,actor_ability,actorhp,readword(ap+'HP'))
            ap,tp=init(turn);move(turn,'DOUBLESLAP');aid(1-turn,'SPIKED_SHELL');word(ap+'HP',80);call('AbilityAfterHit');call('AbilityAfterHit');assert readword(ap+'HP')==60,(turn,'spiked shell per hit')
            for attack,want in [('TACKLE',100),('EARTHQUAKE',100),('EMBER',80),('PSYCHIC_M',80)]:
                init(turn);move(turn,attack);aid(1-turn,'DEEPSEA_PEARL');word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==want,(turn,attack,readword('wDamage'))
                init(turn);move(turn,attack);aid(1-turn,'DEEPSEA_PEARL');put('wUnusedC000',16);word('wDamage',100);call('AbilityFixedDamageModifiers');assert readword('wDamage')==want,(turn,attack,'fixed')
            for attack,expected_type,damage in [('TACKLE','WATER',120),('WATER_GUN','WATER',100),('GROWL','NORMAL',100),('EMBER','FIRE',100)]:
                init(turn);move(turn,attack);aid(turn,'LIQUIDATE');call('AbilityAttempt');assert get(actor+'MoveType')==TYPES[expected_type],(turn,attack,get(actor+'MoveType'))
                word('wDamage',100);call('AbilityModifyDamage');assert readword('wDamage')==damage,(turn,attack,readword('wDamage'))
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'LIQUIDATE');call('AbilityAttempt');put(ap+'Type1',TYPES['WATER']);put(ap+'Type2',TYPES['WATER']);put(tp+'Type1',TYPES['FIRE']);put(tp+'Type2',TYPES['FIRE']);word('wDamage',100);call('AdjustDamageForMoveType');assert readword('wDamage')==300 and get('wDamageMultipliers')==0x94,(turn,'liquidate STAB')
            ap,tp=init(turn);move(turn,'FACADE');aid(turn,'LIQUIDATE');call('AbilityAttempt');put(ap+'Status',16);word(ap+'Attack',50);word(ap+'Special',150);put('wCustomSide',turn);put('wCustomMove',MOVES['FACADE']);put('wCustomStat',3);call('ConditionalOffense');assert game.register_file.HL==150,(turn,'water facade uses Special')
        # Greedy rewards only a participating holder and never stacks.
        init();metadata('wPartyMon1','MEOWTH',2);put('wPartyCount',1);put('wAbilitySide',0);aid(0,'GREEDY');call('AbilityEntry')
        game.memory[addr('wAmountMoneyWon'):addr('wAmountMoneyWon')+3]=[0x00,0x12,0x34];put('wd72d',0);call('PrintEndBattleText')
        assert bytes(game.memory[addr('wAmountMoneyWon'):addr('wAmountMoneyWon')+3])==bytes([0x00,0x24,0x68]),(version,bytes(game.memory[addr('wAmountMoneyWon'):addr('wAmountMoneyWon')+3]),get('wPartyCount'),get('wPartyMon1Type1'),get('wAbilityFlags'))
        game.memory[addr('wAmountMoneyWon'):addr('wAmountMoneyWon')+3]=[0x60,0x00,0x00];call('AbilityGreedyPrize')
        assert bytes(game.memory[addr('wAmountMoneyWon'):addr('wAmountMoneyWon')+3])==bytes([0x99,0x99,0x99])
        game.memory[addr('wAbilityFlags')]=0;game.memory[addr('wAmountMoneyWon'):addr('wAmountMoneyWon')+3]=[0x00,0x12,0x34];call('AbilityGreedyPrize')
        assert bytes(game.memory[addr('wAmountMoneyWon'):addr('wAmountMoneyWon')+3])==bytes([0x00,0x12,0x34])
        metadata('wPartyMon1','MEOWTH',1);game.memory[addr('wAbilityFlags')]=64;call('AbilityGreedyPrize')
        assert bytes(game.memory[addr('wAmountMoneyWon'):addr('wAmountMoneyWon')+3])==bytes([0x00,0x12,0x34])
        # Resourceful max PP, 63 cap, PP Ups, live/box/daycare sources and healing.
        init();metadata('wPartyMon1','MEOWTH',3);put('wPartyCount',1);put('wPartySpecies',ids['MEOWTH']);game.memory[addr('wPartySpecies')+1]=255
        put('wWhichPokemon',0);put('wMonDataLocation',0);put('wCurrentMenuItem',0);put('wPartyMon1Moves',MOVES['GROWL']);put('wPartyMon1PP',0xc0|50)
        call('GetMaxPP');assert get('wMaxPP')==63,(version,'max PP',get('wMaxPP'))
        put('wPartyMon1Moves',MOVES['TACKLE']);put('wPartyMon1PP',20);call('GetMaxPP');assert get('wMaxPP')==40,(version,'base max',get('wMaxPP'))
        put('wPartyMon1Moves',MOVES['GROWL']);put('wPartyMon1PP',0xc0|50);put('wIsInBattle',0);call('HealParty')
        assert get('wPartyMon1PP')==0xc0|63,(version,'heal',get('wPartyMon1PP'))
        call('HealParty');assert get('wPartyMon1PP')==0xc0|63
        put('wMonDataLocation',4);put('wPlayerMonNumber',0);put('wBattleMonMoves',MOVES['TACKLE']);put('wBattleMonPP',20);put('wPlayerBattleStatus3',0)
        call('GetMaxPP');assert get('wMaxPP')==40
        put('wPlayerBattleStatus3',8);call('GetMaxPP');assert get('wMaxPP')==35
        put('wPlayerBattleStatus3',0)
        for root,location in [('wBoxMon1',2),('wDayCareMon',3)]:
            metadata(root,'MEOWTH',3);put(root+'Moves',MOVES['TACKLE']);put(root+'PP',20);put('wWhichPokemon',0);put('wMonDataLocation',location);call('GetMaxPP');assert get('wMaxPP')==40,(root,get('wMaxPP'))
        # Capsule gain/loss adjusts by the real change at the PP-Up cap.
        for base_move,packed,gained in [('TACKLE',20,25),('GROWL',0xc0|50,0xc0|52)]:
            metadata('wPartyMon1','MEOWTH',1);put('wPartyMon1Moves',MOVES[base_move]);put('wPartyMon1PP',packed);put('wPartyMon1Moves' ,MOVES[base_move]);game.memory[addr('wPartyMon1Moves')+1:addr('wPartyMon1Moves')+4]=[0,0,0]
            word('wNatureMonPtr',addr('wPartyMon1'));rng(2);call('AbilityCapsuleApply');assert get('wPartyMon1Type1')>>5==3 and get('wPartyMon1PP')==gained,(version,base_move,'gain',get('wPartyMon1PP'),gained)
            rng(0);call('AbilityCapsuleApply');assert get('wPartyMon1Type1')>>5==1 and get('wPartyMon1PP')==packed,(version,base_move,'loss',get('wPartyMon1PP'),packed)
        # A PP Up at the storage cap must not spill into its two count bits.
        metadata('wPartyMon1','MEOWTH',3);put('wPartyMon1Moves',MOVES['GROWL']);put('wPartyMon1PP',0xc0|63);put('wUsingPPUp',1)
        game.memory[addr('wNormalMaxPPList')]=40;call('AddBonusPP',HL=addr('wPartyMon1PP'),DE=addr('wNormalMaxPPList'))
        assert get('wPartyMon1PP')==0xc0|63
        # Newly obtained Resourceful Pokémon and moves receive their bonus immediately.
        init();put('wPartyCount',0);put('wMonDataLocation',0x80);put('wIsInBattle',0);put('wCurEnemyLVL',20);put('wcf91',ids['MEOWTH']);rng(2,0,0,0);call('AddPartyMon')
        assert get('wPartyMon1Type1')>>5==3,(version,'new ability',get('wPartyMon1Type1'))
        for i in range(4):
            m=game.memory[addr('wPartyMon1Moves')+i]
            if m:
                bank,base=syms['Moves'];normal=game.memory[bank,base+(m-1)*6+5]
                assert game.memory[addr('wPartyMon1PP')+i]==min(normal+5,63),(version,'new PP',m)
        put('wWhichPokemon',0);put('wIsInBattle',0);put('wMoveNum',MOVES['GROWL'])
        game.memory[addr('wPartyMon1Moves'):addr('wPartyMon1Moves')+4]=[MOVES['TACKLE'],0,0,0]
        game.memory[addr('wPartyMon1PP'):addr('wPartyMon1PP')+4]=[40,0,0,0]
        call('LearnMove');assert game.memory[addr('wPartyMon1Moves')+1]==MOVES['GROWL'] and game.memory[addr('wPartyMon1PP')+1]==45,(version,'learn PP')
        init();put('wEnemyMonSpecies2',ids['MEOWTH']);put('wCurEnemyLVL',20);put('wIsInBattle',1);put('wNatureMode',2);put('wNatureEnemySlot',3)
        rng(0);call('LoadEnemyMonData');assert game.memory[addr('wActiveAbilities')+1]==ab['RESOURCEFUL']
        for i in range(4):
            m=game.memory[addr('wEnemyMonMoves')+i]
            if m:
                bank,base=syms['Moves'];normal=game.memory[bank,base+(m-1)*6+5]
                assert game.memory[addr('wEnemyMonPP')+i]==min(normal+5,63),(version,'wild PP',m,game.memory[addr('wEnemyMonPP')+i],normal)
        # A third PP Up preserves its count while reaching the six-bit cap.
        metadata('wPartyMon1','MEOWTH',3);put('wPartyMon1PP',0xc0|59);put('wUsingPPUp',1);game.memory[addr('wNormalMaxPPList')]=40
        call('AddBonusPP',HL=addr('wPartyMon1PP'),DE=addr('wNormalMaxPPList'));assert get('wPartyMon1PP')==0xc0|63
        # Exact 10%, 15%, 25% rolls, including high-byte rejection.
        for percent in (10,15,20,25,30):
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
        # All implemented and reserved descriptions render without changing IDs.
        game.memory[0xff40]=0
        for n in range(1,192):
            active=bytes(game.memory[addr('wActiveAbilities'):addr('wActiveAbilities')+2]);game.memory[addr('wTileMap'):addr('wTileMap')+360]=[0x7f]*360;call('AbilityDrawDescription',A=n)
            assert bytes(game.memory[addr('wActiveAbilities'):addr('wActiveAbilities')+2])==active
            assert game.memory[addr('wTileMap')+4*20+2]!=0x7f,n
        for n,name in [(1,'POISON LEAF'),(135,'MAGIC BOUNCE'),(143,'ACIDIC'),(146,'DIGESTIVE ACID')]:
            call('AbilityDrawDescription',A=n);expected=bytes(0x7f if c==' ' else 0x80+ord(c)-ord('A') for c in name)
            assert bytes(game.memory[addr('wTileMap')+4*20+2:addr('wTileMap')+4*20+2+len(name)])==expected,(n,name)
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
        def execute(attack,turn,actor=None,target=None,pp=20,status=0,hp=160,actor_hp=160,counter_damage=None,random_value=0,subhp=None,screens=0,target_types=None,target_entry=False,bide_damage=None):
            ap,tp=init(turn)
            put('wActionResultOrTookBattleTurn',0);put('wMonIsDisobedient',0)
            for side in (0,1):
                prefix='wEnemy' if side else 'wPlayer';move(side,attack)
                for n in ('DisabledMove','DisabledMoveNumber','NumAttacksLeft','NumHits'):put(prefix+n,0)
            for pref in ('wBattleMon','wPartyMon1','wEnemyMon','wEnemyMon1'):
                put(pref+'Species',ids['BULBASAUR'] if pref in ('wBattleMon','wPartyMon1') else ids['CHARMANDER'])
                put(pref+'Level',50);put(pref+'PP',pp);put(pref+'Moves',MOVES[attack])
            aid(turn,actor);aid(1-turn,target);put(tp+'Status',status);word(tp+'HP',hp);word(ap+'HP',actor_hp);rng(random_value)
            if target_types:
                put(tp+'Type1',TYPES[target_types[0]]);put(tp+'Type2',TYPES[target_types[1]])
            target_name='Player' if turn else 'Enemy'
            put('w'+target_name+'BattleStatus3',screens)
            if subhp is not None:
                put('w'+target_name+'BattleStatus2',16);put('w'+target_name+'SubstituteHP',subhp)
            if target_entry:
                put('wAbilitySide',1-turn);call('AbilityEntry');call('AbilityEntrySpeed')
            if bide_damage is not None:
                side='Enemy' if turn else 'Player';put('w'+side+'BattleStatus1',1);put('w'+side+'MoveEffect',0);word('w'+side+'BideAccumulatedDamage',bide_damage)
            if counter_damage is not None:
                word('wCounterDamage',counter_damage);put('wCounterRecipient',turn)
            call('ExecuteEnemyMove' if turn else 'ExecutePlayerMove')
            return ap,tp
        for turn in (0,1):
            ap,tp=execute('SONICBOOM',turn,actor='LIQUIDATE');assert readword(tp+'HP')==136,(turn,'fixed liquidate',readword(tp+'HP'))
            ap,tp=execute('TACKLE',turn,target_types=('FIRE','FIRE'));normal=160-readword(tp+'HP')
            ap,tp=execute('TACKLE',turn,actor='LIQUIDATE',target_types=('FIRE','FIRE'));assert get('w'+('Enemy' if turn else 'Player')+'MoveType')==TYPES['WATER'] and 160-readword(tp+'HP')>normal,(turn,'live liquidate')
            ap,tp=execute('METRONOME',turn,actor='LIQUIDATE',target_types=('FIRE','FIRE'),random_value=MOVES['TACKLE']);assert get('w'+('Enemy' if turn else 'Player')+'MoveType')==TYPES['WATER'] and readword(tp+'HP')<160,(turn,'metronome liquidate')
            ap,tp=execute('TACKLE',turn,target='SPIKED_SHELL',actor_hp=80);assert readword(ap+'HP')==70,(turn,'live spiked shell')
            ap,tp=execute('EARTHQUAKE',turn,actor='CONTAMINATION',random_value=0);assert get(tp+'Status')==8,(turn,'live contamination',get(tp+'Status'))
            ap,tp=execute('TACKLE',turn,target='STICKY_BODY',random_value=0);assert get('w'+('Enemy' if turn else 'Player')+'MonSpeedMod')==6,(turn,'live sticky body')
            ap,tp=execute('TACKLE',turn,random_value=100);normal=160-readword(tp+'HP')
            ap,tp=execute('TACKLE',turn,target='SOFT_BODY',random_value=100);assert 160-readword(tp+'HP')==max(1,normal*75//100),(turn,'live soft body',normal,readword(tp+'HP'))
            ap,tp=execute('SONICBOOM',turn,actor='REFRIGERATE');assert readword(tp+'HP')==136,(turn,'fixed refrigerate',readword(tp+'HP'))
            ap,tp=execute('ICE_BEAM',turn,target_types=('WATER','WATER'));resisted=160-readword(tp+'HP')
            ap,tp=execute('ICE_BEAM',turn,actor='ICEBREAKER',target_types=('WATER','WATER'));assert 160-readword(tp+'HP')>resisted,(turn,'live icebreaker')
            ap,tp=execute('TACKLE',turn,target_types=('GRASS','GRASS'));normal=160-readword(tp+'HP')
            ap,tp=execute('TACKLE',turn,actor='REFRIGERATE',target_types=('GRASS','GRASS'));assert get('w'+('Enemy' if turn else 'Player')+'MoveType')==TYPES['ICE'] and 160-readword(tp+'HP')>normal,(turn,'live refrigerate')
            ap,tp=execute('METRONOME',turn,actor='REFRIGERATE',target_types=('GRASS','GRASS'),random_value=MOVES['TACKLE']);assert get('w'+('Enemy' if turn else 'Player')+'MoveType')==TYPES['ICE'] and readword(tp+'HP')<160,(turn,'metronome refrigerate')
            ap,tp=execute('TACKLE',turn,target='FLAME_BODY',random_value=0);assert get(ap+'Status')==16,(turn,'live flame body')
            ap,tp=execute('DOUBLESLAP',turn,target='STAMINA',random_value=0);assert get('w'+('Player' if turn else 'Enemy')+'MonDefenseMod')==9,(turn,'live stamina')
            ap,tp=execute('SWORDS_DANCE',turn,target='COMPETITIVE',random_value=0);assert get('w'+('Player' if turn else 'Enemy')+'MonAttackMod')==8,(turn,'live competitive')
            ap,tp=execute('POISONPOWDER',turn,target='MAGIC_BOUNCE');assert get(ap+'Status')==8 and get(tp+'Status')==0,(turn,'live bounce')
            ap,tp=execute('GROWL',turn,target='MAGIC_BOUNCE');assert get('w'+('Enemy' if turn else 'Player')+'MonAttackMod')==6
            ap,tp=execute('ABSORB',turn,target='LIQUID_OOZE',actor_hp=80,random_value=100);damage=160-readword(tp+'HP');assert readword(ap+'HP')==80-max(1,damage//2),(turn,'live liquid ooze',damage,readword(ap+'HP'))
            ap,tp=execute('ABSORB',turn,target='LIQUID_OOZE',actor_hp=1,random_value=100);assert readword(ap+'HP')==0,(turn,'ooze knockout')
            ap,tp=execute('TACKLE',turn,random_value=100);normal=160-readword(tp+'HP')
            ap,tp=execute('TACKLE',turn,actor='TECHNICIAN',random_value=100);assert 160-readword(tp+'HP')==normal*150//100,(turn,normal,readword(tp+'HP'))
            # Threshold triggers also run immediately after recoil and poison,
            # before the opposing Pokémon can take its action.
            ap,tp=execute('TACKLE',turn,random_value=100);normal=160-readword(tp+'HP')
            ap,tp=execute('TACKLE',turn,actor='AMBUSH',random_value=100);assert 160-readword(tp+'HP')==normal*125//100
            ap,tp=execute('DOUBLESLAP',turn,random_value=100);multi=160-readword(tp+'HP')
            ap,tp=execute('DOUBLESLAP',turn,actor='AMBUSH',random_value=100);assert 160-readword(tp+'HP')==2*((multi//2)*125//100),(turn,multi,readword(tp+'HP'))
            ap,tp=execute('DIG',turn,random_value=100);assert readword(tp+'HP')==160;call('ExecuteEnemyMove' if turn else 'ExecutePlayerMove');normal=160-readword(tp+'HP')
            ap,tp=execute('DIG',turn,actor='AMBUSH',random_value=100);assert readword(tp+'HP')==160;call('ExecuteEnemyMove' if turn else 'ExecutePlayerMove')
            assert 160-readword(tp+'HP')==normal*125//100,(turn,normal,readword(tp+'HP'))
            ap,tp=execute('SEISMIC_TOSS',turn,actor='AMBUSH');assert readword(tp+'HP')==98
            ap,tp=execute('BIDE',turn,actor='AMBUSH',bide_damage=20);assert readword(tp+'HP')==110,(turn,readword(tp+'HP'),get('wMoveMissed'),readword('wDamage'),get('wAbilityHit'),get('wPlayerMoveNum'),get('wPlayerMovePower'),get('wPlayerBattleStatus1'),get('wPlayerNumAttacksLeft'),readword('wPlayerBideAccumulatedDamage'))
            ap,tp=execute('BIDE',turn,target='ELUSIVE',target_entry=True,bide_damage=20)
            assert readword(tp+'HP')==120 and get('w'+('Player' if turn else 'Enemy')+'MonEvasionMod')==7
            ap,tp=execute('TACKLE',turn,target='ELUSIVE',target_entry=True,random_value=254)
            assert get('wMoveMissed')==1 and get('w'+('Player' if turn else 'Enemy')+'MonEvasionMod')==7
            ap,tp=execute('TACKLE',turn,target='ELUSIVE',target_entry=True,subhp=120);assert readword(tp+'HP')==160 and get('w'+('Player' if turn else 'Enemy')+'MonEvasionMod')==7
            ap,tp=execute('GROWL',turn,target='ELUSIVE',target_entry=True)
            assert get('w'+('Player' if turn else 'Enemy')+'MonEvasionMod')==8
            ap,tp=execute('EARTHQUAKE',turn,actor='SAND_RUSH');assert get('w'+('Enemy' if turn else 'Player')+'MonSpeedMod')==8
            ap,tp=execute('EARTHQUAKE',turn,actor='AFTERSHOCK');assert get(tp+'Status')==64
            ap,tp=execute('EARTHQUAKE',turn,actor='AFTERSHOCK',target='SHIELD_DUST');assert get(tp+'Status')==0
            ap,tp=execute('TACKLE',turn,actor='LEECHING',actor_hp=80);damage=160-readword(tp+'HP')
            assert readword(ap+'HP')==80+max(1,damage//10),(turn,damage,readword(ap+'HP'))
            ap,tp=execute('TACKLE',turn,actor='LEECHING',actor_hp=80,subhp=20);assert readword(ap+'HP')==82
            ap,tp=execute('TACKLE',turn,target='PARASITE',subhp=120);assert game.memory[addr('wActiveAbilities')+turn]==0
            ap,tp=execute('TACKLE',turn,target='PARASITE');assert game.memory[addr('wActiveAbilities')+turn]==ab['PARASITE']
            ap,tp=execute('EARTHQUAKE',turn,target='PARASITE');assert game.memory[addr('wActiveAbilities')+turn]==0
            ap,tp=execute('SING',turn,random_value=254);assert not(get(tp+'Status')&7)
            ap,tp=execute('SING',turn,actor='MYCELIUM',random_value=254);assert get(tp+'Status')&7
            ap,tp=execute('SING',turn,actor='MYCELIUM',random_value=254,status=16);assert get(tp+'Status')==16
            call('ResidualClearAll');ap,tp=execute('TACKLE',turn,target='DEATH_SPORE',hp=1,random_value=0)
            assert get('wEnemyResidual' if turn else 'wPlayerResidual')&2 and get(ap+'Status')==0
            call('ResidualClearAll');ap,tp=execute('TACKLE',turn,target='DEATH_SPORE',hp=1,random_value=1)
            assert get(ap+'Status')==8 and not(get('wEnemyResidual' if turn else 'wPlayerResidual')&2)
            call('ResidualClearAll');ap,tp=execute('TACKLE',turn,target='DEATH_SPORE',hp=160)
            assert get(ap+'Status')==0 and not(get('wEnemyResidual' if turn else 'wPlayerResidual')&2)
            ap,tp=execute('TACKLE',turn,random_value=100,target_types=('ROCK','ROCK'));normal=160-readword(tp+'HP')
            ap,tp=execute('TACKLE',turn,actor='TINTED_LENS',random_value=100,target_types=('ROCK','ROCK'))
            assert 160-readword(tp+'HP')==2*normal,(turn,normal,readword(tp+'HP'))
            ap,tp=execute('TACKLE',turn,actor='TINTED_LENS',random_value=100,target_types=('GHOST','GHOST'));assert readword(tp+'HP')==160
            ap,tp=execute('VINE_WHIP',turn,random_value=100,target_types=('GRASS','POISON'));normal=160-readword(tp+'HP')
            ap,tp=execute('VINE_WHIP',turn,actor='TINTED_LENS',random_value=100,target_types=('GRASS','POISON'));assert 160-readword(tp+'HP')==2*normal
            ap,tp=execute('TACKLE',turn,actor='TOXIC_SCALES',target='PARASITE');assert get(tp+'Status')==8 and game.memory[addr('wActiveAbilities')+turn]==ab['PARASITE']
            ap,tp=execute('TACKLE',turn,actor='TOXIC_SCALES');assert get(tp+'Status')==8
            ap,tp=execute('TACKLE',turn,actor='TOXIC_SCALES',target='SHIELD_DUST');assert get(tp+'Status')==0
            ap,tp=execute('SEISMIC_TOSS',turn,actor='VENOMOUS',status=8);assert readword(tp+'HP')==98
            # Infiltrator affects the damage calculation and restores intact screens.
            for attack,screen in [('TACKLE',4),('EMBER',2),('AERIAL_ACE',4),('SHOCK_WAVE',2)]:
                ap,tp=execute(attack,turn,random_value=100);normal=160-readword(tp+'HP')
                ap,tp=execute(attack,turn,screens=screen,random_value=100);screened=160-readword(tp+'HP')
                ap,tp=execute(attack,turn,actor='INFILTRATOR',screens=screen,random_value=100);bypass=160-readword(tp+'HP')
                assert bypass==normal and screened<normal,(turn,attack,normal,screened,bypass)
                assert get('w'+('Player' if turn else 'Enemy')+'BattleStatus3')&screen
            ap,tp=execute('BRICK_BREAK',turn,actor='INFILTRATOR',screens=6,subhp=120)
            assert get('w'+('Player' if turn else 'Enemy')+'BattleStatus3')&6==0
            assert readword(tp+'HP')<160 and get('w'+('Player' if turn else 'Enemy')+'SubstituteHP')==120
            assert get('w'+('Player' if turn else 'Enemy')+'BattleStatus2')&16
            ap,tp=execute('TACKLE',turn,actor='INFILTRATOR',subhp=120)
            assert readword(tp+'HP')<160 and get('w'+('Player' if turn else 'Enemy')+'SubstituteHP')==120
            assert get('w'+('Player' if turn else 'Enemy')+'BattleStatus2')&16
            ap,tp=execute('SING',turn,actor='INFILTRATOR',subhp=120,random_value=100)
            assert get(tp+'Status')&7 and get('w'+('Player' if turn else 'Enemy')+'BattleStatus2')&16
            ap,tp=init(turn);move(turn,'TACKLE');aid(turn,'INFILTRATOR');target_side='Player' if turn else 'Enemy'
            put('w'+target_side+'BattleStatus2',16);call('AbilityBeforeAction');assert not(get('w'+target_side+'BattleStatus2')&16)
            put('wPlayerMonNumber' if turn else 'wEnemyMonPartyPos',1);call('AbilityAfterAction')
            assert not(get('w'+target_side+'BattleStatus2')&16)
            ap,tp=execute('SING',turn,random_value=190);assert not(get(tp+'Status')&7)
            ap,tp=execute('SING',turn,actor='ECHOLOCATION',random_value=190);assert get(tp+'Status')&7
            for damage in (1,2,3,4,255,256,999):
                init(turn);aid(turn,'BLOODSUCKER');word('wDamage',damage);call('AbilityBloodsuckerCache');word('wDamage',max(1,damage//2));call('AbilityBloodsuckerAdd')
                assert readword('wDamage')==max(1,damage//2)+damage//4,(turn,damage,readword('wDamage'))
            for attack in ('ABSORB','DRAIN_PUNCH'):
                ap,tp=execute(attack,turn,actor='BLOODSUCKER',actor_hp=80);damage=160-readword(tp+'HP')
                assert readword(ap+'HP')==min(160,80+max(1,damage//2)+damage//4),(turn,attack,damage,readword(ap+'HP'))
            ap,tp=execute('ABSORB',turn,actor='BLOODSUCKER',actor_hp=80,hp=1);assert readword(ap+'HP')==81
            ap,tp=execute('SHADOW_LEECH',turn,actor='BLOODSUCKER',actor_hp=80,status=1);damage=160-readword(tp+'HP')
            assert readword(ap+'HP')==min(160,80+damage+damage//4),(turn,damage,readword(ap+'HP'))
            ap,tp=execute('SLEEP_POWDER',turn,random_value=220);assert not(get(tp+'Status')&7)
            ap,tp=execute('SLEEP_POWDER',turn,actor='POLLEN',random_value=220);assert get(tp+'Status')&7
            ap,tp=execute('ABSORB',turn,actor='ABSORPTION',actor_hp=80);damage=160-readword(tp+'HP')
            assert readword(ap+'HP')==min(160,80+max(1,damage//2)+damage//4),(turn,damage,readword(ap+'HP'))
            ap,tp=execute('TACKLE',turn,target='EFFECT_SPORE');assert get(ap+'Status')==8
            for attack in ('THUNDERBOLT','THUNDER_WAVE','SHOCK_WAVE','FLASH'):
                ap,tp=execute(attack,turn,target='RUBBER_SKIN');assert readword(tp+'HP')==160 and get(tp+'Status')==0,(turn,attack,readword(tp+'HP'),get(tp+'Status'))
                assert get('wMoveMissed')==1 and get('wDamageMultipliers')&127==0,(turn,attack,get('wMoveMissed'),get('wDamageMultipliers'))
                assert get('w'+('Player' if turn else 'Enemy')+'MonAccuracyMod')==7
            ap,tp=execute('TACKLE',turn,target='RUBBER_SKIN');assert readword(tp+'HP')<160
            ap,tp=init(turn);move(turn,'TACKLE');aid(1-turn,'INFLATABLE');put('wCustomTargetHadSub',1);call('AbilityAfterHit');assert get('w'+('Player' if turn else 'Enemy')+'MonDefenseMod')==7
            ap,tp=execute('EMBER',turn);fire_damage=160-readword(tp+'HP')
            ap,tp=execute('EMBER',turn,target='THICK_FAT');assert 160-readword(tp+'HP')==max(1,fire_damage//2),(turn,fire_damage,readword(tp+'HP'))
            ap,tp=execute('TACKLE',turn,target='INFLATABLE');assert get('w'+('Player' if turn else 'Enemy')+'MonDefenseMod')==8
            ap,tp=execute('EARTHQUAKE',turn,target='INFLATABLE');assert get('w'+('Player' if turn else 'Enemy')+'MonDefenseMod')==8
            ap,tp=execute('EMBER',turn,target='INFLATABLE');assert get('w'+('Player' if turn else 'Enemy')+'MonDefenseMod')==7
            ap,tp=execute('DOUBLESLAP',turn,target='INFLATABLE');assert get('w'+('Player' if turn else 'Enemy')+'MonDefenseMod')==9
            ap,tp=execute('SING',turn,actor='SOOTHING_VOICE',actor_hp=80,random_value=254);assert readword(ap+'HP')==100
            ap,tp=execute('SNARL',turn,actor='SOOTHING_VOICE',actor_hp=80);assert readword(ap+'HP')==100
            ap,tp=execute('TACKLE',turn);normal=160-readword(tp+'HP')
            ap,tp=execute('TACKLE',turn,target='ILLUSION');assert 160-readword(tp+'HP')==max(1,normal//2),(turn,normal,readword(tp+'HP'))
            ap,tp=execute('DOUBLESLAP',turn);multi=160-readword(tp+'HP')
            ap,tp=execute('DOUBLESLAP',turn,target='ILLUSION');assert abs((160-readword(tp+'HP'))-multi//2)<=1,(turn,multi,readword(tp+'HP'))
            ap,tp=execute('TACKLE',turn,target='NINE_LIVES',hp=1);assert readword(tp+'HP')==1
            ap,tp=execute('SEISMIC_TOSS',turn,target='NINE_LIVES',hp=10);assert readword(tp+'HP')==1
            call('ResidualClearAll');ap,tp=execute('TACKLE',turn,target='AFTERMATH',hp=1)
            assert readword(tp+'HP')==0 and get('wEnemyResidual' if turn else 'wPlayerResidual')&2
            call('ResidualClearAll');ap,tp=execute('TACKLE',turn,target='AFTERMATH',hp=160)
            assert not(get('wEnemyResidual' if turn else 'wPlayerResidual')&2)
            ap,tp=execute('EMBER',turn,actor='FOXFIRE');assert get(tp+'Status')==16 and get('w'+('Enemy' if turn else 'Player')+'MonSpecialMod')==8
            put('wAbilityOldStatus',0);call('AbilityFoxfire');assert get('w'+('Enemy' if turn else 'Player')+'MonSpecialMod')==8
            ap,tp=execute('LICK',turn,actor='FOXS_CUNNING');assert get('w'+('Enemy' if turn else 'Player')+'MonEvasionMod')==8
            call('AbilitySandAfterAction');assert get('w'+('Enemy' if turn else 'Player')+'MonEvasionMod')==8
            ap,tp=execute('METRONOME',turn,random_value=MOVES['TACKLE']);normal=160-readword(tp+'HP')
            ap,tp=execute('METRONOME',turn,actor='UNPREDICTABLE',random_value=MOVES['TACKLE']);assert 160-readword(tp+'HP')>normal,(turn,normal,readword(tp+'HP'))
            ap,tp=init(turn);aid(turn,'MOON_CHILD');word(ap+'HP',80);put('wResidualRoundDone',0);call('AbilityEndRound');assert readword(ap+'HP')==90
            for status in (8,16):
                ap,tp=init(turn);aid(turn,'MAGIC_GUARD');word(ap+'HP',80);put(ap+'Status',status)
                put('w'+('Enemy' if turn else 'Player')+'BattleStatus2',128);call('HandlePoisonBurnLeechSeed')
                assert readword(ap+'HP')==80 and readword(tp+'HP')==160,(turn,status,readword(ap+'HP'))
            ap,tp=init(turn);aid(turn,'MAGIC_GUARD');word(ap+'HP',80);put('w'+('Enemy' if turn else 'Player')+'BattleStatus2',128);call('HandlePoisonBurnLeechSeed');assert readword(ap+'HP')==80
            ap,tp=init(turn);aid(turn,'MAGIC_GUARD');word(ap+'HP',80);put('wCustomSide',turn);put('wCustomChance',0);put('wCustomDelta',3);call('ResidualFraction');assert readword(ap+'HP')==80
            ap,tp=init(turn);call('ResidualClearAll');aid(turn,'MAGIC_GUARD');word(ap+'HP',80);put('wResidualRoundDone',0)
            residual='wEnemyResidual' if turn else 'wPlayerResidual'
            game.memory[addr(residual):addr(residual)+5]=[2,2,2,0,20];call('ResidualEndRound');assert readword(ap+'HP')==80,(turn,readword(ap+'HP'));call('ResidualClearAll')
            ap,tp=execute('TAKE_DOWN',turn,actor='MAGIC_GUARD',actor_hp=80);assert readword(ap+'HP')==80 and readword(tp+'HP')<160
            ap,tp=execute('TACKLE',turn,actor='MAGIC_GUARD',target='SPINY_ARMOR',actor_hp=80);assert readword(ap+'HP')==80 and readword(tp+'HP')<160
            ap,tp=execute('SLUDGE',turn);normal=160-readword(tp+'HP');assert get(tp+'Status')==8
            ap,tp=execute('SLUDGE',turn,actor='SHEER_FORCE');assert 160-readword(tp+'HP')>normal and get(tp+'Status')==0
            ap,tp=execute('TWINEEDLE',turn,actor='SHEER_FORCE');assert get(tp+'Status')==0 and readword(tp+'HP')<160
            ap,tp=execute('SCALD',turn,actor='SHEER_FORCE');assert get(tp+'Status')==0 and readword(tp+'HP')<160
            ap,tp=execute('TACKLE',turn,actor='RAMPAGE');dealt=160-readword(tp+'HP');assert readword(ap+'HP')==160-max(1,dealt//10),(turn,dealt,readword(ap+'HP'))
            ap,tp=execute('SEISMIC_TOSS',turn,actor='RAMPAGE');assert readword(tp+'HP')==98 and readword(ap+'HP')==154,(turn,readword(tp+'HP'),readword(ap+'HP'))
            ap,tp=execute('TACKLE',turn,actor='RAMPAGE',hp=1);assert readword(ap+'HP')==159 and readword(tp+'HP')==0
            ap,tp=execute('DOUBLESLAP',turn,actor='RAMPAGE',actor_hp=1);assert readword(ap+'HP')==0 and get('w'+('Enemy' if turn else 'Player')+'NumAttacksLeft')==0
            ap,tp=execute('TAKE_DOWN',turn,actor='PROTECTIVE_INSTINCT',actor_hp=85)
            assert readword(ap+'HP')<80 and get('w'+('Enemy' if turn else 'Player')+'MonDefenseMod')==8
            ap,tp=init(turn);aid(turn,'PROTECTIVE_INSTINCT');word(ap+'HP',85);put(ap+'Status',8)
            call('HandlePoisonBurnLeechSeed')
            assert readword(ap+'HP')==75 and get('w'+('Enemy' if turn else 'Player')+'MonDefenseMod')==8
            ap,tp=execute('SEISMIC_TOSS',turn,actor='MEASURED');assert readword(tp+'HP')==120
            ap,tp=execute('SEISMIC_TOSS',turn,target='THICK_HIDE');assert readword(tp+'HP')==118
            ap,tp=execute('SEISMIC_TOSS',turn,actor='MEASURED',target='THICK_HIDE');assert readword(tp+'HP')==126
            ap,tp=execute('COUNTER',turn,actor='MEASURED',target='THICK_HIDE',counter_damage=20);assert readword(tp+'HP')==133,(turn,readword(tp+'HP'),get('wMoveMissed'),get('w'+('Enemy' if turn else 'Player')+'MoveNum'),get('wUnusedC000'),get('wActiveAbilities'),game.memory[addr('wActiveAbilities')+1])
            ap,tp=execute('TACKLE',turn,target='SPINY_ARMOR',actor_hp=80);assert readword(ap+'HP')==70 and readword(tp+'HP')<160
            ap,tp=execute('EARTHQUAKE',turn,target='SPINY_ARMOR',actor_hp=80);assert readword(ap+'HP')==70 and readword(tp+'HP')<160
            ap,tp=execute('EMBER',turn,target='SPINY_ARMOR',actor_hp=80);assert readword(ap+'HP')==80 and readword(tp+'HP')<160
            ap,tp=execute('DOUBLESLAP',turn,target='SPINY_ARMOR',actor_hp=5)
            assert readword(ap+'HP')==0 and 0<readword(tp+'HP')<160
            assert get('w'+('Enemy' if turn else 'Player')+'NumAttacksLeft')==0
            ap,tp=execute('TACKLE',turn,target='SPINY_ARMOR',hp=1,actor_hp=5)
            assert readword(ap+'HP')==0 and readword(tp+'HP')==0 and game.register_file.B==0
            ap,tp=execute('EARTHQUAKE',turn,actor='BURROWER',actor_hp=80);assert readword(ap+'HP')==100
            ap,tp=execute('GROWL',turn,actor='ROLLING_DEFENSE');assert get('w'+('Enemy' if turn else 'Player')+'MonDefenseMod')==8
            ap,tp=execute('EARTHQUAKE',turn,actor='SAND_VEIL');assert get('w'+('Enemy' if turn else 'Player')+'MonEvasionMod')==8
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
        print(f'{version}: all 92 species / 460 slots, damage/contact/status/crit/priority/accuracy/threshold/KO/healing effects, exact proc odds and Ancient/capsule HP scaling passed')
    finally:game.stop(save=False)

if __name__=='__main__':
    for version in ('pokered','pokeblue'):validate(version)
