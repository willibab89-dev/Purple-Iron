# New-move distribution, batch 2: Charm, Heal Bell and Snarl

Cumulative Red/Blue patches retain all earlier sprites, species, stats, moves, TMs, encounters and trainer fixes. Species count remains 183 and move count remains 236 including Struggle. Existing 183-species saves remain compatible.

## Added level-up entries

| Move | Pokémon | Level |
| --- | --- | ---: |
| Charm | Eevee only | 40 |
| Charm | Jynx | 26 |
| Heal Bell | Wigglytuff | 49 |
| Heal Bell | Lapras | 45 |
| Snarl | Persian | 27 |
| Snarl | Growlithe | 28 |
| Snarl | Arcanine | 28 |

All existing move entries and learning levels remain. Jynx's Charm moves from the proposed level 25 to 26 because it already learns Ice Punch at 25 and Shin's level-up routine offers only one move per level. The separate levels allow both to be learned normally without an engine change.

## Eevee's evolution choice

Vaporeon, Jolteon and Flareon do not receive Charm in their starting or level-up lists, or through a new TM. To carry Charm into an evolution, learn it while still Eevee at level 40 or above, then evolve while retaining the move. The relearner checks the current species: evolved forms cannot use it to obtain Eevee's Charm. Keep the move when choosing later move replacements; forgetting it after evolution means it cannot be relearned by that evolution under these lists.

## Existing move behavior

- Charm: Normal, 0 power, 90 accuracy, 20 PP; lowers the target's Attack by two stages under the existing status-move rules.
- Heal Bell: Normal status, 5 PP; cures major statuses on the active Pokémon and living party members. It does not restore HP, revive fainted members or remove volatile effects. The existing unique Chansey still learns it.
- Snarl: Normal and physical, 40 power, 95 accuracy, 15 PP; lowers the target's Special by one stage after an eligible hit. Existing Substitute, immunity and other hit gates remain.

No stats, types, TMs, encounters, move effects or trainer overrides change in this batch. Added entries can shift the last four naturally generated moves on wild or trainer Pokémon; existing custom trainer slot overrides remain in place.

## Updating and verification

Apply the matching BPS to an original, unmodified Red or Blue ROM. Back up saves. Existing Pokémon do not automatically replace a known move; use normal level-up learning or Shin's move relearner when eligible. The Eevee evolution restriction above also applies to existing saves.

Both versions check actual level-up learning and PP for all seven additions plus Jynx's retained Ice Punch, the Eevee level-39/40 relearner boundary, exclusion of Charm from all three evolved relearner lists even at level 100, and Jynx's separate 25/26 learning levels. Existing exact learnset/generated-move, species, TM, encounter, save, trainer and battle-mechanics suites also run. BPS application is compared byte for byte with the built ROMs.

Remaining move-distribution suggestions are still pending; this batch adds only the agreed Charm, Heal Bell and Snarl entries.
