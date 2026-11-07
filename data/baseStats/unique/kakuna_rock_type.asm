db DEX_UNIQUE_KAKUNA_ROCK_TYPE ; pokedex id
db 65 ; base hp
db 45 ; base attack
db 120 ; base defense
db 20 ; base speed
db 50 ; base special
db ROCK ; species type 1
db ROCK ; species type 2
db 120 ; catch rate
db 71 ; base exp yield
INCBIN "pic/unique/kakuna_rock_type.pic",0,1
dw Unique10PicFront
dw Unique10PicBack
; attacks known at lvl 0
db TACKLE
db HARDEN
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 0
	tmlearn 0
	tmlearn 20,21
	tmlearn 0
	tmlearn 33,34
	tmlearn 44,48
	tmlearn 50
db 0 ; padding
