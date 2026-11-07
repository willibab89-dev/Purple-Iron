SECTION "Conditional damage and hybrid stats", ROMX, BANK[$35]

BankedPlayerDamageVars:
	call IsConditionalDamageMove
	jr c, .custom
	call LegacyPlayerDamageVars
	jr StoreBankedDamageVars
.custom
	call ConditionalDamageVars
	jr StoreBankedDamageVars
BankedEnemyDamageVars:
	call IsConditionalDamageMove
	jr c, .custom
	call LegacyEnemyDamageVars
	jr StoreBankedDamageVars
.custom
	call ConditionalDamageVars
StoreBankedDamageVars:
	; Bankswitch uses BC to restore its bank. Export these two results through
	; scratch HRAM, which CalculateDamage immediately initializes again.
	ld a, b
	ld [H_MULTIPLICAND + 1], a
	ld a, c
	ld [H_MULTIPLICAND + 2], a
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
	call ConditionalPower
	call ConditionalOffense
	push hl
	call ConditionalDefense
	ld b, h
	ld c, l
	pop hl
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
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	add hl, de
	jp ConditionalCap999
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
	call ConditionalReadStat
	push hl
	ld a, [wCustomSide]
	xor 1
	ld b, 0
	ld c, 2
	call ConditionalReadStat
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
