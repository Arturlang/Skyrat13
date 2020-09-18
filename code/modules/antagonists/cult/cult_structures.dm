/obj/structure/destructible/cult
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/cult.dmi'
	light_power = 2
	var/cooldowntime = 0
	break_sound = 'sound/hallucinations/veryfar_noise.ogg'
	debris = list(/obj/item/stack/sheet/runed_metal = 1)

/obj/structure/destructible/cult/proc/conceal() //for spells that hide cult presence
	density = FALSE
	visible_message("<span class='danger'>[src] fades away.</span>")
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100 //To help ghosts distinguish hidden runes
	light_range = 0
	light_power = 0
	update_light()
	STOP_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/cult/proc/reveal() //for spells that reveal cult presence
	density = initial(density)
	invisibility = 0
	visible_message("<span class='danger'>[src] suddenly appears!</span>")
	alpha = initial(alpha)
	light_range = initial(light_range)
	light_power = initial(light_power)
	update_light()
	START_PROCESSING(SSfastprocess, src)


/obj/structure/destructible/cult/examine(mob/user)
	. = ..()
	. += "<span class='notice'>\The [src] is [anchored ? "":"not "]secured to the floor.</span>"
	if((iscultist(user) || isobserver(user)) && cooldowntime > world.time)
		. += "<span class='cult italic'>The magic in [src] is too weak, [p_they()] will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>"

/obj/structure/destructible/cult/examine_status(mob/user)
	if(iscultist(user) || isobserver(user))
		var/t_It = p_they(TRUE)
		var/t_is = p_are()
		return "<span class='cult'>[t_It] [t_is] at <b>[round(obj_integrity * 100 / max_integrity)]%</b> stability.</span>"
	return ..()

/obj/structure/destructible/cult/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/hostile/construct/builder))
		if(obj_integrity < max_integrity)
			M.changeNext_move(CLICK_CD_MELEE)
			obj_integrity = min(max_integrity, obj_integrity + 5)
			Beam(M, icon_state="sendbeam", time=4)
			M.visible_message("<span class='danger'>[M] repairs \the <b>[src]</b>.</span>", \
				"<span class='cult'>You repair <b>[src]</b>, leaving [p_they()] at <b>[round(obj_integrity * 100 / max_integrity)]%</b> stability.</span>")
		else
			to_chat(M, "<span class='cult'>You cannot repair [src], as [p_theyre()] undamaged!</span>")
	else
		..()

/obj/structure/destructible/cult/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/melee/cultblade/dagger) && iscultist(user))
		anchored = !anchored
		density = !density
		to_chat(user, "<span class='notice'>You [anchored ? "":"un"]secure \the [src] [anchored ? "to":"from"] the floor.</span>")
		if(!anchored)
			icon_state = "[initial(icon_state)]_off"
		else
			icon_state = initial(icon_state)
	else
		return ..()

/obj/structure/destructible/cult/ratvar_act()
	if(take_damage(rand(25, 50), BURN) && src) //if we still exist
		var/previouscolor = color
		color = "#FAE48C"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/obj/structure/destructible/cult/proc/check_menu(mob/living/user)
	if(!user || user.incapacitated() || !iscultist(user) || !anchored || cooldowntime > world.time)
		return FALSE
	return TRUE

/obj/structure/destructible/cult/talisman
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar'Sie."
	icon_state = "talismanaltar"
	break_message = "<span class='warning'>The altar shatters, leaving only the wailing of the damned!</span>"

	var/static/image/radial_whetstone = image(icon = 'icons/obj/kitchen.dmi', icon_state = "cult_sharpener")
	var/static/image/radial_shell = image(icon = 'icons/obj/wizard.dmi', icon_state = "construct-cult")
	var/static/image/radial_unholy_water = image(icon = 'icons/obj/drinks.dmi', icon_state = "holyflask")

/obj/structure/destructible/cult/talisman/Initialize()
	. = ..()
	radial_unholy_water.color = "#333333"

/obj/structure/destructible/cult/talisman/ui_interact(mob/user)
	. = ..()

	if(!user.canUseTopic(src, TRUE))
		return
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>You're pretty sure you know exactly what this is used for and you can't seem to touch it.</span>")
		return
	if(!anchored)
		to_chat(user, "<span class='cultitalic'>You need to anchor [src] to the floor with your dagger first.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>")
		return

	to_chat(user, "<span class='cultitalic'>You study the schematics etched into the altar...</span>")

	var/list/options = list("Eldritch Whetstone" = radial_whetstone, "Construct Shell" = radial_shell, "Flask of Unholy Water" = radial_unholy_water)
	var/choice = show_radial_menu(user, src, options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)

	var/reward
	switch(choice)
		if("Eldritch Whetstone")
			reward = /obj/item/sharpener/cult
		if("Construct Shell")
			reward = /obj/structure/constructshell
		if("Flask of Unholy Water")
			reward = /obj/item/reagent_containers/glass/beaker/unholywater

	if(!QDELETED(src) && reward && check_menu(user))
		cooldowntime = world.time + 2400
		new reward(get_turf(src))
		to_chat(user, "<span class='cultitalic'>You kneel before the altar and your faith is rewarded with the [choice]!</span>")

