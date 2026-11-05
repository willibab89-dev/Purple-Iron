# Move overhaul — patch 1

This is a cumulative patch: it includes all previous front sprites, 21 new species, encounters, critical-hit changes and natural thawing. It updates 56 existing moves. It adds no move IDs, changes no learnsets, and introduces no new battle-state/save fields. Water Gun already matches 40 power / 100 accuracy / 25 PP. Aurora Beam already matches the requested 65 power / 100 accuracy / 20 PP with its existing approximately 33% Attack drop.

Apply the Red/Blue BPS patch to its verified original ROM, not to a previously patched ROM. Existing saves from the 172-species version retain their layout. Heal your party at a Pokémon Center after updating so stored PP is refreshed against the changed move limits. Saves from the old 151-species version remain incompatible.

## Delivered changes

Only the changes listed below are applied. Other numeric fields and existing effects remain as before unless an effect replacement is explicitly listed. A move deferred below is kept entirely at its pre-overhaul implementation, even when some of its target numbers could be edited independently. This avoids presenting a partial redesign as complete.

The established secondary-effect routines have their existing byte-based approximations: about 30% flinch is 77/256, and about 33% stat reduction is 85/256. No new percentage system is introduced in this patch.

| Move | Applied changes |
| --- | --- |
| KARATE CHOP | type: NORMAL → FIGHTING |
| DOUBLESLAP | power: 15 → 20; accuracy: 85 → 95; PP: 10 → 15; fixed two-hit effect (power is per hit); high crit (our existing ×2 bonus), with separate rolls on each hit |
| MEGA PUNCH | type: NORMAL → FIGHTING |
| VICEGRIP | type: NORMAL → BUG; power: 55 → 75 |
| CUT | type: NORMAL → BUG |
| GUST | type: NORMAL → FLYING |
| WING ATTACK | power: 35 → 65; PP: 35 → 25 |
| FLY | accuracy: 95 → 100 |
| VINE WHIP | existing ~30% flinch effect |
| MEGA KICK | type: NORMAL → FIGHTING |
| JUMP KICK | power: 70 → 100; accuracy: 95 → 90; PP: 25 → 10; renamed to FLYING PUNCH |
| HORN ATTACK | existing ~33% Defense −1 side effect |
| BODY SLAM | power: 85 → 80; accuracy: 100 → 95 |
| DOUBLE-EDGE | PP: 15 → 10 |
| POISON STING | power: 15 → 25 |
| TWINEEDLE | power: 25 → 35 |
| PIN MISSILE | power: 14 → 25 |
| SING | accuracy: 55 → 60 |
| SUPERSONIC | accuracy: 55 → 85 |
| ACID | power: 40 → 55 |
| FLAMETHROWER | power: 95 → 80 |
| MIST | PP: 30 → 15 |
| HYDRO PUMP | power: 120 → 100; accuracy: 80 → 85 |
| SURF | power: 95 → 80 |
| ICE BEAM | power: 95 → 80 |
| BLIZZARD | power: 120 → 100 |
| SUBMISSION | power: 80 → 100; accuracy: 80 → 95; PP: 25 → 10 |
| ABSORB | power: 20 → 30 |
| MEGA DRAIN | power: 40 → 60 |
| LEECH SEED | accuracy: 90 → 100; PP: 10 → 15 |
| RAZOR LEAF | accuracy: 95 → 100 |
| POISONPOWDER | accuracy: 75 → 85; PP: 35 → 30 |
| STUN SPORE | accuracy: 75 → 85; PP: 30 → 20 |
| DRAGON RAGE | power: 1 → 60; ordinary calculated damage; replaces fixed damage; high crit (our existing ×2 bonus), with separate rolls on each hit |
| THUNDERBOLT | power: 95 → 80 |
| ROCK THROW | accuracy: 65 → 100 |
| EARTHQUAKE | power: 100 → 90 |
| DIG | power: 100 → 70 |
| PSYCHIC | power: 90 → 80; PP: 10 → 15 |
| HYPNOSIS | accuracy: 60 → 70 |
| CONFUSE RAY | accuracy: 100 → 95 |
| HAZE | PP: 30 → 10 |
| LICK | power: 20 → 40 |
| SMOG | power: 20 → 40; accuracy: 70 → 95 |
| SLUDGE | power: 65 → 75 |
| FIRE BLAST | power: 120 → 100; accuracy: 85 → 90 |
| CLAMP | power: 35 → 50; accuracy: 75 → 90; heal 50% of damage dealt; replaces trapping; renamed to CHOMP |
| SPIKE CANNON | type: NORMAL → ROCK; accuracy: 100 → 95; PP: 15 → 20 |
| HI JUMP KICK | power: 85 → 110; accuracy: 90 → 85; PP: 20 → 10 |
| POISON GAS | accuracy: 55 → 100; PP: 40 → 20 |
| BARRAGE | type: NORMAL → GRASS; power: 15 → 20; accuracy: 85 → 90 |
| LEECH LIFE | power: 20 → 40 |
| SPORE | accuracy: 100 → 95; PP: 15 → 10 |
| ACID ARMOR | PP: 40 → 15 |
| CRABHAMMER | type: WATER → NORMAL; accuracy: 85 → 90 |
| ROCK SLIDE | power: 75 → 65; existing ~30% flinch effect |

Chomp remains Water-type, uses Special, keeps Clamp's animation, and uses the established drain behavior (including its Substitute restriction). Flying Punch remains Fighting-type and reuses Jump Kick's animation. Both kicking moves retain Shin's existing one-eighth potential-damage crash effect. Moves keep their existing IDs, TM/HM compatibility and learnsets; Cut and Fly retain their field functions. New move names and numeric stats appear through the existing interfaces.

