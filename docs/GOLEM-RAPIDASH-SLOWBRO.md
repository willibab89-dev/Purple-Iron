# Golem, Rapidash and Slowbro family redesigns

These cumulative Red/Blue patches retain all previous sprites, species, type changes, move effects and individual reviews. Counts remain 183 species and 222 moves. All seven reviewed species retain their existing stats. No new moves, items, effects, animations or save fields are introduced.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special.

### Geodude

Stats: 40 / 80 / 100 / 20 / 30.

Starts: TACKLE, DEFENSE_CURL.

Level-up: 8: ROCK_THROW, 15: ROCK_TOMB, 22: SELFDESTRUCT, 29: ROCK_POLISH, 36: STONE_PRESS, 43: EARTHQUAKE.

### Graveler

Stats: 55 / 95 / 115 / 35 / 45.

Starts: TACKLE, DEFENSE_CURL.

Level-up: 8: ROCK_THROW, 15: ROCK_TOMB, 22: SELFDESTRUCT, 29: ROCK_POLISH, 36: STONE_PRESS, 43: EARTHQUAKE.

### Golem

Stats: 80 / 110 / 130 / 45 / 55.

Starts: TACKLE, DEFENSE_CURL.

Level-up: 8: ROCK_THROW, 15: ROCK_TOMB, 22: SELFDESTRUCT, 29: ROCK_POLISH, 36: STONE_PRESS, 43: EARTHQUAKE, 49: STONE_EDGE, 55: EXPLOSION.

### Ponyta

Stats: 50 / 85 / 55 / 90 / 65.

Starts: EMBER, TAIL_WHIP.

Level-up: 8: STOMP, 15: DOUBLE_KICK, 22: FLAME_CHARGE, 29: FIRE_SPIN, 36: AGILITY, 44: FLAMETHROWER.

### Rapidash

Stats: 65 / 100 / 70 / 105 / 80.

Starts: EMBER, TAIL_WHIP, STOMP.

Level-up: 8: STOMP, 15: DOUBLE_KICK, 22: FLAME_CHARGE, 29: FIRE_SPIN, 36: AGILITY, 41: HORN_ATTACK, 44: FLAMETHROWER, 50: PIERCE, 57: HORN_DRILL.

### Slowpoke

Stats: 90 / 65 / 65 / 15 / 40.

Starts: CONFUSION, GROWL.

Level-up: 8: WATER_GUN, 15: DISABLE, 22: HEADBUTT, 29: AMNESIA, 36: REST, 44: PSYCHIC_M.

### Slowbro

Stats: 95 / 75 / 110 / 30 / 80.

Starts: CONFUSION, GROWL, WATER_GUN.

Level-up: 8: WATER_GUN, 15: DISABLE, 22: HEADBUTT, 29: AMNESIA, 36: REST, 38: WITHDRAW, 44: PSYCHIC_M, 51: SURF.

## Roles and machine changes

Geodude's family turns Defense into Rock damage or uses Rock Polish for conventional offense. Stone Press uses Defense stages and ignores Attack changes and burn's Attack penalty; critical hits use unmodified Defense. Defense Curl replaces redundant Harden leveling. Golem gains Stone Edge and Explosion after evolution. Restore Double-Edge TM10 to all three, remove Fire Blast from all three and Hyper Beam from Golem. Keep Earthquake, Dig, Fissure, Rock Slide, Rock Tomb, Strength, Body Slam, Fighting coverage and Rest. Fissure remains the redesigned damaging Attack-debuff move rather than an OHKO.

Ponyta's family uses fast hoof attacks, residual Fire damage and Rapidash's horn. Remove Growl, Take Down, Will-O-Wisp and Incinerate leveling. Add Facade TM52 and Agility TM63 to both, remove Will-O-Wisp TM58 from both and Hyper Beam from Rapidash. Keep Double Team, Body Slam, Reflect, Swift, Fire Blast and Rest; Earthquake and Dig remain unavailable. Rapidash learns Horn Attack at 41, Pierce at 50 and Horn Drill at 57. Pierce is Fighting-type, 70 power, 100 accuracy, 15 PP, ignores positive target Defense stages and uses Horn Attack's animation. The approved replacement is Pierce, not Jump Kick (displayed as Flying Punch) or High Jump Kick. Horn Drill is the existing 120-power, 40-accuracy Normal attack with target Defense −2, not an instant knockout.

Slowpoke's family slowly builds durability with Amnesia, Rest and Slowbro's Withdraw. Remove Scald and Psyshock leveling; Scald remains unavailable through TM. Slowbro learns Surf naturally at 51, while earlier HM access remains intact. Remove Earthquake, Fissure, Dig and Fire Blast from both; remove Hyper Beam, Mega Punch, Mega Kick and Submission from Slowbro. Keep Surf, Brine, Ice Beam, Blizzard, Psychic, Reflect, Thunder Wave, Dream Eater and Rest; keep Counter and Seismic Toss for Slowbro. Amnesia clears negative stages, preserves positive stages and raises Special one stage; Withdraw raises Defense and accuracy. No immediate recovery is added.

Evolution remains Geodude 25 → Graveler 45 → Golem (trade also available), Ponyta 40 → Rapidash and Slowpoke 37 → Slowbro. Each final form keeps a complete level-up list. Custom variants retain individual stats, starting moves and TM masks; shared parent learnset pointers follow revised parent leveling. Shop inventory and prices are unchanged.

## Updating and verification

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain the same layout; older 151/172/176-species saves require a fresh start. Previously learned moves are not automatically removed.

The tuning registry now contains 83 entries: 82 originals plus Crobat. Existing tests check exact stats, starting moves, complete learnsets, actual generated moves/PP, original/extra machine permissions and historical variants in both versions. The full species, sprite, encounter, save, move, crit and freeze regression suites remain included. Packaging applies both BPS files to verified originals and confirms byte-for-byte reproduction of the builds.
