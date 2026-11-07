db DEX_PUPITAR ; pokedex id
db 70 ; base hp
db 84 ; base attack
db 70 ; base defense
db 51 ; base speed
db 65 ; base special
db ROCK ; species type 1
db GROUND ; species type 2
db 45 ; catch rate
db 144 ; base exp yield
INCBIN "pic/new_species/pupitar.pic",0,1
dw PupitarPicFront
dw PupitarPicBack
; attacks known at lvl 0
db BITE
db LEER
db SAND_ATTACK
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
