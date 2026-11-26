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
	callab AbilityPorygonEntry
	call AbilityEntryOwnEffects
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


AbilityEntryOwnEffects:
	call AbilityHealerOnEntry
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
	ret nz
	call AbilityFlagsPointer
	res 0, [hl]
	jp AbilityGuts

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
	callab AbilityTerrifying
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
 cp AB_HYPER_CUTTER
 jr z, .attackGuard
 cp ABILITY_EXTENDED
 jr nz, .otherAbility
 ld a, [wAbilityResolvedExtended]
 cp AB_UNSTOPPABLE - ABILITY_EXTENDED
 jr z, .attackGuard
 call AbilityGetCustomSide
 jr .otherAbility
.attackGuard
 ld a, [wCustomStat]
 and a
 jr z, .block
 ret
.otherAbility
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

AbilityGetCustomSide:
 ld a, [wCustomSide]
 jp AbilityGet

AbilityKeenEyeTarget::
 call AbilityMirrorArmorLegacy
 ld a, [wAbilityCheckResult]
 and a
 ret nz
 xor a
 ld [wAbilityCheckResult], a
 call AbilityTarget
 cp AB_HYPER_CUTTER
 jr z, .attackGuard
 cp ABILITY_EXTENDED
 jr nz, .otherAbility
 ld a, [wAbilityResolvedExtended]
 cp AB_UNSTOPPABLE - ABILITY_EXTENDED
 jr z, .attackGuard
 call AbilityTarget
 jr .otherAbility
.attackGuard
 ld a, [wCustomStat]
 and a
 jr z, .block
 ret
.otherAbility
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
	cp AB_BONE_BREAKER
	jr z, .physicalHorn
	cp AB_PIERCING_HORN
	ret nz
.physicalHorn
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
 ld a, [wAbilityCheckResult] ; current chart multiplier
 push af
 call AbilityEqualizerSnapshot
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wMoveType]
 ld [wAbilityTemp + 1], a
 call AbilityActor
 pop bc ; B holds the chart multiplier
 jr AbilityTypeOverride

AbilityCorrosiveAICheck:
 ld a, [wAbilityCheckResult]
 push af
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
 pop bc
AbilityTypeOverride:
 ld [wAbilityCheckResult], a
 ld a, [wCustomRandomValue]
 push af
 ld a, b
 ld [wCustomRandomValue], a
 callab AbilityTypeOverrideBanked
 pop af
 ld [wCustomRandomValue], a
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
	callab AbilityAntivirusSecondaryRoll
	ld a, [wAbilityCheckResult]
	and a
	jr z, .ordinaryFreezeCheck
	ld a, $ff
	ld [wCustomRandomValue], a
	ret
.ordinaryFreezeCheck
	call AbilityMove
	inc hl
	ld a, [hl]
	cp FREEZE_SIDE_EFFECT
	jr nz, .ordinary
	call AbilityTarget
	cp ABILITY_EXTENDED
	jr nz, .ordinary
	ld a, [wAbilityResolvedExtended]
	cp AB_MAGMA_ARMOR - ABILITY_EXTENDED
	jr nz, .ordinary
	ld a, $ff
	ld [wCustomRandomValue], a
	ret
.ordinary
	call AbilityActor
	cp AB_MEASURED
	jr z, .double
	cp AB_SERENE_GRACE
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
	callab AbilitySleepwalkerDamage
	callab AbilityFluffyDamage
	callab AbilityEeveeDamage
	callab AbilityGyaradosDamage
	call AbilityDesperationDamage
	callab AbilityBurningRageBanked
	callab AbilityHighHPTypeDamage
	callab AbilitySharpBladesBanked
	call AbilityEqualizerDamage
	call AbilityFocusedDamage
	call AbilityHeavyHitterDamage
	call AbilityTangelaDamage
	call AbilityLuckyDamage
	call AbilityRhyhornDamage
	call AbilityLickitungDamage
	call AbilityHitmonchanDamage
	call AbilityHitmonleeDamage
	call AbilityEggDamage
	call AbilityVoltorbDamage
	call AbilityKrabbyDamage
	call AbilityNocturnalDamage
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
	cp AB_CRUSHING_WEIGHT
	jr z, .heavyweightBoost
	cp AB_HEAVYWEIGHT
	jr nz, .rollout
.heavyweightBoost
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
	cp ABILITY_EXTENDED
	jr nz, .defenderOrdinary
	ld a, [wAbilityResolvedExtended]
	cp AB_LIQUID_BODY - ABILITY_EXTENDED
	jp z, .physicalReduction
	cp AB_MAGMA_COAT - ABILITY_EXTENDED
	jp z, .superEffective
	cp AB_FLEXIBLE - ABILITY_EXTENDED
	jp z, .superEffective
	cp AB_ANCIENT_SHELL - ABILITY_EXTENDED
	jp z, .superEffective
	cp AB_MAGMA_ARMOR - ABILITY_EXTENDED
	jr nz, .restoreDefender
	ld a, [wAbilityMoveType]
	cp ICE
	ret nz
	ld c, 50
	jp .reduce
.restoreDefender
	call AbilityTarget
.defenderOrdinary
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
	cp AB_SOLID_ROCK
	jr z, .superEffective
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
	cp ABILITY_EXTENDED
	jr nz, .legacySpecialDefense
	ld a, [wAbilityResolvedExtended]
	cp AB_COSMIC_CORE - ABILITY_EXTENDED
	jr z, .mentalShield
	call AbilityTarget
	jp .checkThickFat
.legacySpecialDefense
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
	cp AB_ARMORED
	jr z, .physicalReduction
	cp AB_GUARD_UP
	jr z, .physicalReduction
	cp AB_THICK_SKULL
	jr z, .physicalReduction
	cp AB_THICK_TRUNK
	jr z, .physicalReduction
	cp AB_JELLY_BODY
	jr nz, .physicalHide
.physicalReduction
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
	call AbilityParentalOverride
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
	callab AbilitySleepwalkerFixedDamage
	callab AbilityFluffyFixedDamage
	callab AbilityEeveeFixedDamage
	callab AbilityGyaradosFixedDamage
	call AbilityDesperationFixedDamage
	callab AbilityBurningRageFixedBanked
	call AbilityFocusedFixedDamage
	call AbilityHeavyHitterFixedDamage
	call AbilityTangelaFixedDamage
	call AbilityRhyhornFixedDamage
	call AbilityLickitungFixedDamage
	call AbilityEggFixedDamage
	call AbilityNocturnalFixedDamage
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
	cp AB_CRUSHING_WEIGHT
	jr z, .fixedHeavyweightBoost
	cp AB_HEAVYWEIGHT
	jr nz, .fixedRollout
.fixedHeavyweightBoost
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
	cp AB_SOLID_ROCK
	jr z, .fixedSuperEffective
	cp ABILITY_EXTENDED
	jr nz, .notSolidRock
	ld a, [wAbilityResolvedExtended]
	cp AB_LIQUID_BODY - ABILITY_EXTENDED
	jp z, .fixedPhysicalReduction
	cp AB_MAGMA_COAT - ABILITY_EXTENDED
	jr z, .fixedSuperEffective
	cp AB_FLEXIBLE - ABILITY_EXTENDED
	jr z, .fixedSuperEffective
	cp AB_ANCIENT_SHELL - ABILITY_EXTENDED
	jr z, .fixedSuperEffective
	call AbilityTarget
	jr .notSolidRock
.fixedSuperEffective
	ld a, [wDamageMultipliers]
	and $7f
	cp 11
	ret c
	ld c, 75
	jp .scale
.notSolidRock
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
	cp ABILITY_EXTENDED
	jr nz, .fixedLegacySpecial
	ld a, [wAbilityResolvedExtended]
	cp AB_MAGMA_ARMOR - ABILITY_EXTENDED
	jr nz, .fixedCosmic
	call AbilityActorMoveType
	cp ICE
	ret nz
	ld c, 50
	jp .scale
.fixedCosmic
	cp AB_COSMIC_CORE - ABILITY_EXTENDED
	jr z, .fixedMentalShield
	call AbilityTarget
	jp .fixedThickFat
.fixedLegacySpecial
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
	cp AB_ARMORED
	jr z, .fixedPhysicalReduction
	cp AB_GUARD_UP
	jr z, .fixedPhysicalReduction
	cp AB_THICK_SKULL
	jr z, .fixedPhysicalReduction
	cp AB_THICK_TRUNK
	jr z, .fixedPhysicalReduction
	cp AB_JELLY_BODY
	jr nz, .fixedHide
.fixedPhysicalReduction
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
	callab AbilityFocusedAttemptBanked
	callab AbilityWrathAttempt
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
	call AbilityActor
	cp AB_CHARGE
	jr nz, .claimAttempt
	call AbilityActorMoveType
	cp FIRE
	ret nc
