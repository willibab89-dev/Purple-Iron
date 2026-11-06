> The current build also includes TM61–63. See [SPECIES-TUNING-1.md](SPECIES-TUNING-1.md) for the additions and first four species revisions.

# Ten new TMs: TM51–TM60

Cumulative Red/Blue BPS patches include all custom front sprites, 21 unique species and encounters, crit/freeze changes, the completed move overhaul and the thematic distribution of existing TMs. This patch adds ten TM items and their approved compatibility, and stocks them in shops throughout Kanto. The game now has 60 TMs and the original five HMs.

## Updating and buying

Download `pokemon-new-tms-bps` from the successful GitHub Actions run. Apply the matching BPS to an unmodified original Red/Blue ROM, not a previously patched ROM. Existing 172-species saves remain compatible; old 151-species saves do not. Back up saves before updating. Already-known moves are retained. No Pokémon base stats, move stats, natural learnsets, evolution methods or permanent save formats change.

These are ordinary consumable TMs. Successful teaching consumes one; declining, cancelling, incompatible/known moves and battle-use rejection do not consume one. HMs remain reusable and retain their original identities and field functions. The shorter item names fit the inventory width; the teaching screen uses the full move name.

| TM | Move | Shop | Price |
| --- | --- | --- | ---: |
| TM51 | Roost | Viridian City | 18,000 |
| TM52 | Facade | Vermilion City | 6,000 |
| TM53 | Brine | Cerulean City | 5,000 |
| TM54 | Venoshock | Fuchsia City | 6,000 |
| TM55 | Aerial Ace | Celadon Dept. Store 2F TM clerk | 7,000 |
| TM56 | Bulk Up | Vermilion City | 9,000 |
| TM57 | Rock Tomb | Pewter City | 4,000 |
| TM58 | Will-O-Wisp | Cinnabar Island | 14,000 |
| TM59 | Scald | Saffron City | 16,000 |
| TM60 | Curse | Lavender Town | 10,000 |

Prices reflect utility and strength: early Rock Tomb is affordable, while Roost is a deliberately expensive early-town purchase to reward returning to Viridian later. Existing shop stock and prices are preserved. Each stock list remains within the original 14-item shop limit. Other existing TMs are still available from their previous shops and rewards.

## Compatibility rules

Mew learns all ten. Families below are expanded into exact species lists; no extra pre-evolution should be inferred beyond the listed names. Roost is limited to the winged final forms in the Charmander, Dratini, Caterpie and Venonat families; Doduo remains the approved bird exception. Aerial Ace is limited to Kabutops in its family.

Brine is available to Water types except Magikarp. Venoshock is available to Poison types plus Paras, Parasect and Tangela. Scald is selective: Slowbro, Starmie, Lapras and Gyarados do not receive it. Gen 1 damage categories and all custom move effects remain unchanged: Venoshock is physical, and Curse remains the custom 1/8-HP residual status move.

Variants inherit suitable source access, checked against actual typing for Brine/Venoshock. Fighting Geodude additionally gets Bulk Up; Fighting Goldeen gets Facade, without Brine/Scald; Rock Kakuna gets Rock Tomb, without Venoshock. The three original TM permissions Take Down, Double-Edge and Rage were also restored to unique Nidoran♂: a source-name spelling mismatch had prevented it inheriting those permissions in the preceding thematic patch.

## Exact compatible original species

### TM51: Roost

charizard, butterfree, pidgey, pidgeotto, pidgeot, spearow, fearow, zubat, golbat, venomoth, farfetchd, doduo, dodrio, scyther, aerodactyl, articuno, zapdos, moltres, dragonite, mew.

### TM52: Facade

rattata, raticate, spearow, fearow, meowth, persian, mankey, primeape, machop, machoke, machamp, farfetchd, doduo, dodrio, lickitung, kangaskhan, tauros, flareon, snorlax, mew.

### TM53: Brine

squirtle, wartortle, blastoise, psyduck, golduck, poliwag, poliwhirl, poliwrath, tentacool, tentacruel, slowpoke, slowbro, seel, dewgong, shellder, cloyster, krabby, kingler, horsea, seadra, goldeen, seaking, staryu, starmie, gyarados, lapras, vaporeon, omanyte, omastar, kabuto, kabutops, mew.

### TM54: Venoshock

bulbasaur, ivysaur, venusaur, weedle, kakuna, beedrill, ekans, arbok, nidoranf, nidorina, nidoqueen, nidoranm, nidorino, nidoking, zubat, golbat, oddish, gloom, vileplume, paras, parasect, venonat, venomoth, bellsprout, weepinbell, victreebel, tentacool, tentacruel, grimer, muk, gastly, haunter, gengar, koffing, weezing, tangela, mew.

### TM55: Aerial Ace

