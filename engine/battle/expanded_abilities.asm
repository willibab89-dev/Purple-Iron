; Shared ability mechanics. This bank has room for the early-species pools.
; Flags per party member: 0 Hot Temper / Quick Feet status, 1 Confident /
; Overcharge, 2 low-HP trigger,
; 3 first damaging move spent; 4..5 Relentless hit count; 6 Intimidate spent;
; 7 already affected by Intimidate. Bits 0..2 and 6..7 persist in battle.
AbilityEntry:
	call AbilityRolloutResetSide
	call AbilityClearRelentless
	call AbilityFlagsPointer
	res 3, [hl]
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_GREEDY
	jr nz, .entryAbilities
	call AbilityFlagsPointer
	set 6, [hl] ; holder participated in this battle
	ret
.entryAbilities
	cp AB_ILLUSION
	jr z, .resetEntryFlag
	cp AB_ELUSIVE
	ret nz
.resetEntryFlag
	call AbilityFlagsPointer
	res 0, [hl]
	ret

AbilityClearRelentless:
	ld hl, wAbilityFlags
	ld b, 12
.loop
	ld a, [hl]
	and $cf
	ld [hli], a
	dec b
	jr nz, .loop
	ret

; Called after the newly loaded combatant's stat stages are initialized.
AbilityEntrySpeed:
	call AbilityImmunityOnEntry
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_ELUSIVE
	jr nz, .perfume
	call AbilityFlagsPointer
	set 0, [hl]
	ld a, 5 ; Evasion
	call AbilityRaiseStage
.perfume
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_PERFUME
	jr nz, .tailwind
	ld a, 5 ; Evasion
	call AbilityRaiseStage
.tailwind
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_TAILWIND
	jr nz, .intimidate
	ld a, 2 ; Speed
	call AbilityRaiseStage
.intimidate
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_QUICK_FEET
	jr nz, .checkGuts
	call AbilityFlagsPointer
	res 0, [hl] ; reapply the boost after stages reset on each entry
	call AbilityQuickFeet
.checkGuts
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_GUTS
	jr nz, .checkIntimidate
	call AbilityFlagsPointer
	res 0, [hl]
	call AbilityGuts
.checkIntimidate
	ld a, [wFirstMonsNotOutYet]
	and a
	jr z, .oneSide
	ld a, [wAbilitySide]
	and a
	ret nz ; first enemy waits until the player's first combatant is ready
	call AbilityIntimidate
	ld a, 1
	ld [wAbilitySide], a
	call AbilityIntimidate
	xor a
	ld [wAbilitySide], a
	ret
.oneSide
	jp AbilityIntimidate

AbilityQuickFeetBoth:
	xor a
	ld [wAbilitySide], a
	call AbilityQuickFeet
	call AbilityGuts
	ld a, 1
	ld [wAbilitySide], a
	call AbilityQuickFeet
	jp AbilityGuts

AbilityQuickFeet:
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_QUICK_FEET
	ret nz
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	inc hl
	inc hl ; major status is at HP + 3
	ld a, [hl]
	and a
	jr z, .healthy
	call AbilityFlagsPointer
	bit 0, [hl]
	ret nz
	set 0, [hl]
	ld a, 2 ; Speed
	jp AbilityRaiseStage
.healthy
	call AbilityFlagsPointer
	res 0, [hl]
	ret

; Each holder may trigger once; each target may be affected once per battle.
AbilityIntimidate:
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_INTIMIDATE
	jr z, .holder
	cp AB_GROWL_INTIMIDATE
	ret nz
.holder
	call AbilityFlagsPointer
	bit 6, [hl]
	ret nz
	ld a, [wAbilitySide]
	xor 1
	ld [wAbilitySide], a
	and a
	jr nz, .targetReady
	; Wild enemy data is loaded before StartBattle and before the player's
	; first mon. InitBattleVariables clears this species even if old HP remains.
	ld a, [wBattleMonSpecies]
	and a
	jr z, .restoreSide
.targetReady
	call AbilityHP
	ld a, [hli]
	or [hl]
	jr z, .restoreSide
	ld a, [wAbilitySide]
	xor 1
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	set 6, [hl]
	ld a, [wAbilitySide]
	xor 1
	ld [wAbilitySide], a
	call AbilityGet
	cp AB_CLEAR_BODY
	jr z, .restoreSide
	ld a, [wAbilitySide]
	xor 1
	call AbilityGet
	cp AB_GROWL_INTIMIDATE
	jr z, .apply
	call AbilityFlagsPointer
	bit 7, [hl]
	jr nz, .restoreSide
.apply
	call AbilityFlagsPointer
	set 7, [hl]
	ld a, 2 ; Speed
	ld [wCustomStat], a
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	ld a, -1
	ld [wCustomDelta], a
	xor a
	ld [wCustomChanged], a
	callab CustomChangeStage
.restoreSide
	ld a, [wAbilitySide]
	xor 1
	ld [wAbilitySide], a
	ret

AbilityTarget:
	ld a, [H_WHOSETURN]
	xor 1
	jp AbilityGet

; Called by CustomChangeStage before modifying a stage.
AbilityKeenEyeCustom:
 call AbilityMagneticCustom
 ld a, [wAbilityCheckResult]
 and a
 ret nz
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wCustomDelta]
 bit 7, a
 ret z
 ld a, [wCustomSide]
 call AbilityGet
 cp AB_CLOUD_NINE
 jr z, .opponent
 cp AB_CLEAR_BODY
 jr z, .opponent
 cp AB_UNYIELDING
 jr nz, .accuracy
 ld a, [wCustomStat]
 cp 2
 ret nc
.opponent
 ld a, [wCustomSide]
 ld b, a
 ld a, [H_WHOSETURN]
 cp b
 jr nz, .block
 ret
.accuracy
 cp AB_KEEN_EYE
 jr z, .checkStat
 cp AB_MIND_READER
 ret nz
.checkStat
 ld a, [wCustomStat]
 cp 4
 ret nz
.block
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilityKeenEyeTarget::
 xor a
 ld [wAbilityCheckResult], a
 call AbilityTarget
 cp AB_CLOUD_NINE
 jr z, .block
 cp AB_CLEAR_BODY
 jr z, .block
 cp AB_UNYIELDING
 jr nz, .keen
 ld a, [wCustomStat]
 cp 2
 jr c, .block
 ret
.keen
 cp AB_KEEN_EYE
 jr z, .accuracy
 cp AB_MIND_READER
 ret nz
.accuracy
 ld a, [wCustomStat]
 cp 4
 ret nz
.block
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilityDampCheck:
 xor a
 ld [wAbilityCheckResult], a
 call AbilityMove
 inc hl
 ld a, [hl]
 cp EXPLODE_EFFECT
 ret nz
 call AbilityTarget
 cp AB_DAMP
 ret nz
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilityPiercingBeakCheck:
	xor a
	ld [wAbilityCheckResult], a
	call AbilityActor
	cp AB_PIERCING_BEAK
	jr z, .beak
	cp AB_SPOON_BENDER
	jr nz, .horn
	call AbilityActorMoveType
	cp PSYCHIC
	ret nz
	ld a, 2
	jr .store
.horn
	cp AB_PIERCING_HORN
	ret nz
	call AbilityActorMoveType
	cp FIRE
	ret nc
	ld a, 2
	jr .store
.beak
	call AbilityActorMoveType
	cp FLYING
	ret nz
	ld a, 1
.store
	ld [wAbilityCheckResult], a
	ret

; The chart supplies the matched defending type in wAbilityTemp. The result
; is the replacement multiplier (0 means no override).
AbilityCorrosiveCheck:
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wMoveType]
 ld [wAbilityTemp + 1], a
 call AbilityActor
 jr AbilityTypeOverride

AbilityCorrosiveAICheck:
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wUnusedC000]
 bit 3, a
 ld a, [wEnemyMoveType]
 jr z, .move
 ld a, [wPlayerMoveType]
.move
 ld [wAbilityTemp + 1], a
 ld a, [wUnusedC000]
 bit 3, a
 ld a, 1
 jr z, .side
 xor a
.side
 call AbilityGet
AbilityTypeOverride:
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
 ret nz
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

AbilityDefiantTarget:
 xor a
 ld [wAbilityCheckResult], a
 call AbilityTarget
 cp AB_DEFIANT
 ret nz
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilityMove:
	ld hl, wPlayerMoveNum
	ld a, [H_WHOSETURN]
	and a
	ret z
	ld hl, wEnemyMoveNum
	ret

; Percentage roll, exact across the 200 accepted byte values. Result in carry.
; Carry iff draw < percentage*2.
AbilityRoll:
	ld a, b
	add a
	push af
.retry
	callab CustomRandomInBattleBank
	ld a, [wCustomRandomValue]
	cp 200
	jr nc, .retry
	ld b, a
	pop af
	ld c, a
	ld a, b
	cp c
	ret

; The RNG draw is already in wCustomRandomValue. Halving it doubles the
; threshold probability exactly and makes thresholds >=128 guaranteed.
AbilityMeasuredEffectRoll:
	call AbilityActor
	cp AB_MEASURED
	jr z, .double
	cp AB_TWIN_BEAKS
	ret nz
.double
	ld a, [wCustomRandomValue]
	srl a
	ld [wCustomRandomValue], a
	ret

AbilityScaleDamage:
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
	; Preserve type immunities: only nonzero input damage may become minimum 1.
	ret

AbilityModifyDamage:
	call AbilityRefrigerateDamage
	call AbilityDoduoOffense
	call AbilityFarfetchDamage
	call AbilityMagnetDamage
	call AbilityPatientDamage
	ld a, [wUnusedC000]
	bit 4, a
	ret nz ; fixed damage ignores ordinary damage modifiers
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	ld hl, wPlayerMovePower
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	and a
	jr z, .power
	ld hl, wEnemyMovePower
.power
	ld a, [hli]
	and a
	ret z
	ld a, [hl]
	ld [wAbilityMoveType], a
	call AbilityActor
	cp AB_MEASURED
	jr nz, .overgrowth
	ld c, 80
	call AbilityScaleDamage
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	jr nz, .measuredDone
	inc a
	ld [wDamage + 1], a ; a non-immune damaging move still deals at least 1
.measuredDone
	jp .defender
.overgrowth
	cp AB_OVERGROWTH
	jr nz, .blaze
	ld a, [wAbilityMoveType]
	cp GRASS
	jp nz, .defender
	call AbilityHP
	ld a, [de]
	cp [hl]
	jp nz, .defender
	inc de
	inc hl
	ld a, [de]
	cp [hl]
	jp nz, .defender
	jr .quarter
.blaze
	cp AB_BLAZE
	jr nz, .water
	ld a, [wAbilityMoveType]
	cp FIRE
	jp nz, .defender
	call AbilityBelowThird
	jp nc, .defender
	jr .quarter
.water
	cp AB_WATER_PRESSURE
	jr nz, .psionic
	ld a, [wAbilityMoveType]
	cp WATER
	jp nz, .defender
	ld a, [wAbilityPPLeft]
	cp 25
	jr c, .pp
	ld a, 25
.pp
	add a
	add 100
	ld c, a
	call AbilityScaleDamage
	jp .defender
.psionic
	cp AB_PSIONIC
	jr nz, .venomous
	ld a, [wAbilityMoveType]
	cp PSYCHIC
	jp nz, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.venomous
	cp AB_TINTED_LENS
	jr nz, .notTinted
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	ld a, [wDamageMultipliers]
	and $7f
	jp z, .defender
	cp 10
	jp nc, .defender
	ld c, 200
	call AbilityScaleDamage
	jp .defender
.notTinted
	cp AB_VENOMOUS
	jr nz, .piercing
	call AbilityTargetStatus
	bit PSN, [hl]
	jp z, .defender
.quarter
	ld c, 125
	call AbilityScaleDamage
	jp .defender
.piercing
	cp AB_PIERCING_STING
	jr nz, .newOffense
	ld a, [wAbilityMoveType]
	cp POISON
	jp nz, .defender
	call AbilityTargetStatus
	inc hl
	ld a, [hli]
	cp BUG
	jr z, .double
	ld a, [hl]
	cp BUG
	jp nz, .defender
.double
	ld c, 200
	call AbilityScaleDamage
	ld a, [wDamageMultipliers]
	ld b, a
	and $7f
	add a
	ld c, a
	ld a, b
	and $80
	or c
	ld [wDamageMultipliers], a
	jp .defender
.newOffense
	cp AB_BLAZING_TRAIL
	jr nz, .digger
	call AbilityBlazingTrailCheck
	jp nc, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.digger
	cp AB_DIGGER
	jr nz, .heavyweight
	call AbilityDiggerCheck
	jp nc, .defender
	ld c, 125
	call AbilityScaleDamage
	jp .defender
.heavyweight
	cp AB_HEAVYWEIGHT
	jr nz, .rollout
	call AbilityHeavyweightCheck
	jp nc, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.rollout
	cp AB_ROLLOUT
	jr nz, .digestive
	call AbilityRolloutScale
	jp .defender
.digestive
	cp AB_DIGESTIVE_ACID
	jr nz, .ironGrip
	call AbilityDigestiveAcidCheck
	jp nc, .defender
	ld c, 125
	call AbilityScaleDamage
	jp .defender
.ironGrip
	cp AB_IRON_GRIP
	jr nz, .ironFist
	call AbilityIronGripCheck
	jp nc, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.ironFist
	cp AB_IRON_FIST
	jr nz, .legendary
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 7, a
	jp z, .defender
	ld c, 125
	call AbilityScaleDamage
	jp .defender
.legendary
	cp AB_LEGENDARY
	jr nz, .unsophisticated
	call AbilityLegendaryCheck
	jp nc, .defender
	ld c, 125
	call AbilityScaleDamage
	jp .defender
.unsophisticated
	cp AB_UNSOPHISTICATED
	jr nz, .strongJaw
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 6, a
	jp z, .defender
	ld c, 125
	call AbilityScaleDamage
	jp .defender
.strongJaw
	cp AB_STRONG_JAW
	jr z, .physicalStrong
	cp AB_HUSTLE
	jr nz, .voltage
	ld c, 125
	jr .physicalBoost
.physicalStrong
	ld c, 115
.physicalBoost
	ld a, [wAbilityMoveType]
	cp FIRE ; physical types precede FIRE
	jp nc, .defender
	call AbilityScaleDamage
	jp .defender
.voltage
	cp AB_VOLTAGE
	jr nz, .sniper
	ld a, [wAbilityMoveType]
	cp ELECTRIC
	jp nz, .defender
	call AbilityTargetStatus
	bit PAR, [hl]
	jp z, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.sniper
	cp AB_SNIPER
	jr nz, .predator
	ld a, [wCriticalHitOrOHKO]
	and a
	jp z, .defender
	ld c, 150
	call AbilityScaleDamage
	jp .defender
