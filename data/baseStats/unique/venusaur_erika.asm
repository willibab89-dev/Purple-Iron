db DEX_UNIQUE_VENUSAUR_ERIKA ; pokedex id
db 80 ; base hp
db 82 ; base attack
db 83 ; base defense
db 80 ; base speed
db 100 ; base special
db GRASS ; species type 1
db POISON ; species type 2
db 45 ; catch rate
db 208 ; base exp yield
INCBIN "pic/unique/venusaur_erika.pic",0,1
dw Unique21PicFront
dw Unique21PicBack
; attacks known at lvl 0
db TACKLE
db GROWL
db LEECH_SEED
db VINE_WHIP
db 3 ; growth rate
; learnset
	tmlearn 3,6,8
	tmlearn 15
	tmlearn 21,22
	tmlearn 0
	tmlearn 33
	tmlearn 44
	tmlearn 51
db 0 ; padding
