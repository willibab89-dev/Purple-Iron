# Lickitung, Weezing and Rhydon family redesigns

Cumulative Red/Blue patches retain every earlier sprite, species, type change, move effect and family review. Counts remain 183 species and 227 moves. No moves, items, animations, battle handlers or save fields are added.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special.

### Lickitung

Stats: 100 / 75 / 75 / 30 / 70.

Starts: LICK, SUPERSONIC.

Level-up: 7: WRAP, 15: DISABLE, 23: STOCKPILE, 31: TONGUE_LASH, 39: BODY_SLAM, 47: REST.

### Koffing

Stats: 40 / 65 / 95 / 35 / 60.

Starts: TACKLE, SMOG.

Level-up: 7: SMOKESCREEN, 14: SLUDGE, 21: POLLUTION, 28: POISON_GAS, 42: HAZE.

### Weezing

Stats: 65 / 90 / 120 / 60 / 85.

Starts: TACKLE, SMOG.

Level-up: 7: SMOKESCREEN, 14: SLUDGE, 21: POLLUTION, 28: POISON_GAS, 36: INCINERATE, 42: HAZE, 49: EXPLOSION.

### Rhyhorn

Stats: 80 / 85 / 95 / 25 / 30.

Starts: HORN_ATTACK, TAIL_WHIP.

Level-up: 9: STOMP, 17: ROCK_TOMB, 25: TAKE_DOWN, 33: PIERCE, 41: EARTHQUAKE.

### Rhydon

Stats: 105 / 130 / 120 / 40 / 45.

Starts: HORN_ATTACK, TAIL_WHIP, STOMP.

Level-up: 9: STOMP, 17: ROCK_TOMB, 25: TAKE_DOWN, 33: PIERCE, 41: EARTHQUAKE, 49: MEGAHORN, 57: HORN_DRILL.

## Roles and machine changes

Lickitung gains HP 90→100, Attack 55→75 and Special 60→70; Defense and Speed stay unchanged. Lick, Wrap, Disable, Stockpile and Tongue Lash define its disruptive generalist role. Body Slam at 39 is the final approved replacement for the proposed Slam. Rest provides sleep-based recovery. Remove Stomp, Astonish, Defense Curl, Facade and Screech leveling; Facade remains a TM. Remove Swords Dance (already unavailable), Earthquake, Fissure and Hyper Beam machine compatibility. Keep existing Water/Ice/Electric/Fire coverage, Body Slam, Facade, Surf, Strength, Cut, Rest, Mega Punch, Mega Kick, Submission, Counter and Seismic Toss. Tongue Lash lowers Special, helping special coverage and weakening opposing special attacks. Stockpile raises Defense and Special. Existing Body Slam retains its Gen 1 Normal-type paralysis restriction.

Koffing/Weezing keep stats and pure Poison typing; evolution remains level 35. Pollution at 21 is the final approved replacement for Self-Destruct and the temporary Acid Armor suggestion. No Acid Armor is added. Remove Stockpile, Venoshock and Self-Destruct leveling. Remove Self-Destruct TM36 from both and Hyper Beam from Weezing. Keep Toxic, Venoshock, Thunderbolt, Thunder, Fire Blast, Rest, Explosion and existing Will-O-Wisp machine access. Weezing learns Incinerate immediately after evolution and Explosion at 49. Poison and burn are alternative strategies; Haze resets stages and cures both major statuses, so it can undo the user's poison/burn setup. No immediate recovery or defensive setup is added.

Rhyhorn/Rhydon retain their stats and pure Ground typing. Evolution remains level 42; Earthquake at 41 ensures natural Ground STAB before evolution. Horn Attack, Take Down, Pierce, Megahorn and Horn Drill emphasize charging and horns rather than Golem's defensive Rock identity. Remove Fury Attack, Leer, Rock Polish, Stone Press and Stone Edge leveling. Remove Thunderbolt, Thunder, Fire Blast and Fissure machines from both; remove Water Gun, Bubblebeam, Ice Beam, Blizzard, Surf and Hyper Beam from Rhydon. Keep Earthquake, Dig, Rock Slide, Rock Tomb, Body Slam, Double-Edge, Strength, Rest and Rhydon's physical Fighting/Bulk Up options. Rock Tomb does not guarantee this slow line outspeeds a target after one drop. Take Down doubles power strictly below half target HP and retains recoil; Horn Drill is a damaging Defense-debuff move, not an OHKO.

Other machine permissions, shops and prices stay unchanged. Custom variants retain individual stats, starting moves and machine masks; existing shared parent learnset pointers follow the revised parent lists.

## Updating and verification

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain the same layout; older 151/172/176-species saves require a fresh start. Known moves are not automatically deleted. Lickitung's new party stats apply on normal recalculation, such as leveling up.

The tuning registry now contains 113 entries: all 112 original species through Rhydon, plus Crobat. Existing tests validate exact stats/starts/learnsets, real generated moves/PP, original/extra TM permissions and historical variants. The full species, sprite, encounter, save, move, critical-hit and freeze regression suites remain included in both versions. Packaging applies each BPS to a verified original and compares byte for byte with the build.
