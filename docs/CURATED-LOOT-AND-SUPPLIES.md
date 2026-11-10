# Curated visible loot and new supplies

Ability Capsules and Nature Capsules cost ¥30,000 each; First Aid costs ¥10,000. All three are sold by the existing post–Elite Four Celadon third-floor vendor. Bag names are ABILITY CAP, NATURE CAP and FIRST AID.

- Ability Capsule: rerolls a different ability slot, preserving nature. Only species with implemented abilities are eligible (currently the standard Bulbasaur, Charmander and Squirtle families, plus the Caterpie and Weedle evolution lines). Equal odds among the other four slots.
- Nature Capsule: rerolls a different nature, preserving ability slot, DVs, stat experience, moves, PP and status. Recalculates stats and preserves missing HP, with at least 1 HP for a living Pokémon; never revives.
- First Aid: outside battle, heals every living party member by half its own maximum HP, rounded down (minimum 1), capped at maximum. Does not revive or cure status. Consumed only if someone heals.
- All three are consumable, outside-battle items. Cancelled/failed uses consume nothing.

## Pickup rules

Visible item balls only. Hidden items, gifts, rewards, shops, HMs, quest items, fossils, evolution stones and other unlisted items retain their original rewards. Each listed pool includes its original item. A location uses a deterministic hash of the saved Trainer ID, map and sprite index, with no game RNG consumed and no new save fields. Leaving, reloading or retrying with a full bag does not reroll. Uncollected items may change if a future patch changes the pools.

Only premium pickups in the following late areas can yield the new rare items: VICTORY_ROAD_1, VICTORY_ROAD_2, VICTORY_ROAD_3, MANSION_1, MANSION_2, MANSION_3, MANSION_4, UNKNOWN_DUNGEON_1, UNKNOWN_DUNGEON_2, UNKNOWN_DUNGEON_3, POWER_PLANT. Eligible originals: RARE_CANDY, MAX_ELIXER, MAX_POTION, FULL_RESTORE, PP_UP, MAX_REVIVE. For each such pickup: original 10/16, First Aid 4/16, Nature Capsule 1/16, Ability Capsule 1/16. These are per-location probabilities across Trainer IDs; a save need not contain every rare drop. All three have guaranteed postgame shop access.

TM replacements retain type, damaging/status role and comparable power (within 20) and accuracy (within 25). Status and fixed-damage moves also retain the same effect. Selection uses hash modulo pool size, so non-power-of-two pool weights differ by at most one of 256 hash values. Existing TM compatibility is unchanged.

## Pools

