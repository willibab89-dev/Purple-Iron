db DEX_BALTOY ; pokedex id
db 40 ; base hp
db 40 ; base attack
db 55 ; base defense
db 55 ; base speed
db 55 ; base special
db ROCK ; species type 1
db GHOST ; species type 2
db 90 ; catch rate
db 100 ; base exp yield
INCBIN "pic/new_species/baltoy.pic",0,1
dw BaltoyPicFront
dw BaltoyPicBack
; attacks known at lvl 0
db CONFUSION
db HARDEN
db 0
db 0
db 0 ; growth rate
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 29,30,32
	tmlearn 33
	tmlearn 44
	tmlearn 50
db 0 ; padding
