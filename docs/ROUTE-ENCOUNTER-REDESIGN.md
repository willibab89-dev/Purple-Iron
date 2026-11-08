# Route encounter redesign

Implemented on top of all existing species, moves, trainers and sprite changes. Current 183-species saves remain compatible.

Most routes now offer rare finds alongside their common residents. Meowth progresses from 5% on Route 1 to 14.78% on Route 5 and about 22–30% on Routes 7/8. Ponyta is 5% on Route 7, then 19.92% on Route 17. Eevee is 2% on Route 7 and 15.23% on Route 21 at level 30. Tangela is 5% on Route 15 and 19.53% on Route 21 at level 30. The existing Celadon Eevee gift is retained.

A single unbiased percent roll selects ordinary rares and existing variants together. Existing variant/additional-species percentages are preserved, including unique Squirtle at 1% on Routes 24/25, Miltank at 2% on Routes 14/15 and big Tentacool at 1% wherever eligible. Normal base-slot probabilities are multiplied by the remaining share; their very rare starter/opposite-version slots still exist but are slightly reduced where new rare pools overlap. Fishing, caves, Safari expansion, gifts and trainer parties are unchanged. No existing species loses its habitat: where a common-table species moves into a rare pool, that species remains present on the route.

Route 19/20/21 surfing now has Tentacool at levels 20–30, Tentacruel at 30/35 and Seaking at 35. Each coast also has its own 5% find: Horsea on Route 19 (27), Shellder on Route 20 (28), Staryu on Route 21 (30). Big Tentacool now inherits the local level-20 baseline; its 1% rate is unchanged. Mareanie remains a 5% Super Rod find on Routes 19/20.

The Pokédex AREA list for rule-based species combines rare locations, ordinary grass/surf habitats and applicable Super Rod habitats. Later common locations remain visible. This does not change AREA behavior for species without a rule-based encounter.

## Final normal encounter probabilities

Percentages are conditional on a generated encounter, assume no Repel/shiny-attraction override, and already include all applicable rare pools. Base slots use inclusive RNG thresholds, not rounded 20/15/10/5/1 weights. Rounding below may total slightly above/below 100%. Land means grass for these routes. Encounter frequency per step is unchanged. Both versions retain their habitat flavor; all listed shared rare finds are in both.

### Red

