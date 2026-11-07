# Clefairy and Vulpix family redesigns, plus Moonlight

This cumulative Red/Blue patch implements both approved families and the new Moonlight move. Species remain 183; move records increase from 219 to 220, including Struggle 165. All previous sprites, added species, move mechanics, type changes and individual reviews remain included.

## Stats and typing

All four keep their existing stats. Clefairy/Clefable remain Normal, Vulpix remains Fire, and Ninetales retains its implemented Fire/Ghost typing.

| Pokémon | HP | Attack | Defense | Speed | Special |
| --- | ---: | ---: | ---: | ---: | ---: |
| Clefairy | 70 | 45 | 48 | 35 | 60 |
| Clefable | 95 | 70 | 73 | 60 | 85 |
| Vulpix | 38 | 41 | 40 | 65 | 65 |
| Ninetales | 73 | 76 | 75 | 100 | 100 |

## Starting and level-up moves

### Clefairy

Starts with Pound, Growl.

9: Sing, 14: Double Slap, 20: Metronome, 26: Minimize, 30: Swift, 35: Psych Up, 40: Moonlight, 48: Light Screen.

### Clefable

Starts with Pound, Growl, Sing, Double Slap.

9: Sing, 14: Double Slap, 20: Metronome, 26: Minimize, 32: Swift, 38: Psych Up, 44: Moonlight, 50: Light Screen.

### Vulpix

Starts with Ember, Tail Whip.

9: Quick Attack, 14: Roar, 19: Will O Wisp, 24: Confuse Ray, 28: Incinerate, 34: Flamethrower, 40: Cauterize, 46: Fire Spin.

### Ninetales

Starts with Ember, Tail Whip, Quick Attack, Roar.

9: Quick Attack, 14: Roar, 19: Will O Wisp, 24: Confuse Ray, 28: Incinerate, 32: Wailing Cry, 36: Flamethrower, 42: Cauterize, 48: Fire Spin.

Clefairy still evolves with a Moon Stone and Vulpix with a Fire Stone. Both evolved forms have full level-up lists, allowing early stone evolution without locking out their planned progression.

## Moonlight

- New move ID 220, appended after Shadow Leech without renumbering existing moves.
- Normal-type status move, 10 PP, restores floor(half maximum HP), capped at maximum HP. Fails at full HP and does not clear major status.
- Reuses the existing healing effect and Recover animation. No weather behavior or new field-healing action is added.
- Clefairy learns it at 40; Clefable at 44. It is not a TM.

Names, animation mapping, PP and Metronome bounds include the new ID. The move/name end labels now mark the actual ends of the appended tables. `data/additional_moves.json` records the new move separately from historical patch fixtures.

## Family roles and machine changes

**Clefairy family:** bulky magical tricksters with Sing, Metronome, Minimize, Swift, Psych Up, Moonlight and Light Screen. Keep existing Psychic, Ice, Thunderbolt/Thunder, Fire Blast and Solar Beam compatibility. Retain Metronome, Mimic, Reflect, Rest, Thunder Wave and Substitute. Remove Water Gun, Bubblebeam, Submission and Seismic Toss, and Clefable's Hyper Beam. Toxic remains excluded. Minimize plus Moonlight is intentionally retained for playtesting. Psych Up replaces all six user stages, including evasion and negative stages; it can therefore erase Minimize boosts.

**Vulpix family:** supernatural disruption and cursed fire. Earlier Will-O-Wisp supports Incinerate; Ninetales gains Wailing Cry at 32. Keep Confuse Ray, Roar, Flamethrower, Cauterize and Fire Spin. Remove Flame Charge from level-up lists. Retain Will-O-Wisp/Curse as TMs, plus existing Mimic, Substitute, Double Team, Reflect, Rest, Fire Blast and Dig compatibility. Remove Skull Bash from both and Hyper Beam from Ninetales. Toxic remains excluded.

Wailing Cry uses physical Ghost damage and lowers Special after an eligible hit; Normal targets are immune. Cauterize restores one-quarter HP and clears major status, not confusion or Curse. Existing burn/Curse/Fire Spin stacking remains unchanged. These combinations require playtesting, not additional battle-mechanic changes in this patch.

No TM items, compatibility for unrelated species, shop stock or prices change. Existing unique variants and their headers remain untouched.

## Updating and verification

Download artifact `pokemon-183-species-bps` from the successful Actions run and apply the matching BPS to an original, unmodified English Red/Blue ROM. Existing 183-species saves retain their layout. Earlier 151/172/176-species saves need a fresh start. Previously learned moves are not erased automatically.

`data/species_tuning.json` now contains 40 reviewed originals: every species through Ninetales, plus Farfetch'd and Onix. Historical fixtures allow only the approved header/list/TM differences. The extended integration tests cover all 220 move names and mapped animations, and every Metronome candidate. Moonlight has separate tests for both actors, 64 healing/status/full-HP cases per ROM, the existing 255/511 HP boundaries, animation mapping, generated PP and SRAM preservation with PP-Up bits. The usual party-generation/learnset/TM tests and all prior species/sprite/encounter/save/move/crit/freeze regressions also run in both versions. Both BPS patches are applied to verified originals and compared byte for byte with the builds.
