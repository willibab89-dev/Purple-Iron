db DEX_PUPITAR ; pokedex id
db 70 ; base hp
db 84 ; base attack
db 70 ; base defense
db 51 ; base speed
db 65 ; base special
db GROUND ; species type 1
db GROUND ; species type 2
db 45 ; catch rate
db 144 ; base exp yield
INCBIN "pic/new_species/pupitar.pic",0,1
dw PupitarPicFront
dw PupitarPicBack
db BITE
db LEER
db SAND_ATTACK
db ROCK_THROW
db 5 ; growth rate
	tmlearn 6
	tmlearn 10
	tmlearn 0
	tmlearn 32
	tmlearn 0
	tmlearn 44
	tmlearn 50
db 0 ; padding
