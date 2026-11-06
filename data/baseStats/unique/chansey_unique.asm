db DEX_UNIQUE_CHANSEY_UNIQUE ; pokedex id
db 250 ; base hp
db 5 ; base attack
db 5 ; base defense
db 50 ; base speed
db 105 ; base special
db NORMAL ; species type 1
db NORMAL ; species type 2
db 30 ; catch rate
db 255 ; base exp yield
INCBIN "pic/unique/chansey_unique.pic",0,1
dw Unique3PicFront
dw Unique3PicBack
; attacks known at lvl 0
db POUND
db DOUBLESLAP
db 0
db 0
db 4 ; growth rate
; learnset
	tmlearn 1,5,8
	tmlearn 11,12,13,14,15
	tmlearn 17,18,19,22,24
	tmlearn 25,29,30,31
	tmlearn 33,34,35,37,38,40
	tmlearn 41,44,45,46
	tmlearn 49,54,55
db 0 ; padding
