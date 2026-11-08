# Regular trainer proposals

**Approved roster plan — now implemented.** See [implementation details and verification](REGULAR-TRAINER-CHANGES.md). “Current” below means the pre-patch team; “Proposed” is the now-implemented team. The baseline was commit `761bc58` (5% badge boosts and the route redesign included).

[Full before/after spreadsheet](REGULAR-TRAINER-PROPOSALS.csv). The expandable sections below specify every proposed team; numbers after Pokémon names are levels.

## Recommended direction

Make battles harder through themed breadth, appropriate evolutions and fewer duplicate fillers. Keep the early game manageable, make most midgame regulars teams of three, and give stronger late-game trainers four or occasionally five. Keep a few small specialist teams when their members warrant it. For each extra Pokémon added, lower every proposed party member by one level: +1 Pokémon means −1 level; +2 means −2 levels. Teams that stay the same size or shrink keep their proposed levels. This includes evolved species; do not raise an ace to undo the reduction.

Regular Gym trainers are included. Gym Leaders and Elite Four are excluded. Rivals/Champion, Giovanni’s story fights, Oak, Silph Chief, Fuji, Seiga, Red, the Dojo master and Janine are also preserved as named or special bosses. These 48 excluded stored teams remain untouched; 313 regular stored teams are covered here. Several records are shared between NPCs, so a record change applies wherever used. Direct map-object references were checked; the Underground Path’s dummy Youngster reference is excluded from location lists.

| Team size | Current | Proposed |
| --- | ---: | ---: |
| 1 | 57 | 6 |
| 2 | 130 | 11 |
| 3 | 82 | 245 |
| 4 | 32 | 38 |
| 5 | 11 | 12 |
| 6 | 1 | 1 |

**281 teams change; 32 are retained. Small teams fall from 187 to 17. Regular party slots rise from 752 to 981 (+30.5%).** Expanded teams have lower levels under the rule above; a handful of support Pokémon are lower still. For example, a solo level-14 team expanded to three becomes level 12, and a solo level-25 team expanded to three becomes level 23. Extra experience is not exactly proportional to slot count because species/base experience also change.

## Representative changes

| Location / record | Current | Proposed |
| --- | --- | --- |
| Viridian Forest — BUG_CATCHER 3 | Weedle 9 | Weedle 8, Caterpie 7 |
| Route 3 — YOUNGSTER 2 | Spearow 14 | Spearow 12, Rattata 12, Mankey 12 |
| S.S. Anne 1F rooms — YOUNGSTER 8 | Nidoran♂ 21 | Nidorino 19, Raticate 19, Pikachu 19 |
| Route 6 — JR_TRAINER_M 4 | Squirtle 20 | Wartortle 18, Pikachu 18, Fearow 18 |
| Rock Tunnel B1F — HIKER 10 | Geodude 25 | Graveler 23, Onix 23, Machop 23 |
| Route 17 — BIKER 9 | Muk 33 | Grimer 31, Arbok 31, Muk 31 |
| Silph Co. 4F — SCIENTIST 4 | Electrode 33 | Electrode 31, Magneton 31, Porygon 31 |
| Viridian Gym — TAMER 3 | Rhyhorn 43 | Rhydon 41, Sandslash 41, Arbok 41 |
| Victory Road 3F — COOLTRAINER_M 2 | Exeggutor 43, Cloyster 43, Arcanine 43 | Exeggutor 42, Cloyster 42, Arcanine 42, Claydol 42 |
| Victory Road 1F — COOLTRAINER_F 4 | Persian 44, Ninetales 44 | Persian 42, Ninetales 42, Raichu 42, Tangela 42 |

## Small-team exceptions

The six retained solo fights are Onix 17 (Route 25), Rapidash 41 (Cinnabar Gym), Vaporeon 35 (Route 20), Slowbro 38 (Saffron Gym), Starmie 37 (Route 21) and Poliwrath 36 (Dojo student). They use the Pokémon’s reviewed stats and natural moves; no new boss-style move overrides are assumed.

The eleven pairs have explicit reasons in the spreadsheet: three early introductions, an evolved Bug pair, Clefairy/Clefable, Ninetales/Persian, Electabuzz/Jolteon, Arbok/Tauros, Dodrio/Farfetch’d and the two existing Haunter specialists. The six-Magikarp fisherman remains a deliberate joke: his dialogue explicitly says he only catches Magikarp. No other proposal repeats the same species within a team.

## Things to watch before implementation

- **Experience and attrition:** 229 extra party slots, plus stronger evolutions, can make the player outlevel unchanged bosses. Apply the per-added-Pokémon level reductions without changing rewards, then playtest regional progression. Lower levels reduce experience per opponent, but do not guarantee unchanged total experience. Count/experience growth does not prove battles are well balanced.
- **Early routes:** Viridian Forest rises only from six total opposing Pokémon to seven. Route 3 rises from 17 to 24, with at most one evolved Bug ace per early Bug Catcher; avoid making the opening a resource grind.
- **Long areas:** Rock Tunnel rises from 37 to 47 regular opposing Pokémon, the S.S. Anne from 32 to 48, Silph Co. from 82 to 100 and Pokémon Tower from 25 to 47. Tower has its existing 5F healing zone, but the climb before it and the repeated status pressure still need testing. Do not automatically add extra Toxic, sleep or confusion overrides.
- **Natural moves matter:** fresh Metapod/Kakuna know only Harden, so this proposal avoids using them as padding. Butterfree at level 27 currently auto-generates Stun Spore/Sleep Powder/Supersonic/Whirlwind; the suggested level-27 trainer slot uses Venonat instead. Fixing that natural-set issue globally would be a separate change.
- **Evolution timing:** the chosen rosters are retained when levels are reduced, so some evolved NPC Pokémon now sit below the player’s normal evolution thresholds—for example, the proposed Graveler moves from level 25 to 23. This is allowed by the existing trainer format, like its legacy underlevel evolutions. Do not raise levels or automatically replace the evolved species to cancel the requested reduction. Recheck natural moves at the new levels before implementation.
- **Habitat and theme:** selected regulars show Mareanie, Miltank, Sableye, Baltoy, Claydol, Pupitar and Toxapex where they suit the trainer. No legendary or unique trainer-exclusive variant is added to a regular team. Check the repeated Sableye/ghost fights for frustration before finalizing.
- **Dialogue and records:** spot-check species-specific dialogue when an anchor evolves or is replaced. Shared records affect multiple NPCs. The existing reviewed-trainer test pins the old roster checksum and count; implementation must update its expected roster totals while preserving all protected boss sets and validating party loading in both versions.
- **AI scope:** this proposal changes team composition only. Existing class AI, trainer items, postgame scaling, battle style rules and the new 5% badge bonus stay as implemented.

## Suggested implementation batches

