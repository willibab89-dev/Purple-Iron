SECTION "Conditional damage and hybrid stats", ROMX, BANK[$35]

BankedPlayerDamageVars:
 call UnawareBegin
 call UnawarePlayerDamageVars
 jr UnawareFinish
BankedEnemyDamageVars:
 call UnawareBegin
 call UnawareEnemyDamageVars
UnawareFinish:
 push af
 push bc
 push de
 push hl
 call UnawareEnd
 pop hl
 pop de
 pop bc
 pop af
 jp StoreBankedDamageVars
UnawarePlayerDamageVars:
	call InfiltratorMaskScreens
	push af
	call IsConditionalDamageMove
	jr c, .custom
	call LegacyPlayerDamageVars
	jr InfiltratorFinishDamageVars
.custom
	call ConditionalDamageVars
	jr InfiltratorFinishDamageVars
UnawareEnemyDamageVars:
	call InfiltratorMaskScreens
	push af
	call IsConditionalDamageMove
	jr c, .custom
	call LegacyEnemyDamageVars
	jr InfiltratorFinishDamageVars
.custom
	call ConditionalDamageVars
InfiltratorFinishDamageVars:
	; Restore screen flags while preserving every result and the result flags.
	push af
	push bc
	push de
	push hl
	ld hl, sp + 9
	ld a, [hl]
	call InfiltratorRestoreScreens
	pop hl
	pop de
	pop bc
	pop af
	inc sp
	inc sp
	jr StoreBankedDamageVars

InfiltratorMaskScreens:
	abilitycall AbilityInfiltratorCheck
	ld a, [wAbilityCheckResult]
	and a
	ret z
	call InfiltratorTargetStatus3
	ld a, [hl]
	and (1 << HAS_REFLECT_UP) | (1 << HAS_LIGHT_SCREEN_UP)
	push af
	ld a, [hl]
	and $f9
	ld [hl], a
	pop af
	ret
InfiltratorRestoreScreens:
	and a
	ret z
	ld b, a
	call InfiltratorTargetStatus3
	ld a, [hl]
	or b
	ld [hl], a
	ret
InfiltratorTargetStatus3:
	ld hl, wEnemyBattleStatus3
	ld a, [H_WHOSETURN]
	and a
	ret z
	ld hl, wPlayerBattleStatus3
	ret

StoreBankedDamageVars:
	; Bankswitch uses BC to restore its bank. Export these two results through
	; scratch HRAM, which CalculateDamage immediately initializes again.
	ld a, b
	ld [H_MULTIPLICAND + 1], a
	ld a, c
	ld [H_MULTIPLICAND + 2], a
	ret

; BC is the full defensive stat; HL and DE are preserved for the caller.
AdjustPiercingBeakDefense:
	abilitycall AbilityPiercingBeakCheck
	ld a, [wAbilityCheckResult]
	and a
	ret z
	cp 2
	jr z, .horn
	push hl
	ld h, b
	ld l, c
	srl h
	rr l
	srl h
	rr l
	ld a, c
	sub l
	ld c, a
	ld a, b
	sbc h
	ld b, a
	or c
	jr nz, .done
	inc c
.done
	pop hl
	ret
.horn
	push hl
	push de
	push bc
	xor a
	ld [H_DIVIDEND], a
	ld [H_DIVIDEND + 1], a
	ld a, b
	ld [H_DIVIDEND + 2], a
	ld a, c
	ld [H_DIVIDEND + 3], a
	ld a, 5
	ld [H_DIVISOR], a
	ld b, 4
	call Divide
	ld a, [H_QUOTIENT + 2]
	ld [wAbilityTemp], a
	ld a, [H_QUOTIENT + 3]
	ld [wAbilityTemp + 1], a
	pop bc
	pop de
	ld hl, wAbilityTemp + 1
	ld a, c
	sub [hl]
	ld c, a
	dec hl
	ld a, b
	sbc [hl]
	ld b, a
	pop hl
	or c
	ret nz
	inc c
	ret

INCLUDE "engine/battle/legacy_damage_vars.asm"

ConditionalActorMove:
	ld hl, wPlayerMoveNum
	ld de, wPlayerMovePower
	ld a, [H_WHOSETURN]
	and a
	ret z
	ld hl, wEnemyMoveNum
	ld de, wEnemyMovePower
	ret

; Verify power/type as well as ID: confusion temporarily substitutes its own
; 40-power typeless attack without changing the selected move's ID.
IsConditionalDamageMove:
	call ConditionalActorMove
	ld a, [hl]
	ld hl, ConditionalDamageMoves
.loop
	ld b, [hl]
	inc b
	dec b
	jr z, .no
	cp b
	jr z, .found
	inc hl
	inc hl
	inc hl
	jr .loop
.found
	inc hl
	ld a, [de]
	cp [hl]
	jr nz, .no
	inc de
	inc hl
	ld a, [de]
	cp [hl]
	jr nz, .no
	scf
	ret
.no
	and a
	ret
ConditionalDamageMoves:
	db SHOCK_FANG, 65, ELECTRIC
	db VINE_CRUSH, 70, GRASS
	db ELECTRO_BALL, 40, ELECTRIC
	db WAKE_UP_SLAP, 60, NORMAL
	db AMBUSH, 50, BUG
	db RAZOR_WIND, 40, DRAGON
	db EGG_BOMB, 100, NORMAL
	db BRICK_BREAK, 70, FIGHTING
	db STOMP, 65, NORMAL
	db TAKE_DOWN, 60, NORMAL
	db DRILL_PECK, 80, FLYING
	db WATERFALL, 70, WATER
	db FACADE, 60, NORMAL
	db FLAIL, 1, NORMAL
	db BRINE, 50, WATER
	db INCINERATE, 50, FIRE
	db VENOSHOCK, 50, POISON
	db POLLUTION, 40, POISON
	db PUNISHMENT, 40, GHOST
	db SHOCK_WAVE, 40, ELECTRIC
	db POISON_TAIL, 40, POISON
	db FROST_BREATH, 60, ICE
	db ICE_SHARD, 50, ICE
	db PIERCE, 70, FIGHTING
	db STONE_PRESS, 50, ROCK
	db PSYSHOCK, 60, PSYCHIC
	db SNIPE_SHOT, 70, WATER
	db AERIAL_ACE, 60, FLYING
	db 0

ConditionalTargetStatus:
	ld hl, wEnemyMonStatus
	ld a, [H_WHOSETURN]
	and a
	ret z
	ld hl, wBattleMonStatus
	ret
ConditionalTargetMods:
	ld hl, wEnemyMonStatMods
	ld a, [H_WHOSETURN]
	and a
	ret z
	ld hl, wPlayerMonStatMods
	ret
ConditionalTargetStatus1:
	ld hl, wEnemyBattleStatus1
	ld a, [H_WHOSETURN]
	and a
	ret z
	ld hl, wPlayerBattleStatus1
	ret
ConditionalTargetStatus3:
	ld hl, wEnemyBattleStatus3
	ld a, [H_WHOSETURN]
	and a
	ret z
	ld hl, wPlayerBattleStatus3
	ret

; Carry = guaranteed critical hit. No RNG or stages are changed here.
ConditionalCriticalCheck:
	push hl
	push de
	push bc
	call IsConditionalDamageMove
	jr nc, .no
	call ConditionalActorMove
	ld a, [hl]
	cp FROST_BREATH
	jr z, .speed
	cp SHOCK_WAVE
	jr z, .paralysis
	cp POISON_TAIL
	jr nz, .no
	call ConditionalTargetStatus
	bit PSN, [hl]
	jr nz, .yes
	jr .no
.paralysis
	call ConditionalTargetStatus
	bit PAR, [hl]
	jr nz, .yes
	jr .no
.speed
	call ConditionalTargetMods
	inc hl
	inc hl
	ld a, [hl]
	cp 7
	jr c, .yes
.no
	and a
	jr .done
.yes
	scf
.done
	pop bc
	pop de
	pop hl
	ret

; Called after the ordinary Substitute / Fly / Dig checks. Immunity's earlier
; missed flag remains set; these moves never bypass invulnerability or typing.
ConditionalAccuracyCheck:
	push hl
	push de
	push bc
	abilitycall AbilityAntivirusSleepCheck
	ld a, [wAbilityCheckResult]
	and a
	jr nz, .immune
	abilitycall AbilitySteadfastDirectCheck
	ld a, [wAbilityCheckResult]
	and a
	jr nz, .immune
	abilitycall AbilityDampCheck
	ld a, [wAbilityCheckResult]
	and a
	jr nz, .immune
	abilitycall AbilityLevitateCheck
	ld a, [wAbilityCheckResult]
	and a
	jr nz, .immune
	abilitycall AbilityRubberSkinCheck
	ld a, [wAbilityCheckResult]
	and a
	jr z, .checkMove
.immune
	xor a
	ld [wDamage], a
	ld [wDamage + 1], a
	ld a, [wDamageMultipliers]
	and $80
	ld [wDamageMultipliers], a
	ld a, 1
	ld [wMoveMissed], a
	scf
	jr .done
.checkMove
	call ConditionalActorMove
	ld a, [hl]
	cp SNIPE_SHOT
	jr z, .yes
	cp AERIAL_ACE
	jr z, .yes
	cp ZAP_CANNON
	jr z, .zap
	cp THUNDER
	jr nz, .no
	call ConditionalTargetStatus
	ld a, [hl]
	and $7f
	jr nz, .yes
.no
	and a
	jr .done
.zap
	call ConditionalTargetStatus
	ld a, [hl]
	and 1 << PAR
	jr nz, .yes
	jr .no
.yes
	abilitycall AbilityEarthEaterOnHit
	scf
.done
	pop bc
	pop de
	pop hl
	ret

ConditionalDamageVars:
	xor a
	ld [wDamage], a
	ld [wDamage + 1], a
	ld [wCustomChanged], a ; bypass positive defensive stages?
	ld a, [H_WHOSETURN]
	ld [wCustomSide], a
	call ConditionalActorMove
	ld a, [hl]
	ld [wCustomMove], a
	ld a, [de]
	ld [wCustomChance], a ; effective power, kept out of the move record
	inc de
	ld a, [de]
	cp FIRE
	ld a, 0
	ld b, 1
	jr c, .indices
	ld a, 3
	ld b, 3
.indices
	ld [wCustomStat], a ; offensive stat index
	ld a, b
	ld [wCustomDelta], a ; defensive stat index
	ld a, [wCustomMove]
 cp SHOCK_FANG
 jr nz, .stonePress
 ; Shock Fang is Electric but uses physical Attack and Defense.
 xor a
 ld [wCustomStat], a
 inc a
 ld [wCustomDelta], a
 jr .power
.stonePress
	cp STONE_PRESS
	jr nz, .psyshock
	ld a, 1
	ld [wCustomStat], a
	jr .power
.psyshock
	cp PSYSHOCK
	jr nz, .bypass
	ld a, 1
	ld [wCustomDelta], a
	jr .power
.bypass
	cp DRILL_PECK
	jr z, .setBypass
	cp WATERFALL
	jr z, .setBypass
	cp PIERCE
	jr nz, .power
.setBypass
	ld a, 1
	ld [wCustomChanged], a
.power
	abilitycall AbilityStrongmanCheck
	ld a, [wAbilityCheckResult]
	and a
	jr z, .ordinaryOffense
	ld a, [wCustomStat]
	and a
	jr nz, .ordinaryOffense
	ld a, 3
	ld [wCustomStat], a
.ordinaryOffense
	call ConditionalPower
	call ConditionalOffense
	push hl
	call ConditionalDefense
	ld b, h
	ld c, l
	pop hl
	call AdjustPiercingBeakDefense
	call AbilityHugePowerScale
	; Identical Gen 1 joint stat scaling, with the existing minimum-one fix.
	ld a, h
	or b
	jr z, .scaled
	srl b
	rr c
	srl b
	rr c
	srl h
	rr l
	srl h
	rr l
	ld a, h
	or l
	jr nz, .defenseMinimum
	inc l
.defenseMinimum
	ld a, b
	or c
	jr nz, .scaled
	inc c
.scaled
	ld b, l
	ld a, [wCustomChance]
	ld d, a
	ld a, [H_WHOSETURN]
	and a
	ld a, [wBattleMonLevel]
	jr z, .level
	ld a, [wEnemyMonLevel]
.level
	ld e, a
	ld a, [wCriticalHitOrOHKO]
	and a
	jr z, .done
	sla e
.done
	ret

; Read a stat into HL. A = absolute side, B = 0 modified / 1 unmodified,
; C = index (Attack 0, Defense 1, Speed 2, Special 3).
ConditionalReadStat:
	and a
	jr nz, .enemy
	ld hl, wBattleMonAttack
	bit 0, b
	jr z, .offset
	ld hl, wPlayerMonUnmodifiedAttack
	jr .offset
.enemy
	ld hl, wEnemyMonAttack
	bit 0, b
	jr z, .offset
	ld hl, wEnemyMonUnmodifiedAttack
.offset
	ld a, c
	add a
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hli]
	ld l, [hl]
	ld h, a
	ret

ConditionalOffense:
	ld a, [wCustomStat]
	and a
	jr nz, .ordinary ; only physical Facade ignores the burn penalty
	ld a, [wCustomMove]
	cp FACADE
	jr nz, .ordinary
	ld a, [wCriticalHitOrOHKO]
	and a
	jr nz, .ordinary
	ld hl, wBattleMonStatus
	ld a, [wCustomSide]
	and a
	jr z, .burn
	ld hl, wEnemyMonStatus
.burn
	bit BRN, [hl]
	jp nz, ConditionalUnburnedAttack
.ordinary
	ld a, [wCustomStat]
	ld c, a
	ld a, [wCriticalHitOrOHKO]
	ld b, a
	ld a, [wCustomSide]
	jp ConditionalReadStat

ConditionalDefense:
	ld a, [wCustomDelta]
	ld c, a
	ld a, [wCriticalHitOrOHKO]
	ld b, a
	and a
	jr nz, .read
	ld a, [wCustomChanged]
	and a
	jr z, .read
	push bc
	call ConditionalTargetMods
	ld e, c
	ld d, 0
	add hl, de
	ld a, [hl]
	pop bc
	cp 8
	jr c, .read
	ld b, 1
.read
	ld a, [wCustomSide]
	xor 1
	call ConditionalReadStat
	ld a, [wCriticalHitOrOHKO]
	and a
	ret nz ; Gen 1 crits ignore screens, even on hybrid-stat moves.
	bit 0, b
	jr z, .screenCheck
	; Bypass removes stages, not the player's separate badge bonus.
	ld a, [wCustomSide]
	xor 1
	call ConditionalBadgeBoost
.screenCheck
	ld a, [wCustomMove]
	cp EGG_BOMB
	jr z, .screenBreak
	cp BRICK_BREAK
	jr nz, .ordinaryScreen
.screenBreak
	push hl
	call ConditionalTargetStatus1
	inc hl ; status2 follows status1
	bit HAS_SUBSTITUTE_UP, [hl]
	pop hl
	ret z ; intact screen is ignored only if the hit can actually remove it
.ordinaryScreen
	push hl
	call ConditionalTargetStatus3
	ld a, [wCustomDelta]
	cp 1
	jr nz, .special
	bit HAS_REFLECT_UP, [hl]
	jr .screen
.special
	bit HAS_LIGHT_SCREEN_UP, [hl]
.screen
	pop hl
	ret z
	add hl, hl
	jp ConditionalCap999

ConditionalCap999:
	ld a, h
	cp 999 / $100
	ret c
	jr nz, .cap
	ld a, l
	cp 999 % $100
	ret c
.cap
	ld hl, 999
	ret

; Facade ignores burn without mutating the stored Attack or approximating it
; by doubling the already-rounded burnt value. Match Shin's stage ratios/badges.
ConditionalUnburnedAttack:
	ld c, 0
	ld b, 1
	ld a, [wCustomSide]
	call ConditionalReadStat
	push hl
	ld hl, wPlayerMonAttackMod
	ld a, [wCustomSide]
	and a
	jr z, .stage
	ld hl, wEnemyMonAttackMod
.stage
	ld a, [hl]
	dec a
	add a
	ld c, a
	ld b, 0
	ld hl, ConditionalStatRatios
	add hl, bc
	pop de
	xor a
	ld [H_MULTIPLICAND], a
	ld a, d
	ld [H_MULTIPLICAND + 1], a
	ld a, e
	ld [H_MULTIPLICAND + 2], a
	ld a, [hli]
	ld [H_MULTIPLIER], a
	call Multiply
	ld a, [hl]
	ld [H_DIVISOR], a
	ld b, 4
	call Divide
	ld a, [H_QUOTIENT + 2]
	ld h, a
	ld a, [H_QUOTIENT + 3]
	ld l, a
	call ConditionalCap999
	ld a, h
	or l
	jr nz, .badge
	inc l
.badge
	ld c, 0
	ld a, [wCustomSide]
	jp ConditionalBadgeBoost

; HL = rebuilt stat, A = absolute side, C = stat index. Badge boosts are
; independent of stages; crits skip this helper entirely.
ConditionalBadgeBoost:
	and a
	ret nz
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	ret z
	ld a, [wOptions]
	bit 6, a
	jr z, .badgeAllowed
	ld a, [wIsInBattle]
	cp 1
	ret nz
.badgeAllowed
	ld a, c
	add a
	ld b, a
	ld a, [wObtainedBadges]
.shift
	inc b
	dec b
	jr z, .test
	srl a
	dec b
	jr .shift
.test
	and 1
	ret z
	ld d, h
	ld e, l
	call BadgeBoostFivePercent
	ld h, d
	ld l, e
	ret

; DE = stat (0..999); return min(999, stat + floor(stat / 20)) in DE.
; Shared with ordinary stat initialization/rebuilding. Preserve BC.
BadgeBoostFivePercent:
	push bc
	ld h, d
	ld l, e
	ld bc, 0
.divide20
	ld a, h
	and a
	jr nz, .subtract
	ld a, l
	cp 20
	jr c, .addBonus
.subtract
	ld a, l
	sub 20
	ld l, a
	ld a, h
	sbc 0
	ld h, a
	inc bc
	jr .divide20
.addBonus
	ld h, d
	ld l, e
	add hl, bc
	call ConditionalCap999
	ld d, h
	ld e, l
	pop bc
	ret

ConditionalStatRatios:
	db 25,100, 28,100, 33,100, 40,100, 50,100, 66,100
	db 1,1, 15,10, 2,1, 25,10, 3,1, 35,10, 4,1

; HL = current HP, DE = max HP. A = absolute side.
ConditionalHP:
	and a
	ld hl, wBattleMonHP
	ld de, wBattleMonMaxHP
	ret z
	ld hl, wEnemyMonHP
	ld de, wEnemyMonMaxHP
	ret

