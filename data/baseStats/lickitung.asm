db DEX_LICKITUNG ; pokedex id
db 100 ; base hp
db 75 ; base attack
db 75 ; base defense
db 30 ; base speed
db 70 ; base special
db NORMAL ; species type 1
db NORMAL ; species type 2
db 45 ; catch rate
db 127 ; base exp yield
INCBIN LICKITUNG_FR,0,1 ; 77, sprite dimensions
dw LickitungPicFront
dw LickitungPicBack
; attacks known at lvl 0
db LICK
db SUPERSONIC
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 1,5,8
	tmlearn 11,12,13,14
	tmlearn 17,18,19,24
	tmlearn 25
	tmlearn 38,40
	tmlearn 44
	tmlearn 51,53,54
db 0 ; padding