1. Forest, Pewter, Route 3 and Mt. Moon: verify starter matchups, recovery resources and the approach to Misty.
2. Cerulean routes, S.S. Anne, Vermilion and Rock Tunnel: verify the three-Pokémon baseline without major level inflation.
3. Celadon/Rocket Hideout, Tower, Cycling Road, Fuchsia and Silph Co.: test attrition, status repetition and the new species placements.
4. Sea routes, Cinnabar, Viridian Gym students and Victory Road: finish the stronger specialist teams and test progression into the unchanged Elite Four.

Before publishing gameplay changes, load every proposed team in both ROMs; check species, levels, moves, PP, party size, overrides, protected bosses and save compatibility, then verify BPS round trips. The checks performed for this planning document are static: valid species/levels, complete coverage, party size at most six, no increased maximum team levels, per-added-Pokémon level reductions, and at least one damaging natural move per non-Ditto party member. Ditto retains its existing automatic transformation behavior. Gameplay difficulty still needs emulator/playtesting.

## Complete proposals by trainer class

<details>
<summary>Youngster — 12 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Route 3 | Rattata 11, Ekans 11 | Rattata 10, Ekans 10, Spearow 10 |
| 2 | Route 3 | Spearow 14 | Spearow 12, Rattata 12, Mankey 12 |
| 3 | Mt. Moon 1F | Rattata 10, Rattata 10, Zubat 10 | Rattata 10, Ekans 10, Zubat 10 |
| 4 | Route 24 | Rattata 14, Ekans 14, Zubat 14 | Rattata 14, Ekans 14, Zubat 14 |
| 5 | Route 25 | Rattata 15, Spearow 15 | Rattata 14, Spearow 14, Nidoran♂ 14 |
| 6 | Route 25 | Slowpoke 17 | Slowpoke 15, Sandshrew 15, Paras 15 |
| 7 | Route 25 | Ekans 14, Sandshrew 14 | Ekans 13, Sandshrew 13, Mankey 13 |
| 8 | S.S. Anne 1F rooms | Nidoran♂ 21 | Nidorino 19, Raticate 19, Pikachu 19 |
| 9 | Route 11 | Ekans 21 | Ekans 19, Sandshrew 19, Drowzee 19 |
| 10 | Route 11 | Sandshrew 19, Zubat 19 | Sandshrew 18, Zubat 18, Spearow 18 |
| 11 | Route 11 | Rattata 17, Rattata 17, Raticate 17 | Rattata 17, Ekans 17, Raticate 17 |
| 12 | Route 11 | Nidoran♂ 18, Nidorino 18 | Nidoran♂ 17, Nidorino 17, Spearow 17 |

</details>

<details>
<summary>Bug Catcher — 13 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Viridian Forest | Weedle 6, Caterpie 6 | Weedle 6, Caterpie 6 |
| 2 | Viridian Forest | Weedle 7, Kakuna 7, Weedle 7 | Weedle 7, Caterpie 7, Paras 7 |
| 3 | Viridian Forest | Weedle 9 | Weedle 8, Caterpie 7 |
| 4 | Route 3 | Caterpie 10, Weedle 10, Caterpie 10 | Caterpie 10, Weedle 10, Butterfree 10 |
| 5 | Route 3 | Weedle 9, Kakuna 9, Caterpie 9, Metapod 9 | Caterpie 9, Weedle 9, Paras 9 |
| 6 | Route 3 | Caterpie 11, Metapod 11 | Paras 10, Caterpie 10, Butterfree 10 |
| 7 | Mt. Moon 1F | Weedle 11, Kakuna 11 | Weedle 10, Paras 10, Beedrill 10 |
| 8 | Mt. Moon 1F | Caterpie 10, Metapod 10, Caterpie 10 | Caterpie 10, Weedle 10, Butterfree 10 |
| 9 | Route 24 | Caterpie 14, Weedle 14 | Butterfree 13, Beedrill 13, Paras 13 |
| 10 | Route 6 | Weedle 16, Caterpie 16, Weedle 16 | Beedrill 16, Butterfree 16, Venonat 16 |
| 11 | Route 6 | Butterfree 20 | Beedrill 17, Butterfree 19 |
| 12 | Route 9 | Beedrill 19, Beedrill 19 | Beedrill 18, Venonat 18, Paras 18 |
| 13 | Route 9 | Caterpie 20, Weedle 20, Venonat 20 | Butterfree 20, Beedrill 20, Venonat 20 |

</details>

<details>
<summary>Lass — 18 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Route 3 | Pidgey 9, Pidgey 9 | Pidgey 8, Rattata 8, Nidoran♀ 8 |
| 2 | Route 3 | Rattata 10, Nidoran♂ 10 | Rattata 9, Nidoran♂ 9, Pidgey 9 |
| 3 | Route 3 | Jigglypuff 14 | Jigglypuff 12, Pidgey 12, Clefairy 12 |
| 4 | Route 4 | Paras 31, Paras 31, Parasect 31 | Parasect 31, Venomoth 31, Tangela 31 |
| 5 | Mt. Moon 1F | Oddish 11, Bellsprout 11 | Oddish 10, Bellsprout 10, Paras 10 |
| 6 | Mt. Moon 1F | Clefairy 14 | Clefairy 12, Jigglypuff 12, Pikachu 12 |
| 7 | Route 24 | Pidgey 16, Nidoran♀ 16 | Pidgey 15, Nidoran♀ 15, Jigglypuff 15 |
| 8 | Route 24 | Pidgey 14, Nidoran♀ 14 | Pidgey 13, Nidoran♀ 13, Oddish 13 |
| 9 | Route 25 | Nidoran♂ 15, Nidoran♀ 15 | Nidoran♂ 14, Nidoran♀ 14, Clefairy 14 |
| 10 | Route 25 | Oddish 13, Pidgey 13, Oddish 13 | Oddish 13, Pidgey 13, Bellsprout 13 |
| 11 | S.S. Anne 1F rooms | Pidgey 18, Nidoran♀ 18 | Pidgeotto 17, Nidoran♀ 17, Meowth 17 |
| 12 | S.S. Anne 2F rooms | Rattata 18, Pikachu 18 | Rattata 17, Pikachu 17, Clefairy 17 |
| 13 | Route 8 | Nidoran♀ 23, Nidorina 23 | Nidorina 22, Clefairy 22, Meowth 22 |
| 14 | Route 8 | Meowth 24, Jigglypuff 24, Eevee 24 | Meowth 24, Jigglypuff 24, Eevee 24 |
| 15 | Route 8 | Pidgey 19, Rattata 19, Nidoran♂ 19, Meowth 19, Pikachu 19 | Pidgeotto 19, Rattata 19, Nidoran♂ 19, Meowth 19, Pikachu 19 |
| 16 | Route 8 | Clefairy 22, Clefable 22 | Clefairy 22, Clefable 22 |
| 17 | Celadon Gym | Bellsprout 23, Weepinbell 23 | Bellsprout 22, Weepinbell 22, Exeggcute 22 |
| 18 | Celadon Gym | Oddish 23, Gloom 23 | Oddish 22, Gloom 22, Paras 22 |

