# Hypno, Kingler and Electrode family redesigns

Cumulative Red/Blue patches retain every previous sprite, species, type change, move effect and family review. There are 183 species and now 227 move records. All six reviewed species keep their stats. No item, animation asset or save field is added.

## Electro Ball

New move 227: Electric, special, 100 accuracy, 10 PP, Thunder Shock animation. Base power is selected at execution from current battle Speed, including stages and paralysis:

| User Speed / target Speed | Power |
| --- | ---: |
| Less than 1 | 40 |
| At least 1, less than 2 | 60 |
| At least 2, less than 3 | 80 |
| At least 3, less than 4 | 120 |
| At least 4 | 150 |

The ROM stores a 40-power base record and computes the bracket dynamically without changing that record. Bounded 16-bit subtraction avoids overflow from multiplying large Speed values. A defensive zero-target-Speed guard treats it as one. Critical hits retain the power bracket selected from current Speeds, then use existing Gen 1 critical damage rules. Ground immunity and ordinary accuracy/invulnerability checks remain intact. The AI evaluates the same current-power brackets. Thunderbolt remains a useful machine alternative against similarly fast targets.

## Stats and level-up moves

Stats are HP / Attack / Defense / Speed / Special.

### Drowzee

Stats: 60 / 48 / 45 / 42 / 90.

Starts: POUND, HYPNOSIS.

Level-up: 7: SAND_ATTACK, 13: CONFUSION, 19: DISABLE, 25: HEADBUTT, 33: PSYBEAM, 40: PSYCHIC_M.

### Hypno

Stats: 85 / 73 / 70 / 67 / 115.

Starts: POUND, HYPNOSIS, CONFUSION.

Level-up: 7: SAND_ATTACK, 13: CONFUSION, 19: DISABLE, 25: HEADBUTT, 27: DREAM_EATER, 33: PSYBEAM, 40: PSYCHIC_M, 47: AMNESIA.

### Krabby

Stats: 30 / 105 / 90 / 50 / 25.

Starts: BUBBLE, LEER.

Level-up: 7: HARDEN, 13: VICEGRIP, 20: STOMP, 27: SHELL_BREAK, 34: CRABHAMMER, 41: SWORDS_DANCE.

### Kingler

Stats: 55 / 130 / 115 / 75 / 50.

Starts: BUBBLE, LEER, VICEGRIP.

Level-up: 7: HARDEN, 13: VICEGRIP, 20: STOMP, 27: SHELL_BREAK, 34: CRABHAMMER, 41: SWORDS_DANCE, 48: GUILLOTINE.

### Voltorb

Stats: 40 / 30 / 50 / 100 / 55.

Starts: TACKLE, SCREECH.

Level-up: 7: THUNDERSHOCK, 14: SONICBOOM, 21: SELFDESTRUCT, 28: LIGHT_SCREEN, 35: ELECTRO_BALL, 42: SWIFT.

### Electrode

Stats: 60 / 50 / 70 / 140 / 80.

Starts: TACKLE, SCREECH, THUNDERSHOCK.

Level-up: 7: THUNDERSHOCK, 14: SONICBOOM, 21: SELFDESTRUCT, 28: LIGHT_SCREEN, 35: ELECTRO_BALL, 42: SWIFT, 49: EXPLOSION.

## Roles and machine changes

Drowzee/Hypno retain Psychic/Ground and the Sandman identity. Sand Attack is the existing damaging Ground accuracy-drop move. Dream Eater arrives immediately after evolution at 26; Amnesia is Hypno's late setup. Remove Astonish, Poison Gas, Psyshock, Psych Up, Punishment, Mind Break and Meditate leveling. Add Dig TM28 to both; do not add Earthquake or Mud Wave. Remove Mega Punch, Mega Kick and Submission from both, plus Hyper Beam from Hypno. Keep Psychic, Dream Eater, Thunder Wave, Reflect, Rest, Mimic, Substitute, Curse, Body Slam, Counter and Seismic Toss permissions.

Krabby/Kingler focus on claws. Vice Grip is physical Bug; Shell Break is the existing damaging Bug Defense-drop move, distinct from Shell Smash. Crabhammer remains Normal, high critical, 90 power/90 accuracy. Its critical hits ignore Swords Dance boosts and target Defense drops; other physical attacks benefit normally. Guillotine damages and lowers target Special by two stages. Remove Flail and X-Scissor leveling. Add Facade TM52 to both and remove Scald TM59 from both; remove Hyper Beam from Kingler. Keep Swords Dance, Body Slam, Surf, Ice Beam, Blizzard, Cut, Strength, Rest and Brine. No Earthquake or Dig addition. Evolution remains 28.

Voltorb/Electrode focus on speed, screens and explosive pressure. Remove provisional Charge and Shock Wave leveling; teach Electro Ball at 35. Electrode gains Explosion at 49. Keep Thunderbolt, Thunder, Thunder Wave, Reflect, Double Team, Swift, Rest, Self-Destruct and Explosion machine permissions; remove Hyper Beam from Electrode. Toxic remains unavailable and no Agility is added. Evolution remains 30.

Custom variants retain individual stats, starting moves and machine masks; shared parent learnset pointers follow revised parent lists. Other permissions, shops and prices remain unchanged.

## Updating and validation

Apply the matching BPS to an original unmodified English Red/Blue ROM. Current 183-species saves retain the same layout; already known moves are not automatically deleted. Earlier 151/172/176-species saves require a fresh start.

The tuning registry now contains 102 reviewed entries: 101 originals plus Crobat. Existing tests validate exact stats/starts/learnsets, actual generated moves/PP, original/extra machine masks and historical variants in both versions. New Electro Ball tests cover exact ratios, 16-bit extremes, current Speed stages/paralysis, critical hits, action-time changes, AI, actual execution/PP, Ground immunity and SRAM retention. All earlier species, sprite, encounter, save, move, critical-hit and freeze regressions remain included. Packaging applies each BPS to a verified original and compares byte for byte with its build.
