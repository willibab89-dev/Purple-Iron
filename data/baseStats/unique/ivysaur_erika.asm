db DEX_UNIQUE_IVYSAUR_ERIKA ; pokedex id
db 60 ; base hp
db 62 ; base attack
db 63 ; base defense
db 60 ; base speed
db 80 ; base special
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
db LEECH_SEED
db 0
db 3 ; growth rate
; learnset
	tmlearn 3,6,8
	tmlearn 0
	tmlearn 21,22
	tmlearn 0
	tmlearn 33
	tmlearn 44
	tmlearn 51
db 0 ; padding
