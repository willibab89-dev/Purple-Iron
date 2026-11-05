# Move overhaul — patch 5

Cumulative Red/Blue BPS patches: all prior front sprites, 21 new species and encounters, crit/freeze changes, and move patches 1–4 remain included. Adds 21 new moves with 165 level-up entries across 108 original species, and completes Counter, Egg Bomb, Psywave and Tri Attack. There are 212 move records. Existing IDs and TM/HM assignments remain unchanged. Variant species inherit their originals' learnset additions.

## Update and learning

Download `pokemon-move-patch-5-bps` from the successful Actions run. Apply the matching BPS to its verified unmodified original Red/Blue ROM, not to a previously patched ROM. Existing 172-species saves remain compatible; permanent party/box/save formats and existing field addresses are unchanged. Three bytes of previously unused transient battle scratch now track Counter, outside saved data and below the unchanged stack boundary. Old 151-species saves remain incompatible. Back up saves and heal at a Pokemon Center after updating to refresh PP. Link battles require identical ROM revisions.

Existing Pokemon keep their moves. For eligible missed learning levels, use Shin's relearner in the Saffron house below Copycat's house, subject to its existing requirements/cost. Original learning entries, levels and evolutions remain intact. Generated wild/trainer movesets use expanded learnsets; explicit trainer move overrides remain in effect.

## Existing moves completed

| Move | Final stats | Change |
| --- | --- | --- |
| Counter | Fighting / 1 table power / 100 accuracy / 20 PP | Fixed retaliation for twice the last physical HP damage received this turn. See exact rules below. |
| Egg Bomb | Normal / 100 power / 75 accuracy / 10 PP | An eligible hit ignores its applicable protective screen and removes both target screens. |
| Psywave | Psychic / variable fixed damage / 100 accuracy / 15 PP | Requested accuracy change. Retains Shin's positive random damage formula, with a safe level-one minimum range. |
| Tri Attack | Normal / 80 power / 100 accuracy / 10 PP | About 20% chance of one burn, freeze or paralysis. |

Counter uses a separate record of actual incoming HP damage, not shared damage-calculation scratch or the opponent's menu selection. Physical means the existing Gen 1 type category (types below Fire, including typeless Struggle). Special attacks, Counter itself, Substitute-only damage, recoil/crash, self-confusion and residual damage do not supply a record. For multihit attacks it uses the last HP-damaging strike, not the sum. Fixed-damage attacks that run through the physical attack path (such as Seismic Toss) qualify. Damage is measured after HP capping. The record resets each turn, at battle initialization and on active-mon data loading. Counter fails without a matching record, and retains Fighting's Ghost immunity and normal accuracy/invulnerability checks. Its fixed retaliation does not receive STAB, effectiveness multipliers, burn penalties or critical hits.

Psywave still rolls positive damage below floor(1.5 × user level), as Shin did on both sides. The exclusive upper bound is now at least 2, so level one deals 1 damage instead of looping forever. No modern Psywave curve is substituted. It retains ordinary type immunity behavior and cannot crit.

## New moves

Gen 1 type-based physical/special categories remain. Self-directed status moves do not roll accuracy. Guaranteed stat changes happen after an eligible hit; target stat drops respect Mist and Substitute. Positive-stage resets are resets, so they ignore Mist, but a hit on Substitute does not reset its owner's stages.

