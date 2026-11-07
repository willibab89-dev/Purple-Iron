db DEX_CLOYSTER ; pokedex id
db 50 ; base hp
db 95 ; base attack
db 180 ; base defense
db 70 ; base speed
db 85 ; base special
db WATER ; species type 1
db ICE ; species type 2
db 60 ; catch rate
db 203 ; base exp yield
INCBIN CLOYSTER_FR,0,1 ; 77, sprite dimensions
dw CloysterPicFront
dw CloysterPicBack
; attacks known at lvl 0
db TACKLE
db WITHDRAW
db WATER_GUN
db 0
db 5 ; growth rate
; learnset
	tmlearn 0
	tmlearn 11,12,13,14
	tmlearn 0
	tmlearn 30
	tmlearn 33,34,36,39
	tmlearn 44,47
	tmlearn 49,53
db 0 ; padding
