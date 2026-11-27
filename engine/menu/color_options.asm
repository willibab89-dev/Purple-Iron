SECTION "Color scheme options", ROMX, BANK[$3d]

DisplayOptionMenu:
	coord hl, 0, 0
	ld b, 3
	ld c, 18
	call TextBoxBorder
	coord hl, 0, 5
	ld b, 3
	ld c, 18
	call TextBoxBorder
	coord hl, 0, 10
	ld b, 3
	ld c, 18
	call TextBoxBorder
	coord hl, 1, 1
	ld de, TextSpeedOptionText
	call PlaceString
	coord hl, 1, 6
	ld de, BattleAnimationOptionText
	call PlaceString
	coord hl, 1, 11
	ld de, BattleStyleOptionText
	call PlaceString
	coord hl, 2, 16
	ld de, OptionMenuCancelText
	call PlaceString
	call PlaceSoundSetting	;joenote - display the sound setting
	call PlaceColorScheme
	xor a
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	inc a
	ld [wLetterPrintingDelayFlags], a
	ld [wUnusedCD40], a
	ld a, 3 ; text speed cursor Y coordinate
	ld [wTopMenuItemY], a
	call SetCursorPositionsFromOptions
	ld a, [wOptionsTextSpeedCursorX] ; text speed cursor X coordinate
	ld [wTopMenuItemX], a
	ld a, $01
	ld [H_AUTOBGTRANSFERENABLED], a ; enable auto background transfer
	call Delay3
.loop
	call PlaceMenuCursor
	call SetOptionsFromCursorPositions
.getJoypadStateLoop
	call JoypadLowSensitivity
	ld a, [hJoy5]
	ld b, a
	and A_BUTTON | B_BUTTON | START | D_RIGHT | D_LEFT | D_UP | D_DOWN ; any key besides select pressed?
	jp z, .cycleSoundSetting	;joenote - take advantage of pokeyellow sound engine
	;jr z, .getJoypadStateLoop
	bit 1, b ; B button pressed?
	jp nz, .exitMenu
	bit 3, b ; Start button pressed?
	jp nz, .exitMenu
	bit 0, b ; A button pressed?
	jp z, .checkDirectionKeys
 ld a, [wTopMenuItemY]
 cp 16
 jp nz, .loop
.exitMenu
 ld a, SFX_PRESS_AB
 call PlaySound
 ret
.eraseOldMenuCursor
 ld [wTopMenuItemX], a
 call EraseMenuCursor
 jp .loop
.checkDirectionKeys
 ld a, [wTopMenuItemY]
 bit 7, b
 jp nz, .downPressed
 bit 6, b
 jp nz, .upPressed
 cp 8
 jp z, .cursorInBattleAnimation
 cp 13
 jp z, .cursorInBattleStyle
 cp 15
 jp z, .cursorInColor
 cp 16
 jp z, .loop
.cursorInTextSpeed
 bit 5, b
 jp nz, .pressedLeftInTextSpeed
 jp .pressedRightInTextSpeed
.downPressed
 cp 3
 jr z, .downToAnim
 cp 8
 jr z, .downToStyle
 cp 13
 jr z, .downToColor
 cp 15
 jr z, .downToCancel
 ld a, 3
 ld hl, wOptionsTextSpeedCursorX
 jr .updateFromStoredCursor
.downToAnim
 ld a, 8
 ld hl, wOptionsBattleAnimCursorX
 jr .updateFromStoredCursor
.downToStyle
 ld a, 13
 ld hl, wOptionsBattleStyleCursorX
 jr .updateFromStoredCursor
.downToColor
 ld a, 15
 jr .updateColorCursor
.downToCancel
 ld a, 16
 jr .updateFixedCursor
.upPressed
 cp 16
 jr z, .upToColor
 cp 15
 jr z, .upToStyle
 cp 13
 jr z, .upToAnim
 cp 8
 jr z, .upToText
 ld a, 16
 jr .updateFixedCursor
.upToColor
 ld a, 15
 jr .updateColorCursor
.upToStyle
 ld a, 13
 ld hl, wOptionsBattleStyleCursorX
 jr .updateFromStoredCursor
.upToAnim
 ld a, 8
 ld hl, wOptionsBattleAnimCursorX
 jr .updateFromStoredCursor
.upToText
 ld a, 3
 ld hl, wOptionsTextSpeedCursorX
.updateFromStoredCursor
 ld [wTopMenuItemY], a
 ld a, [hl]
 jr .updateCursorX
.updateColorCursor
 ld [wTopMenuItemY], a
 xor a
 jr .updateCursorX
