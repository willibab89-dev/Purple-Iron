# Seven more species: 183 total

This cumulative Red/Blue patch adds Baltoy, Claydol, Crobat, Dittwo, Larvitar, Pupitar and Tyranitar from the second `newmons.zip` (14 PNGs). All previous sprites, species, moves, encounters, crit/freeze behavior and TMs remain included. The earlier proposed type changes to original Kanto species are still proposals and are not included here.

## Start a new game

**A fresh save is required.** The Pokédex now uses 23 bytes each for seen and owned flags instead of 22; older 172/176-species saves are incompatible. Apply the matching BPS to an original, unmodified English Red/Blue ROM. Download artifact `pokemon-183-species-bps` from the successful Actions run.

## New species

Stats and learnsets are provisional and can be redesigned later. Special is a single Gen 1 stat; abilities and Dark/Steel/Fairy types are not added.

| Dex | Species | Type | HP/Attack/Defense/Speed/Special | Obtaining |
| ---: | --- | --- | --- | --- |
| 177 | Baltoy | Rock/Ghost | 40/40/55/55/55 | 2% on both Rock Tunnel floors, level 18 |
| 178 | Claydol | Rock/Ghost | 60/70/105/75/120 | Baltoy evolves at level 36 |
| 179 | Crobat | Poison/Flying | 85/90/80/130/80 | Golbat evolves at level 40; replaces friendship evolution |
| 180 | Dittwo | Normal | 48/48/48/48/48 | 1% on all Pokémon Mansion floors, level 30 |
| 181 | Larvitar | Ground | 50/64/50/41/45 | 2% on all Victory Road floors, level 40 |
| 182 | Pupitar | Ground | 70/84/70/51/65 | Larvitar evolves at level 30 |
| 183 | Tyranitar | Ground/Dragon | 100/134/110/61/95 | Pupitar evolves at level 55 |

Dittwo copies Ditto's stats, Normal typing, catch rate, growth rate and Transform-only learnset. It shares the existing automatic entry transformation, including its safeguards against transforming into another Ditto-like species, substitutes or invulnerable targets. Baltoy, Claydol and Dittwo are genderless; the other four use a 50/50 split. Existing cries and party icons are reused. Encounters are provisional; all previous rare encounter percentages are preserved.

New internal IDs reuse seven empty slots without changing any prior species IDs. Four unused species slots remain. Front and back graphics use the current full-size loader, with original PNGs retained and hashed. No new move IDs or TMs are added.

## Implementation and validation

The seven additions have complete base headers, names, cries, dex entries/order, palettes/icons, level-up/evolution lists and original/extra TM table rows. Metadata is in `data/new_species.json`. Their provisional TM permissions are intentionally limited; detailed move distribution is future work.

The base-stat/evolution bank reached its capacity, so healing, Transform and screen effect routines moved together to unused bank $39. Their existing bank-switch wrapper remains in use. Expanded save flags consume two additional WRAM bytes; the stack retains its $DFFF top and reserves 253 rather than 255 bytes.

Tests exercise every species' header mapping, all 183 back-loader paths, all eleven added fronts, party addition/move PP, gender, high Pokédex flags and fresh save/load, evolution records, rare encounter shares, all TM permissions and Dittwo automatic transformation on both sides. The full existing move/crit/freeze regression suite also runs for Red and Blue. Both cumulative BPS patches are applied locally and compared byte for byte with the built ROMs.
