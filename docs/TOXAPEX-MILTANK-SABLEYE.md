# Toxapex, Miltank and Sableye redesigns

Cumulative Red/Blue patches retain all earlier sprites, species, types, move effects and family reviews. Counts remain 183 species, now with 232 move records. No item, animation asset or save field is added. Both the reviewed-species registry and added-species metadata are synchronized.

## New moves

- Milk Drink (231): Normal status, 10 PP, restores half maximum HP using Recover's effect/animation. Fails at full HP, preserves major status and has no party-healing field function.
- Snarl (232): Normal physical, 40 power, 95 accuracy, 15 PP. Lowers target Special one stage after an eligible hit, using Growl's animation. Respects miss, Ghost immunity, Substitute including breaking hits, Mist, KO and stage caps. Special reduction weakens both special offense and durability in this game.

Old move IDs are unchanged. Both additions join Metronome's eligible pool and the deferred final distribution review; they are not redistributed to earlier species in this patch.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special.

### Mareanie

Stats: 50 / 53 / 62 / 45 / 48.

Starts: POISON_STING, PECK.

Level-up: 8: WATER_GUN, 15: BITE, 22: TOXIC, 29: VENOSHOCK, 36: SCALD, 46: BRINE.

### Toxapex

Stats: 50 / 63 / 152 / 35 / 100.

Starts: POISON_STING, PECK, WATER_GUN.

Level-up: 8: WATER_GUN, 15: BITE, 22: TOXIC, 29: VENOSHOCK, 36: SCALD, 39: RECOVER, 46: BRINE, 53: HAZE.

### Miltank

Stats: 95 / 80 / 105 / 100 / 55.

Starts: TACKLE, GROWL.

Level-up: 9: DEFENSE_CURL, 17: STOMP, 25: BODY_SLAM, 33: MILK_DRINK, 41: FACADE, 49: DOUBLE_EDGE.

### Sableye

Stats: 50 / 85 / 125 / 20 / 85.

Starts: SCRATCH, LEER, SNARL.

Level-up: 8: NIGHT_SHADE, 16: CONFUSE_RAY, 24: SHADOW_LEECH, 32: CRUNCH, 40: RECOVER, 48: PUNISHMENT.

## Roles and compatibility

Mareanie/Toxapex keep their stats and Poison/Water typing. Evolution remains 38, followed by Toxapex Recover at 39. The final approved order is Toxic 22, Venoshock 29, Scald 36; Poison Fang is removed. Venoshock is physical and doubles against poison, while Scald is special and can burn. Poison and burn are alternative strategies. Haze clears stages and cures both major statuses, undoing poison/burn setup. Remove Pin Missile, Poison Tail, Stockpile, Acid Armor and Hydro Pump leveling. Add Scald TM59 to both. Keep Toxic, Venoshock, Brine, Surf, Substitute and Rest; remove Bide. No Ice coverage, Special setup or additional recovery is added.

Miltank keeps 95/80/105/100/55 stats and Normal typing. Stomp benefits from Speed; Body Slam adds paralysis, Milk Drink provides its defining healing, and Double-Edge trades HP for power. Remove Bide, Bulk Up, Recover and Earthquake leveling. Keep Body Slam, Double-Edge, Facade, Strength, Rest, Mega Punch, Mega Kick and Double Team machines. Remove Earthquake, Rock Slide, Rock Tomb TM57, Hyper Beam, Bulk Up TM56 and Bide. No special coverage or Attack setup is added.

Sableye retains its name and pure Ghost typing, with the final Mega-inspired gem-shield stats: 50 HP / 85 Attack / 125 Defense / 20 Speed / 85 Special. Snarl replaces Astonish in starting moves. Night Shade, Confuse Ray, physical Shadow Leech, Normal Crunch, Recover and Punishment form its natural progression. Remove Lick, Curse, Slash and Psych Up leveling; Curse remains a TM. The final audit removes the proposed Reflect slot entirely: no Reflect leveling or TM compatibility is added. Keep Will-O-Wisp, Curse, Mimic, Substitute, Double Team, Facade, Rest, Dig, Strength and Swift machines. Remove Mega Punch, Rock Slide, Rock Tomb TM57 and Aerial Ace TM55. No Mega Evolution, ability, automatic priority, setup or extra recovery is added. Low HP and Speed balance strong defenses, burn support and Recover; Snarl cannot affect Ghost targets.

Other machine permissions, encounters, shops and prices remain unchanged. Existing unique variants retain their headers and masks. The final earlier-species/new-move distribution review remains deferred until remaining species work is finished; Milk Drink and Snarl are recorded in its pending list.

## Updating and verification

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain their layout; older 151/172/176-species saves require a fresh start. Known moves are not automatically removed. Existing Sableye party stats update on normal recalculation, such as leveling up.

The tuning registry contains 156 reviewed entries: original 151, Crobat, Mareanie, Toxapex, Miltank and Sableye. Existing tests verify exact stats/starts/learnsets, actual generated moves/PP, original/extra TM masks and historical variants. Milk Drink tests cover both actors, heal rounding/caps/full HP, preserved status, animation, generated PP and SRAM/PP-Up bits. Snarl tests cover guaranteed drops, actual damage/PP, caps, miss, Ghost immunity, Substitute, Mist, KO, Fly and saves. All prior species, sprite, encounter, save, move, crit and freeze regressions remain included. Packaging applies both BPS files to verified originals and compares byte for byte with the builds.
