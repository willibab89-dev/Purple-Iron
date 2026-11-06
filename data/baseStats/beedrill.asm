db DEX_BEEDRILL ; pokedex id
db 65 ; base hp
db 80 ; base attack
db 40 ; base defense
db 75 ; base speed
db 45 ; base special
db BUG ; species type 1
db POISON ; species type 2
db 45 ; catch rate
db 159 ; base exp yield
INCBIN BEEDRILL_FR,0,1 ; 77, sprite dimensions
dw BeedrillPicFront
dw BeedrillPicBack
; attacks known at lvl 0
db POISON_STING
db STRING_SHOT
db HARDEN
db FURY_ATTACK
db 0 ; growth rate
; learnset
	tmlearn 3,6
	tmlearn 15
	tmlearn 21
	tmlearn 32
	tmlearn 33,39,40
	tmlearn 44
	tmlearn 51
db 0 ; padding