/obj/structure/destructible/cult/forge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar'Sie."
	icon_state = "forge"
	light_range = 2
	light_color = LIGHT_COLOR_LAVA
	break_message = "<span class='warning'>The force breaks apart into shards with a howling scream!</span>"

	var/static/image/radial_flagellant = image(icon = 'icons/obj/clothing/suits.dmi', icon_state = "cultrobes")
	var/static/image/radial_shielded = image(icon = 'icons/obj/clothing/suits.dmi', icon_state = "cult_armor")
	var/static/image/radial_mirror = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "mirror_shield")

/obj/structure/destructible/cult/forge/ui_interact(mob/user)
	. = ..()

	if(!user.canUseTopic(src, TRUE))
		return
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>The heat radiating from [src] pushes you back.</span>")
		return
	if(!anchored)
		to_chat(user, "<span class='cultitalic'>You need to anchor [src] to the floor with your dagger first.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cult italic'>The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>")
		return

	to_chat(user, "<span class='cultitalic'>You study the schematics etched into the forge...</span>")


	var/list/options = list("Shielded Robe" = radial_shielded, "Flagellant's Robe" = radial_flagellant, "Mirror Shield" = radial_mirror)
	var/choice = show_radial_menu(user, src, options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)

	var/reward
	switch(choice)
		if("Shielded Robe")
			reward = /obj/item/clothing/suit/hooded/cultrobes/cult_shield
		if("Flagellant's Robe")
			reward = /obj/item/clothing/suit/hooded/cultrobes/berserker
		if("Mirror Shield")
			reward = /obj/item/shield/mirror

	if(!QDELETED(src) && reward && check_menu(user))
		cooldowntime = world.time + 2400
		new reward(get_turf(src))
		to_chat(user, "<span class='cultitalic'>You work the forge as dark knowledge guides your hands, creating the [choice]!</span>")



/obj/structure/destructible/cult/pylon
	name = "pylon"
	desc = "A floating crystal that slowly heals those faithful to Nar'Sie."
	icon_state = "pylon"
	light_range = 1.5
	light_color = LIGHT_COLOR_RED
	break_sound = 'sound/effects/glassbr2.ogg'
	break_message = "<span class='warning'>The blood-red crystal falls to the floor and shatters!</span>"
	var/heal_delay = 25
	var/last_heal = 0
	var/corrupt_delay = 50
	var/last_corrupt = 0

/obj/structure/destructible/cult/pylon/New()
	START_PROCESSING(SSfastprocess, src)
	..()

/obj/structure/destructible/cult/pylon/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/destructible/cult/pylon/process()
	if(!anchored)
		return
	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(5, src))
			if(iscultist(L) || isshade(L) || isconstruct(L))
				if(L.health != L.maxHealth)
					new /obj/effect/temp_visual/heal(get_turf(src), "#960000")
					if(ishuman(L))
						L.adjustBruteLoss(-1, 0)
						L.adjustFireLoss(-1, 0)
						L.updatehealth()
					if(isshade(L) || isconstruct(L))
						var/mob/living/simple_animal/M = L
						if(M.health < M.maxHealth)
							M.adjustHealth(-3)
				if(ishuman(L) && L.blood_volume < (BLOOD_VOLUME_NORMAL * L.blood_ratio))
					L.blood_volume += 1.0
			CHECK_TICK
	if(last_corrupt <= world.time)
		var/list/validturfs = list()
		var/list/cultturfs = list()
		for(var/T in circleviewturfs(src, 5))
			if(istype(T, /turf/open/floor/engine/cult))
				cultturfs |= T
				continue
			var/static/list/blacklisted_pylon_turfs = typecacheof(list(
				/turf/closed,
				/turf/open/floor/engine/cult,
				/turf/open/space,
				/turf/open/lava,
				/turf/open/chasm))
			if(is_type_in_typecache(T, blacklisted_pylon_turfs))
				continue
			else
				validturfs |= T

		last_corrupt = world.time + corrupt_delay

		var/turf/T = safepick(validturfs)
		if(T)
			if(istype(T, /turf/open/floor/plating))
				T.PlaceOnTop(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)
			else
				T.ChangeTurf(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)
		else
			var/turf/open/floor/engine/cult/F = safepick(cultturfs)
			if(F)
				new /obj/effect/temp_visual/cult/turf/floor(F)
			else
				// Are we in space or something? No cult turfs or
				// convertable turfs?
				last_corrupt = world.time + corrupt_delay*2

/obj/structure/destructible/cult/tome
	name = "archives"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	light_range = 1.5
	light_color = LIGHT_COLOR_FIRE
	break_message = "<span class='warning'>The books and tomes of the archives burn into ash as the desk shatters!</span>"

	var/static/image/radial_blindfold = image(icon = 'icons/obj/clothing/glasses.dmi', icon_state = "blindfold")
	var/static/image/radial_curse = image(icon = 'icons/obj/cult.dmi', icon_state ="shuttlecurse")
	var/static/image/radial_veilwalker = image(icon = 'icons/obj/cult.dmi', icon_state ="shifter")

