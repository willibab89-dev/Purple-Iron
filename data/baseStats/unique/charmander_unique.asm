db DEX_UNIQUE_CHARMANDER_UNIQUE ; pokedex id
db 69 ; base hp
db 82 ; base attack
db 73 ; base defense
db 95 ; base speed
db 80 ; base special
db FIRE ; species type 1
db FIRE ; species type 2
db 45 ; catch rate
db 65 ; base exp yield
INCBIN "pic/unique/charmander_unique.pic",0,1
dw Unique4PicFront
dw Unique4PicBack
; attacks known at lvl 0
db SCRATCH
db GROWL
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 32
	tmlearn 38,39
	tmlearn 44
	tmlearn 0
db 0 ; padding
