# Aerodactyl, Snorlax and legendary bird redesigns

Cumulative Red/Blue patches retain all earlier sprites, species, types, move effects and family reviews. Counts remain 183 species, now with 229 moves. All five reviewed species keep their stats. No item, animation asset or save field is added.

## Crunch

New move 229: Normal, physical, 80 power, 100 accuracy, 15 PP, Bite animation. After an eligible hit, 51/256 (about 20%) chance to lower target Defense one stage. The drop respects misses, immunity, Substitute (including a breaking hit), Mist, KO and stage caps. Existing move IDs are unchanged. Aerodactyl and Snorlax learn it at 41.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special.

### Aerodactyl

Stats: 80 / 105 / 65 / 130 / 60.

Starts: WING_ATTACK, BITE.

Level-up: 9: SUPERSONIC, 17: ROCK_TOMB, 25: TAKE_DOWN, 33: ROCK_SLIDE, 41: CRUNCH, 49: STONE_EDGE, 57: SKY_ATTACK.

### Snorlax

Stats: 160 / 110 / 65 / 30 / 65.

Starts: HEADBUTT, GROWL.

Level-up: 9: DEFENSE_CURL, 17: REST, 25: BODY_SLAM, 33: AMNESIA, 41: CRUNCH, 49: DOUBLE_EDGE.

### Articuno

Stats: 90 / 85 / 100 / 85 / 125.

Starts: PECK, ICE_BEAM.

Level-up: 25: ICY_WIND, 35: ICE_ARMOR, 45: GALE_WIND, 50: ROOST, 55: BLIZZARD, 65: FLASH_FREEZE.

### Zapdos

Stats: 90 / 90 / 85 / 100 / 125.

Starts: THUNDERSHOCK, DRILL_PECK.

Level-up: 25: THUNDER_WAVE, 35: LIGHT_SCREEN, 45: THUNDERBOLT, 50: ROOST, 55: THUNDER, 65: THUNDERCLAP.

### Moltres

Stats: 90 / 100 / 90 / 90 / 125.

Starts: PECK, FIRE_SPIN.

Level-up: 25: WING_ATTACK, 35: INCINERATE, 45: FLAMETHROWER, 50: ROOST, 55: FIRE_BLAST, 65: SKY_ATTACK.

## Roles and machine changes

Aerodactyl is a fast prehistoric predator. Bite and Wing Attack replace Wing Attack/Agility starting moves. Remove Rock Polish, Roost, Aerial Ace, Gale Wind and Hyper Beam leveling; natural Speed is sufficient. Rock Slide makes use of flinching, Crunch supplies a reliable jaw attack, and Sky Attack is a physical aerial finisher with a charge turn. Keep Rock Tomb, Aerial Ace, Fly, Sky Attack, Double Team, Reflect, Swift and Rest machines. Add Rock Slide TM48 and Facade TM52. Remove Roost TM51, Hyper Beam, Twister, Whirlwind, Dragon Rage and Fire Blast. No Earthquake, Fighting coverage or extra setup is added.

Snorlax retains its giant physical-attacker identity with sleep-based recovery. Headbutt/Growl replaces the old Headbutt/Amnesia/Rest starting arrangement; Rest and Amnesia are now learned at the listed levels. Remove Stockpile, Harden, Facade and Hyper Beam leveling. Crunch trades Body Slam's paralysis opportunity for a Defense-drop chance. Keep Body Slam, Double-Edge, Facade, Rest, Strength, Surf, Earthquake, Counter, Seismic Toss, Mega Punch, Mega Kick, Submission, Ice Beam and Reflect machines. Remove Thunderbolt, Thunder, Blizzard, Fire Blast, Psychic, Solar Beam, Water Gun, Bubblebeam, Fissure, Self-Destruct, Hyper Beam, Bide, Metronome and Dream Eater. Amnesia still supports Ice Beam and special durability, but broad special coverage is restricted.

Articuno retains Ice/Flying and its double Rock weakness. The final audit replaces the proposed Mist slot with Ice Armor at 35 to compensate for its defensive typing. Roost, Ice Armor, slowing and risky Flash Freeze create its control identity without Special setup. Remove Ice Shard, Icicle Spear, Frost Breath and Agility leveling. Keep Ice Beam, Blizzard, Roost, Reflect, Double Team, Swift, Rest, Fly, Aerial Ace and Sky Attack machines. Remove Water Gun, Bubblebeam, Hyper Beam, Twister and Whirlwind. Freeze retains the implemented 20% thaw chance per turn. Ice Armor/Roost is intentionally strong; no stats or type-chart changes are introduced.

Zapdos keeps Electric/Flying and its naturally strong typing. Drill Peck uses Attack; Electric attacks use Special. Thunder Wave enables Thunder's status accuracy bypass. Thunderbolt is learned naturally; Thunderclap provides late priority/flinch pressure with 5 PP. Remove Charge, Shock Wave, Gale Wind and Agility leveling. Keep Thunderbolt, Thunder, Thunder Wave, Roost, Reflect, Double Team, Swift, Rest, Fly, Aerial Ace and Sky Attack machines; remove Hyper Beam, Twister and Whirlwind. Zap Cannon remains associated with Magneton, and no new setup is added.

Moltres focuses on lingering flames and powerful attacks on both sides. Wing Attack and Sky Attack use Attack; Fire attacks use Special. Incinerate rewards burning, with Will-O-Wisp an optional TM rather than a natural level move. Roost replaces redundant Cauterize recovery. Remove Will-O-Wisp, Gale Wind, Leer, Cauterize and Agility leveling. Keep Fire Blast, Will-O-Wisp, Roost, Reflect, Double Team, Swift, Rest, Fly, Aerial Ace and Sky Attack machines; remove Hyper Beam, Twister and Whirlwind. No Ground coverage, Special boosts or extra healing is added.

All five remain single-stage species. Other machine permissions, shops and prices remain unchanged. Custom variants retain individual headers and machine masks; shared parent learnset pointers follow revised parent lists.

## Deferred final review

The user requested checking earlier Pokémon for moves added during this redesign process, but explicitly saved that task for last. It is recorded in FINAL-MOVE-DISTRIBUTION-REVIEW.md and is not executed in this patch. Update that list with any further moves before the final distribution review.

## Updating and verification

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain their layout; older 151/172/176-species saves require a fresh start. Known moves are not automatically removed.

The tuning registry contains 147 entries: all 146 original species through Moltres, plus Crobat. Existing tests check exact stats/starts/learnsets, actual generated moves/PP, original/extra machine masks and historical variants. Crunch tests cover both actors, all chance boundaries, actual damage/PP, caps, immunity, miss, Substitute, Mist, KO, Fly and SRAM retention. All species, sprite, encounter, save, move, crit and freeze regressions remain included. Packaging applies both BPS patches to verified originals and compares byte for byte with each build.
