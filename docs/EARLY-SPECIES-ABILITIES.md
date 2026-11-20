# Abilities: starters and early Bug lines

Implemented for 46 species, with five equally likely slots per species. The saved slot stays the same on evolution; the ability comes from the evolved species' corresponding slot. Existing saves and the fixed party/box record sizes remain compatible. Unique variants do not inherit these pools automatically.

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
| Pidgey / Pidgeotto / Pidgeot | Tailwind | Predator | Keen Eye | Piercing Beak | Gale Wings |
| Rattata / Raticate | Scavenger | Strong Jaw | Cornered | Hustle | Poison Heal |
| Spearow / Fearow | Ruthless | Short Temper | Relentless | Piercing Beak | Sniper |
| Ekans / Arbok | Intimidate | Shed Skin | Venomous | Predator | Corrosive Venom |
| Pikachu / Raichu | Static | Voltage | Overcharge | Quick Reflexes | Quick Feet |
| Sandshrew | Rolling Defense | Sand Armor | Burrower | Sharp Claws | Sand Veil |
| Sandslash | Spiny Armor | Sand Armor | Burrower | Sharp Claws | Sand Veil |
| Nidoran♀ / Nidorina / Nidoqueen | Poison Point | Measured | Thick Hide | Protective Instinct | Iron Will |
| Nidoran♂ / Nidorino / Nidoking | Poison Point | Piercing Horn | Sheer Force | Bloodlust | Rampage |
| Clefairy / Clefable | Lucky Star | Magic Guard | Moon Child | Unpredictable | Wonder Skin |
| Vulpix / Ninetales | Aftermath | Foxfire | Nine Lives | Fox's Cunning | Illusion |
| Jigglypuff / Wigglytuff | Inflatable | Performer | Rubber Skin | Soothing Voice | Thick Fat |
| Zubat / Golbat / Crobat | Echolocation | Bloodsucker | Gale Wings | Infiltrator | Predator |
| Oddish / Vileplume | Perfume | Absorption | Pollen | Effect Spore | Photosynthesis |
| Gloom | Stench | Absorption | Pollen | Effect Spore | Toxic Waste |

Vine Guard replaces the former Thick Vines in slot 5. Existing Bulbasaur-family Pokémon with that slot receive Vine Guard.

## Effects

Oddish-family effects: Perfume raises Evasion one stage on entry. Absorption adds 25% of damage dealt to healing from damaging drain moves. Pollen adds 20 accuracy points to Poisonpowder, Stun Spore, Sleep Powder and Spore. Effect Spore gives each physical hit a 20% chance to choose poison, paralysis or sleep equally; existing status immunities apply. Stench reduces damage from poisoned opponents by 25%. Toxic Waste heals 1/16 maximum HP each turn while the opposing active Pokémon is alive and poisoned. Photosynthesis heals 1/16 maximum HP each turn while above half HP.

Zubat-family effects: Echolocation adds 20 percentage points to move accuracy before the final cap. Bloodsucker adds 25% of damage dealt to healing from draining moves, rounded down. Gale Wings gives Flying moves +1 priority at full HP. Infiltrator bypasses opposing Reflect, Light Screen and Substitute while preserving them for later attacks; screen-breaking moves still remove screens. Predator boosts physical damage by 20% against slower opponents.

Jigglypuff-family effects: Inflatable raises Defense one stage after each physical hit received; hits on a Substitute do not count. Performer multiplies sound-move accuracy by 1.2. Rubber Skin grants immunity to opposing Electric moves, including Thunder Wave. Soothing Voice restores 1/8 maximum HP after a sound move executes, including when it misses; it cannot revive. Thick Fat halves damage from Fire and Ice moves. Sound moves are Growl, Roar, Sing, Supersonic, Screech, Wailing Cry, Snarl and Heal Bell.

Vulpix-family effects: Aftermath curses a living opponent whose direct attack knocks the holder out. Foxfire raises Special one stage after inflicting burn, once per battle. Nine Lives survives a lethal direct attack with 1 HP once per battle. Fox's Cunning raises Evasion one stage after using a Ghost move, once per battle. Illusion halves damage from the first damaging attack received after entry, including all hits of a multi-hit attack. Hits on a Substitute do not consume Illusion or Nine Lives.

Clefairy-family effects: Lucky Star gives damaging moves a 10% chance to deal 50% more damage. Magic Guard prevents indirect damage from poison, burn, Leech Seed, recoil, crash damage, Spiny Armor and residual Wrap, Fire Spin and Curse. Moon Child heals 1/16 maximum HP each turn, with a minimum of 1 HP and no revival. Unpredictable boosts damage from moves called by Metronome by 30%. Wonder Skin halves the accuracy of incoming status moves.

Nidoran♂-family effects: Poison Point has a 25% chance to poison physical attackers. Piercing Horn ignores 20% of Defense with physical moves. Sheer Force increases damage by 20% for moves with secondary effects and suppresses those effects. Bloodlust increases physical damage by 25% against a living target below half HP. Rampage increases physical damage by 25% and inflicts recoil equal to 10% of damage dealt per hit, rounded down with a minimum of 1; Substitute damage is capped at its remaining HP. Fixed physical damage is affected by Bloodlust and Rampage.

