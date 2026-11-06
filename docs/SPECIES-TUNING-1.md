# First species tuning pass and TM61–63

This cumulative Red/Blue build includes all 183 species, previous front/back sprites, move effects, original-species type changes, encounters and TMs. It applies the requested Ekans, Arbok, Onix and Farfetch'd redesigns. Species and item IDs remain stable, and saves from the previous 183-species build retain their layout. Earlier 151/172/176-species saves require a fresh start.

## Stats and starting moves

| Pokémon | HP | Attack | Defense | Speed | Special | Starting moves |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Ekans | 40 | 60 | 44 | 70 | 40 | Leer, Poison Sting |
| Arbok | 70 | 85 | 69 | 95 | 65 | Leer, Poison Sting, Wrap |
| Onix | 60 | 75 | 130 | 70 | 55 | Screech, Tackle |
| Farfetchd | 62 | 85 | 55 | 87 | 58 | Peck, Sand Attack |

## Level-up moves

### Ekans

10: Poison Sting, 17: Bite, 24: Glare, 31: Poison Fang, 38: Screech.

### Arbok

10: Poison Sting, 17: Bite, 27: Glare, 36: Poison Fang, 47: Screech, 54: Coil.

### Onix

15: Bind, 19: Rock Tomb, 25: Rage, 33: Slam, 43: Stone Press, 50: Coil.

### Farfetchd

7: Leer, 15: Lunge, 23: Slash, 31: Focus Energy, 39: X Scissor, 45: Sky Attack.

The lists replace the previous provisional level-up additions, rather than appending to them. Ekans still evolves into Arbok at level 22. Poison Sting at level 10 is retained as requested; a Pokémon that already knows it does not gain a duplicate move. The evolved form has its own schedule.

## TM changes

| TM | Move | Shop | Price | Initial compatibility |
| --- | --- | --- | ---: | --- |
| 61 | Leech Life | Fuchsia | 4,000 | Ekans, Arbok |
| 62 | Poison Tail | Fuchsia | 6,000 | Ekans, Arbok |
| 63 | Agility | Vermilion | 9,000 | Farfetch'd |

Mew can also learn all three, following its existing all-TM rule. Other species' compatibility can be expanded during their individual reviews. TM51–60 compatibility remains intact: Onix already learns Rock Tomb; Farfetch'd already learns Roost, Facade and Aerial Ace.

Ekans and Arbok cannot learn Earthquake, Dig or Hyper Beam through TMs. Ekans already lacked Hyper Beam. Onix cannot learn Toxic, Mimic or Double Team; those restrictions were already present. Farfetch'd already lacked Toxic and continues to do so. Previously learned moves in an existing save are not erased.

The original four species' stats and starting moves are changed. Existing unique variants keep their custom base headers. Brock's unique Onix keeps its previous base stats and starting moves, but its shared Onix evolution/relearner data follows the new level-up schedule.

## Technical details and verification

TM61–63 occupy previously empty item IDs108–110, and append to the machine move table after the existing 65 entries. Their 13-bit compatibility masks fit the existing two-byte-per-species table; no saved fields expand. The lookup bounds use `NUM_EXTRA_TMS`, and both shops remain within the 14-item limit.

Species tuning metadata is in `data/species_tuning.json`. Historical fixtures retain their original values and allow only the approved stat, starting-move, learnset and TM deltas. Tests check the exact lists, real party generation/PP, variant preservation, original and new TM compatibility, all 68 machine mappings, names/prices/key flags, thirteen teaching/consumption/refusal paths and bag saves. Existing species, sprites, encounters and battle mechanics are tested in both ROMs. Cumulative BPS patches are applied to the originals and compared byte for byte with the builds.

Download artifact `pokemon-183-species-bps` from the successful Actions run. Apply the matching BPS to an original, unmodified English Red/Blue ROM.