ConditionalPower:
	ld a, [wCustomMove]
	cp VINE_CRUSH
	jp z, .paralyzed
	cp ELECTRO_BALL
	jp z, ConditionalElectroBall
	cp WAKE_UP_SLAP
	jp z, .sleep
	cp AMBUSH
	jr z, .ambush
	cp RAZOR_WIND
	jr z, .twister
	cp FLAIL
	jp z, ConditionalFlail
	cp PUNISHMENT
	jp z, ConditionalPunishment
	cp FACADE
	jr z, .facade
	cp STOMP
	jr z, .stomp
	cp TAKE_DOWN
	jr z, .hp
	cp BRINE
	jr z, .hp
	cp INCINERATE
	jr z, .burn
	cp VENOSHOCK
	jr z, .poison
	cp ICE_SHARD
	jr z, .freeze
	cp POLLUTION
	jp z, .water
	ret
.ambush
	callab SequenceTargetBelowHalf
	ret nc
	ld a, [wCustomChance]
	add 30
	ld [wCustomChance], a
	ret
.twister
	callab SequenceAirborneHit
	jr c, .double
	ret
.facade
	ld hl, wBattleMonStatus
	ld a, [wCustomSide]
	and a
	jr z, .statused
	ld hl, wEnemyMonStatus
.statused
	ld a, [hl]
	and $7f
	jr nz, .double
	ret
.stomp
	call ConditionalTargetStatus1
	bit CONFUSED, [hl]
	jr nz, .double
	ret
.hp
	ld a, [wCustomSide]
	xor 1
	call ConditionalHP
	ld a, [hli]
	ld l, [hl]
	ld h, a
	add hl, hl
	ret c ; invalid-overflow HP is certainly not below half
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	ld a, h
	cp b
	jr c, .double
	ret nz
	ld a, l
	cp c
	jr c, .double
	ret nz
	ld a, [wCustomMove]
	cp BRINE
	jr z, .double ; Brine includes exact half; Take Down is strictly below
	ret
.burn
	call ConditionalTargetStatus
	bit BRN, [hl]
	jr nz, .double
	ret
.poison
	call ConditionalTargetStatus
	bit PSN, [hl]
	jr nz, .double
	ret
.paralyzed
	call ConditionalTargetStatus
	bit PAR, [hl]
	jp nz, .double
	ret
.freeze
	call ConditionalTargetStatus
	bit FRZ, [hl]
	jr nz, .double
	ret
.sleep
	call ConditionalTargetStatus
	ld a, [hl]
	and SLP
	jp nz, .double
	ret
.water
	ld hl, wEnemyMonType
	ld a, [wCustomSide]
	and a
	jr z, .types
	ld hl, wBattleMonType
.types
	ld a, [hli]
	cp WATER
	jr z, .double
	ld a, [hl]
	cp WATER
	ret nz
.double
	ld a, [wCustomChance]
	add a
	ld [wCustomChance], a
	ret

ConditionalPunishment:
	call ConditionalTargetMods
	ld b, 6
	ld c, 40
.stat
	ld a, [hli]
	sub 7
	jr c, .next
	and a
	jr z, .next
	ld d, a
.add
	ld a, c
	add 20
	ld c, a
	cp 160
	jr nc, .cap
	dec d
	jr nz, .add
.next
	dec b
	jr nz, .stat
	ld a, c
	ld [wCustomChance], a
	ret
.cap
	ld a, 160
	ld [wCustomChance], a
	ret

ConditionalFlail:
	ld a, [wCustomSide]
	call ConditionalHP
	ld a, [hli]
	ld b, a
	ld a, [hl]
	ld c, a
	ld a, [de]
	ld h, a
	inc de
	ld a, [de]
	ld l, a
	push hl ; maximum HP
	xor a
	ld [H_MULTIPLICAND], a
	ld a, b
	ld [H_MULTIPLICAND + 1], a
	ld a, c
	ld [H_MULTIPLICAND + 2], a
	ld a, 48
	ld [H_MULTIPLIER], a
	call Multiply
	pop bc ; max HP, full 16 bits
	ld a, b
	or c
	jr z, .weak
	ld a, [H_PRODUCT + 1]
	ld [wCustomTargetHadSub], a ; transient pre-damage scratch, captured later
	ld a, [H_PRODUCT + 2]
	ld h, a
	ld a, [H_PRODUCT + 3]
	ld l, a
	ld d, 0
.divide
	ld a, d
	cp 48
	jr nc, .weak
	ld a, [wCustomTargetHadSub]
	and a
	jr nz, .subtract
	ld a, h
	cp b
	jr c, .ratio
	jr nz, .subtract
	ld a, l
	cp c
	jr c, .ratio
.subtract
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ld a, [wCustomTargetHadSub]
	sbc 0
	ld [wCustomTargetHadSub], a
	inc d
	jr .divide
.ratio
	ld a, d
	cp 2
	ld a, 200
	jr c, .store
	ld a, d
	cp 5
	ld a, 150
	jr c, .store
	ld a, d
	cp 10
	ld a, 100
	jr c, .store
	ld a, d
	cp 17
	ld a, 80
	jr c, .store
	ld a, d
	cp 33
	ld a, 40
	jr c, .store
.weak
	ld a, 20
.store
	ld [wCustomChance], a
	ret

; ReadMove is AI-only and reloads base data each time. Give its existing power
; heuristics current conditional power, especially Flail, without changing ROM
; records. Action-time GetCurrentMove reloads base data and recomputes conditions.
ConditionalAIPower:
	ld a, [H_WHOSETURN]
	push af
	ld a, 1
	ld [H_WHOSETURN], a
	call IsConditionalDamageMove
	jr nc, .done
	ld a, 1
	ld [wCustomSide], a
	ld a, [wEnemyMoveNum]
	ld [wCustomMove], a
	ld a, [wEnemyMovePower]
	ld [wCustomChance], a
	call ConditionalPower
	ld a, [wCustomChance]
	ld [wEnemyMovePower], a
.done
	pop af
	ld [H_WHOSETURN], a
	ret

; Compare current battle Speeds with bounded 16-bit subtraction. Do not multiply
; target Speed: four times a large Speed can overflow. Crits retain this bracket.
ConditionalElectroBall:
	ld a, [wCustomSide]
	ld b, 0
	ld c, 2
	ld [wAbilitySide], a
	callab AbilityOneSpeed
	push hl
	ld a, [wCustomSide]
	xor 1
	ld b, 0
	ld c, 2
	ld [wAbilitySide], a
	callab AbilityOneSpeed
	ld b, h
	ld c, l
	ld a, b
	or c
	jr nz, .targetReady
	inc c ; defensive zero-Speed guard
.targetReady
	pop hl
	ld d, 0
.loop
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	jr c, .select
	inc d
	ld a, d
	cp 4
	jr c, .loop
.select
	ld a, d
	ld e, a
	ld d, 0
	ld hl, .powers
	add hl, de
	ld a, [hl]
	ld [wCustomChance], a
	ret
.powers
	db 40, 60, 80, 120, 150

; Temporarily neutralize positive attacking stages when the defender has Unaware.
; Recalculation preserves burn, poison and badge effects; restore the battle
; stats and stages immediately after damage variables have been captured.
UnawareBegin:
 xor a
 ld [wUnawareActive], a
 abilitycall AbilityUnawareCheck
 ld a, [wAbilityCheckResult]
 and a
 ret z
 call UnawareActorMods
 ld de, wUnawareSaved
 ld a, [hl]
 ld [de], a
 cp 8
 jr c, .attackDone
 ld [hl], 7
.attackDone
 inc de
 inc hl
 inc hl
 inc hl
 ld a, [hl]
 ld [de], a
 cp 8
 jr c, .specialDone
 ld [hl], 7
.specialDone
 ; Eight consecutive combat stats begin with Attack.
 inc de
 call UnawareActorStats
 ld b, 8
.save
 ld a, [hli]
 ld [de], a
 inc de
 dec b
 jr nz, .save
 ld a, 1
 ld [wUnawareActive], a
 ld a, [wCustomSide]
 push af
 ld a, [H_WHOSETURN]
 ld [wCustomSide], a
 callab CustomRecalculate
 pop af
 ld [wCustomSide], a
 ; Recalculation touches all stats: retain the original values except where
 ; a positive offensive stage was actually masked.
 call UnawareActorStats
 ld de, wUnawareSaved + 2
 ld a, [wUnawareSaved]
 cp 8
 call c, UnawareRestoreWord
 jr c, .attackRestored
 inc hl
 inc hl
 inc de
 inc de
.attackRestored
 call UnawareRestoreWord ; Defense
 call UnawareRestoreWord ; Speed
 ld a, [wUnawareSaved + 1]
 cp 8
 ret nc
 jp UnawareRestoreWord
UnawareRestoreWord:
 ld a, [de]
 ld [hli], a
 inc de
 ld a, [de]
 ld [hli], a
 inc de
 ret
UnawareEnd:
 ld a, [wUnawareActive]
 and a
 ret z
 call UnawareActorMods
 ld de, wUnawareSaved
 ld a, [de]
 ld [hl], a
 inc de
 inc hl
 inc hl
 inc hl
 ld a, [de]
 ld [hl], a
 inc de
 call UnawareActorStats
 ld b, 8
.restore
 ld a, [de]
 ld [hli], a
 inc de
 dec b
 jr nz, .restore
 xor a
 ld [wUnawareActive], a
 ret
UnawareActorMods:
 ld hl, wPlayerMonStatMods
 ld a, [H_WHOSETURN]
 and a
 ret z
 ld hl, wEnemyMonStatMods
 ret
UnawareActorStats:
 ld hl, wBattleMonAttack
 ld a, [H_WHOSETURN]
 and a
 ret z
 ld hl, wEnemyMonAttack
 ret

; HL points to the actor's physical offensive stat in the legacy damage path.
StrongmanAttackPointer:
 abilitycall AbilityStrongmanCheck
 ld a, [wAbilityCheckResult]
 and a
 ret z
 ld a, [H_WHOSETURN]
 and a
 jr z, .offset
 ld a, [wCriticalHitOrOHKO]
 and a
 jr z, .offset
 ; Enemy critical damage normally retrieves Attack into H_PRODUCT.
 push bc
 push de
 ld c, 5
 call GetEnemyMonStat
 ld hl, H_PRODUCT + 2
 pop de
 pop bc
 ret
.offset
 push de
 ld de, 6
 add hl, de
 pop de
 ret

; Transform replaces stages directly. Its temporary snapshot shares Unaware's
; damage-calculation buffer, which is idle while this status move executes.
AbilityCopycatTransformSnapshot:
 ld hl, wPlayerMonStatMods
 ld a, [H_WHOSETURN]
 and a
 jr z, .copy
 ld hl, wEnemyMonStatMods
.copy
 ld de, wUnawareSaved
 ld b, 6
.loop
 ld a, [hli]
 ld [de], a
 inc de
 dec b
 jr nz, .loop
 ret

AbilityCopycatTransformApply:
 ld a, [wCustomSide]
 push af
 ld a, [wCustomStat]
 push af
 ld a, [H_WHOSETURN]
 ld [wCustomSide], a
 and a
 ld hl, wPlayerMonStatMods
 jr z, .side
 ld hl, wEnemyMonStatMods
.side
 ld de, wUnawareSaved
 ld b, 0
.loop
 ld a, [de]
 ld c, a
 ld a, [hl]
 sub c
 jr z, .next
 bit 7, a
 jr nz, .next
 ld [wCopycatDelta], a
 ld a, b
 ld [wCustomStat], a
 push hl
 push de
 push bc
 abilitycall AbilityCopycatFromSide
 pop bc
 pop de
 pop hl
.next
 inc hl
 inc de
 inc b
 ld a, b
 cp 6
 jr nz, .loop
 pop af
 ld [wCustomStat], a
 pop af
 ld [wCustomSide], a
 ret

; Copycat uses the battle stat-change path; its scratch is shared across banks.
AbilityCopycatFromSideBanked:
 ld a, [wStatAbilityGuard]
 bit 1, a
 ret nz
 ld a, [wCopycatDelta]
 and a
 ret z
 bit 7, a
 ret nz
 callab AbilityGetCopycatTarget
 ld a, [wAbilityResolvedExtended]
 cp AB_COPYCAT - ABILITY_EXTENDED
 ret nz
 ld a, [wAbilitySide]
 push af
 ld a, [wCustomSide]
 push af
 ld a, [wCustomStat]
 push af
 ld a, [wCustomDelta]
 push af
 ld a, [wCustomChanged]
 push af
 ld a, [wCustomSavedTurn]
 push af
 ld a, [wCustomMove]
 push af
 ld a, [wCustomChance]
 push af
 ld a, [wCustomRandomValue]
 push af
 ld a, [wAbilityCheckResult]
 push af
 ld a, [wAbilityTemp]
 push af
 ld a, [wAbilityTemp + 1]
 push af
 ld a, [wCustomSide]
 xor 1
 ld [wAbilitySide], a
 ld [wCustomSide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 jr z, .restore
 ld a, [wCopycatDelta]
 ld [wCustomDelta], a
 ld hl, wStatAbilityGuard
 set 1, [hl]
 callab CustomChangeStage
 ld hl, wStatAbilityGuard
 res 1, [hl]
.restore
 pop af
 ld [wAbilityTemp + 1], a
 pop af
 ld [wAbilityTemp], a
 pop af
 ld [wAbilityCheckResult], a
 pop af
 ld [wCustomRandomValue], a
 pop af
 ld [wCustomChance], a
 pop af
 ld [wCustomMove], a
 pop af
 ld [wCustomSavedTurn], a
 pop af
 ld [wCustomChanged], a
 pop af
 ld [wCustomDelta], a
 pop af
 ld [wCustomStat], a
 pop af
 ld [wCustomSide], a
 pop af
 ld [wAbilitySide], a
 ret

AbilitySapSipperStatusBanked:
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 ld a, [wMoveMissed]
 and a
 ret nz
 callab AbilityTarget
 ld a, [wAbilityResolvedExtended]
 cp AB_SAP_SIPPER - ABILITY_EXTENDED
 ret nz
 callab AbilityMove
 ld a, [hl]
 cp LEECH_SEED
 jr z, .targeted
 cp STUN_SPORE
 jr z, .targeted
 cp SLEEP_POWDER
 jr z, .targeted
 cp SPORE
 ret nz
.targeted
 ld hl, wEnemyBattleStatus2
 ld a, [H_WHOSETURN]
 and a
 jr z, .checkSub
 ld hl, wPlayerBattleStatus2
.checkSub
 bit HAS_SUBSTITUTE_UP, [hl]
 ret nz
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 jpab AbilityRaiseAttack

; Reflections retain their shared scratch while crossing battle banks.
AbilityMirrorArmorCustomBanked:
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wStatAbilityGuard]
 bit 0, a
 ret nz
 ld a, [wCustomDelta]
 bit 7, a
 ret z
 callab AbilityGetCustomSide
 ld a, [wAbilityResolvedExtended]
 cp AB_MIRROR_ARMOR - ABILITY_EXTENDED
 ret nz
 ld a, [wAbilitySide]
 push af
 ld a, [wCustomSide]
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 jr z, .dead
 ld a, [wCustomSide]
 push af
 ld a, [wCustomStat]
 push af
 ld a, [wCustomDelta]
 push af
 ld a, [wCustomChanged]
 push af
 ld a, [wCustomSavedTurn]
 push af
 ld a, [wCustomMove]
 push af
 ld a, [wCustomChance]
 push af
 ld a, [wCustomRandomValue]
 push af
 ld a, [wAbilityTemp]
 push af
 ld a, [wAbilityTemp + 1]
 push af
 ld hl, wStatAbilityGuard
 set 0, [hl]
 ld a, [H_WHOSETURN]
 push af
 ld a, [wCustomSide]
 ld [H_WHOSETURN], a ; the reflection originates from the armor holder
 xor 1
 ld [wCustomSide], a
 callab CustomChangeStage
 pop af
 ld [H_WHOSETURN], a
 ld hl, wStatAbilityGuard
 res 0, [hl]
 pop af
 ld [wAbilityTemp + 1], a
 pop af
 ld [wAbilityTemp], a
 pop af
 ld [wCustomRandomValue], a
 pop af
 ld [wCustomChance], a
 pop af
 ld [wCustomMove], a
 pop af
 ld [wCustomSavedTurn], a
 pop af
 ld [wCustomChanged], a
 pop af
 ld [wCustomDelta], a
 pop af
 ld [wCustomStat], a
 pop af
 ld [wCustomSide], a
 pop af
 ld [wAbilitySide], a
 ld a, 1
 ld [wAbilityCheckResult], a
 ret
.dead
 pop af
 ld [wAbilitySide], a
 ret

; Apply the penalty to this recipient's final award after trade/trainer bonuses.
AbilityPatheticExperience:
 ld a, [H_QUOTIENT + 2]
 push af
 ld a, [H_QUOTIENT + 3]
 push af
 callab AbilityEnsureExpRecipient
 ld a, [wAbilityResolvedExtended]
 cp AB_PATHETIC - ABILITY_EXTENDED
 ld a, 0
 jr nz, .remember
 inc a
.remember
 ld [wAbilityCheckResult], a
 pop af
 ld c, a
 pop af
 ld b, a
 ld a, [wAbilityCheckResult]
 and a
 jr z, .store
 ; floor(3 * experience / 4) = experience - ceil(experience / 4).
 ld h, b
 ld l, c
 srl b
 rr c
 srl b
 rr c
 ld a, l
 and 3
 jr z, .subtract
 inc bc
.subtract
 ld a, l
 sub c
 ld c, a
 ld a, h
 sbc b
 ld b, a
.store
 ld a, b
 ld [H_QUOTIENT + 2], a
 ld a, c
 ld [H_QUOTIENT + 3], a
 ret

AbilityDesperationBanked:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_DESPERATION - ABILITY_EXTENDED
 ret nz
 ld hl, wPlayerMoveType
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 and a
 jr z, .type
 ld hl, wEnemyMoveType
.type
 ld a, [hl]
 cp FIRE
 ret nc
 callab AbilityBelowThird
 ret nc
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 jpab AbilityScaleDamage125

AbilityDancerAfterActionBanked:
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_DANCER - ABILITY_EXTENDED
 ret nz
 callab AbilityDancerStatusCheck
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab AbilityFlagsPointer
 bit 2, [hl]
 ret nz
 set 2, [hl]
 jpab AbilityRaiseSpeed

AbilitySturdyIncomingBanked:
 callab AbilityHP
 ld a, [de]
 cp [hl]
 ret nz
 inc de
 inc hl
 ld a, [de]
 cp [hl]
 ret nz
 dec hl
 ld a, [hli]
 ld b, a
 ld a, [hl]
 ld c, a
 or b
 ret z
 ld a, [wDamage]
 cp b
 ret c
 jr nz, .survive
 ld a, [wDamage + 1]
 cp c
 ret c
