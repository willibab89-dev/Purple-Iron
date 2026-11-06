db DEX_SABLEYE ; pokedex id
db 50 ; base hp
db 75 ; base attack
db 75 ; base defense
db 50 ; base speed
db 65 ; base special
db GHOST ; species type 1
db GHOST ; species type 2
db 45 ; catch rate
db 133 ; base exp yield
INCBIN "pic/new_species/sableye.pic",0,1
dw SableyePicFront
dw SableyePicBack
db SCRATCH
db LEER
db ASTONISH
db 0
db 3 ; growth rate
	tmlearn 1
	tmlearn 0
	tmlearn 0
	tmlearn 28,31,32
	tmlearn 39
	tmlearn 44,48
	tmlearn 50,54
db 0 ; padding
