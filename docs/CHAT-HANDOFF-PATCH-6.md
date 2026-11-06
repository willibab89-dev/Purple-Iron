# Purple-Iron: planning handoff after move patch 6

**Update:** the move overhaul is now complete through patch 8. Read [MOVE-PATCH-7.md](MOVE-PATCH-7.md) for Ingrain, Curse, Shadow Leech, Wrap, Fire Spin and 26 learning additions, and [MOVE-PATCH-8.md](MOVE-PATCH-8.md) for Roar, Flying-type Whirlwind and Ditto/Happy Ditto automatic entry transformation. There are now 219 move records. The tables below remain a historical patch-6 snapshot; the two linked guides supersede its unfinished-move list and Transform behavior. Pokémon base stats remain unchanged.

Snapshot: commit `56e3b5d`, branch `unique-species`, repository `willibab89-dev/Purple-Iron`, 6 November 2026. Based on Shin Pokémon Red/Blue. This describes the actual implemented game through patch 6, rather than every idea discussed earlier.

## Prompt for the new chat

I am redesigning a PvE-focused Gen 1 Pokémon game based on Shin Pokémon Red/Blue. Help me review every Pokémon's stats, typing, moves, learn levels, evolution and niche, one family at a time. Use this document as the current baseline. Proposals are planning only until I explicitly approve implementation.

Prioritize distinct roles and synergies over giving every Pokémon the same strongest moves. Early-game moves do not need to remain competitive forever. Keep the limited Gen 1 animations in mind: reuse existing animations. If I list a move without any changes, it stays exactly as currently implemented. Do not substitute modern move stats or mechanics from memory. Distinguish implemented mechanics, unfinished approved designs, and fresh proposals. Ask about material decisions and track my approved changes as we go.

Use five base stats: HP, Attack, Defense, Speed and a single Special stat. No physical/special split by move: damage category follows type. Do not assume modern abilities, held items, weather or Fairy/Dark/Steel types have been added. The 21 variants are separate species and can receive their own future balancing.

For each family, show its current data first, identify a useful niche and weaknesses, propose modest changes, explain synergies with the custom move pool, and record the final approved design separately from suggestions. Account for evolution timing, stone evolutions, TM/HM access and trainer difficulty, not just final-level strength.

## Current build and scope

- 151 original Pokémon with replaced front sprites, plus 21 separate variant species: 172 total. Original back sprites are retained; variants reuse their sources' back sprites.
- 216 move records: the original 165 slots (including Struggle) and 51 added moves. Three planned new moves remain unimplemented.
- Base-stat overhaul has not been performed by these move patches. Actual current values are included below. Ditto and Happy Ditto both still have 48/48/48/48/48; neither has automatic entry transformation yet.
- Original learning entries and evolution destinations have been preserved, with 444 added level-up entries across patches 3–6 (95 + 154 + 165 + 30). Current complete level-up lists are included below. Existing Pokémon retain their known moves when updating.
- Original TM/HM move assignments and compatibility remain; renamed/retyped moves retain their old slots and field functions. TM02 is now Twister. The new moves currently enter through level-up/relearning, not new TM slots.
- The diploma requires the original 150 non-Mew species. Mew and all 21 variants are optional and cannot substitute for missing originals.
- Some variants are deliberately trainer-exclusive, so obtaining every one of all 172 species through normal encounters is not currently promised.
- Both Red and Blue build and pass automated species, save, encounter, move and battle-mechanics checks. No full manual playthrough is claimed.

## Battle rules that matter for balancing

Physical types: Normal, Fighting, Flying, Poison, Ground, Rock, Bug and Ghost. Special types: Fire, Water, Grass, Electric, Ice, Psychic and Dragon. Special boosts affect both special offense and special defense.

Normal critical chance is `floor(base Speed / 2) / 256`. High-crit moves multiply the threshold by 2, rather than the old ×8. Focus Energy and Dire Hit share a boost counter: successive successful uses give ×2, ×3, then ×4. It stacks multiplicatively with a high-crit move, up to a combined ×8 threshold; actual probability caps at 255/256. Switching, replacement, new battles and Haze reset the focus boost. Critical damage otherwise follows Shin's Gen 1 rules: it ignores stages, screens and badge/status stat modifiers. Consequently, a guaranteed crit can discard the user's setup boosts as well as the opponent's defenses.

The high-crit set is Karate Chop, Razor Leaf, Crabhammer, Slash, Double Slap, Dragon Rage, X-Scissor, Stone Edge and Icicle Spear. Conditional guaranteed-crit moves are Shock Wave (paralysis), Poison Tail (poison) and Frost Breath (negative Speed stage; paralysis alone does not qualify).

Freeze has an exact 20% thaw chance immediately before each attempted move, on both sides. A thaw permits the selected move that turn unless another blocker applies. Switching does not itself cure freeze. Using an item/switching does not grant an action-time thaw roll. Ice Shard and Icicle Spear do not thaw their targets.

Stages run from −6 to +6. Multi-stat changes clamp independently. Eligible guaranteed target drops follow a successful hit without a second accuracy roll, respect Mist/Substitute and do not affect a fainted target. A strike breaking Substitute still cannot drop/confuse/flinch its owner. Self-effects such as Fury Attack's Attack drop and Flame Charge's Speed boost can occur after a knockout or Substitute hit. Multihit attacks continue after breaking Substitute.

Approximate secondary odds use byte thresholds (about 30% = 77/256, about 33% = 85/256, about 20% = 51/256). Self-targeting status moves do not need an accuracy roll. Nominal 100 accuracy is distinct from an explicit accuracy/evasion bypass.

No OHKO moves remain among Fissure, Horn Drill and Guillotine: these now deal ordinary high damage and inflict two-stage target debuffs. Normal immunities and critical rules apply.

## Implemented changes by patch

| Patch | Delivered |
| --- | --- |
| Before move patches | Custom fronts, 21 species, encounters/trainers, crit balancing, 20% natural thaw. |
| 1 | 56 existing move changes: numeric/type changes and reused effects. |
| 2 | 22 existing move redesigns: multi-stat changes, damaging debuffs, former OHKOs and more. |
| 3 | 10 new moves; safe new move IDs/names/animations/Metronome; 95 learning additions. |
| 4 | 16 new moves; five existing conditional/hybrid redesigns; 154 learning additions. |
| 5 | 21 new moves; Counter, Egg Bomb, Psywave and Tri Attack; 165 learning additions. |
| 6 | Four new moves; Rage, Bide, Fury Swipes, Skull Bash and Twister; 30 learning additions. |

## Unfinished approved designs — NOT implemented

These still use their prior behavior or are absent. Do not build a current moveset around the proposed behavior until implemented.

- Wrap: planned 25 power / 90 accuracy / 15 PP, 2–3 turns of damage and switch prevention while both sides can attack normally; user switching releases it. Exact residual implementation belongs to the next patch.
- Fire Spin: planned 35 power / 85 accuracy / 15 PP; one attack, then 1/16 max HP residual for three turns, no switch prevention, switching clears it.
- Roar and Whirlwind: planned forced switches in trainer battles; Whirlwind planned Flying type.
- Transform: automatic entry transformation is planned; it is not active. Proposed Ditto/Happy Ditto exceptions and HP handling must be checked against the approved plan before coding. No Ditto HP buff should be assumed.
- Ingrain, Curse and Shadow Leech: not present in the move pool. Curse is intended as a custom 1/8 max HP residual, no healing; Normal immune; fails with conflicting Leech Seed/poison/Toxic. It is not the Gen 2 move. Final integration rules for the three residual moves remain work for the next patch.

## Important custom interactions

- Chomp replaces Clamp: Water 50/90/10, heals half damage, no trap. Bind is a single attack with a Speed drop; Constrict is Grass damage with a Speed drop.
- Petal Dance no longer locks/confuses; Growth raises Special and Defense; Amnesia clears negative stages then grants only +1 Special.
- Crabhammer is Normal and physical, not Water. Kingler therefore uses Attack but loses Water STAB on it.
- Stone Press uses user Defense against target Defense. Defense stages/badge apply on ordinary hits, Attack boosts/burn do not. A crit uses unmodified Defense.
- Psyshock uses Special against target Defense; Reflect protects, Light Screen does not.
- Drill Peck and Pierce ignore positive target Defense stages; Waterfall ignores positive target Special stages. Negative stages/screens still apply on non-crits.
- Counter returns twice the last actual physical HP damage taken this turn, not the whole multihit sum. It does not record special, residual, recoil, confusion or Substitute-only damage. Retains Fighting/Ghost immunity.
- Egg Bomb and Brick Break ignore the applicable screen on an eligible hit, then remove both target screens. Misses/Substitute hits do not remove them.
- Cauterize heals a quarter max HP and cures major status, not confusion/Leech Seed. Can be wasted at full HP. It cannot act through sleep/freeze.
- Tri Attack chooses one burn/freeze/paralysis after its ~20% gate, without rerolling a blocked ailment. New status handlers use the ailment's natural type immunity; old move-specific quirks remain on old moves.
- Poison Fang can upgrade ordinary poison to Toxic; does not restart an existing Toxic counter.
- Punishment is Ghost and caps at 160 power: 40 + 20 per positive stage across all six stages. Negative stages do not subtract.
- Rage locks 2–3 turns, with Attack boosts when hit; not Dragon Dance. Bide stores for exactly two global turns, then releases when able. Skull Bash grants +2 Defense on charge.
- Thunderclap and Aqua Jet have +1 priority. Ice Shard has no priority. Ambush gets +1 priority and +30 power only against a target strictly below half HP.
- Flail uses the later-generation HP-ratio power curve (20–200). Roost is simple half-HP recovery with no temporary type removal. Synthesis has no weather scaling.

## All 51 added moves

Values are final patch-6 values. Power is per strike for multihit attacks. “—” means unused, not missing design information.

| Move | Type | Power | Accuracy | PP | Effect |
| --- | --- | ---: | ---: | ---: | --- |
| Giga Drain | Grass | 80 | 100 | 10 | Heals 50% of damage dealt. |
| Synthesis | Grass | — | — | 10 | Restores half maximum HP; no weather scaling. |
| Megahorn | Bug | 100 | 85 | 10 | Ordinary damage. |
| X-Scissor | Bug | 65 | 95 | 15 | High crit (existing ×2 bonus). |
| Astonish | Ghost | 30 | 100 | 20 | About 30% flinch; useful only before the target acts. |
| Drain Punch | Fighting | 60 | 100 | 10 | Heals 50% of damage dealt. |
| Stone Edge | Rock | 75 | 85 | 15 | High crit (existing ×2 bonus). |
| Rock Polish | Rock | — | — | 15 | User Speed +2. |
| Ice Armor | Ice | — | — | 10 | User Defense +2. |
| Roost | Flying | — | — | 10 | Restores half maximum HP; no temporary type removal. |
| Facade | Normal | 60 | 100 | 20 | Double power with a major status; ignores burn's Attack penalty. |
| Flail | Normal | 20–200 | 100 | 15 | 20–200 power using the agreed later-generation HP curve. |
| Brine | Water | 50 | 100 | 10 | Double power when target HP is at or below half. |
| Incinerate | Fire | 50 | 100 | 10 | Double power against a burned target. |
| Venoshock | Poison | 50 | 100 | 10 | Double power against a poisoned/badly poisoned target. |
| Pollution | Poison | 40 | 95 | 10 | Double power against either Water typing. |
| Punishment | Ghost | 40–160 | 100 | 10 | 40 + 20 per positive target stage, capped at 160; counts all six stages. |
| Shock Wave | Electric | 40 | 100 | 10 | Guaranteed critical hit against a paralyzed target. |
| Poison Tail | Poison | 40 | 100 | 25 | Guaranteed critical hit against a poisoned/badly poisoned target. |
| Frost Breath | Ice | 60 | 100 | 15 | Guaranteed critical hit against a target with a negative Speed stage; paralysis alone does not qualify. |
| Ice Shard | Ice | 50 | 100 | 20 | Double power against a frozen target; does not thaw it. No priority added. |
| Pierce | Fighting | 70 | 100 | 15 | Ignores positive target Defense stages. |
| Stone Press | Rock | 50 | 100 | 10 | User Defense versus target Defense, instead of user Attack. |
| Psyshock | Psychic | 60 | 100 | 15 | User Special versus target Defense. |
| Snipe Shot | Water | 70 | 100 | 10 | Bypasses accuracy/evasion; respects immunity and Fly/Dig invulnerability. |
| Aerial Ace | Flying | 60 | 100 | 15 | Bypasses accuracy/evasion; respects immunity and Fly/Dig invulnerability. |
| Tongue Lash | Normal | 60 | 100 | 15 | Target Special −1 on hit. |
| Stockpile | Normal | — | — | 10 | User Defense +1 / Special +1; ordinary stage caps, no separate stockpile counter. |
| Lunge | Bug | 40 | 100 | 15 | Target Attack −1 on hit. |
| Shell Break | Bug | 40 | 100 | 15 | Target Defense −1 on hit. |
| Wailing Cry | Ghost | 40 | 100 | 15 | Target Special −1 on hit; calculated Ghost damage, not fixed Night Shade damage. |
| Psych Up | Psychic | — | — | 10 | Copy all six target stages, replacing own positive/negative stages. |
| Mind Break | Psychic | 50 | 100 | 10 | After damage, reset positive target Special stages to neutral. |
| Bulk Up | Fighting | — | — | 10 | User Attack +1 / Defense +1. |
| Brick Break | Fighting | 70 | 100 | 15 | Ignore applicable screen for an eligible hit and remove both target screens on hit. |
| Rock Tomb | Rock | 50 | 95 | 15 | Target Speed −1 on hit. |
| Will-O-Wisp | Fire | — | 85 | 15 | Inflict burn. |
| Flame Charge | Fire | 40 | 100 | 20 | User Speed +1 after a successful hit, including KO/Substitute. |
| Cauterize | Fire | — | — | 10 | Heal one quarter maximum HP and clear own major status; can be wasted at full HP. |
| Scald | Water | 40 | 100 | 15 | About 30% burn chance. |
| Charge | Electric | — | — | 10 | User Special +1 / accuracy +1; no extra next-attack bonus. |
| Icy Wind | Ice | 40 | 100 | 15 | Target Speed −1 on hit. |
| Flash Freeze | Ice | — | 40 | 5 | Inflict freeze. |
| Gale Wind | Flying | 50 | 100 | 15 | After damage, reset positive target evasion stages to neutral. |
| Coil | Poison | — | — | 10 | User Attack +1 / Defense +1 / accuracy +1. |
| Poison Fang | Poison | 50 | 100 | 15 | About 20% badly poison; upgrades normal poison. |
| Dragon Dance | Dragon | — | — | 10 | User Attack +1 / Speed +1. |
| Ambush | Bug | 50 | 100 | 10 | 50 power normally; +30 power and +1 priority against targets strictly below half HP. |
| Aqua Jet | Water | 40 | 100 | 20 | +1 priority. |
| Thunderclap | Electric | 50 | 100 | 5 | +1 priority; 30% flinch chance. |
| Icicle Spear | Ice | 15 | 90 | 15 | Hits 2–5 times; high-crit modifier applies separately per strike. Does not thaw frozen targets. |

## Current complete move table

This is the actual source table, including unchanged Shin moves. Status/fixed/variable moves can have zero or placeholder table power; consult the behavior rather than interpreting that field as ordinary damage. Raw effect names identify inherited Shin routines; they are not a claim that a modern-generation implementation is used.

