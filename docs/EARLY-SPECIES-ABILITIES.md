# Abilities: starters and early Bug lines

Implemented for 15 original species, with five equally likely slots per species and 34 distinct ability effects. The saved slot stays the same on evolution; the ability comes from the evolved species' corresponding slot. Existing saves and the fixed party/box record sizes remain compatible. Unique variants do not inherit these pools automatically.

| Species | Slot 1 | Slot 2 | Slot 3 | Slot 4 | Slot 5 |
|---|---|---|---|---|---|
| Bulbasaur / Ivysaur / Venusaur | Poison Leaf | Chlorophyll | Overgrowth | Photosynthesis | Vine Guard |
| Charmander / Charmeleon / Charizard | Blaze | Combustion | Wildfire | Hot Temper | Confident |
| Squirtle / Wartortle / Blastoise | Water Pressure | Shell Guard | Ancient | Water Veil | Shell Armor |
| Caterpie | Run Away | Repulsive | Survival Instincts | Quick Reflexes | Shield Dust |
| Metapod | Hard Shell | Fortify | Regeneration | Quick Reflexes | Battle Armor |
| Butterfree | Compound Eyes | Psionic | Dust Cloud | Quick Reflexes | Wonder Skin |
| Weedle | Poison Point | Repulsive | Venomous | Piercing Sting | Shield Dust |
| Kakuna | Hard Shell | Fortify | Toxic Shell | Piercing Sting | Battle Armor |
| Beedrill | Ruthless | Frenzy | Venomous | Piercing Sting | Quick Reflexes |

Vine Guard replaces the former Thick Vines in slot 5. Existing Bulbasaur-family Pokémon with that slot receive Vine Guard.

## Effects

| Ability | Behavior |
|---|---|
| Poison Leaf | Successful damaging Grass moves have a 25% chance to poison. |
| Chlorophyll | Effective Speed ×1.5 while living HP is strictly below one-third maximum HP. No stage modification or repeated stacking. |
| Overgrowth | Grass damage ×1.25 at full HP. |
| Photosynthesis | Recover 1/16 maximum HP at round end while strictly above half HP. |
| Vine Guard | Incoming Flying damage ×0.5. |
| Blaze | Fire damage ×1.25 while living HP is strictly below one-third maximum HP. |
| Combustion | Successful damaging non-Fire moves have a 15% chance to burn. |
| Wildfire | Attack +1 after successfully burning an opponent. An already burned opponent does not trigger it again. |
| Hot Temper | Special +1 after taking physical move damage, once per party member per battle. |
| Confident | Accuracy +1 after an accuracy miss with a damaging move, once per party member per battle. Type immunity does not count as an accuracy miss. |
| Water Pressure | Water damage gains 2% per current PP, read before deduction, up to +50%. PP Ups count. Shin's existing unlimited enemy-PP behavior remains in effect; the ability reads the enemy's stored PP. |
| Shell Guard | Defense +1 after surviving a critical hit. Each critical strike of a multi-hit move can trigger it. |
| Ancient | Maximum HP ×1.2 after nature scaling, capped at 999. Applies during normal stat generation/recalculation, including leveling, evolution and storage withdrawal. Nature/Ability Capsule recalculation preserves missing HP, with a living minimum of 1; never revives. |
| Water Veil | Prevents new burns and halves incoming Fire damage. It does not cure a pre-existing burn. Fire moves can still thaw a frozen holder. |
| Shell Armor / Battle Armor | Prevent incoming critical hits, including moves that would otherwise guarantee a critical hit. |
| Run Away | Guaranteed escape from wild battles; does not permit fleeing trainer battles. |
| Repulsive | Successful damaging moves have a 10% chance to flinch. The target must still have an action remaining for the flinch to matter. |
| Survival Instincts | Speed +1 when living HP drops below one-third maximum, once per party member per battle. Also checked when a turn begins with low HP. |
| Quick Reflexes | First attempted damaging move after each entry gets +1 priority, added to its existing priority. A miss consumes it; a status move or inability to execute a move does not. Switching out and back in refreshes it. |
| Shield Dust | Blocks target-directed added move effects, including ability-granted Poison Leaf/Combustion/Repulsive effects. Direct status moves, damage, hit count, draining, recoil, primary trapping, screen removal and stat-reset attacks are unaffected. Fire thawing is still allowed. |
| Hard Shell | Incoming physical move damage ×0.75. |
| Fortify | Defense +1 when living HP drops below one-third maximum, once per party member per battle. Also checked when a turn begins with low HP. |
| Regeneration | Recover 1/16 maximum HP at round end, at any living HP. |
| Compound Eyes | Move accuracy ×1.3 after nature and stage factors, capped at the engine's always-hit threshold. |
| Psionic | Psychic damage ×1.2. |
| Dust Cloud | Taking a contact hit has a 25% chance to lower the attacker's Accuracy one stage. |
| Wonder Skin | Incoming status-move accuracy ×0.5. Damaging moves are unaffected. |
| Poison Point / Toxic Shell | Taking a contact hit has a 25% chance to poison the attacker. |
| Venomous | Damage ×1.25 against poisoned/badly poisoned opponents. |
| Piercing Sting | Poison is ×2 against the Bug type; combine normally with the opponent's other type. Bug/Poison therefore takes neutral Poison damage, Bug/Grass ×4. |
| Ruthless | Double the final critical-hit chance against an opponent with any major status condition, capped at the existing critical-rate maximum. |
| Frenzy | Attack +1 after a direct damaging-move knockout, while the user survives. Residual damage and opponents already fainted before the move do not count. |

