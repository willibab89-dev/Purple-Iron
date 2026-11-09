# Rematch moveset proposals

Implemented following approval. Reviewed all 77 Pokémon across seven Gym rematches, four Elite Four rematches and three Champion branches. Proposed changes: **37**; retained sets: **40**.

All proposed moves pass a static check against current starting moves, level-up moves at the battle level, and approved TM/HM compatibility. No learnset or TM distribution expansion is required. Species, levels, team order, first-clear battles and AI remain unchanged. Champion moves remain unchanged under the approved same-team, +25-level instruction.

## Main fixes

- Give Hypno Hypnosis to enable Dream Eater.
- Give Magneton and unique Raichu reliable paralysis to enable Zap Cannon.
- Let Erika’s Venusaur and Koga’s poison attackers enable their own Venoshock.
- Restore Sableye’s Snarl and Parasect’s Spore identities.
- Replace Onix’s late-game Rage/Slam slots with Rock Tomb/Earthquake.
- Give pure-Dragon Dragonite Dragon STAB without assuming Dragon Dance boosts special attacks.

## Mechanics and tradeoffs

Damage categories still follow Gen 1 types. Dragon attacks are special; Dragon Dance benefits physical attacks and Speed. Dragon Rage is the implemented 60-power attack, not fixed 40 damage. Critical hits ignore relevant stat stages, so Charge does not amplify guaranteed Shock Wave critical hits. Screens protect their current user rather than a modern teamwide duration.

Egg Bomb remains on Chansey for its screen-breaking utility. PvE charge moves remain where they fit. Cloyster trades reliable Ice Beam for Surf while retaining its two multihit signatures. Arcanine uses legal Rest rather than unavailable Cauterize, accepting the sleep turns. Status spread from an earlier teammate is an opportunity, not a guaranteed combo.

These changes preserve the existing AI. Further playtesting should assess sequencing for sleep/Dream Eater, paralysis payoffs, poison/Venoshock, recovery and setup. Gym rematches should remain useful money-farming battles without excessive healing stalls.

## Full review

### Lorelei — record 2

| Pokémon | Level | Current moves | Proposed moves | Reason |
|---|---:|---|---|---|
| Dewgong | 84 | Bubblebeam, Ice Armor, Brine, Ice Beam | Keep current | Keep the reviewed role and working combination. |
| Cloyster | 83 | Icicle Spear, Spike Cannon, Ice Beam, Shell Smash | Icicle Spear, Spike Cannon, Surf, Shell Smash | Add Water STAB while retaining both multihit signatures and the physical Spike Cannon/Shell Smash plan; trade reliable Ice Beam for coverage. |
| Slowbro | 84 | Rest, Ice Beam, Psychic, Surf | Keep current | Keep the reviewed role and working combination. |
| Jynx | 86 | Charm, Lovely Kiss, Frost Breath, Psychic | Keep current | Keep the reviewed role and working combination. |
| Lapras | 86 | Confuse Ray, Ice Beam, Heal Bell, Hydro Pump | Keep current | Keep the reviewed role and working combination. |
| Omanyte Unique | 80 | Chomp, Rock Tomb, Brine, Amnesia | Keep current | Keep the reviewed role and working combination. |

### Bruno — record 2

| Pokémon | Level | Current moves | Proposed moves | Reason |
|---|---:|---|---|---|
| Hitmonchan | 85 | Ice Punch, Thunderpunch, Fire Punch, Brick Break | Keep current | Keep the reviewed role and working combination. |
| Hitmonlee | 85 | Rolling Kick, Hi Jump Kick, Triple Kick, Mega Kick | Body Slam, Hi Jump Kick, Triple Kick, Focus Energy | Keep two distinctive kicks; Body Slam gives neutral physical coverage/paralysis and Focus Energy adds crit pressure. Rock TMs are not currently permitted. |
| Machamp | 88 | Karate Chop, Submission, Double Edge, Mega Kick | Bulk Up, Submission, Double Edge, Rock Slide | Replace low-power Karate Chop and redundant Mega Kick with physical setup and Flying coverage. |
| Poliwrath | 87 | Body Slam, Bulk Up, Hydro Pump, Submission | Keep current | Keep the reviewed role and working combination. |
| Pinsir | 86 | Shell Break, Submission, Bulk Up, Guillotine | Vicegrip, Submission, Bulk Up, Guillotine | Use the redesigned 75-power Bug Vicegrip as reliable STAB; keep Fighting coverage, setup and the intended risky finisher. |
| Primeape | 88 | Focus Energy, Brick Break, Punishment, Thrash | Keep current | Keep the reviewed role and working combination. |

### Agatha — record 2

