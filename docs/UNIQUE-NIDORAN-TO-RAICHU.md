# Unique Nidoran, Omanyte, Brock's Onix and Surge's Raichu

Cumulative Red/Blue patches include all earlier sprites, species, move changes and TM changes. Species count remains 183; move count remains 236 including Struggle. Existing 183-species saves remain compatible. No new battle effects or save fields are introduced.

Stats are HP / Attack / Defense / Speed / Special. All four variants have independent level-up lists and no evolution. Ordinary counterparts are unchanged.

## Unique Nidoran male

Pure Poison; 76 / 77 / 80 / 65 / 65.

Starts with Tackle and Leer. Level 7 Poison Sting, 15 Double Kick, 23 Charm, 31 Poison Fang, 39 Venoshock, 47 Flail.

TMs: Toxic, Body Slam, Double-Edge, Rage, Reflect, Rest, Substitute, Venoshock and Poison Tail. No elemental coverage, Horn Drill, Earthquake or stat-boost setup. Its existing 1% land encounters wherever either ordinary Nidoran gender appears remain. It no longer evolves into ordinary Nidorino.

Charm helps it survive physical attacks, poisoning enables Venoshock, and Flail rewards surviving at low HP. Poison moves use Attack under the game's Gen 1 damage categories.

## Unique Omanyte

Rock/Water; 65 / 55 / 110 / 40 / 95.

Starts with Water Gun and Withdraw. Level 9 Constrict, 17 Wrap, 25 Chomp, 33 Rock Tomb, 41 Brine, 49 Amnesia. Chomp retains the internal CLAMP move ID and heals half of damage dealt. Brine doubles power when the target is at or below half HP. Amnesia gives +1 Special and clears negative stat stages; it is not the original +2 Special move.

TMs: Bubblebeam, Water Gun, Ice Beam, Reflect, Bide, Rest, Substitute, Surf, Brine and Rock Tomb. No Blizzard, Scald, Shell Smash or direct recovery move beyond Rest. Existing 1% level-20 Rock Tunnel land encounters on both floors remain. It no longer evolves into ordinary Omastar.

## Brock's Onix

Rock/Ground; 50 / 60 / 150 / 50 / 40.

Starts with Tackle and Screech. Level 7 Harden, 15 Wrap, 23 Rock Throw, 31 Rock Tomb, 39 Stone Press, 47 Rock Polish.

Brock retains his level-15 variant. Its final loaded set is Tackle, Screech, Harden and Wrap. The old Bide override is removed. Both sides can attack during Wrap; the target's voluntary switching is prevented for its existing short duration. Harden improves physical durability and Stone Press damage later on. Its 4x Water/Grass weaknesses remain.

TMs: Body Slam, Dig, Bide, Rest, Rock Slide, Substitute, Strength and Rock Tomb. No Earthquake, Fissure, Selfdestruct or Explosion; no recovery beyond Rest.

## Surge's Raichu

Pure Electric; 70 / 100 / 70 / 85 / 85.

Starts with Thunder Shock and Growl. Level 7 Quick Attack, 15 Thunder Wave, 23 Thunder Punch, 31 Mega Punch, 39 Body Slam, 47 Light Screen, 55 Zap Cannon.

Surge retains his level-25 variant. Its final loaded set is Growl, Quick Attack, Thunder Wave and Thunder Punch. The old Thunderbolt override is removed. Thunder Punch uses Special; Mega Punch is Fighting-type and uses Attack. Zap Cannon has 100 accuracy against paralyzed targets, subject to its existing immunity and invulnerability rules.

TMs: Mega Punch, Mega Kick, Body Slam, Counter, Seismic Toss, Thunderbolt, Thunder, Reflect, Swift, Rest, Thunder Wave, Substitute and Facade. Flash HM compatibility is retained. No Hyper Beam, Double Team, Agility or Charge.

## Correction to final Gym leader moves

Shin's ReadTrainer first generates natural moves, then applies SpecialTrainerMoves. Earlier review checks validated generated species moves, overlooking these final overrides. This patch supersedes earlier descriptions of the affected final boss sets:

- Brock's Onix: Tackle / Screech / Harden / Wrap.
- Surge's Raichu: Growl / Quick Attack / Thunder Wave / Thunder Punch.
- Erika's unique Ivysaur: Stun Spore / Leech Seed / Reflect / Vine Crush. Its four old slot overrides are removed.
- Giovanni's unique Nidoking: Stomp / Crunch / Earthquake / Poison Fang. Its old Earthquake and Ice Beam slot overrides are removed, restoring the agreed natural set.
- Koga's unique Grimer: Sludge / Disable / Toxic / Acid Armor. No correction was required; its slot had no special override.

Unrelated trainer overrides are preserved, including Erika's Venusaur, Giovanni's other team members, Koga's other team members and Misty's Starmie. Changes to other Gym members await their own reviews.

## Updating and verification

Apply the matching BPS to an original, unmodified Red or Blue ROM. Back up saves. Existing Pokémon keep previously learned moves; changed stats appear when recalculated, such as on level-up. Shin's move relearner supplies eligible missed moves. No types change in this batch.

Automated checks execute the actual ReadTrainer routine in both versions with default unscaled levels, including natural move generation and special trainer overrides. They check all five reviewed Gym variants above and preserve selected unrelated overrides. Existing species, generated moves/PP, evolution, encounters, saves, TM and battle-mechanics suites also run. BPS application is compared byte for byte with the built ROMs. This is not a full manual campaign playthrough; Brock's early-game balance should still be evaluated in play.

The broad redistribution of new moves to earlier species remains deferred until the final review.