| ID | Move | Type | Table power | Accuracy | PP | Overhaul status | Behavior/routine |
| ---: | --- | --- | ---: | ---: | ---: | --- | --- |
| 1 | Pound | Normal | 40 | 100 | 35 | Retained | Shin effect: no additional effect. |
| 2 | Karate Chop | Fighting | 50 | 100 | 25 | Changed | Shin effect: no additional effect. |
| 3 | Doubleslap | Normal | 20 | 95 | 15 | Changed | Exactly two hits after one accuracy check; high-crit ×2 on each strike. |
| 4 | Comet Punch | Normal | 100 | 50 | 15 | Changed | One hit; guaranteed confusion on an eligible target. |
| 5 | Mega Punch | Fighting | 80 | 85 | 20 | Changed | Shin effect: no additional effect. |
| 6 | Pay Day | Normal | 40 | 100 | 20 | Retained | Shin effect: pay day effect. |
| 7 | Fire Punch | Fire | 75 | 100 | 15 | Retained | Shin effect: burn side effect1. |
| 8 | Ice Punch | Ice | 75 | 100 | 15 | Retained | Shin effect: freeze side effect. |
| 9 | Thunderpunch | Electric | 75 | 100 | 15 | Retained | Shin effect: paralyze side effect1. |
| 10 | Scratch | Normal | 40 | 100 | 35 | Retained | Shin effect: no additional effect. |
| 11 | Vicegrip | Bug | 75 | 100 | 30 | Changed | Shin effect: no additional effect. |
| 12 | Guillotine | Normal | 120 | 40 | 5 | Changed | Ordinary Normal damage; target Special −2. No OHKO restrictions. |
| 13 | Twister | Dragon | 40 | 100 | 15 | Changed | Renamed Twister; no charge; ~30% flinch; hits Fly users and doubles power against them, never Dig. |
| 14 | Swords Dance | Normal | 0 | 100 | 30 | Retained | Shin effect: attack up2 effect. |
| 15 | Cut | Bug | 50 | 95 | 30 | Changed | Bug damage; HM field function retained. |
| 16 | Gust | Flying | 40 | 100 | 35 | Changed | Shin effect: no additional effect. |
| 17 | Wing Attack | Flying | 65 | 100 | 25 | Changed | Shin effect: no additional effect. |
| 18 | Whirlwind | Normal | 0 | 85 | 20 | Retained | Shin effect: switch and teleport effect. |
| 19 | Fly | Flying | 70 | 100 | 15 | Changed | Shin effect: fly effect. |
| 20 | Bind | Normal | 60 | 90 | 15 | Changed | Target Speed −1 (100%); no trapping. |
| 21 | Slam | Normal | 60 | 90 | 20 | Changed | Target Defense −1 (100%). |
| 22 | Vine Whip | Grass | 35 | 100 | 10 | Changed | About 30% flinch, useful before the target acts. |
| 23 | Stomp | Normal | 65 | 100 | 20 | Changed | Double power against confusion; retains its ~30% flinch effect. |
| 24 | Double Kick | Fighting | 30 | 100 | 30 | Retained | Shin effect: attack twice effect. |
| 25 | Mega Kick | Fighting | 120 | 75 | 5 | Changed | Shin effect: no additional effect. |
| 26 | Flying Punch | Fighting | 100 | 90 | 10 | Changed | Renamed Flying Punch; retains Fighting typing and Jump Kick animation/crash mechanics. |
| 27 | Rolling Kick | Fighting | 60 | 85 | 15 | Retained | Shin effect: flinch side effect2. |
| 28 | Sand-Attack | Ground | 15 | 95 | 15 | Changed | Shin effect: attack and stat effect. |
| 29 | Headbutt | Normal | 70 | 100 | 15 | Retained | Shin effect: flinch side effect2. |
| 30 | Horn Attack | Normal | 65 | 100 | 25 | Changed | About 33% chance of target Defense −1. |
| 31 | Fury Attack | Normal | 80 | 95 | 15 | Changed | One hit; user Attack −1 after a successful hit, including Substitute or a knockout. |
| 32 | Horn Drill | Normal | 120 | 40 | 5 | Changed | Ordinary Normal damage; target Defense −2. No OHKO restrictions. |
| 33 | Tackle | Normal | 35 | 95 | 35 | Retained | Shin effect: no additional effect. |
| 34 | Body Slam | Normal | 80 | 95 | 15 | Changed | Shin effect: paralyze side effect2. |
| 35 | Wrap | Normal | 15 | 85 | 20 | Retained | Shin effect: trapping effect. |
| 36 | Take Down | Normal | 60 | 85 | 20 | Changed | Double power against targets strictly below half HP; retains quarter-damage recoil. |
| 37 | Thrash | Normal | 90 | 100 | 20 | Retained | Shin effect: thrash petal dance effect. |
| 38 | Double-Edge | Normal | 100 | 100 | 10 | Changed | Shin effect: recoil effect. |
| 39 | Tail Whip | Normal | 0 | 100 | 30 | Retained | Shin effect: defense down1 effect. |
| 40 | Poison Sting | Poison | 25 | 100 | 35 | Changed | Shin effect: poison side effect1. |
| 41 | Twineedle | Bug | 35 | 100 | 20 | Changed | Shin effect: twineedle effect. |
| 42 | Pin Missile | Bug | 25 | 85 | 20 | Changed | Shin effect: two to five attacks effect. |
| 43 | Leer | Normal | 0 | 100 | 30 | Retained | Shin effect: defense down1 effect. |
| 44 | Bite | Normal | 60 | 100 | 25 | Retained | Shin effect: flinch side effect1. |
| 45 | Growl | Normal | 0 | 100 | 40 | Retained | Shin effect: attack down1 effect. |
| 46 | Roar | Normal | 0 | 100 | 20 | Retained | Shin effect: switch and teleport effect. |
| 47 | Sing | Normal | 0 | 60 | 15 | Changed | Shin effect: sleep effect. |
| 48 | Supersonic | Normal | 0 | 85 | 20 | Changed | Shin effect: confusion effect. |
| 49 | Sonicboom | Normal | 1 | 90 | 20 | Retained | Shin effect: special damage effect. |
| 50 | Disable | Normal | 0 | 55 | 20 | Retained | Shin effect: disable effect. |
| 51 | Acid | Poison | 55 | 100 | 30 | Changed | Shin effect: defense down side effect. |
| 52 | Ember | Fire | 40 | 100 | 25 | Retained | Shin effect: burn side effect1. |
| 53 | Flamethrower | Fire | 80 | 100 | 15 | Changed | Shin effect: burn side effect1. |
| 54 | Mist | Ice | 0 | 100 | 15 | Changed | Shin effect: mist effect. |
| 55 | Water Gun | Water | 40 | 100 | 25 | Retained | Shin effect: no additional effect. |
| 56 | Hydro Pump | Water | 100 | 85 | 5 | Changed | Shin effect: no additional effect. |
| 57 | Surf | Water | 80 | 100 | 15 | Changed | Shin effect: no additional effect. |
| 58 | Ice Beam | Ice | 80 | 100 | 10 | Changed | Shin effect: freeze side effect. |
| 59 | Blizzard | Ice | 100 | 90 | 5 | Changed | Shin effect: freeze side effect. |
| 60 | Psybeam | Psychic | 65 | 100 | 20 | Retained | Shin effect: confusion side effect. |
| 61 | Bubblebeam | Water | 60 | 100 | 20 | Changed | Target Speed −1 (100%). |
| 62 | Aurora Beam | Ice | 65 | 100 | 20 | Retained | Shin effect: attack down side effect. |
| 63 | Hyper Beam | Normal | 150 | 90 | 5 | Retained | Shin effect: hyper beam effect. |
| 64 | Peck | Flying | 35 | 100 | 35 | Retained | Shin effect: no additional effect. |
| 65 | Drill Peck | Flying | 80 | 100 | 20 | Changed | Ignores positive target Defense stages. |
| 66 | Submission | Fighting | 100 | 95 | 10 | Changed | Shin effect: recoil effect. |
| 67 | Low Kick | Fighting | 50 | 90 | 20 | Retained | Shin effect: flinch side effect2. |
| 68 | Counter | Fighting | 1 | 100 | 20 | Changed | Fixed retaliation for twice the last physical HP damage received this turn. See exact rules below. |
| 69 | Seismic Toss | Fighting | 1 | 100 | 20 | Retained | Shin effect: special damage effect. |
| 70 | Strength | Normal | 80 | 100 | 15 | Retained | Shin effect: no additional effect. |
| 71 | Absorb | Grass | 30 | 100 | 20 | Changed | Shin effect: drain hp effect. |
| 72 | Mega Drain | Grass | 60 | 100 | 10 | Changed | Shin effect: drain hp effect. |
| 73 | Leech Seed | Grass | 0 | 100 | 15 | Changed | Shin effect: leech seed effect. |
| 74 | Growth | Grass | 0 | 100 | 40 | Changed | Grass; user Special +1 and Defense +1. |
| 75 | Razor Leaf | Grass | 55 | 100 | 25 | Changed | Shin effect: no additional effect. |
| 76 | Solarbeam | Grass | 120 | 100 | 10 | Retained | Shin effect: charge effect. |
| 77 | Poisonpowder | Poison | 0 | 85 | 30 | Changed | Shin effect: poison effect. |
| 78 | Stun Spore | Grass | 0 | 85 | 20 | Changed | Shin effect: paralyze effect. |
| 79 | Sleep Powder | Grass | 0 | 75 | 15 | Retained | Shin effect: sleep effect. |
| 80 | Petal Dance | Grass | 90 | 100 | 10 | Changed | Target evasion −1; no locking or confusion. |
| 81 | String Shot | Bug | 15 | 95 | 40 | Changed | Deals damage and lowers target Speed by one. |
| 82 | Dragon Rage | Dragon | 60 | 100 | 10 | Changed | Calculated Dragon damage, not fixed 40; high-crit ×2. |
| 83 | Fire Spin | Fire | 15 | 70 | 15 | Retained | Shin effect: trapping effect. |
| 84 | Thundershock | Electric | 40 | 100 | 30 | Retained | Shin effect: paralyze side effect1. |
| 85 | Thunderbolt | Electric | 80 | 100 | 15 | Changed | Shin effect: paralyze side effect1. |
| 86 | Thunder Wave | Electric | 0 | 100 | 20 | Retained | Shin effect: paralyze effect. |
| 87 | Thunder | Electric | 100 | 70 | 10 | Changed | Bypasses accuracy/evasion against a target with any major status; retains its existing paralysis chance. Respects immunity/invulnerability. |
| 88 | Rock Throw | Rock | 50 | 100 | 15 | Changed | Shin effect: no additional effect. |
| 89 | Earthquake | Ground | 90 | 100 | 10 | Changed | Shin effect: no additional effect. |
| 90 | Fissure | Ground | 100 | 40 | 5 | Changed | Ordinary Ground damage; target Attack −2. No OHKO restrictions. |
| 91 | Dig | Ground | 70 | 100 | 10 | Changed | Shin effect: charge effect. |
| 92 | Toxic | Poison | 0 | 85 | 10 | Retained | Shin effect: poison effect. |
| 93 | Confusion | Psychic | 50 | 100 | 25 | Retained | Shin effect: confusion side effect. |
| 94 | Psychic | Psychic | 80 | 100 | 15 | Changed | Shin effect: special down side effect. |
| 95 | Hypnosis | Psychic | 0 | 70 | 20 | Changed | Shin effect: sleep effect. |
| 96 | Meditate | Psychic | 0 | 100 | 15 | Changed | User Attack +1 / Speed +1. |
| 97 | Agility | Psychic | 0 | 100 | 30 | Retained | Shin effect: speed up2 effect. |
| 98 | Quick Attack | Normal | 40 | 100 | 30 | Retained | Shin effect: no additional effect. |
| 99 | Rage | Normal | 40 | 95 | 20 | Changed | Locks for 2–3 turns including activation; +1 Attack for each opposing HP-damaging hit while active; no Speed boost. |
| 100 | Teleport | Psychic | 0 | 100 | 20 | Retained | Shin effect: switch and teleport effect. |
| 101 | Night Shade | Ghost | 1 | 100 | 15 | Retained | Shin effect: special damage effect. |
| 102 | Mimic | Normal | 0 | 100 | 10 | Retained | Shin effect: mimic effect. |
| 103 | Screech | Normal | 0 | 85 | 40 | Retained | Shin effect: defense down2 effect. |
| 104 | Double Team | Normal | 0 | 100 | 15 | Retained | Shin effect: evasion up1 effect. |
| 105 | Recover | Normal | 0 | 100 | 20 | Retained | Shin effect: heal effect. |
| 106 | Harden | Normal | 0 | 100 | 30 | Retained | Shin effect: defense up1 effect. |
| 107 | Minimize | Normal | 0 | 100 | 20 | Retained | Shin effect: evasion up1 effect. |
| 108 | Smokescreen | Normal | 0 | 100 | 20 | Retained | Shin effect: accuracy down1 effect. |
| 109 | Confuse Ray | Ghost | 0 | 95 | 10 | Changed | Shin effect: confusion effect. |
| 110 | Withdraw | Water | 0 | 100 | 40 | Changed | User Defense +1 / accuracy +1. |
| 111 | Defense Curl | Normal | 0 | 100 | 40 | Retained | Shin effect: defense up1 effect. |
| 112 | Barrier | Psychic | 0 | 100 | 30 | Retained | Shin effect: defense up2 effect. |
| 113 | Light Screen | Psychic | 0 | 100 | 30 | Retained | Shin effect: light screen effect. |
| 114 | Haze | Ice | 0 | 100 | 10 | Changed | Shin effect: haze effect. |
| 115 | Reflect | Psychic | 0 | 100 | 20 | Retained | Shin effect: reflect effect. |
| 116 | Focus Energy | Normal | 0 | 100 | 30 | Retained | Shin effect: focus energy effect. |
| 117 | Bide | Bird | 0 | 100 | 10 | Changed | Store damage for two global turns including activation; release twice stored damage on next available action; delayed release cannot collect extra turns. |
| 118 | Metronome | Bird | 0 | 100 | 10 | Retained | Shin effect: metronome effect. |
| 119 | Mirror Move | Flying | 0 | 100 | 20 | Retained | Shin effect: mirror move effect. |
| 120 | Selfdestruct | Normal | 130 | 100 | 5 | Retained | Shin effect: explode effect. |
| 121 | Egg Bomb | Normal | 100 | 75 | 10 | Changed | An eligible hit ignores its applicable protective screen and removes both target screens. |
| 122 | Lick | Ghost | 40 | 100 | 30 | Changed | Shin effect: paralyze side effect2. |
| 123 | Smog | Poison | 40 | 95 | 20 | Changed | Shin effect: poison side effect2. |
| 124 | Sludge | Poison | 75 | 100 | 20 | Changed | Shin effect: poison side effect2. |
| 125 | Bone Club | Ground | 65 | 85 | 20 | Retained | Shin effect: flinch side effect1. |
| 126 | Fire Blast | Fire | 100 | 90 | 5 | Changed | Shin effect: burn side effect2. |
| 127 | Waterfall | Water | 70 | 100 | 15 | Changed | Ignores positive target Special stages. |
| 128 | Chomp | Water | 50 | 90 | 10 | Changed | Renamed Chomp; heal 50% of damage dealt; no trapping; established drain/Substitute rules. |
| 129 | Swift | Normal | 60 | 100 | 20 | Retained | Shin effect: swift effect. |
| 130 | Skull Bash | Normal | 100 | 100 | 15 | Changed | User Defense +2 during its charging turn; attacks next turn; boost remains if interrupted. |
| 131 | Spike Cannon | Rock | 20 | 95 | 20 | Changed | Shin effect: two to five attacks effect. |
| 132 | Constrict | Grass | 25 | 100 | 15 | Changed | Grass; target Speed −1 (100%). |
| 133 | Amnesia | Psychic | 0 | 100 | 10 | Changed | Clear negative stages, preserve positive stages, then Special +1. |
| 134 | Kinesis | Psychic | 0 | 80 | 15 | Changed | Target accuracy −1 / Attack −1. |
| 135 | Softboiled | Normal | 0 | 100 | 10 | Retained | Shin effect: heal effect. |
| 136 | Hi Jump Kick | Fighting | 110 | 85 | 10 | Changed | Shin effect: jump kick effect. |
| 137 | Glare | Normal | 0 | 75 | 30 | Retained | Shin effect: paralyze effect. |
| 138 | Dream Eater | Psychic | 100 | 100 | 15 | Retained | Shin effect: dream eater effect. |
| 139 | Poison Gas | Poison | 0 | 100 | 20 | Changed | Shin effect: poison effect. |
| 140 | Barrage | Grass | 20 | 90 | 20 | Changed | Shin effect: two to five attacks effect. |
| 141 | Leech Life | Bug | 40 | 100 | 15 | Changed | Shin effect: drain hp effect. |
| 142 | Lovely Kiss | Normal | 0 | 75 | 10 | Retained | Shin effect: sleep effect. |
| 143 | Sky Attack | Flying | 140 | 90 | 5 | Retained | Shin effect: charge effect. |
| 144 | Transform | Normal | 0 | 100 | 10 | Retained | Shin effect: transform effect. |
| 145 | Bubble | Water | 25 | 100 | 30 | Changed | About 30% target Speed −1. |
| 146 | Dizzy Punch | Normal | 70 | 100 | 10 | Changed | About 30% confusion. |
| 147 | Spore | Grass | 0 | 95 | 10 | Changed | Shin effect: sleep effect. |
| 148 | Flash | Electric | 50 | 100 | 20 | Changed | Electric damage; 50% target accuracy −1. Field function retained. |
| 149 | Psywave | Psychic | 1 | 100 | 15 | Changed | Requested accuracy change. Retains Shin's positive random damage formula, with a safe level-one minimum range. |
| 150 | Splash | Normal | 0 | 100 | 40 | Changed | Target Attack −1 / accuracy −1. |
| 151 | Acid Armor | Poison | 0 | 100 | 15 | Changed | Shin effect: defense up2 effect. |
| 152 | Crabhammer | Normal | 90 | 90 | 10 | Changed | Normal physical damage; high-crit ×2; no STAB for pure Water Kingler. |
| 153 | Explosion | Normal | 170 | 100 | 5 | Retained | Shin effect: explode effect. |
| 154 | Fury Swipes | Normal | 35 | 80 | 15 | Changed | One accuracy check; exactly two 35-power strikes if successful; +1 user Attack on an accuracy miss, not immunity/invulnerability. |
| 155 | Bonemerang | Ground | 50 | 90 | 10 | Retained | Shin effect: attack twice effect. |
| 156 | Rest | Psychic | 0 | 100 | 10 | Retained | Shin effect: heal effect. |
| 157 | Rock Slide | Rock | 65 | 90 | 10 | Changed | About 30% flinch. |
| 158 | Hyper Fang | Normal | 80 | 90 | 15 | Retained | Shin effect: flinch side effect1. |
| 159 | Sharpen | Normal | 0 | 100 | 30 | Changed | User Attack +1 / accuracy +1. |
| 160 | Conversion | Normal | 0 | 100 | 30 | Retained | Shin effect: conversion effect. |
| 161 | Tri Attack | Normal | 80 | 100 | 10 | Changed | About 20% chance of one burn, freeze or paralysis. |
| 162 | Super Fang | Normal | 1 | 90 | 10 | Retained | Shin effect: super fang effect. |
| 163 | Slash | Normal | 70 | 100 | 20 | Retained | Shin effect: no additional effect. |
| 164 | Substitute | Normal | 0 | 100 | 10 | Retained | Shin effect: substitute effect. |
| 165 | Struggle | Bird | 50 | 100 | 10 | Retained | Shin effect: recoil effect. |
| 166 | Giga Drain | Grass | 80 | 100 | 10 | Added | Heals 50% of damage dealt. |
| 167 | Synthesis | Grass | 0 | 100 | 10 | Added | Restores half maximum HP; no weather scaling. |
| 168 | Megahorn | Bug | 100 | 85 | 10 | Added | Ordinary damage. |
| 169 | X-Scissor | Bug | 65 | 95 | 15 | Added | High crit (existing ×2 bonus). |
| 170 | Astonish | Ghost | 30 | 100 | 20 | Added | About 30% flinch; useful only before the target acts. |
| 171 | Drain Punch | Fighting | 60 | 100 | 10 | Added | Heals 50% of damage dealt. |
| 172 | Stone Edge | Rock | 75 | 85 | 15 | Added | High crit (existing ×2 bonus). |
| 173 | Rock Polish | Rock | 0 | 100 | 15 | Added | User Speed +2. |
| 174 | Ice Armor | Ice | 0 | 100 | 10 | Added | User Defense +2. |
| 175 | Roost | Flying | 0 | 100 | 10 | Added | Restores half maximum HP; no temporary type removal. |
| 176 | Facade | Normal | 60 | 100 | 20 | Added | Double power with a major status; ignores burn's Attack penalty. |
| 177 | Flail | Normal | 1 | 100 | 15 | Added | 20–200 power using the agreed later-generation HP curve. |
| 178 | Brine | Water | 50 | 100 | 10 | Added | Double power when target HP is at or below half. |
| 179 | Incinerate | Fire | 50 | 100 | 10 | Added | Double power against a burned target. |
| 180 | Venoshock | Poison | 50 | 100 | 10 | Added | Double power against a poisoned/badly poisoned target. |
| 181 | Pollution | Poison | 40 | 95 | 10 | Added | Double power against either Water typing. |
| 182 | Punishment | Ghost | 40 | 100 | 10 | Added | 40 + 20 per positive target stage, capped at 160; counts all six stages. |
| 183 | Shock Wave | Electric | 40 | 100 | 10 | Added | Guaranteed critical hit against a paralyzed target. |
| 184 | Poison Tail | Poison | 40 | 100 | 25 | Added | Guaranteed critical hit against a poisoned/badly poisoned target. |
| 185 | Frost Breath | Ice | 60 | 100 | 15 | Added | Guaranteed critical hit against a target with a negative Speed stage; paralysis alone does not qualify. |
| 186 | Ice Shard | Ice | 50 | 100 | 20 | Added | Double power against a frozen target; does not thaw it. No priority added. |
| 187 | Pierce | Fighting | 70 | 100 | 15 | Added | Ignores positive target Defense stages. |
| 188 | Stone Press | Rock | 50 | 100 | 10 | Added | User Defense versus target Defense, instead of user Attack. |
| 189 | Psyshock | Psychic | 60 | 100 | 15 | Added | User Special versus target Defense. |
| 190 | Snipe Shot | Water | 70 | 100 | 10 | Added | Bypasses accuracy/evasion; respects immunity and Fly/Dig invulnerability. |
| 191 | Aerial Ace | Flying | 60 | 100 | 15 | Added | Bypasses accuracy/evasion; respects immunity and Fly/Dig invulnerability. |
| 192 | Tongue Lash | Normal | 60 | 100 | 15 | Added | Target Special −1 on hit. |
| 193 | Stockpile | Normal | 0 | 100 | 10 | Added | User Defense +1 / Special +1; ordinary stage caps, no separate stockpile counter. |
| 194 | Lunge | Bug | 40 | 100 | 15 | Added | Target Attack −1 on hit. |
| 195 | Shell Break | Bug | 40 | 100 | 15 | Added | Target Defense −1 on hit. |
| 196 | Wailing Cry | Ghost | 40 | 100 | 15 | Added | Target Special −1 on hit; calculated Ghost damage, not fixed Night Shade damage. |
| 197 | Psych Up | Psychic | 0 | 100 | 10 | Added | Copy all six target stages, replacing own positive/negative stages. |
| 198 | Mind Break | Psychic | 50 | 100 | 10 | Added | After damage, reset positive target Special stages to neutral. |
| 199 | Bulk Up | Fighting | 0 | 100 | 10 | Added | User Attack +1 / Defense +1. |
| 200 | Brick Break | Fighting | 70 | 100 | 15 | Added | Ignore applicable screen for an eligible hit and remove both target screens on hit. |
| 201 | Rock Tomb | Rock | 50 | 95 | 15 | Added | Target Speed −1 on hit. |
| 202 | Will-O-Wisp | Fire | 0 | 85 | 15 | Added | Inflict burn. |
| 203 | Flame Charge | Fire | 40 | 100 | 20 | Added | User Speed +1 after a successful hit, including KO/Substitute. |
| 204 | Cauterize | Fire | 0 | 100 | 10 | Added | Heal one quarter maximum HP and clear own major status; can be wasted at full HP. |
| 205 | Scald | Water | 40 | 100 | 15 | Added | About 30% burn chance. |
| 206 | Charge | Electric | 0 | 100 | 10 | Added | User Special +1 / accuracy +1; no extra next-attack bonus. |
| 207 | Icy Wind | Ice | 40 | 100 | 15 | Added | Target Speed −1 on hit. |
| 208 | Flash Freeze | Ice | 0 | 40 | 5 | Added | Inflict freeze. |
| 209 | Gale Wind | Flying | 50 | 100 | 15 | Added | After damage, reset positive target evasion stages to neutral. |
| 210 | Coil | Poison | 0 | 100 | 10 | Added | User Attack +1 / Defense +1 / accuracy +1. |
| 211 | Poison Fang | Poison | 50 | 100 | 15 | Added | About 20% badly poison; upgrades normal poison. |
| 212 | Dragon Dance | Dragon | 0 | 100 | 10 | Added | User Attack +1 / Speed +1. |
| 213 | Ambush | Bug | 50 | 100 | 10 | Added | 50 power normally; +30 power and +1 priority against targets strictly below half HP. |
| 214 | Aqua Jet | Water | 40 | 100 | 20 | Added | +1 priority. |
| 215 | Thunderclap | Electric | 50 | 100 | 5 | Added | +1 priority; 30% flinch chance. |
| 216 | Icicle Spear | Ice | 15 | 90 | 15 | Added | Hits 2–5 times; high-crit modifier applies separately per strike. Does not thaw frozen targets. |

