db DEX_UNIQUE_BULBASAUR_UNIQUE ; pokedex id
db 45 ; base hp
db 49 ; base attack
db 49 ; base defense
db 45 ; base speed
db 65 ; base special
db GRASS ; species type 1
db POISON ; species type 2
db 45 ; catch rate
db 64 ; base exp yield
INCBIN "pic/unique/bulbasaur_unique.pic",0,1
dw Unique2PicFront
dw Unique2PicBack
; attacks known at lvl 0
db TACKLE
db GROWL
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 3,6,8
	tmlearn 0
	tmlearn 21,22
	tmlearn 0
	tmlearn 33
	tmlearn 44
	tmlearn 51
db 0 ; padding
