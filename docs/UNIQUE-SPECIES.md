# Unique species version: 172 Pokémon

This branch adds 21 separate species at Pokédex numbers 152–172. The 151 original species and their custom front sprites remain available. Fossil and ghost display IDs and the existing special MissingNo battle are preserved.

**Start a new save.** Expanding both Pokédex bitfields from 19 to 22 bytes changes the save layout. Do not reuse saves from the 151-species version. Keep that version and its saves separately. Link trading/battling with the old version is untested and unsupported for these new species.

Each new species copies the source's stats, starting/level-up/TM/HM moves, growth, experience yield, cry, Pokédex description, palette, party icon, back sprite and evolution destinations. Evolutions still lead to the original species (for example, unique Bulbasaur evolves into the original Ivysaur). These are new species IDs, not replacements or a new evolution family. Display names are shortened to fit the game's 10-character limit; the filenames below identify the full variant.

Type overrides: Fighting Geodude and Fighting Goldeen are pure Fighting; Rock Kakuna is pure Rock; Poison Grimer remains pure Poison. All other types match their sources. Big Tentacool has catch rate 60 instead of the normal 190; other catch rates are copied.

## Where to find them

Trainer variants are exclusive to the listed trainers. The requested habitats use a separate unbiased 1-in-100 roll per eligible variant, not the original 3/256 slot approximation. When habitats overlap, each variant keeps its own 1% share. The chance is per generated encounter/bite, not per step or rod cast. Ordinary encounter weights fill the remaining share.

“Dark cave” is interpreted as Rock Tunnel, with Omanyte also kept in Safari Zone water. Cerulean means Cerulean City water, not Routes 24/25. New surfing pools in Cerulean City and the four Safari Zone areas use their existing local fishing species as ordinary encounters. Fishing variants use Good/Super Rod pools where eligible; Old Rod remains Magikarp-only. Land/surf and rod pools are checked separately, so Fighting Goldeen no longer appears in Route 12 grass. Tentacool and Geodude variants follow every matching original habitat; Kakuna follows the version-specific original land tables; Nidoran follows both genders' original land tables. Safari's postgame randomization runs before the unique roll so it does not reduce the new 1% chances. Repel still works normally.

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
| 166 | omanyte_unique | OMANYTE U | Safari Zone water (surfing/Good Rod/Super Rod) and both Rock Tunnel floors: 1% (level 20) |
| 167 | onix_brock | B.ONIX | Brock (level 15) |
| 168 | raichu_unique | RAICHU U | Lt. Surge (level 25) |
| 169 | squirtle_unique | SQUIRTLE U | Cerulean City water (surfing/Good Rod/Super Rod): 1% (level 10) |
| 170 | tangela_erika | E.TANGELA | Erika (level 29) |
| 171 | tentacool_big | BIGTENTACL | Every habitat/rod pool containing normal Tentacool: 1%; catch rate 60 (normal 190) |
| 172 | venusaur_erika | E.VENUSAUR | Erika (level 33) |

## Build and validation

Build with the project's pinned RGBDS 0.3.3 toolchain and `make -j2 red blue`. Both ROMs remain 1 MiB. New front and original back graphics are stored together in bank $32; only the new species use this bank lookup. Source PNGs are retained unchanged in `pic/unique/source/`; the import PNGs composite transparency over white and pad Geodude from 46×46 to 48×48 without scaling its pixels.

Run `python3 tools/test_unique_species.py` with `pyboy==2.9.0` installed. The suite checks all species' index/dex round-trips and loaded headers, cloned data and type overrides, routed front/back decompression against direct decoding, Hall of Fame buffer guards, adding every new species to a party, and expanded Pokédex flag writes and SRAM save/load. It runs on both ROMs. These are automated engine tests, not a full manual playthrough or link compatibility test.

Encounter pools are generated with `python3 tools/generate_unique_encounters.py` from `data/unique_encounter_rules.json` and the actual Red/Blue habitat tables. After editing rules or ordinary habitats, regenerate them. The emulator suite exhausts all 100 rolls for every pool, checks unbiased random reduction and rejection, both encounter wrappers, rod identity, and the Pokédex AREA maps.

The patch workflow builds verified original ROMs from the pinned upstream disassembly, creates BPS patches, applies each patch and compares the result with the custom build. Downloads contain patches and documentation only. The old `make compare` hashes predate this project's changes and are not expected to match this version.
