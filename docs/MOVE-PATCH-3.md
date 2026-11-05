# Move overhaul — patch 3

Cumulative Red/Blue BPS patches. Includes all previous front sprites, 21 new species and their encounters, crit/freeze changes, and move patches 1–2. Adds ten playable moves, with 95 level-up entries across 64 original species. Existing moves and their learning levels are retained; no TMs/HMs are replaced. Variant species inherit their originals' additions through their shared learnsets.

## Download and update

Download `pokemon-move-patch-3-bps` from the successful GitHub Actions run. Apply the matching Red/Blue BPS to its verified unmodified original ROM, not to a previously patched ROM. Existing 172-species saves remain compatible; no save/RAM layout fields changed. Old 151-species saves remain incompatible. Keep a backup and heal at a Pokemon Center after updating to refresh PP. Link battles require identical ROM revisions.

Existing party Pokemon do not automatically forget moves or receive past-level additions. Use the move relearner in the Saffron house below Copycat's house for eligible missed moves; its existing requirements/cost still apply. Newly generated wild/trainer Pokemon use the expanded learnsets where their existing move-generation rules apply; trainer parties with explicit moves retain those overrides.

## New moves

Accuracy for self-targeting moves is unused. Other accuracy rules are unchanged. About 30% flinch is the established 77/256 effect. Gen 1 physical/special categories still follow type: Grass is special, Bug/Ghost/Fighting/Rock are physical.

| ID | Move | Type | Power | Accuracy | PP | Effect | Reused animation |
| ---: | --- | --- | ---: | ---: | ---: | --- | --- |
| 166 | GIGA DRAIN | Grass | 80 | 100 | 10 | Heals 50% of damage dealt. | Mega Drain |
| 167 | SYNTHESIS | Grass | — | — | 10 | Restores half maximum HP; no weather scaling. | Recover |
| 168 | MEGAHORN | Bug | 100 | 85 | 10 | Ordinary damage. | Horn Attack |
| 169 | X-SCISSOR | Bug | 65 | 95 | 15 | High crit (existing ×2 bonus). | Slash |
| 170 | ASTONISH | Ghost | 30 | 100 | 20 | About 30% flinch; useful only before the target acts. | Lick |
| 171 | DRAIN PUNCH | Fighting | 60 | 100 | 10 | Heals 50% of damage dealt. | Mega Punch |
| 172 | STONE EDGE | Rock | 75 | 85 | 15 | High crit (existing ×2 bonus). | Rock Throw |
| 173 | ROCK POLISH | Rock | — | — | 15 | User Speed +2. | Agility |
| 174 | ICE ARMOR | Ice | — | — | 10 | User Defense +2. | Barrier |
| 175 | ROOST | Flying | — | — | 10 | Restores half maximum HP; no temporary type removal. | Recover |

Healing, draining and stat moves reuse Shin's established mechanics, including drain's Substitute restriction, normal stat caps, and recovery failing at full HP. Roost/Synthesis do not cause Rest's sleep or status cure. No abilities or weather system is added.

## Learnsets

These are additions, not replacements. Levels were moved to the next unused level when necessary to avoid two moves competing at the same level. Original levels/evolutions are unchanged.

