# Gym Leader teams — implemented

The subsequent [Blaine and Elite Four patch](BLAINE-ELITE-FOUR-CHANGES.md) supplies Blaine’s replacement team and revises all four Elite Four teams. The seven teams documented below remain unchanged; “Blaine unchanged” below describes this earlier patch.

Seven Gym Leader rosters now match the requested order, species and levels in both versions. Blaine’s roster is unchanged. The recently implemented 313 regular teams and all other excluded boss rosters are unchanged.

| Leader | Team, in send-out order |
| --- | --- |
| Giovanni | Rhyhorn 45 → Dugtrio 42 → Nidoqueen 44 → Unique Nidoking 45 → Tyranitar 45 → Rhydon 50 |
| Brock | Geodude 10 → Vulpix 10 → Brock’s Onix 14 |
| Misty | Staryu 18 → Starmie 20 → Psyduck 16 → Horsea 16 |
| Lt Surge | Voltorb 21 → Magnemite 18 → Pikachu 20 → Unique Raichu 24 |
| Erika | Weepinbell 32 → Paras 36 → Gloom 34 → Erika’s Ivysaur 34 → Unique Bulbasaur 32 |
| Koga | Koffing 37 → Unique Poison Grimer 39 → Weezing 43 → Arbok 37 → Toxapex 38 |
| Sabrina | Kadabra 38 → Mr. Mime 40 → Drowzee 39 → Jynx 43 → Slowbro 39 |

Paras remains Paras at level 36; Drowzee remains Drowzee at level 39; Tyranitar remains level 45. No automatic evolution or level correction was applied to the requested teams. Misty’s Starmie remains her second Pokémon, followed by Psyduck and Horsea, as listed.

## Move handling

Existing overrides follow the matching Pokémon. Koga’s reviewed Weezing set (Toxic / Poison Gas / Incinerate / Haze) moves to slot 3, and Giovanni’s reviewed Rhydon set moves to slot 6. Misty’s Starmie, Sabrina’s Kadabra/Mr. Mime, Giovanni’s Dugtrio/Nidoqueen and Koga’s first Koffing retain their applicable existing overrides. Venomoth’s Bug/status overrides and Alakazam’s old slot override no longer land on Sabrina’s Drowzee or Jynx.

Other moves follow the current natural learnsets at the requested levels. For example, Brock’s level-14 unique Onix no longer has its level-15 Wrap, and Giovanni’s level-45 unique Nidoking has not yet learned level-47 Poison Fang. The unchanged reviewed TM overrides remain valid exceptions to natural learning levels. All 32 new leader-slot movesets are pinned in data/gym_leader_review.json and data/trainer_review.json.

## Giovanni: no Gym rematch

After his first defeat, Giovanni still awards the badge/TM normally. If the bag is full, talking to him still reaches TM collection. After the reward has been collected, talking to him triggers his existing departure and hides him; the rematch prompt and route back into battle are removed. His earlier Rocket Hideout/Silph Co. fights are unchanged. Other leaders retain their existing rematch behavior.

## Availability and compatibility

Erika’s former unique Tangela and Venusaur are no longer assigned to a trainer or an acquisition method. They remain defined species, and existing owned copies remain valid. The availability spreadsheet and searchable HTML now identify them as unassigned/unavailable. Six other variants remain trainer-only; player acquisition remains 175 of 183 species per version. No replacement encounter was added.

All previous sprite, species, move, TM, type, encounter, badge-boost and regular-trainer changes are included. Current 183-species saves remain compatible. Counts remain 361 stored trainer teams; the rosters now contain 1,187 entries.

## Verification

Both compiled versions load all 361 teams through ReadTrainer. Tests verify all 313 regular rosters, seven revised leader rosters, 41 unchanged other boss rosters, 82 exact reviewed/preserved boss movesets, valid party/move slots and legal moves. Every revised leader Pokémon is also loaded through the actual send-out routine and checked for its species, level, moves and correct move PP. A separate emulator test executes Giovanni’s talk-script branches for the first challenge, an owed TM and post-reward departure without rematching.

Cumulative BPS patches must reproduce the built ROMs byte for byte; the full battle/species regression suite must pass before publication. Roster and script tests establish implementation correctness, not a guarantee of the final difficulty curve.