## Current species base stats

Stats are HP / Attack / Defense / Speed / Special, not the six-stat modern format. BST here is the sum of those five stats. Variants currently copy the source stats, even where their type differs.

| Dex | Species/source filename | Type | HP | Atk | Def | Spe | Spc | Five-stat BST | Catch rate |
| ---: | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | bulbasaur | Grass/Poison | 45 | 49 | 49 | 45 | 65 | 253 | 45 |
| 2 | ivysaur | Grass/Poison | 60 | 62 | 63 | 60 | 80 | 325 | 45 |
| 3 | venusaur | Grass/Poison | 80 | 82 | 83 | 80 | 100 | 425 | 45 |
| 4 | charmander | Fire | 39 | 52 | 43 | 65 | 50 | 249 | 45 |
| 5 | charmeleon | Fire | 58 | 64 | 58 | 80 | 65 | 325 | 45 |
| 6 | charizard | Fire/Flying | 78 | 84 | 78 | 100 | 85 | 425 | 45 |
| 7 | squirtle | Water | 44 | 48 | 65 | 43 | 50 | 250 | 45 |
| 8 | wartortle | Water | 59 | 63 | 80 | 58 | 65 | 325 | 45 |
| 9 | blastoise | Water | 79 | 83 | 100 | 78 | 85 | 425 | 45 |
| 10 | caterpie | Bug | 45 | 30 | 35 | 45 | 20 | 175 | 255 |
| 11 | metapod | Bug | 50 | 20 | 55 | 30 | 25 | 180 | 120 |
| 12 | butterfree | Bug/Flying | 60 | 45 | 50 | 70 | 80 | 305 | 45 |
| 13 | weedle | Bug/Poison | 40 | 35 | 30 | 50 | 20 | 175 | 255 |
| 14 | kakuna | Bug/Poison | 45 | 25 | 50 | 35 | 25 | 180 | 120 |
| 15 | beedrill | Bug/Poison | 65 | 80 | 40 | 75 | 45 | 305 | 45 |
| 16 | pidgey | Normal/Flying | 40 | 45 | 40 | 56 | 35 | 216 | 255 |
| 17 | pidgeotto | Normal/Flying | 63 | 60 | 55 | 71 | 50 | 299 | 120 |
| 18 | pidgeot | Normal/Flying | 83 | 80 | 75 | 91 | 70 | 399 | 45 |
| 19 | rattata | Normal | 30 | 56 | 35 | 72 | 25 | 218 | 255 |
| 20 | raticate | Normal | 55 | 81 | 60 | 97 | 50 | 343 | 90 |
| 21 | spearow | Normal/Flying | 40 | 60 | 30 | 70 | 31 | 231 | 255 |
| 22 | fearow | Normal/Flying | 65 | 90 | 65 | 100 | 61 | 381 | 90 |
| 23 | ekans | Poison | 35 | 60 | 44 | 55 | 40 | 234 | 255 |
| 24 | arbok | Poison | 60 | 85 | 69 | 80 | 65 | 359 | 90 |
| 25 | pikachu | Electric | 35 | 55 | 30 | 90 | 50 | 260 | 163 |
| 26 | raichu | Electric | 60 | 90 | 55 | 100 | 90 | 395 | 75 |
| 27 | sandshrew | Ground | 50 | 75 | 85 | 40 | 30 | 280 | 255 |
| 28 | sandslash | Ground | 75 | 100 | 110 | 65 | 55 | 405 | 90 |
| 29 | nidoranf | Poison | 55 | 47 | 52 | 41 | 40 | 235 | 235 |
| 30 | nidorina | Poison | 70 | 62 | 67 | 56 | 55 | 310 | 120 |
| 31 | nidoqueen | Poison/Ground | 90 | 82 | 87 | 76 | 75 | 410 | 45 |
| 32 | nidoranm | Poison | 46 | 57 | 40 | 50 | 40 | 233 | 235 |
| 33 | nidorino | Poison | 61 | 72 | 57 | 65 | 55 | 310 | 120 |
| 34 | nidoking | Poison/Ground | 81 | 92 | 77 | 85 | 75 | 410 | 45 |
| 35 | clefairy | Normal | 70 | 45 | 48 | 35 | 60 | 258 | 150 |
| 36 | clefable | Normal | 95 | 70 | 73 | 60 | 85 | 383 | 25 |
| 37 | vulpix | Fire | 38 | 41 | 40 | 65 | 65 | 249 | 190 |
| 38 | ninetales | Fire | 73 | 76 | 75 | 100 | 100 | 424 | 75 |
| 39 | jigglypuff | Normal | 115 | 45 | 20 | 20 | 25 | 225 | 170 |
| 40 | wigglytuff | Normal | 140 | 70 | 45 | 45 | 50 | 350 | 50 |
| 41 | zubat | Poison/Flying | 40 | 45 | 35 | 55 | 40 | 215 | 255 |
| 42 | golbat | Poison/Flying | 75 | 80 | 70 | 90 | 75 | 390 | 90 |
| 43 | oddish | Grass/Poison | 45 | 50 | 55 | 30 | 75 | 255 | 255 |
| 44 | gloom | Grass/Poison | 60 | 65 | 70 | 40 | 85 | 320 | 120 |
| 45 | vileplume | Grass/Poison | 75 | 80 | 85 | 50 | 100 | 390 | 45 |
| 46 | paras | Bug/Grass | 35 | 70 | 55 | 25 | 55 | 240 | 190 |
| 47 | parasect | Bug/Grass | 60 | 95 | 80 | 30 | 80 | 345 | 75 |
| 48 | venonat | Bug/Poison | 60 | 55 | 50 | 45 | 40 | 250 | 190 |
| 49 | venomoth | Bug/Poison | 70 | 65 | 60 | 90 | 90 | 375 | 75 |
| 50 | diglett | Ground | 10 | 55 | 25 | 95 | 45 | 230 | 255 |
| 51 | dugtrio | Ground | 35 | 80 | 50 | 120 | 70 | 355 | 50 |
| 52 | meowth | Normal | 40 | 45 | 35 | 90 | 40 | 250 | 255 |
| 53 | persian | Normal | 65 | 70 | 60 | 115 | 65 | 375 | 90 |
| 54 | psyduck | Water | 50 | 52 | 48 | 55 | 50 | 255 | 190 |
| 55 | golduck | Water | 80 | 82 | 78 | 85 | 80 | 405 | 75 |
| 56 | mankey | Fighting | 40 | 80 | 35 | 70 | 35 | 260 | 190 |
| 57 | primeape | Fighting | 65 | 105 | 60 | 95 | 60 | 385 | 75 |
| 58 | growlithe | Fire | 55 | 70 | 45 | 60 | 50 | 280 | 190 |
| 59 | arcanine | Fire | 90 | 110 | 80 | 95 | 80 | 455 | 75 |
| 60 | poliwag | Water | 40 | 50 | 40 | 90 | 40 | 260 | 255 |
| 61 | poliwhirl | Water | 65 | 65 | 65 | 90 | 50 | 335 | 120 |
| 62 | poliwrath | Water/Fighting | 90 | 85 | 95 | 70 | 70 | 410 | 45 |
| 63 | abra | Psychic | 25 | 20 | 15 | 90 | 105 | 255 | 200 |
| 64 | kadabra | Psychic | 40 | 35 | 30 | 105 | 120 | 330 | 96 |
| 65 | alakazam | Psychic | 55 | 50 | 45 | 120 | 135 | 405 | 50 |
| 66 | machop | Fighting | 70 | 80 | 50 | 35 | 35 | 270 | 180 |
| 67 | machoke | Fighting | 80 | 100 | 70 | 45 | 50 | 345 | 90 |
| 68 | machamp | Fighting | 90 | 130 | 80 | 55 | 65 | 420 | 45 |
| 69 | bellsprout | Grass/Poison | 50 | 75 | 35 | 40 | 70 | 270 | 255 |
| 70 | weepinbell | Grass/Poison | 65 | 90 | 50 | 55 | 85 | 345 | 120 |
| 71 | victreebel | Grass/Poison | 80 | 105 | 65 | 70 | 100 | 420 | 45 |
| 72 | tentacool | Water/Poison | 40 | 40 | 35 | 70 | 100 | 285 | 190 |
| 73 | tentacruel | Water/Poison | 80 | 70 | 65 | 100 | 120 | 435 | 60 |
| 74 | geodude | Rock/Ground | 40 | 80 | 100 | 20 | 30 | 270 | 255 |
| 75 | graveler | Rock/Ground | 55 | 95 | 115 | 35 | 45 | 345 | 120 |
| 76 | golem | Rock/Ground | 80 | 110 | 130 | 45 | 55 | 420 | 45 |
| 77 | ponyta | Fire | 50 | 85 | 55 | 90 | 65 | 345 | 190 |
| 78 | rapidash | Fire | 65 | 100 | 70 | 105 | 80 | 420 | 60 |
| 79 | slowpoke | Water/Psychic | 90 | 65 | 65 | 15 | 40 | 275 | 190 |
| 80 | slowbro | Water/Psychic | 95 | 75 | 110 | 30 | 80 | 390 | 75 |
| 81 | magnemite | Electric | 25 | 35 | 70 | 45 | 95 | 270 | 190 |
| 82 | magneton | Electric | 50 | 60 | 95 | 70 | 120 | 395 | 60 |
| 83 | farfetchd | Normal/Flying | 52 | 65 | 55 | 60 | 58 | 290 | 45 |
| 84 | doduo | Normal/Flying | 35 | 85 | 45 | 75 | 35 | 275 | 190 |
| 85 | dodrio | Normal/Flying | 60 | 110 | 70 | 100 | 60 | 400 | 45 |
| 86 | seel | Water | 65 | 45 | 55 | 45 | 70 | 280 | 190 |
| 87 | dewgong | Water/Ice | 90 | 70 | 80 | 70 | 95 | 405 | 75 |
| 88 | grimer | Poison | 80 | 80 | 50 | 25 | 40 | 275 | 190 |
| 89 | muk | Poison | 105 | 105 | 75 | 50 | 65 | 400 | 75 |
| 90 | shellder | Water | 30 | 65 | 100 | 40 | 45 | 280 | 190 |
| 91 | cloyster | Water/Ice | 50 | 95 | 180 | 70 | 85 | 480 | 60 |
| 92 | gastly | Ghost/Poison | 30 | 35 | 30 | 80 | 100 | 275 | 190 |
| 93 | haunter | Ghost/Poison | 45 | 50 | 45 | 95 | 115 | 350 | 90 |
| 94 | gengar | Ghost/Poison | 60 | 65 | 60 | 110 | 130 | 425 | 45 |
| 95 | onix | Rock/Ground | 35 | 45 | 160 | 70 | 30 | 340 | 45 |
| 96 | drowzee | Psychic | 60 | 48 | 45 | 42 | 90 | 285 | 190 |
| 97 | hypno | Psychic | 85 | 73 | 70 | 67 | 115 | 410 | 75 |
| 98 | krabby | Water | 30 | 105 | 90 | 50 | 25 | 300 | 225 |
| 99 | kingler | Water | 55 | 130 | 115 | 75 | 50 | 425 | 60 |
| 100 | voltorb | Electric | 40 | 30 | 50 | 100 | 55 | 275 | 190 |
| 101 | electrode | Electric | 60 | 50 | 70 | 140 | 80 | 400 | 60 |
| 102 | exeggcute | Grass/Psychic | 60 | 40 | 80 | 40 | 60 | 280 | 90 |
| 103 | exeggutor | Grass/Psychic | 95 | 95 | 85 | 55 | 125 | 455 | 45 |
| 104 | cubone | Ground | 50 | 50 | 95 | 35 | 40 | 270 | 190 |
| 105 | marowak | Ground | 60 | 80 | 110 | 45 | 50 | 345 | 75 |
| 106 | hitmonlee | Fighting | 50 | 120 | 53 | 87 | 35 | 345 | 45 |
| 107 | hitmonchan | Fighting | 50 | 105 | 79 | 76 | 35 | 345 | 45 |
| 108 | lickitung | Normal | 90 | 55 | 75 | 30 | 60 | 310 | 45 |
| 109 | koffing | Poison | 40 | 65 | 95 | 35 | 60 | 295 | 190 |
| 110 | weezing | Poison | 65 | 90 | 120 | 60 | 85 | 420 | 60 |
| 111 | rhyhorn | Ground/Rock | 80 | 85 | 95 | 25 | 30 | 315 | 120 |
| 112 | rhydon | Ground/Rock | 105 | 130 | 120 | 40 | 45 | 440 | 60 |
| 113 | chansey | Normal | 250 | 5 | 5 | 50 | 105 | 415 | 30 |
| 114 | tangela | Grass | 65 | 55 | 115 | 60 | 100 | 395 | 45 |
| 115 | kangaskhan | Normal | 105 | 95 | 80 | 90 | 40 | 410 | 45 |
| 116 | horsea | Water | 30 | 40 | 70 | 60 | 70 | 270 | 225 |
| 117 | seadra | Water | 55 | 65 | 95 | 85 | 95 | 395 | 75 |
| 118 | goldeen | Water | 45 | 67 | 60 | 63 | 50 | 285 | 225 |
| 119 | seaking | Water | 80 | 92 | 65 | 68 | 80 | 385 | 60 |
| 120 | staryu | Water | 30 | 45 | 55 | 85 | 70 | 285 | 225 |
| 121 | starmie | Water/Psychic | 60 | 75 | 85 | 115 | 100 | 435 | 60 |
| 122 | mrmime | Psychic | 40 | 45 | 65 | 90 | 100 | 340 | 45 |
| 123 | scyther | Bug/Flying | 70 | 110 | 80 | 105 | 55 | 420 | 45 |
| 124 | jynx | Ice/Psychic | 65 | 50 | 35 | 95 | 95 | 340 | 45 |
| 125 | electabuzz | Electric | 65 | 83 | 57 | 105 | 85 | 395 | 45 |
| 126 | magmar | Fire | 65 | 95 | 57 | 93 | 85 | 395 | 45 |
| 127 | pinsir | Bug | 65 | 125 | 100 | 85 | 55 | 430 | 45 |
| 128 | tauros | Normal | 75 | 100 | 95 | 110 | 70 | 450 | 45 |
| 129 | magikarp | Water | 20 | 10 | 55 | 80 | 20 | 185 | 255 |
| 130 | gyarados | Water/Flying | 95 | 125 | 79 | 81 | 100 | 480 | 45 |
| 131 | lapras | Water/Ice | 130 | 85 | 80 | 60 | 95 | 450 | 45 |
| 132 | ditto | Normal | 48 | 48 | 48 | 48 | 48 | 240 | 35 |
| 133 | eevee | Normal | 55 | 55 | 50 | 55 | 65 | 280 | 45 |
| 134 | vaporeon | Water | 130 | 65 | 60 | 65 | 110 | 430 | 45 |
| 135 | jolteon | Electric | 65 | 65 | 60 | 130 | 110 | 430 | 45 |
| 136 | flareon | Fire | 65 | 130 | 60 | 65 | 110 | 430 | 45 |
| 137 | porygon | Normal | 65 | 60 | 70 | 40 | 75 | 310 | 45 |
| 138 | omanyte | Rock/Water | 35 | 40 | 100 | 35 | 90 | 300 | 45 |
| 139 | omastar | Rock/Water | 70 | 60 | 125 | 55 | 115 | 425 | 45 |
| 140 | kabuto | Rock/Water | 30 | 80 | 90 | 55 | 45 | 300 | 45 |
| 141 | kabutops | Rock/Water | 60 | 115 | 105 | 80 | 70 | 430 | 45 |
| 142 | aerodactyl | Rock/Flying | 80 | 105 | 65 | 130 | 60 | 440 | 45 |
| 143 | snorlax | Normal | 160 | 110 | 65 | 30 | 65 | 430 | 25 |
| 144 | articuno | Ice/Flying | 90 | 85 | 100 | 85 | 125 | 485 | 3 |
| 145 | zapdos | Electric/Flying | 90 | 90 | 85 | 100 | 125 | 490 | 3 |
| 146 | moltres | Fire/Flying | 90 | 100 | 90 | 90 | 125 | 495 | 3 |
| 147 | dratini | Dragon | 41 | 64 | 45 | 50 | 50 | 250 | 45 |
| 148 | dragonair | Dragon | 61 | 84 | 65 | 70 | 70 | 350 | 45 |
| 149 | dragonite | Dragon/Flying | 91 | 134 | 95 | 80 | 100 | 500 | 45 |
| 150 | mewtwo | Psychic | 106 | 110 | 90 | 130 | 154 | 590 | 3 |
| 151 | mew | Psychic | 100 | 100 | 100 | 100 | 100 | 500 | 45 |
| 152 | blastoise_unique | Water | 79 | 83 | 100 | 78 | 85 | 425 | 45 |
| 153 | bulbasaur_unique | Grass/Poison | 45 | 49 | 49 | 45 | 65 | 253 | 45 |
| 154 | chansey_unique | Normal | 250 | 5 | 5 | 50 | 105 | 415 | 30 |
| 155 | charmander_unique | Fire | 39 | 52 | 43 | 65 | 50 | 249 | 45 |
| 156 | ditto_happy | Normal | 48 | 48 | 48 | 48 | 48 | 240 | 35 |
| 157 | geodude_fighting | Fighting | 40 | 80 | 100 | 20 | 30 | 270 | 255 |
| 158 | goldeen_fighting | Fighting | 45 | 67 | 60 | 63 | 50 | 285 | 225 |
| 159 | grimer_poison | Poison | 80 | 80 | 50 | 25 | 40 | 275 | 190 |
| 160 | ivysaur_erika | Grass/Poison | 60 | 62 | 63 | 60 | 80 | 325 | 45 |
| 161 | kakuna_rock_type | Rock | 45 | 25 | 50 | 35 | 25 | 180 | 120 |
| 162 | marowak_unique | Ground | 60 | 80 | 110 | 45 | 50 | 345 | 75 |
| 163 | nidoking_unique | Poison/Ground | 81 | 92 | 77 | 85 | 75 | 410 | 45 |
| 164 | nidoking_unique2 | Poison/Ground | 81 | 92 | 77 | 85 | 75 | 410 | 45 |
| 165 | nidoranm_unique | Poison | 46 | 57 | 40 | 50 | 40 | 233 | 235 |
| 166 | omanyte_unique | Rock/Water | 35 | 40 | 100 | 35 | 90 | 300 | 45 |
| 167 | onix_brock | Rock/Ground | 35 | 45 | 160 | 70 | 30 | 340 | 45 |
| 168 | raichu_unique | Electric | 60 | 90 | 55 | 100 | 90 | 395 | 75 |
| 169 | squirtle_unique | Water | 44 | 48 | 65 | 43 | 50 | 250 | 45 |
| 170 | tangela_erika | Grass | 65 | 55 | 115 | 60 | 100 | 395 | 45 |
| 171 | tentacool_big | Water/Poison | 40 | 40 | 35 | 70 | 100 | 285 | 60 |
| 172 | venusaur_erika | Grass/Poison | 80 | 82 | 83 | 80 | 100 | 425 | 45 |

