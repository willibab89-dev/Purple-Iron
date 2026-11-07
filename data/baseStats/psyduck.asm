db DEX_PSYDUCK ; pokedex id
db 50 ; base hp
db 52 ; base attack
db 48 ; base defense
db 55 ; base speed
db 50 ; base special
db WATER ; species type 1
db WATER ; species type 2
db 190 ; catch rate
db 80 ; base exp yield
INCBIN PSYDUCK_FR,0,1 ; 55, sprite dimensions
dw PsyduckPicFront
dw PsyduckPicBack
; attacks known at lvl 0
db SCRATCH
db TAIL_WHIP
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 1,5,8
	tmlearn 11,12,13,14,16
	tmlearn 18
	tmlearn 29
	tmlearn 39
	tmlearn 44
	tmlearn 53,54
db 0 ; padding
