# Nature system

Each newly assigned nature is one of 43 equally likely effects. There are 42 combinations that raise one attribute by 10% and lower a different one by 10%, plus one neutral nature. The seven attributes are Attack, Defense, Speed, Special, Accuracy, Crit and Evasion. HP is unaffected. This game's single Special stat covers both special attack and special defense.

Open **POKéMON → choose a Pokémon → NATURE** to see its effect. A neutral nature displays “Raises NONE” and “Lowers NONE”. Nature Capsules select a different effect; they do not spend a capsule to give the same effect again.

Attack, Defense, Speed and Special modify the calculated underlying stat. Accuracy and Evasion modify hit probability; Crit modifies the ordinary critical-hit threshold. Existing ability effects, guaranteed hits and critical hits remain separate. The move information panel shows the nature-adjusted hit chance; its power field shows listed move power.

## Existing saves

Old Pokémon retain their stored nature and ability IDs. The 42 earlier single-stat combinations that do not affect HP retain exactly the same effects; older complex or HP-affecting natures are mapped deterministically to at most one increase and one decrease among the seven attributes. One former ID maps to neutral. The redesigned records use a new marker without changing record sizes, offsets or save checksum layout.

Party Pokémon are migrated when an existing save loads. Stored HP and stats are recalculated, preserving missing HP and never reviving a fainted Pokémon. Box and daycare Pokémon are migrated when accessed; their previous maximum HP is reconstructed using their old nature before conversion. Save the game after migration, and keep a backup when testing a new patch.

The generator keeps all 196 old IDs readable for compatibility, but random assignment uses only the 42 unique combinations and neutral. It uses rejection sampling across five complete sets of 43, so every new nature is equally likely. The extra compatibility IDs do not create extra outcomes or weights. A/B/Select closes the nature screen.

Both Red and Blue builds are covered by emulator tests for distribution, all saved IDs and ability slots, neutral and single-stat effects, old party and boxed Pokémon, HP preservation, battle calculations and save/load. These tests are not a substitute for a complete playthrough.
