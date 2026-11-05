# Move overhaul — patch 4

Cumulative Red/Blue BPS patches: all previous front sprites, 21 new species and encounters, crit/freeze updates, and move patches 1–3 remain included. This patch completes five existing move redesigns and adds 16 moves with 154 level-up entries across 106 original species. There are 191 move records; existing IDs remain unchanged, including Struggle at 165. Variant species inherit their originals' learnsets.

## Update and learning

Download `pokemon-move-patch-4-bps` from the successful Actions run. Apply the matching BPS to its verified unmodified original Red/Blue ROM, not an already patched ROM. Existing 172-species saves retain their layout; no permanent save or WRAM layout fields changed. Old 151-species saves remain incompatible. Back up your save and heal at a Pokemon Center after updating to refresh PP. Link battles require identical ROM revisions.

Existing Pokemon keep their current moves. Eligible missed level-up moves can be learned from Shin's move relearner in Saffron, in the house below Copycat's house, subject to its existing cost/requirements. Existing level-up entries and all TM/HM assignments are retained. Wild/trainer generated movesets use expanded learnsets; explicit trainer move overrides remain in effect.

## Existing moves completed

| Move | Final stats | Behavior |
| --- | --- | --- |
| Stomp | 65 power / 100 accuracy / 20 PP | Double power against confusion; retains its ~30% flinch effect. |
| Take Down | 60 power / 85 accuracy / 20 PP | Double power against targets strictly below half HP; retains quarter-damage recoil. |
| Thunder | 100 power / 70 accuracy / 10 PP | Bypasses accuracy/evasion against a target with any major status; retains its existing paralysis chance. Respects immunity/invulnerability. |
| Drill Peck | 80 power / 100 accuracy / 15 PP | Ignores positive target Defense stages. |
| Waterfall | 70 power / 100 accuracy / 15 PP | Ignores positive target Special stages. |

“Double damage” conditions use the usual double-base-power calculation, before the normal damage formula, STAB, type effectiveness and random variation. The formula's constant term and rounding mean final HP damage is not always exactly twice the ordinary roll. Conditions are read when the attack executes, not when it is selected. Take Down uses strictly below half; Brine includes exactly half.

## New moves

Gen 1 type-based physical/special categories remain: Normal/Ghost/Poison/Fighting/Rock/Flying are physical; Water/Fire/Electric/Ice/Psychic are special. Psyshock is a special Psychic attack using the target's Defense. Stone Press is a physical Rock attack using the user's Defense.

| ID | Move | Type | Power | Accuracy | PP | Effect | Animation |
| ---: | --- | --- | ---: | ---: | ---: | --- | --- |
| 176 | FACADE | Normal | 60 | 100 | 20 | Double power with a major status; ignores burn's Attack penalty. | Body Slam |
| 177 | FLAIL | Normal | 20–200 | 100 | 15 | 20–200 power using the agreed later-generation HP curve. | Thrash |
| 178 | BRINE | Water | 50 | 100 | 10 | Double power when target HP is at or below half. | Bubblebeam |
| 179 | INCINERATE | Fire | 50 | 100 | 10 | Double power against a burned target. | Ember |
| 180 | VENOSHOCK | Poison | 50 | 100 | 10 | Double power against a poisoned/badly poisoned target. | Sludge |
| 181 | POLLUTION | Poison | 40 | 95 | 10 | Double power against either Water typing. | Smog |
| 182 | PUNISHMENT | Ghost | 40–160 | 100 | 10 | 40 + 20 per positive target stage, capped at 160; counts all six stages. | Night Shade |
| 183 | SHOCK WAVE | Electric | 40 | 100 | 10 | Guaranteed critical hit against a paralyzed target. | Thundershock |
| 184 | POISON TAIL | Poison | 40 | 100 | 25 | Guaranteed critical hit against a poisoned/badly poisoned target. | Poison Sting |
| 185 | FROST BREATH | Ice | 60 | 100 | 15 | Guaranteed critical hit against a target with a negative Speed stage; paralysis alone does not qualify. | Aurora Beam |
| 186 | ICE SHARD | Ice | 50 | 100 | 20 | Double power against a frozen target; does not thaw it. No priority added. | Ice Beam |
| 187 | PIERCE | Fighting | 70 | 100 | 15 | Ignores positive target Defense stages. | Horn Attack |
| 188 | STONE PRESS | Rock | 50 | 100 | 10 | User Defense versus target Defense, instead of user Attack. | Rock Throw |
| 189 | PSYSHOCK | Psychic | 60 | 100 | 15 | User Special versus target Defense. | Psybeam |
| 190 | SNIPE SHOT | Water | 70 | 100 | 10 | Bypasses accuracy/evasion; respects immunity and Fly/Dig invulnerability. | Water Gun |
| 191 | AERIAL ACE | Flying | 60 | 100 | 15 | Bypasses accuracy/evasion; respects immunity and Fly/Dig invulnerability. | Wing Attack |

## Stat, screen and critical-hit rules

