db DEX_MR_MIME ; pokedex id
db 50 ; base hp
db 45 ; base attack
db 65 ; base defense
db 90 ; base speed
db 100 ; base special
db PSYCHIC ; species type 1
db PSYCHIC ; species type 2
db 45 ; catch rate
db 136 ; base exp yield
INCBIN MR_MIME_FR,0,1 ; 66, sprite dimensions
dw MrMimePicFront
dw MrMimePicBack
; attacks known at lvl 0
db CONFUSION
db BARRIER
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 8
	tmlearn 0
	tmlearn 18,19,24
	tmlearn 29,30,31
	tmlearn 33,35,40
	tmlearn 44,45,46
	tmlearn 50,55
db 0 ; padding
