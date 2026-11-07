# Scyther, Jynx, Electabuzz and Magmar redesigns

Cumulative Red/Blue patches retain all earlier sprites, species, types, move effects and family reviews. Counts remain 183 species and 228 move records. Only Electabuzz's Attack changes (83→95); other reviewed stats remain unchanged. No moves, effects, animation assets, items or save fields are added.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special.

### Scyther

Stats: 70 / 110 / 80 / 105 / 55.

Starts: QUICK_ATTACK, LEER.

Level-up: 9: LUNGE, 17: WING_ATTACK, 25: FOCUS_ENERGY, 33: SLASH, 41: X_SCISSOR, 49: SWORDS_DANCE.

### Jynx

Stats: 65 / 50 / 35 / 95 / 95.

Starts: POUND, LOVELY_KISS.

Level-up: 9: CONFUSION, 17: ICY_WIND, 25: ICE_PUNCH, 33: PSYBEAM, 41: FROST_BREATH, 49: PSYCHIC_M, 57: BLIZZARD.

### Electabuzz

Stats: 65 / 95 / 57 / 105 / 85.

Starts: QUICK_ATTACK, LEER.

Level-up: 7: THUNDERSHOCK, 15: LOW_KICK, 23: THUNDERPUNCH, 31: SCREECH, 39: BRICK_BREAK, 47: THUNDERCLAP, 55: THUNDER.

### Magmar

Stats: 65 / 95 / 57 / 93 / 85.

Starts: EMBER, LEER.

Level-up: 9: SMOKESCREEN, 17: SMOG, 25: FIRE_PUNCH, 33: MEGA_PUNCH, 41: CAUTERIZE, 49: FLAMETHROWER, 57: FIRE_BLAST.

## Roles and machine changes

Scyther is a fast blade specialist. Lunge supplies early Bug damage and Attack reduction without priority; Wing Attack arrives much earlier. Slash/X-Scissor criticals ignore Swords Dance and Leer stages, making critical offense and boosted ordinary attacks alternative approaches. Remove Double Team, Aerial Ace, Ambush and Agility leveling; keep Aerial Ace and Double Team machines. Add Facade TM52, remove Roost TM51 and Hyper Beam TM15. Keep Swords Dance, Aerial Ace, Double Team, Swift, Skull Bash, Cut and Rest. No Fighting or Rock coverage is added. Bug/Flying and its double Rock weakness remain.

Jynx stays a fragile Ice/Psychic performer. Lovely Kiss is 75 accuracy/10 PP. Icy Wind enables Frost Breath's guaranteed critical against negative target Speed stages; paralysis alone does not qualify. Ice Punch remains special. Remove Lick, Double Slap, Ice Shard, Psyshock, Ice Armor, Mind Break, Body Slam, Thrash and Flash Freeze leveling. Keep Ice Beam, Blizzard, Psychic, Psywave, Reflect, Mimic, Metronome, Substitute, Dream Eater, Rest, Counter and Double Team machines. Remove Mega Punch, Mega Kick, Submission, Seismic Toss, Body Slam, Hyper Beam, Water Gun and Bubblebeam. No immediate recovery, Special setup or Defense buff is added.

Electabuzz retains Electric/Fighting and gains Attack 83→95. Low Kick, Screech and Brick Break support physical Fighting attacks; Thunder Punch is special. Thunderclap offers priority/flinch with 5 PP, and Thunder retains its major-status accuracy bypass. Remove Charge, Shock Wave and Light Screen leveling. Add Facade TM52. Keep Thunderbolt, Thunder, Thunder Wave, Counter, Seismic Toss, Body Slam, Strength, Rest, Mega Punch, Mega Kick, Submission, Reflect, Mimic and Double Team. Remove Psychic, Psywave, Metronome, Dream Eater and Hyper Beam. Bulk Up stays unavailable; low physical Defense remains a weakness.

Magmar uses smoke, close-range attacks and Cauterize. Smog and Mega Punch use Attack; Fire Punch and other Fire attacks use Special. Cauterize heals one-quarter HP and clears major status; Smokescreen can buy recovery turns but does not improve actual defenses. Remove Flame Charge, Will-O-Wisp, Incinerate and Confuse Ray leveling. Add Facade TM52; remove Will-O-Wisp TM58, Psychic, Psywave, Metronome, Dream Eater and Hyper Beam. Keep Mega Punch, Mega Kick, Submission, Counter, Seismic Toss, Body Slam, Strength, Fire Blast, Rest and Rage. Bulk Up remains unavailable. Poison from Smog can prevent burning that target; no stronger healing or stat buff is added.

All four remain single-stage species. Other machine permissions, shops and prices are unchanged. Custom variants retain their own stats, starts and machine masks; shared parent learnset pointers follow revised parent leveling.

## Updating and verification

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain the same layout; older 151/172/176-species saves require a fresh start. Already known moves are not automatically deleted. Electabuzz's party Attack updates on normal recalculation, such as leveling up.

The tuning registry contains 127 reviewed entries: all 126 original species through Magmar, plus Crobat. Existing tests validate exact stats/starts/learnsets, actual generated moves/PP, original/extra machine permissions and historical variants. The full species, sprite, encounter, save, move, crit and freeze regression suites remain included in both versions. Packaging applies each BPS to a verified original and compares byte for byte with the build.
