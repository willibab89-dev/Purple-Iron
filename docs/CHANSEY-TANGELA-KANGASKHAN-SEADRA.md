# Chansey, Tangela, Kangaskhan and Seadra redesigns

Cumulative Red/Blue patches retain all earlier sprites, species, type changes, move effects and family reviews. Counts remain 183 species, now with 228 move records. Only Seadra's HP changes (55→65); other reviewed stats stay unchanged. No items, animation assets or save fields are added.

## Vine Crush

New move 228: Grass, special, 70 power, 100 accuracy, 10 PP. Double base power (140) against a paralyzed target, checked at execution. Other statuses do not activate it. Ordinary accuracy, effectiveness, invulnerability and Substitute handling remain intact; it is not a trapping effect. Critical hits retain conditional power but use existing critical stat rules. Uses Vine Whip's animation, and the AI evaluates its current conditional power. Tangela learns it at 49 instead of Solar Beam; Solar Beam remains an optional TM.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special.

### Chansey

Stats: 250 / 5 / 5 / 50 / 105.

Starts: POUND, GROWL.

Level-up: 9: DOUBLESLAP, 16: SING, 23: SOFTBOILED, 30: SEISMIC_TOSS, 38: LIGHT_SCREEN, 46: EGG_BOMB.

### Tangela

Stats: 65 / 55 / 115 / 60 / 100.

Starts: CONSTRICT, ABSORB.

Level-up: 9: BIND, 17: STUN_SPORE, 25: MEGA_DRAIN, 33: INGRAIN, 41: GROWTH, 49: VINE_CRUSH.

### Kangaskhan

Stats: 105 / 95 / 80 / 90 / 40.

Starts: POUND, GROWL.

Level-up: 9: BITE, 17: RAGE, 25: MEGA_PUNCH, 33: COUNTER, 41: DIZZY_PUNCH, 49: FACADE.

### Horsea

Stats: 30 / 40 / 70 / 60 / 70.

Starts: BUBBLE.

Level-up: 8: SMOKESCREEN, 15: WATER_GUN, 22: FOCUS_ENERGY, 29: SNIPE_SHOT, 36: AGILITY, 50: HYDRO_PUMP.

### Seadra

Stats: 65 / 65 / 95 / 85 / 95.

Starts: BUBBLE, SMOKESCREEN.

Level-up: 8: SMOKESCREEN, 15: WATER_GUN, 22: FOCUS_ENERGY, 29: SNIPE_SHOT, 36: AGILITY, 43: DRAGON_RAGE, 50: HYDRO_PUMP.

## Roles and machine changes

Chansey remains a healer and special wall. Learn Soft-Boiled and Seismic Toss naturally, retaining Sing, Light Screen and thematic Egg Bomb; Egg Bomb's poor physical damage is offset by its screen-breaking utility. Remove Tail Whip, Minimize, Defense Curl and Double-Edge leveling. Keep Soft-Boiled, Seismic Toss, Counter, Thunder Wave, Reflect, Rest, Ice Beam, Blizzard, Thunderbolt, Thunder, Psychic, Fire Blast, Egg Bomb, Mimic, Metronome and Dream Eater permissions. Remove Mega Punch, Mega Kick, Submission, Body Slam, Hyper Beam, Solar Beam, Water Gun, Bubblebeam, Skull Bash and Bide. Toxic stays unavailable. No physical stat buff or extra defensive setup is added.

Tangela is a rooted vine controller. Ingrain heals 1/16 maximum HP per round and prevents voluntary switching; Growth raises Special and Defense. Stun Spore activates Vine Crush's conditional power. Mega Drain offers weaker draining damage without taking Vileplume's Giga Drain identity. Remove Poison Powder, Sleep Powder, Synthesis, Giga Drain, Vine Whip and Slam leveling. Keep Mega Drain, Solar Beam, Rest, Body Slam and Cut permissions; remove Hyper Beam, Swords Dance, Bide and Venoshock TM54. No Leech Seed or immediate recovery is added. Ingrain/Growth/Stun Spore/Vine Crush occupies all four slots; adding Mega Drain requires sacrificing a component.

Kangaskhan uses Rage, Counter and Dizzy Punch as a protective parent. Pound/Growl replaces Comet Punch/Rage starting moves. Remove Tail Whip, Leer and Brick Break leveling; learn Facade at 49. Rage's boosts persist after the lock until a stage-reset condition removes them. Facade ignores burn's Attack penalty; other physical attacks do not. Keep Body Slam, Double-Edge, Facade, Mega Punch, Mega Kick, Submission, Counter, Seismic Toss, Strength, Rest and Surf. Keep Ice Beam, Blizzard and Thunderbolt as optional coverage limited by Special 40. Remove Earthquake, Fissure, Rock Slide, Fire Blast, Thunder, Hyper Beam and Bulk Up TM56. No immediate recovery or defensive setup is added.

Horsea/Seadra remain pure Water and evolve at 32. Seadra gains HP 55→65. Focus Energy supports precise special attacks; Snipe Shot has no extra critical bonus, but bypasses accuracy/evasion checks. Dragon Rage is 60-power special Dragon damage, not fixed damage. Remove Leer, Aqua Jet, Brine and Dragon Dance leveling. Keep Surf, Ice Beam, Blizzard, Double Team, Swift, Rest and Brine machine permissions. Remove Scald TM59 from both; add Agility TM63 to both. Remove Hyper Beam from Seadra. No Special boosting or immediate recovery is added.

Other machine permissions, shops and prices remain unchanged. Custom variants retain their own headers and machine masks; shared parent learnset pointers follow revised parent lists.

## Updating and validation

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain the same layout; older 151/172/176-species saves require a fresh start. Already learned moves are not automatically deleted. Existing Seadra party HP stats update on normal recalculation, such as leveling up.

The tuning registry now contains 118 entries: all 117 original species through Seadra, plus Crobat. Tests verify exact stats/starts/learnsets, real generated moves/PP, original/extra machine masks and historical variants. Dedicated Vine Crush tests cover both actors, target statuses, critical power, action-time condition changes, actual damage/PP, accuracy, Fly/Dig, Substitute, type effectiveness, AI and SRAM retention. All previous species, sprite, encounter, save, move, crit and freeze regressions remain included. Packaging applies both BPS files to verified originals and compares byte for byte with the builds.