## Current starting moves, level-up moves, evolutions and TM/HM access

These are full current source lists, not just new additions. Starting moves are the four header slots; generated high-level movesets can replace them with later learning entries. Variant lists follow their original source, with evolution destinations still pointing to original species. “None” means no entries in that category. Evolution rules below retain source syntax: EV_LEVEL = level; EV_ITEM = item evolution (the extra `1` is engine metadata); EV_TRADE = trade evolution. TM numbers 51–55 are HM01–HM05 in source order.

### 1. bulbasaur

- Starting: Tackle, Growl.
- Level-up: 7: Leech Seed, 13: Vine Whip, 20: Poisonpowder, 25: Synthesis, 27: Razor Leaf, 34: Growth, 41: Sleep Powder, 42: Giga Drain, 48: Solarbeam.
- Evolution: EV_LEVEL, 16, IVYSAUR.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut.

### 2. ivysaur

- Starting: Tackle, Growl, Leech Seed.
- Level-up: 7: Leech Seed, 13: Vine Whip, 22: Poisonpowder, 29: Synthesis, 30: Razor Leaf, 38: Growth, 46: Sleep Powder, 47: Giga Drain, 54: Solarbeam.
- Evolution: EV_LEVEL, 32, VENUSAUR.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut.

### 3. venusaur

- Starting: Tackle, Growl, Leech Seed, Vine Whip.
- Level-up: 7: Leech Seed, 13: Vine Whip, 22: Poisonpowder, 30: Razor Leaf, 33: Synthesis, 43: Growth, 50: Giga Drain, 55: Sleep Powder, 65: Solarbeam.
- Evolution: None.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut.

### 4. charmander

- Starting: Scratch, Growl.
- Level-up: 9: Ember, 15: Leer, 20: Flame Charge, 22: Rage, 28: Incinerate, 30: Slash, 38: Flamethrower, 46: Fire Spin.
- Evolution: EV_LEVEL, 16, CHARMELEON.
- TM/HM: TM01 Mega Punch, TM03 Swords Dance, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM23 Dragon Rage, TM28 Dig, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut, HM04 Strength.

### 5. charmeleon

- Starting: Scratch, Growl, Ember.
- Level-up: 9: Ember, 15: Leer, 24: Rage, 25: Flame Charge, 32: Incinerate, 33: Slash, 42: Flamethrower, 56: Fire Spin.
- Evolution: EV_LEVEL, 36, CHARIZARD.
- TM/HM: TM01 Mega Punch, TM03 Swords Dance, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM23 Dragon Rage, TM28 Dig, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut, HM04 Strength.

### 6. charizard

- Starting: Scratch, Growl, Ember, Leer.
- Level-up: 9: Ember, 15: Leer, 24: Rage, 28: Flame Charge, 36: Slash, 37: Incinerate, 42: Aerial Ace, 46: Flamethrower, 47: Cauterize, 48: Dragon Dance, 55: Fire Spin.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM03 Swords Dance, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM23 Dragon Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut, HM02 Fly, HM04 Strength.

### 7. squirtle

- Starting: Tackle, Tail Whip.
- Level-up: 8: Bubble, 15: Water Gun, 22: Bite, 23: Aqua Jet, 28: Withdraw, 30: Brine, 34: Scald, 35: Skull Bash, 38: Snipe Shot, 42: Hydro Pump.
- Evolution: EV_LEVEL, 16, WARTORTLE.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM28 Dig, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf, HM04 Strength.

### 8. wartortle

- Starting: Tackle, Tail Whip, Bubble.
- Level-up: 8: Bubble, 15: Water Gun, 24: Bite, 26: Aqua Jet, 31: Withdraw, 34: Brine, 38: Scald, 39: Skull Bash, 42: Snipe Shot, 47: Hydro Pump.
- Evolution: EV_LEVEL, 36, BLASTOISE.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM28 Dig, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf, HM04 Strength.

### 9. blastoise

- Starting: Tackle, Tail Whip, Bubble, Water Gun.
- Level-up: 8: Bubble, 15: Water Gun, 24: Bite, 30: Aqua Jet, 31: Withdraw, 38: Brine, 42: Skull Bash, 43: Scald, 46: Snipe Shot, 52: Hydro Pump.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf, HM04 Strength.

### 10. caterpie

- Starting: Tackle, String Shot.
- Level-up: None.
- Evolution: EV_LEVEL, 7, METAPOD.
- TM/HM: None.

### 11. metapod

- Starting: Harden.
- Level-up: 7: Harden.
- Evolution: EV_LEVEL, 10, BUTTERFREE.
- TM/HM: None.

### 12. butterfree

- Starting: Tackle, String Shot, Harden, Confusion.
- Level-up: 12: Confusion, 15: Poisonpowder, 16: Stun Spore, 17: Sleep Powder, 21: Supersonic, 26: Whirlwind, 28: Gust, 32: Psybeam.
- Evolution: None.
- TM/HM: TM02 Twister, TM04 Whirlwind, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM44 Rest, TM46 Psywave, TM50 Substitute, HM04 Strength.

### 13. weedle

- Starting: Poison Sting, String Shot.
- Level-up: None.
- Evolution: EV_LEVEL, 7, KAKUNA.
- TM/HM: None.

### 14. kakuna

- Starting: Harden.
- Level-up: 7: Harden.
- Evolution: EV_LEVEL, 10, BEEDRILL.
- TM/HM: None.

### 15. beedrill

- Starting: Poison Sting, String Shot, Harden, Fury Attack.
- Level-up: 12: Fury Attack, 16: Focus Energy, 20: Twineedle, 25: Rage, 28: Lunge, 30: Pin Missile, 34: Pierce, 35: Agility, 38: Ambush, 48: Megahorn.
- Evolution: None.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut.

### 16. pidgey

- Starting: Gust.
- Level-up: 5: Sand-Attack, 12: Quick Attack, 19: Whirlwind, 25: Roost, 28: Wing Attack, 32: Aerial Ace, 36: Agility, 44: Mirror Move.
- Evolution: EV_LEVEL, 18, PIDGEOTTO.
- TM/HM: TM02 Twister, TM04 Whirlwind, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM43 Sky Attack, TM44 Rest, TM50 Substitute, HM02 Fly.

### 17. pidgeotto

- Starting: Gust, Sand-Attack.
- Level-up: 5: Sand-Attack, 12: Quick Attack, 21: Whirlwind, 29: Roost, 31: Wing Attack, 36: Aerial Ace, 38: Gale Wind, 40: Agility, 49: Mirror Move.
- Evolution: EV_LEVEL, 36, PIDGEOT.
- TM/HM: TM02 Twister, TM04 Whirlwind, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM43 Sky Attack, TM44 Rest, TM50 Substitute, HM02 Fly.

### 18. pidgeot

- Starting: Gust, Sand-Attack, Quick Attack.
- Level-up: 5: Sand-Attack, 12: Quick Attack, 21: Whirlwind, 31: Wing Attack, 33: Roost, 40: Aerial Ace, 42: Gale Wind, 44: Agility, 54: Mirror Move.
- Evolution: None.
- TM/HM: TM02 Twister, TM04 Whirlwind, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM43 Sky Attack, TM44 Rest, TM50 Substitute, HM02 Fly.

