# Claydol, Dittwo, Tyranitar and Dragonite redesigns

Cumulative Red/Blue patches retain earlier sprites, species, move effects and reviews. Counts remain 183 species, now with 233 move records. No item, animation asset or save field is added. Added-species metadata and the review registry are synchronized.

## Duplicate and Dittwo entry behavior

New move 233: Duplicate, Normal status, 100 accuracy, 10 PP. Exact Mimic effect and animation: ordinary player battles let the player choose an opponent move; enemy/link use follows existing random Mimic selection. It temporarily replaces its own active move slot, without transforming species, typing or stats. It uses existing Mimic PP behavior rather than Transform's five-PP rule. Original party moves are preserved and normal switching reloads them. No Mimic TM is added to Dittwo.

Dittwo is removed from automatic-transformation eligibility and from the exclusions on Ditto's transformation targets. Ditto and Happy Ditto retain automatic transformation; they may now copy untransformed Dittwo. Dittwo itself never auto-transforms. A copied Transform move remains usable under the ordinary move's rules; Dittwo's natural moves and machines do not include Transform.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special.

### Baltoy

Stats: 40 / 40 / 55 / 55 / 55.

Starts: CONFUSION, HARDEN.

Level-up: 9: ROCK_THROW, 17: NIGHT_SHADE, 25: PSYBEAM, 33: REFLECT, 45: WAILING_CRY.

### Claydol

Stats: 60 / 70 / 105 / 75 / 120.

Starts: CONFUSION, HARDEN, ROCK_THROW.

Level-up: 9: ROCK_THROW, 17: NIGHT_SHADE, 25: PSYBEAM, 33: REFLECT, 37: STONE_PRESS, 45: WAILING_CRY, 53: LIGHT_SCREEN.

### Dittwo

Stats: 132 / 33 / 66 / 33 / 66.

Starts: DUPLICATE.

Level-up: 10: DOUBLESLAP, 30: STOCKPILE, 40: SLUDGE, 50: RECOVER.

### Larvitar

Stats: 50 / 64 / 50 / 41 / 45.

Starts: BITE, LEER.

Level-up: 8: SAND_ATTACK, 16: ROCK_THROW, 24: DIG, 32: CRUNCH, 40: ROCK_SLIDE, 48: EARTHQUAKE.

### Pupitar

Stats: 70 / 84 / 70 / 51 / 65.

Starts: BITE, LEER, SAND_ATTACK.

Level-up: 8: SAND_ATTACK, 16: ROCK_THROW, 24: DIG, 32: CRUNCH, 40: ROCK_SLIDE, 48: EARTHQUAKE.

### Tyranitar

Stats: 100 / 134 / 110 / 61 / 95.

Starts: BITE, LEER, ROCK_THROW.

Level-up: 8: SAND_ATTACK, 16: ROCK_THROW, 24: DIG, 32: CRUNCH, 40: ROCK_SLIDE, 48: EARTHQUAKE, 56: DRAGON_RAGE, 64: OUTRAGE.

## Roles and machine compatibility

Baltoy/Claydol keep their stats and Rock/Ghost typing, evolving at 36. Night Shade supplies dependable damage; Psybeam preserves psychic heritage; Reflect/Light Screen establish a guardian role. Stone Press at 37 uses Claydol's Defense, while Wailing Cry lowers Special. Remove Tackle, Astonish, Earthquake, natural Psychic and Explosion leveling. Add Psychic TM29, Psywave TM30, Reflect TM33, Rock Tomb TM57 and Curse TM60 to both. Keep Double Team, Substitute and Rest; remove Toxic and Double-Edge. No immediate recovery, Special setup, Earthquake/Explosion addition or Levitate ability.

Dittwo uses 132 HP / 33 Attack / 66 Defense / 33 Speed / 66 Special. Duplicate, Double Slap, Stockpile, Sludge and Recover replace its old Transform-only progression. Its complete machine pool is Body Slam TM08, Water Gun TM11, Rest TM44 and Substitute TM50, with no extra TMs. Stockpile raises Defense and Special, supporting Water Gun or copied special attacks; Sludge remains physical with poison pressure. High-level generated moves follow the usual last-four rule, so players retaining Duplicate should choose which later move to skip. Normal typing blocks this game's Curse. Rest can cure Toxic, making poison counterplay rather than a guaranteed knockout. Existing party Dittwo do not automatically forget previously learned Transform; use normal replacement/relearning for old saves.

Larvitar/Pupitar become Rock/Ground; Tyranitar becomes Rock/Dragon. Stats and evolution at 30/55 stay unchanged. Rock Slide at 40 is the final approved replacement for proposed Thrash, supplying physical Rock STAB. Crunch uses Attack; Dragon Rage/Outrage use Special. Tyranitar gains Dragon Rage at 56 after acquiring Dragon typing. Keep Double-Edge, Double Team, Substitute and Rest machines; remove Toxic from all three. Add Dig TM28, Earthquake TM26, Rock Slide TM48 and Rock Tomb TM57 to all three. Add Fire Blast TM38, Thunder TM25, Blizzard TM14 and Hyper Beam TM15 to Tyranitar only. No Dragon Dance, Rock Polish, defensive setup or immediate recovery. Early stages have double Water/Grass weaknesses; Tyranitar has ordinary Ice, Fighting, Ground and Dragon weaknesses, with neutral Water/Grass matchups.

Dragonite becomes pure Dragon; Dratini/Dragonair stay pure Dragon. Dragonite's stats and previously approved learnset stay unchanged, including Wing Attack at 56 as coverage rather than STAB. It loses Ground immunity and Rock weakness, gains Electric resistance, and has ordinary Ice weakness instead of double Ice weakness. Dragon Dance supports physical coverage; Outrage stays special. Roost remains unavailable, with no compensating stat buff or extra move assignment.

The existing type chart itself is unchanged. All other machine permissions, encounters, shops and prices stay unchanged. Custom variants retain individual headers/masks and any existing shared parent learnsets.

## Deferred review and updating

The earlier-species/new-move distribution review remains saved for last. Duplicate joins its pending list; no broad redistribution is performed here.

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain their layout; older 151/172/176-species saves require a fresh start. Already known moves are not automatically removed. Existing party stats update on normal recalculation. Previously saved party Pokémon may retain their stored old typings; newly generated specimens use the revised typings immediately.

## Validation

The tuning registry now contains 162 entries: all original 151 and all eleven additional species. Existing tests validate exact stats/starts/learnsets, real generated moves/PP, original/extra machine masks and historical variants. Dedicated tests cover player-selected/enemy-random Duplicate, PP, identity/type/stat/party preservation, normal switch restoration, failure, Dittwo entry exclusion, Ditto copying Dittwo and SRAM retention. Actual damage tests verify pure Dragon, Rock/Dragon and Rock/Ground effectiveness, including double weaknesses and Electric immunity. Earlier auto-Transform tests continue for Ditto/Happy Ditto; all prior species, sprite, encounter, save, move, crit and freeze regressions remain included. Packaging applies both BPS patches to verified originals and compares byte for byte with the builds.