.updateFixedCursor
 ld [wTopMenuItemY], a
 ld a, 1
.updateCursorX
 ld [wTopMenuItemX], a
 call PlaceUnfilledArrowMenuCursor
 jp .loop
.cursorInColor
 ld a, [wColorScheme]
 and $f8
 cp $a0
 ld a, 0
 jr nz, .colorValue
 ld a, [wColorScheme]
 and 7
 cp 7
 jr c, .colorValue
 xor a
.colorValue
 bit 5, b
 jr z, .colorRight
 and a
 jr nz, .colorLeft
 ld a, 7
.colorLeft
 dec a
 jr .colorSave
.colorRight
 inc a
 cp 7
 jr c, .colorSave
 xor a
.colorSave
 or $a0
 ld [wColorScheme], a
 call PlaceColorScheme
 call RunDefaultPaletteCommand
 jp .loop
.cursorInBattleAnimation
	ld a, [wOptionsBattleAnimCursorX] ; battle animation cursor X coordinate
	xor $0b ; toggle between 1 and 10
	ld [wOptionsBattleAnimCursorX], a
	jp .eraseOldMenuCursor
.cursorInBattleStyle
	ld a, [wOptionsBattleStyleCursorX] ; battle style cursor X coordinate
	xor $0b ; toggle between 1 and 10
	ld [wOptionsBattleStyleCursorX], a
	jp .eraseOldMenuCursor
.pressedLeftInTextSpeed
	ld a, [wOptionsTextSpeedCursorX] ; text speed cursor X coordinate
	cp 1
	jr z, .updateTextSpeedXCoord
	cp 7
	jr nz, .fromSlowToMedium
	sub 6
	jr .updateTextSpeedXCoord
.fromSlowToMedium
	sub 7
	jr .updateTextSpeedXCoord
.pressedRightInTextSpeed
	ld a, [wOptionsTextSpeedCursorX] ; text speed cursor X coordinate
	cp 14
	jr z, .updateTextSpeedXCoord
	cp 7
	jr nz, .fromFastToMedium
	add 7
	jr .updateTextSpeedXCoord
.fromFastToMedium
	add 6
.updateTextSpeedXCoord
	ld [wOptionsTextSpeedCursorX], a ; text speed cursor X coordinate
	jp .eraseOldMenuCursor
.cycleSoundSetting	;joenote - cycle through mono, earphone 1, 2, and 3
	ld a, b
	and SELECT
	jp z, .getJoypadStateLoop
	push bc
	ld a, [wOptions]
	push af
	add $10
	and %00110000
	ld b, a
	pop af
	and %11001111
	or b
	pop bc
	ld [wOptions], a
	call PlaceSoundSetting
	jp .getJoypadStateLoop

TextSpeedOptionText:
	db   "TEXT SPEED"
	next " FAST  MEDIUM SLOW@"

BattleAnimationOptionText:
	db   "BATTLE ANIMATION"
	next " ON       OFF@"

BattleStyleOptionText:
	db   "BATTLE STYLE"
	next " SHIFT    SET@"

ColorSchemeText:
 db "COLOR: @"
ColorSchemeNames:
 dw .default, .gray, .sgb, .green, .night, .mononoke, .hollow
.default db "DEFAULT     @"
.gray db "BLACK/WHITE @"
.sgb db "SUPER GB    @"
.green db "GREEN       @"
.night db "NIGHT       @"
.mononoke db "MONONOKE    @"
.hollow db "HOLLOW      @"
PlaceColorScheme:
 coord hl, 1, 15
 ld de, ColorSchemeText
 call PlaceString
 ld a, [wColorScheme]
 and $f8
 cp $a0
 ld a, 0
 jr nz, .index
 ld a, [wColorScheme]
 and 7
 cp 7
 jr c, .index
 xor a
.index
 add a
 ld e, a
 ld d, 0
 ld hl, ColorSchemeNames
 add hl, de
 ld a, [hli]
 ld d, [hl]
 ld e, a
 coord hl, 7, 15
 jp PlaceString

OptionMenuCancelText:
	db "CANCEL@"

;joenote - show the sound setting on the m enu
OptionMenuSoundText:
	dw OptionMenuMono
	dw OptionMenuEar1
	dw OptionMenuEar2
	dw OptionMenuEar3
OptionMenuMono:
	db "MONO     @"
OptionMenuEar1:
	db "EARPHONE1@"
OptionMenuEar2:
	db "EARPHONE2@"
OptionMenuEar3:
	db "EARPHONE3@"
PlaceSoundSetting:
	ld hl, OptionMenuSoundText
	ld a, [wOptions]
	and %00110000
	swap a
