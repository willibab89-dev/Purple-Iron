# Rattata, Spearow and Pikachu family redesigns

This cumulative 183-species Red/Blue patch implements the six approved originals after the latest audit. Previous sprites, additional species, move effects, type changes, starter and early-bug/bird redesigns remain included. No new move mechanics or TM items are introduced.

## Stats

| Pokémon | HP | Attack | Defense | Speed | Special |
| --- | ---: | ---: | ---: | ---: | ---: |
| Rattata | 30 | 56 | 35 | 72 | 25 |
| Raticate | 65 | 81 | 60 | 97 | 50 |
| Spearow | 40 | 60 | 30 | 70 | 31 |
| Fearow | 65 | 90 | 65 | 100 | 61 |
| Pikachu | 35 | 55 | 30 | 90 | 50 |
| Raichu | 60 | 90 | 55 | 110 | 90 |

Only Raticate's HP (55→65) and Raichu's Speed (100→110) change. Fearow and the three earlier stages retain their stats and types.

## Starting and level-up moves

### Rattata

Starts with Tackle, Tail Whip.

7: Quick Attack, 14: Hyper Fang, 18: Focus Energy, 23: Flail, 29: Super Fang, 35: Facade.

### Raticate

Starts with Tackle, Tail Whip, Quick Attack.

7: Quick Attack, 14: Hyper Fang, 18: Focus Energy, 25: Flail, 32: Super Fang, 39: Facade.

### Spearow

Starts with Peck, Growl.

7: Leer, 12: Fury Attack, 17: Focus Energy, 23: Drill Peck, 29: Glare, 35: Pierce.

### Fearow

Starts with Peck, Growl, Leer.

7: Leer, 12: Fury Attack, 17: Focus Energy, 25: Drill Peck, 32: Glare, 39: Pierce.

### Pikachu

Starts with Thunder Shock, Growl.

6: Tail Whip, 8: Thunder Wave, 11: Quick Attack, 15: Double Team, 20: Shock Wave, 25: Charge, 29: Slam, 34: Thunderclap, 40: Light Screen, 46: Thunder.

### Raichu

Starts with Thunder Shock, Growl, Tail Whip, Thunder Wave.

6: Tail Whip, 8: Thunder Wave, 11: Quick Attack, 15: Double Team, 22: Shock Wave, 27: Charge, 31: Slam, 37: Thunderclap, 43: Light Screen, 50: Thunder.

Rattata and Spearow still evolve at level 20. Pikachu still evolves using a Thunder Stone. Raichu now has a full progression including Quick Attack and Double Team, so early stone evolution does not prevent learning the planned moves later.

## Compatibility and roles

- **Rattata family:** scrappy physical attackers using Hyper Fang, earlier Super Fang, Flail and Facade. Restore Double-Edge TM10 for both. Keep Dig, Body Slam, Double Team, Rest and Facade. Remove Bubblebeam, Water Gun, Ice Beam, Blizzard, Thunderbolt and Thunder compatibility; remove Raticate's Hyper Beam. Permissions that were already absent remain absent.
- **Spearow family:** fast predators using Focus Energy, Drill Peck, Glare and Pierce. Glare replaces level-up Agility at 29/32. Remove level-up Roost, Mirror Move, Gale Wind and Aerial Ace; keep Aerial Ace as a TM. Add Agility TM63 to both, keep Facade, Fly, Double Team, Rest and Rage. Remove Roost TM51, Twister TM02, Whirlwind TM04, Sky Attack TM43 and Fearow's Hyper Beam. Pidgeot's wind/recovery design is unchanged.
- **Pikachu family:** paralysis-based offense with optional physical attacks. Thunderbolt becomes a TM choice rather than a level-up move. Add Facade TM52 and Agility TM63 to both. Keep Thunderbolt, Thunder, Thunder Wave, Flash, Body Slam, Double Team, Reflect and Rest. Remove Submission and Seismic Toss compatibility, and Raichu's Hyper Beam.

TM52 and TM63 remain sold in Vermilion at 6,000 and 9,000 respectively; no vendor or price changes are needed. All other species retain their existing machine masks, including Mew's all-TM permissions.

## Audited battle interactions

- Facade doubles power with a major status and ignores burn's Attack penalty. Double-Edge recoil provides an optional route to stronger Flail, but may knock out the user.
- Glare remains 75 accuracy. Drill Peck and Pierce ignore positive Defense stages, not the target's underlying Defense.
- Shock Wave always critically hits a paralyzed target. These Gen 1 critical hits ignore Charge's Special boost, so Charge→Thunderbolt/Thunder and Thunder Wave→Shock Wave are alternative tools, not stacking damage boosts.
- Thunder always hits a target with a major status, while respecting typing immunity and invulnerability. Charge raises Special and accuracy. Thunderclap retains 50 power, +1 priority, 30% flinch and 5 PP.

These effects are existing mechanics and are unchanged by this patch.

Existing unique variants retain custom base stats, starting moves and TM masks. Unique Raichu retains its previous base header, including 100 Speed; its already-shared level-up/relearner list follows Raichu's new schedule.

## Updating and verification

Download artifact `pokemon-183-species-bps` from the successful Actions run and apply the matching BPS to an original, unmodified English Red/Blue ROM. Existing 183-species saves keep their layout. Earlier 151/172/176-species saves require a fresh start.

Existing Pokémon do not automatically forget moves removed from learnsets or TM compatibility. A normal level-up recalculates existing party Pokémon's stats; new Pokémon use the revised data immediately.

`data/species_tuning.json` now contains 28 reviewed originals: every species through Raichu, plus Farfetch'd and Onix. The metadata records explicit original-TM additions as well as removals. Tests verify the exact stat/start/level-up data, real party generation and PP, historical variant headers, all original and extra TM eligibility, real teaching/consumption/refusal and save behavior. The full existing sprite/species/encounter/move/crit/freeze suites also run for Red and Blue. Both BPS patches are applied to verified originals and compared byte for byte with the builds.
