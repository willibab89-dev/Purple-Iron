# Regular trainer teams — implemented

The approved [before/after roster list](REGULAR-TRAINER-PROPOSALS.md) and [spreadsheet](REGULAR-TRAINER-PROPOSALS.csv), including the level reductions approved at proposal commit `0e6ba04`, are now implemented in both versions.

## Changes

- Reviewed 313 regular stored teams: 281 changed and 32 retained.
- Expanded 183 teams. Adding one Pokémon lowers every proposed party member by one level; adding two lowers every proposed party member by two levels. Teams that do not grow retain their proposed levels.
- Small teams fall from 187 to 17: six solo specialists and eleven pairs. Most teams now have three Pokémon; stronger late-game trainers often have four.
- Regular opposing party slots rise from 752 to 981. Across all 361 stored teams, including protected bosses, there are now 1,178 entries.
- Removed repeated filler species except the deliberate six-Magikarp fisherman. Avoided fresh Harden-only cocoons and attackless natural movesets. Regular parties use their current natural moves, with no new custom overrides.
- Included selected Mareanie, Toxapex, Miltank, Sableye, Baltoy, Claydol and Pupitar where they fit the trainer. No legendary or trainer-exclusive unique variant was added to a regular team.

Examples: the lone level-14 Spearow trainer on Route 3 now has Spearow/Rattata/Mankey at level 12; the lone level-25 Geodude trainer in Rock Tunnel now has Graveler/Onix/Machop at level 23. The requested reductions also apply to evolved species; some NPC evolutions consequently appear below player evolution thresholds. Existing trainer data supports this.

## Preserved scope

All 48 excluded boss records are unchanged: Gym Leaders, Elite Four, rivals/Champion, Giovanni’s story fights, Oak, Silph Chief, Fuji, Seiga, Red, the Dojo master and Janine. All 63 previously reviewed or preserved exact boss movesets remain intact, including the scripted level-128 Fossil/MissingNo encounter. Ordinary Gym trainers are included in this patch.

AI, trainer items, scripts, encounter tables, species stats, moves, TMs and money formulas are unchanged. Lower party levels can lower the existing money payout naturally. This patch retains all prior changes, including the route encounter redesign and 5% badge stat boosts. Species count remains 183; current 183-species saves remain compatible.

## Verification and balance

The compiled-party regression loads all 361 teams in each version through ReadTrainer. It verifies every regular and protected roster, levels, party size, natural damaging moves, PP, move legality, absence of duplicate nonzero moves, 63 exact boss sets and bounded special-move overrides. The implementation manifest is data/regular_trainer_review.json; the prior boss-moves fixture now tracks the updated roster checksum and count.

Both cumulative BPS patches must round-trip to their built ROMs byte for byte before publication, and the full GitHub battle/species regression suite must pass. The larger teams still increase route length and can increase total experience despite the level reductions. Regional playtesting remains useful, especially Route 3, Rock Tunnel and Pokémon Tower; these automated checks verify correct implementation rather than proving the difficulty curve.
