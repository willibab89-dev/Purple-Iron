# Walking and status balance changes

This cumulative patch includes all earlier nature, ability, sprite, species, move, encounter and trainer changes.

## Movement

Ordinary on-foot walking is **10% faster on average**, automatically, indoors and outdoors. Shin's existing B-to-run and bicycle speeds remain unchanged. Surfing, ledges, spinners, scripted movement and Cycling Road's special bicycle rules retain their existing behavior.

The player receives one extra native movement update per ten ordinary updates. Credit is deferred at the last update of a tile so the movement counter cannot underflow or skip a tile-boundary event. Eighty two-frame walking ticks now cover eleven tiles instead of ten: 160 frames instead of 176, a 10% speed increase. The boost uses the existing player-only movement updater; world frame delays, music, menus, NPC update cadence, collision and per-tile encounter/poison/step logic are unchanged. The fractional cadence is slightly uneven because movement updates are discrete.

## Paralysis

- Battle Speed is **50%** of its otherwise calculated value, rather than 25%.
- Full paralysis is **exactly 20%**, using the existing unbiased one-in-five battle roll also used for natural thawing. Values 250–255 are rejected, and 50 of the 250 accepted RNG outcomes block the action.
- Stage, nature and badge adjustments precede the Speed penalty. Integer division rounds down, with minimum Speed 1. Rebuilding stats never compounds the penalty.

## Poison and Toxic

Both reduce battle **Special to 25%** of its otherwise calculated value, rounded down with a minimum of 1. Because Gen 1 has a shared Special stat, this weakens both special offense and special defense.

Ordinary poison damage and Toxic's escalating HP damage remain intact. The Special penalty is applied when status is inflicted, on send-out, after leveling/recalculation and after relevant stat-stage changes. Poison Leaf, Poison Fang and other custom status paths use the same rules. Upgrading poison to Toxic does not apply another Special penalty.

Permanent underlying nature/stat values are not damaged. Critical hits retain the existing engine rule of using underlying stats and bypassing status stat penalties, as they already do for burn. Fixed-damage moves retain their existing behavior.

## Curing and compatibility

Cures rebuild stats from the nature-adjusted underlying values and current stages rather than multiplying a rounded-down value back up. This restores exact values, including odd stats, and retains boosts. Rest, status medicines, Full Restore, AI cures, Cauterize and Heal Bell use the updated paths; Haze already clears statuses and restores underlying stats.

Full Restore on a reserve Pokémon does not remove the active Pokémon's poison penalty or Toxic counter. Full Restore on the active Pokémon also clears its Toxic flag/counter.

No saved record layout changed. Existing nature-enabled saves remain compatible. The walking phase uses one volatile byte in previously unused WRAM padding and resets on map load. No additional stack space is consumed and no sprite assets changed.

## Verification

Both Red and Blue build. The new emulator harness checks walking cadence and boundary deferral, movement exclusions, all 250 accepted paralysis rolls on both sides plus rejection cases, Speed/Special rounding and minimums, repeated stat rebuilds, native stat-up effects, native poison infliction, exact cure restoration and actual Full Restore/Antidote use on active and reserve Pokémon. Updated regression expectations cover Electro Ball, Quiver Dance and other effects affected by the new penalties. Existing species, nature, ability, move, trainer, encounter, sprite and save checks remain in CI. BPS patches must reproduce both built ROMs byte for byte.
