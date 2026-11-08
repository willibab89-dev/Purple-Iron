# Final trainer moveset review

Cumulative Red/Blue patches retain all previous sprites, species, stats, moves, TMs and encounters. Species count remains 183; move count remains 236 including Struggle. Existing 183-species saves remain compatible.

This patch updates final boss movesets only: 55 Pokémon across the Gym, Elite Four, Champion, Professor Oak, Silph Chief, Mr. Fuji, Seiga and Red records. Species rosters, levels, species stats, rewards and encounter scripts are unchanged. The exact plan and preserved sets are recorded in data/trainer_review.json.

## Corrections

- All six exact duplicate moves are removed: Misty's Starmie, Giovanni's Rhydon, Lorelei's Slowbro and Jynx, Agatha's Golbat and final Gengar.
- Old trainer coverage is brought into line with reviewed natural learnsets and current TM lists, including Arbok's removed Earthquake, Rhydon's special coverage and Red's starters' removed Earthquake.
- Agatha's first Gengar now has Hypnosis with Dream Eater. Her final Gengar uses Confuse Ray, Curse and Shadow Leech with Psychic.
- Lance's Dragonite has physical Body Slam and Wing Attack for Dragon Dance. Aerodactyl regains Rock attacks. Gyarados uses Outrage in place of Fire Blast.
- Lorelei's Lapras can use Heal Bell. The Champion's Pidgeot, Exeggutor and Gyarados follow their agreed wind, colony and mixed rampaging roles.
- The extra bosses use the agreed new sets. Professor Oak's other Pokémon, Seiga's already-approved Victreebel, Fuji's automatic-transforming Ditto and the special level-128 Fossil/MissingNo encounter are preserved.
- Three small remaining legacy conflicts are resolved: Koga's Weezing regains Haze instead of Mimic; Sabrina's Venomoth regains Leech Life instead of Supersonic; Champion Charizard regains Wing Attack instead of its old Swords Dance override, giving Dragon Dance a physical attack to boost.
- Red's final special-move record now has its missing zero terminator before the outer FF sentinel. The compiled-table regression rejects invalid party/move slot writes and unterminated records.

## Final changed sets

Trainer labels below identify the underlying stored records. SONY3 is the Champion; Gentleman 5 is Fuji; Lass 19 is Seiga; Jr Trainer M 9 is Red.

