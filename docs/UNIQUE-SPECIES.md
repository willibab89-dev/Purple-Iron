# Unique species version: 172 Pokémon

See `MOVE-PATCH-5.md` for the latest cumulative move changes and remaining work. Earlier patch notes are retained for reference.

This branch adds 21 separate species at Pokédex numbers 152–172. The 151 original species and their custom front sprites remain available. Fossil and ghost display IDs and the existing special MissingNo battle are preserved.

**A new save is required only when upgrading from the old 151-species version.** The 172-species layout uses 22-byte Pokédex bitfields. Saves from previous 172-species patches remain compatible. Keep a backup; link battles require matching ROM revisions.

Each new species copies the source's stats, starting/level-up/TM/HM moves, growth, experience yield, cry, Pokédex description, palette, party icon, back sprite and evolution destinations. Evolutions still lead to the original species (for example, unique Bulbasaur evolves into the original Ivysaur). These are new species IDs, not replacements or a new evolution family. Display names are shortened to fit the game's 10-character limit; the filenames below identify the full variant.

Type overrides: Fighting Geodude and Fighting Goldeen are pure Fighting; Rock Kakuna is pure Rock; Poison Grimer remains pure Poison. All other types match their sources. Big Tentacool has catch rate 60 instead of the normal 190; other catch rates are copied.

## Where to find them

Trainer variants are exclusive to the listed trainers. The requested habitats use a separate unbiased 1-in-100 roll per eligible variant, not the original 3/256 slot approximation. When habitats overlap, each variant keeps its own 1% share. The chance is per generated encounter/bite, not per step or rod cast. Ordinary encounter weights fill the remaining share.

Unique Omanyte appears only on the two Rock Tunnel floors. Unique Squirtle appears only in grass on Routes 24/25. Cerulean City and Safari Zone surfing pools remain unchanged from the original version. Fishing variants use Good/Super Rod pools where eligible; Old Rod remains Magikarp-only. Land/surf and rod pools are checked separately, so Fighting Goldeen no longer appears in Route 12 grass. Tentacool and Geodude variants follow every matching original habitat; Kakuna follows the version-specific original land tables; Nidoran follows both genders' original land tables. Safari's postgame randomization runs before the unique roll so it does not reduce the new 1% chances. Repel still works normally.

Unique Marowak and the second Nidoking retain their previous rarest-slot encounters (3/256, about 1.2%); their locations were not changed in this update.

| Dex | Variant file | In-game name | Availability |
| --- | --- | --- | --- |
| 152 | blastoise_unique | BLASTOISEU | Rival with Squirtle: Silph Co., Route 22, Champion (levels 40/53/65); trainer-only |
| 153 | bulbasaur_unique | BULBASAURU | Viridian Forest: 1% land encounters (level 6) |
| 154 | chansey_unique | CHANSEY U | Cerulean Cave, all floors: 1% land encounters (level 55) |
| 155 | charmander_unique | CHARMANDRU | Mt. Moon, all floors: 1% land encounters (level 10) |
| 156 | ditto_happy | HAPPYDITTO | Pokémon Mansion on Cinnabar, all floors: 1% land encounters (level 30) |
| 157 | geodude_fighting | F.GEODUDE | Every land/surf table containing normal Geodude: 1% |
| 158 | goldeen_fighting | F.GOLDEEN | Every habitat/rod pool containing normal Goldeen: 1% |
| 159 | grimer_poison | P.GRIMER | Koga (level 39) |
| 160 | ivysaur_erika | E.IVYSAUR | Erika (level 33) |
| 161 | kakuna_rock_type | R.KAKUNA | Every land table containing normal Kakuna: 1% |
| 162 | marowak_unique | MAROWAK U | victoryroad2 (level 40, grass/cave, rarest slot) |
| 163 | nidoking_unique | NIDOKING U | Giovanni, Viridian Gym (level 47) |
| 164 | nidoking_unique2 | NIDOKING 2 | safarizone1 (level 30, grass/cave, rarest slot) |
| 165 | nidoranm_unique | NIDORAN U | Every land table containing either Nidoran gender: 1% |
| 166 | omanyte_unique | OMANYTE U | Rock Tunnel, both floors: 1% land encounters (level 20) |
| 167 | onix_brock | B.ONIX | Brock (level 15) |
| 168 | raichu_unique | RAICHU U | Lt. Surge (level 25) |
| 169 | squirtle_unique | SQUIRTLE U | Routes 24 and 25: 1% grass encounters (level 10) |
| 170 | tangela_erika | E.TANGELA | Erika (level 29) |
| 171 | tentacool_big | BIGTENTACL | Every habitat/rod pool containing normal Tentacool: 1%; catch rate 60 (normal 190) |
| 172 | venusaur_erika | E.VENUSAUR | Erika (level 33) |