charizard, pidgey, pidgeotto, pidgeot, spearow, fearow, sandshrew, sandslash, zubat, golbat, meowth, persian, farfetchd, doduo, dodrio, scyther, kabutops, aerodactyl, articuno, zapdos, moltres, dragonite, mew.

### TM56: Bulk Up

nidoking, mankey, primeape, poliwrath, machop, machoke, machamp, hitmonlee, hitmonchan, rhydon, kangaskhan, pinsir, mew.

### TM57: Rock Tomb

sandshrew, sandslash, nidoqueen, nidoking, diglett, dugtrio, machop, machoke, machamp, geodude, graveler, golem, onix, cubone, marowak, rhyhorn, rhydon, pinsir, omanyte, omastar, kabuto, kabutops, aerodactyl, mew.

### TM58: Will-O-Wisp

charizard, vulpix, ninetales, growlithe, arcanine, ponyta, rapidash, gastly, haunter, gengar, marowak, koffing, weezing, magmar, flareon, moltres, mew.

### TM59: Scald

squirtle, wartortle, blastoise, psyduck, golduck, poliwag, poliwhirl, poliwrath, krabby, kingler, horsea, seadra, vaporeon, omanyte, omastar, mew.

### TM60: Curse

vulpix, ninetales, gastly, haunter, gengar, drowzee, hypno, exeggcute, exeggutor, cubone, marowak, mew.

## Variant compatibility

| Variant/source filename | New TMs |
| --- | --- |
| blastoise_unique | TM53 Brine, TM59 Scald |
| bulbasaur_unique | TM54 Venoshock |
| chansey_unique | None |
| charmander_unique | None |
| ditto_happy | None |
| geodude_fighting | TM56 Bulk Up, TM57 Rock Tomb |
| goldeen_fighting | TM52 Facade |
| grimer_poison | TM54 Venoshock |
| ivysaur_erika | TM54 Venoshock |
| kakuna_rock_type | TM57 Rock Tomb |
| marowak_unique | TM57 Rock Tomb, TM58 Will-O-Wisp, TM60 Curse |
| nidoking_unique | TM54 Venoshock, TM56 Bulk Up, TM57 Rock Tomb |
| nidoking_unique2 | TM54 Venoshock, TM56 Bulk Up, TM57 Rock Tomb |
| nidoranm_unique | TM54 Venoshock |
| omanyte_unique | TM53 Brine, TM57 Rock Tomb, TM59 Scald |
| onix_brock | TM57 Rock Tomb |
| raichu_unique | None |
| squirtle_unique | TM53 Brine, TM59 Scald |
| tangela_erika | TM54 Venoshock |
| tentacool_big | TM53 Brine, TM54 Venoshock |
| venusaur_erika | TM54 Venoshock |

## Implementation and compatibility

The ten new inventory IDs use previously unused values 0x62–0x6B, so all existing item, TM and HM IDs remain stable. The old machine-to-move table's first 55 entries are unchanged: TM01–TM50 occupy entries 1–50 and HM01–HM05 entries 51–55. The added items map to entries 56–65 while displaying TM51–TM60. Ordinary item prices hold full three-byte BCD values, supporting the selected prices above the old nibble-priced TM limit.

Existing seven-byte compatibility fields and 28-byte species headers are retained. Ten additional permissions per species live in a separate two-byte ROM table indexed by Pokédex number. CanLearnTM handles both tables and bounds invalid move lookups. No extra saved or WRAM fields are allocated. Bag/PC item storage continues to use ordinary item/quantity pairs.

The old machine-name list was moved to a roomier ROM bank. Item-name lookup selects the correct list and bank and resets its name-list type, so the existing TM/HM names, all 219 move names and new inventory names remain distinct. Key-item flags cover the new items as ordinary sellable/tossable TMs. Start-menu use routes them to the existing party-teaching interface.

## Verification

Both Red and Blue build. New PyBoy checks cover all 1,720 species/new-TM eligibility cases; boundary cases for Mew, winged evolutions, selective Scald and typed variants; all 65 old/new machine mappings and HM/TM classification; old and new names including alternating lookups; original/new price tables and runtime prices; original shop stock, new placements and shop buffer limits; non-key/reusable-HM flags; stacking and save/load of all ten new items; teaching all ten through the real item dispatch, compatibility, LearnMove, PP initialization and consumption routines; and already-known, incompatible, cancelled/declined and in-battle refusal paths. Presentation and player selections are stubbed for automated teaching tests, not the teaching/consumption logic itself.

Existing thematic compatibility, species, encounters, save/load, crit, freeze and all move suites remain in CI. Both BPS patches are applied to verified originals and compared byte for byte with the custom builds. These checks do not claim a full manual playthrough or link compatibility test; link play still requires identical ROM revisions, and the previously documented forced-switch link restriction remains.

## Remaining planning work

The approved ten new TMs, compatibility, vendor additions and prices are implemented. The separate individual Pokémon stat/learnset review remains future work. Existing level-up alternatives to trade evolution remain as before.
