# Exeggutor, Marowak and Hitmon family redesigns

Cumulative Red/Blue patches retain all earlier sprites, species, types, move effects and family reviews. Counts remain 183 species and 227 move records. This patch changes six species' stats/starts/learnsets and approved machine masks; it adds no moves, effects, animation assets, items or save fields.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special.

### Exeggcute

Stats: 60 / 40 / 80 / 40 / 60.

Starts: BARRAGE, HYPNOSIS.

Level-up: 9: CONFUSION, 16: REFLECT, 23: LEECH_SEED, 30: PSYBEAM, 44: PSYCHIC_M, 51: SOLARBEAM.

### Exeggutor

Stats: 95 / 95 / 85 / 55 / 125.

Starts: BARRAGE, HYPNOSIS.

Level-up: 9: CONFUSION, 16: REFLECT, 23: LEECH_SEED, 30: PSYBEAM, 37: EGG_BOMB, 44: PSYCHIC_M, 51: SOLARBEAM.

### Cubone

Stats: 50 / 50 / 95 / 35 / 40.

Starts: BONE_CLUB, GROWL.

Level-up: 9: TAIL_WHIP, 16: HEADBUTT, 23: FOCUS_ENERGY, 34: BONEMERANG, 41: RAGE.

### Marowak

Stats: 70 / 95 / 110 / 45 / 50.

Starts: BONE_CLUB, GROWL.

Level-up: 9: TAIL_WHIP, 16: HEADBUTT, 23: FOCUS_ENERGY, 29: WAILING_CRY, 34: BONEMERANG, 41: RAGE, 48: CURSE.

### Hitmonlee

Stats: 50 / 120 / 53 / 87 / 55.

Starts: DOUBLE_KICK, MEDITATE.

Level-up: 15: ROLLING_KICK, 23: FOCUS_ENERGY, 31: BRICK_BREAK, 39: HI_JUMP_KICK, 47: MEGA_KICK.

### Hitmonchan

Stats: 60 / 105 / 79 / 76 / 70.

Starts: MEGA_PUNCH, COMET_PUNCH.

Level-up: 15: COUNTER, 23: FIRE_PUNCH, 28: ICE_PUNCH, 33: THUNDERPUNCH, 39: BULK_UP, 47: BRICK_BREAK.

## Roles and compatibility

Exeggcute/Exeggutor keep their stats and Grass/Psychic typing. Barrage is special Grass multihit damage; Egg Bomb is physical Normal damage that breaks screens. Keep Hypnosis, Leech Seed and Reflect but remove provisional Ingrain, Synthesis, Giga Drain, Psyshock, Mind Break and powder leveling. Keep existing Psychic, Psywave, Reflect, Rest, Mimic, Substitute, Dream Eater, Egg Bomb, Self-Destruct and Explosion machine permissions; Exeggutor retains Mega Drain and Solar Beam. Remove Curse TM60 from both and Hyper Beam from Exeggutor. Leaf Stone evolution retains a full final-form learnset.

Cubone keeps its stats and pure Ground typing. Marowak retains Ground/Ghost, with HP 60→70 and Attack 80→95. Evolution remains level 28; Wailing Cry arrives at 29 and Bonemerang at 34. Remove Astonish, Leer and Thrash leveling. Focus Energy and Rage are alternative offensive strategies because critical hits ignore Attack stages; Rage boosts persist after the lock until switching or stage reset. Wailing Cry's Special reduction weakens special offense as well as durability, while Bonemerang remains physical. Remove Earthquake, Fissure, Water Gun, Bubblebeam, Ice Beam, Blizzard and Fire Blast machines from both, plus Hyper Beam from Marowak. Keep Dig, Rock Tomb, Rock Slide, Body Slam, Strength, Counter, Seismic Toss, Rest and Curse. Marowak retains Will-O-Wisp; Mega Punch, Mega Kick and Submission remain available. No Shadow Leech or immediate recovery is added.

Hitmonlee gains Special 35→55; other stats stay unchanged. Its setup identity is Meditate (+Attack/+Speed), with Brick Break for reliable damage and High Jump Kick/Mega Kick for riskier power. Remove provisional Bulk Up, Pierce and Flying Punch (internal Jump Kick) leveling. Remove Mega Punch TM01 and Bulk Up TM56; add Facade TM52 and Agility TM63. Keep Mega Kick, Submission, Counter, Seismic Toss, Body Slam, Swift, Strength and Rest. Earthquake, Dig and Rock coverage remain unavailable. Triple Kick stays with the reviewed Doduo family.

Hitmonchan gains HP 50→60 and Special 35→70; other stats stay unchanged. Fire, Ice and Thunder Punch remain special because move category is type-based. Bulk Up strengthens its physical punches and Defense, not the elemental punches. Mega Punch and Comet Punch replace its old Comet Punch/Agility start. Remove provisional Drain Punch and Pierce leveling. Remove Mega Kick TM05, Submission TM17 and Bide TM34; add Facade TM52. Keep Mega Punch, Counter, Seismic Toss, Body Slam, Strength, Swift, Rest and Bulk Up. Earthquake, Dig and Rock coverage remain unavailable. It has no evolution changes.

Other existing machine permissions are unchanged. Shop stock/prices are unchanged. Custom variants retain their own stats, starting moves and machine masks; existing shared parent learnset pointers follow parent revisions.

## Updating and verification

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain the same layout; older 151/172/176-species saves require a fresh start. Already learned moves are not automatically removed. Existing party stat changes take effect on normal recalculation, such as leveling up.

The tuning registry contains 108 reviewed entries: all 107 original species through Hitmonchan, plus Crobat. Existing tests check exact stats/starts/learnsets and real generated moves/PP, original/extra TM permissions and historical variants. All species, sprite, encounter, save, move, crit and freeze regressions remain included in both versions. Packaging applies both BPS patches to verified originals and compares byte for byte with the builds.