.claimAttempt
	ld a, [H_WHOSETURN]
	ld [wAbilitySide], a
	call AbilityFlagsPointer
	bit 3, [hl]
	jr nz, .alreadySpent
	set 3, [hl]
	call AbilityActor
	cp AB_CHARGE
	jr z, .boostAttempt
	cp AB_AMBUSH
	ret nz
.boostAttempt
	ld hl, wAbilityHit
	set 4, [hl] ; applies to all hits of this first damaging move
	ret
.alreadySpent
	ret

; Ground/Normal abilities trigger only when a move was actually executed.
AbilitySandAfterAction:
	callab AbilityQuickLearnerAfterAction
	call AbilitySapSipperStatus
	call AbilityDancerAfterAction
	ld a, [wAbilityHit]
	bit 3, a
	ret z
	call AbilityActor
	cp ABILITY_EXTENDED
	jr nz, .ordinaryAbility
	ld a, [wAbilityResolvedExtended]
	cp AB_GENTLE_GIANT - ABILITY_EXTENDED
	jp z, .gentleGiant
	cp AB_SPLASHING - ABILITY_EXTENDED
	jp z, .splashing
	cp AB_VITAL_HEAT - ABILITY_EXTENDED
	jp z, .vitalHeat
	cp AB_ENERGY_DRAIN - ABILITY_EXTENDED
	jp z, .energyDrain
	cp AB_LIVE_WIRE - ABILITY_EXTENDED
	jp z, .liveWire
	ld a, ABILITY_EXTENDED
.ordinaryAbility
	cp AB_ROLLING_DEFENSE
	jp z, .normal
	cp AB_FOOTWORK
	jr nz, .notFootwork
	call AbilityActorMoveType
	cp FIGHTING
	ret nz
	ld a, 5
	jp .once
.notFootwork
	cp AB_SAND_VEIL
	jp z, .evasion
	cp AB_SNOW_VEIL
	jp z, .snowVeil
	cp AB_GLUTTONY
	jr nz, .notGluttony
	call AbilityMove
	inc hl
	inc hl
	ld a, [hli]
	and a
	ret z
	ld a, [hl]
	cp NORMAL
	ret nz
	jr .healWaterOrGround
.notGluttony
	cp AB_HARVEST
	jr nz, .notHarvest
	call AbilityActorMoveType
	cp GRASS
	ret nz
	jr .healWaterOrGround
.notHarvest
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
	jp .once
.powerSwim
	cp AB_POWER_SWIM
	jr nz, .momentum
	call AbilityActorMoveType
	cp WATER
	ret nz
	xor a ; Attack
	jp .once
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
.gentleGiant
	call AbilityMove
	ld a, [hl]
	cp BIDE
	ret z
	call AbilityDancerStatusCheck
	ret nz
	jp .healWaterOrGround
.splashing
	call AbilityMove
	ld a, [hl]
	cp SPLASH
	ret nz
	ld a, 5 ; Evasion
	jp .once
.vitalHeat
	call AbilityActorMoveType
	cp FIRE
	ret nz
	jp .healWaterOrGround
.energyDrain
	call AbilityActorMoveType
	cp ELECTRIC
	ret nz
	jp .healWaterOrGround
.liveWire
	call AbilityActorMoveType
	cp ELECTRIC
	ret nz
	xor a ; Attack
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
	call AbilityVolatile
	call AbilityDeathSpore
	call AbilityRelentlessHit
	call AbilityOvercharge
	call AbilityTastyLeek
	call AbilityRampage
	callab AbilityAncientPowerOnHit
	ld a, [wCustomTargetHadSub]
	and a
	ret nz
	call AbilityActorMoveType
	ld [wAbilityMoveType], a
	call AbilitySpinyArmor
	call AbilityEffectSpore
	call AbilityAftershock
	call AbilityWaterJet
	call AbilityGrappler
	call AbilityAcidic
	call AbilityToxicScales
	call AbilityParasite
	call AbilityConfounding
	call AbilityGhostReaction
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
	callab AbilityIntenseFlamesOnHit
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
	cp AB_SANDMAN
	jr nz, .contamination
	ld a, [wAbilityMoveType]
	cp GROUND
	ret nz
	ld b, 20
	call AbilityRoll
	ret nc
	jp AbilitySandmanSleep
.contamination
	cp AB_TOXIC_FUMES
	jr nz, .notToxicFumes
	ld a, [wAbilityMoveType]
	cp POISON
	ret nz
	call AbilityTargetStatus
	ld a, [hl]
	and a
	ret nz
	ld b, 20
	call AbilityRoll
	ret nc
	ld a, [H_WHOSETURN]
	xor 1
	ld [wCustomSide], a
	ld a, 1 << PSN
	ld [wCustomDelta], a
	jpab UtilityInflictStatus
.notToxicFumes
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
 cp AB_SHORT_CIRCUIT
 jr z, .electric
 cp AB_SLOBBER
 jr z, .physical
 cp AB_CONFOUNDING
 jr z, .psychic
 cp AB_COLLECTIVE_MIND
 jr z, .psychic
 ld c, AB_ENCHANTRESS - ABILITY_EXTENDED
 call AbilityExtendedActorIs
 jr c, .psychic
 ld c, AB_THUNDERSTRUCK - ABILITY_EXTENDED
 call AbilityExtendedActorIs
 jr c, .electric
 ret
.psychic
 ld a, [wAbilityMoveType]
 cp PSYCHIC
 ret nz
 jr .checkTarget
.electric
 ld a, [wAbilityMoveType]
 cp ELECTRIC
 ret nz
 jr .checkTarget
.physical
 ld a, [wAbilityMoveType]
 cp FIRE
 ret nc
.checkTarget
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
 call AbilityActor
 cp AB_SHORT_CIRCUIT
 jr z, .fifteen
 cp AB_SLOBBER
 ld b, 20
 jr nz, .confusionRoll
.fifteen
 ld b, 15
.confusionRoll
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
	cp ABILITY_EXTENDED
	jr nz, .ordinarySturdy
	ld a, [wAbilityResolvedExtended]
	cp AB_DETERMINATION - ABILITY_EXTENDED
	jp z, AbilitySturdyIncoming
	call AbilityTarget
.ordinarySturdy
	cp AB_STURDY
	jp z, AbilitySturdyIncoming
	cp AB_ONIX_STURDY
	jp z, AbilitySturdyIncoming
	cp AB_RESILIENCE
	jp z, AbilityResilienceIncoming
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
	callab AbilityAntivirusActor
	ld a, [wAbilityCheckResult]
	and a
	ret nz
.sleepRoll
	callab CustomRandomInBattleBank
	ld a, [wCustomRandomValue]
	and 7
	cp 2
	jr c, .sleepRoll
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
	jr z, .physical
	cp ABILITY_EXTENDED
	ret nz
	ld a, [wAbilityResolvedExtended]
	cp AB_SPIKY_FUR - ABILITY_EXTENDED
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
	cp ABILITY_EXTENDED
	jr nz, .standardText
	ld a, [wAbilityResolvedExtended]
	cp AB_SPIKY_FUR - ABILITY_EXTENDED
	jp z, AbilitySpikyFurMessage
	call AbilityTarget
.standardText
	cp AB_SPIKED_SHELL
	ld hl, AbilitySpinyArmorText
	jr nz, .print
	ld hl, AbilitySpikedShellText
.print
	jp PrintText

AbilitySpikyFurMessage:
 jpab AbilitySpikyFurMessageBanked

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
	cp ABILITY_EXTENDED
	jr nz, .normalReaction
	ld a, [wAbilityResolvedExtended]
	cp AB_ANGER_POINT - ABILITY_EXTENDED
	jp z, .angerPoint
	cp AB_SAP_SIPPER - ABILITY_EXTENDED
	jp z, .sapSipper
	cp AB_WRATH - ABILITY_EXTENDED
	jp z, .wrath
	call AbilityTarget
.normalReaction
	cp AB_COUNTERPUNCH
	jr nz, .notCounterpunch
	ld a, [wAbilityMoveType]
	cp FIRE
	jp nc, .contact
	call AbilityFlagsPointer
	bit 2, [hl]
	jp nz, .contact
	set 2, [hl]
	xor a
	call AbilityRaiseStage
	jp .contact
.angerPoint
	ld a, [wCriticalHitOrOHKO]
	cp 1
	jp nz, .contact
	call AbilityFlagsPointer
	bit 2, [hl]
	jp nz, .contact
	set 2, [hl]
	xor a
	call AbilityRaiseStage
	xor a
	call AbilityRaiseStage
	jp .contact
.wrath
	call AbilityFlagsPointer
	set 0, [hl]
	jp .contact
