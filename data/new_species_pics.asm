SECTION "Four new species graphics and text", ROMX, BANK[$3E]
MareaniePicFront:: INCBIN "pic/new_species/mareanie.pic"
MareaniePicBack:: INCBIN "pic/new_species/mareanie_b.pic"
ToxapexPicFront:: INCBIN "pic/new_species/toxapex.pic"
ToxapexPicBack:: INCBIN "pic/new_species/toxapex_b.pic"
MiltankPicFront:: INCBIN "pic/new_species/miltank.pic"
MiltankPicBack:: INCBIN "pic/new_species/miltank_b.pic"
SableyePicFront:: INCBIN "pic/new_species/sableye.pic"
SableyePicBack:: INCBIN "pic/new_species/sableye_b.pic"

_MareanieDexEntry::
	text "Poisonous spikes"
	next "cover its body."
	next "It hunts among"
	page "coastal rocks and"
	next "grips prey with"
	next "its sharp claws."
	dex

_ToxapexDexEntry::
	text "It forms a shelter"
	next "with its tough"
	next "poisonous limbs."
	page "It waits for prey"
	next "to wander within"
	next "reach of its claws"
	dex

_MiltankDexEntry::
	text "Its rich milk is"
	next "shared with tired"
	next "hungry POKEMON."
	page "A powerful body"
	next "lets it charge and"
	next "defend its herd."
	dex

_SableyeDexEntry::
	text "It searches caves"
	next "for gems to eat."
	next "Its shining eyes"
	page "glitter eerily in"
	next "the darkness when"
	next "it spots a jewel."
	dex
