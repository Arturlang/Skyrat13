///////////////////////////////////
//////////Autolathe Designs ///////
///////////////////////////////////

/////////////
////Secgear//
/////////////

/datum/design/c9mmrubber
	name = "9mm Rubber Box"
	id = "9mm_rubber"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 30000)
	build_path = /obj/item/ammo_box/c9mm/rubber
	category = list("initial", "Security")

/datum/design/autolathe/circuit/station_map
	name = "Station Map Circuit Board"
	id = "station_map"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 3000)
	category = list("initial", "Electronics")