</details>

<details>
<summary>Sailor — 8 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | S.S. Anne deck | Machop 18, Shellder 18 | Machop 17, Shellder 17, Horsea 17 |
| 2 | S.S. Anne deck | Machop 17, Tentacool 17 | Machop 16, Tentacool 16, Krabby 16 |
| 3 | S.S. Anne B1F rooms | Shellder 21 | Shellder 19, Machop 19, Staryu 19 |
| 4 | S.S. Anne B1F rooms | Horsea 17, Shellder 17, Tentacool 17 | Horsea 17, Shellder 17, Tentacool 17 |
| 5 | S.S. Anne B1F rooms | Tentacool 18, Staryu 18 | Tentacool 17, Staryu 17, Krabby 17 |
| 6 | S.S. Anne B1F rooms | Horsea 17, Horsea 17, Horsea 17 | Horsea 17, Shellder 17, Krabby 17 |
| 7 | S.S. Anne B1F rooms | Machop 20 | Machop 18, Poliwag 18, Krabby 18 |
| 8 | Vermilion Gym | Pikachu 21, Pikachu 21 | Pikachu 20, Magnemite 20, Voltorb 20 |

</details>

<details>
<summary>Jr Trainer M — 8 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Pewter Gym | Diglett 11, Sandshrew 11 | Diglett 11, Sandshrew 11 |
| 2 | Route 24, Route 25 | Rattata 14, Ekans 14 | Rattata 13, Ekans 13, Spearow 13 |
| 3 | Route 24 | Mankey 18 | Mankey 16, Machop 16, Sandshrew 16 |
| 4 | Route 6 | Squirtle 20 | Wartortle 18, Pikachu 18, Fearow 18 |
| 5 | Route 6 | Spearow 16, Raticate 16 | Spearow 15, Ekans 15, Raticate 15 |
| 6 | Route 9 | Growlithe 21, Charmander 21 | Growlithe 20, Charmeleon 20, Mankey 20 |
| 7 | Route 9 | Rattata 19, Diglett 19, Ekans 19, Sandshrew 19 | Rattata 19, Diglett 19, Ekans 19, Sandshrew 19 |
| 8 | Route 12 | Nidoran♂ 29, Nidorino 29 | Nidorino 28, Nidorina 28, Raticate 28 |

</details>

<details>
<summary>Jr Trainer F — 23 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Cerulean Gym | Goldeen 19 | Goldeen 17, Horsea 17, Poliwag 17 |
| 2 | Route 6 | Rattata 16, Pikachu 16 | Rattata 15, Pikachu 15, Meowth 15 |
| 3 | Route 6 | Pidgey 16, Pidgey 16, Pidgey 16 | Pidgey 16, Spearow 16, Nidoran♀ 16 |
| 4 | Route 9 | Oddish 18, Bellsprout 18, Oddish 18, Bellsprout 18 | Oddish 18, Bellsprout 18, Paras 18, Exeggcute 18 |
| 5 | Route 9 | Meowth 23 | Meowth 21, Clefairy 21, Pikachu 21 |
| 6 | Route 10 | Pikachu 20, Clefairy 20 | Pikachu 19, Clefairy 19, Jigglypuff 19 |
| 7 | Route 10 | Pidgey 21, Pidgeotto 21 | Pidgeotto 20, Meowth 20, Nidorina 20 |
| 8 | Rock Tunnel B1F | Jigglypuff 21, Pidgey 21, Meowth 21 | Jigglypuff 21, Pidgeotto 21, Meowth 21 |
| 9 | Rock Tunnel B1F | Oddish 22, Bulbasaur 22 | Gloom 21, Ivysaur 21, Paras 21 |
| 10 | Celadon Gym | Bulbasaur 24, Ivysaur 24 | Bulbasaur 23, Ivysaur 23, Exeggcute 23 |
| 11 | Route 13 | Pidgey 24, Meowth 24, Rattata 24, Pikachu 24, Dratini 24 | Pidgeotto 24, Meowth 24, Raticate 24, Pikachu 24, Dratini 24 |
| 12 | Route 13 | Poliwag 30, Poliwag 30 | Poliwhirl 29, Goldeen 29, Horsea 29 |
| 13 | Route 13 | Pidgey 27, Meowth 27, Pidgey 27, Pidgeotto 27 | Pidgeotto 27, Meowth 27, Nidorina 27, Venonat 27 |
| 14 | Route 13 | Goldeen 28, Poliwag 28, Horsea 28 | Goldeen 28, Poliwhirl 28, Horsea 28 |
| 15 | Route 20 | Goldeen 31, Seaking 31 | Goldeen 30, Seaking 30, Staryu 30 |
| 16 | Route 20 | Tentacool 30, Horsea 30, Seel 30 | Tentacruel 30, Horsea 30, Seel 30 |
| 17 | Rock Tunnel 1F | Bellsprout 22, Clefairy 22 | Weepinbell 21, Clefairy 21, Paras 21 |
| 18 | Rock Tunnel 1F | Meowth 20, Oddish 20, Pidgey 20 | Meowth 20, Oddish 20, Pidgeotto 20 |
| 19 | Rock Tunnel 1F | Pidgey 19, Rattata 19, Rattata 19, Bellsprout 19 | Pidgeotto 19, Rattata 19, Spearow 19, Bellsprout 19 |
| 20 | Route 15 | Gloom 28, Oddish 28, Oddish 28 | Gloom 28, Weepinbell 28, Parasect 28 |
| 21 | Route 15 | Pikachu 29, Raichu 29 | Pikachu 28, Raichu 28, Clefairy 28 |
| 22 | Route 15 | Clefairy 33 | Clefairy 31, Jigglypuff 31, Raichu 31 |
| 23 | Route 15 | Bellsprout 29, Oddish 29, Tangela 29 | Weepinbell 29, Gloom 29, Tangela 29 |

</details>

<details>
<summary>Pokemaniac — 7 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Route 10 | Rhyhorn 30, Lickitung 30 | Rhyhorn 29, Lickitung 29, Slowpoke 29 |
| 2 | Route 10 | Cubone 20, Slowpoke 20 | Cubone 19, Slowpoke 19, Baltoy 19 |
| 3 | Rock Tunnel B1F | Slowpoke 20, Slowpoke 20, Slowpoke 20 | Slowpoke 20, Cubone 20, Lickitung 20 |
| 4 | Rock Tunnel B1F | Charmander 22, Cubone 22 | Charmeleon 21, Cubone 21, Sableye 21 |
| 5 | Rock Tunnel B1F | Slowpoke 25 | Slowpoke 23, Cubone 23, Sableye 23 |
| 6 | Victory Road 2F | Charmeleon 40, Lapras 40, Lickitung 40 | Charizard 39, Lapras 39, Lickitung 39, Pupitar 39 |
| 7 | Rock Tunnel 1F | Cubone 23, Slowpoke 23 | Cubone 22, Slowpoke 22, Sableye 22 |