## Shared rules and menus

- Physical/special uses this game's Gen 1 type categories. Contact is a separate explicit move list in `tools/generate_ability_moves.py`, compiled to `data/ability_move_metadata.asm`; ranged physical moves such as Earthquake do not trigger contact reactions.
- Chance-based attack and contact abilities roll once per move, not once per strike. Shell Guard specifically responds to each surviving critical strike. The 10%, 15% and 25% ability proc probabilities use exact rejection-sampled percentages.
- Substitute-protected targets do not trigger these post-damage/contact abilities. Contact reactions can still trigger on the hit that knocks out the ability holder; stat boosts for a hit recipient require it to survive. Poison Leaf, Poison Point and Toxic Shell inflict ordinary poison, not Toxic. Type/status immunities and the existing Curse/poison exclusion remain enforced.
- Threshold once-per-battle flags, Hot Temper and Confident persist when switching. Quick Reflexes alone refreshes on a new entry.
- Damage multipliers apply to ordinary move damage, not fixed-damage moves, confusion self-damage or residual damage. Multiple relevant damage factors combine multiplicatively with integer rounding.
- HP recovery rounds down, has a minimum of 1, caps at maximum HP and never revives.
- Transform keeps the user's own ability. Nature and ability slot metadata remain separate.
- Party menu **ABILITY** shows the selected Pokémon's current ability. Battle inspection remains **SELECT**, **LEFT/RIGHT** to switch side and **B/SELECT** to close. All new effects have descriptions.
- The trainer AI discourages Will-O-Wisp against Water Veil.
- Ability Capsules now work on every species in the table, changing to a different slot while preserving nature. Changing into or out of Ancient recalculates HP immediately. Nature Capsules preserve the ability slot. Species without a pool still reject Ability Capsules without consuming one.

## Validation

Both ROMs are built and checked with `tools/test_early_abilities.py`, the existing prototype ability tests and the full regression suite. Coverage includes all 75 species/slot combinations, both sides of battle, exact chance boundaries, full native move execution, multi-hit/contact/Substitute rules, priority stacking, critical prevention, all new damage/status/stat effects and Ancient's native wild/capture/capsule/PC/daycare/save paths. Existing generic nature/storage/evolution/Transform tests remain part of the suite. Saved struct lengths, absolute nature scratch addresses and the stack boundary remain unchanged.
