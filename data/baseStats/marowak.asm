db DEX_MAROWAK ; pokedex id
db 70 ; base hp
db 95 ; base attack
db 110 ; base defense
db 45 ; base speed
db 50 ; base special
db GROUND ; species type 1
db GHOST ; species type 2
db 75 ; catch rate
db 124 ; base exp yield
INCBIN MAROWAK_FR,0,1 ; 66, sprite dimensions
dw MarowakPicFront
dw MarowakPicBack
; attacks known at lvl 0
db BONE_CLUB
db GROWL
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 1,5,8
	tmlearn 0
	tmlearn 17,18,19
	tmlearn 28
	tmlearn 34,40
	tmlearn 44
	tmlearn 54
db 0 ; padding