| ID | Move | Type | Power | Accuracy | PP | Effect | Reused animation |
| ---: | --- | --- | ---: | ---: | ---: | --- | --- |
| 192 | TONGUE LASH | Normal | 60 | 100 | 15 | Target Special −1 on hit. | Lick |
| 193 | STOCKPILE | Normal | — | — | 10 | User Defense +1 / Special +1; ordinary stage caps, no separate stockpile counter. | Harden |
| 194 | LUNGE | Bug | 40 | 100 | 15 | Target Attack −1 on hit. | Leech Life |
| 195 | SHELL BREAK | Bug | 40 | 100 | 15 | Target Defense −1 on hit. | Vicegrip |
| 196 | WAILING CRY | Ghost | 40 | 100 | 15 | Target Special −1 on hit; calculated Ghost damage, not fixed Night Shade damage. | Night Shade |
| 197 | PSYCH UP | Psychic | — | — | 10 | Copy all six target stages, replacing own positive/negative stages. | Meditate |
| 198 | MIND BREAK | Psychic | 50 | 100 | 10 | After damage, reset positive target Special stages to neutral. | Psychic M |
| 199 | BULK UP | Fighting | — | — | 10 | User Attack +1 / Defense +1. | Meditate |
| 200 | BRICK BREAK | Fighting | 70 | 100 | 15 | Ignore applicable screen for an eligible hit and remove both target screens on hit. | Karate Chop |
| 201 | ROCK TOMB | Rock | 50 | 95 | 15 | Target Speed −1 on hit. | Rock Throw |
| 202 | WILL-O-WISP | Fire | — | 85 | 15 | Inflict burn. | Ember |
| 203 | FLAME CHARGE | Fire | 40 | 100 | 20 | User Speed +1 after a successful hit, including KO/Substitute. | Ember |
| 204 | CAUTERIZE | Fire | — | — | 10 | Heal one quarter maximum HP and clear own major status; can be wasted at full HP. | Recover |
| 205 | SCALD | Water | 40 | 100 | 15 | About 30% burn chance. | Bubblebeam |
| 206 | CHARGE | Electric | — | — | 10 | User Special +1 / accuracy +1; no extra next-attack bonus. | Focus Energy |
| 207 | ICY WIND | Ice | 40 | 100 | 15 | Target Speed −1 on hit. | Aurora Beam |
| 208 | FLASH FREEZE | Ice | — | 40 | 5 | Inflict freeze. | Ice Beam |
| 209 | GALE WIND | Flying | 50 | 100 | 15 | After damage, reset positive target evasion stages to neutral. | Gust |
| 210 | COIL | Poison | — | — | 10 | User Attack +1 / Defense +1 / accuracy +1. | Defense Curl |
| 211 | POISON FANG | Poison | 50 | 100 | 15 | About 20% badly poison; upgrades normal poison. | Bite |
| 212 | DRAGON DANCE | Dragon | — | — | 10 | User Attack +1 / Speed +1. | Agility |

## Effect details

- Tri Attack uses one 51/256 (~20%) gate followed by one uniform three-way choice. Only one ailment can be inflicted; a blocked selection is not rerolled. Scald uses 77/256 (~30%); Poison Fang uses 51/256 (~20%). Existing moves' old chance routines are unchanged.
- New ailment handlers use the ailment's natural type immunity: Fire is immune to burn, Ice to freeze, Electric to paralysis, and Poison to poison. They do not inherit old attacking-type quirks such as Body Slam's Normal-type paralysis restriction; those old moves are unchanged. Any existing major status blocks a new one except Poison Fang's explicit ordinary-poison upgrade. Poison Fang does not reset an already bad-poisoned target's counter. Battle and party status/HP are synchronized; wild enemies have no trainer-party writes.
- Burn/paralysis stat penalties are rebuilt from underlying stats/stages once. Freeze clears target Hyper Beam recharge as Shin does; the existing exact 20% natural-thaw system remains. Scald and Will-O-Wisp do not gain an unrequested thawing effect.
- Cauterize heals floor(max HP / 4), minimum one, capped at full HP. Clears sleep, poison/Toxic, burn, freeze and paralysis, including Toxic's flag/counter and status stat penalties. Preserves stages and volatile effects such as confusion, Leech Seed, screens and Focus Energy. Full HP/no status still consumes its normal turn and PP; it does not bypass the usual inability to act while asleep/frozen.
- Psych Up copies all six stages, including negative ones, without copying stats, status, screens or other counters. It skips accuracy/evasion and can copy through Substitute/Mist because it changes the user. It fails against Fly/Dig invulnerability or identical stages. Coil and the two-stat boosts clamp each component independently; one capped stat does not block the rest.
- Flame Charge's self boost still occurs after a knockout or a Substitute hit, including a broken Substitute; no boost on a miss/immunity. Egg Bomb/Brick Break leave screens intact on misses and Substitute hits. Their eligible damage ignores the screen immediately; screen flags are removed as the hit's secondary effect. Mind Break/Gale Wind clear positive stages after damage and preserve negative stages.
- All moves use the existing animation map. New IDs above the old HM item boundary retain correct move names. Metronome can select all complete additions and still excludes itself, Struggle, zero and invalid IDs. AI rejects wholly capped/useless utility moves, handles Cauterize's full-health/status distinction, and recognizes all physical types for Counter prediction. Its broader combo/switching heuristics remain approximate.

