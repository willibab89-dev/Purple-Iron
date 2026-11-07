db DEX_MANKEY ; pokedex id
db 40 ; base hp
db 80 ; base attack
db 35 ; base defense
db 70 ; base speed
db 35 ; base special
db FIGHTING ; species type 1
db FIGHTING ; species type 2
db 190 ; catch rate
db 74 ; base exp yield
INCBIN MANKEY_FR,0,1 ; 55, sprite dimensions
dw MankeyPicFront
dw MankeyPicBack
; attacks known at lvl 0
db SCRATCH
db LEER
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 1,5,8
	tmlearn 10,16
	tmlearn 17,18,19,20
	tmlearn 32
	tmlearn 39,40
	tmlearn 44,48
	tmlearn 54
db 0 ; padding