.predator
	cp AB_PREDATOR
	jr nz, .relentless
	ld a, [wAbilityMoveType]
	cp FIRE
	jp nc, .defender
	call AbilityPrepareSpeeds
	ld hl, wAbilityPlayerSpeed
	ld de, wAbilityEnemySpeed
	ld a, [H_WHOSETURN]
	and a
	jr z, .compareSpeed
	ld hl, wAbilityEnemySpeed
	ld de, wAbilityPlayerSpeed
.compareSpeed
	ld a, [de]
	ld b, a
	ld a, [hli]
	cp b
	jp c, .defender
	jr nz, .predatorBoost
	inc de
	ld a, [de]
	ld b, a
	ld a, [hl]
	cp b
	jp c, .defender
	jp z, .defender
.predatorBoost
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.relentless
	cp AB_RELENTLESS
	jr nz, .nidoMale
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	ld a, [hl]
	and $30
	swap a
	ld b, a
	add a
	add a
	add b
	add a ; ten percent per prior hit
	add 100
	ld c, a
	call AbilityScaleDamage
	jp .defender
.nidoMale
	cp AB_OPPORTUNIST
	jr nz, .technician
	call AbilityTargetHasLoweredStage
	jp nc, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.technician
	cp AB_TECHNICIAN
	jr nz, .ambushAbility
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	call AbilityMove
	inc hl
	inc hl
	ld a, [hl]
	and a
	jp z, .defender
	cp 61
	jp nc, .defender
	ld c, 150
	call AbilityScaleDamage
	jp .defender
.ambushAbility
	cp AB_AMBUSH
	jr nz, .luckyStar
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	ld a, [wAbilityHit]
	bit 4, a
	jp z, .defender
	ld c, 125
	call AbilityScaleDamage
	jp .defender
.luckyStar
	cp AB_LUCKY_STAR
	jr nz, .unpredictable
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	ld b, 10
	call AbilityRoll
	jp nc, .defender
	ld c, 150
	call AbilityScaleDamage
	jp .defender
.unpredictable
	cp AB_UNPREDICTABLE
	jr nz, .sheerForce
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	ld a, [wAbilityHit]
	bit 4, a
	jp z, .defender
	ld c, 130
	call AbilityScaleDamage
	jp .defender
.sheerForce
	cp AB_SHEER_FORCE
	jr nz, .bloodlust
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 3, a
	jp z, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.bloodlust
	cp AB_BLOODLUST
	jr nz, .rampage
	call AbilityBloodlustCheck
	jp nc, .defender
	jr .malePhysicalBoost
.rampage
	cp AB_RAMPAGE
	jp nz, .defender
.malePhysicalBoost
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	ld a, [wAbilityMoveType]
	cp FIRE
	jp nc, .defender
	ld c, 125
	call AbilityScaleDamage

.defender
	call AbilityTarget
	cp AB_SOFT_BODY
	jr nz, .notSoftBody
	ld a, [wAbilityMoveType]
	cp NORMAL
	jr z, .softBody
	cp FIGHTING
	ret nz
.softBody
	ld c, 75
	jp .reduce
.notSoftBody
	cp AB_HEADSTRONG
	jr nz, .notHeadstrong
	ld a, [wAbilityMoveType]
	cp PSYCHIC
	ret nz
	ld c, 75
	jp .reduce
.notHeadstrong
	cp AB_STENCH
	jr nz, .vineGuard
	call AbilityActorPoisoned
	ret z
	ld c, 75
	jp .reduce
.vineGuard
	cp AB_VINE_GUARD
	jr nz, .veil
	ld a, [wAbilityMoveType]
	cp FLYING
	jr z, .half
	ret
.veil
	cp AB_DAMP
	jr z, .fireHalf
	cp AB_BLUBBER
	jr z, .fireHalf
	cp AB_WATER_VEIL
	jr nz, .shell
.fireHalf
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nz
.half
	ld c, 50
	jp .reduce
.shell
	cp AB_HARD_SHELL
	jr nz, .sandArmor
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	ld c, 75
	jr .reduce
.sandArmor
	cp AB_SAND_ARMOR
	jr z, .superEffective
	cp AB_SUBTERRANEAN
	jr nz, .thickHide
.superEffective
	ld a, [wDamageMultipliers]
	and $7f
	cp 11 ; neutral is 10
	ret c
	ld c, 75
	jr .reduce
.thickHide
	cp AB_ELEGANT_MANE
	jr z, .mentalShield
	cp AB_MENTAL_SHIELD
	jr z, .mentalShield
	cp AB_DEEPSEA_PEARL
	jr nz, .checkThickFat
.mentalShield
	ld a, [wAbilityMoveType]
	cp FIRE
	ret c
	ld c, 80
	jr .reduce
.checkThickFat
	cp AB_THICK_FAT
	jr nz, .notThickFat
	ld a, [wAbilityMoveType]
	cp FIRE
	jr z, .half
	cp ICE
	jr z, .half
	ret
.notThickFat
	cp AB_JELLY_BODY
	jr nz, .physicalHide
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	ld c, 80
	jr .reduce
.physicalHide
	cp AB_THICK_HIDE
	ret nz
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	ld c, 85
.reduce
	call AbilityScaleDamage
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret nz
	inc a
	ld [wDamage + 1], a
	ret

; Fixed-damage moves are calculated later than the ordinary damage hook.
; Apply the explicitly requested damage reductions after that calculation.
AbilityFixedDamageModifiers:
	call AbilityExistingFixedDamageModifiers
	jp AbilityIncomingDamage
AbilityExistingFixedDamageModifiers:
	; A missed Jump Kick causes crash damage to its user.
	ld a, [wMoveMissed]
	and a
	jr z, .notCrash
	call AbilityActor
	cp AB_MAGIC_GUARD
	jr nz, .notCrash
	call AbilityMove
	inc hl
	ld a, [hl]
	cp JUMP_KICK_EFFECT
	jr nz, .notCrash
	xor a
	ld [wDamage], a
	ld [wDamage + 1], a
	ret
.notCrash
	ld a, [wUnusedC000]
	bit 4, a
	jr nz, .fixed
	call AbilityMove
	ld a, [hl]
	cp COUNTER
	jr z, .fixed
	cp BIDE
	ret nz
.fixed
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	; Bide releases without the usual AbilityAttempt hook.
	ld a, [wAbilityHit]
	bit 5, a
	jr z, .fixedActor
	call AbilityMove
	ld a, [hl]
	cp BIDE
	jr nz, .fixedActor
	ld hl, wAbilityHit
	set 3, [hl]
.fixedActor
	call AbilityRefrigerateFixedDamage
	call AbilityDoduoFixedOffense
	call AbilityFarfetchFixedDamage
	call AbilityPatientCheck
	jr nc, .patientFixedDone
	ld c, 120
	call AbilityScaleDamage
.patientFixedDone
	call AbilityActor
	cp AB_MEASURED
	jr nz, .male
	ld c, 80
	call AbilityScaleDamage
	call AbilityFixedMinimum
	jp .defender
.male
	cp AB_BLAZING_TRAIL
	jr nz, .fixedDigger
	call AbilityBlazingTrailCheck
	jp nc, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.fixedDigger
	cp AB_DIGGER
	jr nz, .fixedHeavyweight
	call AbilityDiggerCheck
	jp nc, .defender
	ld c, 125
	call AbilityScaleDamage
	jp .defender
.fixedHeavyweight
	cp AB_HEAVYWEIGHT
	jr nz, .fixedRollout
	call AbilityHeavyweightCheck
	jp nc, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.fixedRollout
	cp AB_ROLLOUT
	jr nz, .fixedDigestive
	call AbilityRolloutScale
	jp .defender
.fixedDigestive
	cp AB_DIGESTIVE_ACID
	jr nz, .fixedIronGrip
	call AbilityDigestiveAcidCheck
	jp nc, .defender
	ld c, 125
	call AbilityScaleDamage
	jp .defender
.fixedIronGrip
	cp AB_IRON_GRIP
	jr nz, .fixedLegendary
	call AbilityIronGripCheck
	jp nc, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.fixedLegendary
	cp AB_LEGENDARY
	jr nz, .fixedUnsophisticated
	call AbilityLegendaryCheck
	jp nc, .defender
	ld c, 125
	call AbilityScaleDamage
	jp .defender
.fixedUnsophisticated
	cp AB_UNSOPHISTICATED
	jr nz, .fixedOpportunist
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jp z, .defender
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 6, a
	jp z, .defender
	ld c, 125
	call AbilityScaleDamage
	jp .defender
.fixedOpportunist
	cp AB_OPPORTUNIST
	jr nz, .ambushAbility
	call AbilityTargetHasLoweredStage
	jp nc, .defender
	ld c, 120
	call AbilityScaleDamage
	jp .defender
.ambushAbility
	cp AB_AMBUSH
	jr nz, .venomous
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jr z, .defender
	ld a, [wAbilityHit]
	bit 4, a
	jr nz, .ambushBoost
	; Bide releases outside AbilityAttempt, so claim its first hit here.
	call AbilityMove
	ld a, [hl]
	cp BIDE
	jr nz, .defender
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	bit 3, [hl]
	jr nz, .defender
	set 3, [hl]
	ld hl, wAbilityHit
	set 4, [hl]
.ambushBoost
	ld c, 125
	call AbilityScaleDamage
	jr .defender
.venomous
	cp AB_VENOMOUS
	jr nz, .luckyStar
	call AbilityTargetStatus
	bit PSN, [hl]
	jr z, .defender
	ld c, 125
	call AbilityScaleDamage
	jr .defender
.luckyStar
	cp AB_LUCKY_STAR
	jr nz, .unpredictable
	ld b, 10
	call AbilityRoll
	jr nc, .defender
	ld c, 150
	call AbilityScaleDamage
	jr .defender
.unpredictable
	cp AB_UNPREDICTABLE
	jr nz, .bloodlust
	ld a, [wAbilityHit]
	bit 4, a
	jr z, .defender
	ld c, 130
	call AbilityScaleDamage
	jr .defender
.bloodlust
	cp AB_BLOODLUST
	jr nz, .rampage
	call AbilityBloodlustCheck
	jr nc, .defender
	jr .boost
.rampage
	cp AB_RAMPAGE
	jr nz, .defender
.boost
	call AbilityActorMoveType
	cp FIRE
	jr nc, .defender
	ld c, 125
	call AbilityScaleDamage
.defender
	call AbilityTarget
	cp AB_SOFT_BODY
	jr nz, .notSoftBody
	call AbilityActorMoveType
	cp NORMAL
	jr z, .softBody
	cp FIGHTING
	ret nz
.softBody
	ld c, 75
	jp .scale
.notSoftBody
	cp AB_HEADSTRONG
	jr nz, .notHeadstrong
	call AbilityActorMoveType
	cp PSYCHIC
	ret nz
	ld c, 75
	jp .scale
.notHeadstrong
	cp AB_STENCH
	jr nz, .thickFat
	call AbilityActorPoisoned
	ret z
	ld c, 75
	jr .scale
.thickFat
	cp AB_ELEGANT_MANE
	jr z, .fixedMentalShield
	cp AB_MENTAL_SHIELD
	jr z, .fixedMentalShield
	cp AB_DEEPSEA_PEARL
	jr nz, .fixedThickFat
.fixedMentalShield
	call AbilityActorMoveType
	cp FIRE
	ret c
	ld c, 80
	jr .scale
.fixedThickFat
	cp AB_BLUBBER
	jr nz, .notBlubber
	call AbilityActorMoveType
	cp FIRE
	jr z, .half
	ret
.notBlubber
	cp AB_THICK_FAT
	jr nz, .hide
	call AbilityActorMoveType
	cp FIRE
	jr z, .half
	cp ICE
	ret nz
.half
	ld c, 50
	jr .scale
.hide
	cp AB_JELLY_BODY
	jr nz, .fixedHide
	call AbilityActorMoveType
	cp FIRE
	ret nc
	ld c, 80
	jr .scale
.fixedHide
	cp AB_THICK_HIDE
	ret nz
	call AbilityActorMoveType
	cp FIRE
	ret nc
	ld c, 85
.scale
	call AbilityScaleDamage
AbilityFixedMinimum:
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret nz
	inc a
	ld [wDamage + 1], a
	ret

AbilityCachePP:
	ld hl, wBattleMonPP
	ld a, [H_WHOSETURN]
	and a
	ld a, [wPlayerMoveListIndex]
	jr z, .read
	ld hl, wEnemyMonPP
	ld a, [wEnemyMoveListIndex]
.read
	and 3
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hl]
	and $3f
	ld [wAbilityPPLeft], a
	ret

; Called only after the Pokémon can actually execute its move.
AbilityAttempt:
	call AbilityRefrigerateConvert
	call AbilityCachePP
	ld hl, wAbilityHit
	set 3, [hl] ; a move was actually executed this action
	call AbilityMove
	ld a, [hl]
	cp METRONOME
	jr nz, .notMetronome
	call AbilityActor
	cp AB_UNPREDICTABLE
	jr nz, .metronomeDone
	ld hl, wAbilityHit
	set 4, [hl]
.metronomeDone
	ld a, METRONOME
.notMetronome
	call AbilityMoveFlags
	bit 0, a
	jp z, AbilityAttemptStatusMove
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	bit 3, [hl]
	jr nz, .alreadySpent
	set 3, [hl]
	call AbilityActor
	cp AB_AMBUSH
	ret nz
	ld hl, wAbilityHit
	set 4, [hl] ; applies to all hits of this first damaging move
	ret
.alreadySpent
	ret

; Ground/Normal abilities trigger only when a move was actually executed.
AbilitySandAfterAction:
	ld a, [wAbilityHit]
	bit 3, a
	ret z
	call AbilityActor
	cp AB_ROLLING_DEFENSE
	jp z, .normal
	cp AB_SAND_VEIL
	jp z, .evasion
	cp AB_SNOW_VEIL
	jp z, .snowVeil
	cp AB_HYDRATION
	jr nz, .burrower
	call AbilityActorMoveType
	cp WATER
	ret nz
	jr .healWaterOrGround
.burrower
	cp AB_BURROWER
	jr nz, .sandRush
	call AbilityActorMoveType
	cp GROUND
	ret nz
.healWaterOrGround
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	dec hl
	ld a, 3 ; 1/8 maximum HP
	jp AbilityHealFractionFromHL
.sandRush
	cp AB_WILD_CHARGE
	jr nz, .bodybuilder
	call AbilityMove
	inc hl
	inc hl
	ld a, [hli]
	and a
	ret z
	ld a, [hl]
	cp FIRE
	ret nc
	ld a, 2
	jp .once
