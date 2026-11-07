# Sandshrew and both Nidoran families

This cumulative 183-species Red/Blue patch implements the pending Sandshrew and both Nidoran family plans. All prior sprites, added species, move mechanics, Kanto type changes and individually reviewed families remain included. No new battle effects, move IDs, TM items or saved fields are added.

## Base stats

| Pokémon | HP | Attack | Defense | Speed | Special |
| --- | ---: | ---: | ---: | ---: | ---: |
| Sandshrew | 50 | 75 | 85 | 40 | 30 |
| Sandslash | 75 | 100 | 110 | 65 | 55 |
| Nidoran♀ | 55 | 47 | 52 | 41 | 40 |
| Nidorina | 70 | 62 | 67 | 56 | 55 |
| Nidoqueen | 100 | 82 | 95 | 76 | 75 |
| Nidoran♂ | 46 | 57 | 40 | 50 | 40 |
| Nidorino | 61 | 72 | 57 | 65 | 55 |
| Nidoking | 81 | 102 | 77 | 85 | 75 |

Only Nidoqueen's HP 90→100 and Defense 87→95, and Nidoking's Attack 92→102 change. Sandshrew/Sandslash and all earlier Nido stages retain their stats. Types remain Ground for Sandshrew/Sandslash, Poison for the earlier Nidos, and Poison/Ground for the two final evolutions.

## Starting and level-up moves

### Sandshrew

Starts with Scratch.

6: Defense Curl, 10: Sand Attack, 14: Fury Swipes, 19: Dig, 23: Slash, 28: Rock Tomb, 34: Swords Dance, 40: Earthquake.

### Sandslash

Starts with Scratch, Sand Attack, Defense Curl.

6: Defense Curl, 10: Sand Attack, 14: Fury Swipes, 19: Dig, 23: Slash, 30: Rock Tomb, 38: Swords Dance, 46: Earthquake.

### Nidoran♀

Starts with Growl, Tackle.

7: Scratch, 10: Double Kick, 13: Poison Sting, 18: Bite, 24: Poison Fang, 30: Venoshock.

### Nidorina

Starts with Growl, Tackle, Scratch.

7: Scratch, 10: Double Kick, 13: Poison Sting, 20: Bite, 28: Poison Fang, 34: Venoshock.

### Nidoqueen

Starts with Growl, Tackle, Double Kick, Poison Sting.

7: Scratch, 10: Double Kick, 13: Poison Sting, 20: Bite, 23: Body Slam, 28: Poison Fang, 34: Venoshock, 40: Bulk Up, 48: Earthquake.

### Nidoran♂

Starts with Leer, Tackle.

7: Horn Attack, 10: Double Kick, 13: Poison Sting, 18: Focus Energy, 24: Poison Tail, 30: Fury Attack, 43: Horn Drill.

### Nidorino

Starts with Leer, Tackle, Horn Attack.

7: Horn Attack, 10: Double Kick, 13: Poison Sting, 20: Focus Energy, 28: Poison Tail, 34: Fury Attack, 49: Horn Drill.

### Nidoking

Starts with Leer, Tackle, Horn Attack, Poison Sting.

7: Horn Attack, 10: Double Kick, 13: Poison Sting, 20: Focus Energy, 23: Thrash, 28: Poison Tail, 34: Pierce, 42: Earthquake, 50: Megahorn, 58: Horn Drill.

Sandshrew still evolves at 22; both Nidoran evolve at 16. Nidorina and Nidorino still use Moon Stones. Both final Nidos have full level-up lists, allowing early stone evolution without losing their planned progression.

## Machine changes and roles

- **Sandshrew family:** armor, burrowing and claws. Defense Curl, earlier Fury Swipes, Dig, Slash, Rock Tomb, Swords Dance and Earthquake replace the old Poison Sting/Swift list. Keep Earthquake, Dig, Fissure, Rock Tomb, Rock Slide, Swords Dance, Cut, Strength, Rest and Aerial Ace. Remove Submission and Seismic Toss; remove Sandslash's Hyper Beam. Toxic remains excluded. No Stone Press is added.
- **Female Nido family:** durable armored bruisers. Poison Fang and Venoshock support a poison strategy, while Nidoqueen's Body Slam offers an alternative paralysis route. Bulk Up at 40 raises Attack and Defense; Earthquake arrives at 48. Add Poison Tail TM62 throughout the family and Bulk Up TM56 to Nidoqueen. Keep Thunderbolt as requested, alongside existing Ice compatibility and Nidoqueen's Fire Blast. Keep Toxic, Venoshock, Body Slam, Reflect and Rest; Nidoqueen retains Earthquake, Fissure, Rock Tomb, Rock Slide and Strength. Remove Horn Drill, Thunder, Water Gun, Bubblebeam and Surf permissions, plus Nidoqueen's Hyper Beam.
- **Male Nido family:** offensive horn attacks, critical-hit pressure and coverage. Focus Energy, Poison Tail and Fury Attack lead into Nidoking's Thrash, Pierce, Earthquake, Megahorn and late Horn Drill. Add Poison Tail TM62 throughout the family; retain Venoshock as an optional TM. Remove Nidoking's Bulk Up TM56 so Nidoqueen owns that setup role. Keep Thunderbolt, existing Ice compatibility and Nidoking's Fire Blast. Preserve Toxic, Body Slam, Double-Edge, Rest, Horn Drill and Nidoking's Ground/Rock/Strength permissions. Remove Thunder, Water Gun, Bubblebeam and Surf, plus Nidoking's Hyper Beam.

Only existing permissions are retained where specified: these lists do not newly give every earlier stage an evolved form's broad compatibility. TM56 remains in Vermilion for 9,000, TM62 in Fuchsia for 6,000. No stock/price changes are needed. Other species and Mew's all-TM rule are unchanged.

## Battle details

Poison moves use Attack. Bulk Up therefore improves ordinary Venoshock damage, while critical Poison Tail ignores the user's stat boosts under existing Gen 1 rules. Poison and paralysis cannot occupy the same target simultaneously. Slash criticals similarly ignore Swords Dance boosts, which instead help Dig/Earthquake and other ordinary attacks. Horn Drill remains 120 power, 40 accuracy and lowers target Defense two stages after hitting; it is not an OHKO move.

Custom unique variants keep their base stats, starting moves, typing and machine masks. Their existing shared parent evolution/relearner lists follow the new schedules. In particular, the two unique Nidoking variants keep their previous custom base Attack and extra-TM permissions.

## Updating and validation

Download artifact `pokemon-183-species-bps` from the successful Actions run and apply the matching BPS to an original, unmodified English Red/Blue ROM. Existing 183-species saves retain their layout. Earlier 151/172/176-species saves require a fresh start. Previously learned moves are not erased automatically; a normal level-up recalculates existing party stats.

`data/species_tuning.json` now contains 36 reviewed originals: every species through Nidoking, plus Farfetch'd and Onix. Tests verify exact stats, starts, level-up records, real party moves/PP, old variant headers and all original/extra machine eligibility, including the explicitly approved Surf removals. Historical fixtures preserve unrelated data. Real teaching/consumption/refusal and bag saves remain covered, alongside the full species/sprite/encounter/save/move/crit/freeze suites in both ROMs. Both BPS patches are applied to verified originals and compared byte for byte with the builds.