### 19. rattata

- Starting: Tackle, Tail Whip.
- Level-up: 7: Quick Attack, 14: Hyper Fang, 16: Flail, 23: Focus Energy, 28: Facade, 34: Super Fang.
- Evolution: EV_LEVEL, 20, RATICATE.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM14 Blizzard, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 20. raticate

- Starting: Tackle, Tail Whip, Quick Attack.
- Level-up: 7: Quick Attack, 14: Hyper Fang, 20: Flail, 27: Focus Energy, 32: Facade, 41: Super Fang.
- Evolution: None.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 21. spearow

- Starting: Peck, Growl.
- Level-up: 9: Leer, 15: Fury Attack, 22: Mirror Move, 26: Roost, 29: Drill Peck, 32: Aerial Ace, 34: Pierce, 36: Agility.
- Evolution: EV_LEVEL, 20, FEAROW.
- TM/HM: TM02 Twister, TM04 Whirlwind, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM43 Sky Attack, TM44 Rest, TM50 Substitute, HM02 Fly.

### 22. fearow

- Starting: Peck, Growl, Leer.
- Level-up: 9: Leer, 15: Fury Attack, 25: Mirror Move, 30: Roost, 34: Drill Peck, 36: Aerial Ace, 38: Pierce, 40: Gale Wind, 43: Agility.
- Evolution: None.
- TM/HM: TM02 Twister, TM04 Whirlwind, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM43 Sky Attack, TM44 Rest, TM50 Substitute, HM02 Fly.

### 23. ekans

- Starting: Wrap, Leer.
- Level-up: 10: Poison Sting, 17: Bite, 22: Poison Tail, 24: Glare, 25: Coil, 28: Venoshock, 31: Screech, 34: Poison Fang, 38: Acid.
- Evolution: EV_LEVEL, 22, ARBOK.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM21 Mega Drain, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM04 Strength.

### 24. arbok

- Starting: Wrap, Leer, Poison Sting.
- Level-up: 10: Poison Sting, 17: Bite, 26: Poison Tail, 27: Glare, 28: Coil, 32: Venoshock, 36: Screech, 38: Poison Fang, 47: Acid.
- Evolution: None.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM04 Strength.

### 25. pikachu

- Starting: Thundershock, Growl.
- Level-up: 6: Tail Whip, 8: Thunder Wave, 11: Quick Attack, 15: Double Team, 20: Slam, 22: Charge, 26: Thunderbolt, 29: Swift, 30: Shock Wave, 33: Agility, 38: Thunderclap, 41: Thunder, 50: Light Screen.
- Evolution: EV_ITEM, THUNDER_STONE, 1, RAICHU.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM16 Pay Day, TM17 Submission, TM19 Seismic Toss, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM50 Substitute, HM05 Flash.

### 26. raichu

- Starting: Growl, Thundershock.
- Level-up: 11: Tail Whip, 13: Thunder Wave, 25: Slam, 26: Charge, 31: Thunderbolt, 34: Shock Wave, 42: Thunderclap, 46: Thunder, 55: Light Screen.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM16 Pay Day, TM17 Submission, TM19 Seismic Toss, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM50 Substitute, HM05 Flash.

### 27. sandshrew

- Starting: Scratch.
- Level-up: 10: Sand-Attack, 17: Slash, 24: Poison Sting, 31: Swift, 38: Fury Swipes.
- Evolution: EV_LEVEL, 22, SANDSLASH.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM17 Submission, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM01 Cut, HM04 Strength.

### 28. sandslash

- Starting: Scratch, Sand-Attack.
- Level-up: 10: Sand-Attack, 17: Slash, 27: Poison Sting, 36: Swift, 47: Fury Swipes.
- Evolution: None.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM17 Submission, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM01 Cut, HM04 Strength.

### 29. nidoranf

- Starting: Growl, Tackle.
- Level-up: 8: Scratch, 12: Double Kick, 17: Poison Sting, 20: Poison Tail, 23: Tail Whip, 28: Venoshock, 30: Bite, 38: Fury Swipes.
- Evolution: EV_LEVEL, 16, NIDORINA.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM14 Blizzard, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 30. nidorina

- Starting: Growl, Tackle, Scratch.
- Level-up: 8: Scratch, 12: Double Kick, 19: Poison Sting, 24: Poison Tail, 27: Tail Whip, 32: Venoshock, 36: Bite, 37: Poison Fang, 46: Fury Swipes.
- Evolution: EV_ITEM, MOON_STONE, 1, NIDOQUEEN.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 31. nidoqueen

- Starting: Tackle, Scratch, Tail Whip, Body Slam.
- Level-up: 8: Scratch, 12: Double Kick, 19: Poison Sting, 23: Body Slam, 28: Poison Tail, 36: Venoshock, 40: Poison Fang.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM16 Pay Day, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM26 Earthquake, TM27 Fissure, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM03 Surf, HM04 Strength.

### 32. nidoranm

- Starting: Leer, Tackle.
- Level-up: 8: Horn Attack, 12: Double Kick, 17: Poison Sting, 20: Poison Tail, 23: Focus Energy, 28: Venoshock, 30: Fury Attack, 38: Horn Drill.
- Evolution: EV_LEVEL, 16, NIDORINO.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM14 Blizzard, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 33. nidorino

- Starting: Leer, Tackle, Horn Attack.
- Level-up: 8: Horn Attack, 12: Double Kick, 19: Poison Sting, 24: Poison Tail, 27: Focus Energy, 32: Venoshock, 36: Fury Attack, 37: Poison Fang, 46: Horn Drill.
- Evolution: EV_ITEM, MOON_STONE, 1, NIDOKING.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 34. nidoking

- Starting: Tackle, Horn Attack, Poison Sting, Thrash.
- Level-up: 8: Horn Attack, 12: Double Kick, 19: Poison Sting, 23: Thrash, 28: Poison Tail, 36: Venoshock, 40: Pierce, 41: Poison Fang, 55: Megahorn.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM16 Pay Day, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM26 Earthquake, TM27 Fissure, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM03 Surf, HM04 Strength.

### 35. clefairy

- Starting: Pound, Growl.
- Level-up: 13: Sing, 18: Doubleslap, 24: Minimize, 31: Metronome, 39: Defense Curl, 48: Light Screen.
- Evolution: EV_ITEM, MOON_STONE, 1, CLEFABLE.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM22 Solarbeam, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM04 Strength, HM05 Flash.

### 36. clefable

- Starting: Sing, Doubleslap, Minimize, Metronome.
- Level-up: 13: Sing, 18: Doubleslap, 24: Minimize, 31: Metronome.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM22 Solarbeam, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM04 Strength, HM05 Flash.

### 37. vulpix

- Starting: Ember, Tail Whip.
- Level-up: 16: Quick Attack, 21: Roar, 22: Flame Charge, 24: Will-O-Wisp, 28: Confuse Ray, 29: Incinerate, 35: Flamethrower, 36: Cauterize, 42: Fire Spin.
- Evolution: EV_ITEM, FIRE_STONE, 1, NINETALES.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM28 Dig, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 38. ninetales

- Starting: Ember, Tail Whip.
- Level-up: 20: Quick Attack, 26: Flame Charge, 28: Confuse Ray, 29: Will-O-Wisp, 32: Incinerate, 36: Flamethrower, 40: Cauterize, 44: Fire Spin.
- Evolution: None.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM28 Dig, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 39. jigglypuff

- Starting: Sing.
- Level-up: 9: Pound, 14: Disable, 19: Defense Curl, 24: Doubleslap, 29: Rest, 34: Body Slam, 39: Double-Edge.
- Evolution: EV_ITEM, MOON_STONE, 1, WIGGLYTUFF.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM22 Solarbeam, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM04 Strength, HM05 Flash.

### 40. wigglytuff

- Starting: Sing, Disable, Defense Curl, Doubleslap.
- Level-up: 9: Pound, 14: Disable, 19: Defense Curl, 24: Sing, 29: Doubleslap, 34: Disable, 39: Body Slam.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM22 Solarbeam, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM04 Strength, HM05 Flash.

### 41. zubat

- Starting: Leech Life.
- Level-up: 10: Supersonic, 15: Bite, 21: Confuse Ray, 28: Wing Attack, 29: Venoshock, 30: Roost, 34: Poison Fang, 36: Haze.
- Evolution: EV_LEVEL, 22, GOLBAT.
- TM/HM: TM02 Twister, TM04 Whirlwind, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM21 Mega Drain, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM44 Rest, TM50 Substitute.

### 42. golbat

- Starting: Leech Life, Screech, Bite.
- Level-up: 10: Supersonic, 15: Bite, 21: Confuse Ray, 32: Wing Attack, 33: Venoshock, 34: Roost, 38: Poison Fang, 43: Haze.
- Evolution: None.
- TM/HM: TM02 Twister, TM04 Whirlwind, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM44 Rest, TM50 Substitute.

### 43. oddish

- Starting: Absorb.
- Level-up: 15: Poisonpowder, 17: Stun Spore, 19: Sleep Powder, 24: Acid, 28: Synthesis, 33: Petal Dance, 40: Giga Drain, 46: Solarbeam.
- Evolution: EV_LEVEL, 21, GLOOM.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut.

### 44. gloom

- Starting: Absorb, Poisonpowder, Stun Spore.
- Level-up: 15: Poisonpowder, 17: Stun Spore, 19: Sleep Powder, 28: Acid, 32: Synthesis, 38: Petal Dance, 44: Giga Drain, 52: Solarbeam.
- Evolution: EV_ITEM, LEAF_STONE, 1, VILEPLUME.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut.

### 45. vileplume

- Starting: Stun Spore, Sleep Powder, Acid, Petal Dance.
- Level-up: 15: Poisonpowder, 17: Stun Spore, 19: Sleep Powder, 30: Acid, 36: Synthesis, 40: Petal Dance, 44: Giga Drain.
- Evolution: None.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut.

### 46. paras

- Starting: Scratch.
- Level-up: 13: Stun Spore, 20: Leech Life, 24: Lunge, 27: Spore, 28: Ambush, 30: X-Scissor, 34: Slash, 35: Shell Break, 38: Giga Drain, 41: Growth.
- Evolution: EV_LEVEL, 24, PARASECT.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM28 Dig, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut.

### 47. parasect

- Starting: Scratch, Stun Spore, Leech Life.
- Level-up: 13: Stun Spore, 20: Leech Life, 28: Lunge, 30: Spore, 32: Ambush, 34: X-Scissor, 38: Shell Break, 39: Slash, 42: Giga Drain, 48: Growth.
- Evolution: None.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM28 Dig, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut.

### 48. venonat

- Starting: Tackle, Disable.
- Level-up: 11: Supersonic, 19: Confusion, 24: Poisonpowder, 25: Lunge, 27: Leech Life, 28: Ambush, 30: Stun Spore, 35: Psybeam, 38: Sleep Powder, 43: Psychic.
- Evolution: EV_LEVEL, 31, VENOMOTH.
- TM/HM: TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM29 Psychic, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM46 Psywave, TM50 Substitute.

### 49. venomoth

- Starting: Tackle, Disable, Poisonpowder, Leech Life.
- Level-up: 11: Supersonic, 19: Confusion, 24: Poisonpowder, 27: Leech Life, 28: Lunge, 30: Stun Spore, 32: Ambush, 38: Psybeam, 43: Sleep Powder, 50: Psychic.
- Evolution: None.
- TM/HM: TM02 Twister, TM04 Whirlwind, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM44 Rest, TM46 Psywave, TM50 Substitute, HM04 Strength.

### 50. diglett

- Starting: Scratch.
- Level-up: 15: Growl, 19: Dig, 24: Sand-Attack, 31: Slash, 40: Earthquake.
- Evolution: EV_LEVEL, 26, DUGTRIO.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM01 Cut.

### 51. dugtrio

- Starting: Scratch, Growl, Dig.
- Level-up: 15: Growl, 19: Dig, 24: Sand-Attack, 35: Slash, 47: Earthquake.
- Evolution: None.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM01 Cut.

### 52. meowth

- Starting: Scratch, Growl.
- Level-up: 12: Bite, 17: Pay Day, 24: Screech, 30: Punishment, 33: Fury Swipes, 44: Slash.
- Evolution: EV_LEVEL, 28, PERSIAN.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM16 Pay Day, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 53. persian

- Starting: Scratch, Growl, Bite, Screech.
- Level-up: 12: Bite, 17: Pay Day, 24: Screech, 34: Punishment, 37: Fury Swipes, 51: Slash.
- Evolution: None.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM15 Hyper Beam, TM16 Pay Day, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 54. psyduck

- Starting: Scratch.
- Level-up: 28: Tail Whip, 29: Scald, 31: Disable, 36: Confusion, 43: Fury Swipes, 52: Hydro Pump.
- Evolution: EV_LEVEL, 33, GOLDUCK.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM16 Pay Day, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf, HM04 Strength.

### 55. golduck

- Starting: Scratch, Tail Whip, Disable.
- Level-up: 28: Tail Whip, 31: Disable, 32: Scald, 39: Confusion, 48: Fury Swipes, 59: Hydro Pump.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM16 Pay Day, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf, HM04 Strength.

### 56. mankey

- Starting: Scratch, Leer.
- Level-up: 9: Low Kick, 15: Karate Chop, 21: Fury Swipes, 24: Bulk Up, 27: Focus Energy, 30: Punishment, 33: Seismic Toss, 39: Thrash, 45: Screech.
- Evolution: EV_LEVEL, 28, PRIMEAPE.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM16 Pay Day, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM04 Strength.

### 57. primeape

- Starting: Scratch, Leer, Karate Chop, Fury Swipes.
- Level-up: 9: Low Kick, 15: Karate Chop, 21: Fury Swipes, 27: Focus Energy, 28: Rage, 29: Bulk Up, 34: Punishment, 37: Seismic Toss, 40: Brick Break, 42: Drain Punch, 45: Screech, 46: Thrash.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM16 Pay Day, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM04 Strength.

### 58. growlithe

- Starting: Bite, Roar.
- Level-up: 18: Ember, 22: Flame Charge, 23: Leer, 24: Will-O-Wisp, 28: Incinerate, 30: Take Down, 36: Cauterize, 39: Agility, 50: Flamethrower.
- Evolution: EV_ITEM, FIRE_STONE, 1, ARCANINE.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM23 Dragon Rage, TM28 Dig, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 59. arcanine

- Starting: Roar, Bite.
- Level-up: 20: Ember, 26: Flame Charge, 28: Will-O-Wisp, 30: Leer, 32: Incinerate, 40: Take Down, 41: Cauterize, 50: Flamethrower.
- Evolution: None.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM23 Dragon Rage, TM28 Dig, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 60. poliwag

- Starting: Bubble.
- Level-up: 16: Hypnosis, 19: Water Gun, 22: Aqua Jet, 25: Doubleslap, 28: Scald, 31: Body Slam, 38: Amnesia, 45: Hydro Pump.
- Evolution: EV_LEVEL, 25, POLIWHIRL.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM29 Psychic, TM31 Mimic, TM32 Double Team, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM46 Psywave, TM50 Substitute, HM03 Surf.

### 61. poliwhirl

- Starting: Bubble, Hypnosis, Water Gun.
- Level-up: 16: Hypnosis, 19: Water Gun, 26: Doubleslap, 27: Aqua Jet, 32: Scald, 33: Body Slam, 41: Amnesia, 49: Hydro Pump.
- Evolution: EV_ITEM, WATER_STONE, 1, POLIWRATH.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM29 Psychic, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM40 Skull Bash, TM44 Rest, TM46 Psywave, TM50 Substitute, HM03 Surf, HM04 Strength.

### 62. poliwrath

- Starting: Bubble.
- Level-up: 16: Hypnosis, 19: Water Gun, 27: Doubleslap, 30: Aqua Jet, 32: Bulk Up, 35: Body Slam, 36: Scald, 38: Drain Punch, 42: Brick Break, 53: Hydro Pump.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM29 Psychic, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM40 Skull Bash, TM44 Rest, TM46 Psywave, TM50 Substitute, HM03 Surf, HM04 Strength.

### 63. abra

- Starting: Teleport.
- Level-up: 24: Psyshock, 30: Psych Up.
- Evolution: EV_LEVEL, 16, KADABRA.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM05 Flash.

### 64. kadabra

- Starting: Teleport, Kinesis, Confusion, Disable.
- Level-up: 16: Confusion, 20: Disable, 27: Psybeam, 28: Psyshock, 31: Recover, 34: Psych Up, 36: Mind Break, 38: Psychic, 42: Reflect.
- Evolution: EV_TRADE, 1, ALAKAZAM; EV_LEVEL, 46, ALAKAZAM.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM28 Dig, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM05 Flash.

### 65. alakazam

