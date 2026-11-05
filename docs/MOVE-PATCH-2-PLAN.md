# Move overhaul — patch 2 plan

Design reference for patch 2, now implemented; see MOVE-PATCH-2.md for delivered scope and verification. Patch 2 builds cumulatively on patch 1 (6111404). Blank move specifications still mean no change. Unspecified fields of existing moves retain their values, except legacy effects explicitly replaced by the redesign.

## Locked design rules and defaults

- Fury Attack: one 80-power hit, 95 accuracy, 15 PP; user Attack falls one stage after a successful damaging hit, including a knockout. A miss or immunity does not lower Attack.
- Curse fails against an already cursed, Leech Seeded, poisoned or badly poisoned target, and against any target with Normal typing. It does not replace an existing condition. Recommended reciprocal rule: Leech Seed and poison applications also fail while cursed, so the non-stacking rule works in both orders. Burn, paralysis and sleep can coexist with Curse. Curse is a volatile effect, cleared by switching.
- Cauterize can be selected and used at full HP without a major status: consume PP and a turn even if nothing changes. Heal floor(max HP/4), minimum one, capped at maximum; clear sleep, poison/toxic, burn, freeze and paralysis and their relevant counters/stat penalties. Does not cure confusion, Curse, Leech Seed, trapping or stat stages. Normal inability to act still applies: it is not an item usable while asleep/frozen.
- Wrap recommendation for a later patch: make one initial accuracy check; roll 2–3 turns total including the initial hit. Cache the initial 25-power damage result for remaining ticks rather than performing new crit/accuracy/damage calculations. A later tick uses that cached damage (not flat 25 HP), respects Substitute, and cannot spill through a broken Substitute. Both actors choose moves freely. Block voluntary target switching; user switching or either actor fainting clears the effect. Give repeated Wrap no second timer or refresh while this user's Wrap is active. Document fixed later-tick damage as an intentional simplification. Decide phazing interaction when phazing is implemented; recommended forced switching clears the trap. Action prevention on later turns does not cancel an established timer.
- Residual default for later work: Fire Spin and Curse first tick at end of the application turn, then count that tick toward duration. Fire Spin has exactly three ticks; Curse lasts until switching/fainting. Separate counters from Toxic and Leech Seed. Floor fractional damage with minimum one HP. Ingrain first heals at end of the application turn, minimum one, and clears on forced switch/fainting/battle end.

## Missing accuracy and PP: chosen defaults

Only missing fields are supplied. Existing specified values are unchanged. Accuracy below is base accuracy, still subject to the usual checks, except as explicitly noted. Self-targeting moves skip accuracy checks rather than rolling against the opponent.

| Move | Accuracy | PP | Notes |
| --- | --- | --- | --- |
| Stockpile | — | 10 | Self-targeting; PP already specified |
| Synthesis | — | 10 | Self-targeting; PP already specified |
| Ingrain | — | 10 | Self-targeting |
| Lunge | 100 | 15 | Guaranteed Attack drop on hit |
| Shell Break | 100 | 15 | Guaranteed Defense drop on hit |
| Ambush | 100 | 10 | Conditional priority/power |
| Astonish | 100 | 20 | 30% flinch |
| Curse | 85 | 10 | Checks immunity, Substitute and conflicting conditions |
| Wailing Cry | 100 | 15 | Guaranteed Special drop on hit |
| Shadow Leech | 100 | 10 | Conditional increased healing |
| Punishment | 100 | 10 | 40 + 20 per positive target stage, capped at 160 |
| Psych Up | — | 10 | Targeted copying skips accuracy/evasion; PP already specified |
| Drain Punch | 100 | 10 | 50% drain |
| Bulk Up | — | 10 | Self-targeting |
| Rock Tomb | 95 | 15 | Guaranteed Speed drop on hit |
| Rock Polish | — | 15 | Self-targeting |
| Cauterize | — | 10 | Self-targeting; PP already specified |
| Charge | — | 10 | Self-targeting |
| Ice Armor | — | 10 | Self-targeting; PP already specified |
| Aerial Ace | — | 15 | Bypasses accuracy/evasion; respects invulnerability/immunity |
| Roost | — | 10 | Self-targeting; simple half-HP recovery, no temporary type removal recommended |
| Dragon Dance | — | 10 | Self-targeting; PP already specified |

