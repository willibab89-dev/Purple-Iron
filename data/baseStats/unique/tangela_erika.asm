db DEX_UNIQUE_TANGELA_ERIKA ; pokedex id
db 65 ; base hp
db 55 ; base attack
db 115 ; base defense
db 60 ; base speed
db 100 ; base special
db GRASS ; species type 1
db GRASS ; species type 2
db 45 ; catch rate
db 166 ; base exp yield
INCBIN "pic/unique/tangela_erika.pic",0,1
dw Unique19PicFront
dw Unique19PicBack
; attacks known at lvl 0
db CONSTRICT
db BIND
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 3,8
	tmlearn 15
	tmlearn 21,22
	tmlearn 0
	tmlearn 34,40
	tmlearn 44
	tmlearn 51
db 0 ; padding
