# Move overhaul — patch 7

Cumulative Red/Blue BPS patches include every previous front sprite, unique species, encounter, crit/freeze change and move patch. This patch completes Wrap and Fire Spin, and adds Ingrain, Curse and Shadow Leech. There are now 219 move records, including Struggle and 54 added moves. No Pokémon base stats, types or TM/HM compatibility change in this patch.

## Updating and learning

Download `pokemon-move-patch-7-bps` from the successful GitHub Actions run. Apply the matching BPS to an unmodified original Red/Blue ROM, not a previously patched ROM. Existing 172-species saves remain compatible; permanent party, box and save fields retain their addresses and sizes. Old 151-species saves remain incompatible. Back up saves and heal at a Pokémon Center to refresh PP. Link play requires identical revisions; manual link compatibility is not claimed.

Existing Pokémon retain their moves. This patch adds 26 level-up entries without replacing old entries or evolutions. Variants inherit their originals' learning additions. Shin's Saffron relearner can teach eligible missed levels, subject to its ordinary requirements. The new moves have no TM slots yet. The separate Pokémon/TM balancing review can change their distribution later.

## Moves implemented

| Move | Type | Power | Accuracy | PP | Behavior | Animation |
| --- | --- | ---: | ---: | ---: | --- | --- |
| Wrap | Normal | 25 | 90 | 15 | Initial hit plus 1–2 later cached-damage ticks; target cannot voluntarily switch while trapped. Both Pokémon can attack. | Wrap |
| Fire Spin | Fire | 35 | 85 | 15 | One attack, then 1/16 target maximum HP at the end of each round for exactly three ticks. Does not prevent switching. | Fire Spin |
| Ingrain (217) | Grass | — | — | 10 | User heals 1/16 maximum HP at the end of each round and cannot voluntarily switch. | Growth |
| Curse (218) | Ghost | — | 85 | 10 | Inflicts a volatile curse dealing 1/8 target maximum HP per round, with no healing. Normal types are immune. | Confuse Ray |
| Shadow Leech (219) | Ghost | 50 | 100 | 10 | Heals half actual damage dealt, or all actual damage if the target is asleep or cursed. | Leech Life |

Gen 1 damage categories remain type-based: Wrap and Shadow Leech are physical; Fire Spin is special. Shadow Leech is a direct attack, not an ongoing draining effect. Ordinary drain restrictions apply, including no healing from Substitute-only damage. It respects Ghost's current type chart, accuracy and invulnerability rules. Healing uses HP-capped actual damage, a minimum of one when halving a positive hit, and caps at the user's maximum HP.

## Timing, exclusions and switching

New residual effects run once after both actions, including item-use/status-blocked turns, with an end-of-round check on early fainting paths. Processing cannot repeat when a residual KO enters a faint handler. Fire Spin and Curse first tick at the end of the application round. Ingrain first heals then too. Fixed processing order is player then enemy; within a side: Wrap, Fire Spin, Curse, Ingrain. A Pokémon that reaches zero HP cannot heal itself back with Ingrain. Wrap is released immediately if either participant faints, including during residual processing.

Fractional damage/healing floors the fraction and has a minimum of one HP. Curse and Fire Spin have their own state, independent of Toxic/Leech Seed. Their damage ignores Substitute after the effect has been established. Substitute blocks the initial application of Curse, Fire Spin's persistent effect and Wrap's persistent effect, including a hit that breaks Substitute. Their initial damaging attacks still deal their normal damage to Substitute. Ingrain is self-directed and works behind the user's Substitute.

Curse fails against Normal typing, an existing curse, Leech Seed, ordinary poison or Toxic, as well as Substitute/invulnerability or a failed accuracy check. Reciprocally, Leech Seed and all poison applications fail while cursed, including Poison Fang's poisoning component; their damaging components still work. Burn, sleep, freeze and paralysis can coexist with Curse. Curse is not a major status and is not the Gen 2 move: there is no user HP sacrifice or Ghost/non-Ghost split. Cauterize does not clear Curse. Switching/fainting clears it; Haze does not clear these new residual states.

Fire Spin lasts exactly three residual ticks in addition to its single direct hit. A successful new Fire Spin can refresh its counter to three; it never creates a second concurrent Fire Spin. Its ongoing effect survives the source switching or fainting, and clears when the affected target leaves battle. Curse behaves the same way regarding its source. Ingrain lasts until the rooted user leaves/faints, not for a fixed number of turns; reapplying while already rooted fails.

