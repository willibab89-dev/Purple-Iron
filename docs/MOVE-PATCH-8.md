# Move overhaul — patch 8

Cumulative Red/Blue BPS patches include all previous front sprites, 21 unique species and encounters, crit/freeze changes and move patches 1–7. This patch completes Roar, Whirlwind and automatic entry transformation for Ditto and Happy Ditto. The approved move overhaul is now complete: all 54 planned new moves are present, with 219 total move records including Struggle. Pokémon stat, learnset and TM balancing remains a separate future pass.

## Updating

Download `pokemon-move-patch-8-bps` from the successful GitHub Actions run. Apply the matching BPS to an unmodified original Red/Blue ROM, not a previously patched ROM. Existing 172-species saves remain compatible; no saved fields or existing WRAM addresses move. Old 151-species saves remain incompatible. Back up saves before updating. No new moves or learnset entries are added in this patch, and no Pokémon base stats change.

## Roar and Whirlwind

| Move | Type | Accuracy | PP | Priority |
| --- | --- | ---: | ---: | --- |
| Roar | Normal | 100 | 20 | Existing ordinary priority |
| Whirlwind | Flying | 85 | 20 | Existing ordinary priority |

In trainer battles, both force the target to switch to a uniformly selected unfainted reserve. They fail if there is no eligible reserve, the target has Substitute or Fly/Dig invulnerability, or the ordinary accuracy/evasion check fails. Target typing does not create a damaging-move immunity for these status moves. They do not deal damage or end a trainer battle.

The outgoing target's HP/status is synchronized to its roster. The incoming Pokémon uses the normal party loading, sprite, status-reset and entry routines. The target's pending action is cancelled; the incoming Pokémon cannot execute an attack selected for the outgoing one. The source spends its ordinary turn and PP. If the target already acted, no extra action is removed from a future round. These moves retain ordinary priority rather than adopting a later-generation negative priority; this is a balance choice available for the later review.

Forced switching bypasses voluntary Ingrain/Wrap switch restrictions. The departing Pokémon loses its volatile state, including Ingrain, Curse, Fire Spin, stages and focus boosts, and either participant leaving releases Wrap. The other active Pokémon retains its own independent residual conditions. There is no player response-switch prompt when the enemy is forced out. Ordinary response switches after an enemy faints now also check the existing voluntary Ingrain/Wrap restriction; forced replacements still bypass it.

Wild-battle Roar/Whirlwind retain Shin's original escape behavior and level-based rules. Teleport keeps its previous wild/trainer behavior. The new random forced-switch effect explicitly fails in link battles: no synchronized random replacement command has been added to the link protocol. Identical revisions are still required for any link play; this patch does not claim manual link testing.

Enemy scoring now recognizes trainer Roar/Whirlwind as usable when the player has an eligible reserve and discourages them when replacement is impossible. Teleport remains discouraged in trainer battles. Other AI heuristics remain approximate.

## Automatic Transform

Ordinary Ditto and Happy Ditto each get one free transformation attempt per entry, on either side of battle, once both active combatants and their send-out graphics are ready. It does not use a turn or PP, require choosing Transform, or cure status. This covers initial send-outs, voluntary replacements, replacements after fainting and forced replacements.

The attempt fails against:

- Either untransformed Ditto species, preventing Ditto-versus-Ditto order-dependent loops.
- A target that is already transformed.
- A target with Substitute or Fly/Dig invulnerability.

A failed attempt is still spent. An opponent switching, losing Substitute or landing does not cause another attempt. Ditto must leave and re-enter to try again. Haze does not reset this entry-attempt marker. Already transformed users are not automatically transformed again.

Successful transformation keeps the user's own current/max HP, level, major status and permanent identity. No Ditto HP boost is added: both species still have their existing 48/48/48/48/48 base stats. It copies the target's battle species, typing, moves, DVs, underlying non-HP stats and stat stages. Copied moves receive five PP; blank slots receive zero. Shin's existing copied-Transform-to-Struggle rule is retained. Underlying copied stats are rebuilt using the user's copied stages, own badge rules and own burn/paralysis penalties once, rather than inheriting the opponent's status penalty as well. Existing Gen 1 stage ratios and critical rules remain.

Party species, original DVs, stats, moves and PP are not overwritten by this temporary form. Ordinary HP/status synchronization still happens as before. Leaving the field restores original data through the normal replacement routines. Manually selecting Transform remains a normal turn-spending move with normal PP cost; the extra Ditto-only entry restrictions are not imposed on manual Transform.

## Shared Transform fixes

The shared routine now tests the target's actual Fly/Dig invulnerability, rather than inspecting the wrong side or an overwritten register. Original enemy DVs are backed up before setting the transformed flag, and a later manual transformation cannot overwrite that first backup with copied DVs. The wild-capture data reconstruction therefore uses the original Ditto/Happy Ditto species and DVs. Own HP/status remain untouched by both manual and automatic forms.

## State and validation

The entry-attempt marker uses bit 3 of each side's existing transient residual flags. A one-shot forced enemy selector uses bit 7 of the existing residual round byte and the existing transient scratch byte for the selected roster index; it is consumed before normal round-end processing. There are no extra WRAM allocations, save-layout changes, move IDs, TM changes or learnset changes beyond Whirlwind's requested Flying typing.

Both ROMs build. Automated PyBoy checks cover all 219 move records; both Ditto species on both sides with clear, sleep, poison, burn, freeze and paralysis states; original HP/party/PP preservation; copied five-PP moves and Transform-to-Struggle; copied stages and status-penalty recalculation; one-attempt exclusions and switch retry; repeated manual-transform DV preservation and wild capture-data reconstruction; real trainer replacement paths with presentation stubbed; reserve exclusion, fainted slots and uniform ordinal selection; rooted/cursed/wrapped target cleanup; pending-action cancellation, ordinary turn/PP cost and knockout return flags; incoming Ditto entry triggers; wild escape and unchanged trainer Teleport; blocked/invalid/link forced switches; and phazing AI eligibility. Previous species, save, encounter, crit, freeze and move suites remain in CI.

These are automated engine tests with presentation/controlled randomness stubbed where appropriate, not a full manual playthrough or link compatibility test. Packaging applies each BPS to the verified original ROM and compares the result byte for byte with the custom build. Downloads contain patches and guides only.

## Remaining work

No approved move-overhaul implementation remains outstanding. The next planned work is reviewing individual Pokémon, their stats, learning and TM compatibility, plus any new balance decisions from that review.