</details>

<details>
<summary>Super Nerd — 9 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Mt. Moon 1F | Magnemite 11, Voltorb 11 | Magnemite 10, Voltorb 10, Grimer 10 |
| 2 | mtmoon3 | Grimer 12, Voltorb 12, Koffing 12 | Grimer 12, Voltorb 12, Koffing 12 |
| 3 | Route 8 | Voltorb 20, Koffing 20, Voltorb 20, Magnemite 20 | Voltorb 20, Koffing 20, Magnemite 20, Porygon 20 |
| 4 | Route 8 | Grimer 22, Muk 22, Grimer 22 | Grimer 22, Koffing 22, Arbok 22 |
| 5 | Route 8 | Koffing 26 | Koffing 24, Grimer 24, Magnemite 24 |
| 6 | Cinnabar Gym | Vulpix 36, Ninetales 36, Flareon 36 | Vulpix 36, Ninetales 36, Flareon 36 |
| 7 | Cinnabar Gym | Ponyta 34, Charmander 34, Vulpix 34, Growlithe 34 | Ponyta 34, Charmeleon 34, Vulpix 34, Arcanine 34 |
| 8 | Cinnabar Gym | Rapidash 41 | Rapidash 41 |
| 9 | Cinnabar Gym | Growlithe 37, Vulpix 37 | Growlithe 36, Ninetales 36, Magmar 36 |

</details>

<details>
<summary>Hiker — 14 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Mt. Moon 1F | Geodude 10, Geodude 10, Onix 10 | Geodude 10, Machop 10, Onix 10 |
| 2 | Route 25 | Machop 15, Geodude 15 | Machop 14, Geodude 14, Sandshrew 14 |
| 3 | Route 25 | Geodude 13, Geodude 13, Machop 13, Geodude 13 | Geodude 13, Sandshrew 13, Machop 13, Onix 13 |
| 4 | Route 25 | Onix 17 | Onix 17 |
| 5 | Route 9 | Geodude 21, Onix 21 | Geodude 20, Onix 20, Machop 20 |
| 6 | Route 9 | Geodude 20, Machop 20, Geodude 20 | Geodude 20, Machop 20, Sandshrew 20 |
| 7 | Route 10 | Geodude 21, Onix 21 | Geodude 20, Onix 20, Baltoy 20 |
| 8 | Route 10 | Onix 19, Graveler 19 | Onix 18, Graveler 18, Sandshrew 18 |
| 9 | Rock Tunnel B1F | Geodude 21, Geodude 21, Graveler 21 | Geodude 21, Machop 21, Onix 21 |
| 10 | Rock Tunnel B1F | Geodude 25 | Graveler 23, Onix 23, Machop 23 |
| 11 | Rock Tunnel B1F, Route 9 | Machop 20, Onix 20 | Machop 19, Onix 19, Baltoy 19 |
| 12 | Rock Tunnel 1F | Geodude 19, Machop 19, Geodude 19, Geodude 19 | Geodude 19, Machop 19, Sandshrew 19, Onix 19 |
| 13 | Rock Tunnel 1F | Onix 20, Onix 20, Geodude 20 | Onix 20, Geodude 20, Machop 20 |
| 14 | Rock Tunnel 1F | Geodude 21, Graveler 21 | Geodude 20, Onix 20, Baltoy 20 |

</details>

<details>
<summary>Biker — 15 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Route 13 | Koffing 28, Koffing 28, Koffing 28 | Koffing 28, Grimer 28, Golbat 28 |
| 2 | Route 14 | Koffing 29, Grimer 29 | Koffing 28, Grimer 28, Raticate 28 |
| 3 | Route 15 | Koffing 25, Koffing 25, Weezing 25, Koffing 25, Grimer 25 | Koffing 25, Grimer 25, Golbat 25, Arbok 25, Weezing 25 |
| 4 | Route 15 | Koffing 28, Grimer 28, Weezing 28 | Koffing 28, Grimer 28, Golbat 28 |
| 5 | Route 16 | Grimer 29, Koffing 29 | Grimer 28, Koffing 28, Arbok 28 |
| 6 | Route 16 | Weezing 33 | Koffing 31, Golbat 31, Weezing 31 |
| 7 | Route 16 | Grimer 26, Grimer 26, Grimer 26, Grimer 26 | Grimer 26, Koffing 26, Raticate 26, Arbok 26 |
| 8 | Route 17 | Weezing 28, Koffing 28, Weezing 28 | Koffing 28, Grimer 28, Weezing 28 |
| 9 | Route 17 | Muk 33 | Grimer 31, Arbok 31, Muk 31 |
| 10 | Route 17 | Voltorb 29, Voltorb 29 | Voltorb 28, Magnemite 28, Raticate 28 |
| 11 | Route 17 | Weezing 29, Muk 29 | Golbat 28, Weezing 28, Muk 28 |
| 12 | Route 17 | Koffing 25, Weezing 25, Koffing 25, Koffing 25, Weezing 25 | Koffing 25, Grimer 25, Arbok 25, Golbat 25, Weezing 25 |
| 13 | Route 14 | Koffing 26, Koffing 26, Grimer 26, Koffing 26 | Koffing 26, Grimer 26, Arbok 26, Golbat 26 |
| 14 | Route 14 | Grimer 28, Grimer 28, Koffing 28 | Grimer 28, Koffing 28, Arbok 28 |
| 15 | Route 14 | Koffing 29, Muk 29 | Koffing 28, Arbok 28, Muk 28 |

</details>

<details>
<summary>Burglar — 6 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Cinnabar Gym | Growlithe 36, Vulpix 36, Ninetales 36 | Growlithe 36, Vulpix 36, Ninetales 36 |
| 2 | Cinnabar Gym | Ponyta 41 | Ponyta 39, Growlithe 39, Rapidash 39 |
| 3 | Cinnabar Gym | Vulpix 37, Growlithe 37 | Ninetales 36, Growlithe 36, Persian 36 |
| 4 | Pokémon Mansion 2F | Charmander 34, Charmeleon 34 | Charmeleon 33, Growlithe 33, Vulpix 33 |
| 5 | Pokémon Mansion 3F | Ninetales 38 | Ninetales 37, Persian 37 |
| 6 | mansion4 | Growlithe 34, Ponyta 34 | Growlithe 33, Ponyta 33, Charmeleon 33 |

</details>

