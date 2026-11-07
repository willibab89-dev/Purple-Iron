db DEX_HAUNTER ; pokedex id
db 45 ; base hp
db 50 ; base attack
db 45 ; base defense
db 95 ; base speed
db 115 ; base special
db GHOST ; species type 1
db POISON ; species type 2
db 90 ; catch rate
db 126 ; base exp yield
INCBIN HAUNTER_FR,0,1 ; 66, sprite dimensions
dw HaunterPicFront
dw HaunterPicBack
; attacks known at lvl 0
db LICK
db CONFUSE_RAY
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 0
	tmlearn 0
	tmlearn 21,24
	tmlearn 25,29,31,32
	tmlearn 0
	tmlearn 42,44,46
	tmlearn 50
db 0 ; padding