/obj/structure/destructible/cult/tome/ui_interact(mob/user)
	. = ..()

	if(!user.canUseTopic(src, TRUE))
		return
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>These books won't open and it hurts to even try and read the covers.</span>")
		return
	if(!anchored)
		to_chat(user, "<span class='cultitalic'>You need to anchor [src] to the floor with your dagger first.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cult italic'>The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>")
		return

	to_chat(user, "<span class='cultitalic'>You flip through the black pages of the archives...</span>")

	var/list/options = list("Zealot's Blindfold" = radial_blindfold, "Shuttle Curse" = radial_curse, "Veil Walker Set" = radial_veilwalker)
	var/choice = show_radial_menu(user, src, options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)

	var/reward
	switch(choice)
		if("Zealot's Blindfold")
			reward = /obj/item/clothing/glasses/hud/health/night/cultblind
		if("Shuttle Curse")
			reward = /obj/item/shuttle_curse
		if("Veil Walker Set")
			reward = /obj/effect/spawner/bundle/veil_walker
	if(!QDELETED(src) && reward && check_menu(user))
		cooldowntime = world.time + 2400
		new reward(get_turf(src))
		to_chat(user, "<span class='cultitalic'>You summon the [choice] from the archives!</span>")

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                       //Spawned from the Raise Structure rune. Available from the beginning. Trigger progress to ACT I
//      CULT ALTAR       //Allows communication with Nar-Sie for advice and info on the Cult's current objective.
//                       //ACT II : Allows Soulstone crafting, Used to sacrifice the target on the Station
///////////////////////////ACT III : Can plant an empty Soul Blade in it to prompt observers to become the blade's shade
#define ALTARTASK_NONE	0
#define ALTARTASK_GEM	1
#define ALTARTASK_SACRIFICE	2

/obj/structure/destructible/cult/altar
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "altar"
	max_integrity = 100
	layer = TABLE_LAYER
	climbable = TRUE
	obj_flags = CAN_BE_HIT|SHOVABLE_ONTO
	pass_flags = LETPASSTHROW
	var/obj/item/melee/cultblade/blade //Pointer for the inserted cultblade in the altar.
	var/mob/living/buckled_victim //Pointer for the single buckled victim, if there is one
	var/altar_task = ALTARTASK_NONE
	var/gem_delay = 300
	var/datum/progressbar/progbar
	var/mob/summoning_cultist //The cultist trying to summon a shade into his blade
/*
	var/list/watching_mobs = list()
	var/list/watcher_maps = list()
	var/datum/station_holomap/cult/holomap_datum
*/

/obj/structure/destructible/cult/altar/altar/New()
	..()
	flick("[icon_state]-spawn", src)
	//var/image/I = image(icon, "altar_overlay")
	add_overlay("altar_overlay")
	//I.layer = ABOVE_ALL_MOB_LAYER
	//overlays.Add(I)
	for(var/mob/living/carbon/C in loc)
		Crossed(C)
/* Holomaps incompelete
	var/datum/holomap_marker/holomarker = new()
	holomarker.id = HOLOMAP_MARKER_CULT_ALTAR
	holomarker.filter = HOLOMAP_FILTER_CULT
	holomarker.x = src.x
	holomarker.y = src.y
	holomarker.z = src.z
	holomap_markers[HOLOMAP_MARKER_CULT_ALTAR+"_\ref[src]"] = holomarker

	holomap_datum = new
	holomap_datum.initialize_holomap(get_turf(src), cursor_icon = "altar-here")
*/

/obj/structure/destructible/cult/altar/Destroy()
	//stopWatching()
	if(blade)
		if(loc)
			blade.forceMove(loc)
		else
			qdel(blade)
	blade = null
	flick("[icon_state]-break", src)
	//holomap_markers -= HOLOMAP_MARKER_CULT_ALTAR+"_\ref[src]"
	..()

