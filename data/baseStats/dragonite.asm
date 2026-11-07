db DEX_DRAGONITE ; pokedex id
db 91 ; base hp
db 134 ; base attack
db 95 ; base defense
db 80 ; base speed
db 100 ; base special
db DRAGON ; species type 1
db FLYING ; species type 2
db 45 ; catch rate
db 218 ; base exp yield
INCBIN DRAGONITE_FR,0,1 ; 77, sprite dimensions
dw DragonitePicFront
dw DragonitePicBack
; attacks known at lvl 0
db WRAP
db LEER
db THUNDER_WAVE
db 0
db 5 ; growth rate
; learnset
	tmlearn 2,8
	tmlearn 10,11,12,13,14,15
	tmlearn 23,24
	tmlearn 25,32
	tmlearn 33,38,39,40
	tmlearn 44,45
	tmlearn 53,54
db 0 ; padding
