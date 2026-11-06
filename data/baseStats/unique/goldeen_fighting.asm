db DEX_UNIQUE_GOLDEEN_FIGHTING ; pokedex id
db 45 ; base hp
db 67 ; base attack
db 60 ; base defense
db 63 ; base speed
db 50 ; base special
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
	tmlearn 9,11,12,13,14
	tmlearn 0
	tmlearn 0
	tmlearn 39,40
	tmlearn 44
	tmlearn 53
db 0 ; padding
