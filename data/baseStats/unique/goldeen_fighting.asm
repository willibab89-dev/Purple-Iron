db DEX_UNIQUE_GOLDEEN_FIGHTING ; pokedex id
db 65 ; base hp
db 95 ; base attack
db 65 ; base defense
db 95 ; base speed
db 60 ; base special
db FIGHTING ; species type 1
db FIGHTING ; species type 2
db 225 ; catch rate
db 111 ; base exp yield
INCBIN "pic/unique/goldeen_fighting.pic",0,1
dw Unique7PicFront
dw Unique7PicBack
; attacks known at lvl 0
db PECK
db TAIL_WHIP
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 7
	tmlearn 9,10,11,12
	tmlearn 17,19
	tmlearn 32
	tmlearn 39,40
	tmlearn 44
	tmlearn 50,53
db 0 ; padding