Flail retains the specified 100 accuracy and 15 PP. Snipe Shot's specified 100 accuracy is retained in its table, but its cannot-miss effect overrides the roll; it should still respect invulnerability/immunity.

## Flail: later-generation behavior

Use the HP-scaled power calculation implemented for current generations in Pokemon Showdown:

`r = max(1, floor(48 * current_HP / maximum_HP))`

| r | Power |
| --- | --- |
| 1 | 200 |
| 2–4 | 150 |
| 5–9 | 100 |
| 10–16 | 80 |
| 17–32 | 40 |
| 33–48 | 20 |

Read HP at the moment the move executes, not at selection time. Use a wide intermediate for 48 * HP. Normal-type physical damage; normal STAB, screens and critical-hit rules. Implement when new move IDs are supported, not patch 2.

Reference checked: https://github.com/smogon/pokemon-showdown/blob/master/data/moves.ts (Flail basePowerCallback).

## Recommended automatic Transform behavior (later patch)

- Apply to ordinary Ditto and Happy Ditto; keep each one's own current/max HP and major status. Do not add an HP boost.
- Once per entry, after both active combatants and sprites are initialized but before the first action/move selection for that entry. Works for player and enemy. No turn or PP cost; does not clear sleep/freeze.
- Do not retry merely because the opponent switches, Substitute disappears, or an initial attempt fails. Switching Ditto out and back in permits a new attempt.
- Fail against a target with Substitute, an invulnerable Fly/Dig target, an already transformed target, or either untransformed Ditto species. Thus Ditto versus Ditto does not create an order-dependent copy loop. Never re-transform an already transformed user automatically.
- Copy battle typing, moves, non-HP stats and stat stages using a verified shared routine; copied moves get five PP. Keep Shin's existing copied-Transform-to-Struggle rule unless intentionally redesigned later.
- Ordinary use of the Transform move still spends a turn. Keep entry-trigger restrictions separate from the manual move unless deliberately making a shared fix.
- Preserve original identity/DVs and permanent party data, clear transformation on leaving battle/field, and test catching transformed wild Ditto. Shin's routine currently sets TRANSFORMED before testing that flag around original enemy DV preservation; inspect/fix this ordering before adding entry triggers.

## Patch 2 scope: shared effects on existing moves

No new move IDs, learnsets, auto-transform, residual timers, priority overhaul, or new animation mappings in this patch.

1. Create space for battle helpers in a suitable ROM bank. Relocate a coherent routine/table block if needed rather than append into the nearly full battle bank. Preserve calling conventions and registers. Add explicit reusable effect metadata for target/self, stat changes, chance and timing; remove dependence on numeric effect-ID ranges for new effects.
2. Add damage-plus-stat-change handlers. Resolve ordinary accuracy/type/immunity and damage exactly once; then apply the specified secondary effect without a second accuracy test. Route guaranteed changes separately from the old ~33% routine.
3. Implement the following complete move replacements, including their specified numbers:
   - Slam: target Defense -1, 100%.
   - Bind and Constrict: target Speed -1, 100%; Bind loses trapping.
   - Bubblebeam: target Speed -1, 100%.
   - String Shot: 15-power damage plus its existing Speed reduction.
   - Sand Attack: Ground-type 15-power damage plus accuracy -1.
   - Flash: Electric 50-power damage plus 50% accuracy -1; retain its field function.
   - Petal Dance: 90 power, 100 accuracy, 10 PP; target evasion -1 on hit. No lock or confusion.
   - Fissure/Horn Drill/Guillotine: ordinary damage plus target Attack/Defense/Special -2 respectively; remove all OHKO-specific level/Speed/accuracy handling.
   - Fury Attack: single hit and Attack -1 as defined above; remove multihit behavior.
