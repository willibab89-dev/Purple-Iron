# Nature system repository audit

Branch: `unique-species`, starting from `2504e8e`. This audit concerns the cumulative Shin-based game, not upstream vanilla Red/Blue.

## Storage and generation

Party records are 44 bytes, boxed/daycare records 33 bytes, and active battle records 29 bytes. Party, enemy party, loaded-mon, active-box and daycare buffers occupy fixed WRAM regions. Four SRAM banks hold saves and twelve boxes; the current checksums cover the existing data blocks. The recent ability prototype stores F9–FD ability-slot tags in the stored catch-rate byte. Growing every record would shift RAM, save blocks and link serialization.

The planned versioned record format uses the catch-rate byte for nature ID 0–195, the three spare high bits of stored type 1 for ability slot 1–5, and the three high bits of stored type 2 as a format marker. Actual type IDs remain in their low five bits. Existing saves cannot contain that marker with a valid old type, allowing per-Pokémon lazy migration without guessing that an old catch rate is a nature. Old ability tags must be translated before the byte is reused. Battle types remain ordinary unencoded types and capture odds continue using the species-header catch rate.

Generation converges on `engine/add_mon.asm` for party gifts/starters/trainer records; wild generation is in `LoadEnemyMonData`. Full-party captures and gifts use `SendNewMonToBox`. Box/daycare transfers copy the 33-byte common prefix. In-game trades create a fresh received Pokémon through AddPartyMon and then change its OT/name. Evolution copies loaded data back and invokes SetPartyMonTypes, which must preserve new high-bit metadata.

A separate existing use of stored catch rate, `Mon1BCDScore`, must read the species header instead, preserving the original scoring purpose after that byte becomes nature data.

## Calculations and UI

`CalcStat` and `CalcStats` in home.asm provide the underlying five stats. They are shared by generation, evolution, experience, vitamins, boxed stats and withdrawals. Battle stage rebuilding already uses unmodified battle stats; apply natures once in base calculation and never again in stage rebuilding. Enemy Shin stat experience/hard-mode logic and the nature-adjusted critical-hit base-stat path need separate checks. HP changes must preserve damage and must never revive fainted Pokémon.

`CalcHitChance` combines accuracy and evasion stages using integer math. Nature accuracy/evasion should modify its wide result together before the final cap. CriticalHitTest retains base-Speed thresholds, current high-crit/Focus multipliers and guaranteed-crit exceptions; only its final ordinary threshold receives the Crit nature multiplier. Nature Speed must not be fed into that base-Speed calculation.

Transform copies battle stats, moves, DVs and stat stages. Individual nature identity remains permanent; copied stat values must retain their source's nature adjustment without being multiplied again. Accuracy/Crit/Evasion remain the user's own intrinsic traits unless the design is revised later.

Party actions currently offer STATS/SWITCH/ABILITY/CANCEL with up to four field moves. One additional two-row action cannot fit the maximum layout unchanged; the nature UI must use a compact layout or a status-screen alternative, preserving all field moves and actions. Ability inspection already preserves the overworld screen backup.

## Link compatibility and hardware

Current link serialization transfers raw party structures. Unmodified ROMs cannot interpret encoded nature/slot metadata. Unsupported link interactions must be blocked with an explanation rather than silently exchanged; NPC trades remain supported. No claim of unmodified-ROM interoperability will be made.

ROM size is 1 MiB, with appended feature banks available. Existing WRAM ends at DF01, ability scratch uses DF02–DF1B, and the stack begins at DF22 with its top unchanged at DFFF. Nature scratch allocation must remain explicit, bounded and tested with stack guards. Species/sprite assets are untouched.

## Staged implementation

1. Generate 56 ordered simple natures and 140 complex natures from 17 distinct size-eight cyclic orbits plus one size-four orbit. Orbit ordering is SHA-256 over a documented fixed seed and canonical masks. Verify all counts, uniqueness, disjointness and per-attribute balance.
2. Add packed versioned storage, unbiased generation, migration, creation/transfer hooks and safe link handling. Preserve ability slots.
3. Apply the five underlying stat ratios with one rounding rule, HP bounds and no repeated multiplication.
4. Integrate combined Accuracy/Evasion ratios and final ordinary Crit thresholds, preserving move exceptions and Shin fixes.
5. Add dynamic nameless nature descriptions and a usable party action.
6. Exercise persistence, stat/probability math, transformations, menu bounds, both ROMs and all cumulative regressions, then package round-trip-verified BPS patches.
