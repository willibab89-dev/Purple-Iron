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
 ret nz
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

AbilityFluffyDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityFluffyFixedDamage:
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
 ret nz
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
 ret nz
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
 jr AbilityAntivirusResolved
AbilityAntivirusActor:
 xor a
 ld [wAbilityCheckResult], a
 callab AbilityActor
 jr AbilityAntivirusResolved
AbilityAntivirusCustom:
 xor a
 ld [wAbilityCheckResult], a
 callab AbilityGetCustomSide
AbilityAntivirusResolved:
 ld a, [wAbilityResolvedExtended]
 cp AB_ANTIVIRUS - ABILITY_EXTENDED
 ret nz
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
AbilityTerrifying:
 callab AbilityGetSideForDitto
 ld a, [wAbilityResolvedExtended]
 cp AB_TERRIFYING - ABILITY_EXTENDED
 ret nz
 callab AbilityFlagsPointer
 bit 6, [hl]
 ret nz
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
 callab AbilityFlagsPointer
 set 6, [hl]
 ld a, [wAbilitySide]
 xor 1
 ld [wAbilitySide], a
 ld [wCustomSide], a
 callab AbilityGetCustomSideResult
 ld a, [wAbilityCheckResult]
 cp AB_CLEAR_BODY
 jr z, .restore
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