## Freeze and natural thawing

Frozen Pokémon now have an exact 20% chance to thaw immediately before an attempted move, on both sides of battle. A successful thaw prints “thawed out!” and permits the selected move that turn, unless another condition such as flinching, trapping or recharge prevents it. Frozen Pokémon can select a fresh move before the roll; they do not reuse the preceding turn's move. Cancelling the move menu does not grant extra rolls. Using an item or switching does not make an action-time thaw roll.

Thawing clears the active Pokémon's freeze flag and its corresponding party slot. Wild opponents do not write to trainer-party data. Switching itself still does not cure freeze. Existing freezing chances, Ice-type protection, status exclusivity, healing items, Haze and Fire-based thawing are unchanged. No new counters or save-layout changes are needed.

The roll uses battle RNG, including the shared link-battle RNG, with rejection sampling (50 successful outcomes out of 250) rather than an approximation to 20%. Link play between different ROM revisions remains unsupported.

`python3 tools/test_freeze.py` checks both ROMs: all 250 accepted RNG outcomes for each side, rejection of 250–255, same-turn eligibility, other action blockers, correct party-slot synchronization, wild-party guards, preservation of PP/charging state when still frozen, and actual player/enemy move-selection paths. Text/UI endpoints are stubbed in memory during these automated engine tests.

## Critical-hit balance

Normal critical chance is unchanged: `floor(base Speed / 2) / 256`. Karate Chop, Razor Leaf, Crabhammer and Slash now multiply that threshold by 2 instead of 8. Focus Energy and Dire Hit share a counter: first successful use gives x2, second gives x3, third gives x4. Mixing the move and item advances the same counter. Further Focus Energy uses fail; a capped Dire Hit has no effect and is not consumed. The enemy uses the same rules, and its AI only treats Focus Energy as capped at x4.

The focus multiplier stacks multiplicatively with a high-crit move, for a maximum combined x8. The existing 255/256 (about 99.6%) probability cap remains: a fast Pokémon with both boosts can still reach that cap. No new cap on actual probability is imposed.

| Base Speed 100 | Normal move | High-crit move |
| --- | --- | --- |
| No focus | 50/256 (19.5%) | 100/256 (39.1%) |
| One use (x2) | 100/256 (39.1%) | 200/256 (78.1%) |
| Two uses (x3) | 150/256 (58.6%) | 255/256 (99.6%) |
| Three uses (x4) | 200/256 (78.1%) | 255/256 (99.6%) |

Switching, replacement after fainting, starting a new battle, and Haze reset the shared boost. The counter uses previously unused volatile battle-status bits, so this update adds no WRAM bytes or save-layout changes. Status moves and fixed-damage moves still cannot critically hit. Critical damage itself is unchanged.

Run `python3 tools/test_critical_hits.py` with PyBoy installed. It checks 10,240 thresholds per ROM across every base Speed value, both sides, all four high-crit moves and all focus stages; exhausts the RNG range for representative normal/high-crit attacks; and tests mixed move/item uses, cap behavior, Haze, initialization and the actual send-out reset instructions. Text and audio endpoints are stubbed in memory for these engine tests; ROM files are not modified by the test harness.

## Build and validation

Build with the project's pinned RGBDS 0.3.3 toolchain and `make -j2 red blue`. Both ROMs remain 1 MiB. New front and original back graphics are stored together in bank $32; only the new species use this bank lookup. Source PNGs are retained unchanged in `pic/unique/source/`; the import PNGs composite transparency over white and pad Geodude from 46×46 to 48×48 without scaling its pixels.

Run `python3 tools/test_unique_species.py` with `pyboy==2.9.0` installed. The suite checks all species' index/dex round-trips and loaded headers, cloned data and type overrides, routed front/back decompression against direct decoding, Hall of Fame buffer guards, adding every new species to a party, and expanded Pokédex flag writes and SRAM save/load. It runs on both ROMs. These are automated engine tests, not a full manual playthrough or link compatibility test.

Encounter pools are generated with `python3 tools/generate_unique_encounters.py` from `data/unique_encounter_rules.json` and the actual Red/Blue habitat tables. After editing rules or ordinary habitats, regenerate them. The emulator suite exhausts all 100 rolls for every pool, checks unbiased random reduction and rejection, both encounter wrappers, rod identity, and the Pokédex AREA maps.

The patch workflow builds verified original ROMs from the pinned upstream disassembly, creates BPS patches, applies each patch and compares the result with the custom build. Downloads contain patches and documentation only. The old `make compare` hashes predate this project's changes and are not expected to match this version.