.survive
 push bc
 ld a, [wAbilityCheckResult]
 push af
 callab AbilityTargetResult
 ld a, [wAbilityCheckResult]
 ld d, a
 pop af
 ld [wAbilityCheckResult], a
 ld a, d
 cp AB_ONIX_STURDY
 jr z, .once
 cp ABILITY_EXTENDED
 jr nz, .unused
 ld a, [wAbilityResolvedExtended]
 cp AB_DETERMINATION - ABILITY_EXTENDED
 jr nz, .unused
.once
 callab AbilityFlagsPointer
 bit 0, [hl]
 jr nz, .alreadyUsed
 set 0, [hl]
.unused
 pop bc
 ld a, [wCriticalHitOrOHKO]
 cp 2
 jr nz, .notOHKO
 xor a
 ld [wCriticalHitOrOHKO], a
.notOHKO
 ld a, c
 sub 1
 ld [wDamage + 1], a
 ld a, b
 sbc 0
 ld [wDamage], a
 ret
.alreadyUsed
 pop bc
 ret

; Consume Wrath on an executed damaging move; a miss still spends it.
AbilityWrathAttempt:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_WRATH - ABILITY_EXTENDED
 ret nz
 callab AbilityWrathMoveCheck
 ret nc
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityFlagsPointer
 bit 0, [hl]
 ret z
 res 0, [hl]
 ld hl, wAbilityHit
 set 4, [hl]
 ret

AbilityGyaradosDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_OVERWHELMING - ABILITY_EXTENDED
 jr z, .overwhelming
 cp AB_WRATH - ABILITY_EXTENDED
 jp z, AbilityGyaradosFixedDamage.wrath
 cp AB_SAVAGE_JAWS - ABILITY_EXTENDED
 jp z, AbilityGyaradosFixedDamage.jaws
 ret
.overwhelming
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 ld a, [wCriticalHitOrOHKO]
 cp 2
 ret z
 cp 1
 jr nz, .effectiveness
 callab AbilityScaleDamage125
.effectiveness
 ld a, [wDamageMultipliers]
 and $7f
 cp 11
 ret c
 jpab AbilityScaleDamage125

AbilityGyaradosFixedDamage:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_WRATH - ABILITY_EXTENDED
 jr z, .wrath
 cp AB_SAVAGE_JAWS - ABILITY_EXTENDED
 jr z, .jaws
 ret
.wrath
 ld a, [wCriticalHitOrOHKO]
 cp 2
 ret z
 ld a, [wAbilityHit]
 bit 4, a
 jr nz, .wrathBoost
 ; Bide releases outside the ordinary move-attempt hook.
 bit 5, a
 ret z
 callab AbilityMove
 ld a, [hl]
 cp BIDE
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityFlagsPointer
 bit 0, [hl]
 ret z
 res 0, [hl]
 ld hl, wAbilityHit
 set 4, [hl]
.wrathBoost
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 jpab AbilityScaleDamage120
.jaws
 callab AbilityMove
 ld a, [hl]
 cp BITE
 jr z, .jawsBoost
 cp CRUNCH
 jr z, .jawsBoost
 cp HYPER_FANG
 jr z, .jawsBoost
 cp SUPER_FANG
 jr z, .jawsBoost
 cp POISON_FANG
 jr z, .jawsBoost
 cp SHOCK_FANG
 ret nz
.jawsBoost
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 jpab AbilityScaleDamage130

AbilitySharpBladesBanked:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_SHARP_BLADES - ABILITY_EXTENDED
 ret nz
 callab AbilityCuttingCheck
 ret nc
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 jpab AbilityScaleDamage125

AbilityBurningRageBanked:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityBurningRageFixedBanked:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_BURNING_RAGE - ABILITY_EXTENDED
 ret nz
 callab AbilityTargetStatus
 bit BRN, [hl]
 ret z
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 jpab AbilityScaleDamage125

; Transform copies nonempty moves at 5 PP, or 10 for Copy Master.
AbilityCopyMasterTransformPP:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_COPY_MASTER - ABILITY_EXTENDED
 ld a, 5
 jr nz, .store
 ld a, 10
.store
 ld [wAbilityCheckResult], a
 ret

; Called only after successful Transform and copied stats are in place.
AbilityDittoAfterTransform:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_PERFECT_COPY - ABILITY_EXTENDED
 jr z, .eligible
 cp AB_SHAPESHIFTER - ABILITY_EXTENDED
 jr z, .eligible
 cp AB_HAPPY_RETURN - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [de]
 cp [hl]
 jr nz, .eligible
 inc de
 inc hl
 ld a, [de]
 cp [hl]
 ret z
.eligible
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab AbilityFlagsPointer
 bit 2, [hl]
 ret nz
 set 2, [hl]
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_PERFECT_COPY - ABILITY_EXTENDED
 jp z, .heal
 cp AB_HAPPY_RETURN - ABILITY_EXTENDED
 jp z, .heal
 jpab AbilityRaiseSpeed
.heal
 jpab AbilityHealQuarter

; The end-of-round caller supplies an absolute side in wAbilitySide.
AbilityUnstableDNAResidual:
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_UNSTABLE_DNA - ABILITY_EXTENDED
 ret nz
 ld hl, wPlayerBattleStatus3
 ld a, [wAbilitySide]
 and a
 jr z, .status
 ld hl, wEnemyBattleStatus3
.status
 bit TRANSFORMED, [hl]
 ret z
 jpab AbilityRegeneration

; The battle move menu uses this maximum for a transformed Copy Master.
AbilityCopyMasterMaxPP:
 ld a, [wMonDataLocation]
 cp 4
 ret nz
 ld a, [wPlayerBattleStatus3]
 bit TRANSFORMED, a
 ret z
 callab AbilityPlayerResult
 ld a, [wAbilityResolvedExtended]
 cp AB_COPY_MASTER - ABILITY_EXTENDED
 ret nz
 ld a, 10
 ld [wMaxPP], a
 ret

; Carry when the executing move is neither of the user's current types.
AbilityEeveeMoveOffType:
 ld hl, wPlayerMoveType
 ld de, wBattleMonType1
 ld a, [H_WHOSETURN]
 and a
 jr z, .compare
 ld hl, wEnemyMoveType
 ld de, wEnemyMonType1
.compare
 ld a, [hl]
 and $1f
 ld b, a
 ld a, [de]
 and $1f
 cp b
 jr z, .same
 inc de
 ld a, [de]
 and $1f
 cp b
 jr z, .same
 scf
 ret
.same
 and a
 ret

AbilityEeveeDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityEeveeFixedDamage:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_VERSATILITY - ABILITY_EXTENDED
 jr z, .versatility
 cp AB_ADAPTABLE - ABILITY_EXTENDED
 ret nz
 ld a, [wDamageMultipliers]
 and $7f
 ret z
 cp 10
 ret nc
 jr .boost
.versatility
 call AbilityEeveeMoveOffType
 ret nc
.boost
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 jpab AbilityScaleDamage120

AbilityQuickLearnerAfterAction:
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_QUICK_LEARNER - ABILITY_EXTENDED
 jr z, .offType
 cp AB_OVERCLOCK - ABILITY_EXTENDED
 ret nz
 ld hl, wPlayerMoveType
 ld a, [H_WHOSETURN]
 and a
 jr z, .normalType
 ld hl, wEnemyMoveType
.normalType
 ld a, [hl]
 cp NORMAL
 ret nz
 jr .eligible
.offType
 call AbilityEeveeMoveOffType
 ret nc
.eligible
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab AbilityFlagsPointer
 bit 2, [hl]
 ret nz
 set 2, [hl]
 jpab AbilityRaiseSpeed

; Protean changes the battle types, leaving saved party data untouched.
AbilityProteanConvert:
 ld hl, wPlayerMoveNum
 ld de, wBattleMonType1
 ld a, [H_WHOSETURN]
 and a
 jr z, .move
 ld hl, wEnemyMoveNum
 ld de, wEnemyMonType1
.move
 ld a, [hli]
 and a
 ret z
 cp MAX_MOVE_ID + 1
 ret nc
 inc hl
 inc hl
 ld a, [hl] ; current move type, including dynamically reloaded moves
 and $1f
 ld [de], a
 inc de
 ld [de], a
 ret

AbilityHighHPTypeDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_ICE_QUEEN - ABILITY_EXTENDED
 jr z, .ice
 cp AB_POWER_SURGE - ABILITY_EXTENDED
 ret nz
 ld b, ELECTRIC
 jr .type
.ice
 ld b, ICE
.type
 ld hl, wPlayerMoveType
 ld a, [H_WHOSETURN]
 and a
 jr z, .compare
 ld hl, wEnemyMoveType
.compare
 ld a, [hl]
 cp b
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 ld l, [hl]
 ld h, a
 ld a, h
 or l
 ret z
 add hl, hl
 jr c, .aboveHalf
 ld a, [de]
 ld b, a
 inc de
 ld a, [de]
 ld c, a
 ld a, h
 cp b
 ret c
 jr nz, .aboveHalf
 ld a, l
 cp c
 ret c
 ret z
.aboveHalf
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_POWER_SURGE - ABILITY_EXTENDED
 jp z, .electric
 jpab AbilityScaleDamage125
.electric
 jpab AbilityScaleDamage115

; Absorb only after an attack passes accuracy and reachability.
AbilityElementAbsorbOnHit:
 callab AbilityTargetResult
 ld a, [wAbilityCheckResult]
 cp AB_EARTH_EATER
 jr z, .ground
 cp ABILITY_EXTENDED
 ret nz
 ld a, [wAbilityResolvedExtended]
 cp AB_WATER_ABSORB - ABILITY_EXTENDED
 jr z, .water
 cp AB_VOLT_ABSORB - ABILITY_EXTENDED
 ret nz
 ld b, ELECTRIC
 jr .attack
.water
 ld b, WATER
 jr .attack
.ground
 ld b, GROUND
.attack
 ld hl, wPlayerMoveNum
 ld a, [H_WHOSETURN]
 and a
 jr z, .checkMove
 ld hl, wEnemyMoveNum
.checkMove
 inc hl
 inc hl
 ld a, [hli]
 and a
 ret z ; status moves are not attacks
 ld a, [hl]
 cp b
 ret nz
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab AbilityHealQuarter
 xor a
 ld [wDamage], a
 ld [wDamage + 1], a
 ld a, [wDamageMultipliers]
 and $80
 ld [wDamageMultipliers], a
 xor a
 ld [wCriticalHitOrOHKO], a
 ld a, 2
 ld [wMoveMissed], a
 ld hl, AbilityElementAbsorbText
 jp PrintText
AbilityElementAbsorbText:
 text "The attack"
 line "was absorbed!"
 prompt

AbilityBounceMoveBanked:
 ld a, [wAbilityResolvedExtended]
 ld hl, AbilityBounceMoves
 ld de, 1
 jp IsInArray

AbilityBounceMoves:
 db WHIRLWIND, TAIL_WHIP, LEER, GROWL, ROAR, SING, SUPERSONIC, DISABLE
 db LEECH_SEED, POISONPOWDER, STUN_SPORE, SLEEP_POWDER, THUNDER_WAVE, TOXIC
 db HYPNOSIS, SCREECH, SMOKESCREEN, CONFUSE_RAY, KINESIS, SPLASH, GLARE, POISON_GAS
 db LOVELY_KISS, SPORE, WILL_O_WISP, FLASH_FREEZE, CURSE, CHARM, $ff

; B carries the bank during the call; recover the saved slot from scratch.
AbilityFindExtendedPool:
 ld a, [wAbilityTemp]
 ld c, a
 ld a, [wAbilityResolvedExtended]
 ld b, a
 xor a
 ld [wAbilityResolvedExtended], a
 ld hl, AbilityExtendedPoolIds
.find
 ld a, [hli]
 and a
 ret z
 cp c
 jr nz, .next
 ld a, [hli]
 cp b
 jr z, .found
 inc hl
 jr .find
.next
 inc hl
 inc hl
 jr .find
.found
 ld a, [hl]
 ld [wAbilityResolvedExtended], a
 ret

AbilityBearBlaze:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_BEAR_BLAZE - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 and a
 ld a, [wPlayerMoveType]
 jr z, .fireType
 ld a, [wEnemyMoveType]
.fireType
 cp FIRE
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab AbilityBelowThird
 jr c, .boost
 ret nz
.boost
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 ld c, a
 srl b
 rr c
 ld a, [wDamage + 1]
 add c
 ld [wDamage + 1], a
 ld a, [wDamage]
 adc b
 jr nc, .writeHigh
 ld a, $ff
 ld [wDamage + 1], a
.writeHigh
 ld [wDamage], a
 ret


AbilityBearRage:
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab AbilityHalfHPSide
 jr c, .eligible
 ret nz
.eligible
 callab AbilityFlagsPointer
 bit 2, [hl]
 ret nz
 set 2, [hl]
 jpab AbilityRaiseAttack


AbilityMaternalRage:
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab AbilityHalfHPSide
 ret nc
 callab AbilityFlagsPointer
 bit 2, [hl]
 ret nz
 set 2, [hl]
 jpab AbilityRaiseAttack


AbilitySoothingVoice:
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 callab AbilityActorResult
 ld a, [wAbilityCheckResult]
 cp AB_SOOTHING_VOICE
 ret nz
 callab AbilityMove
 ld a, [hl]
 callab AbilityMoveFlagsResult
 ld a, [wAbilityCheckResult]
 bit 4, a
 ret z
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 jpab AbilityHealEighthSide

AbilityBeforeStatusSnapshot:
 ; Residual bit 5 records whether the actor already had a major status.
 ld hl, wPlayerResidual
 ld de, wBattleMonStatus
 ld a, [H_WHOSETURN]
 and a
 jr z, .snapshot
 ld hl, wEnemyResidual
 ld de, wEnemyMonStatus
.snapshot
 res 5, [hl]
 ld a, [de]
 and a
 jr z, .earlyBird
 set 5, [hl]
.earlyBird
 callab AbilityActorResult
 ld a, [wAbilityResolvedExtended]
 cp AB_EARLY_BIRD - ABILITY_EXTENDED
 ret nz
 ld hl, wBattleMonStatus
 ld a, [H_WHOSETURN]
 and a
 jr z, .status
 ld hl, wEnemyMonStatus
.status
 ld a, [hl]
 and SLP
 cp 2
 ret c
 dec [hl]
 ret

AbilitySleepAndScatter:
 abilitycall AbilitySleepAfterAction
 call AbilitySporeScatter
 ; A reactive ability may have inflicted a status on the original actor.
 ld hl, wPlayerResidual
 ld a, [H_WHOSETURN]
 and a
 jr z, .actorSnapshot
 ld hl, wEnemyResidual
.actorSnapshot
 bit 5, [hl]
 ret nz
 ld a, [wAbilityOldStatus]
 push af
 ld a, [H_WHOSETURN]
 push af
 xor 1
 ld [H_WHOSETURN], a
 xor a
 ld [wAbilityOldStatus], a
 call AbilitySporeScatter
 pop af
 ld [H_WHOSETURN], a
 pop af
 ld [wAbilityOldStatus], a
 ret

; Reflect a newly inflicted major status to the opposing battler.
AbilitySporeScatter:
 ld a, [wAbilityOldStatus]
 and a
 ret nz
 callab AbilityTargetResult
 ld a, [wAbilityResolvedExtended]
 cp AB_SPORE_SCATTER - ABILITY_EXTENDED
 ret nz
 ld hl, wEnemyMonStatus
 ld a, [H_WHOSETURN]
 and a
 jr z, .targetStatus
 ld hl, wBattleMonStatus
.targetStatus
 ld a, [hl]
 and a
 ret z
 ld [wCustomDelta], a
 ld a, [H_WHOSETURN]
 ld [wCustomSide], a
 ld hl, wBattleMonStatus
 and a
 jr z, .actorStatus
 ld hl, wEnemyMonStatus
.actorStatus
 ld a, [hl]
 and a
 ret nz
 push hl
 dec hl
 ld a, [hld]
 or [hl]
 pop hl
 ret z
 call AbilityAntivirusReactiveActor
 ld a, [wAbilityCheckResult]
 and a
 ret nz
 ld a, [wCustomDelta]
 and SLP
 jr nz, .sleep
 ld a, [H_WHOSETURN]
 push af
 xor 1
 ld [H_WHOSETURN], a
 ld a, [wCustomDelta]
 cp 1 << PSN
 jr nz, .other
 callab AbilityInflictOrdinaryStatus
 jr .restoreTurn
.other
 callab UtilityInflictStatus
.restoreTurn
 pop af
 ld [H_WHOSETURN], a
 ret
.sleep
 ; Keep the same remaining sleep duration, interrupting recharge.
 ld a, [wCustomDelta]
 ld hl, wBattleMonStatus
 ld de, wPlayerBattleStatus2
 ld b, a
 ld a, [H_WHOSETURN]
 and a
 jr z, .sleepStore
 ld hl, wEnemyMonStatus
 ld de, wEnemyBattleStatus2
.sleepStore
 ld [hl], b
 ld a, [de]
 res NEEDS_TO_RECHARGE, a
 ld [de], a
 jpab UtilitySyncParty