4. Add configurable chance and guaranteed confusion handlers: Bubble 30% Speed -1, Dizzy Punch 30% confusion, and Comet Punch guaranteed confusion on its one successful hit.
5. Add reusable multiple-stat changes: Growth (+Special/+Defense, Grass type), Kinesis (-accuracy/-Attack), Meditate (+Attack/+Speed), Withdraw (+Defense/+accuracy), Splash (-Attack/-accuracy), and Sharpen (+Attack/+accuracy). Each change is one stage. Clamp independently; one capped stat does not block the other. One accuracy check for targeted moves.
6. Implement Amnesia: +1 Special and restore only negative stages to neutral, preserving existing positive stages. Clear negative stages first, then grant Special +1. Recalculate stats with existing major-status penalties applied exactly once.

This covers 22 existing moves, including all three former OHKO moves. Keep every other move at patch 1 behavior. Animation IDs stay the same; use existing stat-change messages without playing the whole move animation twice.

## Potential issues and required validation

- **Classification traps:** current dispatch classifies effects using lists and numeric ranges. Assigning a pure stat-down effect to a damaging move skips damage. New helpers must work through both player and enemy execution paths, and Metronome/Mimic/Transform must retain the move's behavior.
- **Tight ROM banks:** the battle bank has almost no contiguous space. Check both builds after relocation, linker/bank boundaries, far calls and stack/register preservation. The effect-pointer index currently doubles an 8-bit value; do not exceed ID 128 without widening it. Reserve the broader dispatcher work for the move-ID foundation if not needed here.
- **Success ordering:** target stat drops/confusion stop when the target faints; Fury Attack's self-drop still runs after a knockout. Immunity/miss prevents secondary changes. Hitting a Substitute does not lower/confuse its owner, including when the hit breaks it; capture Substitute state before applying damage. Self-drops still occur for a damaging hit on Substitute. Respect Mist for target stat reductions.
- **Damage and accuracy:** test 100% secondaries independently from the original move-accuracy roll; they are guaranteed only after a successful eligible hit. Existing nominal 100-accuracy semantics remain in place unless separately redesigned. Ground Sand Attack can now fail against Flying types because it deals Ground damage.
- **OHKO removal:** Fissure becomes a normal Ground attack (Flying immunity); Horn Drill/Guillotine become Normal damage (Ghost immunity). They can crit normally; no original OHKO speed/level gate should survive.
- **Caps and stages:** test -6/+6, partial multi-stat success, all-stats-at-cap, Mist/Substitute, and Amnesia with negative and positive Special stages. Preserve paralysis/burn effects during recalculation; do not accidentally cure status or multiply penalties twice.
- **AI:** adapt scoring for the new effect metadata and major semantic changes. Do not treat damaging Flash/String Shot as pure status moves, Petal Dance as a lock, or former OHKO moves as OHKOs. AI enhancements beyond these affected categories can wait.
- **Compatibility:** preserve all move IDs and existing 172-species save layout. Heal at a Pokemon Center after updating to refresh PP. Link battles require identical ROM revisions; do not promise compatibility with older builds.
- **Regression:** run move-record/name and unmodified-move checks, targeted emulator tests for all new handlers on both actors (miss/hit/immunity/Substitute/KO/caps/chance boundaries), and all existing species, encounter, crit and freeze suites. Update the patch-1 manifest test to validate patch 2's intentional delta rather than falsely assert patch 1 values forever. Verify both BPS round trips. Manual battle checks remain necessary in addition to routine-level tests.

## Subsequent work

Patch 3: separate move IDs from animation IDs; update Metronome, names, PP and move bounds, then add simple new moves with explicit animations and learnsets. Do not insert placeholder moves or allow Metronome to reach incomplete records. Append IDs, retain Struggle's existing ID explicitly, and exclude it from ordinary random move selection. Revisit the effect dispatcher before exceeding its safe index range.

Later focused patches: conditional damage/crit and hybrid stats; Rage/Bide/Fury Swipes/charge-turn changes; residuals/trapping; forced switches and automatic transformation. Timers and transformation should have separate testing milestones.
