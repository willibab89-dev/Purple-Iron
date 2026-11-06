db DEX_MAREANIE ; pokedex id
db 50 ; base hp
db 53 ; base attack
db 62 ; base defense
db 45 ; base speed
db 48 ; base special
db POISON ; species type 1
db WATER ; species type 2
db 190 ; catch rate
db 61 ; base exp yield
INCBIN "pic/new_species/mareanie.pic",0,1
dw MareaniePicFront
dw MareaniePicBack
db POISON_STING
db PECK
db 0
db 0
db 0 ; growth rate
	tmlearn 6
	tmlearn 11,12
	tmlearn 0
	tmlearn 0
	tmlearn 34
	tmlearn 44
	tmlearn 50,53
db 0 ; padding
