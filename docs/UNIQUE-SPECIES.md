# Unique species version: 172 Pokémon

This branch adds 21 separate species at Pokédex numbers 152–172. The 151 original species and their custom front sprites remain available. Fossil and ghost display IDs and the existing special MissingNo battle are preserved.

**Start a new save.** Expanding both Pokédex bitfields from 19 to 22 bytes changes the save layout. Do not reuse saves from the 151-species version. Keep that version and its saves separately. Link trading/battling with the old version is untested and unsupported for these new species.

Each new species copies the source's stats, starting/level-up/TM/HM moves, growth, catch rate, experience yield, cry, Pokédex description, palette, party icon, back sprite and evolution destinations. Evolutions still lead to the original species (for example, unique Bulbasaur evolves into the original Ivysaur). These are new species IDs, not replacements or a new evolution family. Display names are shortened to fit the game's 10-character limit; the filenames below identify the full variant.

Type overrides: Fighting Geodude and Fighting Goldeen are pure Fighting; Rock Kakuna is pure Rock; Poison Grimer remains pure Poison. All other types match their sources.

## Where to find them

Trainer variants are exclusive to the listed trainers. Wild variants occupy the last encounter slot (3/256, approximately 1.2% of encounters in the listed grass/cave/surf table) in both Red and Blue. Route 12's Fighting Goldeen is a grass encounter, not a fishing encounter. Existing encounter rates and all other table slots are unchanged. These wild locations are initial defaults and can be adjusted independently.

| Dex | Variant file | In-game name | Availability |
| --- | --- | --- | --- |
| 152 | blastoise_unique | BLASTOISEU | seafoamislandb4 (level 35, grass/cave, rarest slot) |
| 153 | bulbasaur_unique | BULBASAURU | route4 (level 10, grass/cave, rarest slot) |
| 154 | chansey_unique | CHANSEY U | safarizone2 (level 26, grass/cave, rarest slot) |
| 155 | charmander_unique | CHARMANDRU | route24 (level 12, grass/cave, rarest slot) |
| 156 | ditto_happy | HAPPYDITTO | route23 (level 33, grass/cave, rarest slot) |
| 157 | geodude_fighting | F.GEODUDE | rocktunnel1 (level 16, grass/cave, rarest slot) |
| 158 | goldeen_fighting | F.GOLDEEN | route12 (level 22, grass/cave, rarest slot) |
| 159 | grimer_poison | P.GRIMER | Koga (level 39) |
| 160 | ivysaur_erika | E.IVYSAUR | Erika (level 33) |
| 161 | kakuna_rock_type | R.KAKUNA | viridianforest (level 6, grass/cave, rarest slot) |
| 162 | marowak_unique | MAROWAK U | victoryroad2 (level 40, grass/cave, rarest slot) |
| 163 | nidoking_unique | NIDOKING U | Giovanni, Viridian Gym (level 47) |
| 164 | nidoking_unique2 | NIDOKING 2 | safarizone1 (level 30, grass/cave, rarest slot) |
| 165 | nidoranm_unique | NIDORAN U | safarizonecenter (level 24, grass/cave, rarest slot) |
| 166 | omanyte_unique | OMANYTE U | seafoamislandb3 (level 30, grass/cave, rarest slot) |
| 167 | onix_brock | B.ONIX | Brock (level 15) |
| 168 | raichu_unique | RAICHU U | Lt. Surge (level 25) |
| 169 | squirtle_unique | SQUIRTLE U | route6 (level 12, grass/cave, rarest slot) |
| 170 | tangela_erika | E.TANGELA | Erika (level 29) |
| 171 | tentacool_big | BIGTENTACL | route21 (level 30, surfing, rarest slot) |
| 172 | venusaur_erika | E.VENUSAUR | Erika (level 33) |

## Build and validation

Build with the project's pinned RGBDS 0.3.3 toolchain and `make -j2 red blue`. Both ROMs remain 1 MiB. New front and original back graphics are stored together in bank $32; only the new species use this bank lookup. Source PNGs are retained unchanged in `pic/unique/source/`; the import PNGs composite transparency over white and pad Geodude from 46×46 to 48×48 without scaling its pixels.

Run `python3 tools/test_unique_species.py` with `pyboy==2.9.0` installed. The suite checks all species' index/dex round-trips and loaded headers, cloned data and type overrides, routed front/back decompression against direct decoding, Hall of Fame buffer guards, adding every new species to a party, and expanded Pokédex flag writes and SRAM save/load. It runs on both ROMs. These are automated engine tests, not a full manual playthrough or link compatibility test.

The patch workflow builds verified original ROMs from the pinned upstream disassembly, creates BPS patches, applies each patch and compares the result with the custom build. Downloads contain patches and documentation only. The old `make compare` hashes predate this project's changes and are not expected to match this version.