- Preserve Shin's Gen 1 crit rules: ignore both actors' stages, badge/status stat modifiers and defensive screens, and use the existing critical-hit damage calculation. Guaranteed crits still respect move accuracy, immunity and invulnerability. When their condition is absent, these moves retain ordinary crit chances and Focus Energy/Dire Hit interactions.
- Stone Press uses Defense stages and Defense's badge bonus on ordinary hits. Attack stages, burn's Attack penalty, and Reflect on the user do not strengthen/weaken its offensive stat. Its crit uses unmodified Defense, so a crit does not preserve its Defense boosts.
- Psyshock uses the user's Special and target Defense. Reflect protects against it; Light Screen does not. Its crit uses unmodified Special/Defense. Burn does not reduce Special-based offense.
- Drill Peck/Pierce/Waterfall remove only positive stages from their relevant target stat. Negative stages, ordinary badge bonuses and applicable screens still count. Crits separately follow the Gen 1 rule above.
- Facade reconstructs Attack from the underlying stat and stage, preserving the ordinary badge rules, without modifying stored Attack or doubling an already-rounded burned value. Its conditional power bonus still applies on a crit, but the crit ignores stat stages/badges as usual.
- Flail uses `r = max(1, floor(48 * current HP / maximum HP))`: r < 2 → 200; < 5 → 150; < 10 → 100; < 17 → 80; < 33 → 40; otherwise 20. Uses full-width HP arithmetic. Its ROM table contains a nonzero placeholder power, never a fixed-damage effect; real damage uses the calculated power. No new special immunity or inability to crit is added.
- Punishment counts positive Attack, Defense, Speed, Special, accuracy and evasion stages independently. Negative stages do not cancel positive stages. Its cap is 160.
- Sleep/freeze still prevent acting under the normal rules. Adding a status-based power/accuracy condition does not let an incapacitated Pokemon act.

## Learnsets

Additions only. A new entry moves to the next free level where needed; old learning levels and evolutions are unchanged.

| Pokemon | Added moves and levels |
| --- | --- |
| Abra | Psyshock 24 |
| Aerodactyl | Aerial Ace 42 |
| Alakazam | Psyshock 32 |
| Arbok | Poison Tail 26, Venoshock 32 |
| Arcanine | Incinerate 32 |
| Articuno | Ice Shard 30, Frost Breath 45 |
| Beedrill | Pierce 34 |
| Blastoise | Brine 38, Snipe Shot 46 |
| Charizard | Incinerate 37, Aerial Ace 42 |
| Charmander | Incinerate 28 |
| Charmeleon | Incinerate 32 |
| Cloyster | Ice Shard 28, Brine 32 |
| Dewgong | Ice Shard 28, Brine 33, Frost Breath 42 |
| Dodrio | Flail 26, Aerial Ace 38 |
| Doduo | Flail 22, Aerial Ace 34 |
| Drowzee | Psyshock 28, Punishment 33 |
| Eevee | Facade 31 |
| Ekans | Poison Tail 22, Venoshock 28 |
| Electabuzz | Shock Wave 32 |
| Electrode | Shock Wave 34 |
| Exeggcute | Psyshock 33 |
| Exeggutor | Psyshock 36 |
| Farfetchd | Aerial Ace 32 |
| Fearow | Aerial Ace 36, Pierce 38 |
| Flareon | Incinerate 31, Facade 37 |
| Gastly | Punishment 32 |
| Gengar | Punishment 40 |
| Geodude | Stone Press 30 |
| Golbat | Venoshock 33 |
| Goldeen | Flail 25, Snipe Shot 34 |
| Golem | Stone Press 38 |
| Graveler | Stone Press 34 |
| Grimer | Pollution 22, Venoshock 31 |
| Growlithe | Incinerate 28 |
| Gyarados | Flail 30 |
| Haunter | Punishment 36 |
| Hitmonchan | Pierce 39 |
| Hitmonlee | Pierce 39 |
| Horsea | Brine 31, Snipe Shot 38 |
| Hypno | Psyshock 32, Punishment 36 |
| Jolteon | Shock Wave 32, Facade 37 |
| Jynx | Ice Shard 26, Psyshock 32, Frost Breath 40 |
| Kabuto | Stone Press 38 |
| Kabutops | Stone Press 43 |
| Kadabra | Psyshock 28 |
| Kangaskhan | Facade 37 |
| Kingler | Flail 28 |
| Koffing | Pollution 22, Venoshock 30 |
| Krabby | Flail 24 |
| Lapras | Ice Shard 24, Frost Breath 40 |
| Lickitung | Facade 34 |
| Magikarp | Flail 25 |
| Magmar | Incinerate 30 |
| Magnemite | Shock Wave 30 |
| Magneton | Shock Wave 34 |
| Mankey | Punishment 30 |
| Meowth | Punishment 30 |
| Mew | Psyshock 41 |
| Mewtwo | Psyshock 55 |
| Moltres | Incinerate 40 |
| MrMime | Psyshock 32 |
| Muk | Pollution 26, Venoshock 34 |
| Nidoking | Poison Tail 28, Venoshock 36, Pierce 40 |
| Nidoqueen | Poison Tail 28, Venoshock 36 |
| NidoranF | Poison Tail 20, Venoshock 28 |
| NidoranM | Poison Tail 20, Venoshock 28 |
| Nidorina | Poison Tail 24, Venoshock 32 |
| Nidorino | Poison Tail 24, Venoshock 32 |
| Ninetales | Incinerate 32 |
| Omanyte | Brine 32, Stone Press 38 |
| Omastar | Brine 36, Stone Press 42 |
| Onix | Stone Press 34 |
| Persian | Punishment 34 |
| Pidgeot | Aerial Ace 40 |
| Pidgeotto | Aerial Ace 36 |
| Pidgey | Aerial Ace 32 |
| Pikachu | Shock Wave 30 |
| Pinsir | Pierce 40 |
| Ponyta | Incinerate 31 |
| Primeape | Punishment 34 |
| Raichu | Shock Wave 34 |
| Rapidash | Incinerate 34 |
| Raticate | Flail 20, Facade 32 |
| Rattata | Flail 16, Facade 28 |
| Rhydon | Stone Press 38, Pierce 42 |
| Rhyhorn | Stone Press 34, Pierce 38 |
| Scyther | Aerial Ace 32 |
| Seadra | Brine 34, Snipe Shot 42 |
| Seaking | Flail 28, Pierce 38, Snipe Shot 40 |
| Seel | Ice Shard 24, Brine 28, Frost Breath 38 |
| Shellder | Ice Shard 24, Brine 28 |
| Slowbro | Psyshock 36 |
| Slowpoke | Psyshock 32 |
| Snorlax | Facade 40 |
| Spearow | Aerial Ace 32, Pierce 34 |
| Squirtle | Brine 30, Snipe Shot 38 |
| Tauros | Facade 36 |
| Tentacool | Venoshock 28, Brine 32 |
| Tentacruel | Venoshock 32, Brine 36 |
| Vaporeon | Facade 37 |
| Voltorb | Shock Wave 30 |
| Vulpix | Incinerate 29 |
| Wartortle | Brine 34, Snipe Shot 42 |
| Weezing | Pollution 26, Venoshock 34 |
| Zapdos | Shock Wave 40 |
| Zubat | Venoshock 29 |

