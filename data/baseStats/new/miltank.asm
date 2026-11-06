db DEX_MILTANK ; pokedex id
db 95 ; base hp
db 80 ; base attack
db 105 ; base defense
db 100 ; base speed
db 55 ; base special
db NORMAL ; species type 1
db NORMAL ; species type 2
db 45 ; catch rate
db 172 ; base exp yield
INCBIN "pic/new_species/miltank.pic",0,1
dw MiltankPicFront
dw MiltankPicBack
db TACKLE
db GROWL
db DEFENSE_CURL
db 0
db 5 ; growth rate
	tmlearn 1,5,8
	tmlearn 9,10,15
	tmlearn 20
	tmlearn 26,32
	tmlearn 34,40
	tmlearn 44,48
	tmlearn 54
db 0 ; padding