.bodybuilder
	cp AB_BODYBUILDER
	jr nz, .powerSwim
	call AbilityActorMoveType
	cp FIGHTING
	ret nz
	ld a, 1
	jr .once
.powerSwim
	cp AB_POWER_SWIM
	jr nz, .momentum
	call AbilityActorMoveType
	cp WATER
	ret nz
	xor a ; Attack
	jr .once
.momentum
	cp AB_MOMENTUM
	jr nz, .actualSandRush
	call AbilityMove
	inc hl
	ld a, [hl]
	cp RECOIL_EFFECT
	ret nz
	ld a, 2
	jr .once
.actualSandRush
	cp AB_SAND_RUSH
	jr nz, .fox
	call AbilityActorMoveType
	cp GROUND
	ret nz
	ld a, 2 ; Speed
	jr .once
.fox
	cp AB_TELEPATHY
	jr nz, .foxy
	call AbilityActorMoveType
	cp PSYCHIC
	ret nz
	ld a, 5
	jr .once
.foxy
	cp AB_FOXS_CUNNING
	ret nz
	call AbilityActorMoveType
	cp GHOST
	ret nz
	ld a, 5
	jr .once
.normal
	call AbilityActorMoveType
	cp NORMAL
	ret nz
	ld a, 1 ; Defense
	jr .once
.snowVeil
	call AbilityActorMoveType
	cp ICE
	ret nz
	ld a, 5
	jr .once
.evasion
	call AbilityActorMoveType
	cp GROUND
	ret nz
	ld a, 5 ; Evasion
.once
	push af
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	jr z, .discard
	call AbilityFlagsPointer
	bit 2, [hl]
	jr nz, .discard
	set 2, [hl]
	pop af
	jp AbilityRaiseStage
.discard
	pop af
	ret
AbilityAttemptStatusMove:
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	res 4, [hl]
	res 5, [hl]
	ret

AbilityHitEvents:
	call AbilityMove
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret z
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	call AbilityLeeching
	call AbilityAftermath
	call AbilityDeathSpore
	call AbilityRelentlessHit
	call AbilityOvercharge
	call AbilityTastyLeek
	call AbilityRampage
	ld a, [wCustomTargetHadSub]
	and a
	ret nz
	call AbilityActorMoveType
	ld [wAbilityMoveType], a
	call AbilitySpinyArmor
	call AbilityEffectSpore
	call AbilityAftershock
	call AbilityGrappler
	call AbilityAcidic
	call AbilityToxicScales
	call AbilityParasite
	call AbilityConfounding
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	ld hl, wAbilityHit
	set 0, [hl]
	call AbilityStickyTrap
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityGetTargetReactions
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	call AbilityLowHPBoth
	ld hl, wAbilityHit
	bit 1, [hl]
	ret nz
	set 1, [hl]
	call AbilityTarget
	cp AB_SHIELD_DUST
	ret z
	call AbilityActor
	cp AB_REPULSIVE
	jr nz, .leaf
	ld b, 10
	call AbilityRoll
	ret nc
	ld hl, wEnemyBattleStatus1
	ld a, [H_WHOSETURN]
	and a
	jr z, .flinch
	ld hl, wPlayerBattleStatus1
.flinch
	set FLINCHED, [hl]
	ret
.leaf
	cp AB_CONTAMINATION
	jr nz, .poisonLeaf
	ld a, [wAbilityMoveType]
	cp GROUND
	ret nz
	ld b, 30
	ld c, 1 << PSN
	jr .rollStatus
.poisonLeaf
	cp AB_POISON_LEAF
	jr nz, .combustion
	ld a, [wAbilityMoveType]
	cp GRASS
	ret nz
	ld b, 25
	ld c, 1 << PSN
	jr .rollStatus
.combustion
	cp AB_COMBUSTION
	ret nz
	ld a, [wAbilityMoveType]
	cp FIRE
	ret z
	ld b, 15
	ld c, 1 << BRN
.rollStatus
	push bc
	call AbilityRoll
	pop bc
	ret nc
	ld a, c
	ld [wCustomDelta], a
	ld a, [H_WHOSETURN]
	xor 1
	ld [wCustomSide], a
	jp AbilityInflictOrdinaryStatus

; Each successful damaging strike counts, including a hit on a Substitute.
AbilityConfounding:
 ld hl, wAbilityHit
 bit 1, [hl]
 ret nz
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 call AbilityActor
 cp AB_CONFOUNDING
 ret nz
 ld a, [wAbilityMoveType]
 cp PSYCHIC
 ret nz
 call AbilityTarget
 cp AB_SHIELD_DUST
 ret z
 cp AB_STEADFAST
 ret z
 cp AB_OBLIVIOUS
 ret z
 cp AB_HEADSTRONG
 ret z
 ld hl, wEnemyBattleStatus1
 ld de, wEnemyConfusedCounter
 ld a, [H_WHOSETURN]
 and a
 jr z, .target
 ld hl, wPlayerBattleStatus1
 ld de, wPlayerConfusedCounter
.target
 bit CONFUSED, [hl]
 ret nz
 push hl
 push de
 ld b, 20
 call AbilityRoll
 pop de
 pop hl
 ret nc
 set CONFUSED, [hl]
 push de
 callab CustomRandomInBattleBank
 pop de
 ld a, [wCustomRandomValue]
 and 3
 add 2
 ld [de], a
 ret

AbilityRelentlessHit:
	call AbilityActor
	cp AB_RELENTLESS
	ret nz
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	ld a, [hl]
	and $30
	cp $30
	ret z
	ld a, [hl]
	add $10
	ld [hl], a
	ret

; Each direct physical strike damages the attacker, even if the holder faints.
 ; The attack pipeline records a successful damaging action immediately before
; the HP/substitute path; fixed damage is calculated after this point.
AbilityMarkDirectHit:
	ld a, [wMoveMissed]
	and a
	ret nz
	call AbilityMove
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret z
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	ld hl, wAbilityHit
	set 5, [hl]
	ret

AbilityIncomingDamage:
	ld hl, wAbilityHit
	bit 5, [hl]
	ret z
	res 5, [hl]
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	ld a, [wCustomTargetHadSub]
	and a
	ret nz ; a substitute, rather than the holder, received the hit
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityTarget
	cp AB_STURDY
	jp z, AbilitySturdyIncoming
	cp AB_ILLUSION
	jr z, .illusion
	cp AB_NINE_LIVES
	ret nz
	call AbilityFlagsPointer
	bit 0, [hl]
	ret nz
	call AbilityHP
	ld a, [hli]
	ld b, a
	ld a, [hl]
	ld c, a
	or b
	ret z
	ld a, [wDamage]
	cp b
	jr c, .done
	jr nz, .survive
	ld a, [wDamage + 1]
	cp c
	jr c, .done
.survive
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jr nz, .notOHKO
	xor a
	ld [wCriticalHitOrOHKO], a
.notOHKO
	push bc
	call AbilityFlagsPointer
	set 0, [hl]
	pop bc
	ld a, c
	sub 1
	ld [wDamage + 1], a
	ld a, b
	sbc 0
	ld [wDamage], a
.done
	ret
.illusion
	ld hl, wAbilityHit
	bit 6, [hl]
	jr nz, .halve
	call AbilityFlagsPointer
	bit 0, [hl]
	ret nz
	set 0, [hl]
	ld hl, wAbilityHit
	set 6, [hl] ; the full multi-hit attack is reduced
.halve
	; OHKO moves use 65535 as a sentinel for the target's remaining HP.
	ld a, [wCriticalHitOrOHKO]
	cp 2
	jr nz, .scale
	xor a
	ld [wCriticalHitOrOHKO], a
	call AbilityHP
	ld a, [hli]
	ld [wDamage], a
	ld a, [hl]
	ld [wDamage + 1], a
.scale
	ld c, 50
	call AbilityScaleDamage
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret nz
	inc a
	ld [wDamage + 1], a
	ret

AbilityAftermath:
	ld a, [wCustomTargetHadSub]
	and a
	ret nz
	call AbilityTarget
	cp AB_AFTERMATH
	ret nz
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret nz
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld hl, wPlayerResidual
	ld a, [H_WHOSETURN]
	and a
	jr z, .curse
	ld hl, wEnemyResidual
.curse
	bit 1, [hl]
	ret nz
	set 1, [hl]
	ld hl, AbilityAftermathText
	jp PrintText
AbilityAftermathText:
	text "AFTERMATH cursed"
	line "the attacker!"
	prompt

 ; Screen bypass is applied only during the damage-stat calculation.
AbilityInfiltratorCheck:
	xor a
	ld [wAbilityCheckResult], a
	ld a, [wAbilityHit]
	bit 3, a ; excludes confusion self-damage and idle calculations
	ret z
	call AbilityActor
	cp AB_INFILTRATOR
	ret nz
	ld a, 1
	ld [wAbilityCheckResult], a
	ret

; Hide only the opposing Substitute flag for the action. The original party
; position is stored in scratch used by other, mutually exclusive abilities.
AbilityInfiltratorStart:
	call AbilityActor
	cp AB_INFILTRATOR
	ret nz
	ld hl, wEnemyBattleStatus2
	ld a, [wEnemyMonPartyPos]
	ld b, a
	ld a, [H_WHOSETURN]
	and a
	jr z, .target
	ld hl, wPlayerBattleStatus2
	ld a, [wPlayerMonNumber]
	ld b, a
.target
	bit HAS_SUBSTITUTE_UP, [hl]
	ret z
	res HAS_SUBSTITUTE_UP, [hl]
	ld a, b
	ld [wAbilityOldStatus], a
	ld hl, wAbilityHit
	set 7, [hl]
	ret

AbilityInfiltratorRestore:
	ld hl, wAbilityHit
	bit 7, [hl]
	ret z
	res 7, [hl]
	ld a, [wIsInBattle]
	and a
	ret z
	ld hl, wEnemyBattleStatus2
	ld a, [wEnemyMonPartyPos]
	ld b, a
	ld a, [H_WHOSETURN]
	and a
	jr z, .target
	ld hl, wPlayerBattleStatus2
	ld a, [wPlayerMonNumber]
	ld b, a
.target
	ld a, [wAbilityOldStatus]
	cp b
	ret nz ; the original target switched out
	set HAS_SUBSTITUTE_UP, [hl]
	ret

; wDamage is the HP actually lost; preserve its quarter until the normal
; drain amount has been calculated by the move effect.
AbilityBloodsuckerCache:
	call AbilityActor
	cp AB_BLOODSUCKER
	jr z, .eligible
	cp AB_ABSORPTION
	ret nz
.eligible
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	ld c, a
	srl b
	rr c
	srl b
	rr c
	ld a, b
	ld [wAbilityTemp], a
	ld a, c
	ld [wAbilityTemp + 1], a
	ret
AbilityBloodsuckerAdd:
	call AbilityActor
	cp AB_BLOODSUCKER
	jr z, .eligible
	cp AB_ABSORPTION
	ret nz
.eligible
	ld a, [wAbilityTemp + 1]
	ld b, a
	ld a, [wDamage + 1]
	add b
	ld [wDamage + 1], a
	ld a, [wAbilityTemp]
	ld b, a
	ld a, [wDamage]
	adc b
	jr nc, .store
	ld a, $ff
	ld [wDamage + 1], a
.store
	ld [wDamage], a
	ret

 ; Leeching uses the actual HP lost, including capped Substitute damage.
AbilityLeeching:
	call AbilityActor
	cp AB_LEECHING
	ret nz
	call AbilityActorMoveType
	cp FIRE
	ret nc
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	ld c, a
	or b
	ret z
	ld a, [wCustomTargetHadSub]
	and a
	jr z, .divide
	ld a, [wAbilityTemp + 1]
	ld d, a
	ld a, b
	and a
	jr nz, .capSub
	ld a, c
	cp d
	jr c, .divide
.capSub
	ld b, 0
	ld c, d
.divide
	xor a
	ld [H_DIVIDEND], a
	ld [H_DIVIDEND + 1], a
	ld a, b
	ld [H_DIVIDEND + 2], a
	ld a, c
	ld [H_DIVIDEND + 3], a
	ld a, 10
	ld [H_DIVISOR], a
	ld b, 4
	call Divide
	ld a, [H_QUOTIENT + 2]
	ld b, a
	ld a, [H_QUOTIENT + 3]
	ld c, a
	or b
	jr nz, .heal
	inc c
.heal
	call AbilityHP
	push hl
	ld a, [hli]
	ld l, [hl]
	ld h, a
	add hl, bc
	jr c, .cap
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	ld a, h
	cp b
	jr c, .store
	jr nz, .capBC
	ld a, l
	cp c
	jr c, .store
.capBC
	ld h, b
	ld l, c
	jr .store
.cap
	ld a, [de]
	ld h, a
	inc de
	ld a, [de]
	ld l, a
.store
	ld b, h
	ld c, l
	pop hl
	ld [hl], b
	inc hl
	ld [hl], c
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	callab UtilitySyncParty
	callab DrawHUDsAndHPBars
	ret

; Contact replaces only the active ability, never the saved ability slot.
AbilityParasite:
	call AbilityTarget
	cp AB_PARASITE
	ret nz
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 1, a
	ret z
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld hl, wActiveAbilities
	ld a, [H_WHOSETURN]
	and a
	jr z, .infect
	inc hl
.infect
	ld a, [hl]
	cp AB_PARASITE
	ret z
	ld [hl], AB_PARASITE
	ld hl, AbilityParasiteText
	jp PrintText
AbilityParasiteText:
	text "PARASITE spread!"
	prompt

; A direct knockout picks Curse or ordinary poison with equal probability.
AbilityDeathSpore:
	ld a, [wCustomTargetHadSub]
	and a
	ret nz
	call AbilityTarget
	cp AB_DEATH_SPORE
	ret nz
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret nz
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	callab CustomRandomInBattleBank
	ld a, [wCustomRandomValue]
	and 1
	jr nz, .poison
	ld hl, wPlayerResidual
	ld a, [H_WHOSETURN]
	and a
	jr z, .curse
	ld hl, wEnemyResidual
.curse
	bit 1, [hl]
	ret nz
	set 1, [hl]
	ld hl, AbilityDeathSporeText
	jp PrintText
.poison
	ld a, [H_WHOSETURN]
	push af
	ld [wCustomSide], a
	xor 1
	ld [H_WHOSETURN], a
	ld a, 1 << PSN
	ld [wCustomDelta], a
	call AbilityInflictOrdinaryStatus
	pop af
	ld [H_WHOSETURN], a
	ret
