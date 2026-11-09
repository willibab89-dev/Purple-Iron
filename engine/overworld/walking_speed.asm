SECTION "Passive walking speed", ROMX, BANK[$3c]

; One additional native player movement update per ten ordinary walking
; updates. Defer it at counter 1 so an extra advance can never cross a tile
; boundary and underflow the following mandatory advance. Deferred credit
; is retained. No world frame delay, NPC update or step-event logic changes.
WalkingSpeedBoost:
	ld a, [wUnusedD119]
	cp 1 ; leave the existing B-run / bicycle factors unchanged
	ret nz
	ld a, [wWalkBikeSurfState]
	and a
	ret nz
	ld a, [wWalkCounter]
	and a
	ret z
	ld a, [wd730]
	bit 7, a
	ret nz
	ld a, [wd736]
	and (1 << 6) | (1 << 7)
	ret nz
	ld a, [wNPCMovementScriptPointerTableNum]
	and a
	ret nz
	ld a, [wCurMap]
	cp ROUTE_17 ; the existing bicycle updater has special rules here
	ret z
	ld a, [wWalkSpeedPhase]
	cp 11
	jr c, .valid
	xor a
.valid
	inc a
	ld [wWalkSpeedPhase], a
	cp 10
	ret c
	ld a, [wWalkCounter]
	cp 2
	ret c
	ld a, [wWalkSpeedPhase]
	sub 10
	ld [wWalkSpeedPhase], a
	ld a, 2
	ld [wUnusedD119], a
	ret
