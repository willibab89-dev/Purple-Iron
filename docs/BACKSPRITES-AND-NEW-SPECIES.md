> Historical guide: the current build has 183 species and requires a fresh save. See [SEVEN-MORE-SPECIES.md](SEVEN-MORE-SPECIES.md). Save compatibility statements below apply only to the earlier build.

# Back sprites and four additional Pokémon: 176 species

Cumulative Red/Blue BPS patches include all prior front sprites, unique species, encounters, crit/freeze changes, the completed move overhaul, thematic TM compatibility and TM51–TM60 with their shops/prices. This patch imports the supplied back sprites, updates Snorlax's front, and adds Mareanie, Toxapex, Miltank and Sableye.

## Updating and save compatibility

Download `pokemon-backs-and-new-species-bps` from the successful GitHub Actions run. Apply the matching BPS to an unmodified original Red/Blue ROM, not an already patched ROM. Back up your save first.

**Valid saves from the existing 172-species build remain compatible.** Both 172 and 176 species use the same 22-byte Pokédex fields; the four new species use the previously unused final four bits. Existing species/item IDs and permanent save addresses remain unchanged. Old 151-species saves remain incompatible. Link play requires identical ROM revisions, and the existing forced-switch link restriction remains.

There are now 176 species: 151 originals, 21 existing unique variants and four additional species. No move IDs are added; all 219 move records and 60 TMs/five HMs remain. The diploma still requires the original 150 non-Mew species; the additional species do not substitute for missing originals.

## Imported graphics

The ZIP contained 309 PNGs: 155 fronts and 154 backs. The 151 original fronts match the active set except the approved Snorlax update. The supplied backs include 150 originals plus the four additional species. **Kangaskhan has no supplied back sprite, so its original Gen 1 back is retained.**

The supplied original backs are routed to 150 replacement streams. The 21 unique variants share their sources' new backs as they previously shared their sources' old backs. The four additional species have their own fronts/backs. This gives 175 full-resolution back renderings and one original Kangaskhan rendering across 176 species.

The 48-pixel back art is preserved without shrinking or interpolation. White padding fits it into the 56×56 battle frame; the 47×48 Dragonair image receives the corresponding blank border rather than being stretched. Four-shade normalization merges near-white 248/255 values and the stray near-black shade in a few five-shade source PNGs to meet the hardware palette limit. Original source PNGs are retained with recorded hashes. Filename mappings handle `ratatta_b`, `nidorono_b`, `wigglypuff_b`, the space in `ekans_b .png`, Mr. Mime punctuation and Nidoran letter case.

The back loader now accepts full-size streams and bypasses the old 2× enlargement for these images. Kangaskhan and the human trainer/Old Man backs retain their original scaling paths. Front rendering, Hall of Fame and Transform use the normal graphics routines. Original front art is otherwise preserved; the existing 21 unique fronts remain unchanged.

## New species and encounters

| Dex | Pokémon | Type | HP | Atk | Def | Speed | Special | Obtaining |
| ---: | --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| 173 | Mareanie | Poison/Water | 50 | 53 | 62 | 45 | 48 | 5% Super Rod encounters on Routes 19/20, level 25 |
| 174 | Toxapex | Poison/Water | 50 | 63 | 152 | 35 | 100 | Evolve Mareanie at level 38 |
| 175 | Miltank | Normal | 95 | 80 | 105 | 100 | 55 | 2% grass encounters on Routes 14/15, level 28 |
| 176 | Sableye | Ghost | 50 | 75 | 75 | 50 | 65 | 2% encounters on both Rock Tunnel floors, level 18 |

Gen 1 has a single Special stat, so the modern split is adapted: Mareanie 48 and Miltank 55 use a rounded average, Toxapex uses 100 rather than importing 142 as both offense and defense, and Sableye remains at 65. Sableye is pure Ghost because Dark typing is not present. No abilities, held items or new battle mechanics are added.

Miltank is female-only. The other three use the existing DV-based 50/50 gender rules. Cries reuse fitting existing sounds (Tentacool, Tentacruel, Tauros and Gastly respectively); palettes and party icons use the existing Gen 1 assets. Miltank uses Recover for milk-themed recovery without adding a Milk Drink move.

Encounter rates use the existing unbiased 100-outcome system. The prior unique species retain each of their existing 1% shares when pools overlap: Rock Tunnel still has 1% unique Omanyte and 1% Fighting Geodude plus the new 2% Sableye. Routes 19/20 retain their existing eligible fishing variants alongside 5% Mareanie. The rates apply to generated encounters/bites, not steps or rod casts. Old/Good Rod behavior is unchanged. Repel still applies normally. Toxapex has no direct wild encounter in this patch.

