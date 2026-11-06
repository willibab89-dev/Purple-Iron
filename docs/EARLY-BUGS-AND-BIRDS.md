# Early bugs and the Pidgey family

This cumulative Red/Blue patch implements the approved Caterpie, Weedle and Pidgey family plans. Total species remain 183. All prior front/back sprites, additional species, move effects, type changes, starter redesigns and earlier individual revisions remain included.

## Base stats

| Pokémon | HP | Attack | Defense | Speed | Special |
| --- | ---: | ---: | ---: | ---: | ---: |
| Caterpie | 45 | 30 | 35 | 45 | 20 |
| Metapod | 50 | 20 | 55 | 30 | 25 |
| Butterfree | 60 | 45 | 50 | 80 | 90 |
| Weedle | 40 | 35 | 30 | 50 | 20 |
| Kakuna | 45 | 25 | 50 | 35 | 25 |
| Beedrill | 65 | 90 | 40 | 85 | 45 |
| Pidgey | 40 | 45 | 40 | 56 | 35 |
| Pidgeotto | 63 | 60 | 55 | 71 | 50 |
| Pidgeot | 90 | 80 | 85 | 91 | 70 |

Only the final evolutions change: Butterfree Speed 70→80 and Special 80→90; Beedrill Attack 80→90 and Speed 75→85; Pidgeot HP 83→90 and Defense 75→85. Earlier stages keep their stats and types.

## Level-up moves

### Caterpie

Starting moves: Tackle, String Shot.

No additional level-up moves.

### Metapod

Starting moves: Harden.

7: Harden.

### Butterfree

Starting moves: Tackle, String Shot, Harden, Confusion.

11: Confusion, 12: Gust, 14: Poison Powder, 16: Stun Spore, 18: Sleep Powder, 24: Supersonic, 27: Whirlwind, 32: Psybeam, 36: Twister.

### Weedle

Starting moves: Poison Sting, String Shot.

No additional level-up moves.

### Kakuna

Starting moves: Harden.

7: Harden.

### Beedrill

Starting moves: Poison Sting, String Shot, Harden, Fury Attack.

11: Fury Attack, 14: Twineedle, 18: Focus Energy, 23: Pin Missile, 28: Agility, 34: Pierce, 40: Ambush.

### Pidgey

Starting moves: Gust.

5: Sand Attack, 9: Quick Attack, 16: Wing Attack, 21: Whirlwind, 25: Gale Wind, 29: Roost, 33: Agility, 37: Mirror Move.

### Pidgeotto

Starting moves: Gust, Sand Attack.

5: Sand Attack, 9: Quick Attack, 16: Wing Attack, 22: Whirlwind, 27: Gale Wind, 32: Roost, 38: Agility, 43: Mirror Move.

### Pidgeot

Starting moves: Gust, Sand Attack, Quick Attack.

5: Sand Attack, 9: Quick Attack, 16: Wing Attack, 22: Whirlwind, 27: Gale Wind, 32: Roost, 40: Agility, 45: Mirror Move, 52: Sky Attack.

Caterpie and Weedle evolve at 7, their cocoons at 10. Pidgey evolves at 18 and Pidgeotto at 36. Evolution data is unchanged. Repeated starting moves appear at the approved levels, allowing their normal learning/relearning without duplicate move slots.

## Distinct roles and compatibility

- **Butterfree:** fragile special attacker and status specialist. Supersonic at 24 replaces the proposed Gale Wind; Twister at 36 is Dragon-type but wind-themed, uses Special, may flinch and punishes airborne Fly users. Retain existing Twister TM compatibility. Add Agility TM63; remove Hyper Beam TM15. Existing Psychic, Mega Drain, Reflect, Rest, Double Team and Roost remain.
- **Beedrill:** fast physical stinger attacker. Earlier Twineedle, Focus Energy, Pin Missile, Agility, Pierce and Ambush replace the provisional Rage/Lunge/Megahorn progression. Add Poison Tail TM62 and Agility TM63; remove Hyper Beam TM15 and Mega Drain TM21. Keep Toxic, Swords Dance, Double Team, Rest, Bug-type Cut and Venoshock. No Roost.
- **Pidgey family:** wind control, physical durability and recovery. Earlier Wing Attack, Gale Wind, Roost and Mirror Move; late Sky Attack belongs to Pidgeot. Add Agility TM63 to all three. Remove Twister TM02 from all three and Hyper Beam TM15 from Pidgeot. Keep Roost, Aerial Ace, Fly, Double Team, Reflect and Rest. No changes are made to Fearow or Dodrio; their individual reviews remain pending.

TM62 remains sold in Fuchsia for 6,000; TM63 in Vermilion for 9,000. No new TM items, prices or vendor changes are needed. Mew retains its existing all-TM compatibility.

The existing Rock-type Kakuna variant retains its custom base header and TM permissions. Its already-shared evolution/relearner pointer continues to follow Kakuna's unchanged list.

## Updating and verification

Download `pokemon-183-species-bps` from the successful Actions run and apply the matching BPS to an original, unmodified English Red/Blue ROM. Saves from the current 183-species builds retain their layout; earlier 151/172/176-species saves require a fresh start.

Existing Pokémon do not automatically forget moves removed from level-up lists or machine compatibility. Newly generated Pokémon use the updated data. A normal level-up recalculates existing party Pokémon's stats.

`data/species_tuning.json` now records 22 reviewed original species. Tests cover exact stats and starting/level-up moves, real party generation and PP, evolution records, old variant headers, all original and extra TM permissions, and real teaching/consumption/refusal paths. Both ROMs also run the full existing sprite/species/encounter/save/move/critical/freeze regression suite. BPS application is compared byte for byte against both builds.