| Original | Possible replacements (weights) |
|---|---|
| POTION | POTION ×3, ANTIDOTE, PARLYZ_HEAL, AWAKENING, BURN_HEAL, POKE_BALL |
| POKE_BALL | POKE_BALL ×4, POTION ×2, ANTIDOTE ×2 |
| SUPER_POTION | SUPER_POTION ×4, FULL_HEAL ×2, GREAT_BALL ×2 |
| HYPER_POTION | HYPER_POTION ×4, FULL_HEAL ×2, ULTRA_BALL ×2 |
| MAX_POTION | MAX_POTION ×4, HYPER_POTION ×2, FULL_RESTORE ×2 |
| FULL_RESTORE | FULL_RESTORE ×4, MAX_POTION ×2, MAX_REVIVE ×2 |
| REVIVE | REVIVE ×4, HYPER_POTION ×2, ULTRA_BALL ×2 |
| MAX_REVIVE | MAX_REVIVE ×4, FULL_RESTORE ×2, MAX_POTION ×2 |
| GREAT_BALL | GREAT_BALL ×4, SUPER_POTION ×2, REVIVE ×2 |
| ULTRA_BALL | ULTRA_BALL ×4, HYPER_POTION ×2, FULL_HEAL ×2 |
| REPEL | REPEL ×4, ESCAPE_ROPE ×2, SUPER_REPEL ×2 |
| SUPER_REPEL | SUPER_REPEL ×4, MAX_REPEL ×2, ESCAPE_ROPE ×2 |
| MAX_REPEL | MAX_REPEL ×4, SUPER_REPEL ×2, ESCAPE_ROPE ×2 |
| ESCAPE_ROPE | ESCAPE_ROPE ×4, REPEL ×2, SUPER_REPEL ×2 |
| ETHER | ETHER ×4, MAX_ETHER ×2, ELIXER ×2 |
| MAX_ETHER | MAX_ETHER ×4, ETHER ×2, ELIXER ×2 |
| ELIXER | ELIXER ×4, MAX_ETHER ×2, MAX_ELIXER ×2 |
| MAX_ELIXER | MAX_ELIXER ×4, ELIXER ×2, MAX_ETHER ×2 |
| ANTIDOTE | ANTIDOTE ×4, PARLYZ_HEAL, AWAKENING, BURN_HEAL, ICE_HEAL |
| PARLYZ_HEAL | PARLYZ_HEAL ×4, ANTIDOTE, AWAKENING, BURN_HEAL, ICE_HEAL |
| AWAKENING | AWAKENING ×4, ANTIDOTE, PARLYZ_HEAL, BURN_HEAL, ICE_HEAL |
| BURN_HEAL | BURN_HEAL ×4, ANTIDOTE, PARLYZ_HEAL, AWAKENING, ICE_HEAL |
| ICE_HEAL | ICE_HEAL ×4, ANTIDOTE, PARLYZ_HEAL, AWAKENING, BURN_HEAL |
| HP_UP | HP_UP ×4, PROTEIN, IRON, CARBOS, CALCIUM |
| PROTEIN | PROTEIN ×4, HP_UP, IRON, CARBOS, CALCIUM |
| IRON | IRON ×4, HP_UP, PROTEIN, CARBOS, CALCIUM |
| CARBOS | CARBOS ×4, HP_UP, PROTEIN, IRON, CALCIUM |
| CALCIUM | CALCIUM ×4, HP_UP, PROTEIN, IRON, CARBOS |
| TM_01 (MEGA_PUNCH) | TM_01 (MEGA_PUNCH), TM_17 (SUBMISSION) |
| TM_02 (RAZOR_WIND) | TM_02 (RAZOR_WIND) |
| TM_03 (SWORDS_DANCE) | TM_03 (SWORDS_DANCE) |
| TM_04 (WHIRLWIND) | TM_04 (WHIRLWIND) |
| TM_05 (MEGA_KICK) | TM_05 (MEGA_KICK), TM_17 (SUBMISSION) |
| TM_06 (TOXIC) | TM_06 (TOXIC) |
| TM_07 (HORN_DRILL) | TM_07 (HORN_DRILL) |
| TM_08 (BODY_SLAM) | TM_08 (BODY_SLAM), TM_09 (TAKE_DOWN), TM_10 (DOUBLE_EDGE), TM_37 (EGG_BOMB), TM_39 (SWIFT), TM_49 (TRI_ATTACK), TM_52 (FACADE) |
| TM_09 (TAKE_DOWN) | TM_08 (BODY_SLAM), TM_09 (TAKE_DOWN), TM_16 (PAY_DAY), TM_39 (SWIFT), TM_49 (TRI_ATTACK), TM_52 (FACADE) |
| TM_10 (DOUBLE_EDGE) | TM_08 (BODY_SLAM), TM_10 (DOUBLE_EDGE), TM_37 (EGG_BOMB), TM_49 (TRI_ATTACK) |
| TM_11 (BUBBLEBEAM) | TM_11 (BUBBLEBEAM), TM_12 (WATER_GUN), TM_53 (BRINE), TM_59 (SCALD) |
| TM_12 (WATER_GUN) | TM_11 (BUBBLEBEAM), TM_12 (WATER_GUN), TM_53 (BRINE), TM_59 (SCALD) |
| TM_13 (ICE_BEAM) | TM_13 (ICE_BEAM), TM_14 (BLIZZARD) |
| TM_14 (BLIZZARD) | TM_13 (ICE_BEAM), TM_14 (BLIZZARD) |
| TM_15 (HYPER_BEAM) | TM_15 (HYPER_BEAM) |
| TM_16 (PAY_DAY) | TM_09 (TAKE_DOWN), TM_16 (PAY_DAY), TM_39 (SWIFT), TM_52 (FACADE) |
| TM_17 (SUBMISSION) | TM_01 (MEGA_PUNCH), TM_05 (MEGA_KICK), TM_17 (SUBMISSION) |
| TM_18 (COUNTER) | TM_18 (COUNTER) |
| TM_19 (SEISMIC_TOSS) | TM_19 (SEISMIC_TOSS) |
| TM_20 (RAGE) | TM_20 (RAGE), TM_52 (FACADE) |
| TM_21 (MEGA_DRAIN) | TM_21 (MEGA_DRAIN) |
| TM_22 (SOLARBEAM) | TM_22 (SOLARBEAM) |
| TM_23 (DRAGON_RAGE) | TM_23 (DRAGON_RAGE) |
| TM_24 (THUNDERBOLT) | TM_24 (THUNDERBOLT) |
| TM_25 (THUNDER) | TM_25 (THUNDER) |
| TM_26 (EARTHQUAKE) | TM_26 (EARTHQUAKE), TM_28 (DIG) |
| TM_27 (FISSURE) | TM_27 (FISSURE) |
| TM_28 (DIG) | TM_26 (EARTHQUAKE), TM_28 (DIG) |
| TM_29 (PSYCHIC_M) | TM_29 (PSYCHIC_M), TM_42 (DREAM_EATER) |
| TM_30 (TELEPORT) | TM_30 (TELEPORT) |
| TM_31 (MIMIC) | TM_31 (MIMIC) |
| TM_32 (DOUBLE_TEAM) | TM_32 (DOUBLE_TEAM) |
| TM_33 (REFLECT) | TM_33 (REFLECT) |
| TM_34 (BIDE) | TM_34 (BIDE) |
| TM_35 (METRONOME) | TM_35 (METRONOME) |
| TM_36 (SELFDESTRUCT) | TM_36 (SELFDESTRUCT) |
| TM_37 (EGG_BOMB) | TM_08 (BODY_SLAM), TM_10 (DOUBLE_EDGE), TM_37 (EGG_BOMB), TM_49 (TRI_ATTACK) |
| TM_38 (FIRE_BLAST) | TM_38 (FIRE_BLAST) |
| TM_39 (SWIFT) | TM_08 (BODY_SLAM), TM_09 (TAKE_DOWN), TM_16 (PAY_DAY), TM_39 (SWIFT), TM_49 (TRI_ATTACK), TM_52 (FACADE) |
| TM_40 (SKULL_BASH) | TM_40 (SKULL_BASH) |
| TM_41 (SOFTBOILED) | TM_41 (SOFTBOILED) |
| TM_42 (DREAM_EATER) | TM_29 (PSYCHIC_M), TM_42 (DREAM_EATER) |
| TM_43 (SKY_ATTACK) | TM_43 (SKY_ATTACK) |
| TM_44 (REST) | TM_44 (REST) |
| TM_45 (THUNDER_WAVE) | TM_45 (THUNDER_WAVE) |
| TM_46 (PSYWAVE) | TM_46 (PSYWAVE) |
| TM_47 (EXPLOSION) | TM_47 (EXPLOSION) |
| TM_48 (ROCK_SLIDE) | TM_48 (ROCK_SLIDE), TM_57 (ROCK_TOMB) |
| TM_49 (TRI_ATTACK) | TM_08 (BODY_SLAM), TM_09 (TAKE_DOWN), TM_10 (DOUBLE_EDGE), TM_37 (EGG_BOMB), TM_39 (SWIFT), TM_49 (TRI_ATTACK), TM_52 (FACADE) |
| TM_50 (SUBSTITUTE) | TM_50 (SUBSTITUTE) |
| TM_51 (ROOST) | TM_51 (ROOST) |
| TM_52 (FACADE) | TM_08 (BODY_SLAM), TM_09 (TAKE_DOWN), TM_16 (PAY_DAY), TM_20 (RAGE), TM_39 (SWIFT), TM_49 (TRI_ATTACK), TM_52 (FACADE) |
| TM_53 (BRINE) | TM_11 (BUBBLEBEAM), TM_12 (WATER_GUN), TM_53 (BRINE), TM_59 (SCALD) |
| TM_54 (VENOSHOCK) | TM_54 (VENOSHOCK), TM_62 (POISON_TAIL) |
| TM_55 (AERIAL_ACE) | TM_55 (AERIAL_ACE) |
| TM_56 (BULK_UP) | TM_56 (BULK_UP) |
| TM_57 (ROCK_TOMB) | TM_48 (ROCK_SLIDE), TM_57 (ROCK_TOMB) |
| TM_58 (WILL_O_WISP) | TM_58 (WILL_O_WISP) |
| TM_59 (SCALD) | TM_11 (BUBBLEBEAM), TM_12 (WATER_GUN), TM_53 (BRINE), TM_59 (SCALD) |
| TM_60 (CURSE) | TM_60 (CURSE) |
| TM_61 (LEECH_LIFE) | TM_61 (LEECH_LIFE) |
| TM_62 (POISON_TAIL) | TM_54 (VENOSHOCK), TM_62 (POISON_TAIL) |
| TM_63 (AGILITY) | TM_63 (AGILITY) |

