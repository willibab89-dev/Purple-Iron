# Porygon, Omastar and Kabutops redesigns

Cumulative Red/Blue patches retain all earlier sprites, species, types, move effects and family reviews. Counts remain 183 species and 228 move records. No moves, effects, animation assets, items or save fields are introduced.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special.

### Porygon

Stats: 75 / 75 / 70 / 40 / 85.

Starts: TACKLE, SHARPEN, CONVERSION.

Level-up: 9: PSYBEAM, 17: RECOVER, 25: TRI_ATTACK, 33: AGILITY, 41: PSYCH_UP, 49: HYPER_BEAM.

### Omanyte

Stats: 35 / 40 / 100 / 35 / 90.

Starts: WATER_GUN, WITHDRAW.

Level-up: 9: CONSTRICT, 17: SUPERSONIC, 25: ROCK_TOMB, 33: BRINE, 49: HYDRO_PUMP.

### Omastar

Stats: 70 / 60 / 125 / 55 / 115.

Starts: WATER_GUN, WITHDRAW.

Level-up: 9: CONSTRICT, 17: SUPERSONIC, 25: ROCK_TOMB, 33: BRINE, 41: STONE_PRESS, 49: HYDRO_PUMP.

### Kabuto

Stats: 30 / 80 / 90 / 55 / 45.

Starts: SCRATCH, HARDEN.

Level-up: 9: ABSORB, 17: ROCK_TOMB, 25: AQUA_JET, 33: SHELL_BREAK.

### Kabutops

Stats: 60 / 115 / 105 / 80 / 70.

Starts: SCRATCH, HARDEN, ABSORB.

Level-up: 9: ABSORB, 17: ROCK_TOMB, 25: AQUA_JET, 33: SHELL_BREAK, 41: SLASH, 49: X_SCISSOR, 57: STONE_EDGE.

## Roles and machine changes

Porygon gains HP 65→75, Attack 60→75 and Special 75→85; Defense 70 and Speed 40 stay unchanged. Its reconfiguration identity uses Sharpen, Conversion, Recover, Tri Attack, Agility and Psych Up, with Hyper Beam as a thematic late attack. Sharpen raises Attack/accuracy; Conversion copies the opponent's typing and can remove Normal STAB; Psych Up replaces its stages and can erase Sharpen/Agility boosts or copy negative stages. Keep Thunderbolt, Thunder, Ice Beam, Blizzard, Psychic, Thunder Wave, Reflect, Mimic, Substitute, Swift, Rest and Hyper Beam machines. Add Facade TM52 and Agility TM63; remove Dream Eater. No Amnesia or defensive setup is added. Porygon remains a single-stage species.

Omanyte/Omastar retain their stats, Rock/Water typing and level-40 evolution. Tentacle disruption, Water special offense and Withdraw-supported Stone Press define their role. Constrict is the existing 25-power special Grass attack with Speed reduction; Supersonic confuses; Rock Tomb supplies physical Rock damage and Speed control. Stone Press arrives at 41 and uses Defense rather than Attack. Withdraw improves Defense/accuracy, but critical Stone Press ignores Defense boosts. Remove Horn Attack, Leer, Rock Polish, Spike Cannon and Stone Edge leveling. Keep Surf, Brine, Rock Tomb, Ice Beam, Blizzard, Reflect, Body Slam and Rest machines. Remove Scald TM59 from both, and Hyper Beam, Horn Drill and Submission from Omastar. Keep Omastar's Seismic Toss option. No Shell Smash or immediate healing is added.

Kabuto/Kabutops retain their stats, Rock/Water typing and level-40 evolution. Absorb is an early draining tool, Aqua Jet a special priority finisher, and Shell Break physical Bug damage with target Defense reduction. Kabutops gains Slash immediately after evolution, then X-Scissor and Stone Edge as later critical options. Remove Rock Polish, Stone Press, Leer and Hydro Pump leveling. Keep Surf, Brine, Ice Beam, Blizzard, Body Slam, Reflect, Rest and Rock Tomb machines. Keep Swords Dance, Aerial Ace and Seismic Toss for Kabutops; remove Hyper Beam, Mega Kick, Submission and Twister. Earthquake/Dig remain unavailable. Critical hits ignore Swords Dance boosts and Shell Break Defense drops, so they are alternative offensive routes. Rock Tomb remains Kabuto's only natural Rock attack; Kabutops' stronger Stone Edge comes late.

Other machine permissions, shops and prices remain unchanged. Custom variants retain individual stats, starting moves and machine masks; shared parent learnset pointers follow revised parent lists. Variant labels are left untouched when editing original-species learnsets.

## Updating and validation

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain the same layout; older 151/172/176-species saves require a fresh start. Already known moves are not automatically deleted. Existing party stat changes apply on normal recalculation, such as leveling up.

The tuning registry contains 142 entries: all 141 original species through Kabutops, plus Crobat. Existing tests validate exact stats/starts/learnsets, real generated moves/PP, original/extra machine permissions and historical variants. All species, sprite, encounter, save, move, crit and freeze regressions remain included in both versions. Packaging applies both BPS files to verified originals and compares byte for byte with the builds.
