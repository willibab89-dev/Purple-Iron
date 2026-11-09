# Elite Four and Champion rematches — implemented

The [postgame ace update](POSTGAME-ACE-CHANGES.md) revises second Lance’s Tyranitar/Dragonite to 82/90; the table below reflects those levels.

The second-clear League teams now match the requested levels and order. The first-clear teams, seven postgame Gym teams, other bosses and 313 regular teams remain unchanged.

## Unlock

After the first completed Hall of Fame, the League’s normal scripts automatically select the second teams. The Champion-defeated event alone does not unlock them before the Hall-of-Fame sequence finishes. Elite Four record 1 becomes record 2; the three starter-dependent Champion records 1/2/3 become 4/5/6. Repeated clears reuse these rematch records: levels are not increased again on a third or later clear. Existing postgame saves unlock them immediately without conversion.

| Opponent | Team, in send-out order |
| --- | --- |
| Lorelei | Dewgong 84 → Cloyster 83 → Slowbro 84 → Jynx 86 → Lapras 86 → Unique Omanyte 80 |
| Bruno | Hitmonchan 85 → Hitmonlee 85 → Machamp 88 → Poliwrath 87 → Pinsir 86 → Primeape 88 |
| Agatha | Marowak 85 → Claydol 88 → Sableye 80 → Gengar 86 → Ninetales 86 → Parasect 88 |
| Lance | Gyarados 88 → Dragonair 86 → Lapras 88 → Tyranitar 82 → Aerodactyl 80 → Dragonite 90 |
| Champion — Blastoise branch | Pidgeot 84 → Alakazam 86 → Rhydon 86 → Arcanine 86 → Exeggutor 88 → Unique Blastoise 90 |
| Champion — Venusaur branch | Pidgeot 84 → Alakazam 86 → Rhydon 86 → Gyarados 86 → Arcanine 88 → Venusaur 90 |
| Champion — Charizard branch | Pidgeot 84 → Alakazam 86 → Rhydon 86 → Exeggutor 86 → Gyarados 88 → Charizard 90 |

The level-80 members are intentional. Lance’s second team has since been updated to Tyranitar 82 and Dragonite 90, with all other members unchanged. Dragonair remains Dragonair at level 86 in the default, unscaled team.

## Moves

Elite Four rematches use their high-level natural moves with the applicable first-clear signature overrides retained. These final sets are explicitly stored for the new records. Hypnosis/Dream Eater Gengar, Hitmonchan’s punches/Brick Break, Lorelei’s support sets and Lance’s reviewed Gyarados/Aerodactyl/Dragonite sets remain with their Pokémon.

The Champion is **the same team and moves, with every level exactly +25**. Each of the three starter branches keeps all six species and all four moves per Pokémon from its first-clear version. Their levels are 84 / 86 / 86 / 86 / 88 / 90. This changes only the final Champion battle; earlier rival battles are unchanged.

## Scope and compatibility

All prior changes remain included, including Gym rematches and Giovanni’s no-rematch behavior. Species count stays 183, and existing 183-species saves remain compatible. The existing optional scaling and randomized-team options are preserved; the listed levels and species are the default unscaled/nonrandom teams. No new save field or repeated-clear counter is introduced.

There are now 375 stored teams, 1,270 total roster entries and 177 exact reviewed boss movesets. Wild encounters and player acquisition methods are unchanged. The availability overview now also lists the rival’s level-90 unique Blastoise in the Champion rematch. Money formulas, trainer AI and items are unchanged; existing payouts naturally use the selected levels.

## Verification

Both compiled versions load all 375 teams. Tests verify all previous regular/base/Gym rosters, seven new League records, 177 exact boss movesets and valid override bounds. Revised base/rematch send-outs are checked for species, level, moves and PP.

A separate emulator regression verifies unchanged first clears, the Hall-of-Fame gate, Champion-only negatives, all four Elite Four second teams, all three Champion +25 branches and identical moves, repeated loads without stacking, class exclusions, link guards, optional scaling and randomized-team behavior. Gym rematch and Giovanni no-rematch tests remain covered. Both cumulative BPS patches must match the built ROMs byte for byte, and the full regression suite must pass before publication.