## Learnsets

Additions only. If a proposed level was occupied, the new entry uses the next free level. No original entry or evolution is replaced.

| Pokemon | Added moves and levels |
| --- | --- |
| Abra | Psych Up 30 |
| Aerodactyl | Gale Wind 46 |
| Alakazam | Psych Up 39, Mind Break 40 |
| Arbok | Coil 28, Poison Fang 38 |
| Arcanine | Flame Charge 26, Will O Wisp 28, Cauterize 41 |
| Articuno | Icy Wind 25, Gale Wind 48, Flash Freeze 56 |
| Beedrill | Lunge 28 |
| Blastoise | Scald 43 |
| Charizard | Flame Charge 28, Cauterize 47, Dragon Dance 48 |
| Charmander | Flame Charge 20 |
| Charmeleon | Flame Charge 25 |
| Cloyster | Icy Wind 24, Flash Freeze 48 |
| Cubone | Wailing Cry 24 |
| Dewgong | Icy Wind 24, Flash Freeze 48 |
| Dodrio | Gale Wind 42 |
| Dragonair | Coil 34, Dragon Dance 40 |
| Dragonite | Coil 40, Dragon Dance 48 |
| Dratini | Coil 31, Dragon Dance 36 |
| Drowzee | Psych Up 30, Mind Break 34 |
| Ekans | Coil 25, Poison Fang 34 |
| Electabuzz | Charge 24 |
| Electrode | Charge 26 |
| Exeggcute | Mind Break 36 |
| Exeggutor | Mind Break 40 |
| Farfetchd | Gale Wind 38 |
| Fearow | Gale Wind 40 |
| Flareon | Flame Charge 24, Will O Wisp 26, Cauterize 38 |
| Gastly | Wailing Cry 26, Will O Wisp 30 |
| Gengar | Wailing Cry 34, Will O Wisp 39 |
| Geodude | Rock Tomb 18 |
| Golbat | Poison Fang 38 |
| Golduck | Scald 32 |
| Golem | Rock Tomb 27 |
| Graveler | Rock Tomb 22 |
| Grimer | Stockpile 26 |
| Growlithe | Flame Charge 22, Will O Wisp 24, Cauterize 36 |
| Gyarados | Dragon Dance 42 |
| Haunter | Wailing Cry 30, Will O Wisp 34 |
| Hitmonchan | Bulk Up 28, Brick Break 42 |
| Hitmonlee | Bulk Up 28, Brick Break 42 |
| Hypno | Psych Up 34, Mind Break 38 |
| Jolteon | Charge 24 |
| Jynx | Icy Wind 22, Mind Break 36, Flash Freeze 48 |
| Kabuto | Rock Tomb 24, Shell Break 29 |
| Kabutops | Rock Tomb 28, Shell Break 33 |
| Kadabra | Psych Up 34, Mind Break 36 |
| Kangaskhan | Brick Break 42 |
| Kingler | Shell Break 32 |
| Koffing | Stockpile 26 |
| Krabby | Shell Break 28 |
| Lapras | Icy Wind 21, Scald 34, Dragon Dance 44, Flash Freeze 48 |
| Lickitung | Stockpile 26, Tongue Lash 32 |
| Machamp | Bulk Up 32, Brick Break 45 |
| Machoke | Bulk Up 28, Brick Break 40 |
| Machop | Bulk Up 24, Brick Break 36 |
| Magmar | Flame Charge 24, Will O Wisp 26, Cauterize 38 |
| Magnemite | Charge 22 |
| Magneton | Charge 26 |
| Mankey | Bulk Up 24 |
| Marowak | Wailing Cry 28 |
| Mew | Psych Up 35 |
| Mewtwo | Psych Up 60, Mind Break 65 |
| Moltres | Will O Wisp 35, Gale Wind 48, Cauterize 52 |
| MrMime | Psych Up 36, Mind Break 38 |
| Muk | Stockpile 31 |
| Nidoking | Poison Fang 41 |
| Nidoqueen | Poison Fang 40 |
| Nidorina | Poison Fang 37 |
| Nidorino | Poison Fang 37 |
| Ninetales | Flame Charge 26, Will O Wisp 29, Cauterize 40 |
| Omanyte | Rock Tomb 24 |
| Omastar | Rock Tomb 28 |
| Onix | Rock Tomb 20, Coil 30 |
| Paras | Lunge 24, Shell Break 35 |
| Parasect | Lunge 28, Shell Break 38 |
| Pidgeot | Gale Wind 42 |
| Pidgeotto | Gale Wind 38 |
| Pikachu | Charge 22 |
| Pinsir | Lunge 28, Shell Break 37 |
| Poliwag | Scald 28 |
| Poliwhirl | Scald 32 |
| Poliwrath | Bulk Up 32, Scald 36, Brick Break 42 |
| Ponyta | Flame Charge 22, Will O Wisp 26 |
| Primeape | Bulk Up 29, Brick Break 40 |
| Psyduck | Scald 29 |
| Raichu | Charge 26 |
| Rapidash | Flame Charge 26, Will O Wisp 31 |
| Rhydon | Rock Tomb 31 |
| Rhyhorn | Rock Tomb 26 |
| Scyther | Lunge 28 |
| Seadra | Dragon Dance 44 |
| Seel | Icy Wind 20 |
| Shellder | Icy Wind 20 |
| Slowbro | Scald 32 |
| Slowpoke | Scald 28 |
| Snorlax | Stockpile 28 |
| Squirtle | Scald 34 |
| Tentacool | Coil 24 |
| Tentacruel | Coil 28 |
| Vaporeon | Scald 32 |
| Venomoth | Lunge 28 |
| Venonat | Lunge 25 |
| Voltorb | Charge 23 |
| Vulpix | Flame Charge 22, Will O Wisp 24, Cauterize 36 |
| Wartortle | Scald 38 |
| Weezing | Stockpile 30 |
| Zapdos | Charge 35, Gale Wind 48 |
| Zubat | Poison Fang 34 |