.sapSipper
	ld a, [wAbilityMoveType]
	cp GRASS
	jp nz, .contact
	xor a
	call AbilityRaiseStage
	jp .contact
.notCounterpunch
	cp AB_STAMINA
	jr nz, .slippery
	ld a, 1 ; Defense
	call AbilityRaiseStage
	jp .contact
.slippery
	cp AB_SLIPPERY
	jr z, .slipperyPhysical
	cp ABILITY_EXTENDED
	jr nz, .inflatable
	ld a, [wAbilityResolvedExtended]
	cp AB_INK_CLOUD - ABILITY_EXTENDED
	jr nz, .restoreInflatable
.slipperyPhysical
	ld a, [wAbilityMoveType]
	cp FIRE
	jp nc, .contact
	call AbilityFlagsPointer
	bit 2, [hl]
	jp nz, .contact
	set 2, [hl]
	ld a, 5 ; Evasion
	call AbilityRaiseStage
	jp .contact
.restoreInflatable
	call AbilityTarget
.inflatable
	cp AB_INFLATABLE
	jr nz, .hotTemper
	ld a, [wAbilityMoveType]
	cp FIRE
	jp nc, .contact
	ld a, 1 ; Defense
	call AbilityRaiseStage
	jp .contact
.hotTemper
	cp AB_CHEMICAL_REACTION
	jr nz, .notChemicalReaction
	ld a, [wAbilityMoveType]
	cp FIRE
	jp nz, .contact
	call AbilityFlagsPointer
	bit 2, [hl]
	jp nz, .contact
	set 2, [hl]
	ld a, 3
	call AbilityRaiseStage
	jp .contact
.notChemicalReaction
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
	cp ABILITY_EXTENDED
	jr nz, .ordinaryPoisonPoint
	ld a, [wAbilityResolvedExtended]
	cp AB_TOXIC_SPINES - ABILITY_EXTENDED
	jr z, .physicalPoisonPoint
	call AbilityTarget
.ordinaryPoisonPoint
	cp AB_PHYSICAL_POISON_POINT
	jr nz, .staticCheck
.physicalPoisonPoint
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
	cp ABILITY_EXTENDED
	jr nz, .legacy
	ld a, [wAbilityResolvedExtended]
	cp AB_MATERNAL_RAGE - ABILITY_EXTENDED
	jp z, AbilityMaternalRage
	ret
.legacy
	cp AB_SECOND_WIND
	jp z, AbilitySecondWind
	cp AB_SURVIVAL_INSTINCTS
	jr z, .speed
	cp AB_LONELY
	jr z, .defense
	cp AB_FORTIFY
	jr nz, .cornered
.defense
	ld a, 1
	jr .stat
.cornered
	cp AB_VENGEFUL
	jr z, .attack
	cp AB_CORNERED
	jr nz, .protective
.attack
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
	cp ABILITY_EXTENDED
	jr nz, .ordinary
	ld a, [wAbilityResolvedExtended]
	cp AB_MOXIE - ABILITY_EXTENDED
	jr z, .directKO
	ret
.ordinary
	cp AB_FRENZY
	jr z, .directKO
	cp AB_SCAVENGER
	jr z, .directKO
	cp AB_LOYALTY
	jr z, .directKO
	cp AB_BONE_COLLECTOR
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
	cp AB_BONE_COLLECTOR
	jr nz, .notBoneCollector
	call AbilityHP
	ld a, 3
	jp AbilityHealFractionFromHL
.notBoneCollector
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
	cp AB_THICK_TRUNK
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
	cp ABILITY_EXTENDED
	jr nz, .legacy
	ld a, [wAbilityResolvedExtended]
	cp AB_ROYAL_HORN - ABILITY_EXTENDED
	ret nz
	call AbilityRoyalHornMove
	ret nc
	ld a, [wNatureResult]
	add 64 ; 25 percentage points in the 256-value threshold
	jr nc, .store
	ld a, 255
	jr .store
.legacy
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
	cp AB_LIMBER
	jr nz, .notLimber
	ld a, b
	cp PARALYZE_SIDE_EFFECT1
	jr z, .block
	cp PARALYZE_SIDE_EFFECT2
	jr z, .block
	ret
.notLimber
	cp AB_SHIELD_DUST
	jr z, .checkThaw
	cp ABILITY_EXTENDED
	jr nz, .ordinaryTarget
	ld a, [wAbilityResolvedExtended]
	cp AB_UNSTOPPABLE - ABILITY_EXTENDED
	jr nz, .ordinaryTargetRestore
	ld a, b
	cp FLINCH_SIDE_EFFECT1
	jr z, .block
	cp FLINCH_SIDE_EFFECT2
	jr z, .block
	ret
.ordinaryTargetRestore
	call AbilityTarget
.ordinaryTarget
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
 jpab AbilityBurnGateBanked

AbilityGetCustomSideResult:
 call AbilityGetCustomSide
 ld [wAbilityCheckResult], a
 ret

; Accuracy is scaled after nature and stage factors, before final byte cap.
AbilityAccuracy:
	call AbilityActor
	cp ABILITY_EXTENDED
	jr nz, .legacyAccuracy
	ld a, [wAbilityResolvedExtended]
	cp AB_ILLUMINATE - ABILITY_EXTENDED
	jp z, .flat15
	jp .target
.legacyAccuracy
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
	push bc
	ld a, [wBuffer]
	push af
	ld de, wBuffer
	ld bc, 1
	ld a, BANK(AbilityMoveMetadata)
	call FarCopyData
	ld a, [wBuffer]
	ld e, a
	pop af
	ld [wBuffer], a
	ld a, e
	pop bc
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
	cp AB_TRIAGE
	jr nz, .notTriage
	ld a, [wAbilityTemp + 1]
	call AbilityTriageMove
	jp nc, .plain
	pop bc
	inc b
	inc b
	inc b
	ld a, b
	ret
.notTriage
	cp AB_QUICK_REFLEXES
	jr z, .quickReflexes
	cp ABILITY_EXTENDED
	jr nz, .gale
	ld a, [wAbilityResolvedExtended]
	cp AB_VANGUARD - ABILITY_EXTENDED
	jr nz, .gale
.quickReflexes
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
	ld a, [wAbilitySide]
	call AbilityGet
	cp AB_PRANKSTER
	jr nz, .wings
	ld a, [wAbilityTemp + 1]
	and a
	jr z, .plain
	cp MAX_MOVE_ID + 1
	jr nc, .plain
	cp BIDE ; zero power but it is a damaging move
	jr z, .plain
	call AbilityMoveFlags
	bit 0, a
	jr nz, .plain
	pop bc
	inc b
	ld a, b
	ret
.wings
	cp ABILITY_EXTENDED
	jr nz, .galeWings
	ld a, [wAbilityResolvedExtended]
	cp AB_LIGHTNING_SPEED - ABILITY_EXTENDED
	jr nz, .plain
	callab AbilityLightningSpeedMove
	ld a, [wAbilityCheckResult]
	and a
	jr z, .plain
	pop bc
	inc b
	ld a, b
	ret
.galeWings
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
	cp 4 ; Speed
	jp z, AbilityColossalSpeed
	cp 1
	ret nz
	ld a, 120
	ld [wAbilityTemp + 1], a
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
	cp AB_BOTTOMLESS_STOMACH
	jr z, .boost
	cp AB_ANCIENT
	jr z, .boost
	cp AB_BLUBBER
	jr z, .boost
	cp AB_COLOSSAL_SIZE
	ret nz
	ld a, 125
	ld [wAbilityTemp + 1], a
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
	ld a, [wAbilityTemp + 1]
	ld c, a
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
 cp LICKITUNG
 jr z, .bottomless
 cp ONIX
 jr z, .colossal
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
.bottomless
 ld b, 5
 xor a
 ret
.colossal
 ld a, 125
 ld [wAbilityTemp + 1], a
 ld b, 2
 xor a
 ret

AbilitySquirtleFamily:
	cp SQUIRTLE
	ret z
	cp WARTORTLE
	ret z
	cp BLASTOISE
	ret


AbilityDustOnly:
 jpab AbilityDustOnlyBanked

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
 jpab AbilityVeilOnlyBanked

; Ability poison is ordinary poison. Poison Fang's shared utility deliberately
; inflicts bad poison, so use a separate status writer for these passives.
AbilityInflictOrdinaryStatus:
	callab AbilityAntivirusCustom
	ld a, [wAbilityCheckResult]
	and a
	ret nz
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
 cp ABILITY_EXTENDED
 jr nz, .ordinary
 ld a, [wAbilityResolvedExtended]
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
 ld [wAbilityResolvedExtended], a
 callab AbilityBounceMoveBanked
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
 cp ABILITY_EXTENDED
 jr nz, .ordinary
 ld a, [wAbilityResolvedExtended]
 cp AB_CRUSHING_GRIP - ABILITY_EXTENDED
 ret nz
 jr .crushing
