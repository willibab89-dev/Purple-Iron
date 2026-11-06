# Thematic TM compatibility

Cumulative Red/Blue patches include all sprites, 172 species, encounters, crit/freeze changes and the completed move overhaul through patch 8. This patch redistributes eight existing TMs according to the approved themes. Rest retains its previous compatibility. It adds no TM items, vendor stock, prices, move IDs, learnset entries or Pokémon stat changes.

## Updating

Download `pokemon-tm-distribution-bps` from the successful GitHub Actions run. Apply the matching BPS to an unmodified original Red/Blue ROM, not a previously patched ROM. Existing 172-species saves remain compatible; old 151-species saves do not. Back up saves before updating. This changes future TM teaching only: already-known moves are retained, and natural level-up/relearner moves are not removed. Mimic/Metronome/Transform behavior is unchanged.

## Rules and totals

Mew keeps all 50 TMs and all five HMs. Every unreviewed TM and all HM compatibility remain exactly as before. The themes use evolutionary family/design rather than hard stat thresholds; some adult flyers gain Double Team where their slow, flightless earlier stages do not. Existing special MissingNo data is unchanged.

| TM | Move | Theme | Original species before | Original species now |
| --- | --- | --- | ---: | ---: |
| TM06 | Toxic | Poison typing; Paras/Parasect and Mew exceptions | 145 | 36 |
| TM09 | Take Down | Body charges and physical tackling | 139 | 30 |
| TM10 | Double-Edge | Reckless committed physical attackers | 137 | 15 |
| TM20 | Rage | Aggressive, territorial or easily provoked | 145 | 27 |
| TM31 | Mimic | Trickery, imitation, performance or intelligence | 145 | 23 |
| TM32 | Double Team | Agile flight, quick movement or evasive mobility | 145 | 60 |
| TM34 | Bide | Endurance, patience and retaliation | 145 | 31 |
| TM50 | Substitute | Decoys, illusions, shedding or replaceable bodies | 145 | 28 |
| TM44 | Rest | Preserve existing broad access | 145 | 145 |

Rest's original exceptions remain Caterpie, Metapod, Weedle, Kakuna, Magikarp and Ditto. Giving Poison-type Weedle/Kakuna thematic Toxic access does not add other TMs to them. Rest has not been expanded to these exceptions as part of this compatibility pass.

Toxic is available to all original Poison-type Pokémon, Paras/Parasect and Mew. Each variant is checked against its actual typing: Rock Kakuna does not get Poison Kakuna's new Toxic access. Other reviewed TM access follows the source species. No extra TM access is inferred merely because a variant has Fighting typing.

## Exact compatible original species

Lists below include pre-evolutions explicitly; no additional family members should be inferred. Unique variants follow their originals except the Toxic/type rule above.

### TM06: Toxic

bulbasaur, ivysaur, venusaur, weedle, kakuna, beedrill, ekans, arbok, nidoranf, nidorina, nidoqueen, nidoranm, nidorino, nidoking, zubat, golbat, oddish, gloom, vileplume, paras, parasect, venonat, venomoth, bellsprout, weepinbell, victreebel, tentacool, tentacruel, grimer, muk, gastly, haunter, gengar, koffing, weezing, mew.

### TM09: Take Down

squirtle, wartortle, blastoise, sandshrew, sandslash, nidoranf, nidorina, nidoqueen, nidoranm, nidorino, nidoking, growlithe, arcanine, geodude, graveler, golem, ponyta, rapidash, doduo, dodrio, seel, dewgong, rhyhorn, rhydon, kangaskhan, goldeen, seaking, tauros, snorlax, mew.

### TM10: Double-Edge

nidoranm, nidorino, nidoking, mankey, primeape, machop, machoke, machamp, rhyhorn, rhydon, kangaskhan, tauros, gyarados, snorlax, mew.

### TM20: Rage

charmander, charmeleon, charizard, spearow, fearow, ekans, arbok, nidoranm, nidorino, nidoking, mankey, primeape, machop, machoke, machamp, doduo, dodrio, krabby, kingler, rhyhorn, rhydon, magmar, pinsir, tauros, gyarados, aerodactyl, mew.

### TM31: Mimic

clefairy, clefable, vulpix, ninetales, jigglypuff, wigglytuff, meowth, persian, abra, kadabra, alakazam, gastly, haunter, gengar, drowzee, hypno, exeggcute, exeggutor, chansey, mrmime, jynx, porygon, mew.