AbilityDeathSporeText:
	text "DEATH SPORE"
	line "cursed its foe!"
	prompt

 ; Carry iff any opposing battle stage is below neutral (7).
AbilityTargetHasLoweredStage:
	ld hl, wEnemyMonStatMods
	ld a, [H_WHOSETURN]
	and a
	jr z, .scan
	ld hl, wPlayerMonStatMods
.scan
	ld b, 6
.loop
	ld a, [hli]
	cp 7
	ret c
	dec b
	jr nz, .loop
	and a
	ret

; Only a participating player's Greedy holder earns the bonus. Battle flags
; alone are insufficient: another ability can use the same flag bit.
AbilityGreedyPrize:
	ld hl, wPartyMon1
	ld de, wAbilityFlags
	ld a, [wPartyCount]
	ld b, a
.loop
	ld a, b
	and a
	ret z
	ld a, [de]
	bit 6, a
	jr z, .next
	push hl
	push de
	push bc
	ld a, [hl]
	cp MEOWTH
	jr z, .species
	cp PERSIAN
	jr nz, .notHolder
.species
	ld bc, 5
	add hl, bc
	ld a, [hli]
	and $e0
	cp 2 << 5
	jr nz, .notHolder
	ld a, [hl]
	and $e0
	cp NATURE_FORMAT_TAG
	jr nz, .notHolder
	pop bc
	pop de
	pop hl
	ld hl, wAmountMoneyWon + 2
	ld d, h
	ld e, l
	ld c, 3
	predef_jump AddBCDPredef
.notHolder
	pop bc
	pop de
	pop hl
.next
	ld a, b
	push af
	ld bc, wPartyMon2 - wPartyMon1
	add hl, bc
	pop af
	ld b, a
	inc de
	dec b
	jr .loop

AbilityActorPoisoned:
	ld hl, wBattleMonStatus
	ld a, [H_WHOSETURN]
	and a
	jr z, .check
	ld hl, wEnemyMonStatus
.check
	bit PSN, [hl]
	ret

AbilityToxicWaste:
	ld a, [wAbilitySide]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	jr z, .noHeal
	inc hl
	inc hl
	bit PSN, [hl]
	jr z, .noHeal
	ld a, [wAbilitySide]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_POISON_ABSORB
	ld a, 4
	jr nz, .heal
	dec a
.heal
	push af
	call AbilityHP
	pop af
	jp AbilityHealFractionFromHL
.noHeal
	ld a, [wAbilitySide]
	xor 1
	ld [wAbilitySide], a
	ret

; The entry bonus applies to the first incoming damaging action, including
; misses and Substitute hits; status moves do not consume it.
AbilityElusiveAfterAttack:
	ld a, [wAbilityHit]
	bit 3, a
	ret z
	call AbilityMove
	ld a, [hl]
	cp BIDE
	jr nz, .ordinary
	; Storage is not an attack; a release must have dealt damage.
	ld hl, wPlayerBattleStatus1
	ld a, [H_WHOSETURN]
	and a
	jr z, .bideStatus
	ld hl, wEnemyBattleStatus1
.bideStatus
	bit STORING_ENERGY, [hl]
	ret nz
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	or b
	ret z
	jr .target
.ordinary
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 0, a
	ret z
.target
	call AbilityTarget
	cp AB_ELUSIVE
	ret nz
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	bit 0, [hl]
	ret z
	res 0, [hl]
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	ld a, 5
	ld [wCustomStat], a
	ld a, -1
	ld [wCustomDelta], a
	xor a
	ld [wCustomChanged], a
	jpab CustomChangeStage

AbilityAftershock:
	call AbilityActor
	cp AB_WRESTLER
	jr nz, .aftershock
	ld a, [wAbilityMoveType]
	cp FIGHTING
	ret nz
	jr .paralyze
.aftershock
	cp AB_AFTERSHOCK
	ret nz
	ld a, [wAbilityMoveType]
	cp GROUND
	ret nz
.paralyze
	call AbilityTarget
	cp AB_SHIELD_DUST
	ret z
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret nz
	ld b, 20
	call AbilityRoll
	ret nc
	ld a, [H_WHOSETURN]
	xor 1
	ld [wCustomSide], a
	ld a, 1 << PAR
	ld [wCustomDelta], a
	jpab UtilityInflictStatus

; Each physical hit may inflict ordinary poison.
AbilityToxicScales:
	call AbilityActor
	cp AB_TOXIC_SCALES
	ret nz
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	call AbilityTarget
	cp AB_SHIELD_DUST
	ret z
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret nz
	ld b, 30
	call AbilityRoll
	ret nc
	ld a, [H_WHOSETURN]
	xor 1
	ld [wCustomSide], a
	ld a, 1 << PSN
	ld [wCustomDelta], a
	jp AbilityInflictOrdinaryStatus

; Choose among the three statuses uniformly; immunities do not reroll.
AbilityEffectSpore:
	call AbilityTarget
	cp AB_EFFECT_SPORE
	ret nz
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret nz
	ld b, 20
	call AbilityRoll
	ret nc
.choose
	callab CustomRandomInBattleBank
	ld a, [wCustomRandomValue]
	and 3
	cp 3
	jr z, .choose
	cp 2
	jr z, .sleep
	ld c, 1 << PSN
	and a
	jr z, .inflict
	ld c, 1 << PAR
.inflict
	ld a, [H_WHOSETURN]
	push af
	ld [wCustomSide], a
	xor 1
	ld [H_WHOSETURN], a
	ld a, c
	ld [wCustomDelta], a
	call AbilityInflictOrdinaryStatus
	pop af
	ld [H_WHOSETURN], a
	ret
.sleep
	callab CustomRandomInBattleBank
	ld a, [wCustomRandomValue]
	and 7
	cp 2
	jr c, .sleep
	ld b, a
	ld a, [H_WHOSETURN]
	ld [wCustomSide], a
	ld hl, wBattleMonStatus
	ld de, wPlayerBattleStatus2
	and a
	jr z, .storeSleep
	ld hl, wEnemyMonStatus
	ld de, wEnemyBattleStatus2
.storeSleep
	ld [hl], b
	ld a, [de]
	res NEEDS_TO_RECHARGE, a
	ld [de], a
	; Sleep interrupts the remaining strikes of a multi-hit move.
	ld hl, wPlayerBattleStatus1
	ld de, wPlayerNumAttacksLeft
	ld a, [H_WHOSETURN]
	and a
	jr z, .interrupt
	ld hl, wEnemyBattleStatus1
	ld de, wEnemyNumAttacksLeft
.interrupt
	bit ATTACKING_MULTIPLE_TIMES, [hl]
	jr z, .syncSleep
	ld a, 1
	ld [de], a
.syncSleep
	callab UtilitySyncParty
	ld hl, AbilityEffectSporeSleepText
	jp PrintText
AbilityEffectSporeSleepText:
	text "Fell asleep!"
	prompt

AbilityRubberSkinCheck:
	xor a
	ld [wAbilityCheckResult], a
	call AbilityActorMoveType
	cp ELECTRIC
	ret nz
	call AbilityTarget
	cp AB_RUBBER_SKIN
	ret nz
	ld a, 1
	ld [wAbilityCheckResult], a
	ret

AbilitySoothingVoice:
	ld a, [wAbilityHit]
	bit 3, a
	ret z
	call AbilityActor
	cp AB_SOOTHING_VOICE
	ret nz
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 4, a
	ret z
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	dec hl
	ld a, 3
	jp AbilityHealFractionFromHL

AbilityFoxfire:
	call AbilityActor
	cp AB_FOXFIRE
	ret nz
	ld a, [wAbilityOldStatus]
	bit BRN, a
	ret nz
	call AbilityTargetStatus
	bit BRN, [hl]
	ret z
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	call AbilityFlagsPointer
	bit 0, [hl]
	ret nz
	set 0, [hl]
	ld a, 3
	jp AbilityRaiseStage

AbilityBloodlustCheck:
	ld a, [H_WHOSETURN]
	xor 1
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	jr z, .no
	dec hl
	jp AbilityHalfHP
.no
	and a
	ret

; Preserve the substitute's pre-hit HP for recoil or healing if it breaks.
AbilityCaptureRampageSubHP:
	call AbilityActor
	cp AB_RAMPAGE
	jr z, .eligible
	cp AB_LEECHING
	ret nz
.eligible
	ld a, [wCustomTargetHadSub]
	and a
	ret z
	ld hl, wEnemySubstituteHP
	ld a, [H_WHOSETURN]
	and a
	jr z, .store
	ld hl, wPlayerSubstituteHP
.store
	ld a, [hl]
	ld [wAbilityTemp + 1], a
	ret

AbilityRampage:
	call AbilityActor
	cp AB_RAMPAGE
	ret nz
	call AbilityActorMoveType
	cp FIRE
	ret nc
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld a, [wDamage]
	ld b, a
	ld a, [wDamage + 1]
	ld c, a
	or b
	ret z
	ld a, [wCustomTargetHadSub]
	and a
	jr z, .divide
	ld a, [wAbilityTemp + 1]
	ld d, a
	ld a, b
	and a
	jr nz, .cap
	ld a, c
	cp d
	jr c, .divide
.cap
	ld b, 0
	ld c, d
.divide
	xor a
	ld [H_DIVIDEND], a
	ld [H_DIVIDEND + 1], a
	ld a, b
	ld [H_DIVIDEND + 2], a
	ld a, c
	ld [H_DIVIDEND + 3], a
	ld a, 10
	ld [H_DIVISOR], a
	ld b, 4
	call Divide
	ld a, [H_QUOTIENT + 2]
	ld b, a
	ld a, [H_QUOTIENT + 3]
	ld c, a
	or b
	jr nz, .amount
	inc c
.amount
	call AbilityHP
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
	ld hl, AbilityRampageText
	jp PrintText
AbilityRampageText:
	text "Hurt by"
	line "RAMPAGE!"
	prompt

AbilitySpinyArmor:
	call AbilityActor
	cp AB_MAGIC_GUARD
	ret z
	call AbilityTarget
	cp AB_SPINY_ARMOR
	jr z, .physical
	cp AB_SPIKED_SHELL
	ret nz
.physical
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
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
	rept 4
	srl b
	rr c
	endr
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
	call AbilityTarget
	cp AB_SPIKED_SHELL
	ld hl, AbilitySpinyArmorText
	jr nz, .print
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

; A successful critical hit, including against a Substitute, triggers once.
AbilityOvercharge:
	call AbilityActor
	cp AB_OVERCHARGE
	ret nz
	ld a, [wCriticalHitOrOHKO]
	cp 1 ; 2 is an OHKO, not a critical hit
	ret nz
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	call AbilityFlagsPointer
	bit 1, [hl]
	ret nz
	set 1, [hl]
	ld a, 3 ; Special
	jp AbilityRaiseStage

AbilityShortTemper:
	call AbilityActor
	cp AB_SHORT_TEMPER
	ret nz
	ld a, [wMoveMissed]
	and a
	ret z
	ld a, [wDamageMultipliers]
	and $7f
	ret z ; immunity is not a miss
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	xor a ; Attack
	jp AbilityRaiseStage

AbilityGetTargetReactions:
	call AbilityHP
	ld a, [hli]
	or [hl]
	jp z, .contact
	call AbilityTarget
	cp AB_STAMINA
	jr nz, .slippery
	ld a, 1 ; Defense
	call AbilityRaiseStage
	jp .contact
.slippery
	cp AB_SLIPPERY
	jr nz, .inflatable
	ld a, [wAbilityMoveType]
	cp FIRE
	jp nc, .contact
	call AbilityFlagsPointer
	bit 2, [hl]
	jp nz, .contact
	set 2, [hl]
	ld a, 5 ; Evasion
	call AbilityRaiseStage
	jr .contact
.inflatable
	cp AB_INFLATABLE
	jr nz, .hotTemper
	ld a, [wAbilityMoveType]
	cp FIRE
	jp nc, .contact
	ld a, 1 ; Defense
	call AbilityRaiseStage
	jr .contact
.hotTemper
	cp AB_OVERLOAD
	jr z, .overload
	cp AB_HEADACHE
	jr nz, .swiftSwim
.overload
	ld a, [wAbilityMoveType]
	cp FIRE
	jr c, .contact
	call AbilityFlagsPointer
	bit 0, [hl]
	jp nz, .contact
	set 0, [hl]
	ld a, 3
	call AbilityRaiseStage
	jr .contact
.swiftSwim
	cp AB_SWIFT_SWIM
	jr nz, .hotTemperCheck
	ld a, [wAbilityMoveType]
	cp WATER
	jp nz, .contact
	ld a, 2
	call AbilityRaiseStage
	ld a, 2
	call AbilityRaiseStage
	jr .contact
.hotTemperCheck
	cp AB_HOT_TEMPER
	jr nz, .shellGuard
	ld a, [wAbilityMoveType]
	cp FIRE
	jp nc, .contact
	call AbilityFlagsPointer
	bit 0, [hl]
	jp nz, .contact
	set 0, [hl]
	ld a, 3
	call AbilityRaiseStage
	jr .contact
.shellGuard
	cp AB_SHELL_GUARD
	jp nz, .contact
	ld a, [wCriticalHitOrOHKO]
	and a
	jr z, .contact
	ld a, 1
	call AbilityRaiseStage
.contact
	ld hl, wAbilityHit
	bit 2, [hl]
	ret nz
	set 2, [hl]
	call AbilityFlameBody
	call AbilityTarget
	cp AB_PHYSICAL_POISON_POINT
	jr nz, .staticCheck
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	jp .poison
.staticCheck
	cp AB_STINGING_SKIN
	jr nz, .static
	ld a, [wAbilityMoveType]
	cp FIRE
	ret nc
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld b, 20
	call AbilityRoll
	ret nc
	jp .inflictReactivePoison
.static
	cp AB_STATIC
	jr nz, .contactMove
	ld a, [wAbilityMoveType]
	cp FIRE ; all physical moves, including ranged moves
	ret nc
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	ld b, 20
	call AbilityRoll
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
.contactMove
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 1, a
	ret z
	call AbilityTarget
	cp AB_DUST_CLOUD
	jr nz, .point
	ld b, 25
	call AbilityRoll
	ret nc
	call AbilityActor
	cp AB_CLEAR_BODY
	ret z
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	ld a, 4
	ld [wCustomStat], a
	ld a, -1
	ld [wCustomDelta], a
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	xor a
	ld [wCustomChanged], a
	jpab CustomChangeStage
.point
	cp AB_POISON_POINT
	jr z, .poison
	cp AB_TOXIC_SHELL
	ret nz
.poison
	ld b, 25
	call AbilityRoll
	ret nc