| Pokémon | Level | Current moves | Proposed moves | Reason |
|---|---:|---|---|---|
| Marowak | 85 | Wailing Cry, Bonemerang, Rage, Curse | Wailing Cry, Bonemerang, Rock Tomb, Curse | Replace Rage with legal Rock Tomb for Flying coverage and speed control; keep both STAB themes and Curse. |
| Claydol | 88 | Stone Press, Mud Wave, Wailing Cry, Light Screen | Stone Press, Mud Wave, Psychic, Light Screen | Use its 120 Special for offense while keeping Defense-based Stone Press and accuracy-dropping Mud Wave. |
| Sableye | 80 | Shadow Leech, Crunch, Recover, Punishment | Shadow Leech, Snarl, Recover, Punishment | Restore the explicitly reviewed Snarl niche: Special suppression, drain/recovery and anti-setup punishment. |
| Gengar | 86 | Hypnosis, Dream Eater, Substitute, Thunderbolt | Keep current | Keep the reviewed role and working combination. |
| Ninetales | 86 | Wailing Cry, Flamethrower, Cauterize, Fire Spin | Wailing Cry, Flamethrower, Cauterize, Will O Wisp | Fire/Ghost burn control with Special reduction and limited healing; trade the residual attack for reliable burn support. |
| Parasect | 88 | Shadow Leech, X Scissor, Curse, Lunge | Shadow Leech, Spore, Curse, Lunge | Restore the mushroom’s signature sleep while retaining Ghost drain, Curse and slow-Pokémon priority Attack reduction. |

### Lance — record 2

| Pokémon | Level | Current moves | Proposed moves | Reason |
|---|---:|---|---|---|
| Gyarados | 88 | Crunch, Dragon Dance, Outrage, Hyper Beam | Hydro Pump, Dragon Dance, Outrage, Hyper Beam | Add Water STAB while retaining the dragon-themed rampage and physical Hyper Beam payoff. Dragon Dance boosts Speed/Hyper Beam, not the special attacks. |
| Dragonair | 86 | Thunder Wave, Dragon Rage, Thunderbolt, Coil | Thunder Wave, Dragon Rage, Thunderbolt, Reflect | Replace an Attack boost with no physical attacker by stronger physical protection. Reflect does not protect against special Ice damage. Dragon Rage is the implemented 60-power attack, not fixed 40 damage. |
| Lapras | 88 | Confuse Ray, Ice Beam, Heal Bell, Hydro Pump | Thunderbolt, Ice Beam, Heal Bell, Hydro Pump | Keep support and both STAB attacks while adding Water-mirror coverage; Lorelei’s Lapras keeps confusion control. |
| Tyranitar | 82 | Rock Slide, Earthquake, Dragon Rage, Outrage | Rock Slide, Earthquake, Thunder, Outrage | Replace the weaker duplicate Dragon attack with legal Electric coverage; Thunder also benefits from paralysis/other status spread earlier in the team. Bulk Up is not currently permitted. |
| Aerodactyl | 80 | Rock Slide, Crunch, Stone Edge, Sky Attack | Rock Slide, Aerial Ace, Stone Edge, Sky Attack | Add immediate reliable Flying STAB; retain flinch/crit Rock choices and the accepted PvE charge attack. |
| Dragonite | 90 | Dragon Dance, Body Slam, Wing Attack, Thunder | Dragon Dance, Body Slam, Outrage, Thunder | Restore pure-Dragon STAB by replacing off-type Wing Attack; retain Body Slam/Thunder status synergy. Outrage is special and is not Attack-boosted by Dragon Dance. |

### Sony3 — record 4

| Pokémon | Level | Current moves | Proposed moves | Reason |
|---|---:|---|---|---|
| Pidgeot | 84 | Gale Wind, Roost, Mirror Move, Sky Attack | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Alakazam | 86 | Thunder Wave, Psychic, Psych Up, Mind Break | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Rhydon | 86 | Megahorn, Earthquake, Rock Slide, Take Down | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Arcanine | 86 | Flamethrower, Rest, Double Edge, Crunch | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Exeggutor | 88 | Hypnosis, Leech Seed, Psychic, Barrage | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Blastoise Unique | 90 | Hydro Pump, Blizzard, Reflect, Skull Bash | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |

### Sony3 — record 5

| Pokémon | Level | Current moves | Proposed moves | Reason |
|---|---:|---|---|---|
| Pidgeot | 84 | Gale Wind, Roost, Mirror Move, Sky Attack | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Alakazam | 86 | Thunder Wave, Psychic, Psych Up, Mind Break | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Rhydon | 86 | Megahorn, Earthquake, Rock Slide, Take Down | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Gyarados | 86 | Dragon Dance, Crunch, Hydro Pump, Outrage | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Arcanine | 88 | Flamethrower, Rest, Double Edge, Crunch | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Venusaur | 90 | Mega Drain, Sludge, Petal Dance, Solarbeam | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |

### Sony3 — record 6

| Pokémon | Level | Current moves | Proposed moves | Reason |
|---|---:|---|---|---|
| Pidgeot | 84 | Gale Wind, Roost, Mirror Move, Sky Attack | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Alakazam | 86 | Thunder Wave, Psychic, Psych Up, Mind Break | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Rhydon | 86 | Megahorn, Earthquake, Rock Slide, Take Down | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Exeggutor | 86 | Hypnosis, Leech Seed, Psychic, Barrage | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Gyarados | 88 | Dragon Dance, Crunch, Hydro Pump, Outrage | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |
| Charizard | 90 | Wing Attack, Flamethrower, Fire Spin, Dragon Dance | Keep current | Keep the approved same-species/same-moves Champion +25-level contract; Champion move edits are outside this default pass. |

### Brock — record 2

| Pokémon | Level | Current moves | Proposed moves | Reason |
|---|---:|---|---|---|
| Golem | 64 | Stone Press, Earthquake, Stone Edge, Explosion | Rock Polish, Earthquake, Stone Edge, Explosion | Trade the second Rock attack for speed setup; keep the physical finisher role distinct from Defense-based Onix. |
| Ninetales | 66 | Wailing Cry, Flamethrower, Cauterize, Fire Spin | Wailing Cry, Flamethrower, Cauterize, Will O Wisp | Fire/Ghost burn control with Special reduction and limited healing; trade the residual attack for reliable burn support. |
| Crobat | 64 | Wing Attack, Poison Fang, Shadow Leech, Haze | Keep current | Keep the reviewed role and working combination. |
| Chansey | 62 | Softboiled, Seismic Toss, Light Screen, Egg Bomb | Keep current | Keep the reviewed role and working combination. |
| Onix | 70 | Rage, Slam, Stone Press, Coil | Rock Tomb, Earthquake, Stone Press, Coil | Replace Rage/Slam with Ground STAB and speed control; Coil supports both Attack-based Earthquake and Defense-based Stone Press. |

### Misty — record 2

| Pokémon | Level | Current moves | Proposed moves | Reason |
|---|---:|---|---|---|
| Golduck | 66 | Amnesia, Psyshock, Hydro Pump, Psychic | Keep current | Keep the reviewed role and working combination. |
| Seadra | 64 | Snipe Shot, Agility, Dragon Rage, Hydro Pump | Keep current | Keep the reviewed role and working combination. |
| Seaking | 65 | Pierce, Agility, Megahorn, Horn Drill | Keep current | Keep the reviewed role and working combination. |
| Vaporeon | 66 | Scald, Acid Armor, Haze, Hydro Pump | Keep current | Keep the reviewed role and working combination. |
| Starmie | 70 | Bubblebeam, Light Screen, Psychic, Hydro Pump | Recover, Light Screen, Psychic, Hydro Pump | Restore the fast ace recovery role instead of a redundant weaker Water attack. |

### Lt Surge — record 2

| Pokémon | Level | Current moves | Proposed moves | Reason |
|---|---:|---|---|---|
| Electrode | 66 | Light Screen, Electro Ball, Swift, Explosion | Light Screen, Electro Ball, Thunder Wave, Explosion | Paralysis enables Electro Ball’s speed-ratio damage and gives the lead a setup role; replace Swift. |
| Magneton | 64 | Charge, Shock Wave, Light Screen, Zap Cannon | Charge, Shock Wave, Thunder Wave, Zap Cannon | Self-enable guaranteed Shock Wave crits and Zap Cannon accuracy; Charge helps Special/accuracy, although crits ignore its Special stages. |
| Electabuzz | 68 | Screech, Brick Break, Thunderclap, Thunder | Keep current | Keep the reviewed role and working combination. |
| Jolteon | 65 | Pin Missile, Thunder Wave, Shock Wave, Thunder | Keep current | Keep the reviewed role and working combination. |
| Raichu Unique | 70 | Mega Punch, Body Slam, Light Screen, Zap Cannon | Mega Punch, Body Slam, Thunder Wave, Zap Cannon | Keep physical coverage while giving the final ace a reliable way to enable Zap Cannon; replace Light Screen. |

### Erika — record 2

