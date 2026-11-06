db DEX_HORSEA ; pokedex id
db 30 ; base hp
db 40 ; base attack
db 70 ; base defense
db 60 ; base speed
db 70 ; base special
db WATER ; species type 1
db WATER ; species type 2
db 225 ; catch rate
db 83 ; base exp yield
INCBIN HORSEA_FR,0,1 ; 55, sprite dimensions
dw HorseaPicFront
dw HorseaPicBack
; attacks known at lvl 0
db BUBBLE
db 0
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