- Starting: Teleport, Kinesis, Confusion, Disable.
- Level-up: 16: Confusion, 20: Disable, 27: Psybeam, 31: Recover, 32: Psyshock, 38: Psychic, 39: Psych Up, 40: Mind Break, 42: Reflect.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM28 Dig, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM05 Flash.

### 66. machop

- Starting: Karate Chop.
- Level-up: 20: Low Kick, 24: Bulk Up, 25: Leer, 32: Focus Energy, 33: Drain Punch, 36: Brick Break, 39: Seismic Toss, 46: Submission.
- Evolution: EV_LEVEL, 28, MACHOKE.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM04 Strength.

### 67. machoke

- Starting: Karate Chop, Low Kick, Leer.
- Level-up: 20: Low Kick, 25: Leer, 28: Bulk Up, 36: Focus Energy, 37: Drain Punch, 40: Brick Break, 44: Seismic Toss, 52: Submission.
- Evolution: EV_TRADE, 1, MACHAMP; EV_LEVEL, 48, MACHAMP.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM04 Strength.

### 68. machamp

- Starting: Karate Chop, Low Kick, Leer.
- Level-up: 20: Low Kick, 25: Leer, 32: Bulk Up, 36: Focus Energy, 40: Drain Punch, 44: Seismic Toss, 45: Brick Break, 52: Submission.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM04 Strength.

### 69. bellsprout

- Starting: Vine Whip, Growth.
- Level-up: 13: Wrap, 15: Poisonpowder, 18: Sleep Powder, 21: Stun Spore, 26: Acid, 28: Synthesis, 33: Razor Leaf, 40: Giga Drain, 42: Slam.
- Evolution: EV_LEVEL, 21, WEEPINBELL.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut.

### 70. weepinbell

- Starting: Vine Whip, Growth, Wrap.
- Level-up: 13: Wrap, 15: Poisonpowder, 18: Sleep Powder, 23: Stun Spore, 29: Acid, 32: Synthesis, 38: Razor Leaf, 44: Giga Drain, 49: Slam.
- Evolution: EV_ITEM, LEAF_STONE, 1, VICTREEBEL.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut.

### 71. victreebel

- Starting: Sleep Powder, Stun Spore, Acid, Razor Leaf.
- Level-up: 13: Wrap, 18: Poisonpowder, 23: Sleep Powder, 30: Stun Spore, 36: Synthesis, 37: Acid, 44: Razor Leaf, 45: Giga Drain.
- Evolution: None.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut.

### 72. tentacool

- Starting: Acid.
- Level-up: 7: Supersonic, 13: Wrap, 18: Poison Sting, 22: Water Gun, 24: Coil, 27: Constrict, 28: Venoshock, 32: Brine, 33: Barrier, 40: Screech, 48: Hydro Pump.
- Evolution: EV_LEVEL, 30, TENTACRUEL.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM21 Mega Drain, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut, HM03 Surf.

### 73. tentacruel

- Starting: Acid, Supersonic, Wrap.
- Level-up: 7: Supersonic, 13: Wrap, 18: Poison Sting, 22: Water Gun, 27: Constrict, 28: Coil, 32: Venoshock, 35: Barrier, 36: Brine, 43: Screech, 50: Hydro Pump.
- Evolution: None.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut, HM03 Surf.

### 74. geodude

- Starting: Tackle.
- Level-up: 11: Defense Curl, 16: Rock Throw, 18: Rock Tomb, 21: Selfdestruct, 22: Rock Polish, 26: Harden, 30: Stone Press, 31: Earthquake, 36: Explosion, 40: Stone Edge.
- Evolution: EV_LEVEL, 25, GRAVELER.
- TM/HM: TM01 Mega Punch, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM36 Selfdestruct, TM38 Fire Blast, TM44 Rest, TM47 Explosion, TM48 Rock Slide, TM50 Substitute, HM04 Strength.

### 75. graveler

- Starting: Tackle, Defense Curl.
- Level-up: 11: Defense Curl, 16: Rock Throw, 21: Selfdestruct, 22: Rock Tomb, 26: Rock Polish, 29: Harden, 34: Stone Press, 36: Earthquake, 43: Explosion, 44: Stone Edge.
- Evolution: EV_TRADE, 1, GOLEM; EV_LEVEL, 45, GOLEM.
- TM/HM: TM01 Mega Punch, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM36 Selfdestruct, TM38 Fire Blast, TM44 Rest, TM47 Explosion, TM48 Rock Slide, TM50 Substitute, HM04 Strength.

### 76. golem

- Starting: Tackle, Defense Curl.
- Level-up: 11: Defense Curl, 16: Rock Throw, 21: Selfdestruct, 26: Rock Polish, 27: Rock Tomb, 29: Harden, 36: Earthquake, 38: Stone Press, 43: Explosion, 48: Stone Edge.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM36 Selfdestruct, TM38 Fire Blast, TM44 Rest, TM47 Explosion, TM48 Rock Slide, TM50 Substitute, HM04 Strength.

### 77. ponyta

- Starting: Ember.
- Level-up: 22: Flame Charge, 26: Will-O-Wisp, 30: Tail Whip, 31: Incinerate, 32: Stomp, 35: Growl, 39: Fire Spin, 43: Take Down, 48: Agility.
- Evolution: EV_LEVEL, 40, RAPIDASH.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 78. rapidash

- Starting: Ember, Tail Whip, Stomp, Growl.
- Level-up: 26: Flame Charge, 30: Tail Whip, 31: Will-O-Wisp, 32: Stomp, 34: Incinerate, 35: Growl, 39: Fire Spin, 47: Take Down, 55: Agility.
- Evolution: None.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 79. slowpoke

- Starting: Confusion.
- Level-up: 18: Disable, 22: Headbutt, 27: Growl, 28: Scald, 32: Psyshock, 33: Water Gun, 40: Amnesia, 48: Psychic.
- Evolution: EV_LEVEL, 37, SLOWBRO.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM16 Pay Day, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM03 Surf, HM04 Strength, HM05 Flash.

### 80. slowbro

- Starting: Confusion, Disable, Headbutt.
- Level-up: 18: Disable, 22: Headbutt, 27: Growl, 32: Scald, 33: Water Gun, 36: Psyshock, 37: Withdraw, 44: Amnesia, 55: Psychic.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM16 Pay Day, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM03 Surf, HM04 Strength, HM05 Flash.

### 81. magnemite

- Starting: Tackle.
- Level-up: 21: Sonicboom, 22: Charge, 25: Thundershock, 29: Supersonic, 30: Shock Wave, 35: Thunder Wave, 41: Swift, 47: Screech.
- Evolution: EV_LEVEL, 30, MAGNETON.
- TM/HM: TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM44 Rest, TM45 Thunder Wave, TM50 Substitute, HM05 Flash.

### 82. magneton

- Starting: Tackle, Sonicboom, Thundershock.
- Level-up: 21: Sonicboom, 25: Thundershock, 26: Charge, 29: Supersonic, 34: Shock Wave, 38: Thunder Wave, 46: Swift, 54: Screech.
- Evolution: None.
- TM/HM: TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM44 Rest, TM45 Thunder Wave, TM50 Substitute, HM05 Flash.

### 83. farfetchd

- Starting: Sand-Attack, Peck.
- Level-up: 7: Leer, 15: Fury Attack, 23: Swords Dance, 28: Roost, 31: Agility, 32: Aerial Ace, 38: Gale Wind, 39: Slash.
- Evolution: None.
- TM/HM: TM02 Twister, TM03 Swords Dance, TM04 Whirlwind, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut, HM02 Fly.

### 84. doduo

- Starting: Peck.
- Level-up: 20: Growl, 22: Flail, 24: Fury Attack, 28: Roost, 30: Drill Peck, 34: Aerial Ace, 36: Rage, 40: Tri Attack, 44: Agility.
- Evolution: EV_LEVEL, 31, DODRIO.
- TM/HM: TM04 Whirlwind, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM43 Sky Attack, TM44 Rest, TM49 Tri Attack, TM50 Substitute, HM02 Fly.

### 85. dodrio

- Starting: Peck, Growl, Fury Attack.
- Level-up: 20: Growl, 24: Fury Attack, 26: Flail, 30: Drill Peck, 32: Roost, 38: Aerial Ace, 39: Rage, 42: Gale Wind, 45: Tri Attack, 51: Agility.
- Evolution: None.
- TM/HM: TM04 Whirlwind, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM43 Sky Attack, TM44 Rest, TM49 Tri Attack, TM50 Substitute, HM02 Fly.

### 86. seel

- Starting: Headbutt.
- Level-up: 20: Icy Wind, 24: Ice Shard, 28: Brine, 30: Growl, 32: Ice Armor, 34: Icicle Spear, 35: Aurora Beam, 38: Frost Breath, 40: Rest, 45: Take Down, 50: Ice Beam.
- Evolution: EV_LEVEL, 34, DEWGONG.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM16 Pay Day, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf, HM04 Strength.

### 87. dewgong

- Starting: Headbutt, Growl, Aurora Beam.
- Level-up: 24: Icy Wind, 28: Ice Shard, 30: Growl, 32: Ice Armor, 33: Brine, 35: Aurora Beam, 38: Icicle Spear, 42: Frost Breath, 44: Rest, 48: Flash Freeze, 50: Take Down, 56: Ice Beam.
- Evolution: None.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM16 Pay Day, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf, HM04 Strength.

### 88. grimer

- Starting: Pound, Disable.
- Level-up: 22: Pollution, 26: Stockpile, 30: Poison Gas, 31: Venoshock, 33: Minimize, 37: Sludge, 42: Harden, 48: Screech, 55: Acid Armor.
- Evolution: EV_LEVEL, 38, MUK.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM20 Rage, TM21 Mega Drain, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM34 Bide, TM36 Selfdestruct, TM38 Fire Blast, TM44 Rest, TM47 Explosion, TM50 Substitute.

### 89. muk

- Starting: Pound, Disable, Poison Gas.
- Level-up: 26: Pollution, 30: Poison Gas, 31: Stockpile, 33: Minimize, 34: Venoshock, 37: Sludge, 45: Harden, 53: Screech, 60: Acid Armor.
- Evolution: None.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM34 Bide, TM36 Selfdestruct, TM38 Fire Blast, TM44 Rest, TM47 Explosion, TM50 Substitute.

### 90. shellder

- Starting: Tackle, Withdraw.
- Level-up: 18: Supersonic, 20: Icy Wind, 23: Chomp, 24: Ice Shard, 28: Brine, 30: Aurora Beam, 32: Icicle Spear, 39: Leer, 50: Ice Beam.
- Evolution: EV_ITEM, WATER_STONE, 1, CLOYSTER.
- TM/HM: TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM36 Selfdestruct, TM39 Swift, TM44 Rest, TM47 Explosion, TM49 Tri Attack, TM50 Substitute, HM03 Surf.

### 91. cloyster

- Starting: Tackle, Withdraw.
- Level-up: 18: Supersonic, 23: Chomp, 24: Icy Wind, 28: Ice Shard, 30: Aurora Beam, 32: Brine, 34: Ice Armor, 36: Icicle Spear, 48: Flash Freeze, 50: Spike Cannon.
- Evolution: None.
- TM/HM: TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM20 Rage, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM36 Selfdestruct, TM39 Swift, TM44 Rest, TM47 Explosion, TM49 Tri Attack, TM50 Substitute, HM03 Surf.

### 92. gastly

- Starting: Lick, Confuse Ray, Night Shade.
- Level-up: 12: Astonish, 26: Wailing Cry, 27: Hypnosis, 30: Will-O-Wisp, 32: Punishment, 35: Dream Eater.
- Evolution: EV_LEVEL, 25, HAUNTER.
- TM/HM: TM06 Toxic, TM20 Rage, TM21 Mega Drain, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM31 Mimic, TM32 Double Team, TM34 Bide, TM36 Selfdestruct, TM42 Dream Eater, TM44 Rest, TM46 Psywave, TM47 Explosion, TM50 Substitute.

### 93. haunter

- Starting: Lick, Confuse Ray, Night Shade.
- Level-up: 12: Astonish, 29: Hypnosis, 30: Wailing Cry, 34: Will-O-Wisp, 36: Punishment, 38: Dream Eater.
- Evolution: EV_TRADE, 1, GENGAR; EV_LEVEL, 45, GENGAR.
- TM/HM: TM06 Toxic, TM20 Rage, TM21 Mega Drain, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM31 Mimic, TM32 Double Team, TM34 Bide, TM36 Selfdestruct, TM42 Dream Eater, TM44 Rest, TM46 Psywave, TM47 Explosion, TM50 Substitute.

### 94. gengar

- Starting: Lick, Confuse Ray, Night Shade.
- Level-up: 12: Astonish, 29: Hypnosis, 34: Wailing Cry, 38: Dream Eater, 39: Will-O-Wisp, 40: Punishment.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM21 Mega Drain, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM36 Selfdestruct, TM40 Skull Bash, TM42 Dream Eater, TM44 Rest, TM46 Psywave, TM47 Explosion, TM50 Substitute, HM04 Strength.

### 95. onix

- Starting: Tackle, Screech.
- Level-up: 15: Bind, 19: Rock Throw, 20: Rock Tomb, 25: Rage, 26: Rock Polish, 30: Coil, 33: Slam, 34: Stone Press, 43: Harden, 44: Stone Edge.
- Evolution: None.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM36 Selfdestruct, TM40 Skull Bash, TM44 Rest, TM47 Explosion, TM48 Rock Slide, TM50 Substitute, HM04 Strength.

### 96. drowzee

- Starting: Pound, Hypnosis.
- Level-up: 12: Disable, 13: Astonish, 17: Confusion, 24: Headbutt, 28: Psyshock, 29: Poison Gas, 30: Psych Up, 32: Psychic, 33: Punishment, 34: Mind Break, 37: Meditate.
- Evolution: EV_LEVEL, 26, HYPNO.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM40 Skull Bash, TM42 Dream Eater, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM05 Flash.

### 97. hypno

- Starting: Pound, Hypnosis, Disable, Confusion.
- Level-up: 12: Disable, 13: Astonish, 17: Confusion, 24: Headbutt, 32: Psyshock, 33: Poison Gas, 34: Psych Up, 36: Punishment, 37: Psychic, 38: Mind Break, 43: Meditate.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM40 Skull Bash, TM42 Dream Eater, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM05 Flash.

### 98. krabby

- Starting: Bubble, Leer.
- Level-up: 20: Vicegrip, 24: Flail, 25: Guillotine, 28: Shell Break, 30: Stomp, 35: Crabhammer, 36: X-Scissor, 40: Harden.
- Evolution: EV_LEVEL, 28, KINGLER.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut, HM03 Surf, HM04 Strength.

### 99. kingler

- Starting: Bubble, Leer, Vicegrip.
- Level-up: 20: Vicegrip, 25: Guillotine, 28: Flail, 32: Shell Break, 34: Stomp, 39: X-Scissor, 42: Crabhammer, 49: Harden.
- Evolution: None.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut, HM03 Surf, HM04 Strength.

### 100. voltorb

- Starting: Tackle, Screech.
- Level-up: 17: Sonicboom, 22: Selfdestruct, 23: Charge, 29: Light Screen, 30: Shock Wave, 36: Swift, 43: Explosion.
- Evolution: EV_LEVEL, 30, ELECTRODE.
- TM/HM: TM06 Toxic, TM09 Take Down, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM36 Selfdestruct, TM39 Swift, TM44 Rest, TM45 Thunder Wave, TM47 Explosion, TM50 Substitute, HM05 Flash.

### 101. electrode

- Starting: Tackle, Screech, Sonicboom.
- Level-up: 17: Sonicboom, 22: Selfdestruct, 26: Charge, 29: Light Screen, 34: Shock Wave, 40: Swift, 50: Explosion.
- Evolution: None.
- TM/HM: TM06 Toxic, TM09 Take Down, TM15 Hyper Beam, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM36 Selfdestruct, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM47 Explosion, TM50 Substitute, HM05 Flash.

### 102. exeggcute

- Starting: Barrage, Hypnosis.
- Level-up: 25: Reflect, 28: Leech Seed, 32: Stun Spore, 33: Psyshock, 35: Synthesis, 36: Mind Break, 37: Poisonpowder, 42: Solarbeam, 43: Giga Drain, 48: Sleep Powder.
- Evolution: EV_ITEM, LEAF_STONE, 1, EXEGGUTOR.
- TM/HM: TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM36 Selfdestruct, TM37 Egg Bomb, TM44 Rest, TM46 Psywave, TM47 Explosion, TM50 Substitute.

### 103. exeggutor

- Starting: Barrage, Hypnosis.
- Level-up: 25: Reflect, 28: Stomp, 36: Psyshock, 39: Synthesis, 40: Mind Break, 42: Solarbeam, 46: Giga Drain, 48: Sleep Powder.
- Evolution: None.
- TM/HM: TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM36 Selfdestruct, TM37 Egg Bomb, TM44 Rest, TM46 Psywave, TM47 Explosion, TM50 Substitute, HM04 Strength.

