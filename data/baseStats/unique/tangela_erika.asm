db DEX_UNIQUE_TANGELA_ERIKA ; pokedex id
db 75 ; base hp
db 95 ; base attack
db 110 ; base defense
db 45 ; base speed
db 75 ; base special
db GRASS ; species type 1
db GRASS ; species type 2
db 45 ; catch rate
db 166 ; base exp yield
INCBIN "pic/unique/tangela_erika.pic",0,1
dw Unique19PicFront
dw Unique19PicBack
; attacks known at lvl 0
db CONSTRICT
db ABSORB
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 8
	tmlearn 0
	tmlearn 21
	tmlearn 0
	tmlearn 33
	tmlearn 44
	tmlearn 50,51
db 0 ; padding
