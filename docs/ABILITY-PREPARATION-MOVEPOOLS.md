# Movepool additions for planned abilities

Implements all 15 requested learnset adjustments. No abilities, move effects, species stats, trainer rosters or explicit trainer move overrides are changed. Existing moves are retained; some learn levels are shifted to make room.

| Pokémon | Added / earlier access |
|---|---|
| Machamp | Doubleslap as a starting move and at Lv 36; Triple Kick at Lv 49. Both are implemented multi-hit attacks. |
| Poliwrath | Fire Punch Lv 35, Ice Punch Lv 41, Thunderpunch Lv 47. |
| Bellsprout | Acid Lv 10 (was 21); Sludge Lv 25. Matching access on Weepinbell and Victreebel. |
| Shellder | Icicle Spear Lv 20 (was 31). Matching access on Cloyster. |
| Doduo | Bite Lv 12: damaging move with a flinch secondary effect, for the planned Twin Beaks synergy. Dodrio also gets it at 12. |
| Onix | Dig Lv 25. |
| Drowzee / Hypno | Mud Wave Lv 22. |
| Exeggcute | Mega Drain Lv 25; also available to Exeggutor at 25. |
| Cubone / Marowak | Take Down Lv 30. |
| Mr. Mime | Doubleslap Lv 18. |
| Magmar | Will-O-Wisp Lv 21. |
| Pinsir | Lunge Lv 17; X-Scissor Lv 41. |
| Eevee | TM28 Dig compatibility. Its evolutions can retain Dig learned as Eevee. |
| Kabuto | Slash Lv 29. Kabutops also learns it at 29 rather than 41. |
| Aerodactyl | Take Down added to starting moves; its Lv-25 entry is retained. Native creation verified at levels 1, 5, 20 and the fossil lab's revival level of 30. |

Comet Punch is a single-hit move in this game, so it is not counted as a multi-hit option for Machamp. Doubleslap is also available through Machamp's starting-move relearner list; its Lv-36 entry ensures it appears during normal move initialization and level progression.

## Moves pushed back

- Machamp: Pierce 49 → 56; Mega Kick 56 → 63.
- Poliwrath: Hydro Pump 44 → 54; Submission 50 → 60.
- Bellsprout / Weepinbell / Victreebel: Razor Leaf 27 → 31; Slam 33 → 37. Victreebel's Poison Fang 39 → 43, Chomp 45 → 49 and Vine Crush 51 → 55.
- Shellder / Cloyster: Chomp 19 → 25; Aurora Beam 25 → 31, making space for Icicle Spear at 20.
- Onix: Rage 25 → 29; Slam 33 → 36; Stone Press 43 → 46; Coil 50 → 54.
- Pinsir: Seismic Toss 17 → 25; Shell Break 25 → 33; Submission 33 → 49; Bulk Up 41 → 57; Guillotine 49 → 65. Bind remains Lv 9.

## Naturally generated trainer moves

**Follow-up implemented:** These eight natural sets have since been replaced by the [approved boss movesets](BOSS-ABILITY-MOVESET-REVIEW.md). The table below records the original automatic changes.

Trainers retain the same species, levels and explicit overrides. Eight first-challenge boss Pokémon pick up different naturally initialized moves as a consequence of the revised level-up lists. The trainer audit records have been refreshed to verify these results:

| Trainer / Pokémon | Natural move changes |
|---|---|
| Erika / Weepinbell Lv 32 | Acid → Sludge |
| Sabrina / Drowzee Lv 39 | Confusion → Mud Wave |
| Blaine / Magmar Lv 40 | Smog → Will-O-Wisp |
| Lorelei / Cloyster Lv 53 | Icicle Spear → Aurora Beam |
| Bruno / Machamp Lv 58 | Mega Kick → Pierce |
| Bruno / Poliwrath Lv 57 | Body Slam and Submission → Ice Punch and Thunderpunch |
| Bruno / Pinsir Lv 56 | Bulk Up and Guillotine → Seismic Toss and X-Scissor |
| Agatha / Marowak Lv 55 | Wailing Cry → Take Down |

The full current lists, including TM/HM compatibility and inherited moves, are in [Every Pokémon's movepool](ALL-POKEMON-MOVEPOOLS.md), with searchable HTML and CSV versions alongside it.

Existing saves remain compatible. Pokémon do not automatically replace their current moves on loading a save. Eligible missed starting/level-up moves can be obtained from the move relearner; future level-ups use the revised lists.