### TM32: Double Team

charmander, charmeleon, charizard, butterfree, beedrill, pidgey, pidgeotto, pidgeot, rattata, raticate, spearow, fearow, pikachu, raichu, sandshrew, sandslash, vulpix, ninetales, zubat, golbat, venomoth, diglett, dugtrio, meowth, persian, mankey, primeape, growlithe, arcanine, abra, kadabra, alakazam, tentacool, tentacruel, ponyta, rapidash, farfetchd, doduo, dodrio, gastly, haunter, gengar, voltorb, electrode, horsea, seadra, staryu, starmie, scyther, jynx, electabuzz, tauros, jolteon, aerodactyl, articuno, zapdos, moltres, dragonite, mewtwo, mew.

### TM34: Bide

squirtle, wartortle, blastoise, sandshrew, sandslash, machop, machoke, machamp, geodude, graveler, golem, slowpoke, slowbro, shellder, cloyster, onix, cubone, marowak, hitmonchan, rhyhorn, rhydon, chansey, tangela, kangaskhan, lapras, omanyte, omastar, kabuto, kabutops, snorlax, mew.

### TM50: Substitute

ekans, arbok, clefairy, clefable, vulpix, ninetales, jigglypuff, wigglytuff, meowth, persian, abra, kadabra, alakazam, grimer, muk, gastly, haunter, gengar, drowzee, hypno, exeggcute, exeggutor, koffing, weezing, mrmime, jynx, porygon, mew.

## Complete compatibility matrix

“Yes” means the TM can be taught. These rows cover all 151 originals and 21 variants; the source filenames identify variants precisely. Other TM/HM bits remain at their previous values.

