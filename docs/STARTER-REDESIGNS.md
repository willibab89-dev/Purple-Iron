# Starter family redesigns

The cumulative 183-species Red/Blue build now implements the approved Bulbasaur, Charmander and Squirtle family plans, including their final audit. All prior sprites, additional species, move effects, Kanto type changes and first four species revisions remain included. No new move IDs, TMs or saved fields are added in this patch.

## Base stats

| Pokémon | HP | Attack | Defense | Speed | Special |
| --- | ---: | ---: | ---: | ---: | ---: |
| Bulbasaur | 45 | 49 | 49 | 45 | 65 |
| Ivysaur | 60 | 62 | 63 | 60 | 80 |
| Venusaur | 80 | 82 | 83 | 80 | 100 |
| Charmander | 39 | 52 | 43 | 65 | 50 |
| Charmeleon | 58 | 64 | 58 | 80 | 65 |
| Charizard | 78 | 94 | 78 | 100 | 85 |
| Squirtle | 44 | 48 | 65 | 43 | 50 |
| Wartortle | 59 | 63 | 80 | 58 | 65 |
| Blastoise | 89 | 83 | 100 | 78 | 85 |

Only Charizard's Attack (84→94) and Blastoise's HP (79→89) change. The other seven starters retain their existing stats. Types stay Grass/Poison, Fire (Fire/Flying for Charizard), and Water.

## Level-up moves

### Bulbasaur

Starting moves: Tackle, Growl.

7: Leech Seed, 10: Vine Whip, 13: Poison Powder, 19: Razor Leaf, 23: Growth, 27: Sleep Powder, 30: Synthesis, 43: Solar Beam.

### Ivysaur

Starting moves: Tackle, Growl, Leech Seed.

7: Leech Seed, 10: Vine Whip, 13: Poison Powder, 20: Razor Leaf, 24: Growth, 28: Sleep Powder, 31: Synthesis, 49: Solar Beam.

### Venusaur

Starting moves: Tackle, Growl, Leech Seed, Vine Whip.

7: Leech Seed, 10: Vine Whip, 13: Poison Powder, 20: Razor Leaf, 24: Growth, 28: Sleep Powder, 31: Synthesis, 35: Sludge, 46: Petal Dance, 58: Solar Beam.

### Charmander

Starting moves: Scratch, Growl.

7: Ember, 13: Leer, 19: Flame Charge, 24: Rage, 28: Incinerate, 33: Slash, 38: Flamethrower, 44: Fire Spin.

### Charmeleon

Starting moves: Scratch, Growl, Ember.

7: Ember, 13: Leer, 20: Flame Charge, 25: Rage, 30: Incinerate, 34: Slash, 42: Flamethrower, 48: Fire Spin.

### Charizard

Starting moves: Scratch, Growl, Ember, Leer.

7: Ember, 13: Leer, 20: Flame Charge, 25: Rage, 30: Incinerate, 34: Slash, 37: Wing Attack, 42: Flamethrower, 48: Fire Spin, 54: Dragon Dance.

### Squirtle

Starting moves: Tackle, Tail Whip.

7: Bubble, 12: Water Gun, 17: Withdraw, 22: Bite, 27: Skull Bash, 43: Hydro Pump.

### Wartortle

Starting moves: Tackle, Tail Whip, Bubble.

7: Bubble, 12: Water Gun, 18: Withdraw, 23: Bite, 30: Skull Bash, 48: Hydro Pump.

### Blastoise

Starting moves: Tackle, Tail Whip, Bubble, Water Gun.

7: Bubble, 12: Water Gun, 18: Withdraw, 23: Bite, 30: Skull Bash, 37: Snipe Shot, 45: Spike Cannon, 54: Hydro Pump.

Bulbasaur, Charmander and Squirtle evolve at level 16. Ivysaur evolves at 32; Charmeleon and Wartortle at 36. Each stage has its own learnset. Wartortle gets Skull Bash at 30 so a normally evolved Blastoise can carry it into battle; Wing Attack and Snipe Shot arrive at 37 after their respective final evolutions.

## Roles and machine compatibility

- **Bulbasaur family:** Leech Seed and Synthesis recovery; no Giga Drain or Ingrain in their new lists. Venusaur adds Sludge at 35 and Petal Dance at 46. Existing TMs, including Mega Drain, Toxic and Venoshock, remain available.
- **Charmander family:** early Flame Charge, physical and special offense, and late Dragon Dance for Charizard. Remove Earthquake, Dig and Fissure compatibility throughout the family. No Will-O-Wisp or Roost compatibility; Charizard retains Aerial Ace and Fly. Cauterize is removed from its level-up list. Incinerate can still exploit burns from damaging Fire moves.
- **Squirtle family:** Withdraw gives Defense/accuracy; Skull Bash boosts Defense while charging. Blastoise alone gets Snipe Shot and Spike Cannon through leveling. Spike Cannon remains **Rock-type**,20 power,95 accuracy,20 PP,2–5 hits. No level-up Bubblebeam, Aqua Jet or Counter. Existing Brine, Scald, Surf, Ice and other TMs remain; remove Earthquake, Dig and Fissure. No Aqua Jet TM is created.

Existing unique variants retain their custom base stats, starting moves and machine masks. Their already-shared parent level-up/relearner lists now follow these new schedules. In particular, unique Blastoise's custom header is not given the original Blastoise's HP buff.

## Updating and validation

Download artifact `pokemon-183-species-bps` from the successful Actions run and apply the matching BPS to an original, unmodified English Red/Blue ROM. Existing 183-species saves retain their layout. Earlier 151/172/176-species saves need a fresh start.

Existing Pokémon do not automatically forget moves removed from these lists or TM permissions. New level-up/relearner rules apply going forward. A normal level-up recalculates existing party Pokémon's stats; new Pokémon use the new base stats immediately.

`data/species_tuning.json` records all thirteen individually reviewed originals. Tests verify their exact stat/start/level-up data and real party-generation moves/PP. Historical fixtures permit only approved changes while preserving variant headers and unrelated data. Real TM checks cover removed Ground permissions and all 13 extra TMs, including Charizard's lost Roost/Will-O-Wisp and retained Aerial Ace. Both versions also run the existing species, sprite, encounter, save, move, crit and freeze regression suites. Cumulative BPS patches are applied locally and compared byte for byte with the ROM builds.
