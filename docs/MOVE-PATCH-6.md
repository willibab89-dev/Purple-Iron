# Move overhaul — patch 6

Cumulative Red/Blue patches include all prior custom front sprites, 21 unique species, encounters, crit/freeze changes and move patches 1–5. This patch completes five existing moves and adds four new moves, bringing the move table to 216 records. Existing move IDs are preserved; Razor Wind's ID now displays TWISTER, including TM02.

## Updating

Download `pokemon-move-patch-6-bps` from the successful GitHub Actions run. Apply the matching BPS to an unmodified original Red/Blue ROM, not a previously patched ROM. Existing 172-species saves remain compatible. Back up saves and heal at a Pokemon Center to refresh PP. Original 151-species saves remain incompatible. Link battles require identical revisions. No permanent save fields or new battle RAM fields are added in this patch.

Existing Pokemon retain their moves. Use Shin's relearner in the Saffron house below Copycat's house for eligible missed levels, subject to its normal requirements. Variant species inherit their originals' learnsets. Original entries and evolutions remain intact.

## Existing moves

| Move | Stats | Behavior |
| --- | --- | --- |
| Rage | Normal, 40 power, 95 accuracy, 20 PP | Commits for 2–3 turns including the first attack. Attack rises one stage whenever actual opposing attack damage reaches the user's HP during Rage. |
| Fury Swipes | Normal, 35 power per strike, 80 accuracy, 15 PP | One accuracy check, then exactly two strikes. An accuracy miss grants the user one Attack stage. |
| Bide | Normal, existing accuracy/PP | Stores incoming damage for two turns including activation, then releases twice the stored damage on the next available action. |
| Skull Bash | Normal, existing power/accuracy/PP | Raises Defense two stages on its charging turn, then attacks next turn. |
| Twister (formerly Razor Wind) | Dragon, 40 power, 100 accuracy, 15 PP | No charge. 30% flinch chance. Hits a target using Fly and doubles power against it. Uses Gust's animation. |

Rage's timer counts attempted turns, including misses and turns blocked by status. Once started, subsequent forced Rage attacks reload their normal accuracy and do not spend additional player PP. The effect remains active through the opponent's remaining action on its last turn, then expires before next round's command selection. Each HP-damaging multihit strike can trigger a boost; Substitute-only damage, misses and zero damage cannot. Existing stage caps and normal switch/Haze resets apply. An initial action blocked before Rage starts does not start its lock.

Bide's collection clock advances at round boundaries. Sleep, freeze or an item can delay release, but cannot extend damage collection beyond its two storage turns. Existing confusion/full-paralysis cancellation rules remain. Fury Swipes does not grant its miss bonus for type immunity or an invulnerable target. Skull Bash grants its boost once per charge; interruption retains the boost, and its existing PP timing remains.

Twister cannot hit underground Dig users. Flinching during a charge clears the charging/invulnerability state. Multihit moves continue after a strike breaks Substitute; a hit that breaks Substitute cannot flinch its owner.

## New moves

Gen 1 type-based physical/special categories remain. Critical hits retain the project's existing rules, including ignoring stages and screens.

| ID | Move | Type | Power | Accuracy | PP | Effect | Animation |
| ---: | --- | --- | ---: | ---: | ---: | --- | --- |
| 213 | Ambush | Bug | 50 | 100 | 10 | +30 power and +1 priority when target HP is strictly below half; otherwise normal priority. | Quick Attack |
| 214 | Aqua Jet | Water | 40 | 100 | 20 | +1 priority. | Quick Attack |
| 215 | Thunderclap | Electric | 50 | 100 | 5 | +1 priority; 30% flinch chance. | Thundershock |
| 216 | Icicle Spear | Ice | 15 per hit | 90 | 15 | Hits 2–5 times; high-crit modifier applies separately per strike. Does not thaw frozen targets. | Pin Missile |

Ambush checks target HP for priority when order is decided and for power when damage is calculated. Icicle Spear uses the existing 2–5-hit distribution and one initial accuracy check. Its high-crit modifier is the previously implemented ×2 rate, with Focus Energy/Dire Hit stacking as before.

## Added level-up entries

| Species | Level | Move |
| --- | ---: | --- |
| Articuno | 42 | Icicle Spear |
| Beedrill | 38 | Ambush |
| Blastoise | 30 | Aqua Jet |
| Cloyster | 36 | Icicle Spear |
| Dewgong | 38 | Icicle Spear |
| Electabuzz | 40 | Thunderclap |
| Goldeen | 22 | Aqua Jet |
| Horsea | 22 | Aqua Jet |
| Jolteon | 40 | Thunderclap |
| Kabuto | 26 | Aqua Jet |
| Kabutops | 30 | Aqua Jet |
| Lapras | 39 | Icicle Spear |
| Paras | 28 | Ambush |
| Parasect | 32 | Ambush |
| Pikachu | 38 | Thunderclap |
| Pinsir | 38 | Ambush |
| Poliwag | 22 | Aqua Jet |
| Poliwhirl | 27 | Aqua Jet |
| Poliwrath | 30 | Aqua Jet |
| Raichu | 42 | Thunderclap |
| Scyther | 38 | Ambush |
| Seadra | 26 | Aqua Jet |
| Seaking | 26 | Aqua Jet |
| Seel | 34 | Icicle Spear |
| Shellder | 32 | Icicle Spear |
| Squirtle | 23 | Aqua Jet |
| Venomoth | 32 | Ambush |
| Venonat | 28 | Ambush |
| Wartortle | 26 | Aqua Jet |
| Zapdos | 45 | Thunderclap |

## Verification and remaining work

Both Red and Blue build. Automated PyBoy checks cover all 216 records, both actors, priority/HP boundaries, Rage timing and PP, delayed Bide release, Skull Bash interruption, Fury Swipes miss gates, multihit/Substitute interactions, airborne Twister, learning/relearning, high-ID save/PP round-trips, and the previous species/crit/freeze/move suites. Battle fixtures stub presentation and control randomness where needed; this is not a full manual playthrough. Packaging verifies that each BPS reproduces the built ROM byte for byte.

Remaining: five existing moves (Fire Spin, Roar, Transform, Whirlwind, Wrap) and three new moves (Ingrain, Curse, Shadow Leech). Their custom trapping/residual, forced-switch and automatic transformation behavior is reserved for subsequent patches.