AbilityExtendedPoolIds:
 db 70, 4, AB_THICK_VINES - ABILITY_EXTENDED
 db 71, 1, AB_PARENTAL_BOND - ABILITY_EXTENDED
 db 71, 3, AB_HEAVY_HITTER - ABILITY_EXTENDED
 db 71, 4, AB_EARLY_BIRD - ABILITY_EXTENDED
 db 71, 5, AB_MATERNAL_RAGE - ABILITY_EXTENDED
 db 72, 2, AB_INK_CLOUD - ABILITY_EXTENDED
 db 72, 3, AB_WATER_JET - ABILITY_EXTENDED
 db 72, 4, AB_FOCUSED - ABILITY_EXTENDED
 db 72, 5, AB_TOXIC_SPINES - ABILITY_EXTENDED
 db 73, 1, AB_ROYAL_HORN - ABILITY_EXTENDED
 db 73, 5, AB_LIGHTNING_ROD - ABILITY_EXTENDED
 db 74, 1, AB_REGENERATOR - ABILITY_EXTENDED
 db 74, 2, AB_COSMIC_CORE - ABILITY_EXTENDED
 db 74, 3, AB_ILLUMINATE - ABILITY_EXTENDED
 db 74, 5, AB_EQUALIZER - ABILITY_EXTENDED
 db 75, 1, AB_COPYCAT - ABILITY_EXTENDED
 db 75, 4, AB_STRONGMAN - ABILITY_EXTENDED
 db 75, 5, AB_MIRROR_ARMOR - ABILITY_EXTENDED
 db 76, 2, AB_SHARP_BLADES - ABILITY_EXTENDED
 db 76, 3, AB_VANGUARD - ABILITY_EXTENDED
 db 76, 5, AB_DOUBLE_SCYTHES - ABILITY_EXTENDED
 db 77, 1, AB_DANCER - ABILITY_EXTENDED
 db 77, 2, AB_COLD_TOUCH - ABILITY_EXTENDED
 db 77, 3, AB_ENCHANTRESS - ABILITY_EXTENDED
 db 77, 4, AB_ICE_QUEEN - ABILITY_EXTENDED
 db 78, 1, AB_POWER_SURGE - ABILITY_EXTENDED
 db 78, 2, AB_ENERGY_DRAIN - ABILITY_EXTENDED
 db 78, 3, AB_THUNDERSTRUCK - ABILITY_EXTENDED
 db 78, 4, AB_LIVE_WIRE - ABILITY_EXTENDED
 db 78, 5, AB_GALVANIZE - ABILITY_EXTENDED
 db 79, 1, AB_MAGMAR_FLAME_BODY - ABILITY_EXTENDED
 db 79, 3, AB_MAGMA_ARMOR - ABILITY_EXTENDED
 db 79, 4, AB_VITAL_HEAT - ABILITY_EXTENDED
 db 79, 5, AB_BURNING_RAGE - ABILITY_EXTENDED
 db 80, 1, AB_MOXIE - ABILITY_EXTENDED
 db 80, 3, AB_ARMOR_CRUSHER - ABILITY_EXTENDED
 db 80, 4, AB_CRUSHING_GRIP - ABILITY_EXTENDED
 db 81, 3, AB_UNSTOPPABLE - ABILITY_EXTENDED
 db 81, 4, AB_ANGER_POINT - ABILITY_EXTENDED
 db 81, 5, AB_SAP_SIPPER - ABILITY_EXTENDED
 db 82, 1, AB_PATHETIC - ABILITY_EXTENDED
 db 82, 2, AB_SPLASHING - ABILITY_EXTENDED
 db 82, 3, AB_DETERMINATION - ABILITY_EXTENDED
 db 82, 5, AB_DESPERATION - ABILITY_EXTENDED
 db 83, 1, AB_OVERWHELMING - ABILITY_EXTENDED
 db 83, 3, AB_WRATH - ABILITY_EXTENDED
 db 83, 4, AB_MOXIE - ABILITY_EXTENDED
 db 83, 5, AB_SAVAGE_JAWS - ABILITY_EXTENDED
 db 84, 1, AB_ANCIENT_SHELL - ABILITY_EXTENDED
 db 84, 3, AB_SAP_SIPPER - ABILITY_EXTENDED
 db 84, 4, AB_GENTLE_GIANT - ABILITY_EXTENDED
 db 85, 1, AB_PERFECT_COPY - ABILITY_EXTENDED
 db 85, 2, AB_UNSTABLE_DNA - ABILITY_EXTENDED
 db 85, 3, AB_SHAPESHIFTER - ABILITY_EXTENDED
 db 85, 4, AB_COPY_MASTER - ABILITY_EXTENDED
 db 86, 1, AB_VERSATILITY - ABILITY_EXTENDED
 db 86, 2, AB_ADAPTABLE - ABILITY_EXTENDED
 db 86, 3, AB_FLEXIBLE - ABILITY_EXTENDED
 db 86, 4, AB_QUICK_LEARNER - ABILITY_EXTENDED
 db 86, 5, AB_PROTEAN - ABILITY_EXTENDED
 db 87, 1, AB_LIQUID_BODY - ABILITY_EXTENDED
 db 87, 4, AB_WATER_ABSORB - ABILITY_EXTENDED
 db 87, 5, AB_DEEP_SEA_PRESSURE - ABILITY_EXTENDED
 db 88, 1, AB_GALVANIZE - ABILITY_EXTENDED
 db 88, 3, AB_SPIKY_FUR - ABILITY_EXTENDED
 db 88, 4, AB_VOLT_ABSORB - ABILITY_EXTENDED
 db 89, 1, AB_HEAT_WAVE - ABILITY_EXTENDED
 db 89, 2, AB_MAGMA_COAT - ABILITY_EXTENDED
 db 89, 4, AB_FLUFFY - ABILITY_EXTENDED
 db 90, 1, AB_CONSERVATIVE - ABILITY_EXTENDED
 db 90, 2, AB_TRACE - ABILITY_EXTENDED
 db 90, 3, AB_ANTIVIRUS - ABILITY_EXTENDED
 db 90, 4, AB_OVERCLOCK - ABILITY_EXTENDED
 db 90, 5, AB_DOWNLOAD - ABILITY_EXTENDED
 db 91, 1, AB_ANCIENT_POWER - ABILITY_EXTENDED
 db 91, 2, AB_MINDS_EYE - ABILITY_EXTENDED
 db 91, 4, AB_CRUSHING_GRIP - ABILITY_EXTENDED
 db 92, 1, AB_KABUTO_EXECUTIONER - ABILITY_EXTENDED
 db 92, 2, AB_ANCIENT_POWER - ABILITY_EXTENDED
 db 92, 5, AB_SHARP_BLADES - ABILITY_EXTENDED
 db 93, 4, AB_SAVAGE_JAWS - ABILITY_EXTENDED
 db 93, 5, AB_TERRIFYING - ABILITY_EXTENDED
 db 94, 1, AB_HEAVY_SLEEPER - ABILITY_EXTENDED
 db 94, 4, AB_SLEEPWALKER - ABILITY_EXTENDED
 db 95, 1, AB_ABSOLUTE_ZERO - ABILITY_EXTENDED
 db 95, 2, AB_ABSOLUTE_ZERO - ABILITY_EXTENDED
 db 95, 3, AB_ABSOLUTE_ZERO - ABILITY_EXTENDED
 db 95, 4, AB_ABSOLUTE_ZERO - ABILITY_EXTENDED
 db 95, 5, AB_ABSOLUTE_ZERO - ABILITY_EXTENDED
 db 96, 1, AB_LIGHTNING_SPEED - ABILITY_EXTENDED
 db 96, 2, AB_LIGHTNING_SPEED - ABILITY_EXTENDED
 db 96, 3, AB_LIGHTNING_SPEED - ABILITY_EXTENDED
 db 96, 4, AB_LIGHTNING_SPEED - ABILITY_EXTENDED
 db 96, 5, AB_LIGHTNING_SPEED - ABILITY_EXTENDED
 db 97, 1, AB_INTENSE_FLAMES - ABILITY_EXTENDED
 db 97, 2, AB_INTENSE_FLAMES - ABILITY_EXTENDED
 db 97, 3, AB_INTENSE_FLAMES - ABILITY_EXTENDED
 db 97, 4, AB_INTENSE_FLAMES - ABILITY_EXTENDED
 db 97, 5, AB_INTENSE_FLAMES - ABILITY_EXTENDED
 db 98, 2, AB_MYSTIC_SCALES - ABILITY_EXTENDED
 db 98, 3, AB_SERPENT_GRACE - ABILITY_EXTENDED
 db 98, 4, AB_MARVEL_SCALE - ABILITY_EXTENDED
 db 99, 1, AB_MULTISCALE - ABILITY_EXTENDED
 db 99, 2, AB_MYSTIC_SCALES - ABILITY_EXTENDED
 db 99, 3, AB_INNER_FOCUS - ABILITY_EXTENDED
 db 99, 4, AB_MARVEL_SCALE - ABILITY_EXTENDED
 db 100, 1, AB_DOMINANCE - ABILITY_EXTENDED
 db 100, 2, AB_DOMINANCE - ABILITY_EXTENDED
 db 100, 3, AB_DOMINANCE - ABILITY_EXTENDED
 db 100, 4, AB_DOMINANCE - ABILITY_EXTENDED
 db 100, 5, AB_DOMINANCE - ABILITY_EXTENDED
 db 101, 1, AB_ANCESTOR - ABILITY_EXTENDED
 db 101, 2, AB_ANCESTOR - ABILITY_EXTENDED
 db 101, 3, AB_ANCESTOR - ABILITY_EXTENDED
 db 101, 4, AB_ANCESTOR - ABILITY_EXTENDED
 db 101, 5, AB_ANCESTOR - ABILITY_EXTENDED
 db 102, 1, AB_REGENERATOR - ABILITY_EXTENDED
 db 102, 2, AB_MERCILESS - ABILITY_EXTENDED
 db 102, 5, AB_BARBED_SHELL - ABILITY_EXTENDED
 db 103, 2, AB_SAP_SIPPER - ABILITY_EXTENDED
 db 108, 2, AB_MIRROR_ARMOR - ABILITY_EXTENDED
 db 108, 3, AB_TRICKSTER - ABILITY_EXTENDED
 db 108, 5, AB_SHADOW_AMBUSH - ABILITY_EXTENDED
 db 109, 3, AB_MINDS_EYE - ABILITY_EXTENDED
 db 109, 5, AB_CLAY_ARMOR - ABILITY_EXTENDED
 db 110, 3, AB_TECTONIC_WRATH - ABILITY_EXTENDED
 db 110, 5, AB_TYRANITAR_TERRIFYING - ABILITY_EXTENDED
 db 105, 5, AB_CONTACT_SPIKED_SHELL - ABILITY_EXTENDED
 db 111, 1, AB_CONTACT_SPIKED_SHELL - ABILITY_EXTENDED
 db 111, 5, AB_ROCK_POISON_POINT - ABILITY_EXTENDED
 db 112, 1, AB_SHADOW_BOXING - ABILITY_EXTENDED
 db 112, 2, AB_SHADOW_BOXING - ABILITY_EXTENDED
 db 112, 3, AB_SHADOW_BOXING - ABILITY_EXTENDED
 db 112, 4, AB_SHADOW_BOXING - ABILITY_EXTENDED
 db 112, 5, AB_SHADOW_BOXING - ABILITY_EXTENDED
 db 113, 1, AB_GIGANTISM - ABILITY_EXTENDED
 db 113, 2, AB_GIGANTISM - ABILITY_EXTENDED
 db 113, 3, AB_GIGANTISM - ABILITY_EXTENDED
 db 113, 4, AB_GIGANTISM - ABILITY_EXTENDED
 db 113, 5, AB_GIGANTISM - ABILITY_EXTENDED
 db 114, 1, AB_INDOMITABLE - ABILITY_EXTENDED
 db 114, 2, AB_INDOMITABLE - ABILITY_EXTENDED
 db 114, 3, AB_INDOMITABLE - ABILITY_EXTENDED
 db 114, 4, AB_INDOMITABLE - ABILITY_EXTENDED
 db 114, 5, AB_INDOMITABLE - ABILITY_EXTENDED
 db 115, 1, AB_SINISTER - ABILITY_EXTENDED
 db 115, 2, AB_SINISTER - ABILITY_EXTENDED
 db 115, 3, AB_SINISTER - ABILITY_EXTENDED
 db 115, 4, AB_SINISTER - ABILITY_EXTENDED
 db 115, 5, AB_SINISTER - ABILITY_EXTENDED
 db 116, 1, AB_RECOVERY - ABILITY_EXTENDED
 db 116, 2, AB_RECOVERY - ABILITY_EXTENDED
 db 116, 3, AB_RECOVERY - ABILITY_EXTENDED
 db 116, 4, AB_RECOVERY - ABILITY_EXTENDED
 db 116, 5, AB_RECOVERY - ABILITY_EXTENDED
 db 117, 1, AB_SHARP_VINES - ABILITY_EXTENDED
 db 117, 2, AB_SHARP_VINES - ABILITY_EXTENDED
 db 117, 3, AB_SHARP_VINES - ABILITY_EXTENDED
 db 117, 4, AB_SHARP_VINES - ABILITY_EXTENDED
 db 117, 5, AB_SHARP_VINES - ABILITY_EXTENDED
 db 118, 1, AB_BIG_BLOOM - ABILITY_EXTENDED
 db 118, 2, AB_BIG_BLOOM - ABILITY_EXTENDED
 db 118, 3, AB_BIG_BLOOM - ABILITY_EXTENDED
 db 118, 4, AB_BIG_BLOOM - ABILITY_EXTENDED
 db 118, 5, AB_BIG_BLOOM - ABILITY_EXTENDED
 db 119, 1, AB_DISCIPLINE - ABILITY_EXTENDED
 db 119, 2, AB_DISCIPLINE - ABILITY_EXTENDED
 db 119, 3, AB_DISCIPLINE - ABILITY_EXTENDED
 db 119, 4, AB_DISCIPLINE - ABILITY_EXTENDED
 db 119, 5, AB_DISCIPLINE - ABILITY_EXTENDED
 db 120, 1, AB_BIG_BLOOM - ABILITY_EXTENDED
 db 120, 2, AB_BIG_BLOOM - ABILITY_EXTENDED
 db 120, 3, AB_BIG_BLOOM - ABILITY_EXTENDED
 db 120, 4, AB_BIG_BLOOM - ABILITY_EXTENDED
 db 120, 5, AB_BIG_BLOOM - ABILITY_EXTENDED
 db 121, 1, AB_HAPPY_RETURN - ABILITY_EXTENDED
 db 121, 2, AB_HAPPY_RETURN - ABILITY_EXTENDED
 db 121, 3, AB_HAPPY_RETURN - ABILITY_EXTENDED
 db 121, 4, AB_HAPPY_RETURN - ABILITY_EXTENDED
 db 121, 5, AB_HAPPY_RETURN - ABILITY_EXTENDED
 db 122, 1, AB_DUELIST - ABILITY_EXTENDED
 db 122, 2, AB_DUELIST - ABILITY_EXTENDED
 db 122, 3, AB_DUELIST - ABILITY_EXTENDED
 db 122, 4, AB_DUELIST - ABILITY_EXTENDED
 db 122, 5, AB_DUELIST - ABILITY_EXTENDED
 db 123, 1, AB_SHELL_REFLEX - ABILITY_EXTENDED
 db 123, 2, AB_SHELL_REFLEX - ABILITY_EXTENDED
 db 123, 3, AB_SHELL_REFLEX - ABILITY_EXTENDED
 db 123, 4, AB_SHELL_REFLEX - ABILITY_EXTENDED
 db 123, 5, AB_SHELL_REFLEX - ABILITY_EXTENDED
 db 124, 1, AB_EFFICIENT - ABILITY_EXTENDED
 db 124, 2, AB_EFFICIENT - ABILITY_EXTENDED
 db 124, 3, AB_EFFICIENT - ABILITY_EXTENDED
 db 124, 4, AB_EFFICIENT - ABILITY_EXTENDED
 db 124, 5, AB_EFFICIENT - ABILITY_EXTENDED
 db 125, 1, AB_KINDLING - ABILITY_EXTENDED
 db 125, 2, AB_KINDLING - ABILITY_EXTENDED
 db 125, 3, AB_KINDLING - ABILITY_EXTENDED
 db 125, 4, AB_KINDLING - ABILITY_EXTENDED
 db 125, 5, AB_KINDLING - ABILITY_EXTENDED
 db 126, 1, AB_ANCIENT_MALICE - ABILITY_EXTENDED
 db 126, 2, AB_ANCIENT_MALICE - ABILITY_EXTENDED
 db 126, 3, AB_ANCIENT_MALICE - ABILITY_EXTENDED
 db 126, 4, AB_ANCIENT_MALICE - ABILITY_EXTENDED
 db 126, 5, AB_ANCIENT_MALICE - ABILITY_EXTENDED
 db 127, 1, AB_TOXIC_PURSUIT - ABILITY_EXTENDED
 db 127, 2, AB_TOXIC_PURSUIT - ABILITY_EXTENDED
 db 127, 3, AB_TOXIC_PURSUIT - ABILITY_EXTENDED
 db 127, 4, AB_TOXIC_PURSUIT - ABILITY_EXTENDED
 db 127, 5, AB_TOXIC_PURSUIT - ABILITY_EXTENDED
 db 128, 1, AB_CAREGIVER - ABILITY_EXTENDED
 db 128, 2, AB_CAREGIVER - ABILITY_EXTENDED
 db 128, 3, AB_CAREGIVER - ABILITY_EXTENDED
 db 128, 4, AB_CAREGIVER - ABILITY_EXTENDED
 db 128, 5, AB_CAREGIVER - ABILITY_EXTENDED
 db 129, 1, AB_BORROWED_STRENGTH - ABILITY_EXTENDED
 db 129, 2, AB_BORROWED_STRENGTH - ABILITY_EXTENDED
 db 129, 3, AB_BORROWED_STRENGTH - ABILITY_EXTENDED
 db 129, 4, AB_BORROWED_STRENGTH - ABILITY_EXTENDED
 db 129, 5, AB_BORROWED_STRENGTH - ABILITY_EXTENDED
 db 130, 1, AB_HORN_SPECIALIST - ABILITY_EXTENDED
 db 130, 2, AB_HORN_SPECIALIST - ABILITY_EXTENDED
 db 130, 3, AB_HORN_SPECIALIST - ABILITY_EXTENDED
 db 130, 4, AB_HORN_SPECIALIST - ABILITY_EXTENDED
 db 130, 5, AB_HORN_SPECIALIST - ABILITY_EXTENDED
 db 131, 5, AB_SAVAGE_JAWS - ABILITY_EXTENDED
 db 133, 1, AB_BEAR_RAGE - ABILITY_EXTENDED
 db 133, 2, AB_BEAR_BLAZE - ABILITY_EXTENDED
 db 133, 3, AB_BEAR_FLAME_BODY - ABILITY_EXTENDED
 db 133, 4, AB_FURNACE - ABILITY_EXTENDED
 db 133, 5, AB_HEAVY_SLEEPER - ABILITY_EXTENDED
 db 134, 3, AB_SPORE_SCATTER - ABILITY_EXTENDED
 db 134, 5, AB_LIGHTWEIGHT - ABILITY_EXTENDED
 db 135, 1, AB_CONTACT_STATIC - ABILITY_EXTENDED
 db 135, 2, AB_WOOL_COAT - ABILITY_EXTENDED
 db 135, 3, AB_SHED_WOOL - ABILITY_EXTENDED
 db 135, 5, AB_CHARGE_UP - ABILITY_EXTENDED
 db 136, 1, AB_CONTACT_STATIC - ABILITY_EXTENDED
 db 136, 2, AB_AMPHAROS_WOOL - ABILITY_EXTENDED
 db 136, 3, AB_SHED_WOOL - ABILITY_EXTENDED
 db 136, 5, AB_CHARGE_UP - ABILITY_EXTENDED
 db 137, 1, AB_BLUFF - ABILITY_EXTENDED
 db 137, 4, AB_PREPARED - ABILITY_EXTENDED
 db 137, 5, AB_HUGE_POWER - ABILITY_EXTENDED
 db 138, 1, AB_WOLF_TERRIFYING - ABILITY_EXTENDED
 db 138, 4, AB_PREPARED - ABILITY_EXTENDED
 db 0

AbilitySpikyFurMessageBanked:
 ld hl, AbilitySpikyFurText
 jp PrintText
AbilitySpikyFurText:
 text "Hurt by"
 line "SPIKY FUR!"
 prompt