| Route / terrain | Final species odds and level range |
| --- | --- |
| 1 / land | PIDGEY: 47.50% (Lv 2–5); RATTATA: 47.50% (Lv 2–4); MEOWTH: 5.00% (Lv 4) |
| 2 / land | RATTATA: 39.05% (Lv 2–5); PIDGEY: 44.02% (Lv 3–5); WEEDLE: 14.93% (Lv 3–5); PIKACHU: 2.00% (Lv 5) |
| 3 / land | PIDGEY: 49.61% (Lv 6–8); SPEAROW: 34.77% (Lv 6–8); SANDSHREW: 5.08% (Lv 8); EKANS: 5.08% (Lv 8); JIGGLYPUFF: 5.47% (Lv 5–7) |
| 4 / land | RATTATA: 44.02% (Lv 8–12); SPEAROW: 34.07% (Lv 8–12); EKANS: 18.76% (Lv 8–12); BULBASAUR: 1.15% (Lv 10); CLEFAIRY: 2.00% (Lv 10) |
| 5 / land | ODDISH: 33.72% (Lv 13–16); PIDGEY: 24.25% (Lv 13–16); MEOWTH: 14.78% (Lv 14); MANKEY: 24.25% (Lv 12–16); GROWLITHE: 3.00% (Lv 13) |
| 6 / land | ODDISH: 37.48% (Lv 13–16); PIDGEY: 38.22% (Lv 13–16); MANKEY: 18.18% (Lv 12–16); SQUIRTLE: 1.11% (Lv 10); KRABBY: 5.00% (Lv 14) |
| 7 / land | PIDGEY: 27.61% (Lv 19–22); ODDISH: 18.53% (Lv 19); MANKEY: 15.26% (Lv 17–20); MEOWTH: 22.16% (Lv 18–20); GROWLITHE: 9.45% (Lv 18–20); EEVEE: 2.00% (Lv 18); PONYTA: 5.00% (Lv 18) |
| 8 / land | PIDGEY: 19.92% (Lv 18); MEOWTH: 29.69% (Lv 18–20); EKANS: 20.31% (Lv 17–19); GROWLITHE: 19.14% (Lv 16–18); MANKEY: 9.77% (Lv 20); VULPIX: 1.17% (Lv 15) |
| 9 / land | RATTATA: 38.22% (Lv 14–17); SPEAROW: 33.03% (Lv 13–17); EKANS: 23.75% (Lv 11–17); CUBONE: 5.00% (Lv 16) |
| 10 / land | VOLTORB: 35.16% (Lv 14–16); SPEAROW: 34.77% (Lv 13–17); EKANS: 25.00% (Lv 11–17); MAGNEMITE: 5.08% (Lv 17) |
| 11 / land | EKANS: 39.43% (Lv 12–15); SPEAROW: 34.07% (Lv 13–17); DROWZEE: 24.50% (Lv 9–15); FARFETCHD: 2.00% (Lv 15) |
| 12 / land | ODDISH: 37.48% (Lv 22–26); PIDGEY: 23.75% (Lv 25–27); VENONAT: 23.75% (Lv 24–26); FARFETCHD: 4.82% (Lv 25); GLOOM: 5.20% (Lv 28–30); SLOWPOKE: 5.00% (Lv 24) |
| 13 / land | ODDISH: 39.45% (Lv 22–26); PIDGEY: 19.92% (Lv 25); VENONAT: 25.00% (Lv 24–26); DITTO: 5.08% (Lv 25); FARFETCHD: 5.08% (Lv 27); GLOOM: 5.47% (Lv 28–30) |
| 14 / land | ODDISH: 34.07% (Lv 22–26); PIDGEY: 19.52% (Lv 26); DITTO: 14.93% (Lv 23); VENONAT: 19.14% (Lv 24–26); GLOOM: 4.98% (Lv 30); PIDGEOTTO: 5.36% (Lv 28–30); MILTANK: 2.00% (Lv 28) |
| 15 / land | ODDISH: 32.33% (Lv 22–26); DITTO: 18.53% (Lv 26); PIDGEY: 14.17% (Lv 23); VENONAT: 18.16% (Lv 26–28); GLOOM: 4.72% (Lv 30); PIDGEOTTO: 5.09% (Lv 28–30); MILTANK: 2.00% (Lv 28); TANGELA: 5.00% (Lv 27) |
| 16 / land | SPEAROW: 37.85% (Lv 20–22); RATTATA: 28.57% (Lv 18–22); DODUO: 23.38% (Lv 18–22); RATICATE: 5.20% (Lv 23–25); RHYHORN: 5.00% (Lv 24) |
| 17 / land | SPEAROW: 19.92% (Lv 20); PONYTA: 19.92% (Lv 28); RATICATE: 25.00% (Lv 25–27); DODUO: 24.61% (Lv 24–28); DODRIO: 5.08% (Lv 29); FEAROW: 5.47% (Lv 25–27) |
| 18 / land | SPEAROW: 37.85% (Lv 20–22); RATICATE: 19.30% (Lv 25–29); DODUO: 23.38% (Lv 24–28); FEAROW: 14.47% (Lv 25–29); LICKITUNG: 5.00% (Lv 28) |
| 19 / surf | TENTACOOL: 84.09% (Lv 20–30); TENTACRUEL: 8.81% (Lv 30–35); SEAKING: 1.10% (Lv 35); UNIQUE_TENTACOOL_BIG: 1.00% (Lv 20); HORSEA: 5.00% (Lv 27) |
| 20 / surf | TENTACOOL: 84.09% (Lv 20–30); TENTACRUEL: 8.81% (Lv 30–35); SEAKING: 1.10% (Lv 35); UNIQUE_TENTACOOL_BIG: 1.00% (Lv 20); SHELLDER: 5.00% (Lv 28) |
| 21 / land | PIDGEY: 19.92% (Lv 25); RATTATA: 19.92% (Lv 27); EEVEE: 15.23% (Lv 30); RATICATE: 14.06% (Lv 28–30); TANGELA: 19.53% (Lv 30); PIDGEOTTO: 11.33% (Lv 32) |
| 21 / surf | TENTACOOL: 84.09% (Lv 20–30); TENTACRUEL: 8.81% (Lv 30–35); SEAKING: 1.10% (Lv 35); UNIQUE_TENTACOOL_BIG: 1.00% (Lv 20); STARYU: 5.00% (Lv 30) |
| 22 / land | RATTATA: 42.23% (Lv 2–4); NIDORAN_M: 37.09% (Lv 2–4); SPEAROW: 9.55% (Lv 3–5); NIDORAN_F: 5.14% (Lv 3–4); UNIQUE_NIDORANM_UNIQUE: 1.00% (Lv 3); MANKEY: 5.00% (Lv 4) |
| 23 / land | EKANS: 18.93% (Lv 26); DITTO: 33.03% (Lv 33–43); SPEAROW: 14.47% (Lv 26); FEAROW: 23.75% (Lv 38–43); ARBOK: 4.82% (Lv 41); RHYDON: 5.00% (Lv 44) |
| 24 / land | WEEDLE: 18.53% (Lv 7); KAKUNA: 18.53% (Lv 8); PIDGEY: 18.89% (Lv 12–13); ODDISH: 18.16% (Lv 13–14); ABRA: 17.80% (Lv 8–12); BELLSPROUT: 1.09% (Lv 12); UNIQUE_KAKUNA_ROCK_TYPE: 1.00% (Lv 8); UNIQUE_SQUIRTLE_UNIQUE: 1.00% (Lv 10); PSYDUCK: 5.00% (Lv 12) |
| 25 / land | WEEDLE: 18.53% (Lv 8); KAKUNA: 18.53% (Lv 9); PIDGEY: 14.17% (Lv 13); ODDISH: 18.16% (Lv 13–14); ABRA: 13.80% (Lv 10–12); METAPOD: 4.72% (Lv 7); CATERPIE: 4.00% (Lv 8); CHARMANDER: 1.09% (Lv 10); UNIQUE_KAKUNA_ROCK_TYPE: 1.00% (Lv 9); UNIQUE_SQUIRTLE_UNIQUE: 1.00% (Lv 10); PSYDUCK: 5.00% (Lv 12) |

