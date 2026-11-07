# Dratini, Mewtwo and Mew redesigns

Cumulative Red/Blue patches retain every earlier sprite, species, type change, move effect and family review. Counts remain 183 species, now with 230 move records. All five reviewed species keep their stats. No item, animation asset or save field is added.

## Outrage

New move 230: Dragon, special, 90 power, 100 accuracy, 10 PP, Thrash animation. Uses the current Thrash attack-lock duration and ending-confusion behavior. Continuation paths explicitly preserve Outrage's ID instead of substituting Normal-type Thrash. The existing type/power/effect record remains Dragon/90 throughout, and PP is spent only on initial use. Interruptions follow current Thrash behavior. Dragon Dance raises its Speed but not its special damage.

Old move IDs remain intact. Outrage is included in Metronome's eligible pool and is listed for the deferred final distribution review; other earlier species do not receive it in this patch.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special. RAZOR_WIND is the internal constant for Twister.

### Dratini

Stats: 41 / 64 / 45 / 50 / 50.

Starts: WRAP, LEER.

Level-up: 10: THUNDER_WAVE, 18: RAZOR_WIND, 26: DRAGON_RAGE, 34: SLAM, 42: COIL.

### Dragonair

Stats: 61 / 84 / 65 / 70 / 70.

Starts: WRAP, LEER, THUNDER_WAVE.

Level-up: 10: THUNDER_WAVE, 18: RAZOR_WIND, 26: DRAGON_RAGE, 34: SLAM, 42: COIL.

### Dragonite

Stats: 91 / 134 / 95 / 80 / 100.

Starts: WRAP, LEER, THUNDER_WAVE.

Level-up: 10: THUNDER_WAVE, 18: RAZOR_WIND, 26: DRAGON_RAGE, 34: SLAM, 56: WING_ATTACK, 60: DRAGON_DANCE, 65: OUTRAGE.

### Mewtwo

Stats: 106 / 110 / 90 / 130 / 154.

Starts: CONFUSION, DISABLE, SWIFT.

Level-up: 55: PSYSHOCK, 63: BARRIER, 66: PSYCHIC_M, 70: RECOVER, 81: AMNESIA.

### Mew

Stats: 100 / 100 / 100 / 100 / 100.

Starts: POUND.

Level-up: 10: TRANSFORM, 20: MEGA_PUNCH, 30: METRONOME, 40: PSYCHIC_M, 50: MIMIC, 60: PSYCH_UP.

## Roles and compatibility

Dratini/Dragonair retain pure Dragon and evolve at 30/55; Dragonite retains Dragon/Flying. Twister and Dragon Rage improve the middle-stage progression. Coil at 42 belongs naturally to the serpentine stages; Dragonite can retain an inherited Coil but does not learn it naturally. Dragonite learns Wing Attack immediately after evolving, Dragon Dance at 60 and Outrage at 65. Remove Agility and natural Hyper Beam leveling. Add Double-Edge TM10 to all three. Keep existing Surf, Ice Beam, Blizzard, Thunderbolt, Thunder, Fire Blast, Reflect, Thunder Wave, Rest, Body Slam and Swift permissions; keep Dragonite's Fly, Aerial Ace, Strength and Hyper Beam. Remove Horn Drill from Dragonair/Dragonite and Roost TM51 from Dragonite. No Earthquake or Fighting additions. Critical hits ignore Attack setup stages; Dragon attacks remain special.

Mewtwo retains its exceptional stats. Remove Psychic from starting slots and teach it at 66. The proposed level-70 generated set is Psyshock, Barrier, Psychic and Recover; Amnesia arrives at 81. Psyshock uses Special against physical Defense; Barrier, Amnesia and Recover consume three slots when used together. Remove Psych Up, Mind Break and Mist leveling. Keep Psychic, Ice Beam, Blizzard, Thunderbolt, Thunder, Fire Blast, Reflect, Thunder Wave, Substitute, Rest, Hyper Beam, Body Slam, Mega Punch, Mega Kick, Submission, Counter, Seismic Toss, Mimic and Metronome machines. Remove Water Gun, Bubblebeam, Solar Beam, Pay Day, Self-Destruct and Dream Eater. Toxic remains unavailable. No further capabilities or stat boosts are added.

Mew keeps 100 in all stats and universal existing original/extra TM/HM compatibility. Transform, Metronome, Mimic and Psych Up establish its adaptable identity. Remove Psyshock leveling and move Psych Up to 60. Transform is still manual: Mew does not gain Ditto's automatic entry transformation. Universal machine access does not automatically teach every new move.

Other permissions, shops and prices remain unchanged. Custom variants retain individual headers and machine masks; shared parent learnset pointers follow revised parent lists.

## Deferred final distribution review

FINAL-MOVE-DISTRIBUTION-REVIEW.md remains pending until remaining species work is finished, as requested. Outrage has been added to its list of moves introduced during species reviews. This patch does not perform that review or redistribute newer moves across older reviewed Pokémon.

## Updating and validation

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain the same layout; older 151/172/176-species saves require a fresh start. Already learned moves are not automatically removed.

The tuning registry now contains 152 entries: all original 151 species, plus Crobat. Existing tests check exact stats/starts/learnsets, actual generated moves/PP, original/extra machine permissions and historical variants. Outrage tests compare real lock histories with Thrash on both sides, verify move/type/power and one-PP retention, ending confusion, Ghost damage, sleep/freeze/paralysis interruptions, misses and SRAM retention. All previous species, sprite, encounter, save, move, crit and freeze regressions remain included. Packaging applies both BPS patches to verified originals and compares byte for byte with the builds.