Dragon Rage now uses normal Dragon damage and can critically hit; it no longer deals fixed 40 damage. Double Slap now always attempts two hits after its ordinary accuracy check, rather than 2–5; a knockout after the first hit can end the attack early. Its high-crit bonus is applied on each hit by the existing battle loop.

## Confirmed target designs requiring later engine work

All 54 new moves are deferred. Even simple new clones need the move-ID/animation separation and move-pool/Metronome groundwork, which is intentionally outside this data-focused first patch. No placeholder new moves are inserted.

The following existing moves have requested redesigns that are also deferred in full:

- Rage: 40 pwr. 95 acc. 20 pp. Lasts 2-3 turns. +1 atk when hit during this (stacks)
- Slam: 60 pwr. 90 acc. 20 pp. -1 defense (100%)
- Egg Bomb: Also removes reflect and light screen from target.
- Dizzy Punch: 30% confusion chance
- Stomp: Double damage against confused targets.
- Skull Bash: +2 defense during charging turn.
- Bide: stores damage for 2 turns.
- Take Down: 60 pwr. Double damage against targets below half HP.
- Horn Drill: 120 pwr. 40 acc. 5 pp. -2 defense stages
- Guillotine: 120 pwr. 40 acc. 5 pp. -2 special stages.
- Wrap: 25 pwr. 90 acc. 15 pp. Deals damage each turn and prevents the target switching for **2–3 turns**. Both Pokémon can attack normally. Switching the user out releases the target.
- Bind: **60 power, 90 accuracy, 15 PP**. Lowers the target’s **Speed by one stage** after hitting. No ongoing trap. (more powerful then constriction but less accurate)
- Fury Attack: 80 pwr. 95 acc. 15 pp. Lowers users atk after a successful hit.
- Fury Swipes: 35 pwr. 80 acc. 15 pp. Hits twice. If it misses you gain +1 atk.
- Comet Punch: 100 pwr. 50 acc. 15 pp. Confuses target (100%) hits once.
- Tri Attack: 20% chance to inflict freeze, burn or paralysis. only 1 condition happens.
- Roar: Now forces switching in trainer battles. 
- Transform: automatically transforms.
- Splash: Lowers targets attack and accuracy (makes them underestimate you)
- Sharpen: +1 atk / +1 accuracy
- Petal Dance: 90 pwr. 100 acc. 10 pp. Lowers targets evasion. (nod to sweet scent)
- Growth: Now a grass move. +1 special / +1 defense
- Constrict: Now a grass move. 25 pwr. 100 acc. 15 pp. Lowers speed by 1 stage.
- String Shot: 15 pwr. 
- Psywave: 100 acc. 15 pp.
- Kinesis: Lowers accuracy and attack by 1 stage.
- Meditate: +1 atk / +1 speed. 15 pp.
- Amnesia: +1 special. Cures negative stat changes. 10 pp.
- Counter: Works on any physical attack.
- Fire Spin: 35 pwr. 85 acc. 15 pp. Deals damage once, then **¹⁄₁₆ maximum HP residual damage for three turns**. Does not prevent switching; switching clears the effect.
- Bubble: 25 pwr. 100 acc. 30 pp. -1 speed (30%)
- Bubblebeam: 60 pwr. 100 acc. 20 pp. -1 speed (100%)
- Waterfall: 70 pwr. 100 acc. 15 pp. ignores the targets positive special stages.
- Withdraw: +1 defense / +1 accuracy
- Flash: Is now an electric move. 50 pwr. 100 acc. 50% chance to lower accuracy by 1 stage.
- Thunder: 100 pwr. 70 acc. Always hits if target has a major status effect
- Fissure: 100 pwr. 40 acc. 5 pp. -2 attack stages.
- Sand Attack: Now ground type. 15 pwr. 95 acc.
- Drill Peck: 80 pwr. 100 acc. 15 pp. Ignores positive defense stages.
- Whirlwind: Now a flying move. Now forces switching in trainer battles. 
- Razor Wind = Renames to Twister: Now a dragon move. 40 pwr. 100 acc. 15 pp. 30% flinch. Double damage versus targets using fly.

These require one or more of: a new compound effect, guaranteed/adjustable secondary-effect odds, conditional damage or critical hits, timer/switching state, multi-stat changes, automatic transformation, or a previously identified technical fix. In particular, the old OHKO moves remain OHKO moves until their complete replacements are implemented; Rage, Wrap and Fire Spin still retain their current Shin behaviors in this first patch. Thunder does not yet gain status-based accuracy bypass, and Flash keeps its existing non-damaging behavior.

## Decisions still outstanding

The complete design is preserved in MOVE-OVERHAUL-PLAN.md. Missing PP/accuracy values for new moves, Flail's power curve, Fury Attack's drop size, residual timing rules, automatic transformation exceptions (including Happy Ditto), and hybrid damage/screen/crit interactions still need final definitions. Later decision: Punishment is capped at 160 power. See MOVE-PATCH-2-PLAN.md for accepted defaults and MOVE-PATCH-2.md for subsequent delivered changes.

## Validation

Run `python3 tools/test_move_patch_1.py` with PyBoy installed after building both ROMs. It checks all 165 ROM move records and names against the baseline plus the approved cumulative patch changes; verifies deferred and unchanged moves; loads each changed move through both actor paths; executes the reused fixed two-hit effect; and confirms the extended high-crit membership. The existing species, encounters, save/load, critical-hit and freeze suites also run in CI. BPS packages are validated by applying them to verified original ROMs and comparing the result byte for byte. This is automated engine validation, not a full manual playthrough.
