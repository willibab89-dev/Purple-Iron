# Lapras, Ditto and Eevee family redesigns

Cumulative Red/Blue patches retain all earlier sprites, species, types, move effects and reviews. Counts remain 183 species and 228 moves. No moves, effects, animation assets, items or save fields are added.

## Stats and level-up moves

Stats below are HP / Attack / Defense / Speed / Special.

### Lapras

Stats: 130 / 85 / 80 / 60 / 95.

Starts: WATER_GUN, GROWL.

Level-up: 9: SING, 17: MIST, 25: BODY_SLAM, 33: CONFUSE_RAY, 41: ICE_BEAM, 49: HYDRO_PUMP.

### Ditto

Stats: 66 / 66 / 66 / 66 / 66.

Starts: TRANSFORM.

Level-up: None.

### Eevee

Stats: 55 / 55 / 50 / 55 / 65.

Starts: TACKLE, TAIL_WHIP.

Level-up: 8: SAND_ATTACK, 15: QUICK_ATTACK, 22: BITE, 29: FOCUS_ENERGY, 36: TAKE_DOWN, 43: DOUBLE_EDGE.

### Vaporeon

Stats: 130 / 65 / 60 / 65 / 110.

Starts: TACKLE, TAIL_WHIP, WATER_GUN.

Level-up: 8: SAND_ATTACK, 15: QUICK_ATTACK, 22: BITE, 29: SCALD, 36: ACID_ARMOR, 43: HAZE, 50: HYDRO_PUMP.

### Jolteon

Stats: 65 / 65 / 60 / 130 / 110.

Starts: TACKLE, TAIL_WHIP, THUNDERSHOCK.

Level-up: 8: SAND_ATTACK, 15: QUICK_ATTACK, 22: DOUBLE_KICK, 29: PIN_MISSILE, 36: THUNDER_WAVE, 43: SHOCK_WAVE, 50: THUNDER.

### Flareon

Stats: 65 / 60 / 130 / 65 / 110.

Starts: TACKLE, TAIL_WHIP, EMBER.

Level-up: 8: SAND_ATTACK, 15: QUICK_ATTACK, 22: BITE, 29: FIRE_SPIN, 36: FLAMETHROWER, 43: CAUTERIZE, 50: FIRE_BLAST.

## Roles and machine changes

Lapras keeps its stats and supportive sea-creature role. Sing and Body Slam supply alternative major statuses; Confuse Ray can coexist with either. Mist prevents stat drops rather than boosting defenses. Remove Icy Wind, Ice Shard, Ice Armor, Scald, Icicle Spear, Frost Breath, Dragon Dance and Flash Freeze leveling. Keep Surf, Brine, Ice Beam, Blizzard, Body Slam, Reflect, Rest, Strength, Psychic and Thunderbolt machines. Remove Thunder, Solar Beam, Dragon Rage, Horn Drill, Hyper Beam, Bide and Dream Eater. Scald remains unavailable; no immediate recovery or stat boosts are added.

Ordinary Ditto gains 66 in all five base stats, retaining automatic entry transformation, Transform-only moves and no machines. HP stays its own after transforming; other base stats mainly matter when transformation is blocked. The existing one-attempt-per-entry restrictions, copied five-PP moves, own HP/status/level retention and temporary copied non-HP stats/stages remain unchanged. Happy Ditto and Dittwo retain their own existing base headers rather than inheriting this ordinary-Ditto stat change.

Eevee keeps its stats and stone evolutions. Earlier Quick Attack and Bite improve training; later recoil moves reward delaying evolution. Remove Growl and Facade leveling. Keep Body Slam, Reflect, Swift, Skull Bash and Rest; add Double-Edge TM10 and Facade TM52. The same two machine options are available to all three reviewed evolutions. Each evolved form has a full natural learnset and immediate elemental starting attack.

Vaporeon retains its stats. Scald and Acid Armor support physical durability, with Haze as an emergency reset that removes its Defense boosts and cures the opponent's burn. Remove Aurora Beam, Facade and Mist leveling. Keep Surf, Scald, Brine, Ice Beam, Blizzard, Reflect, Rest, Body Slam, Swift and Skull Bash machines. Remove Hyper Beam; no immediate recovery or Special boost is added.

Jolteon retains its stats. Double Kick and Pin Missile use moderate Attack; Thunder Wave enables Shock Wave's guaranteed criticals and Thunder's status accuracy bypass. Remove Charge, Facade, Thunderclap and Agility leveling. Keep Thunderbolt, Thunder, Thunder Wave, Double Team, Reflect, Swift, Rest, Body Slam and Skull Bash machines. Remove Hyper Beam; no Agility, Special setup or immediate recovery is added.

Flareon uses the final approved defensive redesign: Attack 130→60 and Defense 60→130, with HP 65, Speed 65 and Special 110 unchanged. Its larger design is reflected in protective bulk, with special Fire attacks, Fire Spin residual pressure and Cauterize quarter-HP/status recovery. Flame Charge is removed to preserve its Speed limitation. Remove the earlier physical Smog/Double-Edge plan and all provisional Will-O-Wisp, Incinerate, Facade, Leer and Rage leveling. Keep inherited Body Slam, Facade, Double-Edge, Reflect, Swift, Skull Bash, Fire Blast and Rest machines. Remove Will-O-Wisp TM58 and Hyper Beam. No Defense or Special boosting is added. Fire Spin plus Cauterize is a strong defensive interaction to watch during playtesting.

Other machine permissions, shops and prices are unchanged. Custom variants retain individual stats, starts and machine masks; shared parent learnset pointers follow revised parent leveling. Previously learned moves remain known unless replaced normally.

## Updating and validation

Apply the matching BPS to an original unmodified English Red/Blue ROM. Existing 183-species saves retain the same layout; older 151/172/176-species saves require a fresh start. Existing party stats update on normal recalculation, such as leveling up.

The tuning registry contains 137 entries: all 136 original species through Flareon, plus Crobat. Existing tests verify exact stats/starts/learnsets, actual generated moves/PP, original/extra machine permissions and historical variants. The full species, sprite, encounter, save, move, crit and freeze regression suites remain included in both versions. Packaging applies each BPS to a verified original and compares byte for byte with the build.
