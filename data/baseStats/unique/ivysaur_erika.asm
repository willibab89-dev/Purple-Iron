db DEX_UNIQUE_IVYSAUR_ERIKA ; pokedex id
db 70 ; base hp
db 62 ; base attack
db 85 ; base defense
db 50 ; base speed
db 85 ; base special
db GRASS ; species type 1
db POISON ; species type 2
db 45 ; catch rate
db 141 ; base exp yield
INCBIN "pic/unique/ivysaur_erika.pic",0,1
dw Unique9PicFront
dw Unique9PicBack
; attacks known at lvl 0
db TACKLE
db GROWL
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 6
	tmlearn 0
	tmlearn 21,22
	tmlearn 0
	tmlearn 33
	tmlearn 44
	tmlearn 50,51
db 0 ; padding
