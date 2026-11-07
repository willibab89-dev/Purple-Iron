db DEX_CLAYDOL ; pokedex id
db 60 ; base hp
db 70 ; base attack
db 105 ; base defense
db 75 ; base speed
db 120 ; base special
db ROCK ; species type 1
db GHOST ; species type 2
db 90 ; catch rate
db 100 ; base exp yield
INCBIN "pic/new_species/claydol.pic",0,1
dw ClaydolPicFront
dw ClaydolPicBack
; attacks known at lvl 0
db CONFUSION
db HARDEN
db ROCK_THROW
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
