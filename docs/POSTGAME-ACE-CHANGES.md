# Postgame final aces and second Lance — implemented

Each post-Hall-of-Fame Gym rematch now ends with the requested Pokémon at level 70. Other members keep their previous levels and relative order. Existing unique variants are retained: Surge uses unique Raichu and Erika uses her unique Venusaur. Brock uses standard Onix as in the prior rematch roster.

| Gym | Final Pokémon | Level |
| --- | --- | ---: |
| Brock | Onix | 70 |
| Misty | Starmie | 70 |
| Lt. Surge | Unique Raichu | 70 |
| Erika | Erika’s Venusaur | 70 |
| Koga | Arbok | 70 |
| Sabrina | Alakazam | 70 |
| Blaine | Magmar | 70 |

Second Lance’s team is now **Gyarados 88 → Dragonair 86 → Lapras 88 → Tyranitar 82 → Aerodactyl 80 → Dragonite 90**. His first-clear team and all other League teams are unchanged. The Champion’s existing +25-level rematch remains intact.

## Money and progression

The existing payout calculation uses the last party member’s level. Each unscaled postgame Gym team now prepares a **₽6,930** win payout (99 × 70), verified using the actual trainer money table and party-loading routine in both versions. A full circuit of seven wins totals ₽48,510 before Pay Day or spending. Money formulas and item prices were not changed. Optional level scaling can still raise levels/payouts as before.

The established loop is preserved: first Gym/League clears → post-Hall-of-Fame Gym rematches for money/training → harder League rematches. Unlock conditions, normal rematch prompts, Giovanni’s no-rematch behavior and save format are unchanged. First-challenge teams remain intact.

## Verification

All 375 stored teams and 1,270 roster entries load in both versions. Tests pin the seven final aces, preserve every other Gym member’s level/order, verify the revised second Lance levels, check all 177 exact boss sets plus actual send-outs/move PP, and exercise Hall-of-Fame gates, optional scaling/random modes, unchanged first clears, Champion branches and Giovanni. The actual prepared Gym payouts are checked as BCD 006930. Cumulative BPS round trips and the full regression suite must pass before publishing.

All previous changes and current 183-species save compatibility are retained. No new move effects, species, stats, AI, encounter changes or training-cost changes were introduced.