; Process each living Heat Wave holder once per residual round.
AbilityHeatWaveBoth:
 xor a
 ld [wAbilitySide], a
 call .one
 ld a, 1
 ld [wAbilitySide], a
.one
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_HEAT_WAVE - ABILITY_EXTENDED
 ret nz
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld a, [wAbilitySide]
 xor 1
 ld [wAbilitySide], a
 ld [wCustomSide], a
 ld hl, wBattleMonType1
 and a
 jr z, .type
 ld hl, wEnemyMonType1
.type
 ld a, [hli]
 and $1f
 cp FIRE
 ret z
 ld a, [hl]
 and $1f
 cp FIRE
 ret z
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld a, 4
 ld [wCustomDelta], a
 xor a
 ld [wCustomChance], a
 jpab ResidualFraction

; New electric-family passives live in this bank to keep battle hooks small.
AbilityRecoveryAndShed:
 abilitycall AbilityRecoveryBoth
 jp AbilityShedWoolBoth

AbilityWoolCoatDamage:
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 callab AbilityTarget
 ld a, [wAbilityResolvedExtended]
 cp AB_WOOL_COAT - ABILITY_EXTENDED
 jr z, .regular
 cp AB_AMPHAROS_WOOL - ABILITY_EXTENDED
 ret nz
 ld hl, wPlayerMoveType
 ld a, [H_WHOSETURN]
 and a
 jr z, .ampharosType
 ld hl, wEnemyMoveType
.ampharosType
 ld a, [hl]
 cp FIRE
 jr z, .fire
 ret nc
 ld c, 75
 jp AbilityFluffyFixedDamage.scale
.fire
 ld c, 150
 jp AbilityFluffyFixedDamage.scale
.regular
 ld hl, wPlayerMoveType
 ld a, [H_WHOSETURN]
 and a
 jr z, .regularType
 ld hl, wEnemyMoveType
.regularType
 ld a, [hl]
 cp FIRE
 ret nc
 ld c, 80
 jp AbilityFluffyFixedDamage.scale

AbilityChargeUpDamage:
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_CHARGE_UP - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 ld hl, wPlayerMoveType
 and a
 jr z, .type
 ld hl, wEnemyMoveType
.type
 ld a, [hl]
 cp ELECTRIC
 ret nz
 callab AbilityRolloutSidePointer
 ld a, [hl]
 and a
 ret z
 ld c, 130
 jp AbilityFluffyFixedDamage.scale

AbilityShedWoolOnHit:
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 jr AbilityShedWoolSide
AbilityShedWoolBoth:
 xor a
 ld [wAbilitySide], a
 call AbilityShedWoolSide
 ld a, 1
 ld [wAbilitySide], a
AbilityShedWoolSide:
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_SHED_WOOL - ABILITY_EXTENDED
 ret nz
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab AbilityHalfHPSide
 jr c, .below
 ret nz
.below
 callab AbilityFlagsPointer
 bit 2, [hl]
 ret nz
 set 2, [hl]
 jpab AbilityHealFifth

AbilityChargeUpOnHit:
 callab AbilityTarget
 ld a, [wAbilityResolvedExtended]
 cp AB_CHARGE_UP - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 callab AbilityRolloutSidePointer
 ld [hl], 1
 ret

AbilityChargeUpAfterAction:
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_CHARGE_UP - ABILITY_EXTENDED
 ret nz
 ld hl, wPlayerMovePower
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 and a
 jr z, .move
 ld hl, wEnemyMovePower
.move
 ld a, [hli]
 and a
 ret z
 ld a, [hl]
 cp ELECTRIC
 ret nz
 callab AbilityRolloutSidePointer
 ld [hl], 0
 ret

AbilityContactReactions:
 abilitycall AbilityFlameBody
 jp AbilityContactStaticOnHit

AbilityContactStaticOnHit:
 callab AbilityTarget
 ld a, [wAbilityResolvedExtended]
 cp AB_CONTACT_STATIC - ABILITY_EXTENDED
 ret nz
 callab AbilityMoveFlagsResult
 ld a, [wAbilityCheckResult]
 bit 1, a
 ret z
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
.retry
 callab CustomRandomInBattleBank
 ld a, [wCustomRandomValue]
 cp 200
 jr nc, .retry
 cp 40
 ret nc
 ld a, [H_WHOSETURN]
 push af
 ld [wCustomSide], a
 xor 1
 ld [H_WHOSETURN], a
 ld a, 1 << PAR
 ld [wCustomDelta], a
 callab UtilityInflictStatus
 pop af
 ld [H_WHOSETURN], a
 ret

AbilityFluffyDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityFluffyFixedDamage:
 call AbilityWoolCoatDamage
 call AbilityChargeUpDamage
 callab AbilityTarget
 ld a, [wAbilityResolvedExtended]
 cp AB_FLUFFY - ABILITY_EXTENDED
 ret nz
 ld hl, wPlayerMoveType
 ld a, [H_WHOSETURN]
 and a
 jr z, .type
 ld hl, wEnemyMoveType
.type
 ld a, [hl]
 cp FIRE
 jr z, .fire
 ret nc
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 ld c, 70
 jr .scale
.fire
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 ld c, 200
.scale
 ld a, [wDamage]
 ld [H_MULTIPLICAND + 1], a
 ld a, [wDamage + 1]
 ld [H_MULTIPLICAND + 2], a
 xor a
 ld [H_MULTIPLICAND], a
 ld a, c
 ld [H_MULTIPLIER], a
 call Multiply
 ld a, 100
 ld [H_DIVISOR], a
 ld b, 4
 call Divide
 ld a, [H_QUOTIENT + 2]
 ld [wDamage], a
 ld b, a
 ld a, [H_QUOTIENT + 3]
 ld [wDamage + 1], a
 or b
 ret nz
 inc a
 ld [wDamage + 1], a
 ret

AbilityFocusedAttemptBanked:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_FOCUSED - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityFlagsPointer
 bit 0, [hl]
 jr z, .first
 bit 1, [hl]
 ret z
 callab AbilityMove
 ld a, [hl]
 cp BIDE
 ret z
 callab AbilityFlagsPointer
 res 1, [hl]
 ret
.first
 set 0, [hl]
 callab AbilityMove
 ld a, [hl]
 cp BIDE
 jr z, .bide
 callab AbilityDancerStatusCheck
 ret z
.mark
 ld hl, wAbilityHit
 set 4, [hl]
 ret
.bide
 callab AbilityFlagsPointer
 set 1, [hl]
 jr .mark

; Species-to-pool lookup is banked separately from descriptions.
AbilityFamilyBanked:
 ld a, [wAbilityResolvedExtended]
 ld b, a
 ld hl, AbilitySpeciesPools
.loop
 ld a, [hli]
 and a
 jr z, .store
 cp b
 ld a, [hli]
 jr nz, .loop
.store
 ld [wAbilityResolvedExtended], a
 ret

AbilitySpeciesPools:
	db BULBASAUR, 1
	db IVYSAUR, 1
	db VENUSAUR, 1
	db CHARMANDER, 2
	db CHARMELEON, 2
	db CHARIZARD, 2
	db SQUIRTLE, 3
	db WARTORTLE, 3
	db BLASTOISE, 3
	db CATERPIE, 4
	db METAPOD, 5
	db BUTTERFREE, 6
	db WEEDLE, 7
	db KAKUNA, 8
	db BEEDRILL, 9
	db PIDGEY, 10
	db PIDGEOTTO, 10
	db PIDGEOT, 10
	db RATTATA, 11
	db RATICATE, 11
	db SPEAROW, 12
	db FEAROW, 12
	db EKANS, 13
	db ARBOK, 13
	db PIKACHU, 14
	db RAICHU, 14
	db SANDSHREW, 15
	db SANDSLASH, 16
	db NIDORAN_F, 17
	db NIDORINA, 17
	db NIDOQUEEN, 17
	db NIDORAN_M, 18
	db NIDORINO, 18
	db NIDOKING, 18
	db CLEFAIRY, 19
	db CLEFABLE, 19
	db VULPIX, 20
	db NINETALES, 20
	db JIGGLYPUFF, 21
	db WIGGLYTUFF, 21
	db ZUBAT, 22
	db GOLBAT, 22
	db CROBAT, 22
	db ODDISH, 23
	db GLOOM, 24
	db VILEPLUME, 23
	db PARAS, 25
	db PARASECT, 26
	db VENONAT, 27
	db VENOMOTH, 27
	db DIGLETT, 28
	db DUGTRIO, 28
	db MEOWTH, 29
	db PERSIAN, 29
	db PSYDUCK, 30
	db GOLDUCK, 31
	db MANKEY, 32
	db PRIMEAPE, 32
	db GROWLITHE, 33
	db ARCANINE, 34
	db POLIWAG, 35
	db POLIWHIRL, 35
	db POLIWRATH, 36
	db ABRA, 37
	db KADABRA, 38
	db ALAKAZAM, 38
	db MACHOP, 39
	db MACHOKE, 39
	db MACHAMP, 40
	db BELLSPROUT, 41
	db WEEPINBELL, 41
	db VICTREEBEL, 41
	db TENTACOOL, 42
	db TENTACRUEL, 42
	db GEODUDE, 43
	db GRAVELER, 44
	db GOLEM, 44
	db PONYTA, 45
	db RAPIDASH, 45
	db SLOWPOKE, 46
	db SLOWBRO, 46
	db MAGNEMITE, 47
	db MAGNETON, 47
	db FARFETCHD, 48
	db DODUO, 49
	db DODRIO, 50
	db SEEL, 51
	db DEWGONG, 51
	db GRIMER, 52
	db MUK, 52
	db SHELLDER, 53
	db CLOYSTER, 53
	db GASTLY, 54
	db HAUNTER, 55
	db GENGAR, 55
	db ONIX, 56
	db DROWZEE, 57
	db HYPNO, 57
	db KRABBY, 58
	db KINGLER, 58
	db VOLTORB, 59
	db ELECTRODE, 59
	db EXEGGCUTE, 60
	db EXEGGUTOR, 61
	db CUBONE, 62
	db MAROWAK, 63
	db HITMONLEE, 64
	db HITMONCHAN, 65
	db LICKITUNG, 66
	db KOFFING, 67
	db WEEZING, 67
	db RHYHORN, 68
	db RHYDON, 68
	db CHANSEY, 69
	db TANGELA, 70
	db KANGASKHAN, 71
	db HORSEA, 72
	db SEADRA, 72
	db GOLDEEN, 73
	db SEAKING, 73
	db STARYU, 74
	db STARMIE, 74
	db MR_MIME, 75
	db SCYTHER, 76
	db JYNX, 77
	db ELECTABUZZ, 78
	db MAGMAR, 79
	db PINSIR, 80
	db TAUROS, 81
	db MAGIKARP, 82
	db GYARADOS, 83
	db LAPRAS, 84
	db DITTO, 85
	db EEVEE, 86
	db VAPOREON, 87
	db JOLTEON, 88
	db FLAREON, 89
	db PORYGON, 90
	db OMANYTE, 91
	db OMASTAR, 91
	db KABUTO, 92
	db KABUTOPS, 92
	db AERODACTYL, 93
	db SNORLAX, 94
	db ARTICUNO, 95
	db ZAPDOS, 96
	db MOLTRES, 97
	db DRATINI, 98
	db DRAGONAIR, 98
	db DRAGONITE, 99
	db MEWTWO, 100
	db MEW, 101
	db MAREANIE, 102
	db TOXAPEX, 102
	db MILTANK, 103
	db LARVITAR, 104
	db PUPITAR, 105
	db UNIQUE_BLASTOISE_UNIQUE, 106
	db UNIQUE_IVYSAUR_ERIKA, 107
	db SABLEYE, 108
	db BALTOY, 109
	db CLAYDOL, 109
	db TYRANITAR, 110
	db UNIQUE_KAKUNA_ROCK_TYPE, 111
	db UNIQUE_GEODUDE_FIGHTING, 112
	db UNIQUE_TENTACOOL_BIG, 113
	db UNIQUE_ONIX_BROCK, 114
	db UNIQUE_NIDOKING_UNIQUE, 115
	db UNIQUE_GRIMER_POISON, 116
	db UNIQUE_TANGELA_ERIKA, 117
	db UNIQUE_VENUSAUR_ERIKA, 118
	db UNIQUE_RAICHU_UNIQUE, 119
	db UNIQUE_BULBASAUR_UNIQUE, 120
	db UNIQUE_DITTO_HAPPY, 121
	db UNIQUE_MAROWAK_UNIQUE, 122
	db UNIQUE_SQUIRTLE_UNIQUE, 123
	db UNIQUE_NIDORANM_UNIQUE, 124
	db UNIQUE_CHARMANDER_UNIQUE, 125
	db UNIQUE_OMANYTE_UNIQUE, 126
	db UNIQUE_NIDOKING_UNIQUE2, 127
	db UNIQUE_CHANSEY_UNIQUE, 128
	db DITTWO, 129
	db UNIQUE_GOLDEEN_FIGHTING, 130
	db TYKER, 131
	db STRAIGAR, 131
	db PHANPY, 132
	db DONPHAN, 132
	db EMBEAR, 133
	db URSEAR, 133
	db VOLKUMA, 133
	db HOPPIP, 134
	db SKIPLOOM, 134
	db JUMPLUFF, 134
	db MAREEP, 135
	db FLAAFFY, 135
	db AMPHAROS, 136
	db GARMIC, 137
	db FANGRIR, 138
	db 0

; The first pair is processed together once both battlers are present.
AbilityPorygonEntry:
 ld a, [wAbilitySide]
 push af
 ld a, [wFirstMonsNotOutYet]
 and a
 jr z, .single
 ld a, [wAbilitySide]
 and a
 jr nz, .restore
 xor a
 ld [wAbilitySide], a
 call .trace
 ld a, 1
 ld [wAbilitySide], a
 call .trace
 jr nc, .enemyTraceDone
 callab AbilityEntryOwnEffects
.enemyTraceDone
 xor a
 ld [wAbilitySide], a
 call .entryEffects
 ld a, 1
 ld [wAbilitySide], a
 call .entryEffects
 jr .restore
.single
 call .trace
 call .entryEffects
.restore
 pop af
 ld [wAbilitySide], a
 ret
.trace
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_TRACE - ABILITY_EXTENDED
 jr nz, .traceNoChange
 callab AbilityHP
 ld a, [hli]
 or [hl]
 jr z, .traceNoChange
 ld a, [wAbilitySide]
 push af
 xor 1
 ld [wAbilitySide], a
 ld hl, wBattleMonSpecies
 and a
 jr z, .traceSpecies
 ld hl, wEnemyMonSpecies
.traceSpecies
 ld a, [hl]
 and a
 jr z, .traceRestore
 callab AbilityHP
 ld a, [hli]
 or [hl]
 jr z, .traceRestore
 ld hl, wActiveAbilities
 ld de, wActiveAbilityExtended
 ld a, [wAbilitySide]
 and a
 jr z, .readAbility
 inc hl
 inc de
.readAbility
 ld a, [hl]
 and a
 jr z, .traceRestore
 ld b, a
 ld a, [de]
 ld c, a
 ld a, b
 cp ABILITY_EXTENDED
 jr nz, .copy
 ld a, c
 cp AB_TRACE - ABILITY_EXTENDED
 jr z, .traceRestore
.copy
 pop af
 ld [wAbilitySide], a
 ld hl, wActiveAbilities
 ld de, wActiveAbilityExtended
 and a
 jr z, .store
 inc hl
 inc de
.store
 ld [hl], b
 ld a, c
 ld [de], a
 scf
 ret
.traceRestore
 pop af
 ld [wAbilitySide], a
.traceNoChange
 and a
 ret
.entryEffects
 call .antivirusEntry
 call .download
 ret
.antivirusEntry
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_ANTIVIRUS - ABILITY_EXTENDED
 jr z, .cureStatus
 cp AB_DISCIPLINE - ABILITY_EXTENDED
 ret nz
.cureStatus
 ld hl, wBattleMonStatus
 ld de, wPlayerBattleStatus3
 ld a, [wAbilitySide]
 and a
 jr z, .status
 ld hl, wEnemyMonStatus
 ld de, wEnemyBattleStatus3
.status
 ld a, [hl]
 and a
 ret z
 xor a
 ld [hl], a
 ld a, [de]
 res BADLY_POISONED, a
 ld [de], a
 ld hl, wPlayerToxicCounter
 ld a, [wAbilitySide]
 and a
 jr z, .toxic
 ld hl, wEnemyToxicCounter
.toxic
 xor a
 ld [hl], a
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 callab CustomRecalculate
 jpab UtilitySyncParty
.download
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_DOWNLOAD - ABILITY_EXTENDED
 ret nz
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld a, [wAbilitySide]
 push af
 xor 1
 ld [wAbilitySide], a
 ld hl, wBattleMonSpecies
 and a
 jr z, .downloadSpecies
 ld hl, wEnemyMonSpecies
.downloadSpecies
 ld a, [hl]
 and a
 jr z, .downloadMissing
 callab AbilityHP
 ld a, [hli]
 or [hl]
 jr z, .downloadMissing
 ld hl, wBattleMonDefense
 ld de, wBattleMonSpecial
 ld a, [wAbilitySide]
 and a
 jr z, .compare
 ld hl, wEnemyMonDefense
 ld de, wEnemyMonSpecial
.compare
 ld a, [de]
 ld b, a
 ld a, [hli]
 cp b
 jr c, .attack
 jr nz, .special
 inc de
 ld a, [de]
 ld b, a
 ld a, [hl]
 cp b
 jr c, .attack
.special
 ld a, 3
 jr .raise
.attack
 xor a
.raise
 ld [wCustomStat], a
 pop af
 ld [wAbilitySide], a
 ld [wCustomSide], a
 ld a, 1
 ld [wCustomDelta], a
 xor a
 ld [wCustomChanged], a
 jpab CustomChangeStage
.downloadMissing
 pop af
 ld [wAbilitySide], a
 ret

; One random decision per actual player action, including Metronome re-entry.
; Parental scratch bits 5 and 4 mark the roll and a pending PP refund.
AbilityConservativeMaybe:
 ld a, [wParentalState]
 bit 5, a
 ret nz
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_CONSERVATIVE - ABILITY_EXTENDED
 jr z, .conservative
 cp AB_EFFICIENT - ABILITY_EXTENDED
 ret nz
 callab AbilityMove
 ld a, [hl]
 cp BIDE
 jr z, .efficientDamaging
 inc hl
 inc hl
 ld a, [hl]
 and a
 ret z
.efficientDamaging
 ld hl, wParentalState
 set 5, [hl]
.retryEfficient
 callab CustomRandomInBattleBank
 ld a, [wCustomRandomValue]
 cp 200
 jr nc, .retryEfficient
 cp 40
 ret nc
 ld hl, wParentalState
 set 4, [hl]
 ret
