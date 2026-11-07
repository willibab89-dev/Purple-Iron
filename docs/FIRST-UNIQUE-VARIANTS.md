# First unique variant redesigns

Cumulative Red/Blue patches retain all earlier sprites, species, type changes, move effects and reviews. Counts remain 183 species, now with 235 move records. The four reviewed variants have independent no-evolution learnset tables; original species and their evolution chains stay unchanged. No item, animation asset or save field is added.

## New moves

- Heal Bell (234): Normal status, 5 PP, Sing animation. Cures major status on the user and living party members. Does not heal HP, revive fainted members, or clear confusion, Curse and other volatile effects. Clears active Toxic counters and recalculates active stats once without burn/paralysis penalties, preserving stages. Active battle status/HP is authoritative; the corresponding roster slot is skipped during reserve scans. Enemy trainer rosters use the same cure rules; wild enemies cure only themselves. Fails if no living eligible member has status. AI recognizes living statused reserves and ignores fainted ones.
- Charm (235): Normal status, 90 accuracy, 20 PP. Lowers target Attack two stages using the existing stat-drop handler and Growl animation. Respects accuracy, Substitute, Mist and normal stage caps.

Old move IDs stay unchanged. Both moves join Metronome's eligible pool and the deferred final move-distribution list. No broad earlier-species redistribution is performed here.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special. All four variants retain their existing typings, encounter/trainer placement and appearance. None evolves.

### blastoise_unique

Stats: 89 / 83 / 100 / 58 / 105.

Starts: TACKLE, TAIL_WHIP, WATER_GUN, WITHDRAW.

Level-up: 7: BUBBLE, 12: WATER_GUN, 18: WITHDRAW, 23: BITE, 30: SKULL_BASH, 37: SNIPE_SHOT, 45: SPIKE_CANNON, 54: HYDRO_PUMP.

### bulbasaur_unique

Stats: 75 / 79 / 79 / 75 / 95.

Starts: TACKLE, GROWL.

Level-up: 7: VINE_WHIP, 14: LEECH_SEED, 21: SLUDGE, 28: MEGA_DRAIN, 35: GROWTH, 42: VENOSHOCK, 49: SYNTHESIS, 56: SOLARBEAM.

### chansey_unique

Stats: 250 / 5 / 5 / 50 / 105.

Starts: POUND, GROWL.

Level-up: 9: SING, 17: DOUBLESLAP, 25: SOFTBOILED, 33: LIGHT_SCREEN, 41: MIST, 49: HEAL_BELL.

### charmander_unique

Stats: 69 / 82 / 73 / 95 / 80.

Starts: SCRATCH, GROWL.

Level-up: 7: EMBER, 14: CHARM, 21: RAGE, 28: FLAME_CHARGE, 35: SLASH, 42: FLAMETHROWER, 49: OUTRAGE, 56: FIRE_BLAST.

## Variant roles and machines

Unique Blastoise stays pure Water and rival-only when the rival chose Squirtle. HP rises to 89 like reviewed ordinary Blastoise, while 20 Speed is exchanged for Special (58 Speed/105 Special) to emphasize its cannons. It retains the reviewed Blastoise progression through Snipe Shot, Spike Cannon and Hydro Pump. Original/extra machine masks match reviewed Blastoise, including Brine/Scald and removal of Earthquake, Dig and Fissure. No immediate recovery is added.

Unique Bulbasaur is an Ash-inspired non-evolving Grass/Poison battler. All original base stats rise by 30 to 75/79/79/75/95. The final natural list includes Leech Seed, Sludge, Mega Drain, Growth, Venoshock, Synthesis and Solar Beam; Stockpile is removed. Growth boosts Special/Defense, while Sludge and Venoshock use Attack. Keep Toxic, Mega Drain, Solar Beam, Reflect, Rest, Cut and Venoshock TM54; remove Swords Dance and Body Slam machine access. No broad physical coverage or Hyper Beam. It remains a 1% Viridian Forest level-6 encounter.

Unique Chansey retains 250/5/5/50/105 stats and pure Normal typing, emphasizing party support instead of dependable damage. Learn Soft-Boiled, Light Screen, Mist and Heal Bell naturally. Its machine pool is Mimic, Reflect, Metronome, Soft-Boiled, Rest and Substitute only. Remove fixed-damage Seismic Toss/Counter, paralysis/Toxic options and broad attack coverage. It remains a 1% Cerulean Cave level-55 encounter. Heal Bell makes it a guardian healer rather than a stronger ordinary Chansey.

Unique Charmander is pure Fire, with no wings or Flying moves. It is non-evolving and receives +30 in each original stat: 69/82/73/95/80. Charm at 14 has the final approved 90 accuracy. Rage/Slash are physical alternatives; Fire attacks and Outrage use Special, so Rage does not boost those. Learn Flame Charge, Flamethrower, Outrage and Fire Blast later. Its machine pool is Double Team, Fire Blast, Swift, Rest and Facade TM52. No Ground coverage, Hyper Beam, Flying move, Roost, Cauterize or Dragon Dance. It remains a 1% Mt. Moon level-10 encounter.

Other variants, original species, shops and prices remain unchanged. Non-reviewed variants retain historical parent-derived headers and their existing shared parent learnset pointers. Reviewed variants are explicitly validated against their own approved registry entries.

## Updating and validation

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain the same layout; older 151/172/176-species saves require a fresh start. Known moves are not automatically deleted; party stat changes apply on normal recalculation. Unique Bulbasaur/Charmander already evolved into ordinary forms do not turn back.

The tuning registry contains 166 reviewed entries: original 151, eleven added species and four unique variants. Existing tests validate exact stats/starts/learnsets, actual generated moves/PP, original/extra machine masks, independent evolution pointers and remaining historical variants. Dedicated Heal Bell/Charm tests cover both actors, active status/stat penalties/Toxic counters, living and fainted reserves, unchanged HP/volatile states, full-party failure, PP, wild-roster isolation, AI eligibility, accuracy boundaries, Substitute, Mist, caps and saved move IDs. All prior species, sprite, encounter, save, move, crit and freeze regressions remain included. Packaging applies both BPS patches to verified originals and compares byte for byte with the builds.

The earlier-Pokémon/new-move distribution review remains saved for last, with Heal Bell and Charm added to its pending list.