## Visible pickup sites

| Map | Object | Original | Pool |
|---|---:|---|---|
| FUCHSIA_HOUSE_2 | 2 | RARE_CANDY | Fixed |
| MANSION_1 | 2 | ESCAPE_ROPE | Curated |
| MANSION_1 | 3 | CARBOS | Curated |
| MANSION_2 | 2 | CALCIUM | Curated |
| MANSION_3 | 3 | MAX_POTION | Late premium (10/4/1/1) |
| MANSION_3 | 4 | IRON | Curated |
| MANSION_4 | 3 | RARE_CANDY | Late premium (10/4/1/1) |
| MANSION_4 | 4 | FULL_RESTORE | Late premium (10/4/1/1) |
| MANSION_4 | 5 | TM_14 | Curated |
| MANSION_4 | 6 | TM_22 | Fixed |
| MANSION_4 | 8 | SECRET_KEY | Fixed |
| MT_MOON_1 | 8 | POTION | Curated |
| MT_MOON_1 | 9 | MOON_STONE | Fixed |
| MT_MOON_1 | 10 | RARE_CANDY | Fixed |
| MT_MOON_1 | 11 | ESCAPE_ROPE | Curated |
| MT_MOON_1 | 12 | POTION | Curated |
| MT_MOON_1 | 13 | TM_12 | Curated |
| MT_MOON_3 | 8 | HP_UP | Curated |
| MT_MOON_3 | 9 | TM_01 | Curated |
| POKEMONTOWER_3 | 4 | ESCAPE_ROPE | Curated |
| POKEMONTOWER_4 | 4 | ELIXER | Curated |
| POKEMONTOWER_4 | 5 | AWAKENING | Curated |
| POKEMONTOWER_4 | 6 | HP_UP | Curated |
| POKEMONTOWER_5 | 6 | NUGGET | Fixed |
| POKEMONTOWER_6 | 4 | RARE_CANDY | Fixed |
| POKEMONTOWER_6 | 5 | X_ACCURACY | Fixed |
| POWER_PLANT | 10 | CARBOS | Curated |
| POWER_PLANT | 11 | HP_UP | Curated |
| POWER_PLANT | 12 | RARE_CANDY | Late premium (10/4/1/1) |
| POWER_PLANT | 13 | TM_25 | Fixed |
| POWER_PLANT | 14 | TM_33 | Fixed |
| ROCKET_HIDEOUT_1 | 6 | ESCAPE_ROPE | Curated |
| ROCKET_HIDEOUT_1 | 7 | HYPER_POTION | Curated |
| ROCKET_HIDEOUT_2 | 2 | MOON_STONE | Fixed |
| ROCKET_HIDEOUT_2 | 3 | NUGGET | Fixed |
| ROCKET_HIDEOUT_2 | 4 | TM_07 | Fixed |
| ROCKET_HIDEOUT_2 | 5 | SUPER_POTION | Curated |
| ROCKET_HIDEOUT_3 | 3 | TM_10 | Curated |
| ROCKET_HIDEOUT_3 | 4 | RARE_CANDY | Fixed |
| ROCKET_HIDEOUT_4 | 5 | HP_UP | Curated |
| ROCKET_HIDEOUT_4 | 6 | TM_02 | Fixed |
| ROCKET_HIDEOUT_4 | 7 | IRON | Curated |
| ROCKET_HIDEOUT_4 | 8 | SILPH_SCOPE | Fixed |
| ROCKET_HIDEOUT_4 | 9 | LIFT_KEY | Fixed |
| ROUTE_12 | 9 | TM_16 | Curated |
| ROUTE_12 | 10 | IRON | Curated |
| ROUTE_15 | 11 | TM_20 | Curated |
| ROUTE_2 | 1 | MOON_STONE | Fixed |
| ROUTE_2 | 2 | HP_UP | Curated |
| ROUTE_24 | 8 | TM_45 | Fixed |
| ROUTE_25 | 10 | TM_19 | Fixed |
| ROUTE_4 | 3 | TM_04 | Fixed |
| ROUTE_9 | 10 | TM_30 | Fixed |
| SAFARI_ZONE_CENTER | 1 | NUGGET | Fixed |
| SAFARI_ZONE_EAST | 1 | FULL_RESTORE | Curated |
| SAFARI_ZONE_EAST | 2 | MAX_POTION | Curated |
| SAFARI_ZONE_EAST | 3 | CARBOS | Curated |
| SAFARI_ZONE_EAST | 4 | TM_37 | Curated |
| SAFARI_ZONE_NORTH | 1 | PROTEIN | Curated |
| SAFARI_ZONE_NORTH | 2 | TM_40 | Fixed |
| SAFARI_ZONE_WEST | 1 | MAX_POTION | Curated |
| SAFARI_ZONE_WEST | 2 | TM_32 | Fixed |
| SAFARI_ZONE_WEST | 3 | MAX_REVIVE | Curated |
| SAFARI_ZONE_WEST | 4 | GOLD_TEETH | Fixed |
| SILPH_CO_10F | 4 | TM_26 | Curated |
| SILPH_CO_10F | 5 | RARE_CANDY | Fixed |
| SILPH_CO_10F | 6 | CARBOS | Curated |
| SILPH_CO_3F | 4 | HYPER_POTION | Curated |
| SILPH_CO_4F | 5 | FULL_HEAL | Fixed |
| SILPH_CO_4F | 6 | MAX_REVIVE | Curated |
| SILPH_CO_4F | 7 | ESCAPE_ROPE | Curated |
| SILPH_CO_5F | 6 | TM_09 | Curated |
| SILPH_CO_5F | 7 | PROTEIN | Curated |
| SILPH_CO_5F | 8 | CARD_KEY | Fixed |
| SILPH_CO_6F | 9 | HP_UP | Curated |
| SILPH_CO_6F | 10 | X_ACCURACY | Fixed |
| SILPH_CO_7F | 10 | CALCIUM | Curated |
| SILPH_CO_7F | 11 | TM_03 | Fixed |
| SS_ANNE_10 | 9 | ETHER | Curated |
| SS_ANNE_10 | 10 | TM_44 | Fixed |
| SS_ANNE_10 | 11 | MAX_POTION | Curated |
| SS_ANNE_8 | 10 | TM_08 | Curated |
| SS_ANNE_9 | 6 | MAX_ETHER | Curated |
| SS_ANNE_9 | 9 | RARE_CANDY | Fixed |
| UNDERGROUND_PATH_WE | 2 | M_GENE | Fixed |
| UNKNOWN_DUNGEON_1 | 1 | FULL_RESTORE | Late premium (10/4/1/1) |
| UNKNOWN_DUNGEON_1 | 2 | MAX_ELIXER | Late premium (10/4/1/1) |
| UNKNOWN_DUNGEON_1 | 3 | NUGGET | Fixed |
| UNKNOWN_DUNGEON_2 | 1 | PP_UP | Late premium (10/4/1/1) |
| UNKNOWN_DUNGEON_2 | 2 | ULTRA_BALL | Curated |
| UNKNOWN_DUNGEON_2 | 3 | FULL_RESTORE | Late premium (10/4/1/1) |
| UNKNOWN_DUNGEON_3 | 2 | ULTRA_BALL | Curated |
| UNKNOWN_DUNGEON_3 | 3 | MAX_REVIVE | Late premium (10/4/1/1) |
| VICTORY_ROAD_1 | 3 | TM_43 | Fixed |
| VICTORY_ROAD_1 | 4 | RARE_CANDY | Late premium (10/4/1/1) |
| VICTORY_ROAD_2 | 7 | TM_17 | Curated |
| VICTORY_ROAD_2 | 8 | FULL_HEAL | Fixed |
| VICTORY_ROAD_2 | 9 | TM_05 | Curated |
| VICTORY_ROAD_2 | 10 | GUARD_SPEC | Fixed |
| VICTORY_ROAD_3 | 5 | MAX_REVIVE | Late premium (10/4/1/1) |
| VICTORY_ROAD_3 | 6 | TM_47 | Fixed |
| VIRIDIAN_FOREST | 5 | ANTIDOTE | Curated |
| VIRIDIAN_FOREST | 6 | POTION | Curated |
| VIRIDIAN_FOREST | 7 | POKE_BALL | Curated |
| VIRIDIAN_GYM | 11 | REVIVE | Curated |