### 104. cubone

- Starting: Bone Club, Growl.
- Level-up: 13: Tail Whip, 16: Headbutt, 17: Astonish, 24: Wailing Cry, 25: Leer, 31: Focus Energy, 38: Thrash, 43: Bonemerang, 46: Rage.
- Evolution: EV_LEVEL, 28, MAROWAK.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM04 Strength.

### 105. marowak

- Starting: Bone Club, Growl, Leer, Focus Energy.
- Level-up: 13: Tail Whip, 16: Headbutt, 17: Astonish, 25: Leer, 28: Wailing Cry, 33: Focus Energy, 41: Thrash, 48: Bonemerang, 55: Rage.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM04 Strength.

### 106. hitmonlee

- Starting: Double Kick, Meditate.
- Level-up: 28: Bulk Up, 33: Rolling Kick, 38: Flying Punch, 39: Pierce, 42: Brick Break, 43: Focus Energy, 48: Hi Jump Kick, 53: Mega Kick.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM04 Strength.

### 107. hitmonchan

- Starting: Comet Punch, Agility.
- Level-up: 28: Bulk Up, 33: Fire Punch, 35: Drain Punch, 38: Ice Punch, 39: Pierce, 42: Brick Break, 43: Thunderpunch, 48: Mega Punch, 53: Counter.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM04 Strength.

### 108. lickitung

- Starting: Wrap, Supersonic.
- Level-up: 7: Stomp, 15: Disable, 18: Astonish, 23: Defense Curl, 26: Stockpile, 31: Slam, 32: Tongue Lash, 34: Facade, 39: Screech.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM03 Swords Dance, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM26 Earthquake, TM27 Fissure, TM31 Mimic, TM32 Double Team, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut, HM03 Surf, HM04 Strength.

### 109. koffing

- Starting: Tackle, Smog.
- Level-up: 22: Pollution, 26: Stockpile, 30: Venoshock, 32: Sludge, 37: Smokescreen, 40: Selfdestruct, 45: Haze, 48: Explosion.
- Evolution: EV_LEVEL, 35, WEEZING.
- TM/HM: TM06 Toxic, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM34 Bide, TM36 Selfdestruct, TM38 Fire Blast, TM44 Rest, TM47 Explosion, TM50 Substitute.

### 110. weezing

- Starting: Tackle, Smog, Sludge.
- Level-up: 26: Pollution, 30: Stockpile, 32: Sludge, 34: Venoshock, 39: Smokescreen, 43: Selfdestruct, 49: Haze, 53: Explosion.
- Evolution: None.
- TM/HM: TM06 Toxic, TM15 Hyper Beam, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM34 Bide, TM36 Selfdestruct, TM38 Fire Blast, TM44 Rest, TM47 Explosion, TM50 Substitute.

### 111. rhyhorn

- Starting: Horn Attack.
- Level-up: 26: Rock Tomb, 30: Stomp, 31: Rock Polish, 34: Stone Press, 35: Tail Whip, 38: Pierce, 40: Fury Attack, 43: Stone Edge, 45: Horn Drill, 50: Leer, 53: Megahorn, 55: Take Down.
- Evolution: EV_LEVEL, 42, RHYDON.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM04 Strength.

### 112. rhydon

- Starting: Horn Attack, Stomp, Tail Whip, Fury Attack.
- Level-up: 30: Stomp, 31: Rock Tomb, 34: Rock Polish, 35: Tail Whip, 38: Stone Press, 40: Fury Attack, 42: Pierce, 47: Stone Edge, 48: Horn Drill, 55: Leer, 59: Megahorn, 64: Take Down.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM16 Pay Day, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM03 Surf, HM04 Strength.

### 113. chansey

- Starting: Pound, Doubleslap.
- Level-up: 12: Tail Whip, 24: Sing, 30: Growl, 38: Minimize, 44: Defense Curl, 48: Light Screen, 54: Double-Edge.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM22 Solarbeam, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM37 Egg Bomb, TM38 Fire Blast, TM40 Skull Bash, TM41 Softboiled, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM04 Strength, HM05 Flash.

### 114. tangela

- Starting: Constrict, Bind.
- Level-up: 27: Absorb, 29: Vine Whip, 32: Poisonpowder, 33: Synthesis, 36: Stun Spore, 39: Sleep Powder, 42: Giga Drain, 45: Slam, 49: Growth.
- Evolution: None.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM31 Mimic, TM32 Double Team, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut.

### 115. kangaskhan

- Starting: Comet Punch, Rage.
- Level-up: 26: Bite, 31: Tail Whip, 36: Mega Punch, 37: Facade, 41: Leer, 42: Brick Break, 46: Dizzy Punch.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM26 Earthquake, TM27 Fissure, TM31 Mimic, TM32 Double Team, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM03 Surf, HM04 Strength.

### 116. horsea

- Starting: Bubble.
- Level-up: 19: Smokescreen, 22: Aqua Jet, 24: Leer, 30: Water Gun, 31: Brine, 37: Agility, 38: Snipe Shot, 45: Hydro Pump.
- Evolution: EV_LEVEL, 32, SEADRA.
- TM/HM: TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf.

### 117. seadra

- Starting: Bubble, Smokescreen.
- Level-up: 19: Smokescreen, 24: Leer, 26: Aqua Jet, 30: Water Gun, 34: Brine, 41: Agility, 42: Snipe Shot, 44: Dragon Dance, 52: Hydro Pump.
- Evolution: None.
- TM/HM: TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf.

### 118. goldeen

- Starting: Peck, Tail Whip.
- Level-up: 19: Supersonic, 22: Aqua Jet, 24: Horn Attack, 25: Flail, 30: Fury Attack, 34: Snipe Shot, 37: Waterfall, 45: Horn Drill, 54: Agility.
- Evolution: EV_LEVEL, 33, SEAKING.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf.

### 119. seaking

- Starting: Peck, Tail Whip, Supersonic.
- Level-up: 19: Supersonic, 24: Horn Attack, 26: Aqua Jet, 28: Flail, 30: Fury Attack, 38: Pierce, 39: Waterfall, 40: Snipe Shot, 46: Megahorn, 48: Horn Drill, 54: Agility.
- Evolution: None.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf.

### 120. staryu

- Starting: Tackle.
- Level-up: 17: Water Gun, 22: Harden, 27: Recover, 32: Swift, 37: Minimize, 42: Light Screen, 47: Hydro Pump.
- Evolution: EV_ITEM, WATER_STONE, 1, STARMIE.
- TM/HM: TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM03 Surf, HM05 Flash.

### 121. starmie

- Starting: Tackle.
- Level-up: 21: Water Gun, 26: Harden, 31: Recover, 36: Swift, 46: Light Screen, 51: Hydro Pump.
- Evolution: None.
- TM/HM: TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM03 Surf, HM05 Flash.

### 122. mrmime

- Starting: Confusion, Barrier.
- Level-up: 15: Confusion, 23: Light Screen, 31: Doubleslap, 32: Psyshock, 36: Psych Up, 38: Mind Break, 39: Meditate, 47: Substitute.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM22 Solarbeam, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM50 Substitute, HM05 Flash.

### 123. scyther

- Starting: Quick Attack.
- Level-up: 17: Leer, 20: Focus Energy, 24: Double Team, 28: Lunge, 29: Slash, 32: Aerial Ace, 35: Swords Dance, 36: X-Scissor, 38: Ambush, 42: Agility, 50: Wing Attack.
- Evolution: None.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut.

### 124. jynx

- Starting: Pound, Lovely Kiss.
- Level-up: 18: Lick, 22: Icy Wind, 23: Doubleslap, 26: Ice Shard, 31: Ice Punch, 32: Psyshock, 35: Ice Armor, 36: Mind Break, 39: Body Slam, 40: Frost Breath, 47: Thrash, 48: Flash Freeze, 58: Blizzard.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM40 Skull Bash, TM44 Rest, TM46 Psywave, TM50 Substitute.

### 125. electabuzz

- Starting: Quick Attack, Leer.
- Level-up: 24: Charge, 32: Shock Wave, 34: Thundershock, 37: Screech, 40: Thunderclap, 42: Thunderpunch, 49: Light Screen, 54: Thunder.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM50 Substitute, HM04 Strength, HM05 Flash.

### 126. magmar

- Starting: Ember.
- Level-up: 24: Flame Charge, 26: Will-O-Wisp, 30: Incinerate, 36: Leer, 38: Cauterize, 39: Confuse Ray, 43: Fire Punch, 48: Smokescreen, 52: Smog, 55: Flamethrower.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM46 Psywave, TM50 Substitute, HM04 Strength.

### 127. pinsir

- Starting: Vicegrip.
- Level-up: 21: Bind, 25: Seismic Toss, 28: Lunge, 30: Guillotine, 34: X-Scissor, 36: Focus Energy, 37: Shell Break, 38: Ambush, 40: Pierce, 43: Harden, 48: Megahorn, 49: Slash, 54: Swords Dance.
- Evolution: None.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM17 Submission, TM19 Seismic Toss, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut, HM04 Strength.

### 128. tauros

- Starting: Tackle.
- Level-up: 21: Stomp, 28: Tail Whip, 35: Leer, 36: Facade, 44: Rage, 51: Take Down.
- Evolution: None.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM26 Earthquake, TM27 Fissure, TM31 Mimic, TM32 Double Team, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM04 Strength.

### 129. magikarp

- Starting: Splash.
- Level-up: 15: Tackle, 25: Flail.
- Evolution: EV_LEVEL, 20, GYARADOS.
- TM/HM: None.

### 130. gyarados

- Starting: Bite, Dragon Rage, Leer, Hydro Pump.
- Level-up: 20: Bite, 25: Dragon Rage, 30: Flail, 32: Leer, 41: Hydro Pump, 42: Dragon Dance, 52: Hyper Beam.
- Evolution: None.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM20 Rage, TM23 Dragon Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf, HM04 Strength.

### 131. lapras

- Starting: Water Gun, Growl.
- Level-up: 16: Sing, 20: Mist, 21: Icy Wind, 24: Ice Shard, 25: Body Slam, 28: Ice Armor, 31: Confuse Ray, 34: Scald, 38: Ice Beam, 39: Icicle Spear, 40: Frost Breath, 44: Dragon Dance, 46: Hydro Pump, 48: Flash Freeze.
- Evolution: None.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM20 Rage, TM22 Solarbeam, TM23 Dragon Rage, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM46 Psywave, TM50 Substitute, HM03 Surf, HM04 Strength.

### 132. ditto

- Starting: Transform.
- Level-up: None.
- Evolution: None.
- TM/HM: None.

### 133. eevee

- Starting: Tackle, Sand-Attack.
- Level-up: 8: Tail Whip, 16: Growl, 23: Quick Attack, 30: Bite, 31: Facade, 36: Focus Energy, 42: Take Down.
- Evolution: EV_ITEM, FIRE_STONE, 1, FLAREON; EV_ITEM, THUNDER_STONE, 1, JOLTEON; EV_ITEM, WATER_STONE, 1, VAPOREON.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 134. vaporeon

- Starting: Tackle, Sand-Attack, Quick Attack, Water Gun.
- Level-up: 8: Tail Whip, 16: Water Gun, 23: Quick Attack, 30: Bite, 32: Scald, 36: Aurora Beam, 37: Facade, 42: Haze, 47: Acid Armor, 48: Mist, 52: Hydro Pump.
- Evolution: None.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf.

### 135. jolteon

- Starting: Tackle, Sand-Attack, Quick Attack, Thundershock.
- Level-up: 8: Tail Whip, 16: Thundershock, 23: Quick Attack, 24: Charge, 30: Double Kick, 32: Shock Wave, 36: Pin Missile, 37: Facade, 40: Thunderclap, 42: Thunder Wave, 47: Agility, 52: Thunder.
- Evolution: None.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM50 Substitute, HM05 Flash.

### 136. flareon

- Starting: Tackle, Sand-Attack, Quick Attack, Ember.
- Level-up: 8: Tail Whip, 16: Ember, 23: Quick Attack, 24: Flame Charge, 26: Will-O-Wisp, 30: Bite, 31: Incinerate, 36: Fire Spin, 37: Facade, 38: Cauterize, 42: Smog, 47: Leer, 48: Rage, 52: Flamethrower.
- Evolution: None.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 137. porygon

- Starting: Tackle, Sharpen, Conversion.
- Level-up: 23: Psybeam, 28: Recover, 35: Agility, 42: Tri Attack.
- Evolution: None.
- TM/HM: TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM05 Flash.

### 138. omanyte

- Starting: Water Gun, Withdraw.
- Level-up: 24: Rock Tomb, 28: Rock Polish, 32: Brine, 34: Horn Attack, 38: Stone Press, 39: Leer, 46: Spike Cannon, 50: Stone Edge, 53: Hydro Pump.
- Evolution: EV_LEVEL, 40, OMASTAR.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM03 Surf.

### 139. omastar

- Starting: Water Gun, Withdraw, Horn Attack.
- Level-up: 28: Rock Tomb, 32: Rock Polish, 34: Horn Attack, 36: Brine, 39: Leer, 42: Stone Press, 44: Spike Cannon, 46: Stone Edge, 49: Hydro Pump.
- Evolution: None.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM17 Submission, TM19 Seismic Toss, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf.

### 140. kabuto

- Starting: Scratch, Harden.
- Level-up: 24: Rock Tomb, 26: Aqua Jet, 28: Rock Polish, 29: Shell Break, 34: Absorb, 38: Stone Press, 39: Slash, 44: Leer, 49: Hydro Pump, 50: Stone Edge.
- Evolution: EV_LEVEL, 40, KABUTOPS.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM03 Surf.

### 141. kabutops

- Starting: Scratch, Harden, Absorb.
- Level-up: 28: Rock Tomb, 30: Aqua Jet, 32: Rock Polish, 33: Shell Break, 34: Absorb, 39: Slash, 42: X-Scissor, 43: Stone Press, 46: Leer, 47: Stone Edge, 53: Hydro Pump.
- Evolution: None.
- TM/HM: TM02 Twister, TM03 Swords Dance, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM17 Submission, TM19 Seismic Toss, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf.

### 142. aerodactyl

- Starting: Wing Attack, Agility.
- Level-up: 25: Rock Polish, 33: Supersonic, 38: Bite, 40: Roost, 42: Aerial Ace, 45: Take Down, 46: Gale Wind, 48: Stone Edge, 54: Hyper Beam.
- Evolution: None.
- TM/HM: TM02 Twister, TM04 Whirlwind, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM23 Dragon Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM43 Sky Attack, TM44 Rest, TM50 Substitute, HM02 Fly.

### 143. snorlax

- Starting: Headbutt, Amnesia, Rest.
- Level-up: 28: Stockpile, 35: Body Slam, 40: Facade, 41: Harden, 48: Double-Edge, 56: Hyper Beam.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM16 Pay Day, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM22 Solarbeam, TM24 Thunderbolt, TM25 Thunder, TM26 Earthquake, TM27 Fissure, TM29 Psychic, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM36 Selfdestruct, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM46 Psywave, TM48 Rock Slide, TM50 Substitute, HM03 Surf, HM04 Strength.

### 144. articuno

- Starting: Peck, Ice Beam.
- Level-up: 25: Icy Wind, 30: Ice Shard, 40: Ice Armor, 42: Icicle Spear, 45: Frost Breath, 48: Gale Wind, 50: Roost, 51: Blizzard, 55: Agility, 56: Flash Freeze, 60: Mist.
- Evolution: None.
- TM/HM: TM02 Twister, TM04 Whirlwind, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM43 Sky Attack, TM44 Rest, TM50 Substitute, HM02 Fly.

### 145. zapdos

- Starting: Thundershock, Drill Peck.
- Level-up: 35: Charge, 40: Shock Wave, 45: Thunderclap, 48: Gale Wind, 50: Roost, 51: Thunder, 55: Agility, 60: Light Screen.
- Evolution: None.
- TM/HM: TM02 Twister, TM04 Whirlwind, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM43 Sky Attack, TM44 Rest, TM45 Thunder Wave, TM50 Substitute, HM02 Fly, HM05 Flash.

### 146. moltres

- Starting: Peck, Fire Spin.
- Level-up: 35: Will-O-Wisp, 40: Incinerate, 48: Gale Wind, 50: Roost, 51: Leer, 52: Cauterize, 55: Agility, 60: Sky Attack.
- Evolution: None.
- TM/HM: TM02 Twister, TM04 Whirlwind, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM43 Sky Attack, TM44 Rest, TM50 Substitute, HM02 Fly.

### 147. dratini

- Starting: Wrap, Leer.
- Level-up: 10: Thunder Wave, 20: Agility, 30: Slam, 31: Coil, 36: Dragon Dance, 40: Dragon Rage, 50: Hyper Beam.
- Evolution: EV_LEVEL, 30, DRAGONAIR.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM23 Dragon Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM50 Substitute, HM03 Surf.

### 148. dragonair

