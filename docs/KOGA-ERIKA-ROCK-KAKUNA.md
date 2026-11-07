# Koga's Grimer, Erika's Ivysaur and Rock Kakuna

Cumulative Red/Blue patches retain all previous sprites, species, move changes and TM changes. There are still 183 species; existing 183-species saves remain compatible. There are now 236 move records, including Struggle at its unchanged ID 165.

Stats are HP / Attack / Defense / Speed / Special. All three variants have independent level-up lists and do not evolve. Their ordinary counterparts are unchanged.

## Koga's Grimer

Pure Poison; 90 / 90 / 90 / 35 / 60.

Starts with Pound and Harden. Level 7 Poison Gas, 15 Sludge, 23 Disable, 31 Toxic, 39 Acid Armor, 47 Venoshock.

Koga retains his existing level-39 variant, whose generated moves are Sludge, Disable, Toxic and Acid Armor.

TMs: Toxic, Body Slam, Mega Drain, Rest, Substitute and Venoshock. No Thunderbolt, Thunder, Fire Blast, Selfdestruct or Explosion.

## Erika's Ivysaur

Grass/Poison; 70 / 62 / 85 / 50 / 85.

Starts with Tackle and Growl. Level 7 Vine Whip, 13 Stun Spore, 19 Leech Seed, 25 Reflect, 33 Vine Crush, 41 Synthesis, 49 SolarBeam.

Erika retains her existing level-33 variant, whose generated moves are Stun Spore, Leech Seed, Reflect and Vine Crush. Vine Crush doubles power against paralyzed targets.

TMs: Toxic, Mega Drain, SolarBeam, Reflect, Rest, Substitute and Cut. No Swords Dance or Body Slam. No Giga Drain or Ingrain.

## Rock Kakuna

Pure Rock; 65 / 45 / 120 / 20 / 50.

Starts with Tackle and Harden. Level 9 Rock Throw, 17 Leech Life, 25 Cocoon, 33 Rock Tomb, 41 Stone Press.

TMs: Rage, Mega Drain, Reflect, Bide, Rest, Rock Slide, Substitute and Rock Tomb.

Cocoon is new move 236: Normal-type, 0 power, 100 listed accuracy, 15 PP, self-targeted +2 Special stages, using Harden's animation and the existing Special-up-two effect. It follows ordinary stage/stat caps; no new battle state is required. Because Special governs offense and defense in Gen 1, optional Mega Drain benefits in damage and healing. Leech Life is physical and is not boosted by Cocoon. Stone Press uses Defense, so Harden improves it instead. Rage commits to its existing 2–3-turn sequence and builds Attack when opposing attack damage reaches HP; the player can select a draining move after the commitment ends. Critical hits retain the project's existing rules and ignore stat stages.

Rock Kakuna keeps its existing 1% encounters wherever ordinary Kakuna appears. It no longer evolves into ordinary Beedrill.

## Updating and validation

Apply the matching BPS to an original, unmodified Red or Blue ROM. Back up saves. Existing Pokémon retain previously learned moves; stat changes appear when stats are recalculated, such as on level-up. Shin's move relearner can provide eligible missed level-up moves.

Both versions are checked for Cocoon's actor paths, stage caps, PP, Mega Drain synergy, unchanged physical damage, generated boss moves, independent no-evolution lists and SRAM preservation. Existing species, encounters, moves, critical hits, freeze and TM checks are also run. Patch application is compared byte for byte with the built ROMs.

The broad redistribution of review-era new moves to earlier Pokémon remains deferred until the end of the species review.