## New species learnsets and machine access

All old species' stats, typing, moves and evolution destinations are unchanged. The four new species have independent data; their defaults can be balanced in the planned Pokémon review.

### Mareanie

Starting moves: Poison Sting, Peck.

| Level | Move |
| ---: | --- |
| 8 | Water Gun |
| 12 | Bite |
| 16 | Pin Missile |
| 20 | Poison Fang |
| 26 | Toxic |
| 30 | Venoshock |
| 34 | Brine |
| 38 | Recover |
| 44 | Poison Tail |

Original machines (source numbering): TM06, TM11, TM12, TM34, TM44, TM50, HM03.

Additional machines: TM53 Brine, TM54 Venoshock.

Evolution: level 38 → Toxapex.

### Toxapex

Starting moves: Poison Sting, Peck, Harden, Water Gun.

| Level | Move |
| ---: | --- |
| 12 | Bite |
| 16 | Pin Missile |
| 20 | Poison Fang |
| 24 | Brine |
| 28 | Toxic |
| 32 | Venoshock |
| 36 | Stockpile |
| 40 | Recover |
| 44 | Poison Tail |
| 48 | Acid Armor |
| 52 | Hydro Pump |

Original machines (source numbering): TM06, TM11, TM12, TM34, TM44, TM50, HM03.

Additional machines: TM53 Brine, TM54 Venoshock.

### Miltank

Starting moves: Tackle, Growl, Defense Curl.

| Level | Move |
| ---: | --- |
| 8 | Stomp |
| 15 | Bide |
| 22 | Body Slam |
| 28 | Facade |
| 34 | Bulk Up |
| 40 | Double Edge |
| 46 | Recover |
| 52 | Earthquake |

Original machines (source numbering): TM01, TM05, TM08, TM09, TM10, TM15, TM20, TM26, TM32, TM34, TM40, TM44, TM48, HM04.

Additional machines: TM52 Facade, TM56 Bulk Up, TM57 Rock Tomb.

### Sableye

Starting moves: Scratch, Leer, Astonish.

| Level | Move |
| ---: | --- |
| 8 | Lick |
| 14 | Night Shade |
| 18 | Confuse Ray |
| 24 | Shadow Leech |
| 30 | Curse |
| 34 | Punishment |
| 42 | Recover |
| 48 | Slash |
| 54 | Psych Up |

Original machines (source numbering): TM01, TM28, TM31, TM32, TM39, TM44, TM48, TM50, HM04.

Additional machines: TM52 Facade, TM55 Aerial Ace, TM57 Rock Tomb, TM58 Will O Wisp, TM60 Curse.

## Implementation and verification

The new internal species IDs reuse four previously unused MissingNo slots: 127, 134, 135 and 137. No existing valid Pokémon is displaced. The misleading old `$8A` comment on the last free slot was corrected; Kingler remains at ID 138 with its original data. New dex entries are appended at 173–176. Original fossil/ghost display IDs and the special MissingNo battle remain intact.

Back-stream lookup is independent of old header pointers, preserving the old data layout. Imported originals are packed in banks $36–$38; the additional species use bank $3E. The old sprite bank-selection logic is retained for legacy/front paths in a roomier bank, with separate handling for the four new species. Decompression does not overwrite the battle-effect chance/RNG scratch. Old header fixtures permit only changed sprite pointers caused by asset placement; old stats and move/TM data remain checked.

Both ROMs build at 1 MiB. Automated PyBoy tests run all 176 back-loader paths and compare all supplied stream pixels to their prepared PNGs, with sprite/Hall of Fame overrun guards and preservation of battle-effect scratch. New fronts and Snorlax are checked through the actual front renderer. Tests verify all dex/header round-trips, four party additions and generated moves/PP, all 16 gender DV cases, the level-38 evolution record, all final Pokédex bits and save/load, stable saved-field addresses, old stats/data preservation, and exact encounter shares. The existing encounter suite exhausts all 100 outcomes in every eligible pool and checks AREA maps. Expanded TM suites now cover all 176 species.

The prior move, status, crit, freeze, phazing, transformation, item teaching, price, vendor and save suites remain in CI. Each BPS is applied to a verified original and compared byte for byte with the custom build. These are automated engine/pixel checks, not a full manual playthrough or link test. Downloads contain patches and documentation only, not full ROMs.