| Pokemon | Added moves and levels |
| --- | --- |
| Aerodactyl | Rock Polish 25, Roost 40, Stone Edge 48 |
| Articuno | Ice Armor 40, Roost 50 |
| Beedrill | Megahorn 48 |
| Bellsprout | Synthesis 28, Giga Drain 40 |
| Bulbasaur | Synthesis 25, Giga Drain 42 |
| Cloyster | Ice Armor 34 |
| Cubone | Astonish 17 |
| Dewgong | Ice Armor 32 |
| Dodrio | Roost 32 |
| Doduo | Roost 28 |
| Drowzee | Astonish 13 |
| Exeggcute | Synthesis 35, Giga Drain 43 |
| Exeggutor | Synthesis 39, Giga Drain 46 |
| Farfetchd | Roost 28 |
| Fearow | Roost 30 |
| Gastly | Astonish 12 |
| Gengar | Astonish 12 |
| Geodude | Rock Polish 22, Stone Edge 40 |
| Gloom | Synthesis 32, Giga Drain 44 |
| Golbat | Roost 34 |
| Golem | Rock Polish 26, Stone Edge 48 |
| Graveler | Rock Polish 26, Stone Edge 44 |
| Haunter | Astonish 12 |
| Hitmonchan | Drain Punch 35 |
| Hypno | Astonish 13 |
| Ivysaur | Synthesis 29, Giga Drain 47 |
| Jynx | Ice Armor 35 |
| Kabuto | Rock Polish 28, Stone Edge 50 |
| Kabutops | Rock Polish 32, X Scissor 42, Stone Edge 47 |
| Kingler | X Scissor 39 |
| Krabby | X Scissor 36 |
| Lapras | Ice Armor 28 |
| Lickitung | Astonish 18 |
| Machamp | Drain Punch 40 |
| Machoke | Drain Punch 37 |
| Machop | Drain Punch 33 |
| Marowak | Astonish 17 |
| Moltres | Roost 50 |
| Nidoking | Megahorn 55 |
| Oddish | Synthesis 28, Giga Drain 40 |
| Omanyte | Rock Polish 28, Stone Edge 50 |
| Omastar | Rock Polish 32, Stone Edge 46 |
| Onix | Rock Polish 26, Stone Edge 44 |
| Paras | X Scissor 30, Giga Drain 38 |
| Parasect | X Scissor 34, Giga Drain 42 |
| Pidgeot | Roost 33 |
| Pidgeotto | Roost 29 |
| Pidgey | Roost 25 |
| Pinsir | X Scissor 34, Megahorn 48 |
| Poliwrath | Drain Punch 38 |
| Primeape | Drain Punch 42 |
| Rhydon | Rock Polish 34, Stone Edge 47, Megahorn 59 |
| Rhyhorn | Rock Polish 31, Stone Edge 43, Megahorn 53 |
| Scyther | X Scissor 36 |
| Seaking | Megahorn 46 |
| Seel | Ice Armor 32 |
| Spearow | Roost 26 |
| Tangela | Synthesis 33, Giga Drain 42 |
| Venusaur | Synthesis 33, Giga Drain 50 |
| Victreebel | Synthesis 36, Giga Drain 45 |
| Vileplume | Synthesis 36, Giga Drain 44 |
| Weepinbell | Synthesis 32, Giga Drain 44 |
| Zapdos | Roost 50 |
| Zubat | Roost 30 |

## Move-system groundwork

- Legacy move IDs 1–165 remain unchanged, including Struggle at 165. New IDs append at 166–175; 255 remains the no-action marker.
- New moves have an explicit animation map. Only move presentation uses it. Raw status/item/capture animations retain their original IDs, even when the numeric value overlaps a new move.
- Metronome can choose all complete new moves, but excludes zero, itself, Struggle, and out-of-range IDs. No incomplete future moves are inserted.
- A legacy name-lookup bug is fixed: only item names can be interpreted as TM/HM names. Future high move IDs will not be mistaken for machine items. Current names, learning, PP lookup and storage retain full move IDs.

## Validation

Both ROMs build and are checked in PyBoy. Tests cover new records/names and all old move records, every animation mapping boundary and unchanged raw special-animation IDs, all 256 Metronome candidate bytes on both actors, all 95 learning entries via daycare/PP and relearner routines, original learnset preservation, high move-ID party save/load, reused effects, full damage/effect routing and player PP consumption for all ten moves. Crit thresholds include both new high-crit moves. Existing species, encounter, save/load, crit, freeze and compound-move suites also run. Presentation and controlled crit/random variation are stubbed in battle-path tests; these are automated engine checks, not a full manual playthrough. BPS packages must reproduce each built ROM byte for byte when applied to verified originals.

## Remaining work

44 planned new moves and the previously listed 18 existing move redesigns remain pending. Automatic transformation, custom trapping/residuals, forced switching, conditional damage/crit, hybrid damage stats and the other later-patch designs are not introduced here. Punishment's future cap remains 160. See MOVE-PATCH-2-PLAN.md for accepted defaults and the design reference for the full target list.