- Starting: Wrap, Leer, Thunder Wave.
- Level-up: 10: Thunder Wave, 20: Agility, 34: Coil, 35: Slam, 40: Dragon Dance, 45: Dragon Rage, 55: Hyper Beam.
- Evolution: EV_LEVEL, 55, DRAGONITE.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM23 Dragon Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM50 Substitute, HM03 Surf.

### 149. dragonite

- Starting: Wrap, Leer, Thunder Wave, Agility.
- Level-up: 10: Thunder Wave, 20: Agility, 35: Slam, 40: Coil, 45: Dragon Rage, 48: Dragon Dance, 60: Hyper Beam.
- Evolution: None.
- TM/HM: TM02 Twister, TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM20 Rage, TM23 Dragon Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM50 Substitute, HM03 Surf, HM04 Strength.

### 150. mewtwo

- Starting: Confusion, Disable, Swift, Psychic.
- Level-up: 55: Psyshock, 60: Psych Up, 63: Barrier, 65: Mind Break, 66: Psychic, 70: Recover, 75: Mist, 81: Amnesia.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM16 Pay Day, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM22 Solarbeam, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM36 Selfdestruct, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM04 Strength, HM05 Flash.

### 151. mew

- Starting: Pound.
- Level-up: 10: Transform, 20: Mega Punch, 30: Metronome, 35: Psych Up, 40: Psychic, 41: Psyshock.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM02 Twister, TM03 Swords Dance, TM04 Whirlwind, TM05 Mega Kick, TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM16 Pay Day, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM23 Dragon Rage, TM24 Thunderbolt, TM25 Thunder, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM36 Selfdestruct, TM37 Egg Bomb, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM41 Softboiled, TM42 Dream Eater, TM43 Sky Attack, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM47 Explosion, TM48 Rock Slide, TM49 Tri Attack, TM50 Substitute, HM01 Cut, HM02 Fly, HM03 Surf, HM04 Strength, HM05 Flash.

### 152. blastoise_unique

- Starting: Tackle, Tail Whip, Bubble, Water Gun.
- Level-up: 8: Bubble, 15: Water Gun, 24: Bite, 30: Aqua Jet, 31: Withdraw, 38: Brine, 42: Skull Bash, 43: Scald, 46: Snipe Shot, 52: Hydro Pump.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf, HM04 Strength.

### 153. bulbasaur_unique

- Starting: Tackle, Growl.
- Level-up: 7: Leech Seed, 13: Vine Whip, 20: Poisonpowder, 25: Synthesis, 27: Razor Leaf, 34: Growth, 41: Sleep Powder, 42: Giga Drain, 48: Solarbeam.
- Evolution: EV_LEVEL, 16, IVYSAUR.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut.

### 154. chansey_unique

- Starting: Pound, Doubleslap.
- Level-up: 12: Tail Whip, 24: Sing, 30: Growl, 38: Minimize, 44: Defense Curl, 48: Light Screen, 54: Double-Edge.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM22 Solarbeam, TM24 Thunderbolt, TM25 Thunder, TM29 Psychic, TM30 Teleport, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM35 Metronome, TM37 Egg Bomb, TM38 Fire Blast, TM40 Skull Bash, TM41 Softboiled, TM44 Rest, TM45 Thunder Wave, TM46 Psywave, TM49 Tri Attack, TM50 Substitute, HM04 Strength, HM05 Flash.

### 155. charmander_unique

- Starting: Scratch, Growl.
- Level-up: 9: Ember, 15: Leer, 20: Flame Charge, 22: Rage, 28: Incinerate, 30: Slash, 38: Flamethrower, 46: Fire Spin.
- Evolution: EV_LEVEL, 16, CHARMELEON.
- TM/HM: TM01 Mega Punch, TM03 Swords Dance, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM23 Dragon Rage, TM28 Dig, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut, HM04 Strength.

### 156. ditto_happy

- Starting: Transform.
- Level-up: None.
- Evolution: None.
- TM/HM: None.

### 157. geodude_fighting

- Starting: Tackle.
- Level-up: 11: Defense Curl, 16: Rock Throw, 18: Rock Tomb, 21: Selfdestruct, 22: Rock Polish, 26: Harden, 30: Stone Press, 31: Earthquake, 36: Explosion, 40: Stone Edge.
- Evolution: EV_LEVEL, 25, GRAVELER.
- TM/HM: TM01 Mega Punch, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM35 Metronome, TM36 Selfdestruct, TM38 Fire Blast, TM44 Rest, TM47 Explosion, TM48 Rock Slide, TM50 Substitute, HM04 Strength.

### 158. goldeen_fighting

- Starting: Peck, Tail Whip.
- Level-up: 19: Supersonic, 22: Aqua Jet, 24: Horn Attack, 25: Flail, 30: Fury Attack, 34: Snipe Shot, 37: Waterfall, 45: Horn Drill, 54: Agility.
- Evolution: EV_LEVEL, 33, SEAKING.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM31 Mimic, TM32 Double Team, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf.

### 159. grimer_poison

- Starting: Pound, Disable.
- Level-up: 22: Pollution, 26: Stockpile, 30: Poison Gas, 31: Venoshock, 33: Minimize, 37: Sludge, 42: Harden, 48: Screech, 55: Acid Armor.
- Evolution: EV_LEVEL, 38, MUK.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM20 Rage, TM21 Mega Drain, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM34 Bide, TM36 Selfdestruct, TM38 Fire Blast, TM44 Rest, TM47 Explosion, TM50 Substitute.

### 160. ivysaur_erika

- Starting: Tackle, Growl, Leech Seed.
- Level-up: 7: Leech Seed, 13: Vine Whip, 22: Poisonpowder, 29: Synthesis, 30: Razor Leaf, 38: Growth, 46: Sleep Powder, 47: Giga Drain, 54: Solarbeam.
- Evolution: EV_LEVEL, 32, VENUSAUR.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut.

### 161. kakuna_rock_type

- Starting: Harden.
- Level-up: 7: Harden.
- Evolution: EV_LEVEL, 10, BEEDRILL.
- TM/HM: None.

### 162. marowak_unique

- Starting: Bone Club, Growl, Leer, Focus Energy.
- Level-up: 13: Tail Whip, 16: Headbutt, 17: Astonish, 25: Leer, 28: Wailing Cry, 33: Focus Energy, 41: Thrash, 48: Bonemerang, 55: Rage.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM04 Strength.

### 163. nidoking_unique

- Starting: Tackle, Horn Attack, Poison Sting, Thrash.
- Level-up: 8: Horn Attack, 12: Double Kick, 19: Poison Sting, 23: Thrash, 28: Poison Tail, 36: Venoshock, 40: Pierce, 41: Poison Fang, 55: Megahorn.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM16 Pay Day, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM26 Earthquake, TM27 Fissure, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM03 Surf, HM04 Strength.

### 164. nidoking_unique2

- Starting: Tackle, Horn Attack, Poison Sting, Thrash.
- Level-up: 8: Horn Attack, 12: Double Kick, 19: Poison Sting, 23: Thrash, 28: Poison Tail, 36: Venoshock, 40: Pierce, 41: Poison Fang, 55: Megahorn.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM15 Hyper Beam, TM16 Pay Day, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM26 Earthquake, TM27 Fissure, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM38 Fire Blast, TM40 Skull Bash, TM44 Rest, TM48 Rock Slide, TM50 Substitute, HM03 Surf, HM04 Strength.

### 165. nidoranm_unique

- Starting: Leer, Tackle.
- Level-up: 8: Horn Attack, 12: Double Kick, 17: Poison Sting, 20: Poison Tail, 23: Focus Energy, 28: Venoshock, 30: Fury Attack, 38: Horn Drill.
- Evolution: EV_LEVEL, 16, NIDORINO.
- TM/HM: TM06 Toxic, TM07 Horn Drill, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM14 Blizzard, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute.

### 166. omanyte_unique

- Starting: Water Gun, Withdraw.
- Level-up: 24: Rock Tomb, 28: Rock Polish, 32: Brine, 34: Horn Attack, 38: Stone Press, 39: Leer, 46: Spike Cannon, 50: Stone Edge, 53: Hydro Pump.
- Evolution: EV_LEVEL, 40, OMASTAR.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM03 Surf.

### 167. onix_brock

- Starting: Tackle, Screech.
- Level-up: 15: Bind, 19: Rock Throw, 20: Rock Tomb, 25: Rage, 26: Rock Polish, 30: Coil, 33: Slam, 34: Stone Press, 43: Harden, 44: Stone Edge.
- Evolution: None.
- TM/HM: TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM20 Rage, TM26 Earthquake, TM27 Fissure, TM28 Dig, TM31 Mimic, TM32 Double Team, TM34 Bide, TM36 Selfdestruct, TM40 Skull Bash, TM44 Rest, TM47 Explosion, TM48 Rock Slide, TM50 Substitute, HM04 Strength.

### 168. raichu_unique

- Starting: Growl, Thundershock.
- Level-up: 11: Tail Whip, 13: Thunder Wave, 25: Slam, 26: Charge, 31: Thunderbolt, 34: Shock Wave, 42: Thunderclap, 46: Thunder, 55: Light Screen.
- Evolution: None.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM16 Pay Day, TM17 Submission, TM19 Seismic Toss, TM20 Rage, TM24 Thunderbolt, TM25 Thunder, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM39 Swift, TM40 Skull Bash, TM44 Rest, TM45 Thunder Wave, TM50 Substitute, HM05 Flash.

### 169. squirtle_unique

- Starting: Tackle, Tail Whip.
- Level-up: 8: Bubble, 15: Water Gun, 22: Bite, 23: Aqua Jet, 28: Withdraw, 30: Brine, 34: Scald, 35: Skull Bash, 38: Snipe Shot, 42: Hydro Pump.
- Evolution: EV_LEVEL, 16, WARTORTLE.
- TM/HM: TM01 Mega Punch, TM05 Mega Kick, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM17 Submission, TM18 Counter, TM19 Seismic Toss, TM20 Rage, TM28 Dig, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM03 Surf, HM04 Strength.

### 170. tangela_erika

- Starting: Constrict, Bind.
- Level-up: 27: Absorb, 29: Vine Whip, 32: Poisonpowder, 33: Synthesis, 36: Stun Spore, 39: Sleep Powder, 42: Giga Drain, 45: Slam, 49: Growth.
- Evolution: None.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM31 Mimic, TM32 Double Team, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut.

### 171. tentacool_big

- Starting: Acid.
- Level-up: 7: Supersonic, 13: Wrap, 18: Poison Sting, 22: Water Gun, 24: Coil, 27: Constrict, 28: Venoshock, 32: Brine, 33: Barrier, 40: Screech, 48: Hydro Pump.
- Evolution: EV_LEVEL, 30, TENTACRUEL.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM09 Take Down, TM10 Double-Edge, TM11 Bubblebeam, TM12 Water Gun, TM13 Ice Beam, TM14 Blizzard, TM20 Rage, TM21 Mega Drain, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM40 Skull Bash, TM44 Rest, TM50 Substitute, HM01 Cut, HM03 Surf.

### 172. venusaur_erika

- Starting: Tackle, Growl, Leech Seed, Vine Whip.
- Level-up: 7: Leech Seed, 13: Vine Whip, 22: Poisonpowder, 30: Razor Leaf, 33: Synthesis, 43: Growth, 50: Giga Drain, 55: Sleep Powder, 65: Solarbeam.
- Evolution: None.
- TM/HM: TM03 Swords Dance, TM06 Toxic, TM08 Body Slam, TM09 Take Down, TM10 Double-Edge, TM15 Hyper Beam, TM20 Rage, TM21 Mega Drain, TM22 Solarbeam, TM31 Mimic, TM32 Double Team, TM33 Reflect, TM34 Bide, TM44 Rest, TM50 Substitute, HM01 Cut.

## Variant availability and inheritance

Each new species copies the source's stats, starting/level-up/TM/HM moves, growth, experience yield, cry, Pokédex description, palette, party icon, back sprite and evolution destinations. Evolutions still lead to the original species (for example, unique Bulbasaur evolves into the original Ivysaur). These are new species IDs, not replacements or a new evolution family. Display names are shortened to fit the game's 10-character limit; the filenames below identify the full variant.

Type overrides: Fighting Geodude and Fighting Goldeen are pure Fighting; Rock Kakuna is pure Rock; Poison Grimer remains pure Poison. All other types match their sources. Big Tentacool has catch rate 60 instead of the normal 190; other catch rates are copied.

## Where to find them

Trainer variants are exclusive to the listed trainers. The requested habitats use a separate unbiased 1-in-100 roll per eligible variant, not the original 3/256 slot approximation. When habitats overlap, each variant keeps its own 1% share. The chance is per generated encounter/bite, not per step or rod cast. Ordinary encounter weights fill the remaining share.

Unique Omanyte appears only on the two Rock Tunnel floors. Unique Squirtle appears only in grass on Routes 24/25. Cerulean City and Safari Zone surfing pools remain unchanged from the original version. Fishing variants use Good/Super Rod pools where eligible; Old Rod remains Magikarp-only. Land/surf and rod pools are checked separately, so Fighting Goldeen no longer appears in Route 12 grass. Tentacool and Geodude variants follow every matching original habitat; Kakuna follows the version-specific original land tables; Nidoran follows both genders' original land tables. Safari's postgame randomization runs before the unique roll so it does not reduce the new 1% chances. Repel still works normally.

Unique Marowak and the second Nidoking retain their previous rarest-slot encounters (3/256, about 1.2%); their locations were not changed in this update.

| Dex | Variant file | In-game name | Availability |
| --- | --- | --- | --- |
| 152 | blastoise_unique | BLASTOISEU | Rival with Squirtle: Silph Co., Route 22, Champion (levels 40/53/65); trainer-only |
| 153 | bulbasaur_unique | BULBASAURU | Viridian Forest: 1% land encounters (level 6) |
| 154 | chansey_unique | CHANSEY U | Cerulean Cave, all floors: 1% land encounters (level 55) |
| 155 | charmander_unique | CHARMANDRU | Mt. Moon, all floors: 1% land encounters (level 10) |
| 156 | ditto_happy | HAPPYDITTO | Pokémon Mansion on Cinnabar, all floors: 1% land encounters (level 30) |
| 157 | geodude_fighting | F.GEODUDE | Every land/surf table containing normal Geodude: 1% |
| 158 | goldeen_fighting | F.GOLDEEN | Every habitat/rod pool containing normal Goldeen: 1% |
| 159 | grimer_poison | P.GRIMER | Koga (level 39) |
| 160 | ivysaur_erika | E.IVYSAUR | Erika (level 33) |
| 161 | kakuna_rock_type | R.KAKUNA | Every land table containing normal Kakuna: 1% |
| 162 | marowak_unique | MAROWAK U | victoryroad2 (level 40, grass/cave, rarest slot) |
| 163 | nidoking_unique | NIDOKING U | Giovanni, Viridian Gym (level 47) |
| 164 | nidoking_unique2 | NIDOKING 2 | safarizone1 (level 30, grass/cave, rarest slot) |
| 165 | nidoranm_unique | NIDORAN U | Every land table containing either Nidoran gender: 1% |
| 166 | omanyte_unique | OMANYTE U | Rock Tunnel, both floors: 1% land encounters (level 20) |
| 167 | onix_brock | B.ONIX | Brock (level 15) |
| 168 | raichu_unique | RAICHU U | Lt. Surge (level 25) |
| 169 | squirtle_unique | SQUIRTLE U | Routes 24 and 25: 1% grass encounters (level 10) |
| 170 | tangela_erika | E.TANGELA | Erika (level 29) |
| 171 | tentacool_big | BIGTENTACL | Every habitat/rod pool containing normal Tentacool: 1%; catch rate 60 (normal 190) |
| 172 | venusaur_erika | E.VENUSAUR | Erika (level 33) |


## Source and download references

- Current patch download: https://github.com/willibab89-dev/Purple-Iron/actions/runs/42144365247 — artifact `pokemon-move-patch-6-bps`.
- Source snapshot: https://github.com/willibab89-dev/Purple-Iron/tree/56e3b5d
- Patch notes: `docs/MOVE-PATCH-1.md` through `docs/MOVE-PATCH-6.md`. Historical “remaining work” sections describe their own patch only; the patch-6 list above supersedes them.
- Approved original design: `docs/MOVE-OVERHAUL-PLAN.md`; accepted defaults: `docs/MOVE-PATCH-2-PLAN.md`. These are plans, not evidence that every listed effect is implemented.
- Current numeric truth: `data/moves.asm`, `data/baseStats/`, `data/evos_moves.asm`, `data/tms.asm`. Detailed custom effects live under `engine/battle/`.

Apply the matching BPS to an unmodified original ROM, not to an already patched one. Existing 172-species saves remain compatible; old 151-species saves do not. Back up saves and heal at a Pokémon Center after updating to refresh PP. Link play requires identical builds. No game code changed to produce this handoff.
