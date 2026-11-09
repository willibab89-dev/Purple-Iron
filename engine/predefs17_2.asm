; Evolution updates actual low type bits without erasing individual metadata.
SetPartyMonTypes:
	call GetPredefRegisters
	naturecall NatureRefreshEvolvedTypes
	ret