Wrap makes one ordinary initial accuracy/crit/damage calculation. Roll two or three total damage events, including that initial hit. Cache the initial actual HP damage; subsequent end-of-round ticks reuse it without new accuracy, crit, type or stat calculations. There is no extra Wrap tick on the application round. The target can still choose moves, and the user can switch unless separately rooted/trapped. The target cannot voluntarily switch until the last tick completes. Either participant leaving or fainting releases it. A repeated successful Wrap deals its normal direct damage but does not refresh the active timer or cached damage. Status preventing the source acting does not cancel an established Wrap. A later-created Substitute absorbs a tick, with no spill to real HP if it breaks. Cached ticks do not feed Rage, Bide or Counter; those hooks remain for actual attacks.

Voluntary party-menu switching shows a failure message while rooted or wrapped, before consuming a turn. Enemy AI voluntary switching uses the same block. Forced replacements bypass the voluntary restriction and clear the departing Pokémon's states. Roar/Whirlwind forced switching remains pending; its eventual implementation should use this existing replacement cleanup. This patch does not add a flee/Teleport escape restriction beyond the specified switching block.

Enemy move scoring discourages impossible Curse applications and repeated Ingrain. Existing broader AI heuristics remain approximate.

## Implementation and compatibility

The new state uses 13 previously unallocated bytes at C0F3–C0FF, after the audio variables and before sprite data. The audio engine's clear routines do not touch that padding. No saved data, existing fields or stack boundaries move. Each active side has flags, a Fire Spin counter, a Wrap counter and cached Wrap damage; the remaining bytes hold transient processing state. Battle initialization clears it, and loading a replacement clears that side's effects and both Wrap links.

Move IDs 1–216 remain stable. New IDs 217–219 use the existing separate animation map. Names, PP, Metronome and learning/save routines accept the additions. The original type-based battle and critical rules remain unchanged.

## Added learning entries

| Pokémon | Level | Move |
| --- | ---: | --- |
| Bellsprout | 30 | Ingrain |
| Bulbasaur | 30 | Ingrain |
| Cubone | 28 | Curse |
| Exeggcute | 30 | Ingrain |
| Exeggutor | 38 | Ingrain |
| Gastly | 33 | Curse |
| Gastly | 34 | Shadow Leech |
| Gengar | 41 | Curse |
| Gengar | 44 | Shadow Leech |
| Gloom | 34 | Ingrain |
| Golbat | 35 | Shadow Leech |
| Haunter | 37 | Curse |
| Haunter | 40 | Shadow Leech |
| Ivysaur | 34 | Ingrain |
| Marowak | 32 | Curse |
| Oddish | 30 | Ingrain |
| Paras | 31 | Ingrain |
| Paras | 32 | Shadow Leech |
| Parasect | 35 | Ingrain |
| Parasect | 36 | Shadow Leech |
| Tangela | 30 | Ingrain |
| Venusaur | 38 | Ingrain |
| Victreebel | 38 | Ingrain |
| Vileplume | 38 | Ingrain |
| Weepinbell | 34 | Ingrain |
| Zubat | 31 | Shadow Leech |

## Validation and remaining work

Automated PyBoy tests run both actor paths on both ROMs. Checks include all 219 records; immediate and delayed residual ticks; round/faint duplicate guards; reciprocal Curse exclusions, coexisting burn/sleep/paralysis and Normal/Substitute/invulnerability gates; HP fractions including 65,535 maximum HP, minimums/caps and no revival; voluntary switch blocks, switch/faint cleanup and source-faint release; Wrap cached damage, no refresh and Substitute breaking; Shadow Leech's conditional healing, overkill cap and Substitute restriction; enemy utility scoring; audio-stop preservation of the new state; all 26 additions through generation/PP and relearner paths; high-ID/PP save round-trips. Existing full learnset/name/animation/Metronome, species, encounter, crit, freeze and move suites remain in CI. Fixtures stub text/presentation and control crit/damage randomness where appropriate; these are engine checks, not a full manual playthrough.

Each BPS is applied to the verified original ROM and compared byte for byte with the built custom ROM. Downloads include patches and guides only, not full ROMs.

**All 54 planned new moves are now present. Three existing redesigns remain: Roar, Whirlwind and automatic Transform.** The Pokémon base-stat/moveset/TM balancing pass remains a separate planned task.
