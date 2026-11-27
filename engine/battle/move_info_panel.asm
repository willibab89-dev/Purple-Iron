SECTION "Battle move information panel", ROMX, BANK[$3d]

; Runs only for the ordinary battle move menu. The power shown is the move's
; listed power; conditional damage modifiers act on damage rather than power.
MoveInfoPanel:
 xor a
 ld [H_AUTOBGTRANSFERENABLED], a
 coord hl, 0, 6
 ld b, 5
 ld c, 9
 call TextBoxBorder
 ld a, [wPlayerDisabledMove]
 and a
 jr z, .enabled
 swap a
 and $f
 ld b, a
 ld a, [wCurrentMenuItem]
 cp b
 jr nz, .enabled
 coord hl, 1, 8
 ld de, MoveInfoDisabled
 call PlaceString
 jp .done
.enabled
 ld hl, wCurrentMenuItem
 dec [hl]
 xor a
 ld [H_WHOSETURN], a
 ld hl, wBattleMonMoves
 ld a, [wCurrentMenuItem]
 ld c, a
 ld b, 0
 add hl, bc
 ld a, [hl]
 ld [wPlayerSelectedMove], a
 ld a, [wPlayerMonNumber]
 ld [wWhichPokemon], a
 ld a, BATTLE_MON_DATA
 ld [wMonDataLocation], a
 callab GetCurrentMove
 callab GetMaxPP
 ld hl, wCurrentMenuItem
 inc [hl]
 coord hl, 1, 7
 ld de, MoveInfoType
 call PlaceString
 coord hl, 1, 8
 predef PrintMoveType
 coord hl, 1, 9
 ld de, MoveInfoPower
 call PlaceString
 ld a, [wPlayerMovePower]
 cp 2 ; 0 = status; 1 = fixed/variable-damage sentinel
 jr c, .noPower
 ld [wcd6d], a
 coord hl, 5, 9
 ld de, wcd6d
 lb bc, 1, 3
 call PrintNumber
 jr .accuracy
.noPower
 coord hl, 5, 9
 ld de, MoveInfoDash
 call PlaceString
.accuracy
 coord hl, 1, 10
 ld de, MoveInfoAccuracy
 call PlaceString
 ; Calculate using the same nature, abilities and stat stages as battle,
 ; then restore the move's original accuracy so selection has no side effect.
 ld a, [wPlayerMoveEffect]
 cp SWIFT_EFFECT
 jr z, .alwaysHits
 ld a, [wPlayerBattleStatus2]
 bit USING_X_ACCURACY, a
 jr z, .noXAccuracy
 ld a, [wPlayerMoveEffect]
 cp OHKO_EFFECT
 jr nz, .alwaysHits
.noXAccuracy
 callab AbilityNoGuardCheck
 ld a, [wAbilityCheckResult]
 and a
 jr nz, .alwaysHits
 ld a, [wPlayerMoveAccuracy]
 push af
 and a
 jr z, .noAccuracy
 callab BankedCalcHitChance
 ld a, [wPlayerMoveAccuracy]
 ld [H_MULTIPLICAND + 2], a
 xor a
 ld [H_MULTIPLICAND], a
 ld [H_MULTIPLICAND + 1], a
 ld a, 100
 ld [H_MULTIPLIER], a
 call Multiply
 ; Round to nearest percentage, rather than truncating 99.6% to 99%.
 ld a, [H_PRODUCT + 3]
 add 127
 ld [H_PRODUCT + 3], a
 ld a, [H_PRODUCT + 2]
 adc 0
 ld [H_PRODUCT + 2], a
 ld a, 255
 ld [H_DIVISOR], a
 ld b, 4
 call Divide
 ld a, [H_QUOTIENT + 3]
 ld [wcd6d], a
 pop af
 ld [wPlayerMoveAccuracy], a
 coord hl, 5, 10
 ld de, wcd6d
 lb bc, 1, 3
 call PrintNumber
 coord hl, 8, 10
 ld [hl], "%"
 jr .pp
.alwaysHits
 ld a, 100
 ld [wcd6d], a
 coord hl, 5, 10
 ld de, wcd6d
 lb bc, 1, 3
 call PrintNumber
 coord hl, 8, 10
 ld [hl], "%"
 jr .pp
.noAccuracy
 pop af
 coord hl, 5, 10
 ld de, MoveInfoDash
 call PlaceString
.pp
 coord hl, 1, 11
 ld de, MoveInfoPP
 call PlaceString
 ld a, [wCurrentMenuItem]
 dec a
 ld c, a
 ld b, 0
 ld hl, wBattleMonPP
 add hl, bc
 ld a, [hl]
 and $3f
 ld [wcd6d], a
 coord hl, 3, 11
 ld de, wcd6d
 lb bc, 1, 2
 call PrintNumber
 coord hl, 5, 11
 ld [hl], "/"
 coord hl, 6, 11
 ld de, wMaxPP
 lb bc, 1, 2
 call PrintNumber
.done
 ld a, 1
 ld [H_AUTOBGTRANSFERENABLED], a
 jp Delay3

MoveInfoType: db "TYPE@"
MoveInfoPower: db "PWR@"
MoveInfoAccuracy: db "ACC@"
MoveInfoPP: db "PP@"
MoveInfoDash: db "--@"
MoveInfoDisabled: db "disabled!@"