.inflictReactivePoison
	; Reverse actor/target for the reactive status, then restore the real turn.
	ld a, [H_WHOSETURN]
	push af
	xor 1
	ld [H_WHOSETURN], a
	xor 1
	ld [wCustomSide], a
	ld a, 1 << PSN
	ld [wCustomDelta], a
	call AbilityInflictOrdinaryStatus
	pop af
	ld [H_WHOSETURN], a
	ret

AbilityLowHPBoth:
	xor a
	ld [wAbilitySide], a
	call AbilityLowHP
	ld a, 1
	ld [wAbilitySide], a
AbilityLowHP:
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_SURVIVAL_INSTINCTS
	jr z, .speed
	cp AB_FORTIFY
	jr nz, .cornered
	ld a, 1
	jr .stat
.cornered
	cp AB_CORNERED
	jr nz, .protective
	xor a ; Attack
	jr .stat
.protective
	cp AB_UNSTABLE
	jr z, .unstable
	cp AB_PROTECTIVE_INSTINCT
	ret nz
	ld a, 1 ; Defense
	push af
	call AbilityHP
	ld a, [hli]
	or [hl]
	jr z, .done
	dec hl
	call AbilityHalfHP
	jr nc, .done
	jr .eligible
.unstable
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 dec hl
 call AbilityHalfHP
 ret nc
 call AbilityFlagsPointer
 bit 2, [hl]
 ret nz
 set 2, [hl]
.randomStat
 callab CustomRandomInBattleBank
 ld a, [wCustomRandomValue]
 and 7
 cp 6
 jr nc, .randomStat
 jp AbilityRaiseStage
.speed
 ld a, 2
.stat
	push af
	call AbilityBelowThird
	jr nc, .done
.eligible
	call AbilityFlagsPointer
	bit 2, [hl]
	jr nz, .done
	set 2, [hl]
	pop af
	jp AbilityRaiseStage
.done
	pop af
	ret

AbilityFrenzy:
	call AbilityActor
	cp AB_FRENZY
	jr z, .directKO
	cp AB_SCAVENGER
	jr z, .directKO
	cp AB_LOYALTY
	jr z, .directKO
	cp AB_CARNIVOROUS
	ret nz
.directKO
	ld a, [wAbilityHit]
	and 1
	ret z
	call AbilityTargetStatus
	dec hl
	ld a, [hld]
	or [hl]
	ret nz
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	call AbilityActor
	cp AB_SCAVENGER
	jr z, AbilityHealQuarter
	cp AB_LOYALTY
	jp z, AbilityHealFifth
	cp AB_CARNIVOROUS
	jp z, AbilityHealFifth
	xor a
	jp AbilityRaiseStage

AbilityHealQuarter:
	call AbilityHP
	ld a, 2
	jp AbilityHealFractionFromHL

; Called at poison damage time; skips poison damage but not Leech Seed.
AbilityMagicGuardActor:
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
AbilityMagicGuardCheck:
	xor a
	ld [wAbilityCheckResult], a
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_MAGIC_GUARD
	ret nz
	ld a, 1
	ld [wAbilityCheckResult], a
	ret

AbilityPoisonHeal:
	xor a
	ld [wAbilityCheckResult], a
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityGet
	cp AB_MAGIC_GUARD
	jr nz, .poisonHeal
	ld a, 2
	ld [wAbilityCheckResult], a
	ret
.poisonHeal
	cp AB_POISON_HEAL
	ret nz
	call AbilityHP
	push hl
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	pop hl
	bit PSN, a
	ret z
	ld a, [hli]
	or [hl]
	ret z
	dec hl
	ld a, 1
	ld [wAbilityCheckResult], a
	ld a, 3
	jp AbilityHealFractionFromHL

; Accuracy is stored on a 0..255 scale: 15 percentage points = 38 units.
AbilityHustleAccuracy:
	call AbilityActor
	cp AB_UNSOPHISTICATED
	jr nz, .hustle
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 6, a
	ret z
	call AbilityMove
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, [hl]
	sub 25
	jr nc, .writeUnsophisticated
	ld a, 1
.writeUnsophisticated
	and a
	jr nz, .storeUnsophisticated
	inc a
.storeUnsophisticated
	ld [hl], a
	ret
.hustle
	cp AB_HUSTLE
	ret nz
	call AbilityMove
	inc hl
	inc hl
	ld a, [hli] ; power
	and a
	ret z
	ld a, [hli] ; type
	cp FIRE
	ret nc
	ld a, [hl] ; accuracy
	sub 38
	jr nc, .store
	ld a, 1
.store
	and a
	jr nz, .write
	inc a
.write
	ld [hl], a
	ret

AbilityRegeneration:
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	; Use the Photosynthesis amount/cap/sync path without its HP threshold.
	call AbilityHP
	push hl
	jp AbilityPhotosynthesis.notEqual

AbilityShedSkin:
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_SHED_SKIN
	ret nz
	call AbilityHP
	ld a, [hli]
	or [hl]
	ret z
	inc hl
	inc hl ; status is HP + 3
	ld a, [hl]
	and a
	ret z
	ld b, 30
	call AbilityRoll
	ret nc
	call AbilityHP
	inc hl
	inc hl
	inc hl
	xor a
	ld [hl], a
	ld hl, wPlayerBattleStatus3
	ld de, wPlayerToxicCounter
	ld a, [wAbilitySide]
	and a
	jr z, .clearToxic
	ld hl, wEnemyBattleStatus3
	ld de, wEnemyToxicCounter
.clearToxic
	res BADLY_POISONED, [hl]
	xor a
	ld [de], a
	ld a, [wAbilitySide]
	ld [wCustomSide], a
	callab CustomRecalculate
	callab UtilitySyncParty
	callab DrawHUDsAndHPBars
	ld hl, AbilityShedSkinText
	jp PrintText

AbilityShedSkinText:
	text "Shed Skin cured"
	line "its condition!"
	prompt

; Common critical-hit gate runs before guaranteed-critical move rules.
AbilityCriticalGuard:
	xor a
	ld [wAbilityCheckResult], a
	call AbilityTarget
	cp AB_SHELL_ARMOR
	jr z, .block
	cp AB_BATTLE_ARMOR
	jr z, .block
	cp AB_IRON_WILL
	ret nz
.block
	ld a, 1
	ld [wAbilityCheckResult], a
	ret
AbilityRuthless:
	call AbilityActor
	cp AB_RUTHLESS
	jr nz, .sharpClaws
	call AbilityTargetStatus
	ld a, [hl]
	and a
	ret z
	ld a, [wNatureResult]
	add a
	jr nc, .store
	ld a, 255
.store
	ld [wNatureResult], a
	ret
.sharpClaws
	cp AB_RAZOR_EDGE
	jr z, .razorEdge
	cp AB_SHARP_CLAWS
	ret nz
	call AbilityActorMoveType
	cp FIRE ; physical types precede FIRE
	ret nc
	ld a, [wNatureResult]
	ld b, a
	srl a
	add b
	jr nc, .store
	ld a, 255
	jr .store

.razorEdge
 call AbilityCuttingCheck
 ret nc
 ld a, [wNatureResult]
 add 38 ; 15 percentage points in the 256-value critical threshold
 jr nc, .razorStore
 ld a, 255
.razorStore
 ld [wNatureResult], a
 ret

; Shield Dust blocks target-directed secondary effects only. Multi-hit,
; recoil, draining, screen removal and primary trapping effects still execute.
AbilityEffectGate:
	xor a
	ld [wAbilityCheckResult], a
	call AbilityMove
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	and a
	ret z
	ld a, b
	ld hl, AbilitySecondaryEffects
	ld de, 1
	push bc
	call IsInArray
	pop bc
	jr c, .secondary
	ld a, c
	cp TRI_ATTACK
	jr z, .secondary
	cp SCALD
	jr z, .secondary
	cp POISON_FANG
	ret nz
.secondary
	call AbilityActor
	cp AB_SHEER_FORCE
	jr z, .checkThaw
	call AbilityTarget
	cp AB_SHIELD_DUST
	jr z, .checkThaw
	cp AB_STEADFAST
	jr z, .steadfast
	cp AB_OBLIVIOUS
	jr z, .steadfast
	cp AB_HEADSTRONG
	ret nz
	ld a, b
	cp CONFUSION_SIDE_EFFECT
	jr z, .block
	ret
.steadfast
	ld a, b
	cp FLINCH_SIDE_EFFECT1
	jr z, .block
	cp FLINCH_SIDE_EFFECT2
	jr z, .block
	cp CONFUSION_SIDE_EFFECT
	ret nz
	jr .block
.checkThaw
	ld a, b
	cp BURN_SIDE_EFFECT1
	jr z, .thaw
	cp BURN_SIDE_EFFECT2
	jr nz, .block
.thaw
	call AbilityTargetStatus
	bit FRZ, [hl]
	ret nz
.block
	ld a, 1
	ld [wAbilityCheckResult], a
	ret
AbilitySecondaryEffects:
	db POISON_SIDE_EFFECT1, POISON_SIDE_EFFECT2, BURN_SIDE_EFFECT1, BURN_SIDE_EFFECT2
	db FREEZE_SIDE_EFFECT, PARALYZE_SIDE_EFFECT1, PARALYZE_SIDE_EFFECT2
	db FLINCH_SIDE_EFFECT1, FLINCH_SIDE_EFFECT2, CONFUSION_SIDE_EFFECT
	db ATTACK_DOWN_SIDE_EFFECT, DEFENSE_DOWN_SIDE_EFFECT, SPEED_DOWN_SIDE_EFFECT, SPECIAL_DOWN_SIDE_EFFECT
	db ATTACK_AND_STAT_EFFECT, $ff

AbilityBurnGate:
	xor a
	ld [wAbilityCheckResult], a
	ld a, [wCustomDelta]
	cp 1 << PSN
	jr nz, .burn
	ld a, [wCustomSide]
	call AbilityGet
	cp AB_IMMUNITY
	jr z, .block
	ret
.burn
	ld a, [wCustomDelta]
	cp 1 << BRN
	ret nz
	call AbilityTarget
	cp AB_WATER_VEIL
	ret nz
.block
	ld a, 1
	ld [wAbilityCheckResult], a
	ret

; Accuracy is scaled after nature and stage factors, before final byte cap.
AbilityAccuracy:
	call AbilityActor
	cp AB_GENIUS
	jr nz, .hypnotic
	call AbilityMove
	inc hl
	inc hl
	ld a, [hl]
	and a
	jp nz, .target
	jr .flat15
.hypnotic
	cp AB_HYPNOTIC
	jr nz, .mycelium
	call AbilityMove
	inc hl
	ld a, [hl]
	cp SLEEP_EFFECT
	jp nz, .target
.flat15
	ld a, [H_QUOTIENT + 3]
	add 38 ; 15 percentage points on the 0..255 scale
	ld [H_QUOTIENT + 3], a
	jp nc, .target
	ld hl, H_QUOTIENT + 2
	inc [hl]
	jp .target
.mycelium
	cp AB_MYCELIUM
	jr nz, .pollen
	call AbilityMove
	inc hl
	inc hl
	ld a, [hl]
	and a
	jr nz, .target
	xor a
	ld [H_QUOTIENT + 2], a
	dec a
	ld [H_QUOTIENT + 3], a
	ret
.pollen
	cp AB_POLLEN
	jr nz, .echolocation
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 5, a
	jr z, .target
	jr .flat20
.echolocation
	cp AB_ECHOLOCATION
	jr nz, .compound
.flat20
	ld a, [H_QUOTIENT + 3]
	add 51 ; 20 percentage points on the 0..255 accuracy scale
	ld [H_QUOTIENT + 3], a
	jr nc, .target
	ld hl, H_QUOTIENT + 2
	inc [hl]
	jr .target
.compound
	cp AB_COMPOUND_EYES
	jr nz, .performer
	ld c, 130
	call AbilityScaleAccuracy
	jr .target
.performer
	cp AB_PERFORMER
	jr nz, .target
	call AbilityMove
	ld a, [hl]
	call AbilityMoveFlags
	bit 4, a
	jr z, .target
	ld c, 120
	call AbilityScaleAccuracy
.target
	call AbilityTarget
	cp AB_WONDER_SKIN
	ret nz
	call AbilityMove
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret nz
	ld c, 50
AbilityScaleAccuracy:
	xor a
	ld [H_MULTIPLICAND], a
	ld a, [H_QUOTIENT + 2]
	ld [H_MULTIPLICAND + 1], a
	ld a, [H_QUOTIENT + 3]
	ld [H_MULTIPLICAND + 2], a
	ld a, c
	ld [H_MULTIPLIER], a
	call Multiply
	ld a, 100
	ld [H_DIVISOR], a
	ld b, 4
	jp Divide

; Move metadata: bit0 damaging, bit1 contact. Lists are indexed by move ID.
AbilityMoveFlags:
	cp MAX_MOVE_ID + 1
	jr nc, .invalid
	and a
	ret z
	dec a
	ld e, a
	ld d, 0
	ld hl, AbilityMoveMetadata
	add hl, de
	ld a, [hl]
	ret

.invalid
	xor a
	ret

; Exact signed priorities, including Quick Reflexes stacking with +1 moves.
AbilityPriority:
	call AbilityLowHPBoth
	xor a
	ld [wAbilitySide], a
	call AbilityPriorityOne
	ld [wAbilityTemp], a
	ld a, 1
	ld [wAbilitySide], a
	call AbilityPriorityOne
	ld b, a
	ld a, [wAbilityTemp]
	xor $80
	ld c, a
	ld a, b
	xor $80
	cp c
	ld a, 0
	jr z, .store
	ld a, 1
	jr c, .store
	inc a
.store
	ld [wAbilityCheckResult], a
	ret
AbilityPriorityOne:
	ld a, [wAbilitySide]
	and a
	ld a, [wPlayerSelectedMove]
	jr z, .selected
	ld a, [wEnemySelectedMove]
.selected
	ld [wAbilityTemp + 1], a
	ld b, 0
	cp COUNTER
	jr nz, .positive
	dec b
	jr .quick
.positive
	cp QUICK_ATTACK
	jr z, .plus
	cp AQUA_JET
	jr z, .plus
	cp THUNDERCLAP
	jr z, .plus
	cp AMBUSH
	jr nz, .quick
	push bc
	ld hl, wEnemyMonHP
	ld de, wEnemyMonMaxHP
	ld a, [wAbilitySide]
	and a
	jr z, .ambush
	ld hl, wBattleMonHP
	ld de, wBattleMonMaxHP
.ambush
	call AbilityHalfHP
	pop bc
	jr nc, .quick
.plus
	inc b