.ordinary
 cp AB_CRUSHING_CLAWS
 jr nz, .grappler
.crushing
 ld a, [wAbilityHit]
 bit 1, a ; a move gets one additional-effect roll
 ret nz
 jr .physical
.grappler
 cp AB_GRAPPLER
 ret nz
.physical
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
 call AbilityActor
 cp AB_CRUSHING_CLAWS
 jr z, .twenty
 cp ABILITY_EXTENDED
 jr nz, .ten
 ld a, [wAbilityResolvedExtended]
 cp AB_CRUSHING_GRIP - ABILITY_EXTENDED
 jr z, .twenty
.ten
 ld b, 10
 jr .roll
.twenty
 ld b, 20
.roll
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
 cp AB_ENTANGLE
 jr z, .entangle
 cp AB_EARTHSHAKER
 jr z, .earthshaker
 cp AB_ACIDIC
 ret nz
 ld a, [wAbilityMoveType]
 cp POISON
 ret nz
 jr .target
.entangle
 ld a, [wAbilityHit]
 bit 1, a
 ret nz
 ld a, [wAbilityMoveType]
 cp GRASS
 ret nz
 jr .target
.earthshaker
 ld a, [wAbilityHit]
 bit 1, a ; one chance per attack, not once per hit
 ret nz
 ld a, [wAbilityMoveType]
 cp GROUND
 ret nz
.target
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
 call AbilityActor
 cp AB_ENTANGLE
 jr z, .entangleRoll
 cp AB_EARTHSHAKER
 jr z, .earthRoll
 ld b, 25
 call AbilityRoll
 ret nc
 ld a, 1 ; Defense
 jr .stat
.entangleRoll
 ld b, 30
 call AbilityRoll
 ret nc
 ld a, 2
 jr .stat
.earthRoll
 ld b, 20
 call AbilityRoll
 ret nc
 ld a, 2 ; Speed
.stat
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
 cp ELECTRIC
 jr z, .electric
 cp GROUND
 ret nz
 call AbilityTarget
 cp AB_LEVITATE
 jr z, .immune
 ret
.electric
 call AbilityTarget
 cp ABILITY_EXTENDED
 ret nz
 ld a, [wAbilityResolvedExtended]
 cp AB_LIGHTNING_ROD - ABILITY_EXTENDED
 ret nz
.immune
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
 cp WATER
 jr z, .water
 cp ELECTRIC
 jr z, .electric
 cp GROUND
 ret nz
 call .targetAbility
 cp AB_LEVITATE
 jr z, .immune
 cp AB_EARTH_EATER
 ret nz
 jr .immune
.water
 call .targetAbility
 cp ABILITY_EXTENDED
 ret nz
 ld a, [wAbilityResolvedExtended]
 cp AB_WATER_ABSORB - ABILITY_EXTENDED
 ret nz
 jr .immune
.electric
 call .targetAbility
 cp ABILITY_EXTENDED
 ret nz
 ld a, [wAbilityResolvedExtended]
 cp AB_LIGHTNING_ROD - ABILITY_EXTENDED
 jr z, .immune
 cp AB_VOLT_ABSORB - ABILITY_EXTENDED
 ret nz
.immune
 ld a, 1
 ld [wAbilityCheckResult], a
 ret
.targetAbility
 ld a, [wUnusedC000]
 bit 3, a
 ld a, 0
 jr z, .side
 inc a
.side
 jp AbilityGet

; A direct lethal hit at full HP leaves the defender at 1 HP.
AbilitySturdyIncoming:
 jpab AbilitySturdyIncomingBanked

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
 cp AB_COMBOS
 jp z, AbilityCombosAfterAction
 cp AB_VOLTORB_CHAIN
 jp z, AbilityVoltorbChainAfterAction
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
 cp AB_LIMBER
 jr nz, .poison
 call AbilityHP
 inc hl
 inc hl
 inc hl
 bit PAR, [hl]
 ret z
 res PAR, [hl]
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 callab CustomRecalculate
 jpab UtilitySyncParty
.poison
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
 cp HITMONLEE
 jr nz, .notLimber
 push hl
 ld bc, wPartyMon1Type1 - wPartyMon1
 add hl, bc
 ld a, [hl]
 and $e0
 pop hl
 cp 5 << 5
 ret nz
 push hl
 ld bc, wPartyMon1Status - wPartyMon1
 add hl, bc
 res PAR, [hl]
 pop hl
 ret
.notLimber
 cp GEODUDE
 jr z, .family
 cp GRAVELER
 jr z, .family
 cp GOLEM
 jr z, .family
 cp EXEGGCUTE
 jr z, .egg
 cp EXEGGUTOR
 ret nz
.egg
 ld c, 4 << 5
 jr .slot
.family
 ld c, 2 << 5
.slot
 push hl
 push bc
 ld bc, wPartyMon1Type1 - wPartyMon1
 add hl, bc
 pop bc
 ld a, [hl]
 and $e0
 cp c
 pop hl
 ret nz
 push hl
 ld bc, wPartyMon1Status - wPartyMon1
 add hl, bc
 res PSN, [hl]
 pop hl
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
 jr z, .ordinary
 cp ABILITY_EXTENDED
 ret nz
 ld a, [wAbilityResolvedExtended]
 cp AB_MAGMAR_FLAME_BODY - ABILITY_EXTENDED
 ret nz
 ld b, 25
 jr .physical
.ordinary
 ld b, 20
.physical
 push bc
 ld a, [wAbilityMoveType]
 cp FIRE
 jr nc, .noPhysical
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 jr z, .noPhysical
 pop bc
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
.noPhysical
 pop bc
 ret

; Legacy stat-up effects raise the active side. Preserve their scratch state.
AbilityCompetitiveLegacy:
 ld a, [wCustomSide]
 push af
 ld a, [wCustomStat]
 push af
 ld a, [H_WHOSETURN]
 ld [wCustomSide], a
 ld a, [wCopycatStat]
 ld [wCustomStat], a
 call AbilityCopycatFromSide
 call AbilityCompetitiveFromSide
 pop af
 ld [wCustomStat], a
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
 call AbilitySimpleLegacy
 jp AbilityCopycatLegacy
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
 cp ABILITY_EXTENDED
 jr nz, .ordinary
 ld a, [wAbilityResolvedExtended]
 cp AB_PROTEAN - ABILITY_EXTENDED
 jr z, .protean
 ld a, ABILITY_EXTENDED
 jr .ordinary
.protean
 jpab AbilityProteanConvert
.ordinary
 cp AB_REFRIGERATE
 jr z, .ice
 cp AB_LIQUIDATE
 jr z, .water
 ld c, AB_GALVANIZE - ABILITY_EXTENDED
 call AbilityExtendedActorIs
 ret nc
 ld b, ELECTRIC
 call AbilityMove
 inc hl
 inc hl
 inc hl ; Galvanize also converts status and fixed-damage moves.
 jr .checkNormal
.water
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
.checkNormal
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

; Nocturnal modifies damaging moves against sleeping living targets.
AbilityNocturnalDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityNocturnalFixedDamage:
 call AbilityActor
 cp AB_NOCTURNAL
 ret nz
 ld a, [wCriticalHitOrOHKO]
 cp 2
 ret z
 call AbilityTargetStatus
 ld a, [hl]
 and SLP
 ret z
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 ld c, 120
 jp AbilityScaleDamage

; Store the opponent's pre-action confusion in the active-side scratch byte.
; Rollout is mutually exclusive with Mind Games and resets this byte on entry.
AbilityMindGamesBefore:
 call AbilityActor
 cp AB_MIND_GAMES
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityRolloutSidePointer
 push hl
 ld hl, wEnemyBattleStatus1
 ld a, [H_WHOSETURN]
 and a
 jr z, .target
 ld hl, wPlayerBattleStatus1
.target
 ld a, [hl]
 and 1 << CONFUSED
 pop hl
 ld [hl], a
 ret
AbilityMindGamesAfter:
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 call AbilityActor
 cp AB_MIND_GAMES
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityRolloutSidePointer
 ld a, [hl]
 and a
 ret nz
 ld hl, wEnemyBattleStatus1
 ld a, [H_WHOSETURN]
 and a
 jr z, .target
 ld hl, wPlayerBattleStatus1
.target
 bit CONFUSED, [hl]
 ret z
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
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
 ld a, 3 ; Special
 jp AbilityRaiseStage