.loop
	and a
	jr z, .done
	dec a
	inc hl
	inc hl
	jr .loop
.done
	ld e, [hl]
	inc hl
	ld d, [hl]
	coord hl, 10, 16
	call PlaceString
	ret

; sets the options variable according to the current placement of the menu cursors in the options menu
SetOptionsFromCursorPositions:
	ld hl, TextSpeedOptionData
	ld a, [wOptionsTextSpeedCursorX] ; text speed cursor X coordinate
	ld c, a
.loop
	ld a, [hli]
	cp c
	jr z, .textSpeedMatchFound
	inc hl
	jr .loop
.textSpeedMatchFound
	ld a, [hl]
	ld d, a
	ld a, [wOptionsBattleAnimCursorX] ; battle animation cursor X coordinate
	dec a
	jr z, .battleAnimationOn
.battleAnimationOff
	set 7, d
	jr .checkBattleStyle
.battleAnimationOn
	res 7, d
.checkBattleStyle
	ld a, [wOptionsBattleStyleCursorX] ; battle style cursor X coordinate
	dec a
	jr z, .battleStyleShift
.battleStyleSet
	set 6, d
	jr .storeOptions
.battleStyleShift
	res 6, d
.storeOptions
	ld a, [wOptions]	;joenote - preserve sound settings
	and %00110000
	or d
	;ld a, d
	ld [wOptions], a
	ret

; reads the options variable and places menu cursors in the correct positions within the options menu
SetCursorPositionsFromOptions:
	ld hl, TextSpeedOptionData + 1
	ld a, [wOptions]
	and %11001111	;joenote - bypass sound settings
	ld c, a
	and $3f
	push bc
	ld de, 2
	call IsInArray
	pop bc
	dec hl
	ld a, [hl]
	ld [wOptionsTextSpeedCursorX], a ; text speed cursor X coordinate
	coord hl, 0, 3
	call .placeUnfilledRightArrow
	sla c
	ld a, 1 ; On
	jr nc, .storeBattleAnimationCursorX
	ld a, 10 ; Off
.storeBattleAnimationCursorX
	ld [wOptionsBattleAnimCursorX], a ; battle animation cursor X coordinate
	coord hl, 0, 8
	call .placeUnfilledRightArrow
	sla c
	ld a, 1
	jr nc, .storeBattleStyleCursorX
	ld a, 10
.storeBattleStyleCursorX
	ld [wOptionsBattleStyleCursorX], a ; battle style cursor X coordinate
	coord hl, 0, 13
	call .placeUnfilledRightArrow
; cursor in front of color scheme and Cancel
	coord hl, 0, 15
	ld a, $ec
	ld [hl], a
	coord hl, 0, 16
	ld a, 1
.placeUnfilledRightArrow
	ld e, a
	ld d, 0
	add hl, de
	ld [hl], $ec ; unfilled right arrow menu cursor
	ret

; table that indicates how the 3 text speed options affect frame delays
; Format:
; 00: X coordinate of menu cursor
; 01: delay after printing a letter (in frames)
TextSpeedOptionData:
	db 14,5 ; Slow
	db  7,3 ; Medium
	db  1,1 ; Fast
	db 7 ; default X coordinate (Medium)
	db $ff ; terminator


GetGBCBasePalAddressBanked:
 ld a, [wGBCPal]
 push hl
 ld l, a
 ld h, 0
 add hl, hl
 add hl, hl
 add hl, hl
 ld de, GBCBasePalettes
 ld a, [wColorScheme]
 and $f8
 cp $a0
 jr nz, .indexed
 ld a, [wColorScheme]
 and 7
 jr z, .indexed
 cp 7
 jr z, .indexed
 cp 2
 jr z, .super
 cp 1
 ld de, ColorSchemeGray
 jr z, .fixed
 cp 3
 ld de, ColorSchemeGreen
 jr z, .fixed
 cp 4
 ld de, ColorSchemeNight
 jr z, .fixed
 cp 5
 ld de, ColorSchemeMononoke
 jr z, .fixed
 ld de, ColorSchemeHollow
.fixed
 pop hl
 ret
.super
 ld de, SuperPalettes
.indexed
 add hl, de
 ld d, h
 ld e, l
 pop hl
 ret


; The dedicated EXP palette uses a blue shade in the default GBC scheme.
; The existing resolver maps it to monochrome, green or custom palettes when
; a global color scheme is active, including during background fades.
RefreshEXPBarPalette:
 ld a, PAL_TOWNMAP
 ld [wGBCPal], a
 call GetGBCBasePalAddressBanked
 jpab TransferEXPBarPalette
