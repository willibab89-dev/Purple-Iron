db DEX_UNIQUE_GRIMER_POISON ; pokedex id
db 90 ; base hp
db 90 ; base attack
db 90 ; base defense
db 35 ; base speed
db 60 ; base special
db POISON ; species type 1
db POISON ; species type 2
db 190 ; catch rate
db 90 ; base exp yield
INCBIN "pic/unique/grimer_poison.pic",0,1
dw Unique8PicFront
dw Unique8PicBack
; attacks known at lvl 0
db POUND
db HARDEN
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 6,8
	tmlearn 0
	tmlearn 21
	tmlearn 0
	tmlearn 0
	tmlearn 44
	tmlearn 50
db 0 ; padding
