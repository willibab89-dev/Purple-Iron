db DEX_VAPOREON ; pokedex id
db 130 ; base hp
db 65 ; base attack
db 60 ; base defense
db 65 ; base speed
db 110 ; base special
db WATER ; species type 1
db WATER ; species type 2
db 45 ; catch rate
db 196 ; base exp yield
INCBIN VAPOREON_FR,0,1 ; 66, sprite dimensions
dw VaporeonPicFront
dw VaporeonPicBack
; attacks known at lvl 0
db TACKLE
db TAIL_WHIP
db WATER_GUN
db 0
db 0 ; growth rate
; learnset
	tmlearn 8
	tmlearn 10,11,12,13,14
	tmlearn 0
	tmlearn 0
	tmlearn 33,39,40
	tmlearn 44
	tmlearn 53
db 0 ; padding