| Trainer record | Slot | Pokémon | Level | Final moves |
| --- | ---: | --- | ---: | --- |
| AGATHA 1 | 2 | Gengar | 56 | Hypnosis / Dream Eater / Substitute / Thunderbolt |
| AGATHA 1 | 3 | Golbat | 56 | Screech / Poison Fang / Shadow Leech / Toxic |
| AGATHA 1 | 4 | Arbok | 58 | Poison Fang / Crunch / Screech / Coil |
| AGATHA 1 | 5 | Gengar | 60 | Confuse Ray / Curse / Shadow Leech / Psychic |
| BRUNO 1 | 2 | Hitmonchan | 55 | Ice Punch / Thunderpunch / Fire Punch / Brick Break |
| CHIEF 1 | 1 | Kangaskhan | 72 | Body Slam / Submission / Counter / Ice Beam |
| CHIEF 1 | 2 | Rhydon | 73 | Earthquake / Rock Slide / Megahorn / Bulk Up |
| CHIEF 1 | 3 | Golduck | 73 | Amnesia / Surf / Psychic / Ice Beam |
| CHIEF 1 | 4 | Pinsir | 74 | Bulk Up / Shell Break / Submission / Body Slam |
| CHIEF 1 | 5 | Scyther | 74 | Swords Dance / Slash / Wing Attack / X Scissor |
| CHIEF 1 | 6 | Tauros | 76 | Facade / Double-Edge / Stomp / Rest |
| GENTLEMAN 5 | 1 | Marowak | 69 | Bonemerang / Body Slam / Seismic Toss / Wailing Cry |
| GENTLEMAN 5 | 2 | Omastar | 70 | Hydro Pump / Ice Beam / Reflect / Stone Press |
| GENTLEMAN 5 | 3 | Kabutops | 70 | Swords Dance / Surf / Slash / Stone Edge |
| GENTLEMAN 5 | 4 | Aerodactyl | 71 | Sky Attack / Reflect / Crunch / Rock Slide |
| GENTLEMAN 5 | 5 | Arcanine | 73 | Fire Blast / Body Slam / Crunch / Rest |
| GIOVANNI 3 | 3 | Nidoqueen | 46 | Earthquake / Poison Fang / Thunderbolt / Bulk Up |
| GIOVANNI 3 | 5 | Rhydon | 50 | Rock Slide / Pierce / Earthquake / Megahorn |
| JR_TRAINER_M 9 | 1 | Lapras | 83 | Hydro Pump / Ice Beam / Thunderbolt / Heal Bell |
| JR_TRAINER_M 9 | 2 | Venusaur | 85 | Sleep Powder / Growth / Petal Dance / Sludge |
| JR_TRAINER_M 9 | 3 | Charizard | 85 | Fire Blast / Wing Attack / Dragon Dance / Hyper Beam |
| JR_TRAINER_M 9 | 4 | Blastoise | 85 | Hydro Pump / Ice Beam / Spike Cannon / Reflect |
| JR_TRAINER_M 9 | 5 | Snorlax | 87 | Crunch / Rest / Body Slam / Earthquake |
| JR_TRAINER_M 9 | 6 | Pikachu | 88 | Thunder Wave / Thunder / Thunderclap / Light Screen |
| KOGA 1 | 4 | Weezing | 43 | Toxic / Poison Gas / Incinerate / Haze |
| LANCE 1 | 1 | Gyarados | 58 | Crunch / Dragon Dance / Outrage / Hyper Beam |
| LANCE 1 | 4 | Aerodactyl | 60 | Rock Slide / Crunch / Stone Edge / Sky Attack |
| LANCE 1 | 5 | Dragonite | 62 | Dragon Dance / Body Slam / Wing Attack / Thunder |
| LASS 19 | 1 | Clefable | 80 | Psychic / Sing / Metronome / Moonlight |
| LASS 19 | 2 | Gengar | 82 | Thunderbolt / Hypnosis / Dream Eater / Confuse Ray |
| LASS 19 | 4 | Ninetales | 83 | Fire Blast / Reflect / Wailing Cry / Confuse Ray |
| LASS 19 | 5 | Kangaskhan | 84 | Dizzy Punch / Counter / Ice Beam / Facade |
| LASS 19 | 6 | Blastoise | 85 | Snipe Shot / Ice Beam / Spike Cannon / Reflect |
| LORELEI 1 | 3 | Slowbro | 55 | Rest / Ice Beam / Psychic / Surf |
| LORELEI 1 | 4 | Jynx | 56 | Charm / Lovely Kiss / Frost Breath / Psychic |
| LORELEI 1 | 5 | Lapras | 56 | Confuse Ray / Ice Beam / Heal Bell / Hydro Pump |
| MISTY 1 | 2 | Starmie | 22 | Harden / Water Gun / Swift / Bubblebeam |
| PROF_OAK 1 | 1 | Tauros | 66 | Rage / Earthquake / Facade / Double-Edge |
| PROF_OAK 2 | 1 | Tauros | 66 | Rage / Earthquake / Facade / Double-Edge |
| PROF_OAK 3 | 1 | Tauros | 66 | Rage / Earthquake / Facade / Double-Edge |
| SABRINA 1 | 2 | Mrmime | 37 | Light Screen / Psybeam / Substitute / Mind Break |
| SABRINA 1 | 3 | Venomoth | 38 | Leech Life / Sleep Powder / Psybeam / Quiver Dance |
| SONY3 1 | 1 | Pidgeot | 59 | Gale Wind / Roost / Mirror Move / Sky Attack |
| SONY3 1 | 3 | Rhydon | 61 | Megahorn / Earthquake / Rock Slide / Take Down |
| SONY3 1 | 4 | Arcanine | 61 | Flamethrower / Rest / Double-Edge / Crunch |
| SONY3 1 | 5 | Exeggutor | 63 | Hypnosis / Leech Seed / Psychic / Barrage |
| SONY3 2 | 1 | Pidgeot | 59 | Gale Wind / Roost / Mirror Move / Sky Attack |
| SONY3 2 | 3 | Rhydon | 61 | Megahorn / Earthquake / Rock Slide / Take Down |
| SONY3 2 | 4 | Gyarados | 61 | Dragon Dance / Crunch / Hydro Pump / Outrage |
| SONY3 2 | 5 | Arcanine | 63 | Flamethrower / Rest / Double-Edge / Crunch |
| SONY3 3 | 1 | Pidgeot | 59 | Gale Wind / Roost / Mirror Move / Sky Attack |
| SONY3 3 | 3 | Rhydon | 61 | Megahorn / Earthquake / Rock Slide / Take Down |
| SONY3 3 | 4 | Exeggutor | 61 | Hypnosis / Leech Seed / Psychic / Barrage |
| SONY3 3 | 5 | Gyarados | 63 | Dragon Dance / Crunch / Hydro Pump / Outrage |
| SONY3 3 | 6 | Charizard | 65 | Wing Attack / Flamethrower / Fire Spin / Dragon Dance |

## Verification and scope

Both ROMs execute ReadTrainer for all 361 stored trainer teams, covering 949 roster entries in each version. There are 948 ordinary-species entries and one preserved scripted Fossil/MissingNo entry. The checks verify all declared species/levels, 63 exact reviewed or preserved sets, no duplicate nonzero moves on ordinary species, and no ordinary-species moves outside their current-level natural moves or existing TM/HM compatibility. The stored trainer-roster source checksum is unchanged.

The compiled SpecialTrainerMoves table is parsed and checked for valid trainer records, party positions, move slots and move IDs, with no duplicate slot writes. Every record must terminate before the outer sentinel. Previously reviewed independent variant evolution lists remain covered.

Existing species, sprites, learning/PP, encounters, saves, TMs, critical hits, freeze, support distribution and move-effect suites also run. BPS application is compared byte for byte with the built ROMs. Checks use default unscaled teams; a full manual campaign playthrough and alternate scaling/random-roster modes remain separate work.

The stale roster-PP bookkeeping noted in the audit is not changed: active enemy loading rebuilds PP, and normal non-link enemy PP behavior remains the existing Gen 1 behavior. This is not an enemy-PP rules patch. Kabutops Shell Smash remains pending separately.

## Updating

Apply the matching BPS to an original, unmodified Red or Blue ROM, not an already patched ROM. Back up saves before updating. Existing 183-species saves remain compatible. Trainer changes apply when a team is loaded for a new battle; begin from a save outside an active battle. No player Pokémon move, stat or type records are migrated.
