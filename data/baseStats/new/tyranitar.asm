db DEX_TYRANITAR ; pokedex id
db 100 ; base hp
db 134 ; base attack
db 110 ; base defense
db 61 ; base speed
db 95 ; base special
db GROUND ; species type 1
db DRAGON ; species type 2
db 45 ; catch rate
db 218 ; base exp yield
INCBIN "pic/new_species/tyranitar.pic",0,1
dw TyranitarPicFront
dw TyranitarPicBack
db BITE
db LEER
db ROCK_SLIDE
db THRASH
db 5 ; growth rate
	tmlearn 6
	tmlearn 10
	tmlearn 0
	tmlearn 32
	tmlearn 0
	tmlearn 44
	tmlearn 50
db 0 ; padding
