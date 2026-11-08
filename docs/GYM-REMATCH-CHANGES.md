# Post-League Gym rematches — implemented

Seven separate five-Pokémon Gym rematch teams now match the requested order, species and levels. All first-challenge Gym teams, the Elite Four, Champion and 313 regular teams are preserved.

## Unlock and behavior

The existing rematch prompts remain. Before completing the Hall of Fame, accepting a rematch still uses that leader’s first team. After the persistent Hall-of-Fame flag is set and the individual leader has already been defeated, normal engagement selects their new record 2. Merely beating the Champion before the Hall-of-Fame sequence, or defeating a different Gym Leader, does not unlock the new team. Existing postgame saves with these events already set unlock them immediately; no save conversion or new save field is needed.

Giovanni is excluded and still leaves without offering a Gym rematch. Existing level-scaling and randomized-team options retain their behavior. Listed levels are the unscaled base levels; enabled optional scaling can raise them as before. Link battles bypass trainer loading/selection as before.

| Leader | Post-Hall-of-Fame team, in send-out order |
| --- | --- |
| Brock | Golem 64 → Ninetales 66 → Crobat 64 → Chansey 62 → Onix 67 |
| Misty | Starmie 62 → Golduck 66 → Seadra 64 → Seaking 65 → Vaporeon 66 |
| Lt Surge | Electrode 66 → Magneton 64 → Unique Raichu 62 → Electabuzz 68 → Jolteon 65 |
| Erika | Victreebel 66 → Erika’s Venusaur 68 → Erika’s Tangela 62 → Vileplume 68 → Exeggutor 66 |
| Koga | Weezing 63 → Muk 65 → Arbok 62 → Tentacruel 68 → Crobat 64 |
| Sabrina | Alakazam 62 → Mr. Mime 62 → Hypno 66 → Jynx 68 → Slowbro 65 |
| Blaine | Charizard 65 → Arcanine 63 → Rapidash 62 → Magmar 62 → Flareon 66 |

Brock’s rematch uses **standard Onix 67**, as listed without a unique qualifier; his first challenge still uses Brock’s unique Onix 14. Crobat was already implemented, so no new species or evolution change was needed. Koga’s rematch Muk and Arbok are their standard forms; his first team retains unique Poison Grimer.

## Moves and availability

New rematch teams use the reviewed natural learnsets at their new levels. They have their own exact moveset fixtures and do not inherit the first team’s slot-specific overrides—Misty’s level-62 Starmie, for example, uses its high-level natural set instead of the first team’s Water Gun set. This pass adds no move effects, TM compatibility or custom rematch overrides; a separate tactical moveset review can build on these teams.

Erika’s unique Venusaur and Tangela return as rematch-only trainer opponents at levels 68 and 62. They are no longer unassigned. Unique Raichu is used by Surge at level 24 initially and 62 in rematches. Player acquisition methods and wild encounter rates are unchanged: 175 species have an acquisition method and eight variants remain trainer-only in each version. The availability spreadsheet and searchable HTML reflect the restored trainer assignments.

All prior changes remain included, with 183 species and current-save compatibility. There are now 368 stored trainer teams (361 previous plus seven rematch records), 1,228 total roster entries and 135 exact reviewed boss movesets. Money formulas, AI and trainer items are unchanged; payouts naturally use the selected party’s levels.

## Verification

Both ROMs load all 368 teams through ReadTrainer. Checks cover the unchanged regular/base/boss rosters, seven exact rematch rosters, all 135 pinned boss sets and bounded move overrides. The real send-out path verifies species, level, moves and PP for all revised base and rematch teams.

A separate emulator test checks every combination of Hall-of-Fame/individual-victory flags for all seven leaders; Champion-only and wrong-leader negatives; real engagement initialization; all other trainer classes remaining excluded; link-battle guards; optional scaling; random 6/3-member parties; and unchanged Giovanni. His existing no-rematch script regression also remains covered. Cumulative BPS patches must round-trip byte for byte and the full regression suite must pass before publication.