<details>
<summary>Engineer — 2 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Route 11 | Porygon 21 | Porygon 19, Magnemite 19, Voltorb 19 |
| 2 | Route 11 | Ditto 18, Electrode 18, Magneton 18 | Ditto 18, Electrode 18, Magneton 18 |

</details>

<details>
<summary>Fisher — 11 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | S.S. Anne 2F rooms | Goldeen 17, Tentacool 17, Goldeen 17 | Goldeen 17, Tentacool 17, Horsea 17 |
| 2 | S.S. Anne B1F rooms | Tentacool 17, Staryu 17, Shellder 17 | Tentacool 17, Staryu 17, Shellder 17 |
| 3 | Route 12 | Goldeen 22, Poliwag 22, Goldeen 22 | Goldeen 22, Poliwag 22, Krabby 22 |
| 4 | Route 12 | Tentacool 24, Goldeen 24 | Tentacool 23, Goldeen 23, Shellder 23 |
| 5 | Route 12 | Goldeen 27 | Goldeen 25, Poliwhirl 25, Krabby 25 |
| 6 | Route 12 | Poliwag 21, Shellder 21, Goldeen 21, Horsea 21 | Poliwag 21, Shellder 21, Goldeen 21, Horsea 21 |
| 7 | Route 21 | Seaking 28, Goldeen 28, Seaking 28, Seaking 28 | Seaking 28, Goldeen 28, Kingler 28, Tentacool 28 |
| 8 | Route 21 | Shellder 31, Cloyster 31 | Shellder 30, Cloyster 30, Staryu 30 |
| 9 | Route 21 | Magikarp 27, Magikarp 27, Magikarp 27, Magikarp 27, Magikarp 27, Magikarp 27 | Magikarp 27, Magikarp 27, Magikarp 27, Magikarp 27, Magikarp 27, Magikarp 27 |
| 10 | Route 21 | Seaking 33, Goldeen 33 | Seaking 32, Goldeen 32, Seadra 32 |
| 11 | Route 12 | Magikarp 24, Magikarp 24, Omanyte 24, Kabuto 24 | Gyarados 24, Poliwag 24, Omanyte 24, Kabuto 24 |

</details>

<details>
<summary>Swimmer — 15 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Cerulean Gym | Horsea 16, Shellder 16 | Horsea 15, Shellder 15, Poliwag 15 |
| 2 | Route 19 | Tentacool 30, Shellder 30 | Tentacruel 29, Shellder 29, Kingler 29 |
| 3 | Route 19 | Goldeen 29, Horsea 29, Staryu 29 | Goldeen 29, Horsea 29, Staryu 29 |
| 4 | Route 19 | Poliwag 30, Poliwhirl 30 | Poliwhirl 29, Horsea 29, Staryu 29 |
| 5 | Route 19 | Horsea 27, Tentacool 27, Tentacool 27, Goldeen 27 | Horsea 27, Tentacool 27, Goldeen 27, Mareanie 27 |
| 6 | Route 19 | Goldeen 29, Shellder 29, Seaking 29 | Goldeen 29, Shellder 29, Seaking 29 |
| 7 | Route 19 | Horsea 30, Horsea 30 | Horsea 29, Staryu 29, Kingler 29 |
| 8 | Route 19 | Tentacool 27, Tentacool 27, Staryu 27, Horsea 27, Tentacruel 27 | Tentacool 27, Goldeen 27, Staryu 27, Horsea 27, Tentacruel 27 |
| 9 | Route 20 | Shellder 31, Cloyster 31 | Shellder 30, Cloyster 30, Horsea 30 |
| 10 | Route 20 | Staryu 35 | Staryu 33, Seadra 33, Seaking 33 |
| 11 | Route 20 | Horsea 28, Horsea 28, Seadra 28, Horsea 28 | Horsea 28, Goldeen 28, Staryu 28, Seadra 28 |
| 12 | Route 21 | Seadra 33, Tentacruel 33 | Seadra 32, Tentacruel 32, Shellder 32 |
| 13 | Route 21 | Starmie 37 | Starmie 37 |
| 14 | Route 21 | Staryu 33, Wartortle 33 | Staryu 32, Wartortle 32, Kingler 32 |
| 15 | Route 21 | Poliwhirl 32, Tentacool 32, Seadra 32 | Poliwhirl 32, Tentacruel 32, Seadra 32 |

</details>

<details>
<summary>Cue Ball — 9 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Route 16 | Machop 28, Mankey 28, Machop 28 | Machoke 28, Primeape 28, Raticate 28 |
| 2 | Route 16 | Mankey 29, Machop 29 | Primeape 28, Machoke 28, Raticate 28 |
| 3 | Route 16 | Machop 33 | Machoke 31, Primeape 31, Growlithe 31 |
| 4 | Route 17 | Mankey 29, Primeape 29 | Mankey 28, Primeape 28, Raticate 28 |
| 5 | Route 17 | Machop 29, Machoke 29 | Machop 28, Machoke 28, Primeape 28 |
| 6 | Route 17 | Machoke 33 | Machoke 31, Primeape 31, Raticate 31 |
| 7 | Route 17 | Mankey 26, Mankey 26, Machoke 26, Machop 26 | Mankey 26, Machop 26, Raticate 26, Arbok 26 |
| 8 | Route 17 | Primeape 29, Machoke 29 | Primeape 28, Machoke 28, Tauros 28 |
| 9 | Route 21 | Tentacool 31, Tentacool 31, Tentacruel 31 | Tentacool 31, Shellder 31, Tentacruel 31 |

</details>

<details>
<summary>Gambler — 6 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Route 11 | Poliwag 18, Horsea 18 | Poliwag 17, Horsea 17, Goldeen 17 |
| 2 | Route 11 | Bellsprout 18, Oddish 18 | Bellsprout 17, Oddish 17, Paras 17 |
| 3 | Route 11 | Voltorb 18, Magnemite 18 | Voltorb 17, Magnemite 17, Pikachu 17 |
| 4 | Route 11 | Growlithe 18, Vulpix 18 | Growlithe 17, Vulpix 17, Ponyta 17 |
| 5 | Route 8 | Poliwag 22, Poliwag 22, Poliwhirl 22 | Poliwag 22, Poliwhirl 22, Krabby 22 |
| 6 | Route 8 | Growlithe 24, Vulpix 24 | Growlithe 23, Vulpix 23, Eevee 23 |

</details>