.conservative
 ld hl, wParentalState
 set 5, [hl]
 callab CustomRandomInBattleBank
 ld a, [wCustomRandomValue]
 cp 64
 ret nc
 ld hl, wParentalState
 set 4, [hl]
 ret

AbilityConservativeRefund:
 ld a, [H_WHOSETURN]
 and a
 ret nz ; enemy moves have unlimited PP in ordinary battles
 ld hl, wParentalState
 bit 4, [hl]
 ret z
 res 4, [hl]
 ld a, [wPlayerMoveListIndex]
 and 3
 ld c, a
 ld b, 0
 ld hl, wBattleMonPP
 add hl, bc
 ld a, [hl]
 and $3f
 ld b, a
 ld a, [wAbilityPPLeft]
 cp b
 ret z
 ret c ; never increase PP that did not actually decrease
 inc [hl]
 ld a, [wPlayerBattleStatus3]
 bit TRANSFORMED, a
 ret nz
 ld a, [wPlayerMonNumber]
 ld hl, wPartyMon1PP
 ld bc, wPartyMon2 - wPartyMon1
 call AddNTimes
 ld a, [wPlayerMoveListIndex]
 and 3
 ld c, a
 ld b, 0
 add hl, bc
 inc [hl]
 ret

AbilityAntivirusTarget:
 xor a
 ld [wAbilityCheckResult], a
 callab AbilityTarget
 jr AbilityAntivirusOpponentResolved
AbilityAntivirusActor:
 xor a
 ld [wAbilityCheckResult], a
 callab AbilityActor
 jr AbilityAntivirusResolved
; Reactive effects originate from the opponent even though their victim acted.
AbilityAntivirusReactiveActor:
 xor a
 ld [wAbilityCheckResult], a
 callab AbilityActor
 jr AbilityAntivirusOpponentResolved
AbilityAntivirusCustom:
 xor a
 ld [wAbilityCheckResult], a
 callab AbilityGetCustomSide
 ld a, [wAbilityResolvedExtended]
 cp AB_DOMINANCE - ABILITY_EXTENDED
 jr nz, AbilityAntivirusResolved
 ld a, [wCustomSide]
 ld b, a
 ld a, [H_WHOSETURN]
 cp b
 ret z ; self-inflicted status is allowed
 jr AbilityAntivirusBlock
AbilityAntivirusOpponentResolved:
 ld a, [wAbilityResolvedExtended]
 cp AB_DOMINANCE - ABILITY_EXTENDED
 jr z, AbilityAntivirusBlock
AbilityAntivirusResolved:
 ld a, [wAbilityResolvedExtended]
 cp AB_ANTIVIRUS - ABILITY_EXTENDED
 jr z, AbilityAntivirusBlock
 cp AB_DISCIPLINE - ABILITY_EXTENDED
 ret nz
AbilityAntivirusBlock:
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilityAntivirusSleepCheck:
 xor a
 ld [wAbilityCheckResult], a
 call ConditionalActorMove
 inc hl
 ld a, [hl]
 cp SLEEP_EFFECT
 ret nz
 jp AbilityAntivirusTarget

; The roll hook covers the legacy burn, freeze and paralysis secondary paths.
AbilityAntivirusSecondaryRoll:
 xor a
 ld [wAbilityCheckResult], a
 call ConditionalActorMove
 inc hl
 ld a, [hl]
 cp BURN_SIDE_EFFECT1
 jr z, .check
 cp BURN_SIDE_EFFECT2
 jr z, .check
 cp FREEZE_SIDE_EFFECT
 jr z, .check
 cp PARALYZE_SIDE_EFFECT1
 jr z, .check
 cp PARALYZE_SIDE_EFFECT2
 ret nz
.check
 jp AbilityAntivirusTarget

DecrementPPBanked:
; after using a move, decrement pp in battle and (if not transformed?) in party
	ld a, [de]
	cp STRUGGLE
	ret z                ; if the pokemon is using "struggle", there's nothing to do
	                     ; we don't decrement PP for "struggle"
	ld hl, wPlayerBattleStatus1
	ld a, [hli]          ; load the wPlayerBattleStatus1 pokemon status flags and increment hl to load the
	                     ; wPlayerBattleStatus2 status flags later
	and (1 << STORING_ENERGY) | (1 << THRASHING_ABOUT) | (1 << ATTACKING_MULTIPLE_TIMES)
	ret nz               ; if any of these statuses are true, don't decrement PP
	bit USING_RAGE, [hl]
	ret nz               ; don't decrement PP either if Pokemon is using Rage
	callab AbilityConservativeMaybe
	ld hl, wBattleMonPP  ; PP of first move (in battle)

; decrement PP in the battle struct
	call .DecrementPP

; decrement PP in the party struct
	ld a, [wPlayerBattleStatus3]
	bit TRANSFORMED, a
	ret nz               ; Return if transformed. Pokemon Red stores the "current pokemon's" PP
	                     ; separately from the "Pokemon in your party's" PP.  This is
	                     ; duplication -- in all cases *other* than Pokemon with Transform.
	                     ; Normally, this means we have to go on and make the same
	                     ; modification to the "party's pokemon" PP that we made to the
	                     ; "current pokemon's" PP.  But, if we're dealing with a Transformed
	                     ; Pokemon, it has separate PP for the move set that it copied from
	                     ; its opponent, which is *not* the same as its real PP as part of your
	                     ; party.  So we return, and don't do that part.

	ld hl, wPartyMon1PP  ; PP of first move (in party)
	ld a, [wPlayerMonNumber] ; which mon in party is active
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes       ; calculate address of the mon to modify
.DecrementPP:
	ld a, [wPlayerMoveListIndex] ; which move (0, 1, 2, 3) did we use?
	ld c, a
	ld b, 0
	add hl ,bc           ; calculate the address in memory of the PP we need to decrement
	                     ; based on the move chosen.
	dec [hl]             ; Decrement PP
	ret

AbilityDustOnlyBanked:
 call AbilityAntivirusTarget
 ld a, [wAbilityCheckResult]
 and a
 ret nz
 callab AbilityTargetResult
 ld a, [wAbilityCheckResult]
 cp AB_IMMUNITY
 jr z, .block
 cp AB_SHIELD_DUST
 jr nz, .clear
 callab AbilityMove
 inc hl
 inc hl
 ld a, [hl]
 and a
 jr z, .clear
.block
 ld a, 1
 ld [wAbilityCheckResult], a
 ret
.clear
 xor a
 ld [wAbilityCheckResult], a
 ret

AbilityVeilOnlyBanked:
 call AbilityAntivirusTarget
 ld a, [wAbilityCheckResult]
 and a
 ret nz
 callab AbilityTargetResult
 ld a, [wAbilityCheckResult]
 cp AB_WATER_VEIL
 jr z, .block
 xor a
 ld [wAbilityCheckResult], a
 ret
.block
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilityLimberTargetBanked:
 call AbilityAntivirusTarget
 ld a, [wAbilityCheckResult]
 and a
 ret nz
 callab AbilityTargetResult
 ld a, [wAbilityCheckResult]
 cp AB_LIMBER
 jr z, .block
 xor a
 ld [wAbilityCheckResult], a
 ret
.block
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilityBurnGateBanked:
 call AbilityAntivirusCustom
 ld a, [wAbilityCheckResult]
 and a
 ret nz
 ld a, [wCustomDelta]
 cp 1 << FRZ
 jr nz, .notFreeze
 callab AbilityGetCustomSide
 ld a, [wAbilityResolvedExtended]
 cp AB_MAGMA_ARMOR - ABILITY_EXTENDED
 jr z, .block
 jr .clear
.notFreeze
 cp 1 << PAR
 jr nz, .notParalysis
 callab AbilityGetCustomSideResult
 ld a, [wAbilityCheckResult]
 cp AB_LIMBER
 jr z, .block
 jr .clear
.notParalysis
 cp 1 << PSN
 jr nz, .burn
 callab AbilityGetCustomSideResult
 ld a, [wAbilityCheckResult]
 cp AB_IMMUNITY
 jr z, .block
 jr .clear
.burn
 cp 1 << BRN
 jr nz, .clear
 callab AbilityTargetResult
 ld a, [wAbilityCheckResult]
 cp AB_WATER_VEIL
 jr z, .block
.clear
 xor a
 ld [wAbilityCheckResult], a
 ret
.block
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

; Shared battle move flags are read through a banked lookup.
INCLUDE "data/ability_move_metadata.asm"

; Roll once per damaging attack, including hits on a substitute.
AbilityAncientPowerOnHit:
 ld a, [wAbilityHit]
 bit 1, a
 ret nz
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_ANCIENT_POWER - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab AbilityFlagsPointer
 bit 2, [hl]
 ret nz
 ; For substitute hits the ordinary hit pipeline does not set this bit.
 ld a, [wCustomTargetHadSub]
 and a
 jr z, .roll
 ld hl, wAbilityHit
 set 1, [hl]
.roll
 callab CustomRandomInBattleBank
 ld a, [wCustomRandomValue]
 cp 200
 jr nc, .roll
 cp 20
 ret nc
 callab AbilityFlagsPointer
 set 2, [hl]
 ld b, 0
.loop
 push bc
 ld a, [H_WHOSETURN]
 ld [wCustomSide], a
 ld a, b
 ld [wCustomStat], a
 ld a, 1
 ld [wCustomDelta], a
 callab CustomChangeStage
 pop bc
 inc b
 ld a, b
 cp 4
 jr c, .loop
 ret

; The entry dispatcher calls this for each battler once both are ready.
; Wolf entry effects may repeat after switching, unlike once-per-battle auras.
; Double the chosen physical Attack before the joint 8-bit stat scaling.
; If it exceeds the legacy 10-bit range, halve both sides first.
AbilityHugePowerScale:
 push bc
 push de
 push hl
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_HUGE_POWER - ABILITY_EXTENDED
 jr nz, .unchanged
 ld a, [H_WHOSETURN]
 and a
 ld hl, wPlayerMoveType
 ld de, wPlayerMoveNum
 jr z, .move
 ld hl, wEnemyMoveType
 ld de, wEnemyMoveNum
.move
 ld a, [de]
 cp STONE_PRESS
 jr z, .unchanged
 cp SHOCK_FANG
 jr z, .double
 ld a, [hl]
 cp FIRE
 jr nc, .unchanged
.double
 pop hl
 pop de
 pop bc
 add hl, hl
 ld a, h
 cp 4
 ret c
 srl h
 rr l
 srl b
 rr c
 ld a, b
 or c
 ret nz
 inc c
 ret
.unchanged
 pop hl
 pop de
 pop bc
 ret

; Block targeted moves with positive priority, including ability-granted priority.
AbilityPreparedCheck:
 xor a
 ld [wAbilityCheckResult], a
 callab AbilityTarget
 ld a, [wAbilityResolvedExtended]
 cp AB_PREPARED - ABILITY_EXTENDED
 jr z, .priority
 xor a
 ld [wAbilityCheckResult], a
 ret
.priority
 ld a, [wAbilitySide]
 push af
 ld a, [wAbilityTemp]
 push af
 ld a, [wAbilityTemp + 1]
 push af
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityPriorityResult
 ld a, [wAbilityCheckResult]
 bit 7, a
 jr nz, .notPriority
 and a
 jr z, .notPriority
 ld a, 1
 jr .result
.notPriority
 xor a
.result
 ld [wAbilityCheckResult], a
 pop af
 ld [wAbilityTemp + 1], a
 pop af
 ld [wAbilityTemp], a
 pop af
 ld [wAbilitySide], a
 ret

AbilityWolfEntry:
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_WOLF_TERRIFYING - ABILITY_EXTENDED
 jr z, .target
 cp AB_BLUFF - ABILITY_EXTENDED
 ret nz
 callab CustomRandomInBattleBank
 ld a, [wCustomRandomValue]
 cp 128
 ret nc
.target
 ld a, [wAbilitySide]
 push af
 xor 1
 ld [wAbilitySide], a
 ld [wCustomSide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 jr z, .done
 callab AbilityGetCustomSideResult
 ld a, [wAbilityCheckResult]
 cp AB_CLEAR_BODY
 jr z, .done
 ld a, [wAbilityResolvedExtended]
 cp AB_DOMINANCE - ABILITY_EXTENDED
 jr z, .done
 xor a
 ld [wCustomStat], a
 dec a
 ld [wCustomDelta], a
 xor a
 ld [wCustomChanged], a
 callab CustomChangeStage
.done
 pop af
 ld [wAbilitySide], a
 ret

AbilityTerrifying:
 call AbilityWolfEntry
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_TYRANITAR_TERRIFYING - ABILITY_EXTENDED
 jr z, .targetCheck
 cp AB_TERRIFYING - ABILITY_EXTENDED
 ret nz
 callab AbilityFlagsPointer
 bit 6, [hl]
 ret nz
.targetCheck
 ld a, [wAbilitySide]
 push af
 xor 1
 ld [wAbilitySide], a
 and a
 jr nz, .targetReady
 ld a, [wBattleMonSpecies]
 and a
 jr z, .restore
.targetReady
 callab AbilityHP
 ld a, [hli]
 or [hl]
 jr z, .restore
 ; Spend the holder's use even if the target prevents the stat drop.
 ld a, [wAbilitySide]
 xor 1
 ld [wAbilitySide], a
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_TYRANITAR_TERRIFYING - ABILITY_EXTENDED
 jr z, .noSpend
 callab AbilityFlagsPointer
 set 6, [hl]
.noSpend
 ld a, [wAbilitySide]
 xor 1
 ld [wAbilitySide], a
 ld [wCustomSide], a
 callab AbilityGetCustomSideResult
 ld a, [wAbilityCheckResult]
 cp AB_CLEAR_BODY
 jr z, .restore
 cp ABILITY_EXTENDED
 jr nz, .defense
 ld a, [wAbilityResolvedExtended]
 cp AB_DOMINANCE - ABILITY_EXTENDED
 jr z, .restore
.defense
 ld a, 1 ; Defense
 ld [wCustomStat], a
 ld a, -1
 ld [wCustomDelta], a
 xor a
 ld [wCustomChanged], a
 callab CustomChangeStage
.restore
 pop af
 ld [wAbilitySide], a
 ret

; Sleepwalker still ticks sleep normally, but does not lose its action.
AbilitySleepwalkerCheck:
 xor a
 ld [wAbilityCheckResult], a
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_SLEEPWALKER - ABILITY_EXTENDED
 ret nz
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

; Fixed-damage attacks are calculated after the ordinary damage pipeline.
AbilitySleepwalkerDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilitySleepwalkerFixedDamage:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_SLEEPWALKER - ABILITY_EXTENDED
 ret nz
 ld hl, wBattleMonStatus
 ld a, [H_WHOSETURN]
 and a
 jr z, .status
 ld hl, wEnemyMonStatus
.status
 ld a, [hl]
 and SLP
 ret z
 ld hl, wDamage
 ld a, [hli]
 or [hl]
 ret z
 dec hl
 srl [hl]
 inc hl
 rr [hl]
 ld a, [hld]
 or [hl]
 ret nz
 inc hl
 inc [hl] ; nonzero damaging moves retain minimum 1 damage
 ret

AbilityHeavySleeperBoth:
 xor a
 ld [wAbilitySide], a
 call .one
 ld a, 1
 ld [wAbilitySide], a
.one
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_HEAVY_SLEEPER - ABILITY_EXTENDED
 ret nz
 callab AbilityHP
 inc hl
 inc hl
 inc hl
 ld a, [hl]
 and SLP
 ret z
 jpab AbilityRegeneration

; Shared type-chart overrides for battle damage and AI scoring.
AbilityTypeOverrideBanked:
 ld a, [wAbilityCheckResult]
 push af
 xor a
 ld [wAbilityCheckResult], a
 pop af
 ; The neutral chart entry makes Bug/Rock available to the shared hooks.
 push af
 ld a, [wAbilityTemp]
 cp ROCK
 jr nz, .otherMatchup
 ld a, [wAbilityTemp + 1]
 cp BUG
 jr nz, .otherMatchup
 pop af
 cp ABILITY_EXTENDED
 jr nz, .bugRockNeutral
 ld a, [wAbilityResolvedExtended]
 cp AB_ARMOR_CRUSHER - ABILITY_EXTENDED
 jr nz, .bugRockNeutral
 ld a, 20
 jr .bugRockStore
.bugRockNeutral
 ld a, 10
.bugRockStore
 ld [wAbilityCheckResult], a
 ret
.otherMatchup
 pop af
 cp AB_ICEBREAKER
 jr nz, .notIcebreaker
 ld a, [wAbilityTemp]
 cp WATER
 ret nz
 ld a, [wAbilityTemp + 1]
 cp ICE
 ret nz
 ld a, 20
 ld [wAbilityCheckResult], a
 ret
.notIcebreaker
 cp AB_CORROSIVE_VENOM
 jr nz, .scrappy
 ld a, [wAbilityTemp]
 cp ROCK
 ret nz
 ld a, [wAbilityTemp + 1]
 cp POISON
 ret nz
 ld a, 20
 ld [wAbilityCheckResult], a
 ret
.scrappy
 cp AB_SCRAPPY
 jr z, .scrappyMatch
 cp ABILITY_EXTENDED
 ret nz
 ld a, [wAbilityResolvedExtended]
 cp AB_ABSOLUTE_ZERO - ABILITY_EXTENDED
 jr nz, .checkMindsEye
 ld a, [wAbilityTemp + 1]
 cp ICE
 ret nz
 ld a, [wCustomRandomValue]
 cp 5
 ret nz
 jr .neutral
.checkMindsEye
 cp AB_MINDS_EYE - ABILITY_EXTENDED
 ret nz
.scrappyMatch
 ld a, [wAbilityTemp]
 cp GHOST
 ret nz
 ld a, [wAbilityTemp + 1]
 cp NORMAL
 jr z, .neutral
 cp FIGHTING
 ret nz
.neutral
 ld a, 10
 ld [wAbilityCheckResult], a
 ret

; Read the selected move's actual type before move execution has begun.
AbilityLightningSpeedMove:
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wAbilityTemp + 1]
 and a
 ret z
 cp MAX_MOVE_ID + 1
 ret nc
 dec a
 ld l, a
 ld h, 0
 add hl, hl
 ld d, h
 ld e, l
 add hl, hl
 add hl, de ; six-byte move record
 ld de, Moves + 3 ; type field
 add hl, de
 ld de, wAbilityCheckResult
 ld bc, 1
 ld a, BANK(Moves)
 call FarCopyData
 ld a, [wAbilityCheckResult]
 cp ELECTRIC
 ld a, 0
 jr nz, .store
 inc a
.store
 ld [wAbilityCheckResult], a
 ret

; The shared after-hit path already checked damage, Substitute, target HP,
; and Shield Dust before this guaranteed burn.
AbilityIntenseFlamesOnHit:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_INTENSE_FLAMES - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 xor 1
 ld [wCustomSide], a
 ld a, 1 << BRN
 ld [wCustomDelta], a
 jpab UtilityInflictStatus

