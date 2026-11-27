# Design document: implementation status

Compared the user-provided `Pasted text.txt` (SHA-256 `ffe58718e00c5239eebe74f1c6323eadf23422bb6977129ad550d127c85a8bb6`) against `unique-species` at commit `f7048e8`. This is a status review, not a change to game behavior. Strikethrough in the source was not used as proof that an item is complete. Earlier redesign notes can reflect decisions made after an older design draft; a difference is flagged for a decision, not treated as an instruction to revert it.

**Scope:** Species/pool presence and the named requests below were checked against the source or documented implementation. The full wording of every original-species ability, move, learnset, encounter, trainer roster, and graphic was not individually re-audited. Items marked “review” need a closer comparison or a user decision; they are not claimed complete.

## Still to implement

### Ability pools added since this review

The planned ability pools are now assigned and tested for Mareanie, Toxapex, Miltank, Sableye, Baltoy, Claydol, Larvitar, Pupitar, Tyranitar, Unique Blastoise, Erika's Ivysaur, Fighting Geodude, Rock Kakuna and Big Tentacool. Fighting Geodude's Shadow Boxing randomly raises Evasion or Speed after each punch, as clarified by the user. Brock's Onix, Giovanni's Nidoking, Koga's Grimer, Erika's Tangela and Venusaur, and Surge's Raichu have since received the user-specified Indomitable, Sinister, Recovery, Sharp Vines, Big Bloom and Discipline respectively. For the four unique variants with only one named ability, all five slots currently give that ability. Their remaining slots can be redesigned if more abilities are specified.

### Pokémon still without ability pools

Eleven of the 183 species have no pool, and the design document does not specify abilities for them:

- Dittwo.
- Unique Bulbasaur, Unique Chansey, Unique Charmander, Happy Ditto, Fighting Goldeen, Unique Marowak, the second Unique Nidoking, Unique Nidoran♂, Unique Omanyte and Unique Squirtle.

These variants do not automatically inherit their ordinary counterparts' pools. Their ability lists remain to be designed or explicitly chosen.

### Proposed species not in the current roster

The current build has 183 Pokédex species. These 16 named species from the document are not present as species IDs and need full integration, including graphics, stats, evolution, learnsets, encounters, Pokédex data and abilities:

- Garmic / Fangrir.
- Hoppip / Skiploom / Jumpluff.
- Tyker / Straigar.
- Umbreon.
- Phanpy / Donphan.
- Mareep / Flaaffy / Ampharos.
- Embear / Ursear / Volkuma.

The 183-species design uses 23 bytes per Pokédex bit field (184 bits); adding all 16 needs a capacity and save-compatibility plan, as well as sufficient internal species IDs and ROM space. Existing mechanics may be reusable, but the new species' slots and their exact variants need implementation and testing.

### New moves and machine distribution

The following proposed moves do not appear as named move records in the current move table:

1. **Protect** — including +4 priority, the stated consecutive-use success progression and resets; then assign its proposed TM compatibility.
2. **Head Smash** — the document specifies Normal, 100 power, 100 accuracy, 10 PP and one-third recoil; then distribute the TM.
3. **Mean Look** — Speed −1 plus the proposed fleeing restriction; then distribute the TM.
4. **Shock Fang** — 65 power, 95 accuracy, 15 PP, using Attack; add to Jolteon's learnset as specified.
5. **Magical Leaf** — the proposed always-hit Grass move and TM distribution.
6. **Last Sting** — the proposed 200-power self-KO move and Beedrill's level-65 learnset.
7. **Cotton Spore** — proposed −2 Speed move for the Hoppip family.
8. **Cotton Guard** — proposed +3 Defense move for the Hoppip family.
9. **Bulldoze** — proposed 60-power move with a 50% Speed-drop chance, including Miltank's proposed level-54 learnset.

The move **Fortify** is also not present under that name. An ability named Fortify exists, but that does not supply the proposed move.

### Other requests needing work or verification

- **Shiny rate:** Shiny detection, palettes and animation exist, but the current checker uses specific DVs; it is not an explicit 1% encounter roll. The level-100 Chansey lead has a separate rare shiny-attraction mechanism. Design whether shininess is independent of DVs and whether the optional stat/move/ability differences are desired.
- **Title:** The title-screen source still identifies Red/Blue Version; the requested Kantwo Version branding needs implementation or visual verification of the actual tiles.
- **Experience-bar color:** An experience bar exists; confirm its displayed color in-game before marking the requested blue change complete.
- **Additional Spaceworld trainer sprites and placements:** Trainer teams were reviewed, but that alone does not establish that the requested additional sprite variants and map placements were added. Audit assets and maps.
- **Diglett's Cave expansion:** The proposed maze, dead ends, items and trainers need a dedicated map audit and implementation if absent. Existing encounter work does not establish that the cave layout was expanded.
- **Day-care:** Existing automated checks cover move learning, experience, nature and ability metadata through day-care paths. The document does not say which older bug was meant, so its overall fix cannot be confirmed without identifying the symptom and testing that flow.
- **All Pokémon obtainable:** The availability report lists 173 obtainable, two postgame/gated, and eight trainer-only species. If “all Pokémon can be found” means the player can catch or obtain every species, the eight trainer-only unique variants still need player acquisition methods.

