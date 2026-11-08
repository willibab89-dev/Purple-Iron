# New-move distribution, batch 3: thematic coverage

Cumulative Red/Blue patches retain all earlier sprites, species, stats, moves, TMs, encounters and trainer fixes. There are still 183 species and 236 move records including Struggle. Existing 183-species saves remain compatible.

## Added level-up entries

| Pokémon | Level | Move |
| --- | ---: | --- |
| Gyarados | 53 | Outrage |
| Baltoy | 29 | Mud Wave |
| Claydol | 41 | Mud Wave |
| Victreebel | 51 | Vine Crush |
| Hitmonlee | 43 | Triple Kick |
| Porygon | 45 | Zap Cannon |

All existing level-up moves and learning levels remain. No stats, types, TMs, encounter tables, move effects or trainer overrides change in this batch. Baltoy and Claydol remain Rock/Ghost, and Baltoy still evolves at 36. Their metadata and executable learnsets are synchronized.

## Intended roles and existing mechanics

- Outrage fits Gyarados's temperament. It is special Dragon damage, so Dragon Dance does not raise its damage; its existing locking/confusion behavior remains.
- Mud Wave gives the clay Pokémon physical Ground coverage with its existing chance to lower accuracy. Their modest Attack limits damage.
- Vine Crush fits Victreebel's vines and doubles power against paralyzed opponents. Its own existing sleep/poison options remain; paralysis can come from a teammate.
- Triple Kick gives Hitmonlee multihit utility, with the existing separate hit checks and stopping rules.
- Zap Cannon fits Porygon's artificial design. Its accuracy condition against paralyzed targets remains; Thunder Wave TM compatibility is unchanged.

## Trainer generation

Adding entries can shift a generated high-level Pokémon's last four natural moves before existing special trainer overrides are applied. Lance's default level-58 Gyarados now finishes loading with Crunch / Dragon Dance / Fire Blast / Hyper Beam: his existing third-slot Fire Blast override replaces the naturally generated Outrage. That override is preserved, and the final loaded set is covered by the trainer regression. Players can retain or relearn Outrage normally. Other trainer overrides remain unchanged.

## Updating and checks

Apply the matching BPS to an original, unmodified Red or Blue ROM. Back up saves. Existing Pokémon do not automatically replace a known move; use normal level-up learning or Shin's move relearner when eligible.

Both versions run the exact learnset/generated-move/PP, species, evolution, TM, encounter, save, trainer and battle-mechanics suites, including the existing effects for all six additions. BPS application is compared byte for byte with the built ROMs.

Kabutops's possible Shell Smash addition remains a separate balance decision and is not implemented here.