.quick
	push bc
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_QUICK_REFLEXES
	jr nz, .gale
	call AbilityFlagsPointer
	bit 3, [hl]
	jr nz, .plain
	ld a, [wAbilityTemp + 1]
	call AbilityMoveFlags
	bit 0, a
	jr z, .plain
	pop bc
	inc b
	ld a, b
	ret
.gale
	cp AB_GALE_WINGS
	jr nz, .plain
	call AbilityHP
	ld a, [de]
	cp [hl]
	jr nz, .plain
	inc de
	inc hl
	ld a, [de]
	cp [hl]
	jr nz, .plain
	ld a, [wAbilityTemp + 1]
	call AbilityMoveFlags
	bit 2, a
	jr z, .plain
	pop bc
	inc b
	ld a, b
	ret
.plain
	pop bc
	ld a, b
	ret

; HP calculation hook: after nature scaling, before the result is stored.
AbilityAncientHP:
	ld a, [wNatureInputBC + 1]
	cp 1
	ret nz
	ld a, [wNatureInputHL]
	ld h, a
	ld a, [wNatureInputHL + 1]
	ld l, a
	ld de, wEnemyMonHP
	ld a, h
	cp d
	jr nz, .player
	ld a, l
	cp e
	jr nz, .player
	ld a, [wMonHIndex]
	call AbilityHPScalingFamily
	ret nz
	ld a, [wNatureEnemySlot]
	jr .slot
.player
	ld de, wBattleMonHP
	ld a, h
	cp d
	jr nz, .stored
	ld a, l
	cp e
	jr nz, .stored
	ld a, [wActiveAbilities]
	cp AB_ANCIENT
	jr z, .boost
	cp AB_BLUBBER
	ret nz
	jr .boost
.stored
	ld de, -16
	add hl, de
	ld a, [hl]
	call AbilityHPScalingFamily
	ret nz
	ld de, 5
	add hl, de
	ld a, [hl]
	rlca
	rlca
	rlca
	and 7
.slot
	cp b
	ret nz
.boost
	ld c, 120
	call AbilityScaleAccuracy ; same 16-bit quotient scaling, no accuracy cap
	ld a, [H_QUOTIENT + 2]
	cp 3
	jr c, .done
	jr nz, .cap
	ld a, [H_QUOTIENT + 3]
	cp 232
	ret c
.cap
	ld a, 3
	ld [H_QUOTIENT + 2], a
	ld a, 231
	ld [H_QUOTIENT + 3], a
.done
	ret
; A = species; Z and B = its HP-boosting slot, or NZ if unsupported.
AbilityHPScalingFamily:
 cp SEEL
 jr z, .blubber
 cp DEWGONG
 jr z, .blubber
 call AbilitySquirtleFamily
 ret nz
 ld b, 3
 xor a
 ret
.blubber
 ld b, 1
 xor a
 ret

AbilitySquirtleFamily:
	cp SQUIRTLE
	ret z
	cp WARTORTLE
	ret z
	cp BLASTOISE
	ret

INCLUDE "data/ability_move_metadata.asm"

AbilityDustOnly:
	xor a
	ld [wAbilityCheckResult], a
	call AbilityTarget
	cp AB_IMMUNITY
	jr z, .block
	cp AB_SHIELD_DUST
	ret nz
	call AbilityMove
	inc hl
	inc hl
	ld a, [hl]
	and a
	ret z
.block
	ld a, 1
	ld [wAbilityCheckResult], a
	ret

AbilityHalfHP:
	ld a, [hli]
	ld l, [hl]
	ld h, a
	add hl, hl
	jr c, .no
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	ld c, a
	ld a, h
	cp b
	ret nz
	ld a, l
	cp c
	ret
.no
	and a
	ret

AbilityPlayerEntry:
	xor a
	ld [wRolloutStacks], a
	call AbilityClearRelentless
	ld hl, wAbilityFlags
	ld a, [wWhichPokemon]
	ld c, a
	ld b, 0
	add hl, bc
	res 3, [hl]
	ret

AbilityVeilOnly:
	xor a
	ld [wAbilityCheckResult], a
	call AbilityTarget
	cp AB_WATER_VEIL
	ret nz
	ld a, 1
	ld [wAbilityCheckResult], a
	ret

; Ability poison is ordinary poison. Poison Fang's shared utility deliberately
; inflicts bad poison, so use a separate status writer for these passives.
AbilityInflictOrdinaryStatus:
	ld a, [wCustomDelta]
	cp 1 << PSN
	jp nz, .burn
	ld a, [wCustomSide]
	call AbilityGet
	cp AB_IMMUNITY
	ret z
	xor a
	ld [wCustomChanged], a
	ld hl, wBattleMonStatus
	ld a, [wCustomSide]
	and a
	jr z, .status
	ld hl, wEnemyMonStatus
.status
	ld a, [hl]
	and a
	ret nz
	push hl
	dec hl
	ld a, [hld]
	or [hl]
	pop hl
	ret z
	inc hl
	ld a, [hli]
	cp POISON
	ret z
	ld a, [hl]
	cp POISON
	ret z
	dec hl
	dec hl
	push hl
	callab ResidualTargetCursed
	pop hl
	ret nz
	ld a, 1 << PSN
	ld [hl], a
	ld hl, wPlayerBattleStatus3
	ld de, wPlayerToxicCounter
	ld a, [wCustomSide]
	and a
	jr z, .clearToxic
	ld hl, wEnemyBattleStatus3
	ld de, wEnemyToxicCounter
.clearToxic
	res BADLY_POISONED, [hl]
	xor a
	ld [de], a
	inc a
	ld [wCustomChanged], a
	callab CustomRecalculate
	callab UtilitySyncParty
	ld hl, AbilityPoisonedText
	jp PrintText
.burn
	jpab UtilityInflictStatus

AbilityExplodeEffect:
	ld hl, wBattleMonHP
	ld de, wPlayerBattleStatus2
	ld a, [H_WHOSETURN]
	and a
	jr z, .faintUser
	ld hl, wEnemyMonHP
	ld de, wEnemyBattleStatus2
.faintUser
	xor a
	ld [hli], a ; set the mon's HP to 0
	ld [hli], a
	inc hl
	ld [hl], a ; set mon's status to 0
	ld a, [de]
	res SEEDED, a ; clear mon's leech seed status
	ld [de], a
	ret

; Clear both volatile conditions from the actor, including self-confusion.
AbilitySteadfastActor:
 call AbilityActor
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

AbilitySteadfastDirectCheck:
 xor a
 ld [wAbilityCheckResult], a
 call AbilityMove
 inc hl
 ld a, [hl]
 cp CONFUSION_EFFECT
 ret nz
 call AbilityTarget
 jr AbilitySteadfastCheck

AbilitySteadfastCustomCheck:
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wCustomSide]
 call AbilityGet
AbilitySteadfastCheck:
 cp AB_STEADFAST
 jr z, .immune
 cp AB_OBLIVIOUS
 jr z, .immune
 cp AB_HEADSTRONG
 ret nz
.immune
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

; Carry iff the executing move's actual maximum PP is at most 10.
AbilityLegendaryCheck:
 ld a, [H_WHOSETURN]
 and a
 ld hl, wPlayerBattleStatus3
 jr z, .transform
 ld hl, wEnemyBattleStatus3
.transform
 bit TRANSFORMED, [hl]
 jr z, .base
 scf
 ret
.base
 call AbilityMove
 ld a, [hl]
 and a
 ret z
 dec a
 ld hl, Moves + 5
 ld bc, MoveEnd - Moves
 call AddNTimes
 ld de, wAbilityTemp
 ld bc, 1
 ld a, BANK(Moves)
 call FarCopyData
 ld a, [wAbilityTemp]
 cp 11
 ret nc
 cp 6
 jr c, .yes
 ; PP-Ups add floor(base PP / 5) each; here the base is 6..10.
 ld b, a
 ld hl, wBattleMonPP
 ld a, [H_WHOSETURN]
 and a
 ld a, [wPlayerMoveListIndex]
 jr z, .pp
 ld hl, wEnemyMonPP
 ld a, [wEnemyMoveListIndex]
.pp
 and 3
 ld e, a
 ld d, 0
 add hl, de
 ld a, [hl]
 and $c0
 rlca
 rlca
 ld c, a
 ld a, b
 cp 10
 ld d, 1
 jr nz, .add
 inc d
.add
 ld a, c
 and a
 jr z, .compare
 ld a, b
 add d
 ld b, a
 dec c
 jr .add
.compare
 ld a, b
 cp 11
 ret
.yes
 scf
 ret

; Restore floor(maximum HP / 5), with the usual minimum of 1 and HP cap.
AbilityHealFifth:
 ld a, 5
AbilityHealDivided:
 ld [wAbilityTemp + 1], a
 call AbilityHP
 push hl
 push de
 xor a
 ld [H_DIVIDEND], a
 ld [H_DIVIDEND + 1], a
 ld a, [de]
 ld [H_DIVIDEND + 2], a
 inc de
 ld a, [de]
 ld [H_DIVIDEND + 3], a
 ld a, [wAbilityTemp + 1]
 ld [H_DIVISOR], a
 ld b, 4
 call Divide
 ld a, [H_QUOTIENT + 2]
 ld b, a
 ld a, [H_QUOTIENT + 3]
 ld c, a
 or b
 jr nz, .amount
 inc c
.amount
 pop de
 pop hl
 push hl
 ld a, [hli]
 ld l, [hl]
 ld h, a
 add hl, bc
 ld a, [de]
 ld b, a
 inc de
 ld a, [de]
 ld c, a
 ld a, h
 cp b
 jr c, .store
 jr nz, .cap
 ld a, l
 cp c
 jr c, .store
.cap
 ld h, b
 ld l, c
.store
 ld b, h
 ld c, l
 pop hl
 ld [hl], b
 inc hl
 ld [hl], c
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 jpab UtilitySyncParty

; Bounce opposing status moves once, without spending a second move or PP.
AbilityBounceDispatch:
 call AbilityTarget
 cp AB_MAGIC_BOUNCE
 jp nz, .ordinary
 call AbilityMove
 ld a, [hli]
 ld b, a
 inc hl
 ld a, [hl]
 and a
 jr nz, .ordinary
 ld a, b
 ld hl, AbilityBounceMoves
 ld de, 1
 call IsInArray
 jr nc, .ordinary
 ; Preserve the opposing move record on the stack, then lend it the move.
 ld hl, wPlayerMoveNum
 ld de, wEnemyMoveNum
 ld a, [H_WHOSETURN]
 and a
 jr z, .copy
 ld hl, wEnemyMoveNum
 ld de, wPlayerMoveNum
.copy
 ld b, 6
.saveLoop
 ld a, [de]
 push af
 ld a, [hli]
 ld [de], a
 inc de
 dec b
 jr nz, .saveLoop
 ld a, [H_WHOSETURN]
 xor 1
 ld [H_WHOSETURN], a
 callab DispatchMoveEffect
 ld a, [H_WHOSETURN]
 xor 1
 ld [H_WHOSETURN], a
 ; Re-select the temporary record, restoring it from its last byte.
 and a
 ld hl, wEnemyMoveMaxPP
 jr z, .restore
 ld hl, wPlayerMoveMaxPP
.restore
 ld b, 6
.restoreLoop
 pop af
 ld [hld], a
 dec b
 jr nz, .restoreLoop
 ret
.ordinary
 jpab DispatchMoveEffect

AbilityBounceMoves:
 db WHIRLWIND, TAIL_WHIP, LEER, GROWL, ROAR, SING, SUPERSONIC, DISABLE
 db LEECH_SEED, POISONPOWDER, STUN_SPORE, SLEEP_POWDER, THUNDER_WAVE, TOXIC
 db HYPNOSIS, SCREECH, SMOKESCREEN, CONFUSE_RAY, KINESIS, SPLASH, GLARE, POISON_GAS
 db LOVELY_KISS, SPORE, WILL_O_WISP, FLASH_FREEZE, CURSE, CHARM, $ff

AbilityMultiHitEffect:
	ld hl, wPlayerBattleStatus1
	ld de, wPlayerNumAttacksLeft
	ld bc, wPlayerNumHits
	ld a, [H_WHOSETURN]
	and a
	jr z, .twoToFiveAttacksEffect
	ld hl, wEnemyBattleStatus1
	ld de, wEnemyNumAttacksLeft
	ld bc, wEnemyNumHits
.twoToFiveAttacksEffect
	bit ATTACKING_MULTIPLE_TIMES, [hl] ; is mon attacking multiple times?
	ret nz
	set ATTACKING_MULTIPLE_TIMES, [hl] ; mon is now attacking multiple times
	ld hl, wPlayerMoveEffect
	ld a, [H_WHOSETURN]
	and a
	jr z, .setNumberOfHits
	ld hl, wEnemyMoveEffect
.setNumberOfHits
	push hl
	ld a, [H_WHOSETURN]
	and a
	ld a, [wPlayerMoveNum]
	jr z, .checkTripleKick
	ld a, [wEnemyMoveNum]
.checkTripleKick
	cp TRIPLE_KICK
	pop hl
	ld a, 3
	jr z, .saveNumberOfHits
	ld a, [hl]
	cp TWINEEDLE_EFFECT
	jr z, .twineedle
	cp ATTACK_TWICE_EFFECT
	ld a, $2 ; number of hits it's always 2 for ATTACK_TWICE_EFFECT
	jr z, .saveNumberOfHits
; Four Arms gives variable-hit attacks their maximum of five hits.
	call AbilityActor
	cp AB_FOUR_ARMS
	jr z, .maximumHits
	cp AB_SKILL_LINK
	jr nz, .rollHits
.maximumHits
	ld a, 5
	jr .saveNumberOfHits
.rollHits
	push bc
	push de
	callab CustomRandomInBattleBank
	pop de
	pop bc
	ld a, [wCustomRandomValue]
	and $3
	cp $2
	jr c, .gotNumHits
; if the number of hits was greater than 2, re-roll again for a lower chance
	push bc
	push de
	callab CustomRandomInBattleBank
	pop de
	pop bc
	ld a, [wCustomRandomValue]
	and $3
.gotNumHits
	inc a
	inc a
	ld [wAbilityTemp], a
	push bc
	push de
	call AbilityActor
	cp AB_TRIPLE_THREAT
	pop de
	pop bc
	ld a, [wAbilityTemp]
	jr nz, .saveNumberOfHits
	cp 3
	jr nc, .saveNumberOfHits
	ld a, 3
.saveNumberOfHits
	ld [de], a
	ld [bc], a
	ret
.twineedle
	ld a, POISON_SIDE_EFFECT1
	ld [hl], a ; set Twineedle's effect to poison effect
	jr .saveNumberOfHits