<details>
<summary>Beauty — 14 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Celadon Gym | Oddish 21, Bellsprout 21, Oddish 21, Bellsprout 21 | Gloom 21, Weepinbell 21, Paras 21, Exeggcute 21 |
| 2 | Celadon Gym | Bellsprout 24, Bellsprout 24 | Weepinbell 23, Gloom 23, Parasect 23 |
| 3 | Celadon Gym | Exeggcute 26 | Exeggcute 24, Gloom 24, Weepinbell 24 |
| 4 | Route 13 | Rattata 27, Pikachu 27, Rattata 27 | Raticate 27, Pikachu 27, Meowth 27 |
| 5 | Route 13 | Clefairy 29, Meowth 29 | Clefairy 28, Persian 28, Miltank 28 |
| 6 | Route 20 | Vaporeon 35 | Vaporeon 35 |
| 7 | Route 20 | Shellder 30, Shellder 30, Cloyster 30 | Shellder 30, Staryu 30, Cloyster 30 |
| 8 | Route 20 | Poliwag 31, Seaking 31 | Poliwhirl 30, Seaking 30, Horsea 30 |
| 9 | Route 15 | Pidgeotto 29, Wigglytuff 29 | Pidgeotto 28, Wigglytuff 28, Clefairy 28 |
| 10 | Route 15 | Bulbasaur 29, Ivysaur 29 | Ivysaur 28, Gloom 28, Tangela 28 |
| 11 | Route 19 | Poliwag 27, Goldeen 27, Seaking 27, Goldeen 27, Poliwag 27 | Poliwhirl 27, Goldeen 27, Seaking 27, Krabby 27, Staryu 27 |
| 12 | Route 19 | Goldeen 30, Seaking 30 | Goldeen 29, Seaking 29, Staryu 29 |
| 13 | Route 19 | Staryu 29, Staryu 29, Staryu 29 | Staryu 29, Goldeen 29, Horsea 29 |
| 14 | Route 20 | Seadra 30, Horsea 30, Seadra 30 | Seadra 30, Staryu 30, Kingler 30 |

</details>

<details>
<summary>Psychic Tr — 4 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Saffron Gym | Kadabra 31, Slowpoke 31, Mr. Mime 31, Kadabra 31 | Kadabra 31, Mr. Mime 31, Hypno 31, Slowpoke 31 |
| 2 | Saffron Gym | Mr. Mime 34, Kadabra 34 | Mr. Mime 33, Kadabra 33, Hypno 33 |
| 3 | Saffron Gym | Slowpoke 33, Slowpoke 33, Slowbro 33 | Slowpoke 33, Hypno 33, Slowbro 33 |
| 4 | Saffron Gym | Slowbro 38 | Slowbro 38 |

</details>

<details>
<summary>Rocker — 2 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Vermilion Gym | Voltorb 20, Magnemite 20, Pikachu 20 | Voltorb 20, Magnemite 20, Pikachu 20 |
| 2 | Route 12 | Electabuzz 29, Jolteon 29 | Electabuzz 29, Jolteon 29 |

</details>

<details>
<summary>Juggler — 6 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Silph Co. 5F | Kadabra 29, Mr. Mime 29 | Kadabra 28, Mr. Mime 28, Hypno 28 |
| 2 | Victory Road 2F | Drowzee 41, Hypno 41, Kadabra 41, Kadabra 41 | Hypno 41, Mr. Mime 41, Kadabra 41, Sableye 41 |
| 3 | Victory Road 2F | Tangela 48, Golem 48 | Tangela 47, Golem 47, Claydol 47 |
| 4 | Fuchsia Gym | Oddish 33, Gastly 33, Venonat 33, Koffing 33 | Gloom 33, Haunter 33, Venomoth 33, Koffing 33 |
| 5 | Fuchsia Gym | Exeggcute 38, Exeggcute 38 | Exeggcute 37, Hypno 37, Venomoth 37 |
| 6 | Fuchsia Gym | Drowzee 34, Hypno 34 | Drowzee 33, Hypno 33, Mr. Mime 33 |

</details>

<details>
<summary>Tamer — 5 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Fuchsia Gym | Sandslash 34, Arbok 34 | Sandslash 33, Arbok 33, Persian 33 |
| 2 | Fuchsia Gym | Arbok 33, Sandslash 33, Arbok 33 | Arbok 33, Sandslash 33, Tauros 33 |
| 3 | Viridian Gym | Rhyhorn 43 | Rhydon 41, Sandslash 41, Arbok 41 |
| 4 | Viridian Gym | Arbok 39, Tauros 39 | Arbok 39, Tauros 39 |
| 5 | Victory Road 2F | Persian 44, Golduck 44 | Persian 42, Golduck 42, Arbok 42, Rhydon 42 |

</details>

<details>
<summary>Bird Keeper — 15 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Route 13 | Pidgey 29, Pidgeotto 29 | Pidgeotto 28, Fearow 28, Doduo 28 |
| 2 | Route 13 | Spearow 25, Pidgey 25, Pidgey 25, Spearow 25, Spearow 25 | Spearow 25, Pidgeotto 25, Doduo 25, Fearow 25, Farfetch’d 25 |
| 3 | Route 13 | Pidgey 26, Pidgeotto 26, Spearow 26, Fearow 26 | Pidgeotto 26, Doduo 26, Farfetch’d 26, Fearow 26 |
| 4 | Route 14 | Farfetch’d 33 | Farfetch’d 31, Fearow 31, Dodrio 31 |
| 5 | Route 14 | Spearow 29, Fearow 29 | Spearow 28, Fearow 28, Doduo 28 |
| 6 | Route 15 | Pidgeotto 26, Farfetch’d 26, Doduo 26, Pidgey 26 | Pidgeotto 26, Farfetch’d 26, Doduo 26, Fearow 26 |
| 7 | Route 15 | Dodrio 28, Doduo 28, Doduo 28 | Dodrio 28, Fearow 28, Pidgeotto 28 |
| 8 | Route 18 | Spearow 29, Fearow 29 | Spearow 28, Fearow 28, Pidgeotto 28 |
| 9 | Route 18 | Dodrio 34 | Dodrio 33, Farfetch’d 33 |
| 10 | Route 18 | Spearow 26, Spearow 26, Fearow 26, Spearow 26 | Spearow 26, Doduo 26, Pidgeotto 26, Fearow 26 |
| 11 | Route 20 | Fearow 30, Fearow 30, Pidgeotto 30 | Fearow 30, Doduo 30, Pidgeotto 30 |
| 12 | Route 14 | Pidgey 28, Doduo 28, Pidgeotto 28 | Pidgeotto 28, Doduo 28, Fearow 28 |
| 13 | Route 14 | Pidgey 26, Spearow 26, Pidgey 26, Fearow 26 | Pidgeotto 26, Spearow 26, Farfetch’d 26, Fearow 26 |
| 14 | Route 14 | Pidgeotto 29, Fearow 29 | Pidgeotto 28, Fearow 28, Doduo 28 |
| 15 | Route 14 | Spearow 28, Doduo 28, Fearow 28 | Spearow 28, Doduo 28, Fearow 28 |

</details>