### Blue

| Route / terrain | Final species odds and level range |
| --- | --- |
| 1 / land | PIDGEY: 47.50% (Lv 2–5); RATTATA: 47.50% (Lv 2–4); MEOWTH: 5.00% (Lv 4) |
| 2 / land | RATTATA: 39.05% (Lv 2–5); PIDGEY: 44.02% (Lv 3–5); CATERPIE: 14.93% (Lv 3–5); PIKACHU: 2.00% (Lv 5) |
| 3 / land | PIDGEY: 49.61% (Lv 6–8); SPEAROW: 34.77% (Lv 6–8); SANDSHREW: 5.08% (Lv 8); EKANS: 5.08% (Lv 8); JIGGLYPUFF: 5.47% (Lv 5–7) |
| 4 / land | RATTATA: 44.02% (Lv 8–12); SPEAROW: 34.07% (Lv 8–12); SANDSHREW: 18.76% (Lv 8–12); BULBASAUR: 1.15% (Lv 10); CLEFAIRY: 2.00% (Lv 10) |
| 5 / land | BELLSPROUT: 33.72% (Lv 13–16); PIDGEY: 24.25% (Lv 13–16); MEOWTH: 14.78% (Lv 14); MANKEY: 24.25% (Lv 12–16); VULPIX: 3.00% (Lv 13) |
| 6 / land | BELLSPROUT: 37.48% (Lv 13–16); PIDGEY: 38.22% (Lv 13–16); MEOWTH: 18.18% (Lv 12–16); SQUIRTLE: 1.11% (Lv 10); KRABBY: 5.00% (Lv 14) |
| 7 / land | PIDGEY: 31.61% (Lv 19–22); BELLSPROUT: 28.70% (Lv 19–22); MEOWTH: 23.25% (Lv 17–20); VULPIX: 9.45% (Lv 18–20); EEVEE: 2.00% (Lv 18); PONYTA: 5.00% (Lv 18) |
| 8 / land | PIDGEY: 29.69% (Lv 18–20); MEOWTH: 29.69% (Lv 18–20); SANDSHREW: 20.31% (Lv 17–19); VULPIX: 19.14% (Lv 16–18); GROWLITHE: 1.17% (Lv 15) |
| 9 / land | RATTATA: 38.22% (Lv 14–17); SPEAROW: 33.03% (Lv 13–17); SANDSHREW: 23.75% (Lv 11–17); CUBONE: 5.00% (Lv 16) |
| 10 / land | VOLTORB: 35.16% (Lv 14–16); SPEAROW: 34.77% (Lv 13–17); SANDSHREW: 25.00% (Lv 11–17); MAGNEMITE: 5.08% (Lv 17) |
| 11 / land | SANDSHREW: 39.43% (Lv 12–15); SPEAROW: 34.07% (Lv 13–17); DROWZEE: 24.50% (Lv 9–15); FARFETCHD: 2.00% (Lv 15) |
| 12 / land | BELLSPROUT: 37.48% (Lv 22–26); PIDGEY: 23.75% (Lv 25–27); VENONAT: 23.75% (Lv 24–26); FARFETCHD: 4.82% (Lv 25); WEEPINBELL: 5.20% (Lv 28–30); SLOWPOKE: 5.00% (Lv 24) |
| 13 / land | BELLSPROUT: 39.45% (Lv 22–26); PIDGEY: 19.92% (Lv 25); VENONAT: 25.00% (Lv 24–26); DITTO: 5.08% (Lv 25); FARFETCHD: 5.08% (Lv 27); WEEPINBELL: 5.47% (Lv 28–30) |
| 14 / land | BELLSPROUT: 34.07% (Lv 22–26); PIDGEY: 19.52% (Lv 26); DITTO: 14.93% (Lv 23); VENONAT: 19.14% (Lv 24–26); WEEPINBELL: 4.98% (Lv 30); PIDGEOTTO: 5.36% (Lv 28–30); MILTANK: 2.00% (Lv 28) |
| 15 / land | BELLSPROUT: 32.33% (Lv 22–26); DITTO: 18.53% (Lv 26); PIDGEY: 14.17% (Lv 23); VENONAT: 18.16% (Lv 26–28); WEEPINBELL: 4.72% (Lv 30); PIDGEOTTO: 5.09% (Lv 28–30); MILTANK: 2.00% (Lv 28); TANGELA: 5.00% (Lv 27) |
| 16 / land | SPEAROW: 37.85% (Lv 20–22); RATTATA: 28.57% (Lv 18–22); DODUO: 23.38% (Lv 18–22); RATICATE: 5.20% (Lv 23–25); RHYHORN: 5.00% (Lv 24) |
| 17 / land | SPEAROW: 19.92% (Lv 20); PONYTA: 19.92% (Lv 28); RATICATE: 25.00% (Lv 25–27); DODUO: 24.61% (Lv 24–28); DODRIO: 5.08% (Lv 29); FEAROW: 5.47% (Lv 25–27) |
| 18 / land | SPEAROW: 37.85% (Lv 20–22); RATICATE: 19.30% (Lv 25–29); DODUO: 23.38% (Lv 24–28); FEAROW: 14.47% (Lv 25–29); LICKITUNG: 5.00% (Lv 28) |
| 19 / surf | TENTACOOL: 84.09% (Lv 20–30); TENTACRUEL: 8.81% (Lv 30–35); SEAKING: 1.10% (Lv 35); UNIQUE_TENTACOOL_BIG: 1.00% (Lv 20); HORSEA: 5.00% (Lv 27) |
| 20 / surf | TENTACOOL: 84.09% (Lv 20–30); TENTACRUEL: 8.81% (Lv 30–35); SEAKING: 1.10% (Lv 35); UNIQUE_TENTACOOL_BIG: 1.00% (Lv 20); SHELLDER: 5.00% (Lv 28) |
| 21 / land | PIDGEY: 19.92% (Lv 25); RATTATA: 19.92% (Lv 27); EEVEE: 15.23% (Lv 30); RATICATE: 14.06% (Lv 28–30); TANGELA: 19.53% (Lv 30); PIDGEOTTO: 11.33% (Lv 32) |
| 21 / surf | TENTACOOL: 84.09% (Lv 20–30); TENTACRUEL: 8.81% (Lv 30–35); SEAKING: 1.10% (Lv 35); UNIQUE_TENTACOOL_BIG: 1.00% (Lv 20); STARYU: 5.00% (Lv 30) |
| 22 / land | RATTATA: 42.23% (Lv 2–4); NIDORAN_F: 37.09% (Lv 2–4); SPEAROW: 9.55% (Lv 3–5); NIDORAN_M: 5.14% (Lv 3–4); UNIQUE_NIDORANM_UNIQUE: 1.00% (Lv 3); MANKEY: 5.00% (Lv 4) |
| 23 / land | SANDSHREW: 18.93% (Lv 26); DITTO: 33.03% (Lv 33–43); SPEAROW: 14.47% (Lv 26); FEAROW: 23.75% (Lv 38–43); SANDSLASH: 4.82% (Lv 41); RHYDON: 5.00% (Lv 44) |
| 24 / land | CATERPIE: 18.73% (Lv 7); METAPOD: 18.73% (Lv 8); PIDGEY: 19.09% (Lv 12–13); BELLSPROUT: 18.36% (Lv 13–14); ABRA: 17.99% (Lv 8–12); ODDISH: 1.10% (Lv 12); UNIQUE_SQUIRTLE_UNIQUE: 1.00% (Lv 10); PSYDUCK: 5.00% (Lv 12) |
| 25 / land | CATERPIE: 18.53% (Lv 8); METAPOD: 18.53% (Lv 9); PIDGEY: 14.17% (Lv 13); BELLSPROUT: 18.16% (Lv 13–14); ABRA: 13.80% (Lv 10–12); KAKUNA: 4.72% (Lv 7); WEEDLE: 4.00% (Lv 8); CHARMANDER: 1.09% (Lv 10); UNIQUE_KAKUNA_ROCK_TYPE: 1.00% (Lv 7); UNIQUE_SQUIRTLE_UNIQUE: 1.00% (Lv 10); PSYDUCK: 5.00% (Lv 12) |

## Verification

Both compiled versions are checked for the original route activation bytes, all common-slot endpoint rolls, every percent outcome through the actual grass/surf encounter routine, final distributions, level bands and retained starter/variant access. The existing species suite also exhausts every pool roll and checks the merged AREA lists. The full battle regression suite and BPS byte-for-byte round trips must pass before publication.