; Called only after a damaging hit that did not strike a Substitute.
AbilityGhostReaction:
 call AbilityTarget
 cp AB_CURSED_BODY
 jp z, AbilityCursedBody
 cp AB_GAS_BODY
 jr z, .physical
 cp AB_CURSED_TOUCH
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
 call AbilityTarget
 cp AB_CURSED_TOUCH
 jr z, .curse
 ; Gas Body applies to all physical attacks, including ranged ones.
 call AbilityActor
 cp AB_CLEAR_BODY
 ret z
 ld b, 30
 call AbilityRoll
 ret nc
 ld a, [H_WHOSETURN]
 ld [wCustomSide], a
 ld a, 4
 ld [wCustomStat], a
 ld a, -1
 ld [wCustomDelta], a
 xor a
 ld [wCustomChanged], a
 jpab CustomChangeStage
.curse
 ld b, 20
 call AbilityRoll
 ret nc
 ld hl, wPlayerResidual
 ld a, [H_WHOSETURN]
 and a
 jr z, .applyCurse
 ld hl, wEnemyResidual
.applyCurse
 bit 1, [hl]
 ret nz
 set 1, [hl]
 ld hl, AbilityCursedTouchText
 jp PrintText
AbilityCursedTouchText:
 text "CURSED TOUCH"
 line "cursed its foe!"
 prompt

; Disable the damaging move for 1-8 actions; counters tick before action.
; Copied moves not present in the attacker's moveset cannot be disabled.
AbilityCursedBody:
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld hl, wPlayerDisabledMove
 ld de, wBattleMonMoves
 ld a, [H_WHOSETURN]
 and a
 jr z, .side
 ld hl, wEnemyDisabledMove
 ld de, wEnemyMonMoves
.side
 ld a, [hl]
 and a
 ret nz
 call AbilityMove
 ld a, [hl]
 ld c, a
 and a
 ret z
 ld hl, wBattleMonMoves
 ld a, [H_WHOSETURN]
 and a
 jr z, .find
 ld hl, wEnemyMonMoves
.find
 ld b, 0
.loop
 ld a, [hli]
 cp c
 jr z, .found
 inc b
 ld a, b
 cp 4
 jr c, .loop
 ret
.found
 push bc
 ld b, 30
 call AbilityRoll
 pop bc
 ret nc
 push bc
 callab CustomRandomInBattleBank
 pop bc
 ld a, [wCustomRandomValue]
 and 7
 add 2 ; pre-action decrement must still leave 1-8 blocked actions
 inc b
 swap b
 add b
 ld hl, wPlayerDisabledMove
 ld de, wPlayerDisabledMoveNumber
 ld b, a
 ld a, [H_WHOSETURN]
 and a
 jr z, .store
 ld hl, wEnemyDisabledMove
 ld de, wEnemyDisabledMoveNumber
.store
 ld [hl], b
 ld a, c
 ld [de], a
 ld hl, AbilityCursedBodyText
 jp PrintText
AbilityCursedBodyText:
 text "CURSED BODY"
 line "disabled its foe!"
 prompt

; Speed is scaled with permanent stats, after natures and before storage.
AbilityColossalSpeed:
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
 cp HITMONLEE
 jr z, .enemyLimber
 cp ONIX
 ret nz
 ld a, [wNatureEnemySlot]
 jr .slot
.enemyLimber
 ld a, [wNatureEnemySlot]
 cp 5
 jp z, .limberScale
 ret
.player
 ld de, wBattleMonHP
 ld a, h
 cp d
 jr nz, .stored
 ld a, l
 cp e
 jr nz, .stored
 ld a, [wActiveAbilities]
 cp AB_LIMBER
 jp z, .limberScale
 cp AB_COLOSSAL_SIZE
 jr nz, .no
 jr .scale
.stored
 ld de, -16
 add hl, de
 ld a, [hl]
 cp HITMONLEE
 jr z, .storedLimber
 cp ONIX
 ret nz
 ld de, 5
 add hl, de
 ld a, [hl]
 rlca
 rlca
 rlca
 and 7
.slot
 cp 2
 ret nz
.scale
 ld c, 75
 jr .scaleCommon
.storedLimber
 ld de, 5
 add hl, de
 ld a, [hl]
 and $e0
 cp 5 << 5
 ret nz
.limberScale
 ld c, 120
.scaleCommon
 call AbilityScaleAccuracy
 ld a, [H_QUOTIENT + 2]
 ld b, a
 ld a, [H_QUOTIENT + 3]
 or b
 ret nz
 inc a
 ld [H_QUOTIENT + 3], a
 ret
.no
 ret

; Invoked after accuracy and reachability succeed, before damage is applied.
AbilityEarthEaterOnHit:
 jpab AbilityElementAbsorbOnHit

; Apply one sleep roll after a successful unshielded Ground attack.
AbilitySandmanSleep:
 callab AbilityAntivirusTarget
 ld a, [wAbilityCheckResult]
 and a
 ret nz
 call AbilityTargetStatus
 ld a, [hl]
 and a
 ret nz
 push hl
.roll
 callab CustomRandomInBattleBank
 ld a, [wCustomRandomValue]
 and 7
 cp 2
 jr c, .roll
 pop hl
 ld [hl], a
 ld hl, wEnemyBattleStatus2
 ld a, [H_WHOSETURN]
 xor 1
 ld [wCustomSide], a
 and a
 jr nz, .status2
 ld hl, wPlayerBattleStatus2
.status2
 res NEEDS_TO_RECHARGE, [hl]
 callab UtilitySyncParty
 ld hl, AbilitySandmanText
 jp PrintText
AbilitySandmanText:
 text "SANDMAN put the"
 line "foe to sleep!"
 prompt

; Both holders are checked once, before the standard end-of-round residuals.
AbilityNightmareBoth:
 xor a
 ld [wAbilitySide], a
 call AbilityNightmareOne
 ld a, 1
 ld [wAbilitySide], a
 jp AbilityNightmareOne
AbilityNightmareOne:
 ld a, [wAbilitySide]
 call AbilityGet
 cp AB_NIGHTMARE
 ret nz
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld a, [wAbilitySide]
 xor 1
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 inc hl
 inc hl
 ld a, [hl]
 and SLP
 ret z
 ld a, [wAbilitySide]
 call AbilityGet
 cp AB_MAGIC_GUARD
 ret z
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 ld a, 4
 ld [wCustomDelta], a
 xor a
 ld [wCustomChance], a
 callab ResidualFraction
 ld hl, AbilityNightmareText
 jp PrintText
AbilityNightmareText:
 text "NIGHTMARE hurt"
 line "the sleeping foe!"
 prompt

; Trigger only when this action newly put a living target to sleep.
AbilitySleepAfterAction:
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 call AbilityActor
 cp AB_DEEP_SLEEP
 jr z, .eligible
 cp AB_DREAMCATCHER
 ret nz
.eligible
 ld a, [wAbilityOldStatus]
 and a
 ret nz
 call AbilityTargetStatus
 ld a, [hl]
 and SLP
 ret z
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 call AbilityActor
 cp AB_DEEP_SLEEP
 jr z, .extend
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityHP
 ld a, 3
 jp AbilityHealFractionFromHL
.extend
 call AbilityTargetStatus
 ld a, [hl]
 and SLP
 cp 7
 jr z, .pending
 inc [hl]
 ld a, [H_WHOSETURN]
 xor 1
 ld [wCustomSide], a
 jpab UtilitySyncParty
.pending
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 call AbilityDeepSleepPointer
 ld a, [hl]
 or c
 ld [hl], a
 ret

; HL = side's bitset; C = current party member's bit.
AbilityDeepSleepPointer:
 ld hl, wDeepSleepPending
 ld a, [wAbilitySide]
 and a
 ld a, [wPlayerMonNumber]
 jr z, .index
 inc hl
 ld a, [wIsInBattle]
 cp 2
 ld a, 0
 jr nz, .index
 ld a, [wEnemyMonPartyPos]
 cp 6
 jr c, .index
 xor a
.index
 cp 6
 jr c, .valid
 xor a
.valid
 ld b, a
 ld c, 1
.loop
 ld a, b
 and a
 ret z
 sla c
 dec b
 jr .loop

; A maxed sleep counter cannot hold eight. After it ticks below seven,
; spend its pending extension; keep the bit with that party member on switch.
AbilityDeepSleepRound:
 ld a, [wCustomSide]
 push af
 xor a
 ld [wAbilitySide], a
 call AbilityDeepSleepRoundOne
 ld a, 1
 ld [wAbilitySide], a
 call AbilityDeepSleepRoundOne
 pop af
 ld [wCustomSide], a
 ret
AbilityDeepSleepRoundOne:
 call AbilityDeepSleepPointer
 ld a, [hl]
 and c
 ret z
 push hl
 push bc
 call AbilityHP
 ld a, [hli]
 or [hl]
 jr z, .clear
 inc hl
 inc hl
 ld a, [hl]
 and SLP
 jr z, .clear
 cp 7
 jr z, .keep
 inc [hl]
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 callab UtilitySyncParty
.clear
 pop bc
 pop hl
 ld a, c
 cpl
 and [hl]
 ld [hl], a
 ret
