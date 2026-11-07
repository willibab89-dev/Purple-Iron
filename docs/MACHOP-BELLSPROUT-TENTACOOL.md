# Machop, Bellsprout and Tentacool family redesigns

Cumulative Red/Blue patches retain all earlier sprites, species, move effects, type changes and reviews. Counts remain 183 species and 222 moves. No new move, TM item, battle effect or save field is introduced. All eight species keep their existing stats.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special. CLAMP is the existing internal constant for the displayed move Chomp.

### Machop

Stats: 70 / 80 / 50 / 35 / 35.

Starts: KARATE_CHOP, LEER.

Level-up: 8: LOW_KICK, 15: FOCUS_ENERGY, 22: SEISMIC_TOSS, 28: BULK_UP, 34: BRICK_BREAK, 41: SUBMISSION.

### Machoke

Stats: 80 / 100 / 70 / 45 / 50.

Starts: KARATE_CHOP, LEER, LOW_KICK.

Level-up: 8: LOW_KICK, 15: FOCUS_ENERGY, 22: SEISMIC_TOSS, 28: BULK_UP, 34: BRICK_BREAK, 41: SUBMISSION.

### Machamp

Stats: 90 / 130 / 80 / 55 / 65.

Starts: KARATE_CHOP, LEER, LOW_KICK.

Level-up: 8: LOW_KICK, 15: FOCUS_ENERGY, 22: SEISMIC_TOSS, 28: BULK_UP, 34: BRICK_BREAK, 41: SUBMISSION, 49: PIERCE, 56: MEGA_KICK.

### Bellsprout

Stats: 50 / 75 / 35 / 40 / 70.

Starts: VINE_WHIP, GROWTH.

Level-up: 7: WRAP, 12: POISONPOWDER, 16: SLEEP_POWDER, 21: ACID, 27: RAZOR_LEAF, 33: SLAM.

### Weepinbell

Stats: 65 / 90 / 50 / 55 / 85.

Starts: VINE_WHIP, GROWTH, WRAP.

Level-up: 7: WRAP, 12: POISONPOWDER, 16: SLEEP_POWDER, 21: ACID, 27: RAZOR_LEAF, 33: SLAM.

### Victreebel

Stats: 80 / 105 / 65 / 70 / 100.

Starts: VINE_WHIP, GROWTH, WRAP, ACID.

Level-up: 7: WRAP, 12: POISONPOWDER, 16: SLEEP_POWDER, 21: ACID, 27: RAZOR_LEAF, 33: SLAM, 39: POISON_FANG, 45: CLAMP.

### Tentacool

Stats: 40 / 40 / 35 / 70 / 100.

Starts: POISON_STING, WATER_GUN.

Level-up: 7: SUPERSONIC, 13: ACID, 19: POISONPOWDER, 25: BIND, 31: BRINE, 37: BARRIER, 43: VENOSHOCK, 49: HYDRO_PUMP.

### Tentacruel

Stats: 80 / 70 / 65 / 100 / 120.

Starts: POISON_STING, WATER_GUN, SUPERSONIC.

Level-up: 7: SUPERSONIC, 13: ACID, 19: POISONPOWDER, 25: BIND, 31: BRINE, 37: BARRIER, 43: VENOSHOCK, 49: HYDRO_PUMP.

## Roles and machine compatibility

Machop's family uses disciplined strength and defense-breaking attacks. Remove provisional Drain Punch leveling. Keep Bulk Up, Brick Break and Submission; Machamp gains Pierce at 49 and Mega Kick at 56. Pierce ignores positive target Defense stages, while Brick Break handles screens. Focus Energy is an alternative to Bulk Up because critical hits ignore Attack stages. Remove Fissure, Dig and Fire Blast from all three, plus Hyper Beam from Machamp. Keep Earthquake, Rock Slide, Rock Tomb, Strength, Counter, Fighting attacks, Body Slam, Double-Edge, Facade, Bulk Up and Rest.

Bellsprout's family traps, poisons and devours prey. Remove provisional Synthesis, Ingrain and Giga Drain, and remove Stun Spore leveling. Wrap does 25-power initial damage and cached damage over its 2–3 turn duration; both combatants can act, and the target cannot voluntarily switch while held. Slam lowers Defense after an eligible hit. Poison Fang can upgrade ordinary poison to bad poison. Chomp is Water-type, 50 power, 90 accuracy, 10 PP, and heals half actual damage dealt. Add Poison Tail TM62 and restore Double-Edge TM10 to all three; remove Hyper Beam from Victreebel. Keep Swords Dance, Toxic, Venoshock, Reflect, Rest, Cut, Mega Drain and Solar Beam.

Tentacool's family uses venom, slowing tentacles and strong Special. Implement the audit adjustment: Tentacool starts with both Poison Sting and Water Gun; Acid arrives at 13 and Poison Powder at 19 for both. This avoids relying solely on weak physical Poison Sting and gives Venoshock a natural poison setup move without requiring a TM. Replace Wrap, Constrict, Coil and Screech leveling with the listed progression. Bind lowers Speed without trapping; Brine doubles base power at or below half target HP; Venoshock doubles against ordinary or bad poison, but remains physical. Keep Toxic, Surf, Brine, Venoshock, Ice Beam, Blizzard, Reflect, Double Team, Rest, Swords Dance and Cut. Remove Mega Drain from both and Hyper Beam from Tentacruel. Scald remains unavailable.

Evolution remains Machop 28 → Machoke 48 → Machamp (trade also available); Bellsprout 21 → Weepinbell, then Leaf Stone → Victreebel; Tentacool 30 → Tentacruel. Final forms have their own complete level-up lists. Custom variants retain individual stats, starts and TM masks; existing shared learnset pointers follow revised parent leveling. Shop stock and prices are unchanged.

## Updating and validation

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain the same layout; older 151/172/176-species saves require a fresh start. Already learned moves are not automatically deleted.

The tuning registry contains 76 reviewed entries: 75 originals plus Crobat. Existing tests verify exact stats/starting moves/learnsets, generated moves and PP, original and extra machine permissions, and historical custom variants. Full species, sprite, encounter, save, move, critical-hit and freeze regressions run in both versions. Packaging applies each BPS to its verified original and compares the result byte for byte with the build.