; Mystic Scales and Multiscale apply to actual and fixed damage.
AbilityDragonScalesDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityDragonScalesFixedDamage:
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 callab AbilityTarget
 ld a, [wAbilityResolvedExtended]
 cp AB_MYSTIC_SCALES - ABILITY_EXTENDED
 jr z, .special
 cp AB_MULTISCALE - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 dec hl
 ld a, [de]
 cp [hl]
 ret nz
 inc de
 inc hl
 ld a, [de]
 cp [hl]
 ret nz
 ld c, 50
 jp AbilityFluffyFixedDamage.scale
.special
 ld hl, wPlayerMoveType
 ld a, [H_WHOSETURN]
 and a
 jr z, .type
 ld hl, wEnemyMoveType
.type
 ld a, [hl]
 cp FIRE
 ret c
 ld c, 80
 jp AbilityFluffyFixedDamage.scale

; A Dragon move can grant one Evasion stage once per battle.
AbilitySerpentGraceAfterAction:
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_SERPENT_GRACE - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 and a
 ld hl, wPlayerMoveType
 jr z, .move
 ld hl, wEnemyMoveType
.move
 ld a, [hl]
 cp DRAGON
 ret nz
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab AbilityFlagsPointer
 bit 2, [hl]
 ret nz
 set 2, [hl]
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 ld a, 5
 ld [wCustomStat], a
 ld a, 1
 ld [wCustomDelta], a
 xor a
 ld [wCustomChanged], a
 jpab CustomChangeStage

; A status condition grants one reversible Defense stage.
AbilityMarvelScaleEntry:
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_MARVEL_SCALE - ABILITY_EXTENDED
 ret nz
 callab AbilityFlagsPointer
 res 0, [hl]
 jr AbilityMarvelScale.apply
AbilityMarvelScale:
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_MARVEL_SCALE - ABILITY_EXTENDED
 jr z, .apply
 ; A suppressed holder must lose its existing temporary stage.
 ld a, [wAbilitySide]
 and a
 ld hl, wActiveAbilities
 jr z, .rawAbility
 inc hl
.rawAbility
 ld a, [hl]
 cp ABILITY_EXTENDED
 ret nz
 ld a, [wAbilitySide]
 and a
 ld hl, wActiveAbilityExtended
 jr z, .rawExtended
 inc hl
.rawExtended
 ld a, [hl]
 cp AB_MARVEL_SCALE - ABILITY_EXTENDED
 ret nz
 jr .healthy
.apply
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 inc hl
 inc hl
 ld a, [hl]
 and a
 jr z, .healthy
 callab AbilityFlagsPointer
 bit 0, [hl]
 ret nz
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 ld a, 1
 ld [wCustomStat], a
 ld [wCustomDelta], a
 xor a
 ld [wCustomChanged], a
 callab CustomChangeStage
 ld a, [wCustomChanged]
 and a
 ret z
 callab AbilityFlagsPointer
 set 0, [hl]
 ret
.healthy
 callab AbilityFlagsPointer
 bit 0, [hl]
 ret z
 res 0, [hl]
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 ld a, 1
 ld [wCustomStat], a
 xor a
 ld [wCustomChanged], a
 dec a
 ld [wCustomDelta], a
 jpab CustomChangeStage

AbilityMarvelScaleHazeReset:
 ; Haze resets stages even if Neutralizing Gas suppresses this ability.
 ld a, [wAbilitySide]
 and a
 ld hl, wActiveAbilities
 jr z, .rawAbility
 inc hl
.rawAbility
 ld a, [hl]
 cp ABILITY_EXTENDED
 ret nz
 ld a, [wAbilitySide]
 and a
 ld hl, wActiveAbilityExtended
 jr z, .rawExtended
 inc hl
.rawExtended
 ld a, [hl]
 cp AB_MARVEL_SCALE - ABILITY_EXTENDED
 ret nz
 callab AbilityFlagsPointer
 res 0, [hl]
 ret

AbilitySteadfastActorBanked:
 callab AbilityActorResult
 ld a, [wAbilityCheckResult]
 cp ABILITY_EXTENDED
 jr nz, .ordinary
 ld a, [wAbilityResolvedExtended]
 cp AB_INNER_FOCUS - ABILITY_EXTENDED
 jr z, .immune
 cp AB_DISCIPLINE - ABILITY_EXTENDED
 jr z, .immune
 cp AB_UNSTOPPABLE - ABILITY_EXTENDED
 ret nz
 ld hl, wPlayerBattleStatus1
 ld a, [H_WHOSETURN]
 and a
 jr z, .clearFlinch
 ld hl, wEnemyBattleStatus1
.clearFlinch
 res FLINCHED, [hl]
 ret
.ordinary
 cp AB_STEADFAST
 jr z, .immune
 cp AB_OBLIVIOUS
 jr z, .immune
 cp AB_HEADSTRONG
 ret nz
 ld hl, wPlayerBattleStatus1
 ld a, [H_WHOSETURN]
 and a
 jr z, .clearConfusion
 ld hl, wEnemyBattleStatus1
.clearConfusion
 res CONFUSED, [hl]
 ret
.immune
 ld hl, wPlayerBattleStatus1
 ld a, [H_WHOSETURN]
 and a
 jr z, .clear
 ld hl, wEnemyBattleStatus1
.clear
 res CONFUSED, [hl]
 res FLINCHED, [hl]
 ret

; Actor's stat is being lowered by a defender's contact ability.
AbilityBlockReactiveStatDrop:
 callab AbilityActorResult
 ld a, [wAbilityCheckResult]
 cp AB_CLEAR_BODY
 ret z
 cp ABILITY_EXTENDED
 ret nz
 ld a, [wAbilityResolvedExtended]
 cp AB_DOMINANCE - ABILITY_EXTENDED
 ret

; Treat nonmatching move types as matching for the ordinary STAB calculation.
AbilityAncestorCheck:
 xor a
 ld [wAbilityCheckResult], a
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_ANCESTOR - ABILITY_EXTENDED
 ret nz
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

; Critical immunity is checked first; only genuinely damaging moves qualify.
AbilityMercilessCheck:
 xor a
 ld [wAbilityCheckResult], a
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_MERCILESS - ABILITY_EXTENDED
 ret nz
 callab AbilityMove
 ld a, [hli]
 cp COUNTER
 ret z
 cp BIDE
 ret z
 ld a, [hli]
 cp SPECIAL_DAMAGE_EFFECT
 ret z
 cp SUPER_FANG_EFFECT
 ret z
 ld a, [hl]
 and a
 ret z
 callab AbilityTargetStatus
 bit PSN, [hl]
 ret z
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilitySpinyArmorBanked:
	callab AbilityActorResult
	ld a, [wAbilityCheckResult]
	cp AB_MAGIC_GUARD
	ret z
	callab AbilityTargetResult
	ld a, [wAbilityCheckResult]
	cp AB_SPINY_ARMOR
	jr z, .physical
	cp AB_SPIKED_SHELL
	jr z, .physical
	cp ABILITY_EXTENDED
	ret nz
	ld a, [wAbilityResolvedExtended]
	cp AB_SPIKY_FUR - ABILITY_EXTENDED
	jr z, .physical
	cp AB_BARBED_SHELL - ABILITY_EXTENDED
	jr z, .contact
	cp AB_CONTACT_SPIKED_SHELL - ABILITY_EXTENDED
	ret nz
.contact
	callab AbilityActorContactResult
	ld a, [wAbilityCheckResult]
	bit 1, a
	ret z
	jr .damage
.physical
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
.damage
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	callab AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	dec hl
	push hl
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	rept 3
	srl b
	rr c
	endr
	ld a, [wAbilityResolvedExtended]
	cp AB_BARBED_SHELL - ABILITY_EXTENDED
	jr z, .fractionReady
	srl b
	rr c
.fractionReady
	ld a, b
	or c
	jr nz, .amount
	inc c
.amount
	pop hl
	ld a, [hli]
	ld d, a
	ld a, [hl]
	sub c
	ld e, a
	ld a, d
	sbc b
	jr nc, .store
	xor a
	ld e, a
.store
	ld [hl], e
	dec hl
	ld [hl], a
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	callab UtilitySyncParty
	callab DrawHUDsAndHPBars
	callab AbilityTargetResult
	ld a, [wAbilityCheckResult]
	cp ABILITY_EXTENDED
	jr nz, .standardText
	ld a, [wAbilityResolvedExtended]
	cp AB_SPIKY_FUR - ABILITY_EXTENDED
	jp z, AbilitySpikyFurMessageBanked
	cp AB_CONTACT_SPIKED_SHELL - ABILITY_EXTENDED
	jr z, .spikedText
	callab AbilityTargetResult
	ld a, [wAbilityCheckResult]
.standardText
	cp AB_SPIKED_SHELL
	ld hl, AbilitySpinyArmorText
	jr nz, .print
	ld hl, AbilitySpikedShellText
	jr .print
.spikedText
	ld hl, AbilitySpikedShellText
.print
	jp PrintText

AbilitySpikedShellText:
	text "Hurt by"
	line "SPIKED SHELL!"
	prompt

AbilitySpinyArmorText:
	text "Hurt by"
	line "SPINY ARMOR!"
	prompt

; Added species damage modifiers, including fixed-damage attacks.
AbilityAddedSpeciesDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityAddedSpeciesFixedDamage:
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_TRICKSTER - ABILITY_EXTENDED
 jr z, .trickster
 cp AB_SHADOW_AMBUSH - ABILITY_EXTENDED
 jr z, .shadow
 cp AB_TECTONIC_WRATH - ABILITY_EXTENDED
 jr z, .ground
 cp AB_KINDLING - ABILITY_EXTENDED
 jr z, .kindling
 callab AbilityTarget
 ld a, [wAbilityResolvedExtended]
 cp AB_CLAY_ARMOR - ABILITY_EXTENDED
 ret nz
 call .moveType
 cp WATER
 ret nz
 ld c, 50
 jp AbilityFluffyFixedDamage.scale
.kindling
 call .moveType
 cp FIRE
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityRolloutSidePointer
 ld a, [hl]
 and a
 ret z
 ld c, 130
 jp AbilityFluffyFixedDamage.scale
.trickster
 call ConditionalTargetStatus1
 bit CONFUSED, [hl]
 ret z
 ld c, 125
 jp AbilityFluffyFixedDamage.scale
.shadow
 call .moveType
 cp GHOST
 ret nz
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 dec hl
 ld a, [de]
 cp [hl]
 ret nz
 inc de
 inc hl
 ld a, [de]
 cp [hl]
 ret nz
 ld c, 130
 jp AbilityFluffyFixedDamage.scale
.ground
 call .moveType
 cp GROUND
 ret nz
 ld c, 150
 jp AbilityFluffyFixedDamage.scale
.moveType
 ld a, [H_WHOSETURN]
 and a
 ld hl, wPlayerMoveType
 jr z, .read
 ld hl, wEnemyMoveType
.read
 ld a, [hl]
 ret

; Each Water hit that damages a living holder raises Attack two stages.
AbilityClayArmorOnHit:
 callab AbilityTarget
 ld a, [wAbilityResolvedExtended]
 cp AB_CLAY_ARMOR - ABILITY_EXTENDED
 ret nz
 ld a, [wAbilityMoveType]
 cp WATER
 ret nz
 ld a, [H_WHOSETURN]
 xor 1
 ld [wCustomSide], a
 xor a
 ld [wCustomStat], a
 ld [wCustomChanged], a
 ld a, 2
 ld [wCustomDelta], a
 jpab CustomChangeStage

; Every executed punch raises one randomly chosen stage, with equal odds.
AbilityShadowBoxingAfterAction:
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_SHADOW_BOXING - ABILITY_EXTENDED
 ret nz
 callab AbilityActorContactResult
 ld a, [wAbilityCheckResult]
 bit 7, a
 ret z
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab CustomRandomInBattleBank
 ld a, [wCustomRandomValue]
 and 1
 ld a, 2 ; Speed
 jr z, .stat
 ld a, 5 ; Evasion
.stat
 ld [wCustomStat], a
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 ld a, 1
 ld [wCustomDelta], a
 xor a
 ld [wCustomChanged], a
 jpab CustomChangeStage

; Onix reduces only the first direct super-effective hit per battle.
AbilityIndomitableIncoming:
 ld a, [wAbilityHit]
 bit 5, a
 ret z
 ld a, [wCustomTargetHadSub]
 and a
 ret nz
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 ld a, [wDamageMultipliers]
 and $7f
 cp 11
 ret c
 callab AbilityTarget
 ld a, [wAbilityResolvedExtended]
 cp AB_INDOMITABLE - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab AbilityFlagsPointer
 bit 2, [hl]
 ret nz
 set 2, [hl]
 ld a, [wCriticalHitOrOHKO]
 cp 2
 jr nz, .scale
 xor a
 ld [wCriticalHitOrOHKO], a
 callab AbilityHP
 ld a, [hli]
 ld [wDamage], a
 ld a, [hl]
 ld [wDamage + 1], a
.scale
 ld hl, wDamage
 srl [hl]
 inc hl
 rr [hl]
 ld a, [hld]
 or [hl]
 ret nz
 inc hl
 inc [hl]
 ret

; Nidoking's bonus applies to physical damage against poisoned targets.
AbilitySinisterDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilitySinisterFixedDamage:
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_SINISTER - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 and a
 ld hl, wPlayerMoveType
 jr z, .type
 ld hl, wEnemyMoveType
.type
 ld a, [hl]
 cp FIRE
 ret nc
 callab AbilityTargetStatus
 bit PSN, [hl]
 ret z
 ld c, 125
 jp AbilityFluffyFixedDamage.scale

; Poisoned living foe enables 1/8 healing at round end.
AbilityRecoveryBoth:
 xor a
 ld [wAbilitySide], a
 call .one
 ld a, 1
 ld [wAbilitySide], a
.one
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_RECOVERY - ABILITY_EXTENDED
 ret nz
 ld a, [wAbilitySide]
 xor 1
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 jr z, .restore
 inc hl
 inc hl
 bit PSN, [hl]
 jr z, .restore
 ld a, [wAbilitySide]
 xor 1
 ld [wAbilitySide], a
 jr AbilityBossHealEighth
.restore
 ld a, [wAbilitySide]
 xor 1
 ld [wAbilitySide], a
 ret

; Each executed Grass-type move heals the living holder.
AbilityBigBloomAfterAction:
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_BIG_BLOOM - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 and a
 ld hl, wPlayerMoveType
 jr z, .type
 ld hl, wEnemyMoveType
.type
 ld a, [hl]
 cp GRASS
 ret nz
AbilityBossHealEighth:
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 ld a, 3
 ld [wCustomDelta], a
 ld a, 1
 ld [wCustomChance], a
 jpab ResidualFraction

; Once-per-battle stage changes on qualifying damaging hits.
AbilityDuelistOnHit:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_DUELIST - ABILITY_EXTENDED
 ret nz
 callab AbilityMove
 inc hl
 inc hl
 inc hl
 ld a, [hl]
 cp FIGHTING
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld a, 1 ; Defense
 jr AbilityOneHitStage

AbilityShellReflexOnHit:
 ld a, [wAbilityMoveType]
 cp FIRE
 ret nc
 callab AbilityTarget
 ld a, [wAbilityResolvedExtended]
 cp AB_SHELL_REFLEX - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 ld a, 2 ; Speed
 jp AbilityOneHitStage

AbilityLightweightOnHit:
 ld a, [wAbilityMoveType]
 cp FIRE
 ret nc
 callab AbilityTarget
 ld a, [wAbilityResolvedExtended]
 cp AB_LIGHTWEIGHT - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 ld a, 5 ; Evasion
 jp AbilityOneHitStage

AbilityOneHitStage:
 push af
 callab AbilityFlagsPointer
 bit 2, [hl]
 jr nz, .used
 set 2, [hl]
 pop af
 ld [wCustomStat], a
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 ld a, 1
 ld [wCustomDelta], a
 xor a
 ld [wCustomChanged], a
 jpab CustomChangeStage
.used
 pop af
 ret

AbilityKindlingAfterAction:
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_KINDLING - ABILITY_EXTENDED
 ret nz
 callab AbilityMove
 inc hl
 inc hl
 ld a, [hli]
 and a
 ret z
 ld a, [hl]
 cp NORMAL
 jr z, .arm
 cp FIRE
 ret nz
 xor a
 jr .store
.arm
 ld a, 1
.store
 push af
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityRolloutSidePointer
 pop af
 ld [hl], a
 ret

AbilityAncientMaliceOnHit:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_ANCIENT_MALICE - ABILITY_EXTENDED
 ret nz
.retry
 callab CustomRandomInBattleBank
 ld a, [wCustomRandomValue]
 cp 200
 jr nc, .retry
 cp 20
 ret nc
 ld a, [H_WHOSETURN]
 xor 1
 ld [wCustomSide], a
 jpab CustomConfuse

AbilityNewAfterAction:
 call AbilityKindlingAfterAction
 call AbilityBigBloomAfterAction
 call AbilityShedWoolBoth
 jp AbilityChargeUpAfterAction
AbilityNewActorHit:
 call AbilityDuelistOnHit
 jp AbilityAncientPowerOnHit
AbilityNewTargetHit:
 call AbilityClayArmorOnHit
 call AbilityShellReflexOnHit
 call AbilityLightweightOnHit
 call AbilityShedWoolOnHit
 jp AbilityChargeUpOnHit
AbilityNewSecondaryHit:
 call AbilityAncientMaliceOnHit
 jp AbilityIntenseFlamesOnHit

AbilityUniquePriority:
 ld a, [wAbilityResolvedExtended]
 cp AB_LIGHTNING_SPEED - ABILITY_EXTENDED
 jp z, AbilityLightningSpeedMove
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wAbilityResolvedExtended]
 cp AB_TOXIC_PURSUIT - ABILITY_EXTENDED
 ret nz
 ld a, [wAbilityTemp + 1]
 cp BIDE
 jr z, .checkPoison
 and a
 ret z
 cp MAX_MOVE_ID + 1
 ret nc
 dec a
 ld l, a
 ld h, 0
 add hl, hl
 ld d, h
 ld e, l
 add hl, hl
 add hl, de
 ld de, Moves + 2
 add hl, de
 ld de, wAbilityCheckResult
 ld bc, 1
 ld a, BANK(Moves)
 call FarCopyData
 ld a, [wAbilityCheckResult]
 and a
 jr z, .poison
 xor a
 ld [wAbilityCheckResult], a
 jr .checkPoison
.poison
 xor a
 ld [wAbilityCheckResult], a
 ret
.checkPoison
 ld hl, wEnemyMonStatus
 ld a, [wAbilitySide]
 and a
 jr z, .status
 ld hl, wBattleMonStatus
