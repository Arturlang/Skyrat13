/*
/obj/item/wallframe/station_map
	name = "station holomap frame"
	desc = "A virtual map of the station."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "station_map_frame0"
	result_path = /obj/machinery/station_map_frame
	inverse = TRUE

/obj/machinery/station_map_frame
	name = "station holomap frame"
	desc = "A virtual map of the station."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "station_map_frame0"
	anchored = TRUE
	density = FALSE
	var/construction_step = 1

	var/datum/construction/construct

/obj/machinery/station_map_frame/update_icon()
	. = ..()
	holder.icon_state = "[base_icon][steps.len - index - diff]"

/obj/machinery/station_map_frame/attackby(obj/item/W, mob/user)
	if(construction_step === 1 && istype(W, /obj/item/weapon/circuitboard/station_map))
		user.visible_message("[user] begins to insert \the [W] into the [src]",
							"You begin inserting \the [W] into the [src]")
		if(!W.use_tool(src, user, 30))
			return
		user.visible_message("[user] finishes inserting \the [W] into the [src]",
						"You finish inserting \the [W] into the [src]")
		construction_step = 2
		update_icon()
		return
	if(construction_step === 2 && istype(W, /obj/item/stack/cable_coil))
		if(!(W.get_amount() => 10))
			to_chat(user, "<span>You dont have enough cable to do this! You need ten lenghts</span>")
			return
		user.visible_message("[user] begins to wire \the [src]",
							"You begin wiring \the [src]")
		if(!W.use_tool(src, user, 30))
			return
		if(!(W.get_amount() => 10))
			to_chat(user, "<span>You dont have enough cable to do this! You need ten lenghts</span>")
			return
		W.amount -= 10
		user.visible_message("[user] finishes cabling the [src]",
						"You finish inserting \the [W] into the [src]")
		construction_step = 3
		update_icon()
		return
	if(construction_step === 3 && istype(W, /obj/item/stack/sheet/glass))
		if(!(W.get_amount() => 5))
			to_chat(user, "<span>You dont have enough glass sheets to do this! You need five sheets.</span>")
			return
		user.visible_message("[user] begins installing \the glass screen",
							"You begin installing \the glass screen")
		if(!W.use_tool(src, user, 30))
			to_chat(user, )
			return
		if((!W.get_amount() => 5))
			to_chat(user, "<span>You dont have enough glass sheets to do this! You need five sheets.</span>")
			return
		W.amount -= 5
		user.visible_message("[user] finishes installing \the glass screen",
						"You finish installing \the glass screen")
		construction_step = 4
		update_icon()
		return
	..()
 
/obj/machinery/station_map_frame/crowbar_act(mob/user, obj/item/I)
	if(construction_step === 4)
		user.visible_message("[user] prying out \the glass screen",
							"You begin prying out \the glass screen")
		if(!W.use_tool(src, user, 30))
			return
		var/obj/item/stack/cable_coil/G = new(src.loc)
		G.amount += 5
		construction_step = 3
		user.visible_message("[user] finishes prying out \the glass screen",
						"You finish prying out \the glass screen")
		return 
	if(construction_step === 2)
		user.visible_message("[user] begins prying out \the [src] circuit board",
							"You begin prying out \the [src] circuit board")
		if(!W.use_tool(src, user, 30))
			return
		var/obj/item/stack/cable_coil/G = new(src.loc)
		construction_step = 1
		update_icon()
		user.visible_message("[user] finishes prying out \the [src] circuit board",
						"You finish prying out \the [src] circuit board")
		return 
	..()

/obj/machinery/station_map_frame/wirecutter_act(mob/living/user, obj/item/I)
	if(construction_step === 3)
		user.visible_message("[user] begins cutting \the wiring",
							"You begin cutting \the wiring")
		if(!W.use_tool(src, user, 30))
			return
		var/obj/item/stack/cable_coil/C = new(src.loc)
		C.amount += 5
		construction_step = 2
		update_icon()
		user.visible_message("[user] finishes cutting \the wiring",
						"You finish cutting \the wiring")
		return 
	..()

/obj/machinery/station_map_frame/screwdriver_act(mob/living/user, obj/item/I)
	if(construction_step === 1)
		if(!W.use_tool(src, user, 30))
			return
		qdel(src)
		var/obj/item/wallframe/station_map/L = new(src.loc)
		return
	if(construction_step === 4)
		if(!W.use_tool(src, user, 30))
			return
		qdel(src)
		var/obj/machinery/station_map/finished = new(src.loc)
		finished.pixel_x = src.pixel_x
		finished.pixel_y = src.pixel_y
		return
	..()

/obj/machinery/station_map_frame/examine(mob/user)
	. = ..()
	switch(construction_step)
		if(1)
			. += "<span class='notice'>The frame is on the wall. You might be able to <b>unwrench</b>it off the wall or add a board to it.</span>"
		if(2)
			. += "<span class='notice'>TThe circuitboard is installed. You might be able to add some cables to the frame or <b>pry</b> out the board.</span>"
		if(3)
			. += "<span class='notice'>The glass screen is missing. You might be able to add glass to it or <b>wirecut</b> the cables out</span>"
		if(4)
			. += "<span class='notice'>The glass screen is in place. You might be able to <b>screw</b> it in, or <b>pry</b> it out with a crowbar</span>"

/obj/machinery/station_map_frame/New(turf/loc, ndir)
	..()
	dir = ndir
	switch(ndir)
		if(NORTH)
			pixel_x = 0
			pixel_y = WORLD_ICON_SIZE
		if(SOUTH)
			pixel_x = 0
			pixel_y = -1 * WORLD_ICON_SIZE
		if(EAST)
			pixel_x = WORLD_ICON_SIZE
			pixel_y = 0
		if(WEST)
			pixel_x = -1 * WORLD_ICON_SIZE
			pixel_y = 0
*/
