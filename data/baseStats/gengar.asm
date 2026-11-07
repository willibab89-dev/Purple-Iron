db DEX_GENGAR ; pokedex id
db 60 ; base hp
db 65 ; base attack
db 60 ; base defense
db 110 ; base speed
db 130 ; base special
db GHOST ; species type 1
db POISON ; species type 2
db 45 ; catch rate
db 190 ; base exp yield
INCBIN GENGAR_FR,0,1 ; 66, sprite dimensions
dw GengarPicFront
dw GengarPicBack
; attacks known at lvl 0
db LICK
db CONFUSE_RAY
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 1,5,8
	tmlearn 0
	tmlearn 17,18,19,21,24
	tmlearn 25,29,31,32
	tmlearn 35,40
	tmlearn 42,44,46
	tmlearn 50,54
db 0 ; padding
