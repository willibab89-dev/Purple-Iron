db DEX_FLAREON ; pokedex id
db 65 ; base hp
db 60 ; base attack
db 130 ; base defense
db 65 ; base speed
db 110 ; base special
db FIRE ; species type 1
db FIRE ; species type 2
db 45 ; catch rate
db 198 ; base exp yield
INCBIN FLAREON_FR,0,1 ; 66, sprite dimensions
dw FlareonPicFront
dw FlareonPicBack
; attacks known at lvl 0
db TACKLE
db TAIL_WHIP
db EMBER
db 0
db 0 ; growth rate
; learnset
	tmlearn 8
	tmlearn 10
	tmlearn 0
	tmlearn 0
	tmlearn 33,38,39,40
	tmlearn 44
	tmlearn 0
db 0 ; padding