.keep
 pop bc
 pop hl
 ret

; If a pending max-duration sleeper was cured, drop its extension before
; another action can put that party member to sleep again.
AbilityDeepSleepClearAwake:
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
 call AbilityDeepSleepPointer
 ld a, [hl]
 and c
 ret z
 push hl
 push bc
 call AbilityHP
 inc hl
 inc hl
 inc hl
 ld a, [hl]
 and SLP
 jr nz, .done
 pop bc
 pop hl
 ld a, c
 cpl
 and [hl]
 ld [hl], a
 ret
.done
 pop bc
 pop hl
 ret

; Ordinary damage only: fixed-damage attacks and OHKOs have no base power.
AbilityKrabbyDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 call AbilityActor
 cp AB_HYPER_CUTTER
 jr z, .critical
 cp AB_BRUTE_FORCE
 ret nz
 ld a, [wCriticalHitOrOHKO]
 cp 2
 ret z
 call AbilityMove
 inc hl
 inc hl
 ld a, [hli]
 and a
 ret z
 cp 61
 ret nc
 ld a, [hl]
 cp FIRE ; physical types precede FIRE
 ret nc
 ld c, 130
 jp AbilityScaleDamage
.critical
 ld a, [wCriticalHitOrOHKO]
 cp 1
 ret nz
 ld c, 125
 jp AbilityScaleDamage

; Voltorb has a consecutive-attack version of Chain Reaction.
AbilityVoltorbDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 call AbilityActor
 cp AB_HIGH_VOLTAGE
 jr z, .speed
 cp AB_VOLTORB_CHAIN
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
 cp 2
 ld c, 120
 jr c, .scale
 ld c, 140
 jr .scale
.speed
 call AbilityActorMoveType
 cp ELECTRIC
 ret nz
 call AbilityCompareFaster
 ret nc
 ld c, 120
.scale
 jp AbilityScaleDamage

AbilityVoltorbChainAfterAction:
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
 cp ELECTRIC
 jr nz, .reset
 ld a, [wMoveMissed]
 and a
 jr nz, .reset
 ld a, [wDamageMultipliers]
 and $7f
 jr z, .reset
 pop hl
 ld a, [hl]
 cp 2
 ret nc
 inc [hl]
 ret
.reset
 pop hl
 ld [hl], 0
 ret

; Only a direct knockout of the holder triggers Volatile, never a Substitute.
AbilityVolatile:
 ld a, [wCustomTargetHadSub]
 and a
 ret nz
 call AbilityTarget
 cp AB_VOLATILE
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
 call AbilityGet
 cp AB_MAGIC_GUARD
 ret z
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 xor a
 ld [H_DIVIDEND], a
 ld [H_DIVIDEND + 1], a
 ld a, [de]
 ld [H_DIVIDEND + 2], a
 inc de
 ld a, [de]
 ld [H_DIVIDEND + 3], a
 ld a, 5
 ld [H_DIVISOR], a
 ld b, 4
 call Divide
 ld a, [H_QUOTIENT + 2]
 ld [wAbilityTemp], a
 ld b, a
 ld a, [H_QUOTIENT + 3]
 or b
 jr nz, .amount
 inc a
.amount
 ld [wAbilityTemp + 1], a
 jp AbilityLiquidOozeHurt

AbilityEggDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityEggFixedDamage:
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 call AbilityActor
 cp AB_EXECUTIONER
 jr z, .executioner
 cp ABILITY_EXTENDED
 jr nz, .ordinary
 ld a, [wAbilityResolvedExtended]
 cp AB_KABUTO_EXECUTIONER - ABILITY_EXTENDED
 jr z, .executioner
 ret
.ordinary
 cp AB_SOLAR_POWER
 ret nz
 call AbilityActorMoveType
 cp GRASS
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityHP
 call AbilityHalfHP
 ret c
 ret z
 jr .boost
.executioner
 call AbilityActorMoveType
 cp FIRE
 ret nc
 ld a, [H_WHOSETURN]
 xor 1
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 dec hl
 call AbilityHalfHP
 ret nc
 call AbilityActor
 cp ABILITY_EXTENDED
 jr nz, .boost
 ld c, 120
 jp AbilityScaleDamage
.boost
 ld c, 125
 jp AbilityScaleDamage

; Rock Head stops move recoil without granting Magic Guard's other protections.
AbilityRecoilGuardActor:
 call AbilityMagicGuardActor
 ld a, [wAbilityCheckResult]
 and a
 ret nz
 call AbilityActor
 cp AB_ROCK_HEAD
 ret nz
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

AbilityHitmonleeDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 call AbilityActor
 cp AB_RECKLESS
 jr z, .reckless
 cp AB_LONG_LEGS
 ret nz
 call AbilityMove
 ld a, [hl]
 cp DOUBLE_KICK
 jr z, .boost
 cp MEGA_KICK
 jr z, .boost
 cp JUMP_KICK
 jr z, .boost
 cp ROLLING_KICK
 jr z, .boost
 cp LOW_KICK
 jr z, .boost
 cp HI_JUMP_KICK
 jr z, .boost
 cp TRIPLE_KICK
 ret nz
 jr .boost
.reckless
 call AbilityMove
 inc hl
 ld a, [hl]
 cp RECOIL_EFFECT
 jr z, .boost
 cp JUMP_KICK_EFFECT
 ret nz
.boost
 ld c, 125
 jp AbilityScaleDamage

AbilityResilienceIncoming:
 ld a, [wDamageMultipliers]
 and $7f
 cp 11
 ret c
 ld hl, wAbilityHit
 bit 6, [hl]
 jr nz, .reduce
 call AbilityFlagsPointer
 bit 0, [hl]
 ret nz
 set 0, [hl]
 ld hl, wAbilityHit
 set 6, [hl]
.reduce
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
 ld c, 25
 call AbilityScaleDamage
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret nz
 inc a
 ld [wDamage + 1], a
 ret

AbilityLimberTarget:
 jpab AbilityLimberTargetBanked

AbilityLimberSecondary:
 call AbilityMove
 inc hl
 ld a, [hl]
 cp PARALYZE_SIDE_EFFECT1
 jr z, AbilityLimberTarget
 cp PARALYZE_SIDE_EFFECT2
 jr z, AbilityLimberTarget
 xor a
 ld [wAbilityCheckResult], a
 ret

; Stacks count completed punches, not hits within a multi-hit move.
AbilityHitmonchanDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 call AbilityActor
 cp AB_COMBOS
 ret nz
 call AbilityMove
 ld a, [hl]
 call AbilityMoveFlags
 bit 7, a
 ret z
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

AbilityCombosAfterAction:
 ld a, [wAbilityHit]
 bit 3, a
 ret z
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityRolloutSidePointer
 push hl
 call AbilityMove
 ld a, [hl]
 call AbilityMoveFlags
 bit 7, a
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

AbilitySecondWind:
 call AbilityBelowThird
 ret nc
 call AbilityFlagsPointer
 bit 2, [hl]
 ret nz
 set 2, [hl]
 jp AbilityHealQuarter

AbilityLickitungDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityLickitungFixedDamage:
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 call AbilityActor
 cp AB_THICK_TONGUE
 ret nz
 call AbilityActorMoveType
 cp NORMAL
 ret nz
 ld c, 130
 jp AbilityScaleDamage

AbilityGasLeakBoth:
 xor a
 ld [wAbilitySide], a
 call AbilityGasLeakOne
 ld a, 1
 ld [wAbilitySide], a
 jp AbilityGasLeakOne
AbilityGasLeakOne:
 ld a, [wAbilitySide]
 call AbilityGet
 cp AB_GAS_LEAK
 ret nz
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld a, [wAbilitySide]
 xor 1
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld a, [wAbilitySide]
 call AbilityGet
 cp AB_MAGIC_GUARD
 ret z
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 ld a, 4
 ld [wCustomDelta], a
 xor a
 ld [wCustomChance], a
 callab ResidualFraction
 ret

AbilityActorResult:
 call AbilityActor
 ld [wAbilityCheckResult], a
 ret
AbilityTargetResult:
 call AbilityTarget
 ld [wAbilityCheckResult], a
 ret

AbilityPlayerResult:
 xor a
 call AbilityGet
 ld [wAbilityCheckResult], a
 ret

AbilityRhyhornDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityRhyhornFixedDamage:
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 call AbilityActor
 cp AB_CHARGE
 jr z, .charge
 cp AB_HORN_BREAKER
 ret nz
 call AbilityMove
 ld a, [hl]
 cp HORN_ATTACK
 jr z, .horn
 cp FURY_ATTACK
 jr z, .horn
 cp HORN_DRILL
 jr z, .horn
 cp MEGAHORN
 ret nz
.horn
 ld c, 125
 jp AbilityScaleDamage
.charge
 ld a, [wCriticalHitOrOHKO]
 cp 2
 ret z
 ld a, [wAbilityHit]
 bit 4, a
 jr nz, .chargeBoost
 ; Bide releases outside the ordinary move-attempt hook.
 bit 5, a
 ret z
 call AbilityMove
 ld a, [hl]
 cp BIDE
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityFlagsPointer
 bit 3, [hl]
 ret nz
 set 3, [hl]
 ld hl, wAbilityHit
 set 4, [hl]
.chargeBoost
 call AbilityActorMoveType
 cp FIRE
 ret nc
 ld c, 130
 jp AbilityScaleDamage

; The top bit is spare in each six-member Deep Sleep party bitset.
AbilityPlayerWithdraw:
 xor a
 jr AbilityWithdraw
AbilityEnemyWithdraw:
 ld a, 1
AbilityWithdraw:
 ld [wAbilitySide], a
 call AbilityGet
 cp ABILITY_EXTENDED
 jr nz, .legacy
 ld a, [wAbilityResolvedExtended]
 cp AB_REGENERATOR - ABILITY_EXTENDED
 ret nz
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 jp AbilityHealQuarter
.legacy
 cp AB_HEALER
 jr z, .healer
 cp AB_NATURAL_CURE
 ret nz
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 inc hl
 inc hl
 xor a
 ld [hl], a
 ld hl, wPlayerBattleStatus3
 ld de, wPlayerToxicCounter
 ld a, [wAbilitySide]
 and a
 jr z, .cure
 ld hl, wEnemyBattleStatus3
 ld de, wEnemyToxicCounter
.cure
 res BADLY_POISONED, [hl]
 xor a
 ld [de], a
 call AbilityDeepSleepClearAwake
 ld a, [wAbilitySide]
 ld [wCustomSide], a
 jpab UtilitySyncParty
.healer
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld hl, wDeepSleepPending
 ld a, [wAbilitySide]
 and a
 jr z, .pending
 inc hl
.pending
 set 7, [hl]
 ret

AbilityHealerOnEntry:
 ld hl, wDeepSleepPending
 ld a, [wAbilitySide]
 and a
 jr z, .check
 inc hl
.check
 bit 7, [hl]
 ret z
 res 7, [hl]
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld a, 10
 jp AbilityHealDivided

AbilityTriageMove:
 cp RECOVER
 jr z, .yes
 cp SOFTBOILED
 jr z, .yes
 cp REST
 jr z, .yes
 cp SYNTHESIS
 jr z, .yes
 cp ROOST
 jr z, .yes
 cp MOONLIGHT
 jr z, .yes
 cp MILK_DRINK
 jr z, .yes
 cp ABSORB
 jr z, .yes
 cp MEGA_DRAIN
 jr z, .yes
 cp GIGA_DRAIN
 jr z, .yes
 cp LEECH_LIFE
 jr z, .yes
 cp DREAM_EATER
 jr z, .yes
 cp DRAIN_PUNCH
 jr z, .yes
 cp SHADOW_LEECH
 jr z, .yes
 cp CLAMP
 jr z, .yes
 and a
 ret
.yes
 scf
 ret

AbilityLuckyDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
 ld a, [wCriticalHitOrOHKO]
 cp 1
 ret nz
 call AbilityTarget
 cp AB_LUCKY
 ret nz
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 ld c, 50
 jp AbilityScaleDamage

AbilityTangelaDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityTangelaFixedDamage:
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 call AbilityActor
 cp ABILITY_EXTENDED
 ret nz
 ld a, [wAbilityResolvedExtended]
 cp AB_THICK_VINES - ABILITY_EXTENDED
 ret nz
 call AbilityActorMoveType
 cp FIRE
 ret nc
 ld c, 120
 jp AbilityScaleDamage

; Carry iff the active actor has the requested extended ability in C.
AbilityExtendedActorIs:
 push bc
 call AbilityActor
 cp ABILITY_EXTENDED
 jr nz, .no
 ld a, [wAbilityResolvedExtended]
 cp c
 jr nz, .no
 pop bc
 scf
 ret
.no
 pop bc
 and a
 ret

; Targeted Grass status moves can hit Sap Sipper without dealing damage.
AbilitySapSipperStatus:
 jpab AbilitySapSipperStatusBanked

AbilityRaiseAttack:
 xor a
 jp AbilityRaiseStage

; Jynx status boost happens once per battle, only on an executed status move.
AbilityDancerAfterAction:
 jpab AbilityDancerAfterActionBanked

AbilityDancerStatusCheck:
 call AbilityMove
 ld a, [hl]
 call AbilityMoveFlags
 bit 0, a
 ret

AbilityRaiseSpeed:
 ld a, 2
 jp AbilityRaiseStage

AbilityScaleDamage115:
 ld c, 115
 jp AbilityScaleDamage

AbilityDesperationDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityDesperationFixedDamage:
 jpab AbilityDesperationBanked

AbilityScaleDamage125:
 ld c, 125
 jp AbilityScaleDamage

AbilityScaleDamage120:
 ld c, 120
 jp AbilityScaleDamage

AbilityScaleDamage130:
 ld c, 130
 jp AbilityScaleDamage

; Carry for damaging moves other than Bide, whose release is handled later.
AbilityWrathMoveCheck:
 call AbilityMove
 ld a, [hl]
 cp BIDE
 jr z, .no
 call AbilityMoveFlags
 bit 0, a
 jr z, .no
 scf
 ret
.no
 and a
 ret

AbilityHeavyHitterDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityHeavyHitterFixedDamage:
 ld c, AB_HEAVY_HITTER - ABILITY_EXTENDED
 call AbilityExtendedActorIs
 ret nc
 call AbilityActorMoveType
 cp FIRE
 ret nc
 ld a, [H_WHOSETURN]
 and a
 jr nz, .enemy
 ld a, [wPatientActed]
 bit 1, a
 jr nz, .boost
 ld a, [wUnusedC000]
 bit 1, a
 ret z
 jr .boost
.enemy
 ld a, [wPatientActed]
 bit 0, a
 jr nz, .boost
 ld a, [wActionResultOrTookBattleTurn]
 and a
 ret z
.boost
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 ld c, 120
 jp AbilityScaleDamage

AbilityMaternalRage:
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
 xor a
 jp AbilityRaiseStage

; Counting down twice per attempted action halves sleep duration, rounding up.
AbilityEarlyBirdBeforeAction:
 ld c, AB_EARLY_BIRD - ABILITY_EXTENDED
 call AbilityExtendedActorIs
 ret nc
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

; Record the first hit and schedule one final strike after ordinary multi-hits.
AbilityParentalAfterHit:
 ld c, AB_PARENTAL_BOND - ABILITY_EXTENDED
 call AbilityExtendedActorIs
 jr c, .eligible
 ld c, AB_DOUBLE_SCYTHES - ABILITY_EXTENDED
 call AbilityExtendedActorIs
 ret nc
 call AbilityCuttingCheck
 ret nc
 ld a, [wParentalState]
 and $0c
 jr nz, .eligible
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 ld a, 4
 ld [wParentalState], a
 ld b, 20
 call AbilityRoll
 ret nc
 ld a, 8
 ld [wParentalState], a
.eligible
 ld a, [wParentalState]
 bit 2, a
 ret nz
 call AbilityMove
 ld a, [hli]
 cp BIDE
 jr z, .damaging
 inc hl
 ld a, [hl]
 and a
 ret z
.damaging
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 ld a, [wParentalState]
 bit 1, a
 ret nz
 bit 0, a
 jr nz, .recorded
 ld a, [wDamage]
 ld [wParentalFirstDamage], a
 ld a, [wDamage + 1]
 ld [wParentalFirstDamage + 1], a
 ld a, [wParentalState]
 or 1
 ld [wParentalState], a
.recorded
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld a, [wAbilitySide]
 xor 1
 ld [wAbilitySide], a
 call AbilityHP
 ld a, [hli]
 or [hl]
 ret z
 ld hl, wPlayerBattleStatus1
 ld de, wPlayerNumAttacksLeft
 ld bc, wPlayerNumHits
 ld a, [H_WHOSETURN]
 and a
 jr z, .side
 ld hl, wEnemyBattleStatus1
 ld de, wEnemyNumAttacksLeft
 ld bc, wEnemyNumHits
