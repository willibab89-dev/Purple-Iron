db DEX_CROBAT ; pokedex id
db 85 ; base hp
db 90 ; base attack
db 80 ; base defense
db 130 ; base speed
db 80 ; base special
db POISON ; species type 1
db FLYING ; species type 2
db 90 ; catch rate
db 204 ; base exp yield
INCBIN "pic/new_species/crobat.pic",0,1
dw CrobatPicFront
dw CrobatPicBack
db LEECH_LIFE
db SCREECH
db BITE
db CONFUSE_RAY
db 0 ; growth rate
	tmlearn 6
	tmlearn 10
	tmlearn 0
	tmlearn 32
	tmlearn 0
	tmlearn 44
	tmlearn 50
db 0 ; padding
