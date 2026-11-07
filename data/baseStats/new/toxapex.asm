db DEX_TOXAPEX ; pokedex id
db 50 ; base hp
db 63 ; base attack
db 152 ; base defense
db 35 ; base speed
db 100 ; base special
db POISON ; species type 1
db WATER ; species type 2
db 75 ; catch rate
db 173 ; base exp yield
INCBIN "pic/new_species/toxapex.pic",0,1
dw ToxapexPicFront
dw ToxapexPicBack
; attacks known at lvl 0
db POISON_STING
db PECK
db WATER_GUN
db 0
db 0 ; growth rate
	tmlearn 6
	tmlearn 11,12
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 44
	tmlearn 50,53
db 0 ; padding