| Dex | Pokémon/source filename | Toxic | Take Down | Double-Edge | Rage | Mimic | Double Team | Bide | Substitute | Rest |
| ---: | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | bulbasaur | Yes | — | — | — | — | — | — | — | Yes |
| 2 | ivysaur | Yes | — | — | — | — | — | — | — | Yes |
| 3 | venusaur | Yes | — | — | — | — | — | — | — | Yes |
| 4 | charmander | — | — | — | Yes | — | Yes | — | — | Yes |
| 5 | charmeleon | — | — | — | Yes | — | Yes | — | — | Yes |
| 6 | charizard | — | — | — | Yes | — | Yes | — | — | Yes |
| 7 | squirtle | — | Yes | — | — | — | — | Yes | — | Yes |
| 8 | wartortle | — | Yes | — | — | — | — | Yes | — | Yes |
| 9 | blastoise | — | Yes | — | — | — | — | Yes | — | Yes |
| 10 | caterpie | — | — | — | — | — | — | — | — | — |
| 11 | metapod | — | — | — | — | — | — | — | — | — |
| 12 | butterfree | — | — | — | — | — | Yes | — | — | Yes |
| 13 | weedle | Yes | — | — | — | — | — | — | — | — |
| 14 | kakuna | Yes | — | — | — | — | — | — | — | — |
| 15 | beedrill | Yes | — | — | — | — | Yes | — | — | Yes |
| 16 | pidgey | — | — | — | — | — | Yes | — | — | Yes |
| 17 | pidgeotto | — | — | — | — | — | Yes | — | — | Yes |
| 18 | pidgeot | — | — | — | — | — | Yes | — | — | Yes |
| 19 | rattata | — | — | — | — | — | Yes | — | — | Yes |
| 20 | raticate | — | — | — | — | — | Yes | — | — | Yes |
| 21 | spearow | — | — | — | Yes | — | Yes | — | — | Yes |
| 22 | fearow | — | — | — | Yes | — | Yes | — | — | Yes |
| 23 | ekans | Yes | — | — | Yes | — | — | — | Yes | Yes |
| 24 | arbok | Yes | — | — | Yes | — | — | — | Yes | Yes |
| 25 | pikachu | — | — | — | — | — | Yes | — | — | Yes |
| 26 | raichu | — | — | — | — | — | Yes | — | — | Yes |
| 27 | sandshrew | — | Yes | — | — | — | Yes | Yes | — | Yes |
| 28 | sandslash | — | Yes | — | — | — | Yes | Yes | — | Yes |
| 29 | nidoranf | Yes | Yes | — | — | — | — | — | — | Yes |
| 30 | nidorina | Yes | Yes | — | — | — | — | — | — | Yes |
| 31 | nidoqueen | Yes | Yes | — | — | — | — | — | — | Yes |
| 32 | nidoranm | Yes | Yes | Yes | Yes | — | — | — | — | Yes |
| 33 | nidorino | Yes | Yes | Yes | Yes | — | — | — | — | Yes |
| 34 | nidoking | Yes | Yes | Yes | Yes | — | — | — | — | Yes |
| 35 | clefairy | — | — | — | — | Yes | — | — | Yes | Yes |
| 36 | clefable | — | — | — | — | Yes | — | — | Yes | Yes |
| 37 | vulpix | — | — | — | — | Yes | Yes | — | Yes | Yes |
| 38 | ninetales | — | — | — | — | Yes | Yes | — | Yes | Yes |
| 39 | jigglypuff | — | — | — | — | Yes | — | — | Yes | Yes |
| 40 | wigglytuff | — | — | — | — | Yes | — | — | Yes | Yes |
| 41 | zubat | Yes | — | — | — | — | Yes | — | — | Yes |
| 42 | golbat | Yes | — | — | — | — | Yes | — | — | Yes |
| 43 | oddish | Yes | — | — | — | — | — | — | — | Yes |
| 44 | gloom | Yes | — | — | — | — | — | — | — | Yes |
| 45 | vileplume | Yes | — | — | — | — | — | — | — | Yes |
| 46 | paras | Yes | — | — | — | — | — | — | — | Yes |
| 47 | parasect | Yes | — | — | — | — | — | — | — | Yes |
| 48 | venonat | Yes | — | — | — | — | — | — | — | Yes |
| 49 | venomoth | Yes | — | — | — | — | Yes | — | — | Yes |
| 50 | diglett | — | — | — | — | — | Yes | — | — | Yes |
| 51 | dugtrio | — | — | — | — | — | Yes | — | — | Yes |
| 52 | meowth | — | — | — | — | Yes | Yes | — | Yes | Yes |
| 53 | persian | — | — | — | — | Yes | Yes | — | Yes | Yes |
| 54 | psyduck | — | — | — | — | — | — | — | — | Yes |
| 55 | golduck | — | — | — | — | — | — | — | — | Yes |
| 56 | mankey | — | — | Yes | Yes | — | Yes | — | — | Yes |
| 57 | primeape | — | — | Yes | Yes | — | Yes | — | — | Yes |
| 58 | growlithe | — | Yes | — | — | — | Yes | — | — | Yes |
| 59 | arcanine | — | Yes | — | — | — | Yes | — | — | Yes |
| 60 | poliwag | — | — | — | — | — | — | — | — | Yes |
| 61 | poliwhirl | — | — | — | — | — | — | — | — | Yes |
| 62 | poliwrath | — | — | — | — | — | — | — | — | Yes |
| 63 | abra | — | — | — | — | Yes | Yes | — | Yes | Yes |
| 64 | kadabra | — | — | — | — | Yes | Yes | — | Yes | Yes |
| 65 | alakazam | — | — | — | — | Yes | Yes | — | Yes | Yes |
| 66 | machop | — | — | Yes | Yes | — | — | Yes | — | Yes |
| 67 | machoke | — | — | Yes | Yes | — | — | Yes | — | Yes |
| 68 | machamp | — | — | Yes | Yes | — | — | Yes | — | Yes |
| 69 | bellsprout | Yes | — | — | — | — | — | — | — | Yes |
| 70 | weepinbell | Yes | — | — | — | — | — | — | — | Yes |
| 71 | victreebel | Yes | — | — | — | — | — | — | — | Yes |
| 72 | tentacool | Yes | — | — | — | — | Yes | — | — | Yes |
| 73 | tentacruel | Yes | — | — | — | — | Yes | — | — | Yes |
| 74 | geodude | — | Yes | — | — | — | — | Yes | — | Yes |
| 75 | graveler | — | Yes | — | — | — | — | Yes | — | Yes |
| 76 | golem | — | Yes | — | — | — | — | Yes | — | Yes |
| 77 | ponyta | — | Yes | — | — | — | Yes | — | — | Yes |
| 78 | rapidash | — | Yes | — | — | — | Yes | — | — | Yes |
| 79 | slowpoke | — | — | — | — | — | — | Yes | — | Yes |
| 80 | slowbro | — | — | — | — | — | — | Yes | — | Yes |
| 81 | magnemite | — | — | — | — | — | — | — | — | Yes |
| 82 | magneton | — | — | — | — | — | — | — | — | Yes |
| 83 | farfetchd | — | — | — | — | — | Yes | — | — | Yes |
| 84 | doduo | — | Yes | — | Yes | — | Yes | — | — | Yes |
| 85 | dodrio | — | Yes | — | Yes | — | Yes | — | — | Yes |
| 86 | seel | — | Yes | — | — | — | — | — | — | Yes |
| 87 | dewgong | — | Yes | — | — | — | — | — | — | Yes |
| 88 | grimer | Yes | — | — | — | — | — | — | Yes | Yes |
| 89 | muk | Yes | — | — | — | — | — | — | Yes | Yes |
| 90 | shellder | — | — | — | — | — | — | Yes | — | Yes |
| 91 | cloyster | — | — | — | — | — | — | Yes | — | Yes |
| 92 | gastly | Yes | — | — | — | Yes | Yes | — | Yes | Yes |
| 93 | haunter | Yes | — | — | — | Yes | Yes | — | Yes | Yes |
| 94 | gengar | Yes | — | — | — | Yes | Yes | — | Yes | Yes |
| 95 | onix | — | — | — | — | — | — | Yes | — | Yes |
| 96 | drowzee | — | — | — | — | Yes | — | — | Yes | Yes |
| 97 | hypno | — | — | — | — | Yes | — | — | Yes | Yes |
| 98 | krabby | — | — | — | Yes | — | — | — | — | Yes |
| 99 | kingler | — | — | — | Yes | — | — | — | — | Yes |
| 100 | voltorb | — | — | — | — | — | Yes | — | — | Yes |
| 101 | electrode | — | — | — | — | — | Yes | — | — | Yes |
| 102 | exeggcute | — | — | — | — | Yes | — | — | Yes | Yes |
| 103 | exeggutor | — | — | — | — | Yes | — | — | Yes | Yes |
| 104 | cubone | — | — | — | — | — | — | Yes | — | Yes |
| 105 | marowak | — | — | — | — | — | — | Yes | — | Yes |
| 106 | hitmonlee | — | — | — | — | — | — | — | — | Yes |
| 107 | hitmonchan | — | — | — | — | — | — | Yes | — | Yes |
| 108 | lickitung | — | — | — | — | — | — | — | — | Yes |
| 109 | koffing | Yes | — | — | — | — | — | — | Yes | Yes |
| 110 | weezing | Yes | — | — | — | — | — | — | Yes | Yes |
| 111 | rhyhorn | — | Yes | Yes | Yes | — | — | Yes | — | Yes |
| 112 | rhydon | — | Yes | Yes | Yes | — | — | Yes | — | Yes |
| 113 | chansey | — | — | — | — | Yes | — | Yes | — | Yes |
| 114 | tangela | — | — | — | — | — | — | Yes | — | Yes |
| 115 | kangaskhan | — | Yes | Yes | — | — | — | Yes | — | Yes |
| 116 | horsea | — | — | — | — | — | Yes | — | — | Yes |
| 117 | seadra | — | — | — | — | — | Yes | — | — | Yes |
| 118 | goldeen | — | Yes | — | — | — | — | — | — | Yes |
| 119 | seaking | — | Yes | — | — | — | — | — | — | Yes |
| 120 | staryu | — | — | — | — | — | Yes | — | — | Yes |
| 121 | starmie | — | — | — | — | — | Yes | — | — | Yes |
| 122 | mrmime | — | — | — | — | Yes | — | — | Yes | Yes |
| 123 | scyther | — | — | — | — | — | Yes | — | — | Yes |
| 124 | jynx | — | — | — | — | Yes | Yes | — | Yes | Yes |
| 125 | electabuzz | — | — | — | — | — | Yes | — | — | Yes |
| 126 | magmar | — | — | — | Yes | — | — | — | — | Yes |
| 127 | pinsir | — | — | — | Yes | — | — | — | — | Yes |
| 128 | tauros | — | Yes | Yes | Yes | — | Yes | — | — | Yes |
| 129 | magikarp | — | — | — | — | — | — | — | — | — |
| 130 | gyarados | — | — | Yes | Yes | — | — | — | — | Yes |
| 131 | lapras | — | — | — | — | — | — | Yes | — | Yes |
| 132 | ditto | — | — | — | — | — | — | — | — | — |
| 133 | eevee | — | — | — | — | — | — | — | — | Yes |
| 134 | vaporeon | — | — | — | — | — | — | — | — | Yes |
| 135 | jolteon | — | — | — | — | — | Yes | — | — | Yes |
| 136 | flareon | — | — | — | — | — | — | — | — | Yes |
| 137 | porygon | — | — | — | — | Yes | — | — | Yes | Yes |
| 138 | omanyte | — | — | — | — | — | — | Yes | — | Yes |
| 139 | omastar | — | — | — | — | — | — | Yes | — | Yes |
| 140 | kabuto | — | — | — | — | — | — | Yes | — | Yes |
| 141 | kabutops | — | — | — | — | — | — | Yes | — | Yes |
| 142 | aerodactyl | — | — | — | Yes | — | Yes | — | — | Yes |
| 143 | snorlax | — | Yes | Yes | — | — | — | Yes | — | Yes |
| 144 | articuno | — | — | — | — | — | Yes | — | — | Yes |
| 145 | zapdos | — | — | — | — | — | Yes | — | — | Yes |
| 146 | moltres | — | — | — | — | — | Yes | — | — | Yes |
| 147 | dratini | — | — | — | — | — | — | — | — | Yes |
| 148 | dragonair | — | — | — | — | — | — | — | — | Yes |
| 149 | dragonite | — | — | — | — | — | Yes | — | — | Yes |
| 150 | mewtwo | — | — | — | — | — | Yes | — | — | Yes |
| 151 | mew | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| 152 | blastoise_unique | — | Yes | — | — | — | — | Yes | — | Yes |
| 153 | bulbasaur_unique | Yes | — | — | — | — | — | — | — | Yes |
| 154 | chansey_unique | — | — | — | — | Yes | — | Yes | — | Yes |
| 155 | charmander_unique | — | — | — | Yes | — | Yes | — | — | Yes |
| 156 | ditto_happy | — | — | — | — | — | — | — | — | — |
| 157 | geodude_fighting | — | Yes | — | — | — | — | Yes | — | Yes |
| 158 | goldeen_fighting | — | Yes | — | — | — | — | — | — | Yes |
| 159 | grimer_poison | Yes | — | — | — | — | — | — | Yes | Yes |
| 160 | ivysaur_erika | Yes | — | — | — | — | — | — | — | Yes |
| 161 | kakuna_rock_type | — | — | — | — | — | — | — | — | — |
| 162 | marowak_unique | — | — | — | — | — | — | Yes | — | Yes |
| 163 | nidoking_unique | Yes | Yes | Yes | Yes | — | — | — | — | Yes |
| 164 | nidoking_unique2 | Yes | Yes | Yes | Yes | — | — | — | — | Yes |
| 165 | nidoranm_unique | Yes | — | — | — | — | — | — | — | Yes |
| 166 | omanyte_unique | — | — | — | — | — | — | Yes | — | Yes |
| 167 | onix_brock | — | — | — | — | — | — | Yes | — | Yes |
| 168 | raichu_unique | — | — | — | — | — | Yes | — | — | Yes |
| 169 | squirtle_unique | — | Yes | — | — | — | — | Yes | — | Yes |
| 170 | tangela_erika | — | — | — | — | — | — | Yes | — | Yes |
| 171 | tentacool_big | Yes | — | — | — | — | Yes | — | — | Yes |
| 172 | venusaur_erika | Yes | — | — | — | — | — | — | — | Yes |

## Implementation and verification

Only the eight selected compatibility bits in each species' existing seven-byte TM/HM mask are changed. Header stats, typing, starting moves, growth, graphics, catch rates, reserved bytes, and other TM/HM bits are preserved. There is no battle code or save-layout change. `data/tm_distribution.json` records the exact before/after memberships and baseline headers.

`tools/test_tm_distribution.py` checks every byte of all 172 compiled headers against the approved bounded delta in both ROMs, verifies untouched Rest/HM/unreviewed bits and thematic boundary examples, then runs 2,408 actual CanLearnTM/GetMonHeader/FlagAction compatibility checks per ROM for the eight reviewed TMs, Rest and all five HMs. The unique-species test independently checks variant compatibility masks alongside preserved cloned fields. Previous species, encounters, save/load, crit, freeze and move tests remain in CI. BPS packaging applies each patch to a verified original and compares it byte for byte with the custom build. These checks do not claim a full manual playthrough.

## Remaining planning list

The ten proposed new TMs (Roost, Facade, Brine, Venoshock, Aerial Ace, Bulk Up, Rock Tomb, Will-O-Wisp, Scald and Curse), their compatibility, additional vendor stock and individual prices remain a separate next task. The existing level-up alternatives to trade evolution are retained.
