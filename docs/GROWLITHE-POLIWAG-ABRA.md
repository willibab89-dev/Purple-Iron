# Growlithe, Poliwag and Abra family redesigns

Cumulative Red/Blue patches retain all previous sprites, species, move effects and reviews. Counts remain 183 species and 222 moves. No new move, item or save field is added.

## Stats and learnsets

Stats below are HP / Attack / Defense / Speed / Special.

### Growlithe

Stats: 55 / 70 / 45 / 60 / 50.

Starts: BITE, ROAR.

Level-up: 7: EMBER, 13: LEER, 19: FLAME_CHARGE, 25: TAKE_DOWN, 31: AGILITY, 37: FLAMETHROWER, 44: DOUBLE_EDGE.

### Arcanine

Stats: 90 / 110 / 80 / 95 / 80.

Starts: BITE, ROAR, EMBER.

Level-up: 7: EMBER, 13: LEER, 19: FLAME_CHARGE, 25: TAKE_DOWN, 31: AGILITY, 37: FLAMETHROWER, 44: DOUBLE_EDGE, 52: FIRE_BLAST.

### Poliwag

Stats: 40 / 50 / 40 / 90 / 40.

Starts: BUBBLE.

Level-up: 8: HYPNOSIS, 14: WATER_GUN, 20: DOUBLESLAP, 26: BUBBLEBEAM, 32: BODY_SLAM, 38: AMNESIA, 44: HYDRO_PUMP.

### Poliwhirl

Stats: 65 / 65 / 65 / 90 / 50.

Starts: BUBBLE, HYPNOSIS, WATER_GUN.

Level-up: 8: HYPNOSIS, 14: WATER_GUN, 20: DOUBLESLAP, 26: BUBBLEBEAM, 32: BODY_SLAM, 38: AMNESIA, 44: HYDRO_PUMP.

### Poliwrath

Stats: 90 / 95 / 95 / 70 / 70.

Starts: BUBBLE, HYPNOSIS, WATER_GUN, DOUBLESLAP.

Level-up: 8: HYPNOSIS, 14: WATER_GUN, 20: DOUBLESLAP, 26: BUBBLEBEAM, 30: DRAIN_PUNCH, 32: BODY_SLAM, 38: BULK_UP, 44: HYDRO_PUMP, 50: SUBMISSION.

### Abra

Stats: 25 / 20 / 15 / 90 / 95.

Starts: TELEPORT.

Level-up: None.

### Kadabra

Stats: 40 / 35 / 30 / 105 / 110.

Starts: TELEPORT, KINESIS, CONFUSION.

Level-up: 16: CONFUSION, 20: DISABLE, 25: PSYBEAM, 30: RECOVER, 35: KINESIS, 40: PSYCHIC_M, 44: PSYCH_UP.

### Alakazam

Stats: 55 / 50 / 45 / 120 / 120.

Starts: TELEPORT, KINESIS, CONFUSION.

Level-up: 16: CONFUSION, 20: DISABLE, 25: PSYBEAM, 30: RECOVER, 35: KINESIS, 40: PSYCHIC_M, 44: PSYCH_UP, 50: MIND_BREAK.

Only Poliwrath Attack (85→95) and Abra/Kadabra/Alakazam Special (105→95, 120→110, 135→120) change. Evolution remains Fire Stone for Growlithe, level 25 then Water Stone for Poliwag, and level 16 then level 46 (or trade) for Abra. Evolved forms retain full level-up lists.

## Roles and TM changes

Growlithe/Arcanine use charging and recoil attacks. Take Down has 60 power, doubled against targets strictly below half HP, and retains recoil; Double-Edge is consistently 100 power. Remove provisional Will-O-Wisp, Incinerate and Cauterize leveling. Add Facade TM52 and Agility TM63, remove Will-O-Wisp TM58, retain Body Slam TM08, Dig, Reflect, Rest and Fire options. Arcanine retains Hyper Beam. Body Slam was already available, so its planned restoration requires no mask change.

Poliwrath becomes a bulky wrestler with Hypnosis, Drain Punch and Bulk Up, with Submission as its stronger recoil alternative. Remove provisional Aqua Jet, Scald and Brick Break leveling. Scald stays a TM. Add Facade to Poliwhirl/Poliwrath. Remove Earthquake and Fissure from those two, and Hyper Beam from Poliwrath. Other existing permissions, including Surf, Ice coverage, Psychic, Counter, Seismic Toss, Strength and Poliwrath Bulk Up, stay intact.

Abra retains its Teleport-only leveling identity. Kadabra/Alakazam use Kinesis, recovery and opponent-dependent tricks rather than Special boosting. Remove Psyshock from all three level-up lists, and remove Disable from evolved starting slots so it first arrives at level 20. Mind Break damages before clearing positive target Special stages; Psych Up copies all target stages, including negative ones. Remove Mega Punch, Mega Kick, Body Slam and Submission from all three, Dig from Kadabra/Alakazam and Hyper Beam from Alakazam. Keep Counter, Seismic Toss, Thunder Wave, Reflect, Mimic, Metronome, Substitute, Double Team, Rest and Psychic options.

Custom variants retain their individual headers and TM permissions. Any existing shared parent learnset pointers continue to follow that parent's revised level-up list. Shop stock and prices are unchanged.

## Updating and validation

Apply the matching BPS to an original unmodified English Red/Blue ROM. Current 183-species saves remain compatible. Already learned moves are not automatically removed; normal leveling recalculates party stats. Older 151/172/176-species saves require a fresh start.

The tuning registry now has 68 reviewed entries: 67 originals plus Crobat. Existing tests verify exact stats, starting moves, complete learnsets, generated moves/PP and original/extra TM permissions in both versions. Full species, sprite, encounter, save, move, crit and freeze regressions remain included. Packaging applies both BPS patches to verified originals and checks byte-for-byte reproduction.
