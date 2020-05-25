
/mob/living/simple_animal/hostile/bat/cult  //A bat that is hostile, instead of retaliate, and is a bit more buff, otherwise glorious copypasta
	faction = "cult"
	maxHealth = 20
	health = 20
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	name = "space bats"
	desc = "A swarm of cute little blood sucking bats that looks pretty pissed."
	turns_per_move = 1
	blood_volume = 300
	response_help_continuous = "brushes aside"
	response_help_simple = "brush aside"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "hits"
	response_harm_simple = "hit"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_chance = 0
	spacewalk = TRUE
	see_in_dark = 10
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 1)
	pass_flags = PASSTABLE
	faction = list("hostile")
	attack_sound = 'sound/weapons/bite.ogg'
	obj_damage = 5
	environment_smash = ENVIRONMENT_SMASH_NONE
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	movement_type = FLYING
	speak_emote = list("squeaks")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	supernatural = 1
	var/max_co2 = 0 
	var/min_oxy = 0
	var/max_tox = 0
	var/shuttletarget = null
	var/enroute = 0

/mob/living/simple_animal/hostile/bat/

/mob/living/simple_animal/hostile/bat/cult/Found(var/atom/the_target)
	//IF WE ARE CULT MONSTERS (those who spawn after Nar-Sie has risen) THEN WE DON'T ATTACK CULTISTS
	if(ismob(the_target))
		var/mob/M = the_target
		if(isanycultist(M))
			return 0
	return ..(the_target)


/mob/living/simple_animal/hostile/bat/cult/CanAttack(var/atom/the_target)
	//IF WE ARE CULT MONSTERS (those who spawn after Nar-Sie has risen) THEN WE DON'T ATTACK CULTISTS
	if(ismob(the_target))
		var/mob/M = the_target
		if(isanycultist(M))
			return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/bat/cult/cultify()
	return

/mob/living/simple_animal/hostile/bat/cult/Life()
	if(timestopped)
		return 0 //under effects of time magick
	..()
	if(emergency_shuttle.location == 1)
		if(!enroute && !target)	//The shuttle docked, all monsters rush for the escape hallway
			if(!shuttletarget && escape_list.len) //Make sure we didn't already assign it a target, and that there are targets to pick
				shuttletarget = pick(escape_list) //Pick a shuttle target
			enroute = 1
			stop_automated_movement = 1
/*			spawn()
				if(!src.stat)
					horde()*/

		if(get_dist(src, shuttletarget) <= 2)		//The monster reached the escape hallway
			enroute = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/bat/cult/proc/horde()
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