## Differences requiring a decision

- **Nature redesign:** The game implements 196 nameless natures using one positive/one negative attribute or two positive/two negative attributes, with 10% modifiers. The newer text asks for regular natures plus critical/accuracy/evasion combinations and “only +1 and −1 per nature,” while a later section asks for roughly 200 new ones. Decide which model and how stage-like wording should translate before changing the existing system.
- **Dragon Dance:** The top of the document asks for +2 Speed; its later move-change list specifies +1 Attack/+1 Speed, which is what the current compound-move table implements. Pick the intended version.
- **Swords Dance and Barrier:** The new requests add −1 Defense to Swords Dance and −1 Special to Barrier; their current move records use the ordinary +2 Attack and +2 Defense effects respectively. Confirm the new penalties. Rock Polish already uses +2 Speed.
- **Drill Peck PP:** The design and historical move documentation say 15 PP, but the current move table says 20 PP. Its defense-stage effect is separately documented as implemented. Check whether the PP change was intentional before changing it.
- **Rock Kakuna:** The design asks for Bug/Rock and 75/45/120/20/60 stats. The documented later redesign uses pure Rock and 65/45/120/20/50, with a different learnset and TMs. Its proposed five abilities are now assigned.
- **Larvitar line:** The design specifies Rock Larvitar/Pupitar and Rock/Dragon Tyranitar with new stats/learnsets; the later redesign documents Rock/Ground earlier forms and different stats/learnsets. Confirm whether this document supersedes that redesign. Their requested ability pools are now assigned; their proposed stats and learnsets still need a decision.
- **Baltoy/Claydol:** Both exist, but the proposed stats and learnsets differ from the documented later redesign; the design also asks for Levitate while that redesign explicitly excluded it. Their requested ability pools are now assigned.
- **Mareanie/Toxapex and Miltank:** The requested Pin Missile, Rock Throw, Rolling Kick, Bulldoze and Protect additions need review against the later documented learnset/TM removals and role decisions.
- **Unique Blastoise, Brock's Onix, Surge's Raichu and Big Tentacool:** Compare the proposed stat/move changes with their existing independently reviewed variants before changing them. Gigantism is now assigned.
- **Terrifying:** Aerodactyl currently lowers the opponent's Defense once per battle. Tyranitar now lowers Defense on each entry, while Fangrir's proposed version says Attack instead of Defense. Confirm Fangrir's intended rules when adding it.
- **Other same-name abilities:** Treat names as hints, not proof of identical behavior; the document has differences such as contact versus physical triggers and different percentages. Match each species' exact wording during implementation.

## Already present, subject to detailed verification

- Ability pools for the original 151, Crobat and the 20 additional species listed above, with five slots each; the five slots repeat the sole specified ability for Articuno, Zapdos, Moltres, Mewtwo and Mew. See [EARLY-SPECIES-ABILITIES.md](EARLY-SPECIES-ABILITIES.md). This establishes registration and prior tests, not a fresh line-by-line audit of all design wording.
- The 21 unique variants and 11 additional species are in the 183-species build, including Crobat. Their presence does not imply their requested ability pools are present.
- Broad move overhaul and the ten listed extra TMs, route encounter redesign, regular-trainer review, Gym and League changes/rematches, curated item pools, and 196-nature system. See the corresponding move-patch, encounter, trainer, loot and nature documents in this directory.
- Badge boosts at 5%, Ice resistance to Ground, Poison no longer super-effective against Bug, the listed original-species type changes, faster walking, and the stated paralysis/poison/freeze changes. See [BADGE-BOOSTS.md](BADGE-BOOSTS.md), [TYPE-CHART-CHANGES.md](TYPE-CHART-CHANGES.md), [TYPE-CHANGES.md](TYPE-CHANGES.md), and [STATUS-AND-WALKING-CHANGES.md](STATUS-AND-WALKING-CHANGES.md).
- The game has an experience bar and shiny presentation, but the requested blue color and 1% shiny generation respectively remain to be verified/changed as described above.

Known documented limitation: Porygon's Trace copies an ability on entry, but bonuses baked into stored HP, Speed or PP do not dynamically apply when copied. See [EARLY-SPECIES-ABILITIES.md](EARLY-SPECIES-ABILITIES.md).