Nidoran♀-family effects: Poison Point has a 25% chance to poison the attacker after a physical hit, including ranged attacks; Weedle retains its previously implemented contact-only Poison Point. Measured multiplies outgoing move damage by 0.8, including fixed-damage moves and Counter, and doubles the probability of move secondary effects using the existing single RNG draw, capped at certainty. Thick Hide multiplies incoming physical move damage by 0.85, including fixed damage. Protective Instinct raises Defense one stage below half HP once per battle. Iron Will prevents critical hits, including guaranteed critical hits. Existing Substitute, type/status immunity and minimum-damage rules apply.

Sandshrew-family effects: Rolling Defense raises Defense one stage after executing a Normal move, once per battle. Spiny Armor damages a physical attacker by 1/16 of its maximum HP per direct hit, including ranged attacks and hits that KO the holder; it does not activate through Substitute. Sand Armor reduces super-effective damage by 25%. Burrower restores 1/8 maximum HP after executing a Ground move. Sharp Claws multiplies physical critical-hit chance by 1.5. Sand Veil raises Evasion one stage after executing a Ground move, once per battle. The Normal/Ground triggers apply when the move executes, including on a miss; two-turn moves trigger when their attack executes.

Pikachu-family effects: Static has an exact 20% chance to paralyze an attacker after a physical hit, including ranged physical moves, once per move; the existing Electric-type/status immunities and Substitute rules apply. Voltage increases Electric damage by 20% against paralyzed targets. Overcharge raises Special one stage after a successful critical hit, once per battle; a hit on a Substitute counts. Quick Reflexes gives the first attempted damaging move after entry +1 priority. Quick Feet raises Speed one stage when a major status is present; it can trigger again after the status is cured and a new one is inflicted, and reapplies on entry. Paralysis retains its existing Speed penalty.

Ekans-family effects: Intimidate lowers the opposing Pokémon’s Speed one stage on entry, once per holder per battle; a given target can only be affected once per battle, so the effect does not stack. Shed Skin has an exact 30% chance at turn end to cure a major status and clear Toxic counters, recalculating stats and synchronizing the party. Venomous increases damage by 25% against poisoned targets; Predator increases physical damage by 20% against slower targets. Corrosive Venom makes Poison attacks super effective against Rock while retaining the defender’s other type interactions; AI effectiveness scoring uses the same rule.

Spearow-family effects: Ruthless doubles critical chance against a target with a major status; Short Temper raises Attack one stage when a move misses (type immunity does not count); Relentless adds 10% damage after each successful damaging strike against the same target, up to 30%, including hits on Substitute. Switching or using a non-damaging move resets the stacks; a miss does not add a stack. Piercing Beak ignores 25% of Defense with Flying attacks; Sniper increases critical damage by 50%.

Pidgey-family effects: Tailwind raises Speed one stage on entry; Predator boosts physical damage by 20% against a slower target; Keen Eye prevents accuracy reductions; Piercing Beak ignores 25% of the defender's Defense for Flying moves; Gale Wings gives Flying moves +1 priority at full HP. Predator compares effective battle speeds. The existing type-based physical/special categories apply.

Rattata-family effects: Scavenger restores 1/4 maximum HP after a direct move KO; Strong Jaw boosts physical damage by 15%; Cornered raises Attack one stage the first time HP falls below one third in a battle; Hustle boosts physical damage by 25% and reduces its base accuracy by 15 percentage points; Poison Heal replaces poison damage with 1/8 maximum HP healing. Poison remains present and Leech Seed still applies. Healing has a minimum of 1 HP and never revives a fainted Pokémon.

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
- Chance-based attack and reactive abilities roll once per move, not once per strike. Shell Guard specifically responds to each surviving critical strike, while Spiny Armor damages on each eligible hit. The 10%, 15%, 20%, 25% and 30% ability proc probabilities use exact rejection-sampled percentages.
- Substitute-protected targets do not trigger defensive reactions. Eligible reactions can still trigger on the hit that knocks out the ability holder; stat boosts for a hit recipient require it to survive. Poison Leaf, both Poison Point variants and Toxic Shell inflict ordinary poison, not Toxic. Type/status immunities and the existing Curse/poison exclusion remain enforced.
- Threshold once-per-battle flags, Hot Temper and Confident persist when switching. Quick Reflexes alone refreshes on a new entry.
- Damage multipliers normally apply to ordinary move damage; Measured and Thick Hide also reduce applicable fixed-damage moves, Counter and Bide. One-hit-KO moves, confusion self-damage and residual damage are unaffected. Multiple relevant damage factors combine multiplicatively with integer rounding.
- HP recovery rounds down, has a minimum of 1, caps at maximum HP and never revives.
- Transform keeps the user's own ability. Nature and ability slot metadata remain separate.
- Party menu **ABILITY** shows the selected Pokémon's current ability. Battle inspection remains **SELECT**, **LEFT/RIGHT** to switch side and **B/SELECT** to close. All new effects have descriptions.
- The trainer AI discourages Will-O-Wisp against Water Veil.
- Ability Capsules now work on every species in the table, changing to a different slot while preserving nature. Changing into or out of Ancient recalculates HP immediately. Nature Capsules preserve the ability slot. Species without a pool still reject Ability Capsules without consuming one.

## Validation

Both ROMs are built and checked with `tools/test_early_abilities.py` and the existing prototype ability tests. Coverage includes all 230 species/slot combinations, both sides of battle, Pidgey-family entry, priority, accuracy and damage paths, Rattata-family damage, accuracy, knockouts, poison and low-HP triggers, exact chance boundaries, contact/Substitute rules and Ancient's native wild/capture/capsule/PC/daycare/save paths. Saved struct lengths, absolute nature scratch addresses and the stack boundary remain unchanged. A complete manual playthrough has not been performed.
