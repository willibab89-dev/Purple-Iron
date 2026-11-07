db DEX_SEADRA ; pokedex id
db 65 ; base hp
db 65 ; base attack
db 95 ; base defense
db 85 ; base speed
db 95 ; base special
db WATER ; species type 1
db WATER ; species type 2
db 75 ; catch rate
db 155 ; base exp yield
INCBIN SEADRA_FR,0,1 ; 66, sprite dimensions
dw SeadraPicFront
dw SeadraPicBack
; attacks known at lvl 0
db BUBBLE
db SMOKESCREEN
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 0
	tmlearn 11,12,13,14
	tmlearn 0
	tmlearn 32
	tmlearn 39,40
	tmlearn 44
	tmlearn 53
db 0 ; padding