<details>
<summary>Blackbelt — 8 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 2 | Fighting Dojo | Mankey 31, Mankey 31, Primeape 31 | Mankey 31, Machoke 31, Primeape 31 |
| 3 | Fighting Dojo | Machop 32, Machoke 32 | Machop 31, Machoke 31, Primeape 31 |
| 4 | Fighting Dojo | Poliwrath 36 | Poliwrath 36 |
| 5 | Fighting Dojo | Machop 31, Mankey 31, Primeape 31 | Machoke 31, Primeape 31, Electabuzz 31 |
| 6 | Viridian Gym | Machop 40, Machoke 40 | Machop 39, Machoke 39, Primeape 39 |
| 7 | Viridian Gym | Machoke 43 | Machoke 41, Primeape 41, Hitmonchan 41 |
| 8 | Viridian Gym | Machoke 38, Machop 38, Machoke 38 | Machoke 38, Primeape 38, Hitmonlee 38 |
| 9 | Victory Road 2F | Machoke 43, Machop 43, Machoke 43 | Machoke 42, Primeape 42, Poliwrath 42, Hitmonlee 42 |

</details>

<details>
<summary>Scientist — 13 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Silph Co. 2F | Grimer 26, Weezing 26, Koffing 26, Weezing 26 | Grimer 26, Magnemite 26, Weezing 26, Porygon 26 |
| 2 | Silph Co. 2F | Magnemite 28, Voltorb 28, Magneton 28 | Magnemite 28, Voltorb 28, Magneton 28 |
| 3 | Silph Co. 3F | Electrode 29, Weezing 29 | Electrode 28, Magnemite 28, Koffing 28 |
| 4 | Silph Co. 4F | Electrode 33 | Electrode 31, Magneton 31, Porygon 31 |
| 5 | Silph Co. 5F | Magneton 26, Koffing 26, Weezing 26, Magnemite 26 | Magneton 26, Koffing 26, Weezing 26, Porygon 26 |
| 6 | Silph Co. 6F | Voltorb 25, Koffing 25, Magneton 25, Magnemite 25, Koffing 25 | Voltorb 25, Koffing 25, Magneton 25, Porygon 25, Grimer 25 |
| 7 | Silph Co. 7F | Electrode 29, Muk 29 | Electrode 28, Muk 28, Porygon 28 |
| 8 | Silph Co. 8F | Grimer 29, Electrode 29 | Grimer 28, Electrode 28, Magnemite 28 |
| 9 | Silph Co. 9F | Voltorb 28, Koffing 28, Magneton 28 | Voltorb 28, Koffing 28, Magneton 28 |
| 10 | Silph Co. 10F | Magnemite 29, Koffing 29 | Magnemite 28, Koffing 28, Porygon 28 |
| 11 | Pokémon Mansion 3F | Magnemite 33, Magneton 33, Voltorb 33 | Magnemite 33, Magneton 33, Electrode 33 |
| 12 | mansion4 | Magnemite 34, Electrode 34 | Magneton 33, Electrode 33, Grimer 33 |
| 13 | Pokémon Mansion 1F | Koffing 34, Voltorb 34 | Koffing 33, Electrode 33, Porygon 33 |

</details>

<details>
<summary>Rocket — 40 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | mtmoon3 | Rattata 13, Zubat 13 | Rattata 12, Zubat 12, Ekans 12 |
| 2 | mtmoon3 | Sandshrew 11, Rattata 11, Zubat 11 | Sandshrew 11, Rattata 11, Zubat 11 |
| 3 | mtmoon3 | Zubat 12, Ekans 12 | Zubat 11, Ekans 11, Sandshrew 11 |
| 4 | mtmoon3 | Raticate 16 | Raticate 14, Zubat 14, Ekans 14 |
| 5 | ceruleancity | Machop 17, Drowzee 17 | Machop 16, Drowzee 16, Ekans 16 |
| 6 | Route 24 | Ekans 15, Zubat 15 | Ekans 14, Zubat 14, Rattata 14 |
| 7 | celadongamecorner | Raticate 20, Zubat 20 | Raticate 19, Zubat 19, Koffing 19 |
| 8 | Rocket Hideout B1F | Drowzee 21, Machop 21 | Drowzee 20, Machop 20, Grimer 20 |
| 9 | Rocket Hideout B1F | Raticate 21, Raticate 21 | Raticate 20, Zubat 20, Drowzee 20 |
| 10 | Rocket Hideout B1F | Grimer 20, Koffing 20, Koffing 20 | Grimer 20, Koffing 20, Drowzee 20 |
| 11 | Rocket Hideout B1F | Rattata 19, Raticate 19, Raticate 19, Rattata 19 | Rattata 19, Ekans 19, Zubat 19, Raticate 19 |
| 12 | Rocket Hideout B1F | Grimer 22, Koffing 22 | Grimer 21, Koffing 21, Raticate 21 |
| 13 | Rocket Hideout B2F | Zubat 17, Koffing 17, Grimer 17, Zubat 17, Raticate 17 | Zubat 17, Koffing 17, Grimer 17, Ekans 17, Rattata 17 |
| 14 | Rocket Hideout B3F | Rattata 20, Raticate 20, Drowzee 20 | Raticate 20, Drowzee 20, Koffing 20 |
| 15 | Rocket Hideout B3F | Machop 21, Machop 21 | Machop 20, Drowzee 20, Raticate 20 |
| 16 | Rocket Hideout B4F | Sandshrew 23, Ekans 23, Sandslash 23 | Sandshrew 23, Drowzee 23, Sandslash 23 |
| 17 | Rocket Hideout B4F | Ekans 23, Sandshrew 23, Arbok 23 | Ekans 23, Grimer 23, Arbok 23 |
| 18 | Rocket Hideout B4F | Koffing 21, Zubat 21 | Koffing 20, Zubat 20, Drowzee 20 |
| 19 | Pokémon Tower 7F | Zubat 25, Zubat 25, Golbat 25 | Zubat 25, Raticate 25, Golbat 25 |
| 20 | Pokémon Tower 7F | Koffing 26, Drowzee 26 | Koffing 25, Hypno 25, Golbat 25 |
| 21 | Pokémon Tower 7F | Zubat 23, Rattata 23, Raticate 23, Zubat 23 | Golbat 23, Rattata 23, Raticate 23, Drowzee 23 |
| 22 | Silph Co. 2F | Cubone 29, Zubat 29 | Marowak 28, Golbat 28, Grimer 28 |
| 23 | Silph Co. 2F | Golbat 25, Zubat 25, Zubat 25, Raticate 25, Zubat 25 | Golbat 25, Raticate 25, Drowzee 25, Koffing 25, Arbok 25 |
| 24 | Silph Co. 3F | Raticate 28, Hypno 28, Raticate 28 | Raticate 28, Hypno 28, Arbok 28 |
| 25 | Silph Co. 4F | Machop 29, Drowzee 29 | Machoke 28, Hypno 28, Golbat 28 |
| 26 | Silph Co. 4F | Ekans 28, Zubat 28, Cubone 28 | Arbok 28, Golbat 28, Marowak 28 |
| 27 | Silph Co. 5F | Arbok 33 | Arbok 31, Golbat 31, Grimer 31 |
| 28 | Silph Co. 5F | Hypno 33 | Hypno 31, Raticate 31, Koffing 31 |
| 29 | Silph Co. 6F | Machop 29, Machoke 29 | Machop 28, Machoke 28, Hypno 28 |
| 30 | Silph Co. 6F | Zubat 28, Zubat 28, Golbat 28 | Zubat 28, Koffing 28, Golbat 28 |
| 31 | Silph Co. 7F | Raticate 26, Arbok 26, Koffing 26, Golbat 26 | Raticate 26, Arbok 26, Koffing 26, Golbat 26 |
| 32 | Silph Co. 7F | Cubone 29, Cubone 29 | Marowak 28, Hypno 28, Golbat 28 |
| 33 | Silph Co. 7F | Sandshrew 29, Sandslash 29 | Sandshrew 28, Sandslash 28, Koffing 28 |
| 34 | Silph Co. 8F | Raticate 26, Zubat 26, Golbat 26, Rattata 26 | Raticate 26, Zubat 26, Golbat 26, Grimer 26 |
| 35 | Silph Co. 8F | Weezing 28, Golbat 28, Koffing 28 | Koffing 28, Golbat 28, Weezing 28 |
| 36 | Silph Co. 9F | Drowzee 28, Grimer 28, Machop 28 | Hypno 28, Grimer 28, Machoke 28 |
| 37 | Silph Co. 9F | Golbat 28, Drowzee 28, Hypno 28 | Golbat 28, Drowzee 28, Hypno 28 |
| 38 | Silph Co. 10F | Machoke 33 | Machoke 31, Golbat 31, Arbok 31 |
| 39 | Silph Co. 11F | Rattata 25, Rattata 25, Zubat 25, Rattata 25, Ekans 25 | Raticate 25, Golbat 25, Arbok 25, Drowzee 25, Koffing 25 |
| 40 | Silph Co. 11F | Cubone 32, Drowzee 32, Marowak 32 | Cubone 32, Hypno 32, Marowak 32 |

