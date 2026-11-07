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
db GROWL
db 0
db 0
db 4 ; growth rate
; learnset
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 31
	tmlearn 33,35
	tmlearn 41,44
	tmlearn 50
db 0 ; padding