/obj/structure/destructible/cult/altar/attackby(obj/item/I, mob/user)
	if(altar_task)
		return ..()
	if(I.type == /obj/item/melee/cultblade)
		if(blade)
			to_chat(user,"<span class='warning'>You must remove \the [blade] planted into \the [src] first.</span>")
			return TRUE
		var/turf/T = get_turf(user)
		playsound(T, 'sound/weapons/bloodyslice.ogg', 50, TRUE)
		I.forceMove(src)
		blade = I
		update_icon()
		if(!ishuman(buckled_victim))
			buckled_victim.adjustBruteLoss(blade.force)
		if(buckled_victim && buckled_victim.resting)
			buckled_victim.apply_damage(blade.force, BRUTE, BODY_ZONE_CHEST)
			if(buckled_victim == user)
				user.visible_message("<span class='danger'>\The [user] holds \the [I] above their stomach and impales themselves on \the [src]!</span>",
				"<span class='danger'>You hold \the [I] above your stomach and impale yourself on \the [src]!</span>")
			else
				user.visible_message("<span class='danger'>\The [user] holds \the [I] above \the [buckled_victim]'s stomach and impales them on \the [src]!</span>",
				"<span class='danger'>You hold \the [I] above \the [buckled_victim]'s stomach and impale them on \the [src]!</span>")
		else
			to_chat(user, "You plant \the [blade] on top of \the [src]</span>")
			if(istype(blade) && !blade.soulstone.shade)
				var/icon/logo_icon = icon('icons/misc/cult_logo.dmi', "shade-blade")
				for(var/mob/dead/observer/O in GLOB.dead_mob_list)
					if(!O.client || jobban_isbanned(O, ROLE_CULTIST) || O.client.is_afk())
						continue
					if(O?.mind && O.mind.has_antag_datum(/datum/antagonist/cult))
						var/datum/antagonist/cult/cultist = O.mind.has_antag_datum(/datum/antagonist/cult)
						if(cultist.second_chance) //Would use notify_ghosts here if we could manually edit the notify range.
							to_chat(O, "[icon2base64html(logo_icon)]<span class='recruit'>\The [user] has planted a Soul Blade on an altar, \
							 opening a small crack in the veil that allows you to become the blade's resident shade. \
							 s (<a href='?src=\ref[src];signup=\ref[O]'>Possess now!</a>)</span>[icon2base64html(logo_icon)]")
		return TRUE
	if(user.pulling && ismob(user.pulling))
		if(blade)
			to_chat(user,"<span class='warning'>You must remove \the [blade] planted on \the [src] first.</span>")
			return TRUE
		user.pulling.forceMove(src.loc)
		var/mob/living/carbon/human/C = locate() in loc
		user.stop_pulling()
		if(!do_after(user, C, 15))
			return
		if(ishuman(C))
			C.resting = TRUE
		C.forceMove(loc)
		buckle_mob(C)
		to_chat(user, "<span class='warning'>You move \the [C] on top of \the [src]</span>")
		return TRUE
	..()

/obj/structure/destructible/cult/altar/buckle_mob(mob/living/M, force, check_loc)
	. = ..()
	if(buckled_mobs.len < 2)
		buckled_victim = M //All we do here is register the pointer of the victim we buckle,
						   // so we dont need to search for them in the contents. There shouldnt ever be more than one buckled victim.
	
	
/obj/structure/destructible/cult/altar/update_icon()
	icon_state = "altar"
	overlays.len = 0
	if(blade)
		var/image/I
		if(!istype(blade))
			I = image(icon, "altar-cultblade")
		else if(blade.soulstone.shade)
			I = image(icon, "altar-soulblade-full")
		else
			I = image(icon, "altar-soulblade")
		I.layer = ABOVE_ALL_MOB_LAYER
		I.pixel_y = 3
		overlays.Add(I)
	var/image/I = image(icon, "altar_overlay")
	I.layer = ABOVE_ALL_MOB_LAYER
	overlays.Add(I)

	if(obj_integrity < max_integrity/3)
		overlays.Add("altar_damage2")
	else if(obj_integrity < 2* max_integrity /3)
		overlays.Add("altar_damage1")

//We want people on top of the altar to appear slightly higher
/obj/structure/destructible/cult/altar/Crossed(atom/movable/mover)
	if(iscarbon(mover))
		mover.pixel_y += 7 * PIXEL_MULTIPLIER

/obj/structure/destructible/cult/altar/Uncrossed(atom/movable/mover)
	if(iscarbon(mover))
		mover.pixel_y -= 7 * PIXEL_MULTIPLIER

//They're basically the height of regular tables
/obj/structure/destructible/cult/altar/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return TRUE
	if(mover.throwing)
		return TRUE
	if(locate(/obj/structure/table) in get_turf(mover))
		return TRUE
	else
		return !density

/obj/structure/destructible/cult/altar/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovable(caller))
		var/atom/movable/mover = caller
		. = . || (mover.pass_flags & PASSTABLE)

/*
/obj/structure/destructible/cult/altar/proc/checkPosition()
	for(var/mob/M in watching_mobs)
		if(get_dist(src,M) > 1)
			stopWatching(M)

/obj/structure/destructible/cult/altar/proc/stopWatching(mob/user)
	if(!user)
		for(var/mob/M in watching_mobs)
			if(M.client)
				spawn(5)//we give it time to fade out
					M.client.images -= watcher_maps["\ref[M]"]
				//M.callOnFace -= "\ref[src]"
				animate(watcher_maps["\ref[M]"], alpha = 0, time = 5, easing = LINEAR_EASING)

		watching_mobs = list()
	else
		if(user.client)
			spawn(5)//we give it time to fade out
				if(!(user in watching_mobs))
					user.client.images -= watcher_maps["\ref[user]"]
					watcher_maps -= "\ref[user]"
			//user.callOnFace -= "\ref[src]"

			animate(watcher_maps["\ref[user]"], alpha = 0, time = 5, easing = LINEAR_EASING)

			watching_mobs -= user
*/