## Engine and AI

Legacy damage-stat selection is relocated intact into a roomy ROM bank. Unaffected attacks use that exact legacy implementation; public wrappers preserve its damage inputs across the bank call. The new path validates ID, base power and type so confusion's temporary typeless self-damage cannot accidentally inherit a selected move's conditions. Effective power is transient: move records, PP and saved moves retain their original data/IDs.

Metronome includes all complete additions and still excludes itself, Struggle, zero and invalid IDs. New moves reuse existing animations through the separate mapping; raw status/item/capture animations retain their IDs. The move-choice AI reads current conditional power, especially Flail, and recognizes Psyshock when evaluating Defense boosts. Its broader switching and combo heuristics remain approximate; no full battle-search AI is introduced.

## Validation

Both versions: all 191 records against the cumulative change ledger; all old names plus additions and animation mapping; all 256 Metronome candidate bytes on both sides; 154 new learnset entries via actual generation/daycare PP and relearner routines; high move-ID save/load. Tests cover action-time conditional power, exact half-HP boundaries, Flail thresholds through full 16-bit HP values, Punishment's cap, stage bypass, screens, badge/burn handling, hybrid stats, 1,536 guaranteed-crit RNG cases per ROM, accuracy versus invulnerability/immunity, AI reload, normal damage formula, full execution/PP paths, recoil/flinch/frozen-state retention, and Substitute breaking. There are 484 comparisons between relocated legacy and public damage-stat paths per ROM, including unchanged-condition cases. Legacy stat-selection source matches patch 3 after label relocation. Presentation and controlled crit/random variation are stubbed in battle-path tests; this is automated validation, not a full manual playthrough. All previous species, encounter, crit, freeze and move suites run too. BPS application must reproduce each ROM byte for byte.

## Remaining work and count correction

Earlier summaries omitted Tri Attack from the remaining list. It is still pending. The correct remaining totals after this patch are **14 existing redesigns and 28 new moves**.

Existing: Bide, Counter, Egg Bomb, Fire Spin, Fury Swipes, Psywave, Rage, Razor Wind, Roar, Skull Bash, Transform, Tri Attack, Whirlwind, Wrap.

New: Tongue Lash, Stockpile, Ingrain, Lunge, Shell Break, Ambush, Curse, Wailing Cry, Shadow Leech, Psych Up, Mind Break, Bulk Up, Brick Break, Rock Tomb, Will-O-Wisp, Flame Charge, Cauterize, Aqua Jet, Scald, Thunderclap, Charge, Icy Wind, Icicle Spear, Flash Freeze, Gale Wind, Coil, Poison Fang, Dragon Dance.

Next planned group: status/stat/utility effects, including Tri Attack, screen removal, Counter and Psywave review. Custom timers/trapping, forced switching, priority/turn-sequence changes and automatic transformation remain for their focused later patches. Accepted defaults remain in MOVE-PATCH-2-PLAN.md; no pending mechanics are inserted as placeholder moves.
