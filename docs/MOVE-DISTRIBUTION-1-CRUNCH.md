# New-move distribution, batch 1: Crunch

This cumulative Red/Blue patch retains every previous sprite, species, stat, move, TM and trainer change. Species count remains 183 and move count remains 236 including Struggle. Existing 183-species saves remain compatible.

## New level-up entries

| Pokémon | Level | Move |
| --- | ---: | --- |
| Arbok | 43 | Crunch |
| Growlithe | 40 | Crunch |
| Arcanine | 40 | Crunch |
| Gyarados | 45 | Crunch |

All existing level-up entries remain. There are no stat, type, TM, encounter or move-effect changes. Raticate's fang/Facade identity is preserved; it does not receive Crunch in this batch.

Crunch remains Normal-type and physical: 80 power, 100 accuracy, 15 PP, with a 51/256 (approximately 20%) chance to lower the target's Defense by one stage after an eligible hit. It is not Dark-type. Bite retains its earlier-game role and flinch effect.

The additions provide thematic biting attacks and reliable physical options alongside the recipients' existing moves. Gyarados can choose Crunch without Thrash's commitment or Hyper Beam's recharge.

## Trainer compatibility

The inserted entry shifts Blaine's level-47 Arcanine's natural move slots. His old Agility override would then produce duplicate Agility. Moving his Fire Blast override to the second slot and removing the redundant Agility override gives the final set Agility / Fire Blast / Crunch / Double-Edge, preserving his other three options and leaving naturally generated Crunch and its 15 PP intact. Agatha's Arbok and Lance's Gyarados receive Crunch through ordinary generation and retain their existing overrides. Other trainer overrides are unchanged. Final loaded sets are checked through ReadTrainer in both versions.

## Updating and checks

Apply the matching BPS to an original, unmodified Red or Blue ROM. Back up saves. Existing Pokémon do not automatically replace a known move; those already past the learning level can use Shin's move relearner under its normal rules. A generated high-level Pokémon's last four eligible natural moves can change because of the inserted entry; this is the normal move-generation behavior.

Both versions run the existing exact learnset/generated-move/PP, species, TM, encounter, save, trainer and battle-mechanics checks, including Crunch's existing effect regression. BPS application is compared byte for byte with the built ROMs.

The broader distribution review remains in progress. This batch implements only the four agreed Crunch entries.