.status
 bit PSN, [hl]
 ret z
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

; Heal Bell has succeeded. Heal the active holder and each living reserve.
AbilityCaregiverAfterHealBell:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_CAREGIVER - ABILITY_EXTENDED
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 callab AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab AbilityFlagsPointer
 bit 2, [hl]
 ret nz
 set 2, [hl]
 call AbilityBossHealEighth
 ld a, [H_WHOSETURN]
 and a
 jr nz, .enemy
 ld hl, wPartyMon1HP
 ld a, [wPlayerMonNumber]
 ld [wCustomStat], a
 ld a, [wPartyCount]
 jr .count
.enemy
 ld a, [wIsInBattle]
 cp 2
 ret nz
 ld hl, wEnemyMon1HP
 ld a, [wEnemyMonPartyPos]
 ld [wCustomStat], a
 ld a, [wEnemyPartyCount]
.count
 cp 7
 jr c, .bounded
 ld a, 6
.bounded
 and a
 ret z
 ld b, a
 ld c, 0
.loop
 ld a, [wCustomStat]
 cp c
 jr z, .next
 push bc
 push hl
 ld a, [hli]
 ld b, a
 ld a, [hl]
 ld c, a
 or b
 jr z, .noHeal
 dec hl
 ld de, wPartyMon1MaxHP - wPartyMon1HP
 add hl, de
 ld a, [hli]
 ld d, a
 ld e, [hl]
 push de
 srl d
 rr e
 srl d
 rr e
 srl d
 rr e
 ld a, d
 or e
 jr nz, .fraction
 inc e
.fraction
 ld h, b
 ld l, c
 add hl, de
 pop de
 jr c, .maximum
 ld a, h
 cp d
 jr c, .write
 jr nz, .maximum
 ld a, l
 cp e
 jr c, .write
.maximum
 ld h, d
 ld l, e
.write
 ld d, h
 ld e, l
 pop hl
 ld a, d
 ld [hli], a
 ld [hl], e
 dec hl
 pop bc
 jr .next
.noHeal
 pop hl
 pop bc
.next
 push bc
 ld bc, wPartyMon2 - wPartyMon1
 add hl, bc
 pop bc
 inc c
 dec b
 jr nz, .loop
 ret

; Remember the slot replaced by a successful Duplicate until switching.
AbilityBorrowedRecord:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_BORROWED_STRENGTH - ABILITY_EXTENDED
 ret nz
 callab AbilityMove
 ld a, [hl]
 cp DUPLICATE
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 and a
 ld a, [wPlayerMoveListIndex]
 jr z, .slot
 ld a, [wEnemyMoveListIndex]
.slot
 inc a
 push af
 callab AbilityRolloutSidePointer
 pop af
 ld [hl], a
 ret

AbilityMultiAfterHit:
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_BORROWED_STRENGTH - ABILITY_EXTENDED
 jp nz, .ordinary
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 and a
 ld a, [wPlayerMoveListIndex]
 jr z, .slot
 ld a, [wEnemyMoveListIndex]
.slot
 inc a
 push af
 callab AbilityRolloutSidePointer
 pop af
 cp [hl]
 ret nz
 ld hl, wParentalState
 set 3, [hl] ; existing extra-hit engine uses half damage for this bit
 jpab AbilityParentalAfterHit.eligible
.ordinary
 jpab AbilityParentalAfterHit

AbilityHornSpecialistCheck:
 xor a
 ld [wAbilityCheckResult], a
 callab AbilityActor
 ld a, [wAbilityResolvedExtended]
 cp AB_HORN_SPECIALIST - ABILITY_EXTENDED
 ret nz
 callab AbilityMove
 ld a, [hl]
 jr AbilityHornSpecialistMove

AbilityHornSpecialistAICheck:
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wUnusedC000]
 bit 3, a
 ld a, 1
 jr z, .side
 xor a
.side
 ld [wAbilitySide], a
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_HORN_SPECIALIST - ABILITY_EXTENDED
 ret nz
 ld a, [wAbilitySide]
 and a
 ld a, [wPlayerMoveNum]
 jr z, AbilityHornSpecialistMove
 ld a, [wEnemyMoveNum]
AbilityHornSpecialistMove:
 cp HORN_ATTACK
 jr z, .yes
 cp PIERCE
 jr z, .yes
 cp HORN_DRILL
 ret nz
.yes
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

; Five byte-sized slots per pool, read across banks.
AbilityPoolIds:
	db AB_POISON_LEAF, AB_CHLOROPHYLL, AB_OVERGROWTH, AB_PHOTOSYNTHESIS, AB_VINE_GUARD
	db AB_BLAZE, AB_COMBUSTION, AB_WILDFIRE, AB_HOT_TEMPER, AB_CONFIDENT
	db AB_WATER_PRESSURE, AB_SHELL_GUARD, AB_ANCIENT, AB_WATER_VEIL, AB_SHELL_ARMOR
	db AB_RUN_AWAY, AB_REPULSIVE, AB_SURVIVAL_INSTINCTS, AB_QUICK_REFLEXES, AB_SHIELD_DUST
	db AB_HARD_SHELL, AB_FORTIFY, AB_REGENERATION, AB_QUICK_REFLEXES, AB_BATTLE_ARMOR
	db AB_COMPOUND_EYES, AB_PSIONIC, AB_DUST_CLOUD, AB_QUICK_REFLEXES, AB_WONDER_SKIN
	db AB_POISON_POINT, AB_REPULSIVE, AB_VENOMOUS, AB_PIERCING_STING, AB_SHIELD_DUST
	db AB_HARD_SHELL, AB_FORTIFY, AB_TOXIC_SHELL, AB_PIERCING_STING, AB_BATTLE_ARMOR
	db AB_RUTHLESS, AB_FRENZY, AB_VENOMOUS, AB_PIERCING_STING, AB_QUICK_REFLEXES
	db AB_TAILWIND, AB_PREDATOR, AB_KEEN_EYE, AB_PIERCING_BEAK, AB_GALE_WINGS
	db AB_SCAVENGER, AB_STRONG_JAW, AB_CORNERED, AB_HUSTLE, AB_POISON_HEAL
	db AB_RUTHLESS, AB_SHORT_TEMPER, AB_RELENTLESS, AB_PIERCING_BEAK, AB_SNIPER
	db AB_INTIMIDATE, AB_SHED_SKIN, AB_VENOMOUS, AB_PREDATOR, AB_CORROSIVE_VENOM
	db AB_STATIC, AB_VOLTAGE, AB_OVERCHARGE, AB_QUICK_REFLEXES, AB_QUICK_FEET
	db AB_ROLLING_DEFENSE, AB_SAND_ARMOR, AB_BURROWER, AB_SHARP_CLAWS, AB_SAND_VEIL
	db AB_SPINY_ARMOR, AB_SAND_ARMOR, AB_BURROWER, AB_SHARP_CLAWS, AB_SAND_VEIL
	db AB_PHYSICAL_POISON_POINT, AB_MEASURED, AB_THICK_HIDE, AB_PROTECTIVE_INSTINCT, AB_IRON_WILL
	db AB_PHYSICAL_POISON_POINT, AB_PIERCING_HORN, AB_SHEER_FORCE, AB_BLOODLUST, AB_RAMPAGE
	db AB_LUCKY_STAR, AB_MAGIC_GUARD, AB_MOON_CHILD, AB_UNPREDICTABLE, AB_WONDER_SKIN
	db AB_AFTERMATH, AB_FOXFIRE, AB_NINE_LIVES, AB_FOXS_CUNNING, AB_ILLUSION
	db AB_INFLATABLE, AB_PERFORMER, AB_RUBBER_SKIN, AB_SOOTHING_VOICE, AB_THICK_FAT
	db AB_ECHOLOCATION, AB_BLOODSUCKER, AB_GALE_WINGS, AB_INFILTRATOR, AB_PREDATOR
	db AB_PERFUME, AB_ABSORPTION, AB_POLLEN, AB_EFFECT_SPORE, AB_PHOTOSYNTHESIS
	db AB_STENCH, AB_ABSORPTION, AB_POLLEN, AB_EFFECT_SPORE, AB_TOXIC_WASTE
	db AB_EFFECT_SPORE, AB_LEECHING, AB_PARASITE, AB_MYCELIUM, AB_REGROWTH
	db AB_EFFECT_SPORE, AB_LEECHING, AB_PARASITE, AB_MYCELIUM, AB_DEATH_SPORE
	db AB_SHIELD_DUST, AB_TOXIC_SCALES, AB_TINTED_LENS, AB_POISON_ABSORB, AB_VENOMOUS
	db AB_AMBUSH, AB_SUBTERRANEAN, AB_ELUSIVE, AB_AFTERSHOCK, AB_SAND_RUSH
	db AB_OPPORTUNIST, AB_GREEDY, AB_RESOURCEFUL, AB_QUICK_REFLEXES, AB_TECHNICIAN
	db AB_HEADACHE, AB_PSIONIC, AB_DAMP, AB_CONFOUNDING, AB_UNSTABLE
	db AB_CLOUD_NINE, AB_SWIFT_SWIM, AB_DAMP, AB_MIND_READER, AB_WATER_VEIL
	db AB_DEFIANT, AB_SHORT_TEMPER, AB_SCRAPPY, AB_UNSOPHISTICATED, AB_BLOODLUST
	db AB_LOYALTY, AB_MOMENTUM, AB_STEADFAST, AB_GROWL_INTIMIDATE, AB_ELEGANT_MANE
	db AB_LEGENDARY, AB_MOMENTUM, AB_STEADFAST, AB_GROWL_INTIMIDATE, AB_ELEGANT_MANE
	db AB_HYPNOTIC, AB_SLIPPERY, AB_SWIFT_SWIM, AB_HYDRATION, AB_WATER_VEIL
	db AB_WRESTLER, AB_SLIPPERY, AB_SWIFT_SWIM, AB_POWER_SWIM, AB_IRON_FIST
	db AB_RUN_AWAY, AB_MENTAL_SHIELD, AB_TELEPATHY, AB_GENIUS, AB_MAGIC_BOUNCE
	db AB_SPOON_BENDER, AB_MAGIC_GUARD, AB_MIND_READER, AB_GENIUS, AB_MAGIC_BOUNCE
	db AB_NO_GUARD, AB_GUTS, AB_IRON_GRIP, AB_GRAPPLER, AB_BODYBUILDER
	db AB_NO_GUARD, AB_GUTS, AB_FOUR_ARMS, AB_GRAPPLER, AB_BODYBUILDER
	db AB_ACIDIC, AB_CARNIVOROUS, AB_STICKY_TRAP, AB_CHLOROPHYLL, AB_DIGESTIVE_ACID
	db AB_CLEAR_BODY, AB_LIQUID_OOZE, AB_STINGING_SKIN, AB_JELLY_BODY, AB_VENOMOUS
	db AB_LEVITATE, AB_IMMUNITY, AB_STURDY, AB_ROLLOUT, AB_HEAVYWEIGHT
	db AB_DIGGER, AB_IMMUNITY, AB_STURDY, AB_ROLLOUT, AB_HEAVYWEIGHT
	db AB_FLAME_BODY, AB_COMPETITIVE, AB_BLAZING_TRAIL, AB_WILD_CHARGE, AB_STAMINA
	db AB_SHELL_ARMOR, AB_OBLIVIOUS, AB_UNAWARE, AB_PATIENT, AB_SIMPLE
	db AB_LEVITATE, AB_BATTERY, AB_OVERLOAD, AB_CHAIN_REACTION, AB_MAGNETIC_FIELD
	db AB_UNDERDOG, AB_UNYIELDING, AB_TASTY_LEEK, AB_PRECISION, AB_RAZOR_EDGE
	db AB_TWIN_BEAKS, AB_STAMPEDE, AB_QUICK_FEET, AB_BIRD_RELENTLESS, AB_HEADSTRONG
	db AB_TRIPLE_THREAT, AB_STAMPEDE, AB_QUICK_FEET, AB_BIRD_RELENTLESS, AB_HEADSTRONG
	db AB_BLUBBER, AB_HYDRATION, AB_REFRIGERATE, AB_ICEBREAKER, AB_SNOW_VEIL
	db AB_CONTAMINATION, AB_GRIMER_TOXIC_WASTE, AB_STICKY_BODY, AB_LIQUID_OOZE, AB_SOFT_BODY
	db AB_SHELL_ARMOR, AB_SKILL_LINK, AB_SPIKED_SHELL, AB_DEEPSEA_PEARL, AB_LIQUIDATE
	db AB_LEVITATE, AB_GAS_BODY, AB_PRANKSTER, AB_NOCTURNAL, AB_MIND_GAMES
	db AB_LEVITATE, AB_CURSED_TOUCH, AB_PRANKSTER, AB_CURSED_BODY, AB_MIND_GAMES
	db AB_CRUSHING_WEIGHT, AB_COLOSSAL_SIZE, AB_ONIX_STURDY, AB_EARTHSHAKER, AB_EARTH_EATER
	db AB_NIGHTMARE, AB_SANDMAN, AB_DEEP_SLEEP, AB_DREAMCATCHER, AB_MENTAL_SHIELD
	db AB_CRUSHING_CLAWS, AB_SHELL_ARMOR, AB_BRUTE_FORCE, AB_WATER_PRESSURE, AB_HYPER_CUTTER
	db AB_HIGH_VOLTAGE, AB_SHORT_CIRCUIT, AB_VOLATILE, AB_UNSTABLE, AB_VOLTORB_CHAIN
	db AB_COLLECTIVE_MIND, AB_EXECUTIONER, AB_HARVEST, AB_IMMUNITY, AB_SOLAR_POWER
	db AB_COLLECTIVE_MIND, AB_THICK_TRUNK, AB_HARVEST, AB_IMMUNITY, AB_SOLAR_POWER
	db AB_LONELY, AB_THICK_SKULL, AB_ROCK_HEAD, AB_UNDERDOG, AB_BONE_BREAKER
	db AB_VENGEFUL, AB_THICK_SKULL, AB_ROCK_HEAD, AB_BONE_COLLECTOR, AB_BONE_BREAKER
	db AB_RECKLESS, AB_RESILIENCE, AB_FOOTWORK, AB_LONG_LEGS, AB_LIMBER
	db AB_IRON_FIST, AB_SECOND_WIND, AB_COMBOS, AB_COUNTERPUNCH, AB_GUARD_UP
	db AB_GLUTTONY, AB_POISON_HEAL, AB_THICK_TONGUE, AB_SLOBBER, AB_BOTTOMLESS_STOMACH
	db AB_LEVITATE, AB_TOXIC_FUMES, AB_GAS_LEAK, AB_CHEMICAL_REACTION, AB_NEUTRALIZING_GAS
	db AB_CHARGE, AB_ARMORED, AB_SOLID_ROCK, AB_ROCK_HEAD, AB_HORN_BREAKER
	db AB_NATURAL_CURE, AB_SERENE_GRACE, AB_TRIAGE, AB_HEALER, AB_LUCKY
	db AB_ENTANGLE, AB_REGROWTH, AB_VINE_GUARD, ABILITY_EXTENDED, AB_DAMP
	db ABILITY_EXTENDED, AB_SCRAPPY, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db AB_SNIPER, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_SWIFT_SWIM, AB_WATER_VEIL, AB_HORN_BREAKER, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_NATURAL_CURE, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_PRANKSTER, AB_MAGIC_BOUNCE, ABILITY_EXTENDED, ABILITY_EXTENDED
	db AB_TECHNICIAN, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_EXECUTIONER, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_SNOW_VEIL
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_HOT_TEMPER, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_HYPER_CUTTER, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_HARD_SHELL
	db AB_STAMPEDE, AB_RAMPAGE, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_SWIFT_SWIM, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_GROWL_INTIMIDATE, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_ICEBREAKER, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_SHELL_ARMOR
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_SOFT_BODY
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_WATER_VEIL, AB_REGENERATION, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_QUICK_FEET, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_HIGH_VOLTAGE
	db ABILITY_EXTENDED, ABILITY_EXTENDED, AB_COMBUSTION, ABILITY_EXTENDED, AB_FLAME_BODY
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, AB_PATIENT, ABILITY_EXTENDED, AB_SHELL_ARMOR
	db ABILITY_EXTENDED, ABILITY_EXTENDED, AB_BATTLE_ARMOR, AB_LEECHING, ABILITY_EXTENDED
	db AB_PREDATOR, AB_ROCK_HEAD, AB_RELENTLESS, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_THICK_FAT, AB_GLUTTONY, ABILITY_EXTENDED, AB_IMMUNITY
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db AB_SHED_SKIN, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_WATER_VEIL
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_WATER_VEIL
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, AB_CORROSIVE_VENOM, AB_SNIPER, ABILITY_EXTENDED

	db AB_THICK_FAT, ABILITY_EXTENDED, AB_ROLLOUT, AB_SCRAPPY, AB_SERENE_GRACE
	db AB_EARTH_EATER, AB_BATTLE_ARMOR, AB_AFTERSHOCK, AB_SHORT_TEMPER, AB_UNDERDOG
	db AB_EARTH_EATER, AB_SHELL_ARMOR, AB_EARTHSHAKER, AB_DEFIANT, ABILITY_EXTENDED
	db AB_WATER_PRESSURE, AB_WATER_PRESSURE, AB_WATER_PRESSURE, AB_WATER_PRESSURE, AB_WATER_PRESSURE
	db AB_VINE_GUARD, AB_VINE_GUARD, AB_VINE_GUARD, AB_VINE_GUARD, AB_VINE_GUARD

	db AB_PRANKSTER, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_CURSED_BODY, ABILITY_EXTENDED
	db AB_LEVITATE, AB_CURSED_BODY, ABILITY_EXTENDED, AB_IMMUNITY, ABILITY_EXTENDED
	db AB_EARTH_EATER, AB_BATTLE_ARMOR, ABILITY_EXTENDED, AB_RAMPAGE, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_SHED_SKIN, AB_HEAVYWEIGHT, AB_ONIX_STURDY, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED

	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db AB_STAMINA, AB_THICK_FAT, AB_STATIC, AB_SCRAPPY, ABILITY_EXTENDED
	db AB_STURDY, AB_ROLLOUT, AB_EARTHSHAKER, AB_HEAVYWEIGHT, AB_MOMENTUM
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED
	db AB_POLLEN, AB_SHIELD_DUST, ABILITY_EXTENDED, AB_RUN_AWAY, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_OVERCHARGE, ABILITY_EXTENDED
	db ABILITY_EXTENDED, ABILITY_EXTENDED, ABILITY_EXTENDED, AB_OVERCHARGE, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_RUN_AWAY, AB_SNOW_VEIL, ABILITY_EXTENDED, ABILITY_EXTENDED
	db ABILITY_EXTENDED, AB_BIRD_RELENTLESS, AB_REFRIGERATE, ABILITY_EXTENDED, 0 ; Mold Breaker pending
