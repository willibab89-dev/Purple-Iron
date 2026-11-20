# Pending abilities: Pidgey through Sandshrew

These are requested designs; implementation status is noted below. Each line is a five-slot pool, in the order given. Strike-through formatting in the source request was explicitly to be ignored.

## Pidgey / Pidgeotto / Pidgeot (implemented)

1. Tailwind: Raise Speed by one stage on entering battle.
2. Predator: Physical moves deal 20% more damage against slower targets.
3. Keen Eye: Prevent Accuracy from being lowered.
4. Piercing Beak: Flying attacks ignore 25% of the target's Defense.
5. Gale Wings: Flying moves gain +1 priority at full HP.

## Rattata / Raticate (implemented)

1. Scavenger: Restore 25% maximum HP after knocking out an opponent.
2. Strong Jaw: Physical moves deal 15% more damage.
3. Cornered: Raise Attack by one stage when HP falls below one third, once per battle.
4. Hustle: Physical attacks deal 25% more damage but lose 15 accuracy points.
5. Poison Heal: Restore 1/8 maximum HP each turn while poisoned instead of taking poison damage.

## Spearow / Fearow (implemented)

1. Ruthless: Double critical-hit chance against targets with a major status condition.
2. Short Temper: Raise Attack by one stage when one of its moves misses.
3. Relentless: Consecutive damaging attacks against the same target deal 10% more damage per successful hit, up to 30%; reset on switching targets or using a non-damaging move.
4. Piercing Beak: Flying attacks ignore 25% of the target's Defense.
5. Sniper: Critical hits deal 50% more damage.

## Ekans / Arbok (implemented)

1. Intimidate: Lower the opponent's Speed by one stage on entering battle, once per Pokémon; does not stack.
2. Shed Skin: 30% chance to cure a major status condition at the end of each turn.
3. Venomous: Deal 25% more damage against poisoned targets.
4. Predator: Physical moves deal 20% more damage against slower targets.
5. Corrosive Venom: Poison attacks are super effective against Rock types.

## Pikachu / Raichu (implemented)

1. Static: Physical attacks have a 20% chance to paralyze the attacker.
2. Voltage: Electric moves deal 20% more damage against paralyzed targets.
3. Overcharge: Raise Special by one stage after landing a critical hit, once per battle.
4. Quick Reflexes: First attack after entering battle gains +1 priority.
5. Quick Feet: Raise Speed by one stage when affected by a major status condition.

## Sandshrew (implemented)

1. Rolling Defense: Raise Defense by one stage after using a Normal move, once per battle.
2. Sand Armor: Reduce super-effective damage by 25%.
3. Burrower: Restore 1/8 maximum HP after using a Ground move.
4. Sharp Claws: Multiply physical attacks' critical-hit chance by 1.5.
5. Sand Veil: Raise Evasion by one stage after using a Ground move, once per battle.

## Sandslash (implemented)

1. Spiny Armor: Physical attackers lose 1/16 of their maximum HP when hitting the holder.
2. Sand Armor: Reduce super-effective damage by 25%.
3. Burrower: Restore 1/8 maximum HP after using a Ground move.
4. Sharp Claws: Multiply physical attacks' critical-hit chance by 1.5.
5. Sand Veil: Raise Evasion by one stage after using a Ground move, once per battle.

## Implementation notes

The Pidgey through Pikachu families are implemented as marked above. Quick Reflexes applies to the first attempted **damaging** move after entry. Static applies to all physical attacks, including ranged moves. Intimidate is once per holder and target per battle. Relentless resets its hit count when either combatant switches or its holder uses a non-damaging move. The Sandshrew and Sandslash pools are also implemented.
