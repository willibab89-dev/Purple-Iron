# Final four unique variants

Cumulative Red/Blue patches include all previous sprites, species, move and TM changes. There are still 183 species and 236 move records including Struggle. All 183 species now have entries in data/species_tuning.json, completing the individual species review pass. No new moves, effects, types or save fields are introduced here.

Stats below are HP / Attack / Defense / Speed / Special. All four variants have independent level-up lists and no evolution. Their ordinary counterparts are unchanged.

## Unique Squirtle

Pure Water; 74 / 78 / 95 / 73 / 80, or +30 to each original stat.

Starts with Tackle, Tail Whip and Withdraw. Level 7 Water Gun, 15 Aqua Jet, 23 Bite, 31 Counter, 39 Skull Bash, 47 Waterfall, 55 Shell Smash.

TMs: Mega Punch, Body Slam, Counter, Seismic Toss, Reflect, Rest, Substitute, Surf, Strength and Facade. No Earthquake, Dig, Ice Beam or Blizzard. Keeps its existing 1% level-10 grass encounters on Routes 24/25 and no longer evolves into ordinary Wartortle.

Shell Smash gives +2 Attack, +2 Speed and -2 Defense. It improves physical moves, not Water damage, under the game's Gen 1 categories. Waterfall is special and bypasses positive Special stages on the target, not physical Defense boosts. Withdraw retains its existing +1 Defense/+1 accuracy behavior. Counter and Skull Bash offer a defensive alternative to Shell Smash.

## Erika's unique Tangela

Pure Grass; 75 / 95 / 110 / 45 / 75.

Starts with Constrict and Absorb. Level 7 Bind, 15 Leech Life, 23 Sleep Powder, 31 Ingrain, 39 Vice Grip, 47 Stockpile.

TMs: Body Slam, Mega Drain, Reflect, Rest, Substitute, Cut and Leech Life. No Swords Dance, Hyper Beam, Toxic or SolarBeam.

Vice Grip is Bug-type and physical, with 75 power. Leech Life is also physical. Stockpile gives +1 Defense and +1 Special; Special boosts Absorb or optional Mega Drain, but not the Bug attacks. Its final default level-29 Gym set is Absorb / Bind / Leech Life / Sleep Powder.

## Big Tentacool

Water/Poison; 100 / 60 / 75 / 40 / 105.

Starts with Poison Sting and Water Gun. Level 7 Supersonic, 15 Acid, 23 Wrap, 31 Brine, 39 Toxic, 47 Mist, 55 Hydro Pump.

TMs: Toxic, Bubblebeam, Water Gun, Ice Beam, Reflect, Rest, Substitute, Surf, Brine and Venoshock. No Swords Dance, Double Team, Mega Drain, Blizzard or direct draining moves. No immediate healing outside Rest.

Keeps its existing 1% encounters wherever ordinary Tentacool appears, with catch rate 60 rather than ordinary Tentacool's 190. It no longer evolves into ordinary Tentacruel. Toxic plus short-duration Wrap pressure helps bring targets into Brine's doubled-power range. Mist protects its stages without curing the target's poison.

## Erika's unique Venusaur

Grass/Poison; 80 / 82 / 83 / 65 / 115. Fifteen points move from Speed to Special, preserving ordinary Venusaur's stat total.

Starts with Tackle and Growl. Level 7 Vine Whip, 15 Poison Powder, 23 Growth, 31 Petal Dance, 39 Sludge, 47 Synthesis, 55 Venoshock.

TMs: Toxic, Mega Drain, SolarBeam, Reflect, Rest, Substitute, Cut and Venoshock. No Swords Dance, Body Slam or Hyper Beam. No natural Sleep Powder, Leech Seed, Giga Drain or SolarBeam.

Growth gives +1 Special/+1 Defense. Petal Dance is a single attack with an evasion drop, not a locking/confusing sequence. Synthesis is learned after Erika's Gym battle. The four remaining old Venusaur trainer overrides are removed, so its final default level-33 set is Vine Whip / Poison Powder / Growth / Petal Dance.

## Erika's complete final team

| Pokémon | Level | Final loaded moves |
| --- | ---: | --- |
| Unique Tangela | 29 | Absorb / Bind / Leech Life / Sleep Powder |
| Unique Ivysaur | 33 | Stun Spore / Leech Seed / Reflect / Vine Crush |
| Unique Venusaur | 33 | Vine Whip / Poison Powder / Growth / Petal Dance |

The trainer-loading regression executes ReadTrainer, including natural move generation and special overrides, for all three in both versions. Reviewed Brock, Surge, Koga and Giovanni sets stay covered; unrelated custom trainer moves remain unchanged.

## Updating and checks

Apply the matching BPS to an original, unmodified Red or Blue ROM. Existing 183-species saves remain compatible; back them up before updating. Existing Pokémon retain learned moves, and stat changes appear when recalculated, such as on level-up. Shin's move relearner supplies eligible missed level-up moves. No species types change in this batch.

Both versions run the species/header/sprite, exact generated learnset/PP, evolution-pointer, encounter, catch-rate, TM, SRAM and battle-mechanics suites, plus final trainer-party checks. BPS application is compared byte for byte with the built ROMs. Automated verification is not a complete manual campaign playthrough.

The individual species review is complete. The previously requested broad review of earlier Pokémon for moves introduced during this process remains pending; this patch does not begin that redistribution.
