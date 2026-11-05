# Move overhaul — patch 2

Cumulative Red/Blue BPS patches: includes all previous front sprites, 21 new species and their encounters, crit/freeze changes, and move patch 1. This patch completes 22 additional existing move redesigns. It adds no new move IDs or learnsets.

Apply to the verified unmodified original Red/Blue ROM, not a previously patched ROM. Existing 172-species saves retain their layout. Heal at a Pokemon Center after updating to refresh stored PP. Saves from the old 151-species layout remain incompatible. Link battles require the same ROM revision.

## Implemented moves

Power/accuracy/PP are the final values, including retained fields. “—” power indicates a status move; listed status accuracy is ignored for self-targeting moves. Chance effects occur after the move hits. Existing Shin accuracy rules are retained, including its fix for the old 1-in-256 miss. Approximately 30% is 77/256; 50% is 128/256; guaranteed effects do not make an extra probability roll.

| Move | Power | Accuracy | PP | Effect |
| --- | ---: | ---: | ---: | --- |
| Comet Punch | 100 | 50 | 15 | One hit; guaranteed confusion on an eligible target. |
| Guillotine | 120 | 40 | 5 | Ordinary Normal damage; target Special −2. No OHKO restrictions. |
| Bind | 60 | 90 | 15 | Target Speed −1 (100%); no trapping. |
| Slam | 60 | 90 | 20 | Target Defense −1 (100%). |
| Sand Attack | 15 | 95 | 15 | Ground damage and target accuracy −1. |
| Fury Attack | 80 | 95 | 15 | One hit; user Attack −1 after a successful hit, including Substitute or a knockout. |
| Horn Drill | 120 | 40 | 5 | Ordinary Normal damage; target Defense −2. No OHKO restrictions. |
| Bubblebeam | 60 | 100 | 20 | Target Speed −1 (100%). |
| Growth | — | 100 | 40 | Grass; user Special +1 / Defense +1. |
| Petal Dance | 90 | 100 | 10 | Target evasion −1; no locking or confusion. |
| String Shot | 15 | 95 | 40 | Deals damage and lowers target Speed by one. |
| Fissure | 100 | 40 | 5 | Ordinary Ground damage; target Attack −2. No OHKO restrictions. |
| Meditate | — | 100 | 15 | User Attack +1 / Speed +1. |
| Withdraw | — | 100 | 40 | User Defense +1 / accuracy +1. |
| Constrict | 25 | 100 | 15 | Grass; target Speed −1 (100%). |
| Amnesia | — | 100 | 10 | Clear negative stages, preserve positive stages, then Special +1. |
| Kinesis | — | 80 | 15 | Target accuracy −1 / Attack −1. |
| Bubble | 25 | 100 | 30 | About 30% target Speed −1. |
| Dizzy Punch | 70 | 100 | 10 | About 30% confusion. |
| Flash | 50 | 100 | 20 | Electric damage; 50% target accuracy −1. Field function retained. |
| Splash | — | 100 | 40 | Target Attack −1 / accuracy −1. |
| Sharpen | — | 100 | 30 | User Attack +1 / accuracy +1. |

## Shared rules

- One accuracy check for a damaging move or targeted compound status move. Misses and type immunity prevent secondary effects.
- Target stat changes respect Mist and Substitute. A hit that breaks Substitute still cannot lower/confuse its owner. Mist blocks stat drops, not the move's damage or confusion. A target knockout prevents target changes.
- Fury Attack's self-drop still happens after a knockout or a hit on Substitute, including when Substitute breaks. It does not happen on a miss/immunity.
- Each stat clamps independently between −6 and +6. A capped first stat does not prevent the second from changing. Amnesia clears negative stages before raising Special.
- Stats are rebuilt from their unmodified values, with badge boosts and burn/paralysis penalties applied once. Animations are reused; secondary changes do not replay the whole attack animation.
- Fissure now respects Flying immunity; Horn Drill and Guillotine respect Ghost immunity. These moves use normal damage and crit rules; the old OHKO Speed/level rules no longer apply.
- Move IDs, names, field functions and learning compatibility remain stable. The moved legacy effect table uses a 16-bit index, making room for later effect additions. Compound status AI checks whether either stat can change and avoids wholly capped/protected uses; other existing AI behavior remains.

## Accepted rules for later patches — not implemented here

Punishment will use 40 + 20 per positive target stage, capped at 160. Missing accuracy/PP defaults, the later-generation Flail formula, Curse exclusion rules, simplified Wrap ticks, residual timing, Cauterize's ability to waste a turn, Roost's simple recovery, and Ditto/Happy Ditto entry transformation recommendations are recorded in MOVE-PATCH-2-PLAN.md. Frost Breath will trigger its guaranteed crit from a negative Speed stage, not paralysis alone.

All 54 new moves remain pending the move-ID/animation foundation and learnsets. Automatic transformation, custom Wrap/Fire Spin/Curse/Ingrain timers, forced switching, conditional damage/crit moves, hybrid damage stats, Rage, Bide, Fury Swipes, Skull Bash and other deferred patch-1 designs remain unchanged. No new-move placeholder records are inserted.

## Validation

Both versions are tested with PyBoy: all 165 move records against the approved cumulative changes; all 22 replacements loaded and their handlers exercised on both actors; actual move damage/application/effect routing for all 22 (presentation, PP setup and crit/random variation stubbed); chance boundaries, caps, partial success, misses, Substitute/Mist/KO gates, Substitute-breaking Fury Attack, confusion duration, Amnesia, badge/status recalculation, AI utility and legacy effect bank dispatch. The existing species, encounters, save/load, crit and freeze suites also run. BPS patches are applied to verified originals and compared byte for byte with the built ROMs. These checks do not replace a full manual playthrough.
