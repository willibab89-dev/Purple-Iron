# Muk, Cloyster and Gengar family redesigns

Cumulative Red/Blue patches retain all previous sprites, added species, type changes, move effects and reviews. Counts remain 183 species, now with 226 move records. All seven reviewed species keep their existing stats. No new item, animation asset or save field is introduced.

## New moves

- Mud Wave (225): Ground, physical, 80 power, 95 accuracy, 15 PP. After an eligible hit, 77/256 (about 30%) chance to lower target accuracy one stage. No drop on miss, immunity, Substitute (including a breaking hit), Mist or KO. Accuracy stages clamp normally. Uses Surf's animation.
- Shell Smash (226): Normal status, 10 PP. User Attack +2, Speed +2, Defense −2. Each stat clamps independently; a capped boost never blocks another boost or the Defense reduction. Self setup works regardless of opposing Substitute/Mist. AI discourages it when both offensive boosts are capped. Uses Withdraw's animation. It is distinct from the existing damaging Bug move Shell Break; Stone Press remains unchanged for other Pokémon.

Both moves are appended without changing old IDs. Names, PP, animation mappings, Metronome bounds and saved move bytes support both additions.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special. CLAMP is Chomp's internal constant.

### Grimer

Stats: 80 / 80 / 50 / 25 / 40.

Starts: POUND, DISABLE.

Level-up: 7: POISON_GAS, 10: HARDEN, 14: POLLUTION, 21: SLUDGE, 28: MUD_WAVE, 35: SCREECH.

### Muk

Stats: 105 / 105 / 75 / 50 / 65.

Starts: POUND, DISABLE, POISON_GAS.

Level-up: 7: POISON_GAS, 10: HARDEN, 14: POLLUTION, 21: SLUDGE, 28: MUD_WAVE, 35: SCREECH, 39: ACID_ARMOR, 53: TOXIC.

### Shellder

Stats: 30 / 65 / 100 / 40 / 45.

Starts: TACKLE, WITHDRAW.

Level-up: 7: WATER_GUN, 13: SUPERSONIC, 19: CLAMP, 25: AURORA_BEAM, 31: ICICLE_SPEAR, 43: ICE_BEAM.

### Cloyster

Stats: 50 / 95 / 180 / 70 / 85.

Starts: TACKLE, WITHDRAW, WATER_GUN.

Level-up: 7: WATER_GUN, 13: SUPERSONIC, 19: CLAMP, 25: AURORA_BEAM, 31: ICICLE_SPEAR, 37: SPIKE_CANNON, 43: ICE_BEAM, 49: SHELL_SMASH.

### Gastly

Stats: 30 / 35 / 30 / 80 / 100.

Starts: LICK, CONFUSE_RAY.

Level-up: 8: HYPNOSIS, 15: NIGHT_SHADE, 22: WAILING_CRY, 29: DREAM_EATER, 36: CURSE, 43: SHADOW_LEECH.

### Haunter

Stats: 45 / 50 / 45 / 95 / 115.

Starts: LICK, CONFUSE_RAY.

Level-up: 8: HYPNOSIS, 15: NIGHT_SHADE, 22: WAILING_CRY, 29: DREAM_EATER, 36: CURSE, 43: SHADOW_LEECH.

### Gengar

Stats: 60 / 65 / 60 / 110 / 130.

Starts: LICK, CONFUSE_RAY.

Level-up: 8: HYPNOSIS, 15: NIGHT_SHADE, 22: WAILING_CRY, 29: DREAM_EATER, 36: CURSE, 43: SHADOW_LEECH, 50: PSYCHIC_M.

## Roles, machines and evolutions

Grimer/Muk retain Ground/Poison. Harden at 10 precedes Muk's Acid Armor at 39, immediately after evolution at 38. Mud Wave at 28 replaces the provisional Stockpile slot; there is no Earthquake addition. Remove Minimize and Venoshock leveling; Venoshock remains a TM. Keep Toxic, Body Slam, Rest, Substitute and Mega Drain permissions. Remove Thunderbolt, Thunder, Fire Blast, Self-Destruct and Explosion from both, plus Hyper Beam from Muk. Poison Gas and late Toxic offer different poison options; Pollution supplies anti-Water coverage.

Shellder/Cloyster retain Water Stone evolution and full evolved leveling. Withdraw, Chomp and projectile attacks support the armored-shell identity. Cloyster gains Spike Cannon at 37 and Shell Smash at 49, replacing the proposed Stone Press slot. Shell Smash strengthens physical Rock-type Spike Cannon, but not special Ice/Water attacks. Remove provisional Icy Wind, Ice Shard, Brine, Ice Armor, Flash Freeze and Leer leveling. Keep Surf, Brine, Ice Beam, Blizzard, Reflect, Rest, Tri Attack, Self-Destruct and Explosion machine permissions. Remove Hyper Beam from Cloyster; Toxic remains unavailable.

Gastly/Haunter/Gengar retain Ghost/Poison and evolution at 25 then 45 (trade also available). Night Shade is removed from starting slots and learned at 15; Normal targets therefore require existing TM alternatives early on. Hypnosis/Dream Eater and Curse/Shadow Leech are alternative recovery strategies. Shadow Leech heals all actual damage against sleeping or cursed targets; Curse fails against Normal, poison/Toxic and Leech Seed. Wailing Cry is physical Ghost damage that lowers Special, helping later Psychic attacks. Psychic is learned naturally by Gengar at 50. Remove Astonish, Punishment and Will-O-Wisp leveling; Will-O-Wisp remains a machine option. Remove Toxic, Self-Destruct and Explosion from all three, and Hyper Beam from Gengar. Keep existing Psychic, Dream Eater, Curse, Will-O-Wisp, Thunderbolt, Thunder, Mega Drain, Mimic, Substitute and Rest permissions. Reflect stays unavailable.

Other permissions not explicitly changed remain intact. Custom variants retain their individual stats, starts and machine masks; shared parent learnset pointers follow parent revisions. Shop inventory and prices are unchanged.

## Updating and validation

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain their layout; already known moves are not automatically deleted. Older 151/172/176-species saves require a fresh start.

The tuning registry contains 96 reviewed entries: 95 originals plus Crobat. Existing checks validate exact stats, starting/level-up moves, real generated PP, original/extra machine permissions and historical variants in both versions. New tests cover Mud Wave chance boundaries and miss/immunity/Substitute/Mist/KO gates; Shell Smash stat caps, actual execution/PP, self protection gates and AI; and SRAM retention of both new IDs. The full species, sprite, encounter, save, move, critical-hit and freeze suites remain included. Packaging applies each BPS to a verified original and checks byte-for-byte reproduction.
