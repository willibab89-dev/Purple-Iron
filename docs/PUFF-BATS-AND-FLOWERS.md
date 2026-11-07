# Jigglypuff, Zubat/Crobat and Oddish family redesigns

This cumulative Red/Blue patch implements the three approved family plans after their audit. Species remain 183; move records increase from 220 to 221, including unchanged Struggle 165. Every earlier sprite, added species, type change, move effect and individual redesign remains included.

## Stats

| Pokémon | HP | Attack | Defense | Speed | Special |
| --- | ---: | ---: | ---: | ---: | ---: |
| Jigglypuff | 115 | 45 | 20 | 20 | 25 |
| Wigglytuff | 140 | 70 | 45 | 45 | 65 |
| Zubat | 40 | 45 | 35 | 55 | 40 |
| Golbat | 75 | 80 | 70 | 90 | 75 |
| Crobat | 85 | 90 | 80 | 130 | 80 |
| Oddish | 45 | 50 | 55 | 30 | 75 |
| Gloom | 60 | 65 | 70 | 40 | 85 |
| Vileplume | 75 | 80 | 85 | 50 | 110 |

Only Wigglytuff's Special 50→65 and Vileplume's Special 100→110 change. All other listed stats and types stay unchanged.

## Starting and level-up moves

### Jigglypuff

Starts with Sing, Pound.

7: Defense Curl, 12: Double Slap, 17: Disable, 23: Stockpile, 29: Body Slam, 35: Rest, 41: Wake-Up Slap.

### Wigglytuff

Starts with Sing, Pound, Defense Curl, Double Slap.

7: Defense Curl, 12: Double Slap, 17: Disable, 26: Stockpile, 32: Body Slam, 38: Rest, 45: Wake-Up Slap.

### Zubat

Starts with Leech Life.

5: Supersonic, 10: Bite, 15: Wing Attack, 20: Confuse Ray, 23: Screech, 25: Poison Fang, 30: Shadow Leech, 35: Haze.

### Golbat

Starts with Leech Life, Supersonic, Bite.

5: Supersonic, 10: Bite, 15: Wing Attack, 20: Confuse Ray, 23: Screech, 28: Poison Fang, 34: Shadow Leech, 39: Haze.

### Crobat

Starts with Leech Life, Bite, Screech, Confuse Ray.

5: Supersonic, 10: Bite, 15: Wing Attack, 20: Confuse Ray, 23: Screech, 28: Poison Fang, 34: Shadow Leech, 44: Haze.

### Oddish

Starts with Absorb.

9: Poison Powder, 12: Stun Spore, 15: Sleep Powder, 19: Mega Drain, 23: Acid, 31: Giga Drain, 37: Petal Dance, 43: Solar Beam.

### Gloom

Starts with Absorb, Poison Powder, Stun Spore.

9: Poison Powder, 12: Stun Spore, 15: Sleep Powder, 20: Mega Drain, 26: Acid, 35: Giga Drain, 42: Petal Dance, 49: Solar Beam.

### Vileplume

Starts with Absorb, Acid, Poison Powder, Stun Spore.

9: Poison Powder, 12: Stun Spore, 15: Sleep Powder, 20: Mega Drain, 26: Acid, 35: Giga Drain, 42: Petal Dance, 54: Solar Beam.

Evolution remains Moon Stone for Jigglypuff, 22 for Zubat, 40 for Golbat, 21 for Oddish and Leaf Stone for Gloom. Wigglytuff/Vileplume retain full post-stone progression. Crobat's provisional imported metadata is synchronized with its actual headers, permissions and new learnset.

## Wake-Up Slap

- New move ID 221, Normal, 60 power, 100 accuracy, 15 PP. Existing IDs, including Moonlight 220, stay unchanged.
- Uses physical damage and the existing Double Slap animation, but strikes once.
- Base power doubles to 120 when the target is asleep. The target wakes after taking direct HP damage, including a knockout.
- Misses, Ghost immunity, invulnerability and zero damage do not wake the target. A Substitute absorbs the attack and prevents waking, including a hit that breaks it. The sleep-based power bonus still applies while the sleeping target is shielded.
- Only sleep bits are cleared; party status/HP are synchronized for the player and trainer enemies. No new saved state is needed.
- Jigglypuff learns it at 41 and Wigglytuff at 45. It is not a TM. Stockpile boosts Defense and Special, not slap damage; the target must be asleep, not the user.

## Family roles and compatibility

**Jigglypuff family:** singing, inflation and physical slaps. Stockpile raises Defense/Special and supports optional special coverage; Rest supplies recovery with sleep as its cost. Add Facade TM52. Keep Body Slam, Reflect, Rest, Substitute and existing Ice/Electric/Fire Blast permissions. Remove Water Gun, Bubblebeam, Submission, Seismic Toss and Wigglytuff's Hyper Beam. Toxic remains excluded. No Moonlight or Minimize is added.

**Zubat family:** fast poison/draining disruption. Earlier Wing Attack and Poison Fang, Screech and Shadow Leech replace provisional Roost/Venoshock/Aerial Ace level-up additions. Keep Toxic, Venoshock, Aerial Ace, Double Team and Rest; Crobat gains the relevant missing extra-machine permissions. Add Leech Life TM61 to all three. Remove Roost, Mega Drain, Twister and Whirlwind permissions, Golbat's Hyper Beam, and Crobat's provisional Double-Edge/Substitute. No Super Fang is added.

Haze remains Shin's existing reset: it clears both Pokémon's stat stages and major status, including poison applied by Poison Fang/Toxic and Defense drops from Screech. Shadow Leech normally heals half actual damage; confusion and poison do not enable its full-heal bonus, which requires an asleep or cursed target. No changes to those mechanics are made here.

**Oddish family:** slow powder users with damage-based recovery. Mega Drain leads into Giga Drain; Petal Dance is the stronger immediate option. Remove Synthesis and Ingrain from all three level-up lists, preserving their distinction from Venusaur and Tangela. Keep Toxic, Venoshock, Mega Drain, Solar Beam and existing Reflect/Rest permissions. Remove Take Down, Double-Edge and Vileplume's Hyper Beam where previously available. No broad elemental coverage, Spore or Growth is added. Major statuses remain mutually exclusive.

TM52 remains in Vermilion for 6,000; TM61 in Fuchsia for 4,000. No new machines, stock or price changes are needed. Other species' permissions and Mew's all-TM rule remain unchanged.

## Updating and validation

Download artifact `pokemon-183-species-bps` from the successful Actions run and apply the matching BPS to an original, unmodified English Red/Blue ROM. Existing 183-species saves retain their layout; earlier 151/172/176-species saves require a fresh start. Previously learned moves are not erased automatically. A normal level-up recalculates existing party stats.

The tuning registry now contains 48 reviewed species: 47 originals (all through Vileplume, Farfetch'd and Onix) plus Crobat. Exact starts, stats, learnsets, party-generated moves/PP, historical variants and all TM permissions are checked. Wake-Up Slap has 48 power/wake/pipeline checks per ROM covering both actors, misses, Ghost immunity, Fly, Substitute survival/breaking, knockout, PP, party status and SRAM preservation with PP-Up bits. All 221 names/animations and Metronome choices, Moonlight and the existing full species/sprite/encounter/save/move/crit/freeze suites also run. Both BPS patches are applied to verified originals and compared byte for byte with the builds.
