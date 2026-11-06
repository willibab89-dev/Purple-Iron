# Kanto type changes

This cumulative 183-species build includes all previous sprites, new species, moves, encounters and TMs, plus these changes to the original species:

| Pokémon | Type |
| --- | --- |
| Grimer / Muk | Ground/Poison |
| Ninetales | Fire/Ghost |
| Drowzee / Hypno | Psychic/Ground |
| Golduck | Water/Psychic |
| Marowak | Ground/Ghost |
| Parasect | Bug/Ghost |
| Electabuzz | Electric/Fighting |
| Rhyhorn / Rhydon | Ground |

Normal battle calculations automatically use these types for STAB, weaknesses, resistances and immunities. Pure Ground occupies both stored type slots without doubling its effects. Stats, learnsets, TM permissions and the existing unique variants retain their previous designs. For example, unique Grimer remains pure Poison and unique Marowak remains pure Ground.

Species IDs, total species count and save layout are unchanged from the preceding 183-species build. Saves from that build are compatible. Earlier 172/176-species saves still require a fresh start. Apply the matching cumulative BPS to an original, unmodified Red/Blue ROM; artifact name is `pokemon-183-species-bps`.

Validation checks the exact type bytes and real GetMonHeader results for all eleven changed originals in Red and Blue. Historical fixtures allow only these documented type differences, while preserving all other header fields, variant typings and TM permissions. Existing sprite, species, encounters, fresh-save/load and move tests run as regressions.
