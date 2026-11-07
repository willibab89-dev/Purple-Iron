# Paras, Venonat and Diglett family redesigns

This cumulative Red/Blue patch implements the three approved plans after their audit. Species remain 183; move records increase from 221 to 222, with Struggle 165 unchanged. Every prior sprite, added species, move effect, type change and individual review remains included.

## Stats

| Pokémon | HP | Attack | Defense | Speed | Special |
| --- | ---: | ---: | ---: | ---: | ---: |
| Paras | 35 | 70 | 55 | 25 | 55 |
| Parasect | 70 | 95 | 80 | 30 | 80 |
| Venonat | 60 | 55 | 50 | 45 | 40 |
| Venomoth | 70 | 65 | 60 | 90 | 90 |
| Diglett | 10 | 55 | 25 | 95 | 45 |
| Dugtrio | 35 | 95 | 50 | 120 | 70 |

Only Parasect's HP 60→70 and Dugtrio's Attack 80→95 change. Venomoth and the earlier stages retain their stats. Existing typings stay unchanged, including Bug/Ghost Parasect.

## Starting and level-up moves

### Paras

Starts with Scratch.

7: Stun Spore, 12: Leech Life, 16: Poison Powder, 20: Slash, 23: Spore, 29: X Scissor.

### Parasect

Starts with Scratch, Stun Spore, Leech Life, Poison Powder.

7: Stun Spore, 12: Leech Life, 16: Poison Powder, 20: Slash, 23: Spore, 25: Shadow Leech, 31: X Scissor, 38: Curse, 43: Lunge.

### Venonat

Starts with Tackle, Disable.

8: Confusion, 13: Poison Powder, 18: Leech Life, 23: Sleep Powder, 28: Psybeam, 40: Psychic.

### Venomoth

Starts with Tackle, Disable, Confusion, Poison Powder.

8: Confusion, 13: Poison Powder, 18: Leech Life, 23: Sleep Powder, 28: Psybeam, 32: Quiver Dance, 42: Psychic.

### Diglett

Starts with Scratch, Growl.

5: Sand Attack, 12: Dig, 20: Slash, 25: Screech, 33: Earthquake, 41: Fissure.

### Dugtrio

Starts with Scratch, Growl, Dig.

5: Sand Attack, 12: Dig, 20: Slash, 27: Screech, 37: Earthquake, 47: Fissure.

Paras evolves at 24, Venonat at 31 and Diglett at 26. Evolution requirements are unchanged. Spore arrives before Paras's evolution, Shadow Leech immediately after; Quiver Dance arrives immediately after Venonat's evolution.

## Quiver Dance

New move ID 222, Bug-type status move, 10 PP: Special +1 and Speed +1. It reuses the existing two-stat boost handler and Agility animation; no new battle handler or saved state is introduced. Venomoth learns it at 32. It is not a TM.

Special increases both special damage and special durability under the game's Gen 1 rules. Bug and Poison attacks remain physical, so Quiver Dance does not strengthen Leech Life or Venoshock. Psychic attacks benefit but receive no STAB from Venomoth's Bug/Poison typing. Each boost independently respects the existing stage caps; a capped stat does not prevent the other boost. AI uses the same table and discourages it only when neither stage can rise.

## Roles and compatibility

**Paras family:** fungal sleep/draining control. Spore enables Shadow Leech's full actual-damage healing; Curse provides an alternative enabling condition plus residual damage. Normal targets are immune to both Ghost components, requiring Bug coverage. Poison/Toxic and Curse are mutually exclusive. Add Leech Life TM61 to both and Curse TM60 to Parasect. Keep Swords Dance, Cut, Dig, Rest, Toxic and Venoshock. Keep Paras's Mega Drain/Solar Beam compatibility but remove those two TMs from Parasect, along with Hyper Beam. Remove provisional Giga Drain, Ingrain, Growth, Shell Break and Ambush level-up additions. Lunge provides the approved late Attack-drop option; it does not gain priority in this patch.

**Venonat family:** hypnotic special setup. Earlier Confusion and Sleep Powder lead into Venomoth's Quiver Dance/Psychic route. Poison/Toxic plus physical Venoshock remains an alternative. Remove Supersonic, Stun Spore, Lunge and Ambush from leveling. Keep Psychic, Psywave, Toxic, Venoshock, Reflect, Rest and Venomoth's Double Team. Remove Mega Drain and Solar Beam from both; remove Roost, Twister, Whirlwind and Hyper Beam from Venomoth. No base-stat buff or easy recovery is added.

**Diglett family:** fast, fragile Ground offense. Earlier Dig and Slash, then Screech, Earthquake and late Fissure. Keep Ground TMs, Rock Tomb/Rock Slide, Cut, Double Team and Rest. Remove Body Slam from both and Hyper Beam from Dugtrio. Toxic and Substitute remain excluded. Slash criticals ignore Screech's Defense drops; ordinary Ground attacks can exploit them. Fissure remains 100 power, 40 accuracy and target Attack−2 after an eligible hit, not an OHKO.

No new TM items, shop stock or prices are needed. TM61 remains in Fuchsia for 4,000; TM60 in Lavender for 10,000. Unrelated species and Mew's all-TM compatibility remain unchanged.

## Updating and validation

Download artifact `pokemon-183-species-bps` from the successful Actions run and apply the matching BPS to an original, unmodified English Red/Blue ROM. Existing 183-species saves retain their layout; earlier 151/172/176-species saves require a fresh start. Existing moves are not automatically deleted by evolution or compatibility changes. A normal level-up recalculates current party stats.

The registry now contains 54 reviewed species: 53 originals (every species through Dugtrio, Farfetch'd and Onix), plus Crobat. Tests cover exact stats/starts/learnsets, real party moves/PP, historical variants and original/extra TM permissions. Quiver Dance has 26 boost/cap/status/self-gate/pipeline/AI cases per ROM, plus generated PP and SRAM/PP-Up preservation. The expanded integration checks cover all 222 names/animations and Metronome choices. Moonlight, Wake-Up Slap and the full existing species/sprite/encounter/save/move/crit/freeze regression suites also run in both versions. Both cumulative BPS patches are applied to verified originals and compared byte for byte against the builds.
