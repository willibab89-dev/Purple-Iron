# Meowth, Psyduck and Mankey family redesigns

This cumulative Red/Blue patch implements the three approved family plans, including the audit's Bubblebeam adjustment. Species remain 183 and move records remain 222. Every previous sprite, added species, move effect, type change and individual review remains included. No new move, TM item, battle handler or saved field is introduced.

## Stats

| Pokémon | HP | Attack | Defense | Speed | Special |
| --- | ---: | ---: | ---: | ---: | ---: |
| Meowth | 40 | 45 | 35 | 90 | 40 |
| Persian | 65 | 80 | 60 | 115 | 65 |
| Psyduck | 50 | 52 | 48 | 55 | 50 |
| Golduck | 80 | 82 | 78 | 85 | 80 |
| Mankey | 40 | 80 | 35 | 70 | 35 |
| Primeape | 75 | 105 | 60 | 95 | 60 |

Only Persian's Attack 70→80 and Primeape's HP 65→75 change. Psyduck/Golduck keep their stats, and Golduck retains its implemented Water/Psychic typing.

## Starting and level-up moves

### Meowth

Starts with Scratch, Growl.

9: Bite, 14: Pay Day, 19: Fury Swipes, 24: Screech, 29: Slash, 35: Punishment.

### Persian

Starts with Scratch, Growl, Bite, Screech.

9: Bite, 14: Pay Day, 19: Fury Swipes, 24: Screech, 31: Slash, 38: Punishment.

### Psyduck

Starts with Scratch, Tail Whip.

7: Water Gun, 12: Confusion, 17: Disable, 22: Bubblebeam, 27: Psybeam, 31: Amnesia, 40: Hydro Pump, 46: Psychic.

### Golduck

Starts with Scratch, Tail Whip, Water Gun, Confusion.

7: Water Gun, 12: Confusion, 17: Disable, 22: Bubblebeam, 27: Psybeam, 31: Amnesia, 34: Psyshock, 44: Hydro Pump, 50: Psychic.

### Mankey

Starts with Scratch, Leer.

7: Low Kick, 12: Karate Chop, 17: Fury Swipes, 22: Rage, 27: Focus Energy, 32: Punishment, 38: Thrash.

### Primeape

Starts with Scratch, Leer, Karate Chop, Fury Swipes.

7: Low Kick, 12: Karate Chop, 17: Fury Swipes, 22: Rage, 27: Focus Energy, 29: Brick Break, 34: Punishment, 42: Thrash.

Evolution stays at 28 for Meowth, 33 for Psyduck and 28 for Mankey. Slash arrives much earlier for Persian. Psyshock arrives immediately after Golduck's normal evolution, and Brick Break immediately after Primeape's.

## Roles and compatibility

**Meowth family:** slippery, fast opportunists. Earlier Pay Day, claw attacks, Screech and Punishment support its speed without adding recovery or setup. Keep Pay Day, Mimic, Substitute, Double Team, Aerial Ace, Body Slam, Facade, Swift and Rest. Remove Water Gun, Bubblebeam, Thunderbolt, Thunder and Skull Bash, plus Persian's Hyper Beam. Toxic remains excluded. Critical Slash ignores Attack boosts and Defense drops; Screech mainly helps ordinary hits, and may reduce Punishment's base power when it removes positive target Defense stages.

**Psyduck family:** headaches developing into controlled psychic power. Bubblebeam at 22 replaces the proposed Fury Swipes slot for both, improving the natural Water progression and supplying a guaranteed Speed drop after an eligible hit. Amnesia clears negative user stages, preserves positive stages, then raises Special one stage. Golduck's Psyshock uses Special against Defense. Add Psychic TM29 to both. Keep Surf, Brine, Scald, Ice Beam, Blizzard, Body Slam, Strength and Rest. Remove Dig, Submission, Seismic Toss and Skull Bash, plus Golduck's Hyper Beam. No direct recovery or speed-boost move is added. Existing optional machine permissions not explicitly changed remain intact.

**Mankey family:** anger, commitment and risk. Rage and Fury Swipes provide Attack-boost opportunities; Focus Energy/Karate Chop is an alternative critical route. Remove provisional Bulk Up, Seismic Toss, Drain Punch and Screech leveling; Bulk Up and Seismic Toss remain machine options. Keep Rage, Facade, Double-Edge, Bulk Up, Submission, Counter, Seismic Toss, Mega Punch, Mega Kick, Rock Slide, Strength, Double Team and Rest. Remove Thunderbolt, Thunder, Dig and Metronome, plus Primeape's Hyper Beam. Toxic remains excluded.

Rage's Attack boosts persist after its 2–3 turn lock until ordinary stage-reset conditions remove them. Critical hits ignore those boosts. Thrash is Normal coverage rather than a direct upgrade to Fighting STAB: Brick Break's 70 power becomes effectively 105 against a neutral target with STAB, while Thrash is 90 and requires commitment. Punishment remains Ghost-type and capped at 160 power.

No extra-TM masks, shop stock or prices change in this patch. Other species and all custom variants retain their headers and machine permissions.

## Updating and validation

Download artifact `pokemon-183-species-bps` from the successful Actions run and apply the matching BPS to an original, unmodified English Red/Blue ROM. Existing 183-species saves retain their layout; earlier 151/172/176-species saves require a fresh start. Already learned moves are not automatically deleted. A normal level-up recalculates current party stats.

The registry now contains 60 reviewed species: 59 originals (every species through Primeape, Farfetch'd and Onix), plus Crobat. Tests check exact stats/starts/learnsets, actual generated moves/PP, historical variants and original/extra TM permissions, including the new Psychic compatibility and the approved removals. Moonlight, Wake-Up Slap and Quiver Dance tests remain included alongside the full existing species/sprite/encounter/save/move/crit/freeze regression suite in both versions. Both BPS patches are applied to verified originals and compared byte for byte with the builds.
