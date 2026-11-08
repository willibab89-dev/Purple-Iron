# Mew diploma gate and availability overview corrections

Cumulative Red/Blue patches retain all previous sprites, species, stats, moves, TMs, encounters and trainer changes. Species count remains 183 and move count remains 236 including Struggle. Existing 183-species saves remain compatible.

## Enforced acquisition requirement

Mew's ordinary Cerulean Cave B1F encounter is now correctly locked behind obtaining the diploma for the original 150 non-Mew species.

- Before the diploma: that slot produces level-70 Ditto.
- After the diploma: the same slot produces level-70 Mew.
- Cerulean Cave remains post-Champion. Location, encounter slots, weights and custom replacement rates are unchanged.

The old routine changed the selected-species field before battle but left the actual enemy-species field as Mew when wIsInBattle was still zero. The fix synchronizes those fields for a pending or active wild Mew encounter. It preserves non-Mew encounters, trainer-class data and the existing randomized-trainer behavior. No new RNG calls, save fields or event flags are introduced.

The existing 1% unique-Chansey replacement still applies. The conditional Mew/Ditto slot is approximately 1.16% after that custom pool. Ditto's ordinary automatic entry transformation behavior is unchanged. Existing party/box Pokémon are not removed or migrated; the restriction applies to newly generated encounters.

## Availability overview updates

The Markdown, CSV and searchable HTML now document:

- The conditional level-70 Ditto fallback before the diploma.
- Mt. Moon's Helix/Dome fossil choice and Pewter Museum's Old Amber source.
- Post-Champion purchases of Dome Fossil, Helix Fossil and Old Amber from Celadon Department Store 3F, followed by level-30 revival at Cinnabar Lab.
- Fishing requires facing valid water from land; fishing while surfing is blocked.
- Starter, Dojo and fossil choices next to the relevant entries.

The overview still covers all 183 species: 175 have player-acquisition routes and eight variants are trainer-only. The proposed route redesign is not implemented by this patch.

## Verification

Both versions exercise the actual final Cerulean Cave encounter slot through TryDoWildEncounter and LoadEnemyMonData, with and without the diploma. The regression checks level 70, the unique-Chansey replacement, non-Mew species, active wild states, trainer-class preservation and randomized-trainer states. Existing species, sprite, learning, PP, TM, encounter, save, trainer and move-effect suites also run. BPS application is compared byte for byte with the built ROMs.

The availability CSV is checked for all 183 unique dex entries; the searchable HTML JavaScript is syntax-checked. All three overview formats are included with the patch artifact.

## Updating

Apply the matching BPS to an original, unmodified Red or Blue ROM. Back up saves. Existing 183-species saves remain compatible. No player Pokémon stats, types or moves change. Start from a save outside an active battle so a new encounter uses the repaired selector.
