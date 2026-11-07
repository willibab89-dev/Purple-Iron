db DEX_SABLEYE ; pokedex id
db 50 ; base hp
db 85 ; base attack
db 125 ; base defense
db 20 ; base speed
db 85 ; base special
db GHOST ; species type 1
db GHOST ; species type 2
db 45 ; catch rate
db 133 ; base exp yield
INCBIN "pic/new_species/sableye.pic",0,1
dw SableyePicFront
dw SableyePicBack
; attacks known at lvl 0
db SCRATCH
db LEER
db SNARL
db 0
db 3 ; growth rate
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 28,31,32
	tmlearn 39
	tmlearn 44
	tmlearn 50,54
db 0 ; padding