; No Guard bypasses accuracy/evasion and the Fly/Dig invulnerability check.
; Type immunities and ability immunities are handled separately.
AbilityNoGuardCheck:
 xor a
 ld [wAbilityCheckResult], a
 call AbilityActor
 cp AB_NO_GUARD
 jr z, .yes
 call AbilityTarget
 cp AB_NO_GUARD
 ret nz
.yes
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

; Guts grants one Attack stage only while a major condition is present.
AbilityGuts:
 ld a, [wAbilitySide]
 call AbilityGet
 cp AB_GUTS
 ret nz
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 inc hl
 inc hl
 ld a, [hl]
 and a
 jr z, .healthy
 call AbilityFlagsPointer
 bit 0, [hl]
 ret nz
 xor a
 call AbilityRaiseStage
 ld a, [wCustomChanged]
 and a
 ret z
 call AbilityFlagsPointer
 set 0, [hl]
 ret
.healthy
 call AbilityFlagsPointer
 bit 0, [hl]
 ret z
 res 0, [hl]
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 xor a
 ld [wCustomStat], a
 ld [wCustomChanged], a
 dec a
 ld [wCustomDelta], a
 jpab CustomChangeStage

; Carry when the current physical move faces greater Defense than Attack.
AbilityIronGripCheck:
 call AbilityActorMoveType
 cp FIRE
 ret nc
 ld hl, wBattleMonAttack
 ld de, wEnemyMonDefense
 ld a, [H_WHOSETURN]
 and a
 jr z, .compare
 ld hl, wEnemyMonAttack
 ld de, wBattleMonDefense
.compare
 ld a, [de]
 ld b, a
 ld a, [hli]
 cp b
 ret nz
 inc de
 ld a, [de]
 ld b, a
 ld a, [hl]
 cp b
 ret

AbilityGrappler:
 call AbilityActor
 cp AB_GRAPPLER
 ret nz
 ld a, [wAbilityMoveType]
 cp FIRE
 ret nc
 call AbilityTarget
 cp AB_SHIELD_DUST
 ret z
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 ld [wCustomSide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab CustomTargetProtected
 ret nz
 ld b, 10
 call AbilityRoll
 ret nc
 ld a, 1 ; Defense
 ld [wCustomStat], a
 xor a
 ld [wCustomChanged], a
 dec a
 ld [wCustomDelta], a
 jpab CustomChangeStage

AbilityFourArmsCheck:
 xor a
 ld [wAbilityCheckResult], a
 call AbilityActor
 cp AB_FOUR_ARMS
 jr z, .guaranteed
 cp AB_TRIPLE_THREAT
 jr z, .guaranteed
 cp AB_SKILL_LINK
 ret nz
.guaranteed
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

; Haze clears both status and stages together, so no old Guts stage remains.
AbilityGutsHazeReset:
 ld a, [wAbilitySide]
 push af
 xor a
 ld [wAbilitySide], a
 call .one
 ld a, 1
 ld [wAbilitySide], a
 call .one
 pop af
 ld [wAbilitySide], a
 ret
.one
 ld a, [wAbilitySide]
 call AbilityGet
 cp AB_GUTS
 ret nz
 call AbilityFlagsPointer
 res 0, [hl]
 ret

; Poison damage increases if the target's Defense exceeds its Special.
AbilityDigestiveAcidCheck:
 call AbilityActorMoveType
 cp POISON
 jr z, .poison
 and a
 ret
.poison
 ld hl, wEnemyMonSpecial
 ld de, wEnemyMonDefense
 ld a, [H_WHOSETURN]
 and a
 jr z, .compare
 ld hl, wBattleMonSpecial
 ld de, wBattleMonDefense
.compare
 ld a, [de]
 ld b, a
 ld a, [hli]
 cp b
 ret nz
 inc de
 ld a, [de]
 ld b, a
 ld a, [hl]
 cp b
 ret

AbilityAcidic:
 call AbilityActor
 cp AB_ACIDIC
 ret nz
 ld a, [wAbilityMoveType]
 cp POISON
 ret nz
 call AbilityTarget
 cp AB_SHIELD_DUST
 ret z
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 ld [wCustomSide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab CustomTargetProtected
 ret nz
 ld b, 25
 call AbilityRoll
 ret nc
 ld a, 1 ; Defense
 ld [wCustomStat], a
 xor a
 ld [wCustomChanged], a
 dec a
 ld [wCustomDelta], a
 jpab CustomChangeStage

AbilityStickyTrap:
 ld a, [wAbilityMoveType]
 cp FIRE
 ret nc
 call AbilityTarget
 cp AB_STICKY_TRAP
 jr z, .sticky
 cp AB_STICKY_BODY
 ret nz
.sticky
 call AbilityActor
 cp AB_CLEAR_BODY
 ret z
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 ld [wCustomSide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 callab CustomTargetProtected
 ret nz
 ld b, 20
 call AbilityRoll
 ret nc
 ld a, 2 ; Speed
 ld [wCustomStat], a
 xor a
 ld [wCustomChanged], a
 dec a
 ld [wCustomDelta], a
 jpab CustomChangeStage

; A drain on a Liquid Ooze holder damages the drainer instead of healing.
AbilityLiquidOozeMoveCheck:
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wCustomTargetHadSub]
 and a
 ret nz
 call AbilityTarget
 cp AB_LIQUID_OOZE
 ret nz
 ld a, 1
 ld [wAbilityCheckResult], a
 ret
AbilityLiquidOozeMoveDamage:
 ld a, [wAbilitySide]
 push af
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 ld a, [wDamage]
 ld [wAbilityTemp], a
 ld a, [wDamage + 1]
 ld [wAbilityTemp + 1], a
 call AbilityLiquidOozeHurt
 pop af
 ld [wAbilitySide], a
 ret
AbilityLiquidOozeSeedDamage:
 ld a, [wAbilitySide]
 push af
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 ld a, [wNatureInputBC]
 ld [wAbilityTemp], a
 ld a, [wNatureInputBC + 1]
 ld [wAbilityTemp + 1], a
 call AbilityLiquidOozeHurt
 pop af
 ld [wAbilitySide], a
 ret
AbilityLiquidOozeHurt:
 ld a, [wAbilitySide]
 call AbilityGet
 cp AB_MAGIC_GUARD
 ret z
 call AbilityHP
 ld a, [hli]
 ld b, a
 ld a, [hl]
 ld c, a
 or b
 ret z
 ld a, [wAbilityTemp + 1]
 ld d, a
 ld a, c
 sub d
 ld c, a
 ld a, [wAbilityTemp]
 ld d, a
 ld a, b
 sbc d
 jr nc, .store
 xor a
 ld c, a
.store
 ld [hl], c
 dec hl
 ld [hl], a
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 callab UtilitySyncParty
 jpab DrawHUDsAndHPBars

AbilityLevitateCheck:
 xor a
 ld [wAbilityCheckResult], a
 call AbilityActorMoveType
 cp GROUND
 ret nz
 call AbilityTarget
 cp AB_LEVITATE
 ret nz
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilityLevitateAICheck:
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wUnusedC000]
 bit 3, a
 ld a, [wEnemyMoveType]
 jr z, .type
 ld a, [wPlayerMoveType]
.type
 cp GROUND
 ret nz
 ld a, [wUnusedC000]
 bit 3, a
 ld a, 0
 jr z, .side
 inc a
.side
 call AbilityGet
 cp AB_LEVITATE
 ret nz
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

; A direct lethal hit at full HP leaves the defender at 1 HP.
AbilitySturdyIncoming:
 call AbilityHP
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

AbilityDiggerCheck:
 ld hl, wEnemyMonType1
 ld a, [H_WHOSETURN]
 and a
 jr z, .types
 ld hl, wBattleMonType1
.types
 ld a, [hli]
 cp GROUND
 jr z, .yes
 ld a, [hl]
 cp GROUND
 jr z, .yes
 and a
 ret
.yes
 scf
 ret

AbilityHeavyweightCheck:
 call AbilityActorMoveType
 cp ROCK
 jr z, .rock
 and a
 ret
.rock
 ld hl, wBattleMonDefense
 ld de, wEnemyMonDefense
 ld a, [H_WHOSETURN]
 and a
 jr z, .compare
 ld hl, wEnemyMonDefense
 ld de, wBattleMonDefense
.compare
 ld a, [de]
 cp [hl]
 ret nz
 inc de
 inc hl
 ld a, [de]
 cp [hl]
 ret

AbilityRolloutSidePointer:
 ld hl, wRolloutStacks
 ld a, [wAbilitySide]
 and a
 ret z
 inc hl
 ret
AbilityRolloutResetSide:
 call AbilityRolloutSidePointer
 ld [hl], 0
 ret

; Add 10% of the attack's unboosted damage for each prior successful move.
; The multiplier is calculated with a 32-bit product and saturates at 65535.
AbilityRolloutScale:
 call AbilityActorMoveType
 cp GROUND
 jr z, .eligible
 cp ROCK
 ret nz
.eligible
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityRolloutSidePointer
 ld a, [hl]
 and a
 ret z
 ld [H_MULTIPLIER], a
 xor a
 ld [H_MULTIPLICAND], a
 ld a, [wDamage]
 ld [H_MULTIPLICAND + 1], a
 ld a, [wDamage + 1]
 ld [H_MULTIPLICAND + 2], a
 call Multiply
 ld a, 10
 ld [H_DIVISOR], a
 ld b, 4
 call Divide
 ld a, [H_QUOTIENT]
 ld b, a
 ld a, [H_QUOTIENT + 1]
 or b
 jr nz, .cap
 ld a, [H_QUOTIENT + 3]
 ld b, a
 ld a, [wDamage + 1]
 add b
 ld [wDamage + 1], a
 ld a, [H_QUOTIENT + 2]
 ld b, a
 ld a, [wDamage]
 adc b
 jr c, .cap
 ld [wDamage], a
 ret
.cap
 ld a, $ff
 ld [wDamage], a
 ld [wDamage + 1], a
 ret

; One stack per completed Ground/Rock attack. Misses and other moves reset it.
AbilityRolloutAfterAction:
 call AbilityActor
 cp AB_CHAIN_REACTION
 jp z, AbilityChainAfterAction
 cp AB_BIRD_RELENTLESS
 jp z, AbilityBirdRelentlessAfterAction
 cp AB_ROLLOUT
 ret nz
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityRolloutSidePointer
 push hl
 call AbilityMove
 inc hl
 inc hl
 ld a, [hli]
 and a
 jr z, .reset
 ld a, [hl]
 cp GROUND
 jr z, .checkHit
 cp ROCK
 jr nz, .reset
.checkHit
 ld a, [wMoveMissed]
 and a
 jr nz, .reset
 ld a, [wDamageMultipliers]
 and $7f
 jr z, .reset
 pop hl
 ld a, [hl]
 cp $ff
 ret z
 inc [hl]
 ret
.reset
 pop hl
 ld [hl], 0
 ret

; Clear pre-existing poison when an Immunity holder enters battle.
AbilityImmunityOnEntry:
 ld a, [wAbilitySide]
 call AbilityGet
 cp AB_IMMUNITY
 ret nz
 call AbilityHP
 inc hl
 inc hl
 inc hl
 bit PSN, [hl]
 ret z
 res PSN, [hl]
 ld hl, wPlayerBattleStatus3
 ld de, wPlayerToxicCounter
 ld a, [wAbilitySide]
 and a
 jr z, .clear
 ld hl, wEnemyBattleStatus3
 ld de, wEnemyToxicCounter
.clear
 res BADLY_POISONED, [hl]
 xor a
 ld [de], a
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 callab CustomRecalculate
 jpab UtilitySyncParty

; The capsule operates on party records outside battle.
AbilityImmunityCapsule:
 ld a, [wNatureMonPtr]
 ld h, a
 ld a, [wNatureMonPtr + 1]
 ld l, a
 ld a, [hl]
 cp GEODUDE
 jr z, .family
 cp GRAVELER
 jr z, .family
 cp GOLEM
 ret nz
.family
 push hl
 ld bc, wPartyMon1Type1 - wPartyMon1
 add hl, bc
 ld a, [hl]
 and $e0
 cp 2 << 5
 pop hl
 ret nz
 ld bc, wPartyMon1Status - wPartyMon1
 add hl, bc
 res PSN, [hl]
 ret

; Carry iff a Fire move's user is strictly faster using current battle speeds.
AbilityBlazingTrailCheck:
 call AbilityActorMoveType
 cp FIRE
 jr z, .fire
 and a
 ret
.fire
AbilityCompareFaster:
 call AbilityPrepareSpeeds
 ld hl, wAbilityPlayerSpeed
 ld de, wAbilityEnemySpeed
 ld a, [H_WHOSETURN]
 and a
 jr z, .compare
 ld hl, wAbilityEnemySpeed
 ld de, wAbilityPlayerSpeed
.compare
 ld a, [de]
 cp [hl]
 ret nz
 inc de
 inc hl
 ld a, [de]
 cp [hl]
 ret

; Physical hits can burn their attacker, including hits that knock the holder out.
AbilityFlameBody:
 call AbilityTarget
 cp AB_FLAME_BODY
 ret nz
 ld a, [wAbilityMoveType]
 cp FIRE
 ret nc
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld b, 20
 call AbilityRoll
 ret nc
 ld a, [H_WHOSETURN]
 push af
 ld [wCustomSide], a
 xor 1
 ld [H_WHOSETURN], a
 ld a, 1 << BRN
 ld [wCustomDelta], a
 callab UtilityInflictStatus
 pop af
 ld [H_WHOSETURN], a
 ret

; Legacy stat-up effects raise the active side. Preserve their scratch state.
AbilityCompetitiveLegacy:
 ld a, [wCustomSide]
 push af
 ld a, [H_WHOSETURN]
 ld [wCustomSide], a
 call AbilityCompetitiveFromSide
 pop af
 ld [wCustomSide], a
 ret

; wCustomSide is the side whose stage actually rose. Save shared scratch
; because a Competitive response itself uses the generic stat-change path.
AbilityCompetitiveFromSide:
 ld a, [wCustomSide]
 xor 1
 call AbilityGet
 cp AB_COMPETITIVE
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
 ld a, [wCustomSide]
 xor 1
 ld [wAbilitySide], a
 and a
 jr nz, .checkHP
 ld a, [wBattleMonSpecies]
 and a
 jr z, .restore
.checkHP
 call AbilityHP
 ld a, [hli]
 or [hl]
 jr z, .restore
 call AbilityFlagsPointer
 bit 0, [hl]
 jr nz, .restore
 set 0, [hl]
 xor a ; Attack
 call AbilityRaiseStage
.restore
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

; Track completed actions independently for both sides during the round.
AbilityPatientMarkAction:
 ld a, [H_WHOSETURN]
 and a
 jr nz, AbilityPatientMarkEnemy
 ld hl, wPatientActed
 set 0, [hl]
 ret
AbilityPatientMarkEnemy:
 ld hl, wPatientActed
 set 1, [hl]
 ret
AbilityPatientDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz ; fixed damage is handled separately
 call AbilityPatientCheck
 ret nc
 ld c, 120
 jp AbilityScaleDamage
AbilityPatientCheck:
 call AbilityActor
 cp AB_PATIENT
 jr nz, .no
 ld a, [H_WHOSETURN]
 and a
 jr nz, .enemy
 ld a, [wPatientActed]
 bit 1, a
 jr nz, .yes
 ld a, [wUnusedC000]
 bit 1, a ; enemy item or switch has already taken its action
 jr nz, .yes
 jr .no
.enemy
 ld a, [wPatientActed]
 bit 0, a
 jr nz, .yes
 ld a, [wActionResultOrTookBattleTurn]
 and a
 jr z, .no
.yes
 scf
 ret
.no
 and a
 ret

AbilitySimpleCustomDelta:
 ld a, [wCustomSide]
 call AbilityGet
 cp AB_SIMPLE
 ret nz
 ld a, [wCustomDelta]
 bit 7, a
 jr nz, .negative
 cp 7
 jr c, .double
 ld a, 12
 jr .store
.negative
 cp -6 & $ff
 jr nc, .double
 ld a, -12 & $ff
 jr .store
.double
 add a
.store
 ld [wCustomDelta], a
 ret

; wAbilityTemp is the already-clamped new stage.
AbilitySimpleLegacyUp:
 call AbilityMagneticLegacy
 ld a, [wAbilityCheckResult]
 and a
 ret nz
 ld a, [H_WHOSETURN]
 jr AbilitySimpleLegacy
AbilitySimpleLegacyDown:
 ld a, [H_WHOSETURN]
 xor 1
AbilitySimpleLegacy:
 push af
 call AbilityGet
 cp AB_SIMPLE
 jr nz, .done
 pop af
 ld hl, wPlayerMonStatMods
 and a
 jr z, .index
 ld hl, wEnemyMonStatMods
.index
 ld a, [wUnusedD71B]
 dec a
 ld e, a
 ld d, 0
 add hl, de
 ld a, [wAbilityTemp]
 sub [hl]
 add a
 add [hl]
 bit 7, a
 jr nz, .min
 and a
 jr nz, .max
.min
 ld a, 1
.max
 cp 14
 jr c, .save
 ld a, 13
.save
 ld [wAbilityTemp], a
 ret
.done
 pop af
 ret

AbilityUnawareCheck:
 xor a
 ld [wAbilityCheckResult], a
 call AbilityTarget
 cp AB_UNAWARE
 ret nz
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

; Carry when the opposite living battler has Magnetic Field.
AbilityMagneticAgainstSide:
 xor 1
 ld b, a
 call AbilityGet
 cp AB_MAGNETIC_FIELD
 jr nz, .no
 ld a, b
 ld hl, wBattleMonHP
 and a
 jr z, .hp
 ld hl, wEnemyMonHP
.hp
 ld a, [hli]
 or [hl]
 jr z, .no
 scf
 ret
.no
 and a
 ret

AbilityMagneticCustom:
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wCustomDelta]
 and a
 ret z
 bit 7, a
 ret nz
 ld a, [wCustomStat]
 cp 2
 jr z, .check
 cp 5
 ret nz
