# Blaine and Elite Four teams — implemented

The subsequent [post-League Gym rematches](GYM-REMATCH-CHANGES.md) add separate Gym rematch teams; Blaine’s first team and all four Elite Four teams below remain unchanged.

Blaine and the four first-challenge Elite Four base teams now match the requested species, levels and send-out order in both versions. Each team has six Pokémon. Earlier Gym changes, all 313 regular teams and the Champion are unchanged.

| Trainer | Team, in send-out order |
| --- | --- |
| Bruno | Hitmonchan 55 → Hitmonlee 55 → Machamp 58 → Poliwrath 57 → Pinsir 56 → Primeape 58 |
| Blaine | Unique Charmander 45 → Arcanine 43 → Rapidash 40 → Magmar 40 → Ninetales 38 → Flareon 39 |
| Lorelei | Dewgong 54 → Cloyster 53 → Slowbro 54 → Jynx 56 → Lapras 56 → Unique Omanyte 60 |
| Agatha | Marowak 55 → Claydol 58 → Sableye 60 → Gengar 56 → Ninetales 56 → Parasect 58 |
| Lance | Gyarados 58 → Dragonair 56 → Lapras 58 → Tyranitar 60 → Aerodactyl 60 → Dragonite 62 |

No automatic level correction or evolution was applied to the requested rosters. “Agathe” is stored under the game’s existing Agatha trainer class.

## Existing movesets follow their Pokémon

- Blaine: Arcanine’s Fire Blast override moves to slot 2; Magmar’s Strength to slot 4; Ninetales’ Swift to slot 5. Rapidash retains its Take Down override in slot 3. Unique Charmander and Flareon use their current natural moves at levels 45 and 39.
- Lorelei: Dewgong, Slowbro, Jynx and Lapras retain their applicable existing overrides. Her level-60 unique Omanyte uses its independent natural learnset; it remains obtainable in Rock Tunnel as before.
- Bruno: Hitmonchan’s elemental punches/Brick Break move to slot 1, Hitmonlee’s Rolling Kick to slot 2 and Machamp’s Karate Chop/Double-Edge to slot 3. Removed Onix overrides do not land on Poliwrath, Pinsir or Primeape. New members use their natural moves.
- Agatha: her single level-56 Gengar retains the former level-56 Gengar’s Hypnosis / Dream Eater / Substitute / Thunderbolt set, now in slot 4. The former Haunter, Golbat, Arbok and second Gengar overrides are removed. Marowak, Claydol, Sableye, Ninetales and Parasect use their current natural learnsets and previously implemented typings.
- Lance: Gyarados and the retained Dragonair keep their existing overrides. Aerodactyl’s full set moves to slot 5 and Dragonite’s to slot 6. Lapras and Tyranitar use natural moves rather than inheriting the removed Dragonair/Aerodactyl slot overrides.

All 30 new party-slot movesets are recorded in data/blaine_elite_review.json and the current trainer regression fixture. No new move effects, stats, types or AI were added.

## Scope and compatibility

These are the base first-challenge teams. Existing League replay/scaling behavior is unchanged; no separate second-challenge rosters were added. Blaine retains his existing rematch behavior, and Giovanni’s newly disabled Gym rematch stays disabled. Badge/TM rewards, trainer items, party-size limit and money formulas are unchanged; existing level-dependent payouts naturally use the new levels.

All previous changes are included: sprites, 183 species, moves, TMs, types, encounters, 5% badge boosts, regular trainers and the seven earlier Gym Leader teams. Current 183-species saves remain compatible. Counts remain 361 stored trainer teams; total roster entries rise from 1,187 to 1,193.

## Verification

Both compiled versions load all 361 teams through ReadTrainer. Checks cover the 313 unchanged regular rosters, all 12 revised Gym/Elite teams, 36 unchanged other boss rosters, 100 exact boss movesets and bounded overrides. Every member of all 12 revised teams also passes the real send-out path with the expected species, level, moves and PP. Both cumulative BPS patches must reproduce the built ROMs byte for byte, and the full battle/species regression suite must pass before publication.