| Pokémon | Level | Current moves | Proposed moves | Reason |
|---|---:|---|---|---|
| Victreebel | 66 | Slam, Poison Fang, Chomp, Vine Crush | Sleep Powder, Poison Fang, Chomp, Vine Crush | Trade Slam for legal sleep control; retain Poison Fang pressure and draining Chomp/Clamp. Stun Spore is not currently permitted, so Vine Crush is ordinary Grass STAB here rather than a self-enabled paralysis combo. |
| Tangela Erika | 62 | Sleep Powder, Ingrain, Vicegrip, Stockpile | Keep current | Keep the reviewed role and working combination. |
| Vileplume | 68 | Acid, Giga Drain, Petal Dance, Solarbeam | Acid, Giga Drain, Petal Dance, Poisonpowder | Preserve Vileplume’s Giga Drain identity, trade a third Grass attack for poisoning that can support the final Venusaur. |
| Exeggutor | 66 | Psybeam, Egg Bomb, Psychic, Solarbeam | Hypnosis, Egg Bomb, Psychic, Solarbeam | Replace redundant Psybeam with sleep; preserve screen-breaking Egg Bomb and the sleep/charge opportunity. |
| Venusaur Erika | 70 | Petal Dance, Sludge, Synthesis, Venoshock | Petal Dance, Poisonpowder, Synthesis, Venoshock | Give the final ace its own way to enable Venoshock; keep Synthesis and no extra draining heal. |

### Koga — record 2

| Pokémon | Level | Current moves | Proposed moves | Reason |
|---|---:|---|---|---|
| Weezing | 63 | Poison Gas, Incinerate, Haze, Explosion | Poison Gas, Venoshock, Haze, Explosion | Poison setter with its own damaging payoff and anti-setup/finisher tools; replace unsupported burn-payoff Incinerate. |
| Muk | 65 | Mud Wave, Screech, Acid Armor, Toxic | Mud Wave, Venoshock, Acid Armor, Toxic | Restore Poison offense alongside Ground offense; Toxic enables Venoshock and Acid Armor retains the tank role. |
| Tentacruel | 68 | Brine, Barrier, Venoshock, Hydro Pump | Brine, Barrier, Venoshock, Toxic | Poison chip enables Venoshock immediately and eventually Brine; retain Barrier and trade the second Water attack for self-contained setup. |
| Crobat | 64 | Wing Attack, Poison Fang, Shadow Leech, Haze | Keep current | Keep the reviewed role and working combination. |
| Arbok | 70 | Poison Fang, Crunch, Screech, Coil | Keep current | Keep the reviewed role and working combination. |

### Sabrina — record 2

| Pokémon | Level | Current moves | Proposed moves | Reason |
|---|---:|---|---|---|
| Mrmime | 62 | Substitute, Mind Break, Psych Up, Psychic | Keep current | Keep the reviewed role and working combination. |
| Hypno | 66 | Dream Eater, Psybeam, Psychic, Amnesia | Dream Eater, Hypnosis, Psychic, Amnesia | Replace redundant Psybeam with the missing sleep move; both sleep/drain and Special setup now have a purpose. |
| Jynx | 68 | Psybeam, Frost Breath, Psychic, Blizzard | Lovely Kiss, Charm, Psychic, Blizzard | Restore sleep and the approved Charm niche for frail Jynx; keep Blizzard to distinguish this from Lorelei’s Frost Breath set. |
| Slowbro | 65 | Rest, Withdraw, Psychic, Surf | Rest, Amnesia, Psychic, Surf | Special setup improves both STAB attacks and Special defense; distinguish this set from Lorelei’s Ice Beam coverage. |
| Alakazam | 70 | Kinesis, Psychic, Psych Up, Mind Break | Kinesis, Psychic, Recover, Mind Break | Keep physical/accuracy disruption and anti-Special-setup damage; replace the less reliable copied-stage slot with recovery. |

### Blaine — record 2

| Pokémon | Level | Current moves | Proposed moves | Reason |
|---|---:|---|---|---|
| Charizard | 65 | Wing Attack, Flamethrower, Fire Spin, Dragon Dance | Keep current | Keep the reviewed role and working combination. |
| Arcanine | 63 | Flamethrower, Crunch, Double Edge, Fire Blast | Flamethrower, Crunch, Double Edge, Rest | Replace the second Fire attack with legal full healing/status removal to offset Double-Edge recoil; Rest leaves two vulnerable turns. Cauterize is not in the current Arcanine learnset. |
| Rapidash | 62 | Horn Attack, Flamethrower, Pierce, Horn Drill | Stomp, Flamethrower, Pierce, Horn Drill | Upgrade the early Horn Attack slot to the horse’s flinch move; preserve piercing coverage and the redesigned high-risk Horn Drill. |
| Flareon | 66 | Fire Spin, Flamethrower, Cauterize, Fire Blast | Fire Spin, Flamethrower, Cauterize, Reflect | Emphasize the reviewed bulky Flareon role rather than three Fire attacks; keep residual pressure and quarter-HP healing. |
| Magmar | 70 | Mega Punch, Cauterize, Flamethrower, Fire Blast | Mega Punch, Facade, Cauterize, Fire Blast | Retain Fire/Fighting offense and quarter-HP healing, add legal neutral physical coverage and a status-punishing Facade. Psychic is not currently permitted. |