.check
 ld a, [wCustomSide]
 call AbilityMagneticAgainstSide
 ret nc
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

; Legacy stat-up hooks put the stat index in wUnusedD71B (one-based).
AbilityMagneticLegacy:
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wUnusedD71B]
 cp 3
 jr z, .check
 cp 6
 ret nz
.check
 ld a, [H_WHOSETURN]
 call AbilityMagneticAgainstSide
 ret nc
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilityMagneticPsych:
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wCustomSide]
 call AbilityMagneticAgainstSide
 ret nc
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilityMagnetDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
 call AbilityActor
 cp AB_BATTERY
 jr z, .battery
 cp AB_CHAIN_REACTION
 ret nz
 call AbilityActorMoveType
 cp ELECTRIC
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityRolloutSidePointer
 ld a, [hl]
 and a
 ret z
 jr .boost
.battery
 call AbilityActorMoveType
 cp ELECTRIC
 ret nz
 call AbilityBatteryCheck
 ret nc
.boost
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 ld c, 120
 jp AbilityScaleDamage

; Compare pre-deduction PP to the selected move's maximum, including PP Ups.
AbilityBatteryCheck:
 ld a, [H_WHOSETURN]
 and a
 ld hl, wPlayerBattleStatus3
 jr z, .transform
 ld hl, wEnemyBattleStatus3
.transform
 bit TRANSFORMED, [hl]
 jr z, .normal
 ld b, 5
 jr .compare
.normal
 ld hl, wBattleMonMoves
 ld a, [H_WHOSETURN]
 and a
 ld a, [wPlayerMoveListIndex]
 jr z, .slot
 ld hl, wEnemyMonMoves
 ld a, [wEnemyMoveListIndex]
.slot
 and 3
 ld e, a
 ld d, 0
 add hl, de
 ld a, [hl]
 and a
 ret z
 dec a
 ld hl, Moves + 5
 ld bc, MoveEnd - Moves
 call AddNTimes
 ld de, wAbilityTemp
 ld bc, 1
 ld a, BANK(Moves)
 call FarCopyData
 ld a, [wAbilityTemp]
 ld b, a
 ; floor(base PP / 5), capped at 7, matches AddBonusPP.
 ld c, 0
.divide
 cp 5
 jr c, .divided
 sub 5
 inc c
 ld a, c
 cp 7
 jr z, .divided
 ld a, [wAbilityTemp]
 ld d, a
 ld a, c
 add a
 add a
 add c
 ld e, a
 ld a, d
 sub e
 jr .divide
.divided
 ld hl, wBattleMonPP
 ld a, [H_WHOSETURN]
 and a
 ld a, [wPlayerMoveListIndex]
 jr z, .ppslot
 ld hl, wEnemyMonPP
 ld a, [wEnemyMoveListIndex]
.ppslot
 and 3
 ld e, a
 ld d, 0
 add hl, de
 ld a, [hl]
 and $c0
 rlca
 rlca
 ld d, a
.add
 ld a, d
 and a
 jr z, .cap
 ld a, b
 add c
 ld b, a
 dec d
 jr .add
.cap
 ld a, b
 cp 64
 jr c, .compare
 ld b, 63
.compare
 ld a, [wAbilityPPLeft]
 add a
 cp b
 ret z
 ccf
 ret

; Once an Electric attack is used, its next Electric attack is boosted.
; The side-local Rollout byte is shared: these abilities are mutually exclusive.
AbilityChainAfterAction:
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 call AbilityMove
 inc hl
 inc hl
 ld a, [hli]
 and a
 ret z
 ld a, [hl]
 cp ELECTRIC
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityRolloutSidePointer
 ld [hl], 1
 ret

; Transform directly copies stages; retain the previous Speed/Evasion when
; the copy would increase them under an opposing Magnetic Field.
AbilityMagneticSnapshot:
 ld hl, wPlayerMonSpeedMod
 ld de, wPlayerMonEvasionMod
 ld a, [H_WHOSETURN]
 and a
 jr z, .save
 ld hl, wEnemyMonSpeedMod
 ld de, wEnemyMonEvasionMod
.save
 ld a, [hl]
 ld [wAbilityTemp], a
 ld a, [de]
 ld [wAbilityTemp + 1], a
 ret
AbilityMagneticRestoreCopiedStages:
 ld a, [H_WHOSETURN]
 call AbilityMagneticAgainstSide
 ret nc
 ld hl, wPlayerMonSpeedMod
 ld de, wPlayerMonEvasionMod
 ld a, [H_WHOSETURN]
 and a
 jr z, .restore
 ld hl, wEnemyMonSpeedMod
 ld de, wEnemyMonEvasionMod
.restore
 ld a, [wAbilityTemp]
 cp [hl]
 jr nc, .evasion
 ld [hl], a
.evasion
 ld a, [de]
 ld b, a
 ld a, [wAbilityTemp + 1]
 cp b
 ret nc
 ld [de], a
 ret

INCLUDE "data/farfetch_ability_moves.asm"

AbilityPrecisionCheck:
 call AbilityMove
 ld a, [hl]
 ld hl, AbilityPrecisionMoves
 ld de, 1
 jp IsInArray
AbilityCuttingCheck:
 call AbilityMove
 ld a, [hl]
 ld hl, AbilityCuttingMoves
 ld de, 1
 jp IsInArray

; Set the base chance before the ordinary accuracy/evasion multipliers.
AbilityPrecisionAccuracy:
 call AbilityActor
 cp AB_PRECISION
 ret nz
 call AbilityPrecisionCheck
 ret nc
 ld hl, wPlayerMoveAccuracy
 ld a, [H_WHOSETURN]
 and a
 jr z, .set
 ld hl, wEnemyMoveAccuracy
.set
 ld [hl], $ff
 ret

AbilityFarfetchDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityFarfetchFixedDamage:
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 call AbilityActor
 cp AB_UNDERDOG
 jr z, .underdog
 cp AB_PRECISION
 ret nz
 call AbilityPrecisionCheck
 jr nc, .done
 jr .boost
.underdog
 call AbilityUnderdogCheck
 jr nc, .done
.boost
 ld c, 120
 jp AbilityScaleDamage
.done
 ret

; Sum the five Gen 1 base stats for each current species, including variants.
AbilityUnderdogCheck:
 ld a, [H_WHOSETURN]
 and a
 ld a, [wBattleMonSpecies]
 jr z, .actor
 ld a, [wEnemyMonSpecies]
.actor
 call AbilityBaseStatSum
 push bc
 ld a, [H_WHOSETURN]
 and a
 ld a, [wEnemyMonSpecies]
 jr z, .target
 ld a, [wBattleMonSpecies]
.target
 call AbilityBaseStatSum
 pop de
 ld a, d
 cp b
 ret nz
 ld a, e
 cp c
 ret

; Input internal species ID; output BC = HP + Attack + Defense + Speed + Special.
AbilityBaseStatSum:
 and a
 jr z, .zero
 dec a
 ld hl, PokedexOrder
 ld e, a
 ld d, 0
 add hl, de
 ld de, wAbilityTemp
 ld bc, 1
 ld a, BANK(PokedexOrder)
 call FarCopyData
 ld a, [wAbilityTemp]
 and a
 jr z, .zero
 dec a
 ld hl, BaseStats + 1
 ld bc, MonBaseStatsEnd - MonBaseStats
 call AddNTimes
 ld de, wUnawareSaved
 ld bc, 5
 ld a, BANK(BaseStats)
 call FarCopyData
 ld hl, wUnawareSaved
 ld b, 0
 ld c, 0
 ld d, 5
.sum
 ld a, [hli]
 add c
 ld c, a
 jr nc, .next
 inc b
.next
 dec d
 jr nz, .sum
 ret
.zero
 ld bc, 0
 ret

AbilityTastyLeek:
 call AbilityActor
 cp AB_TASTY_LEEK
 ret nz
 ld a, [wCriticalHitOrOHKO]
 cp 1
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld a, 10
 jp AbilityHealDivided

; Doduo's Relentless tracks successful attacks rather than individual hits.
; The active-side Rollout byte is free because a battler has only one ability.
AbilityDoduoOffense:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityDoduoFixedOffense:
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 call AbilityActor
 cp AB_STAMPEDE
 jr z, .stampede
 cp AB_BIRD_RELENTLESS
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityRolloutSidePointer
 ld a, [hl]
 and a
 ret z
 ld b, a
 add a
 add a
 add b
 add a
 add 100
 ld c, a
 jp AbilityScaleDamage
.stampede
 call AbilityActorMoveType
 cp NORMAL
 ret nz
 call AbilityCompareFaster
 ret nc
 ld c, 120
 jp AbilityScaleDamage

AbilityBirdRelentlessAfterAction:
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityRolloutSidePointer
 push hl
 call AbilityMove
 inc hl
 inc hl
 ld a, [hl]
 and a
 jr z, .reset
 ld a, [wMoveMissed]
 and a
 jr nz, .reset
 ld a, [wDamageMultipliers]
 and $7f
 jr z, .reset
 pop hl
 ld a, [hl]
 cp 3
 ret nc
 inc [hl]
 ret
.reset
 pop hl
 ld [hl], 0
 ret

; Convert damaging Normal moves to Ice or Water before damage and type checks.
AbilityRefrigerateConvert:
 call AbilityActor
 cp AB_REFRIGERATE
 jr z, .ice
 cp AB_LIQUIDATE
 ret nz
 ld b, WATER
 jr .move
.ice
 ld b, ICE
.move
 call AbilityMove
 inc hl
 inc hl
 ld a, [hli]
 and a
 ret z
 ld a, [hl]
 cp NORMAL
 ret nz
 ld [hl], b
 ret

AbilityRefrigerateDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityRefrigerateFixedDamage:
 call AbilityActor
 cp AB_REFRIGERATE
 jr z, .ice
 cp AB_LIQUIDATE
 ret nz
 call AbilityActorMoveType
 cp WATER
 ret nz
 jr .converted
.ice
 call AbilityActorMoveType
 cp ICE
 ret nz
.converted
 ld a, [wCriticalHitOrOHKO]
 cp 2
 ret z
 call AbilityMove
 ld a, [hl]
 and a
 ret z
 dec a
 ld hl, Moves + 3 ; the original type in the ROM move record
 ld bc, MoveEnd - Moves
 call AddNTimes
 ld de, wAbilityTemp
 ld bc, 1
 ld a, BANK(Moves)
 call FarCopyData
 ld a, [wAbilityTemp]
 cp NORMAL
 ret nz
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 ld c, 120
 jp AbilityScaleDamage

; Grimer-family Toxic Waste checks either living battler for poison.
AbilityGrimerToxicWaste:
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 inc hl
 inc hl
 bit PSN, [hl]
 jr nz, .heal
 ld a, [wAbilitySide]
 xor 1
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 jr z, .restoreNoHeal
 inc hl
 inc hl
 bit PSN, [hl]
 jr z, .restoreNoHeal
 ld a, [wAbilitySide]
 xor 1
 ld [wAbilitySide], a
.heal
 call AbilityHP
 ld a, 4
 jp AbilityHealFractionFromHL
.restoreNoHeal
 ld a, [wAbilitySide]
 xor 1
 ld [wAbilitySide], a
 ret