.side
 bit ATTACKING_MULTIPLE_TIMES, [hl]
 jr z, .start
 ld a, [de]
 cp 1
 ret nz
 ld a, 2
 ld [de], a
 ld a, [bc]
 inc a
 ld [bc], a
 jr .scheduled
.start
 ; Native multi-hit moves set their own counter after their first hit.
 push hl
 push de
 push bc
 call AbilityMove
 inc hl
 ld a, [hl]
 cp TWO_TO_FIVE_ATTACKS_EFFECT
 jr z, .native
 cp ATTACK_TWICE_EFFECT
 jr z, .native
 cp TWINEEDLE_EFFECT
 jr z, .native
 pop bc
 pop de
 pop hl
 set ATTACKING_MULTIPLE_TIMES, [hl]
 ld a, 2
 ld [de], a
 ld [bc], a
.scheduled
 ld a, [wParentalState]
 or 3
 ld [wParentalState], a
 ret
.native
 pop bc
 pop de
 pop hl
 ret

; Called after other modifiers, immediately before the actual HP/substitute hit.
AbilityParentalOverride:
 ld a, [wParentalState]
 bit 1, a
 ret z
 ld hl, wPlayerNumAttacksLeft
 ld a, [H_WHOSETURN]
 and a
 jr z, .remaining
 ld hl, wEnemyNumAttacksLeft
.remaining
 ld a, [hl]
 cp 1
 ret nz
 ld a, [wParentalFirstDamage]
 ld b, a
 ld a, [wParentalFirstDamage + 1]
 ld c, a
 srl b
 rr c
 ld a, [wParentalState]
 bit 3, a
 jr nz, .scaled
 srl b
 rr c
.scaled
 ld a, b
 or c
 jr nz, .store
 inc c
.store
 ld a, b
 ld [wDamage], a
 ld a, c
 ld [wDamage + 1], a
 ret

; Focused is spent on the holder's first executed move, even a status move.
AbilityFocusedDamage:
 ld a, [wUnusedC000]
 bit 4, a
 ret nz
AbilityFocusedFixedDamage:
 ld c, AB_FOCUSED - ABILITY_EXTENDED
 call AbilityExtendedActorIs
 ret nc
 ld a, [wCriticalHitOrOHKO]
 cp 2
 ret z
 ld a, [wAbilityHit]
 bit 4, a
 jr nz, .boost
 bit 5, a
 ret z
 call AbilityMove
 ld a, [hl]
 cp BIDE
 ret nz
 ld a, [H_WHOSETURN]
 ld [wAbilitySide], a
 call AbilityFlagsPointer
 bit 1, [hl]
 ret z
 res 1, [hl]
 ld hl, wAbilityHit
 set 4, [hl]
.boost
 ld a, [wDamage]
 ld b, a
 ld a, [wDamage + 1]
 or b
 ret z
 ld c, 120
 jp AbilityScaleDamage

AbilityWaterJet:
 ld c, AB_WATER_JET - ABILITY_EXTENDED
 call AbilityExtendedActorIs
 jr c, .water
 ld c, AB_DEEP_SEA_PRESSURE - ABILITY_EXTENDED
 call AbilityExtendedActorIs
 jr c, .water
 ld c, AB_COLD_TOUCH - ABILITY_EXTENDED
 call AbilityExtendedActorIs
 ret nc
 ld a, [wAbilityMoveType]
 cp FIRE
 ret nc
 jr .eligible
.water
 ld a, [wAbilityMoveType]
 cp WATER
 ret nz
.eligible
 ld a, [wAbilityHit]
 bit 1, a
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
 ld b, 20
 call AbilityRoll
 ret nc
 ld a, 2
 ld [wCustomStat], a
 xor a
 ld [wCustomChanged], a
 dec a
 ld [wCustomDelta], a
 jpab CustomChangeStage

; Match the same horn-based moves as Horn Breaker.
AbilityRoyalHornMove:
 call AbilityMove
 ld a, [hl]
 cp HORN_ATTACK
 jr z, .yes
 cp FURY_ATTACK
 jr z, .yes
 cp HORN_DRILL
 jr z, .yes
 cp MEGAHORN
 jr z, .yes
 and a
 ret
.yes
 scf
 ret

; wParentalState bit 7 and the adjacent word are free when the actor has
; Equalizer rather than Parental Bond. Capture damage after STAB, before type.
AbilityEqualizerSnapshot:
 call AbilityMove
 inc hl
 inc hl
 ld a, [hl]
 and a
 ret z ; status moves do not gain this effect
 ld c, AB_EQUALIZER - ABILITY_EXTENDED
 call AbilityExtendedActorIs
 ret nc
 ld a, [wParentalState]
 bit 7, a
 ret nz
 set 7, a
 res 6, a
 ld [wParentalState], a
 ld a, [wMoveMissed]
 and a
 jr z, .saveDamage
 ld a, [wParentalState]
 set 6, a
 ld [wParentalState], a
.saveDamage
 ld a, [wDamage]
 ld [wParentalFirstDamage], a
 ld a, [wDamage + 1]
 ld [wParentalFirstDamage + 1], a
 ret

AbilityEqualizerDamage:
 ld a, [wParentalState]
 bit 7, a
 ret z
 res 7, a
 ld [wParentalState], a
 ld c, AB_EQUALIZER - ABILITY_EXTENDED
 call AbilityExtendedActorIs
 ret nc
 ld a, [wDamageMultipliers]
 and $7f
 ret z ; retain all type immunities
 cp 10
 ret nc ; neutral and super-effective damage stay as calculated
 ld a, [wParentalFirstDamage]
 ld [wDamage], a
 ld a, [wParentalFirstDamage + 1]
 ld [wDamage + 1], a
 ld b, a
 ld a, [wDamage]
 or b
 jr z, .preserveMiss
 ld a, [wParentalState]
 bit 6, a
 jr nz, .preserveMiss
 xor a
 ld [wMoveMissed], a ; type rounding briefly produced zero damage
.preserveMiss
 ld a, [wDamageMultipliers]
 and $80
 or 10
 ld [wDamageMultipliers], a
 ret

; AI type evaluation uses the simulated attacker's side, not H_WHOSETURN.
AbilityEqualizerAIFinal:
 ld a, [wTypeEffectiveness]
 and a
 ret z
 cp 10
 ret nc
 ld a, [wUnusedC000]
 bit 3, a
 jr nz, .player
 ld a, [wEnemyMovePower]
 and a
 ret z
 ld a, 1
 jr .check
.player
 ld a, [wPlayerMovePower]
 and a
 ret z
 xor a
.check
 call AbilityGet
 cp ABILITY_EXTENDED
 ret nz
 ld a, [wAbilityResolvedExtended]
 cp AB_EQUALIZER - ABILITY_EXTENDED
 ret nz
 ld a, 10
 ld [wTypeEffectiveness], a
 ret

AbilityStrongmanCheck:
 xor a
 ld [wAbilityCheckResult], a
 ld c, AB_STRONGMAN - ABILITY_EXTENDED
 call AbilityExtendedActorIs
 ret nc
 call AbilityActorMoveType
 cp FIRE
 ret nc
 ld a, 1
 ld [wAbilityCheckResult], a
 ret

; Reflect stage reductions via the same protected, capped stat-change path.
AbilityMirrorArmorCustom:
 jpab AbilityMirrorArmorCustomBanked

AbilityMirrorArmorLegacy:
 xor a
 ld [wAbilityCheckResult], a
 ld a, [wCustomSide]
 push af
 ld a, [wCustomDelta]
 push af
 ld a, [H_WHOSETURN]
 xor 1
 ld [wCustomSide], a
 call AbilityMove
 inc hl
 ld a, [hl]
 cp ATTACK_DOWN2_EFFECT
 jr c, .one
 cp EVASION_DOWN2_EFFECT + 1
 jr nc, .one
 ld a, -2
 jr .delta
.one
 ld a, -1
.delta
 ld [wCustomDelta], a
 call AbilityMirrorArmorCustom
 pop af
 ld [wCustomDelta], a
 pop af
 ld [wCustomSide], a
 ret

; Copy a positive actual stage delta once, with a guard for two holders.
AbilityCopycatFromSide:
 jpab AbilityCopycatFromSideBanked

AbilityGetCopycatTarget:
 ld a, [wCustomSide]
 xor 1
 jp AbilityGet

; Legacy stat-up hook runs before its clamped new stage is written.
AbilityCopycatLegacy:
 ld a, [wUnusedD71B]
 dec a
 ld [wCopycatStat], a
 ld e, a
 ld d, 0
 ld hl, wPlayerMonStatMods
 ld a, [H_WHOSETURN]
 and a
 jr z, .stage
 ld hl, wEnemyMonStatMods
.stage
 add hl, de
 ld a, [wAbilityTemp]
 sub [hl]
 ld [wCopycatDelta], a
 ret
