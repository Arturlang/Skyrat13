/mob/living/simple_animal/hostile/faithless/cult
	faction = list("cult")
	var/shuttletarget
	var/enroute = FALSE

/mob/living/simple_animal/hostile/faithless/cult/CanAttack(var/atom/the_target)
	//IF WE ARE CULT MONSTERS (those who spawn after Nar-Sie has risen) THEN WE DON'T ATTACK CULTISTS
	if(ismob(the_target))
		var/mob/M = the_target
		if(isanycultist(M))
			return FALSE
	return ..(the_target)

/mob/living/simple_animal/hostile/faithless/cult/cultify()
	return

/mob/living/simple_animal/hostile/faithless/cult/Life()
	if(timestopped)
		return FALSE //under effects of time magick
	..()
	if(emergency_shuttle.location == 1)
		if(!enroute && !target)	//The shuttle docked, all monsters rush for the escape hallway
			if(!shuttletarget && escape_list.len) //Make sure we didn't already assign it a target, and that there are targets to pick
				shuttletarget = pick(escape_list) //Pick a shuttle target
			enroute = TRUE
			stop_automated_movement = TRUE
/*			spawn()
				if(!src.stat)
					horde()*/

		if(get_dist(src, shuttletarget) <= 2)		//The monster reached the escape hallway
			enroute = FALSE
			stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/faithless/cult/proc/horde()
	var/turf/T = get_step_to(src, shuttletarget)
	for(var/atom/A in T)
		if(istype(A,/obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/D = A
			if(D.density && !D.locked && !D.welded)
				D.open()
		else if(istype(A,/obj/machinery/door/mineral))
			var/obj/machinery/door/D = A
			if(D.density)
				D.open()
		else if(istype(A,/obj/structure/cult_legacy/pylon))
			A.attack_animal(src)
		else if(istype(A, /obj/structure/window) || istype(A, /obj/structure/closet) || istype(A, /obj/structure/table) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/rack))
			A.attack_animal(src)
	Move(T)
	var/new_target = FindTarget()
	GiveTarget(new_target)
	if(!target || enroute)
		spawn(10)
			if(!src.stat)
				horde()
