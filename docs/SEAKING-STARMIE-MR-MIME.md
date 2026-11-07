# Seaking, Starmie and Mr. Mime redesigns

Cumulative Red/Blue patches retain all earlier sprites, species, types, move effects and family reviews. Counts remain 183 species and 228 move records. No new move, effect, animation, item or save field is introduced.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special.

### Goldeen

Stats: 45 / 67 / 60 / 63 / 50.

Starts: PECK, TAIL_WHIP.

Level-up: 8: SUPERSONIC, 15: HORN_ATTACK, 22: AQUA_JET, 29: WATERFALL, 42: AGILITY.

### Seaking

Stats: 80 / 102 / 65 / 78 / 80.

Starts: PECK, TAIL_WHIP, SUPERSONIC.

Level-up: 8: SUPERSONIC, 15: HORN_ATTACK, 22: AQUA_JET, 29: WATERFALL, 35: PIERCE, 42: AGILITY, 49: MEGAHORN, 56: HORN_DRILL.

### Staryu

Stats: 30 / 45 / 55 / 85 / 70.

Starts: TACKLE, HARDEN.

Level-up: 7: WATER_GUN, 14: SWIFT, 21: RECOVER, 28: BUBBLEBEAM, 35: LIGHT_SCREEN, 49: HYDRO_PUMP.

### Starmie

Stats: 60 / 75 / 85 / 115 / 100.

Starts: TACKLE, HARDEN, WATER_GUN.

Level-up: 7: WATER_GUN, 14: SWIFT, 21: RECOVER, 28: BUBBLEBEAM, 35: LIGHT_SCREEN, 42: PSYCHIC_M, 49: HYDRO_PUMP.

### MrMime

Stats: 50 / 45 / 65 / 90 / 100.

Starts: CONFUSION, BARRIER.

Level-up: 9: MIMIC, 16: LIGHT_SCREEN, 23: PSYBEAM, 30: SUBSTITUTE, 37: MIND_BREAK, 44: PSYCH_UP, 51: PSYCHIC_M.

## Roles and machine changes

Goldeen/Seaking are horn fighters with Waterfall preserving their upstream-swimming identity. Goldeen stays unchanged; Seaking gains Attack 92→102 and Speed 68→78. Evolution remains level 33. Aqua Jet and Waterfall remain special; horn moves use Attack. Pierce ignores positive target Defense stages; Waterfall ignores positive target Special stages. Remove Fury Attack, Flail and Snipe Shot leveling. Add Facade TM52 and Agility TM63 to both; keep Surf, Brine, Ice Beam, Blizzard, Swift and Rest. Remove Hyper Beam from Seaking. Scald, Earthquake and Dig stay unavailable. No Attack setup or immediate recovery is added.

Staryu/Starmie keep stats and Water Stone evolution, with a complete evolved learnset. Recover preserves regeneration; Bubblebeam provides guaranteed Speed reduction after an eligible hit. Swift is physical and serves as early star-themed utility. Starmie learns Psychic naturally at 42. Remove Minimize leveling. Keep Surf, Ice Beam, Blizzard, Thunderbolt, Psychic, Thunder Wave, Reflect, Rest, Swift, Mimic and Substitute machine permissions. Remove Thunder from both and Hyper Beam from Starmie; remove Brine TM53 from both. Scald stays unavailable. No Special setup or extra recovery is added.

Mr. Mime gains HP 40→50; other stats stay unchanged. Barrier, Mimic, Light Screen, Substitute, Mind Break and Psych Up establish its barrier/trickster identity. Psych Up replaces its own stages and can erase Barrier boosts or copy negative stages; Mind Break removes positive target Special stages after damage. Remove Double Slap, Psyshock and Meditate leveling. Keep Psychic, Thunderbolt, Thunder Wave, Reflect, Mimic, Substitute, Counter, Rest, Body Slam and Seismic Toss permissions. Keep Metronome TM35: contrary to the planning audit's wording, inspection confirms it was already available before this patch. Remove Thunder, Solar Beam, Hyper Beam, Mega Punch, Mega Kick and Submission. No Recover or Amnesia is added.

Other existing machine permissions, shops and prices remain unchanged. Custom variants retain individual stats, starts and machine masks; shared parent learnset pointers follow revised parent leveling.

## Updating and verification

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain the same layout; older 151/172/176-species saves require a fresh start. Already learned moves are not automatically deleted. Party stat changes take effect on normal recalculation, such as leveling up.

The tuning registry contains 123 reviewed entries: all 122 original species through Mr. Mime, plus Crobat. Existing tests check exact stats/starts/learnsets, actual generated moves/PP, original/extra TM permissions and historical variants. The full species, sprite, encounter, save, move, crit and freeze regression suites remain included in both versions. Packaging applies each BPS to a verified original and compares byte for byte with the build.
