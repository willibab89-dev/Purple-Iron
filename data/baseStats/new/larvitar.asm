db DEX_LARVITAR ; pokedex id
db 50 ; base hp
db 64 ; base attack
db 50 ; base defense
db 41 ; base speed
db 45 ; base special
db ROCK ; species type 1
db GROUND ; species type 2
db 45 ; catch rate
db 67 ; base exp yield
INCBIN "pic/new_species/larvitar.pic",0,1
dw LarvitarPicFront
dw LarvitarPicBack
; attacks known at lvl 0
db BITE
db LEER
db 0
db 0
db 5 ; growth rate
	tmlearn 0
	tmlearn 10
	tmlearn 0
	tmlearn 26,28,32
	tmlearn 0
	tmlearn 44,48
	tmlearn 50
db 0 ; padding