## Validation

Both ROMs build and run all existing species, encounter, save/load, crit, freeze and move suites. Tests cover all 212 records/names/animation mappings and all Metronome candidate bytes; independent stage caps, resets, screens and Substitute; exhaustive chance gates and single-status selection; poison upgrades and Toxic preservation; typed/status immunity and wild-party guards; exact quarter healing, stage/status preservation and full-health PP spending; Psych Up; physical Counter recording via actual attacks, special attacks, Substitute, HP capping, stale shared scratch and overflow; Psywave at level one; all 165 learning entries through generation/daycare PP and relearner routines; high-ID party save/load. Battle-path tests run both actor paths with presentation and controlled crit/random variation stubbed; these are automated engine checks, not a full manual playthrough. BPS packages must reproduce each built ROM byte for byte when applied to verified originals.

## Remaining work

**10 existing redesigns and 7 new moves remain.**

Existing: Bide, Fire Spin, Fury Swipes, Rage, Razor Wind, Roar, Skull Bash, Transform, Whirlwind, Wrap.

New: Ingrain, Ambush, Curse, Shadow Leech, Aqua Jet, Thunderclap, Icicle Spear.

Next: turn sequences and priority/multihit mechanics. Custom trapping/residuals, forced switching and automatic transformation remain for the final focused group. No incomplete moves are inserted as placeholders.