</details>

<details>
<summary>Cooltrainer M — 6 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Viridian Gym | Nidorino 39, Nidoking 39 | Nidorino 38, Nidoking 38, Sandslash 38 |
| 2 | Victory Road 3F | Exeggutor 43, Cloyster 43, Arcanine 43 | Exeggutor 42, Cloyster 42, Arcanine 42, Claydol 42 |
| 3 | Victory Road 3F | Kingler 43, Tentacruel 43, Blastoise 43 | Kingler 42, Lapras 42, Blastoise 42, Toxapex 42 |
| 4 | Victory Road 1F | Ivysaur 42, Wartortle 42, Charmeleon 42, Charizard 42 | Venusaur 41, Blastoise 41, Charmeleon 41, Charizard 41, Pupitar 41 |
| 5 | Viridian Gym | Sandslash 39, Dugtrio 39 | Sandslash 38, Dugtrio 38, Rhyhorn 38 |
| 6 | Viridian Gym | Rhyhorn 43 | Rhydon 41, Sandslash 38, Arbok 38 |

</details>

<details>
<summary>Cooltrainer F — 4 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Celadon Gym | Weepinbell 24, Gloom 24, Ivysaur 24 | Weepinbell 24, Gloom 24, Ivysaur 24 |
| 2 | Victory Road 3F | Bellsprout 43, Weepinbell 43, Victreebel 43 | Victreebel 42, Parasect 42, Tangela 42, Venomoth 42 |
| 3 | Victory Road 3F | Parasect 43, Dewgong 43, Chansey 43 | Parasect 42, Dewgong 42, Chansey 42, Mr. Mime 42 |
| 4 | Victory Road 1F | Persian 44, Ninetales 44 | Persian 42, Ninetales 42, Raichu 42, Tangela 42 |

</details>

<details>
<summary>Gentleman — 4 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | S.S. Anne 1F rooms | Growlithe 18, Growlithe 18 | Growlithe 17, Ponyta 17, Vulpix 17 |
| 2 | S.S. Anne 1F rooms | Nidoran♂ 19, Nidoran♀ 19 | Nidoran♂ 18, Nidoran♀ 18, Ponyta 18 |
| 3 | S.S. Anne 2F rooms, Vermilion Gym | Pikachu 23 | Pikachu 21, Magnemite 21, Voltorb 21 |
| 4 | S.S. Anne 2F rooms | Growlithe 17, Ponyta 17 | Growlithe 16, Ponyta 16, Eevee 16 |

</details>

<details>
<summary>Channeler — 16 teams</summary>

| Record | Location(s) | Current team | Proposed team |
| --- | --- | --- | --- |
| 1 | Pokémon Tower 3F | Gastly 23 | Gastly 21, Cubone 21, Drowzee 21 |
| 2 | Pokémon Tower 3F | Gastly 24 | Gastly 22, Drowzee 22, Exeggcute 22 |
| 3 | Pokémon Tower 3F | Gastly 22 | Gastly 20, Cubone 20, Exeggcute 20 |
| 4 | Pokémon Tower 4F | Gastly 24 | Gastly 22, Cubone 22, Sableye 22 |
| 5 | Pokémon Tower 4F | Gastly 23, Gastly 23 | Gastly 22, Drowzee 22, Cubone 22 |
| 6 | Pokémon Tower 4F | Gastly 22 | Gastly 20, Exeggcute 20, Drowzee 20 |
| 7 | Pokémon Tower 5F | Haunter 23 | Gastly 22, Haunter 22 |
| 8 | Pokémon Tower 5F | Gastly 22 | Gastly 20, Cubone 20, Drowzee 20 |
| 9 | Pokémon Tower 5F | Gastly 24 | Gastly 22, Exeggcute 22, Sableye 22 |
| 10 | Pokémon Tower 5F | Haunter 22 | Gastly 21, Haunter 21 |
| 11 | Pokémon Tower 6F | Gastly 22, Gastly 22, Gastly 22 | Gastly 22, Drowzee 22, Cubone 22 |
| 12 | Pokémon Tower 6F | Gastly 24 | Gastly 22, Cubone 22, Exeggcute 22 |
| 13 | Pokémon Tower 6F | Gastly 24 | Gastly 22, Drowzee 22, Sableye 22 |
| 14 | Saffron Gym | Gastly 34, Haunter 34 | Gastly 33, Haunter 33, Marowak 33 |
| 15 | Saffron Gym | Haunter 38 | Haunter 36, Sableye 36, Hypno 36 |
| 16 | Saffron Gym | Gastly 33, Gastly 33, Haunter 33 | Haunter 33, Parasect 33, Hypno 33 |

</details>
