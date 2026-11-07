# Magnemite, Dodrio and Dewgong family redesigns

Cumulative Red/Blue patches retain all earlier sprites, species, types, move effects and family reviews. There are 183 species and now 224 move records. Stats and evolution levels remain unchanged. No new item or save field is introduced.

## New moves

- Zap Cannon (223): Electric, 120 power, 50 accuracy, 5 PP. Bypasses accuracy/evasion when the target is paralyzed; other major statuses do not activate it. Ground immunity and Fly/Dig protection remain. No paralysis side effect. Uses Thunder's animation. Thunder itself remains unchanged.
- Triple Kick (224): Fighting, 20 power per kick, 95 accuracy, 15 PP. Up to three kicks; each checks accuracy separately and a miss stops the sequence. Power does not escalate. Each strike uses the existing separate damage/critical path, can break Substitute and stops on KO. PP is spent once. Uses Double Kick's animation. Other multihit moves retain their existing accuracy behavior.

Both moves are appended; existing IDs remain intact. Names, animations, generated PP, Metronome bounds and save move bytes support both additions.

## Stats and level-up moves

Stats are HP / Attack / Defense / Speed / Special.

### Magnemite

Stats: 25 / 35 / 70 / 45 / 95.

Starts: TACKLE, THUNDERSHOCK.

Level-up: 8: SUPERSONIC, 14: THUNDER_WAVE, 20: SONICBOOM, 26: FLASH, 33: CHARGE, 40: SHOCK_WAVE, 47: LIGHT_SCREEN, 54: ZAP_CANNON.

### Magneton

Stats: 50 / 60 / 95 / 70 / 120.

Starts: TACKLE, THUNDERSHOCK, SUPERSONIC.

Level-up: 8: SUPERSONIC, 14: THUNDER_WAVE, 20: SONICBOOM, 26: FLASH, 33: CHARGE, 40: SHOCK_WAVE, 47: LIGHT_SCREEN, 54: ZAP_CANNON.

### Doduo

Stats: 35 / 85 / 45 / 75 / 35.

Starts: PECK, GROWL.

Level-up: 9: QUICK_ATTACK, 16: FURY_ATTACK, 23: TRIPLE_KICK, 30: DRILL_PECK, 38: AGILITY, 45: THRASH.

### Dodrio

Stats: 60 / 110 / 70 / 100 / 60.

Starts: PECK, GROWL, FURY_ATTACK.

Level-up: 9: QUICK_ATTACK, 16: FURY_ATTACK, 23: TRIPLE_KICK, 30: DRILL_PECK, 32: TRI_ATTACK, 38: AGILITY, 45: THRASH.

### Seel

Stats: 65 / 45 / 55 / 45 / 70.

Starts: HEADBUTT, GROWL.

Level-up: 8: WATER_GUN, 15: ICY_WIND, 22: REST, 29: AURORA_BEAM, 41: BRINE, 48: ICE_BEAM.

### Dewgong

Stats: 90 / 70 / 80 / 70 / 95.

Starts: HEADBUTT, GROWL, WATER_GUN.

Level-up: 8: WATER_GUN, 15: ICY_WIND, 22: REST, 29: AURORA_BEAM, 35: ICE_ARMOR, 41: BRINE, 48: ICE_BEAM.

## Roles, machines and evolution

Magnemite/Magneton remain pure Electric. Zap Cannon replaces only their proposed level-54 Thunder slot, not Thunder globally. Thunder Wave enables Zap Cannon's accuracy bypass and Shock Wave's guaranteed criticals. Charge boosts Special and accuracy; its Special boost benefits ordinary Zap Cannon damage but is ignored by Shock Wave criticals. Thunderbolt, Thunder, Thunder Wave, Reflect and Rest machine permissions remain intact; Toxic was already unavailable. Other permissions not specified for removal remain unchanged. Evolution remains level 30.

Doduo/Dodrio emphasize running speed, multiple heads, kicks and aggressive physical attacks. Triple Kick directly replaces Double Kick at 23 for both. Dodrio gains Tri Attack immediately after its level-31 evolution. Thrash at 45 is the final approved choice, replacing the temporary Flail/Aerial Ace suggestions. Remove Roost, Gale Wind, Aerial Ace and Rage leveling. Remove Roost TM51, add Agility TM63; keep Facade and Aerial Ace machines. Restore Double-Edge TM10, remove Whirlwind and Sky Attack from both, and Hyper Beam from Dodrio. Keep Fly field access, Body Slam, Double Team, Reflect, Swift, Tri Attack and Rest.

Seel/Dewgong focus on defensive Ice control. Icy Wind lowers Speed; Aurora Beam can lower Attack; Dewgong gains Ice Armor immediately after evolution at 34. Rest supplies sleep-based recovery. Brine rewards weakening the target. The revised lists replace provisional Ice Shard, Icicle Spear, Frost Breath, Flash Freeze and Take Down additions. Existing machine permissions are unchanged because this plan specified no machine changes. Seel remains Water; Dewgong remains Water/Ice.

Custom variants retain individual headers and machine masks; existing shared parent learnset pointers follow revised parent lists. Shops and prices are unchanged.

## Updating and validation

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain their layout; already learned moves are not automatically deleted. Older 151/172/176-species saves require a fresh start.

The tuning registry now contains 89 reviewed entries: 88 originals plus Crobat. Tests check exact stats/starts/learnsets and actual generated moves/PP, original/extra TM masks and historical variants. Dedicated new-move tests cover both actors, accuracy/status boundaries, partial Triple Kick misses, PP, Substitute, KO, immunity and airborne targets. All earlier species, sprite, encounter, save, move, crit and freeze regressions remain included. Packaging applies both BPS files to verified originals and compares byte for byte with each build.