/obj/structure/destructible/cult/altar/conceal()
	if(blade || altar_task)
		return
	anim(location = loc,target = loc,a_icon = icon, flick_anim = "[icon_state]-conceal")
	for(var/mob/living/carbon/C in loc)
		Uncrossed(C)
	..()

/obj/structure/destructible/cult/altar/reveal()
	flick("[icon_state]-spawn", src)
	..()
	for(var/mob/living/carbon/C in loc)
		Crossed(C)

/obj/structure/destructible/cult/altar/ui_interact(mob/user)
	. = ..()
	if(iscultist(user))
		cultist_act(user)
	else if(is_servant_of_ratvar(user))
		servant_of_ratvar_act(user)
	else
		noncultist_act(user)

/obj/structure/destructible/cult/altar/proc/servant_of_ratvar_act(mob/living/user)
	var/send_dir = get_dir(src, user)
	var/turf/T = get_ranged_target_turf(user, send_dir, 5)
	user.throw_at(T, send_dir, 5) //Yeet the heretic
	user.DefaultCombatKnockdown(user, 10)
	to_chat(user, )

/obj/structure/destructible/cult/altar/proc/cultist_act(mob/user, menu = "default")
	/*if(user in watching_mobs)
		stopWatching(user)
		return
	*/
	/* Contributors are checked during the dance.
		if(altar_task == ALTARTASK_SACRIFICE)
			if(user in contributors)
				return
			//if(!user.checkTattoo(TATTOO_SILENT))
			if(prob(5))
				user.say("Let me show you the dance of my people!","C")
			else
				user.say("Barhah hra zar'garis!","C")
			contributors.Add(user)
		return */ 
	if(blade in src.contents)
		var/choices = list(
			list("Remove Blade", "radial_altar_remove", "Transfer some of your blood to the blade to repair it and refuel its blood level, or you could just slash someone."),
			list("Sacrifice", "radial_altar_sacrifice", "Initiate the sacrifice ritual. The ritual can only proceed if the proper victim has been nailed to the altar."),
			)
		var/task = show_radial_menu(user,loc,choices,'icons/obj/cult_radial3.dmi',"radial-cult2")
		if(!has_buckled_mobs() || !Adjacent(user) || !task)
			return
		switch(task)
			if("Remove Blade")
				if(has_buckled_mobs())
					for(var/U in buckled_mobs)
						if(U != user)
							return
					var/mob/unbuckled = input(src, "Who do you wish to unbuckle?", "Unbuckle Who?") as null|mob in buckled_mobs
					if(do_after(user, src, 20))
						unbuckled.visible_message("<span class='notice'>\The [unbuckled] was freed from \the [src] by \the [user]!</span>", "You were freed from \the [src] by \the [user].")
						user.unbuckle_mob(unbuckled, user)
						if(blade)
							remove_blade(user)
			if("Sacrifice")
				var/datum/antagonist/cult/cult = user.mind.has_antag_datum(/datum/antagonist/cult, TRUE)
				if(cult && cult.cult_team)
					if(buckled_victim)
						if(cult.cult_team.is_sacrifice_target(buckled_victim.mind))
							var/list/contributors = list()
							altar_task = ALTARTASK_SACRIFICE
							update_icon()
							contributors += user
							var/list/things_in_range = range(1, src)
							var/obj/item/toy/plush/narplush/plushsie = locate() in things_in_range //This plushie is an avatar~
							if(istype(plushsie) && plushsie.is_invoker)
								contributors += plushsie
							for(var/mob/living/L in things_in_range)
								if(iscultist(L))
									if(L == user)
										continue
									if(ishuman(L))
										var/mob/living/carbon/human/H = L
										if((HAS_TRAIT(H, TRAIT_MUTE)) || H.silent)
											continue
									if(L.stat)
										continue
								contributors += L
							progbar = new(contributors, 30, src) //TEST IF IT WORKS FOR LIST'S
							var/image/I = image('icons/obj/cult.dmi',"build")
							I.pixel_y = 8
							src.overlays += I
							//if(!user.checkTattoo(TATTOO_SILENT))
							if(prob(1))
								user.say("Let me show you the dance of my people!","C")
							else
								user.say("Barhah hra zar'garis!","C")
							safe_space()
							for(var/mob/M in range(src, 40))
								if(M.z == z && M.client)
									if(get_dist(M, src) <= 20)
										M.playsound_local(src, get_sfx("explosion"), 50, TRUE)
										shake_camera(M, 2, 1)
									else
										M.playsound_local(src, 'sound/effects/explosionfar.ogg', 50, TRUE)
										shake_camera(M, 1, 1)
							spawn()
								dance_start(contributors)
						else
							to_chat(user, "<span class='sinister'>This isn't the One.</span>")

	else if(blade)
		remove_blade(user)
	else
		var/choices = list(
			list("Consult Roster", "radial_altar_roster", "Check the names and status of all of the cult's members."),
			list("Look through Veil", "radial_altar_map", "Check the veil for tears to locate other occult constructions."),
			list("Commune with Nar-Sie", "radial_altar_commune", "Obtain guidance from Nar-Sie to help you complete your objectives."),
			list("Conjure Soul Gem", "radial_altar_gem", "Order the altar to sculpt you a soul shard, to capture the soul of your enemies."),
			)
		var/task = show_radial_menu(user,loc,choices,'icons/obj/cult_radial3.dmi',"radial-cult2")
		if(has_buckled_mobs() || !Adjacent(user) || !task)
			return
		switch(task)
			if("Consult Roster")
				var/datum/antagonist/cult/cult = user.mind.has_antag_datum(/datum/antagonist/cult, TRUE)
				var/datum/team/cult/team = cult.cult_team
				if(!team)
					return
				var/dat = {"<body style="color:#FFFFFF" bgcolor="#110000"><ul>"}
				for(var/mob/living/L in GLOB.player_list)
					var/mob/M = L
					var/conversion = ""
					if(!iscultist(M) && M.stat == DEAD)
						return
					var/datum/antagonist/cult/C = M.mind.has_antag_datum(/datum/antagonist/cult, TRUE)
					if(C.conversion.len > 0)
						conversion = pick(C.conversion)
					var/origin_text = ""
					switch(conversion)
						if("converted")
							origin_text = "Converted by [C.conversion[conversion]]"
						if("resurrected")
							origin_text = "Resurrected by [C.conversion[conversion]]"
						if("soulstone")
							origin_text = "Soul captured by [C.conversion[conversion]]"
						if("altar")
							origin_text = "Volunteer shade"
						if("sacrifice")
							origin_text = "Sacrifice"
						else
							origin_text = "Founder"
					var/mob/living/carbon/H = C
					var/extra = ""
					if(H && istype(H))
						if(H.health < HEALTH_THRESHOLD_CRIT && H.health > HEALTH_THRESHOLD_DEAD)
							extra = " - <span style='color:#FF0000'>CRITICAL</span>"
						else if(H.health < HEALTH_THRESHOLD_DEAD)
							extra = " - <span style='color:#FF0000'>DEAD</span>"
					dat += "<li><b>[M.name]</b></li> - [origin_text][extra]"
				dat += {"</ul></body>"}
				user << browse("<TITLE>Cult Roster</TITLE>[dat]", "window=cultroster;size=500x300")
				onclose(user, "cultroster")
			/*if ("Look through Veil")
				if(user.hud_used && user.hud_used.holomap_obj)
					if(!("\ref[user]" in watcher_maps))
						var/image/personnal_I = prepare_cult_holomap()
						var/turf/T = get_turf(src)
						if(map.holomap_offset_x.len >= T.z)
							holomap_datum.cursor.pixel_x = (T.x-8+map.holomap_offset_x[T.z]) * PIXEL_MULTIPLIER
							holomap_datum.cursor.pixel_y = (T.y-8+map.holomap_offset_y[T.z]) * PIXEL_MULTIPLIER
						else
							holomap_datum.cursor.pixel_x = (T.x-8) * PIXEL_MULTIPLIER
							holomap_datum.cursor.pixel_y = (T.y-8) * PIXEL_MULTIPLIER
						if(T.z == STATION_Z)
							personnal_I.overlays += holomap_datum.cursor
						watcher_maps["\ref[user]"] = personnal_I
					var/image/I = watcher_maps["\ref[user]"]
					I.loc = user.hud_used.holomap_obj
					I.alpha = 0
					animate(watcher_maps["\ref[user]"], alpha = 255, time = 5, easing = LINEAR_EASING)
					watching_mobs |= user
					user.client.images |= watcher_maps["\ref[user]"]
					user.callOnFace["\ref[src]"] = "checkPosition"
			if("Commune with Nar-Sie")
				switch(GLOB.veil_thickness)
					if(CULT_MENDED)
						to_chat(user, "...nothing but silence...")
					if(CULT_PROLOGUE)
						to_chat(user, "<span class='game say'><span class='danger'>Nar-Sie</span> murmurs, <span class='sinister'>How interesting...</span></span>")
					if(CULT_ACT_I)
						to_chat(user, "<span class='game say'><span class='danger'>Nar-Sie</span> murmurs, <span class='sinister'>The conversion rune is <span class='danger'>Join Blood Self</span>, but you now have many new runes at your disposal to help you in your task, therefore I recommend you first summon an Arcane Tome to easily scribe them. The rune that conjures a tome is <span class='danger'>See Blood Hell</span>.</span></span>")
					if(CULT_ACT_II)
						var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
						if(cult)
							var/datum/objective/bloodcult_sacrifice/O = locate() in cult.objective_holder.objectives
							if(O && !O.IsFulfilled())
								if(!O.sacrifice_target || !O.sacrifice_target.loc)//if there's no target or its body was destroyed, immediate reroll
									replace_target()
									return
								else
									var/turf/T = get_turf(O.sacrifice_target)
									var/datum/shuttle/S = is_on_shuttle(T)
									if((T.z == CENTCOMM_Z) && (emergency_shuttle.shuttle == S || emergency_shuttle.escape_pods.Find(S)))
										to_chat(user,"<b>\The [O.sacrifice_target] has fled the station along with the rest of the crew. Unless we can bring them back in time with a Path rune or sacrifice him where he stands, it's over.</b>")
										return
									else if(T.z != STATION_Z)//if the target fled the station, offer to reroll the target. May or not add penalties for that later.
										var/choice = alert(user,"The target has fled the station, do you wish for another sacrifice target to be selected?","[name]","Yes","No")
										if(choice == "Yes")
											replace_target(user)
											return
									else
										to_chat(user,"<b>\The [O.sacrifice_target] is in [get_area_name(O, 1)].</b>")
										
						to_chat(user, "<span class='game say'><span class='danger'>Nar-Sie</span> murmurs, <span class='sinister'>To perform the sacrifice, you'll have to forge a cult blade first. It doesn't matter if the target is alive of not, lay their body down on the altar and plant the blade on their stomach. Next, touch the altar to perform the next step of the ritual. The more of you, the quicker it will be done.</span></span>")
					if(CULT_ACT_III)
						to_chat(user, "<span class='game say'><span class='danger'>Nar-Sie</span> murmurs, <span class='sinister'>The crew is now aware of our presence, prepare to draw blood. Your priority is to spill as much blood as you can all over the station, bloody trails left by foot steps count toward this goal. How you obtain the blood, I leave to your ambition, but remember that if the crew destroys every blood stones, you will be doomed.</span></span>")
					if(CULT_ACT_IV)
						to_chat(user, "<span class='game say'><span class='danger'>Nar-Sie</span> murmurs, <span class='sinister'>One of the blood stones has become my anchor in this plane, you can touch any other stone to locate it. Touch the anchor to perform the Tear Reality ritual before the crew breaks it.</span></span>")
					if(CULT_EPILOGUE)
						to_chat(user, "<span class='game say'><span class='danger'>Nar-Sie</span> murmurs, <span class='sinister'>Remarkable work, [user.real_name], I greatly enjoyed observing this game. Your work is over now, but I may have more in store for you in the future. In the meanwhile, bask in your victory.</span></span>")
				/* TODO: I'll finish that up someday
				var/dat = {"<body style="color:#FFFFFF" bgcolor="#110000"><ul>"}
				dat += {"</ul></body>"}
				user << browse("<TITLE>Nar-Sie's Tips</TITLE>[dat]", "window=narsietips;size=500x300")
				onclose(user, "narsietips")
				*/ */
			if("Conjure Soul Gem")
				altar_task = ALTARTASK_GEM
				update_icon()
				overlays += "altar-soulstone1"
				spawn(gem_delay / 3)
					update_icon()
					overlays += "altar-soulstone2"
					sleep (gem_delay/3)
					update_icon()
					overlays += "altar-soulstone3"
					sleep (gem_delay/3)
					altar_task = ALTARTASK_NONE
					update_icon()
					var/obj/item/soulstone/gem = new(loc)  //TODO PORT SOULGEM AND ITS CONSTRUCTS
					gem.pixel_y = 4
/*
/obj/structure/destructible/cult/altar/proc/replace_target(mob/user)
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if(cult)
		var/datum/objective/bloodcult_sacrifice/O = locate() in cult.objective_holder.objectives
		if(O && !O.IsFulfilled())
			if(O.replace_target(user))
				for(var/datum/role/cultist/C in cult.members)
					var/mob/M = C.antag.current
					if(M && iscultist(M))
						to_chat(M,"<b>A new target has been assigned. [O.explanation_text]</b>")
						if(M == O.sacrifice_target)
							to_chat(M,"<b>There is no greater honor than purposefuly relinquishing your body for the coming of Nar-Sie.</b>")
						to_chat(M,"<b>Should the target's body be annihilated, or should they flee the station, you may commune with Nar-Sie at an altar to have him designate a new target.</b>")
			else
				for(var/datum/role/cultist/C in cult.members)
					var/mob/M = C.antag.current
					if(M && iscultist(M))
						to_chat(M,"<b>There are no elligible targets aboard the station, how did you guys even manage that one?</b>")//if there's literally no humans aboard the station
						to_chat(M,"<b>There needs to be humans aboard the station, cultist or not, for a target to be selected.</b>")
*/
/obj/structure/destructible/cult/altar/proc/noncultist_act(mob/user)//Non-cultists can still remove blades planted on altars.
	if(has_buckled_mobs())
		for(var/U in buckled_mobs)
			if(U != user)
				return
			var/mob/unbuckled = input(src, "Who do you wish to unbuckle?", "Unbuckle Who?") as null|mob in buckled_mobs
			if(do_after(user, src, 20))
				unbuckled.visible_message("<span class='notice'>\The [unbuckled] was freed from \the [src] by \the [user]!</span>", "You were freed from \the [src] by \the [user].")
				user.unbuckle_mob(unbuckled, user)
				if(blade)
					remove_blade(user)
	else if(blade)
		remove_blade(user)
	else
		to_chat(user,"<span class='sinister'>You feel madness taking its toll, trying to figure out \the [name]'s purpose.</span>")
	return TRUE

/obj/structure/destructible/cult/altar/proc/remove_blade(mob/user)
	if(!user.canUseTopic(src, TRUE, TRUE, TRUE))
		return
	if(!user.put_in_active_hand(blade))
		user.put_in_hands(blade)
	else
		blade.forceMove(loc)
	blade.attack_hand(user)
	to_chat(user, "You remove \the [blade] from \the [src]</span>")
	blade = null
	playsound(loc, 'sound/weapons/blade1.ogg', 50, TRUE)
	update_icon()
	if(summoning_cultist)
		summoning_cultist = null

/obj/structure/destructible/cult/altar/Topic(href, href_list)
	if(href_list["signup"])
		var/mob/M = usr
		if(!isobserver(M) || !iscultist(M))
			return
		var/mob/dead/observer/O = M
		var/obj/item/melee/cultblade/blade = locate() in src
		if(!istype(blade))
			to_chat(usr, "<span class='warning'>The blade was removed from \the [src].</span>")
			return
		if(blade.soulstone.shade)
			to_chat(usr, "<span class='warning'>Another shade was faster, and is currently possessing \the [blade].</span>")
			return
		var/datum/antagonist/cult/cultist = M.mind.has_antag_datum(/datum/antagonist/cult, TRUE)
		cultist.second_chance = 0 //Thats our second chance, used.
		blade.soulstone.init_shade(O, cultist)


/obj/structure/destructible/cult/altar/proc/dance_start(list/dancers)//This is executed at the end of the sacrifice ritual
	//var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	//if (cult)
	//	cult.change_cooldown = max(cult.change_cooldown,60 SECONDS)
	var/mob/living/F = dancers[1]
	var/datum/antagonist/cult/C = F.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	altar_task = ALTARTASK_NONE
	update_icon()
	if(!buckled_victim)
		return
	if((((ishuman(buckled_victim) || iscyborg(buckled_victim)) && buckled_victim.stat != DEAD) || C.cult_team.is_sacrifice_target(buckled_victim.mind)))
		for(var/M in dancers)
			to_chat(M, "<span class='cult italic'>[buckled_victim] is too greatly linked to the world! You need three acolytes!</span>")
		log_game("Sacrifice ritual failed - not enough acolytes or target is alive.")
		return FALSE
	if(buckled_victim.mind)
		GLOB.sacrificed += buckled_victim.mind
		for(var/datum/objective/sacrifice/sac_objective in C.cult_team.objectives)
			if(sac_objective.target == buckled_victim.mind)
				sac_objective.sacced = TRUE
				sac_objective.update_explanation_text()
	else
		GLOB.sacrificed += buckled_victim

	new /obj/effect/temp_visual/cult/sac(get_turf(src))

	var/obj/item/soulstone/stone = new /obj/item/soulstone(get_turf(src))
	if(buckled_victim.mind && !buckled_victim.suiciding)
		stone.invisibility = INVISIBILITY_MAXIMUM //so it's not picked up during transfer_soul()
		stone.transfer_soul("FORCE", buckled_victim, usr)
		stone.invisibility = 0

	if(buckled_victim)
		if(iscyborg(buckled_victim))
			playsound(buckled_victim, 'sound/magic/disable_tech.ogg', 100, TRUE)
			var/mob/living/silicon/robot/bot = buckled_victim
			bot.deconstruct()
		else
			playsound(buckled_victim, 'sound/magic/disintegrate.ogg', 100, TRUE)
			var/mob/living/carbon/human/H = buckled_victim
			H.spew_organ(2, 6)
	return TRUE

#undef ALTARTASK_NONE
#undef ALTARTASK_GEM
#undef ALTARTASK_SACRIFICE

/obj/structure/destructible/cult/altar/proc/safe_space()
	for(var/turf/T in range(5, src))
		var/dist = cheap_pythag(T.x - src.x, T.y - src.y)
		if(dist <= 2.5)
			T.ChangeTurf(/turf/open/floor/engine/cult)
			new /obj/effect/temp_visual/cult/turf/floor(T)
			for(var/obj/structure/S in T)
				if(!istype(S, /obj/structure/destructible/cult/))
					qdel(S)
			for(var/obj/machinery/M in T)
				qdel(M)
		else if(dist <= 4.5)
			if(istype(T,  /turf/open/space))
				T.ChangeTurf(/turf/open/floor/engine/cult)
				new /obj/effect/temp_visual/cult/turf/floor(T)
			else
				T.narsie_act(ignore_mobs = TRUE)
		else if(dist <= 5.5)
			if(istype(T, /turf/open/space))
				T.ChangeTurf(/turf/open/floor/engine/cult)
				new /obj/effect/temp_visual/cult/turf/floor(T)
			else
				T.narsie_act(ignore_mobs = TRUE)

/obj/effect/spawner/bundle/veil_walker
	items = list(/obj/item/cult_shift, /obj/item/flashlight/flare/culttorch)

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = TRUE
	anchored = TRUE

/obj/effect/gateway/singularity_act()
	return

/obj/effect/gateway/singularity_pull()
	return
