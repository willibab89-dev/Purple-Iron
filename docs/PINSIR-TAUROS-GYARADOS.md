# Pinsir, Tauros and Gyarados redesigns

Cumulative Red/Blue patches retain all earlier sprites, species, types, move effects and family reviews. Counts remain 183 species and 228 moves. All four reviewed species retain their stats. No moves, effects, animation assets, items or save fields are added.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special.

### Pinsir

Stats: 65 / 125 / 100 / 85 / 55.

Starts: VICEGRIP, HARDEN.

Level-up: 9: BIND, 17: SEISMIC_TOSS, 25: SHELL_BREAK, 33: SUBMISSION, 41: BULK_UP, 49: GUILLOTINE.

### Tauros

Stats: 75 / 100 / 95 / 110 / 70.

Starts: TACKLE, TAIL_WHIP.

Level-up: 9: STOMP, 17: HORN_ATTACK, 25: RAGE, 33: TAKE_DOWN, 41: THRASH, 49: DOUBLE_EDGE.

### Magikarp

Stats: 20 / 10 / 55 / 80 / 20.

Starts: SPLASH.

Level-up: 15: TACKLE, 19: FLAIL.

### Gyarados

Stats: 95 / 125 / 79 / 81 / 100.

Starts: BITE, LEER.

Level-up: 21: BITE, 27: DRAGON_RAGE, 33: THRASH, 41: HYDRO_PUMP, 49: DRAGON_DANCE, 57: HYPER_BEAM.

## Roles and machine changes

Pinsir is a crushing grappler rather than Scyther's fast blade specialist. Vice Grip is 75-power Bug STAB; Bind lowers Speed; Shell Break damages and lowers Defense; Submission supplies strong Fighting coverage with recoil. Bulk Up is its setup identity. Remove Lunge, X-Scissor, Focus Energy, Ambush, Pierce, Megahorn, Slash and Swords Dance leveling. Remove Swords Dance and Hyper Beam machines; add Facade TM52. Keep Bulk Up, Body Slam, Submission, Seismic Toss, Strength, Cut, Rest and Rock Tomb. Earthquake, Dig and Rock Slide remain unavailable.

Tauros is a fast reckless charging attacker. Stomp, Horn Attack, Rage, Take Down, Thrash and Double-Edge provide different risks despite sharing Normal typing. Remove Leer and Facade leveling; Facade remains a TM. Take Down doubles power strictly below half target HP and retains recoil; Thrash locks and ends in confusion; Rage's boosts persist after its lock until switching or stage reset. Keep Body Slam, Double-Edge, Facade, Strength, Double Team, Rest and Earthquake. Remove Ice Beam, Blizzard, Thunderbolt, Thunder, Fire Blast, Fissure, Horn Drill and Hyper Beam machines. No additional setup, Speed boosts or immediate recovery is added.

Magikarp retains Splash, Tackle at 15 and moves Flail forward to 19, immediately before evolution at 20. Gyarados retains Water/Flying and removes Dragon Rage and Hydro Pump from its starting slots, keeping Bite/Leer as the new two-move start. Its full revised natural progression includes Bite at 21 for normally evolved Magikarp, special Dragon Rage, physical Thrash, Hydro Pump, Dragon Dance and Hyper Beam. Remove Flail leveling from Gyarados; Flail already learned as Magikarp is retained through evolution. Dragon Dance strengthens physical attacks and Speed, not special Water/Dragon damage. Keep Body Slam, Double-Edge, Hyper Beam, Surf, Strength, Reflect, Rest, Brine, Thunder and Blizzard machine permissions. Remove Thunderbolt, Ice Beam and Fire Blast. Scald, Earthquake and immediate recovery remain unavailable.

Existing Gyarados do not automatically forget previously known Hydro Pump or other removed moves. Newly generated low-level Gyarados no longer receive Hydro Pump from starting slots. Pinsir/Tauros remain single-stage species, and Magikarp's evolution level stays unchanged. Other machine permissions, shops and prices remain unchanged. Custom variants retain individual headers and machine masks; shared parent learnset pointers follow revised parent leveling.

## Updating and verification

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain the same layout; older 151/172/176-species saves require a fresh start. Already learned moves are not automatically removed.

The tuning registry contains 131 entries: all 130 original species through Gyarados, plus Crobat. Existing tests verify exact stats/starts/learnsets, actual generated moves/PP, original/extra machine permissions and historical variants. Full species, sprite, encounter, save, move, crit and freeze regression suites remain included in both versions. Packaging applies both BPS files to verified originals and compares byte for byte with the builds.
