/obj/item/tome
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister-looking cover."
	icon_state ="tome"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tome/traitor
	var/spent = FALSE

/obj/item/tome/traitor/check_uplink_validity()
	return !spent

/obj/item/tome/traitor/attack_self(mob/living/user)
	if(!iscultist(user) && !spent)
		to_chat(user, "<span class='userdanger'>You press your hand onto [src], sinister tendrils of corrupted magic swirling around you. Was this the best of ideas?</span>")
		if(user.mind.add_antag_datum(/datum/antagonist/cult/neutered/traitor))
			spent = TRUE
		else
			to_chat(user, "<span class='userdanger'>[src] falls dark. It appears you weren't worthy.</span>")
	return ..()

/obj/item/melee/cultblade/dagger
	name = "ritual dagger"
	desc = "A strange dagger said to be used by sinister groups for \"preparing\" a corpse before sacrificing it to their dark gods."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "cultdagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	w_class = WEIGHT_CLASS_SMALL
	force = 15
	throwforce = 25
	armour_penetration = 35
	actions_types = list(/datum/action/item_action/cult_dagger)

/obj/item/melee/cultblade/dagger/Initialize()
	. = ..()
	var/image/I = image(icon = 'icons/effects/blood.dmi' , icon_state = null, loc = src)
	I.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_dagger", I)

/obj/item/melee/cultblade
	name = "eldritch longsword"
	desc = "A sword humming with unholy energy. It glows with a dim red light."
	icon_state = "cultblade"
	item_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	sharpness = IS_SHARP
	w_class = WEIGHT_CLASS_BULKY
	force = 30
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "rended")
	var/obj/item/soulstone/soulstone

/obj/item/melee/cultblade/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 40, 100)
	AddElement(/datum/element/sword_point)

/obj/item/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!iscultist(user))
		punish_user(user, target)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(rand(force/2, force), BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		else
			user.adjustBruteLoss(rand(force/2,force))
		return
	..()

/obj/item/melee/cultblade/proc/punish_user(target, victim)
	var/pushed_away_from = src
	target.DefaultCombatKnockdown(100)
	target.dropItemToGround(src, TRUE)
	if(victim)
		pushed_away_from = victim
	target.visible_message("<span class='warning'>A powerful force shoves [target] away from [pushed_away_from]!</span>", \
							"<span class='cultlarge'>\"You shouldn't play with sharp things. You'll poke someone's eye out.\"</span>")

/obj/item/melee/cultblade/attackby(obj/item/I, mob/living/user, params)
	if(iscultist(user))
		punish_user(user)
		return
	if(istype(/obj/item/soulstone) && !soulstone)
		to_chat(user, "<span class='notice'You insert the soul shard into the pommel of the sword.</span>")
		soulstone = I
		I.forceMove(src)
		return
	if(soulstone)
		to_chat(user, "<span class='notice'There is no room for two soulstones in the sword.</span>")
		return
	. = ..()

/obj/item/melee/cultblade/AltClick(mob/living/carbon/user)
	if(!soulstone)
		return
	if(!iscultist(user))
		punish_user(user)
		return
	if(user.get_empty_held_indexes())
		user.put_in_hands(soulstone)
		to_chat(user, "<span class='notice'You remove the soulstone from the sword's pommel.</span>")
		soulstone = null
		return
	else
		to_chat(user, "<span class='warning'You need a empty hand to remove the soulstone!</span>")
	. = ..()
		
///////////////////////////////////////CULT BLADE////////////////////////////////////////////////
/*
/obj/item/melee/cultblade/cultblade
	name = "cult blade"
	icon = 'icons/obj/cult_64x64.dmi'
	desc = "An arcane weapon wielded by the followers of Nar-Sie. It features a nice round socket at the base of its obsidian blade."
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	icon_state = "cultblade"
	item_state = "cultblade"
	force = 30
	throwforce = 10
	integrity_failure = 50
	max_integrity = 100
	hitsound = "sound/weapons/bladeslice.ogg"
	var/checkcult = TRUE

/obj/item/melee/cultblade/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!checkcult)
		return ..()
	if(iscultist(user))
		if(ishuman(target) && target.resting)
			var/obj/structure/cult/altar/altar = locate() in target.loc
			if(altar)
				altar.attackby(src,user)
				return
			else
				return ..()
		else
			return ..()
	else
		user.Stun(5)
		to_chat(user, "<span class='warning'>An unexplicable force powerfully repels \the [src] from [target]!</span>")
		if(user.active_hand_index == 1)
			user.apply_damage((rand(force / 2, force)), BRUTE, BODY_ZONE_L_ARM)
		else
			user.apply_damage(rand(force / 2, force), BRUTE, BODY_ZONE_R_ARM)

/obj/item/melee/cultblade/cultblade/pickup(mob/living/user)
	if(checkcult && !iscultist(user))
		to_chat(user, "<span class='warning'>An overwhelming feeling of dread comes over you as you pick up \the [src]. It would be wise to rid yourself of this, quickly.</span>")
		user.Dizzy(120)

/obj/item/melee/cultblade/cultblade/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/paper))
		fire_act(I)
		return TRUE
	if(istype(I, /obj/item/soulstone/gem))
		if(user.get_inactive_held_item() != src)
			to_chat(user,"<span class='warning'>You must hold \the [src] in your hand to properly place \the [I] in its socket.</span>")
			return TRUE
		var/turf/T = get_turf(user)
		playsound(T, 'sound/items/Deconstruct.ogg', 50, TRUE)
		user.dropItemToGround(src)
		var/obj/item/melee/cultblade/soulblade/SB = new (T)
		if(fingerprints)
			SB.fingerprints = fingerprints.Copy()
		spawn(1)
			user.put_in_active_hand(SB)
		for(var/mob/living/simple_animal/shade/A in I)
			A.forceMove(SB)
			SB.shade = A
			A.give_blade_powers()
			break
		SB.update_icon()
		qdel(I)
		qdel(src)
		return TRUE
	if(istype(I, /obj/item/soulstone))
		to_chat(user,"<span class='warning'>\The [I] doesn't fit in \the [src]'s socket.</span>")
		return TRUE
	..()

/obj/item/melee/cultblade/cultblade/nocult
	name = "broken cult blade"
	desc = "What remains of an arcane weapon wielded by the followers of Nar-Sie. In this state, it can be held mostly without risks."
	icon_state = "cultblade-broken"
	item_state = "cultblade-broken"
	checkcult = FALSE
	force = 15

/obj/item/melee/cultblade/cultblade/nocult/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/paper))
		return TRUE
	if(istype(I, /obj/item/soulstone/gem))
		to_chat(user,"<span class='warning'>The [src]'s damage doesn't allow it to hold \a [I] any longer.</span>")
		return TRUE
	..()

///////////////////////////////////////SOUL BLADE////////////////////////////////////////////////

/obj/item/melee/cultblade/soulblade
	name = "soul blade"
	desc = "An obsidian blade fitted with a soul gem, giving it soul catching properties."
	pixel_x = -16 * PIXEL_MULTIPLIER
	pixel_y = -16 * PIXEL_MULTIPLIER
	icon_state = "soulblade"
	item_state = "soulblade"
	force = 30//30 brute, plus 5 burn
	throwforce = 20
	hitsound = "sound/weapons/bladeslice.ogg"
	var/mob/living/simple_animal/shade/shade
	var/blood = 0
	var/maxregenblood = 8//the maximum amount of blood you can regen by waiting around.
	var/maxblood = 100
	var/movespeed = 2//smaller = faster
	max_integrity = 40

/obj/item/melee/cultblade/soulblade/Destroy()
	var/turf/T = get_turf(src)
	if(istype(loc, /obj/item/projectile))
		qdel(loc)
	if(shade)
		shade.remove_blade_powers()
		if(T)
			shade.forceMove(T)
			shade.status_flags &= ~GODMODE
			shade.mobility_flags = MOBILITY_FLAGS_DEFAULT
			shade.cancel_camera()
			var/datum/control/C = shade.control_object[src]
			if(C)
				C.break_control()
				qdel(C)
		else
			qdel(shade)
	if(T)
		var/obj/item/melee/cultblade/cultblade/nocult/B = new (T)
		B.Move(get_step_rand(T))
		if (fingerprints)
			B.fingerprints = fingerprints.Copy()
		new /obj/item/soulstone(T)
	shade = null
	..()

/obj/item/melee/cultblade/soulblade/examine(mob/user)
	..()
	if(iscultist(user))
		to_chat(user, "<span class='info'>blade blood: [blood]%</span>")
		to_chat(user, "<span class='info'>blade health: [round((health/maxHealth)*100)]%</span>")

/obj/item/melee/cultblade/soulblade/attack_self(mob/user)
	var/choices = list(
		list("Give Blood", "radial_giveblood", "Transfer some of your blood to \the [src] to repair it and refuel its blood level, or you could just slash someone."),
		list("Remove Gem", "radial_removegem", "Remove the soul gem from the blade."),
		)

	if(!iscultist(user))
		choices = list(
			list("Remove Gem", "radial_removegem", "Remove the soul gem from \the [src]."),
			)

	var/task = show_radial_menu(user,user,choices,'icons/obj/cult_radial.dmi',"radial-cult")//spawning on loc so we aren't offset by pixel_x/pixel_y, or affected by animate()
	if(user.get_active_hand() != src)
		to_chat(user,"<span class='warning'>You must hold \the [src] in your active hand.</span>")
		return
	switch(task)
		if("Give Blood")
			var/data = use_available_blood(user, 10)
			if(data[BLOODCOST_RESULT] != BLOODCOST_FAILURE)
				blood = min(maxblood, blood + 20)//reminder that the blade cannot give blood back to their wielder, so this should prevent some exploits
				health = min(maxHealth, health + 10)
		if("Remove Gem")
			var/turf/T = get_turf(user)
			playsound(T, 'sound/items/Deconstruct.ogg', 50, FALSE, -3)
			user.dropItemToGround(src)
			var/obj/item/melee/cultblade/cultblade/CB = new (T)
			var/obj/item/soulstone/gem/SG = new (T)
			if(fingerprints)
				CB.fingerprints = fingerprints.Copy()
			user.put_in_active_hand(CB)
			user.put_in_inactive_hand(SG)
			if(shade)
				shade.forceMove(SG)
				shade.remove_blade_powers()
				SG.icon_state = "soulstone2"
				SG.item_state = "shard-soulstone2"
				SG.name = "Soul Stone: [shade.real_name]"
				shade = null
			loc = null//so we won't drop a broken blade and shard
			qdel(src)


/obj/item/melee/cultblade/soulblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!iscultist(user))
		user.Paralyse(5)
		to_chat(user, "<span class='warning'>An unexplicable force powerfully repels \the [src] from \the [target]!</span>")
		var/datum/organ/external/affecting = user.get_active_hand_organ()
		if(affecting && affecting.take_damage(rand(force/2, force))) //random amount of damage between half of the blade's force and the full force of the blade.
			user.UpdateDamageIcon()
		return
	if(ishuman(target) && target.resting)
		var/obj/structure/cult/altar/altar = locate() in target.loc
		if (altar)
			altar.attackby(src,user)
			return
	..()
	if(!shade && istype(target, /mob/living/carbon))
		transfer_soul("VICTIM", target, user,1)
		update_icon()

/obj/item/melee/cultblade/soulblade/afterattack(atom/A, mob/living/user, proximity_flag, click_parameters)
	if(proximity_flag)
		return
	if(user.is_pacified(VIOLENCE_SILENT, A, src))
		return

	if(blood >= 5)
		blood = max(0,blood-5)
		var/turf/starting = get_turf(user)
		var/turf/target = get_turf(A)
		var/obj/item/projectile/bloodslash/BS = new (starting)
		BS.firer = user
		BS.original = A
		BS.target = target
		BS.current = starting
		BS.starting = starting
		BS.yo = target.y - starting.y
		BS.xo = target.x - starting.x
		user.delayNextAttack(4)
		if(user.zone_sel)
			BS.def_zone = user.zone_sel.selecting
		else
			BS.def_zone = LIMB_CHEST
		BS.OnFired()
		playsound(starting, 'sound/effects/forge.ogg', 100, TRUE)
		BS.process()

/obj/item/melee/cultblade/soulblade/on_attack(atom/attacked, mob/user)
	..()
	if(ismob(attacked))
		var/mob/living/M = attacked
		M.take_organ_damage(0,5)
		playsound(loc, 'sound/weapons/welderattack.ogg', 50, TRUE)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(C.stat != DEAD)
				if(C.take_blood(null, 10))
					blood = min(100, blood + 10)
					to_chat(user, "<span class='warning'>You steal some of their blood!</span>")
			else
				if(C.take_blood(null, 5))//same cost as spin, basically negates the cost, but doesn't let you farm corpses. It lets you make a mess out of them however.
					blood = min(100, blood + 5)
					to_chat(user, "<span class='warning'>You steal a bit of their blood, but not much.</span>")

			if(shade && shade.hud_used && shade.gui_icons && shade.gui_icons.soulblade_bloodbar)
				var/matrix/MAT = matrix()
				MAT.Scale(1, blood / maxblood)
				var/total_offset = (60 + (100 * (blood / maxblood))) * PIXEL_MULTIPLIER
				shade.hud_used.mymob.gui_icons.soulblade_bloodbar.transform = MAT
				shade.hud_used.mymob.gui_icons.soulblade_bloodbar.screen_loc = "WEST,CENTER-[8-round(total_offset / WORLD_ICON_SIZE)]:[total_offset % WORLD_ICON_SIZE]"
				shade.hud_used.mymob.gui_icons.soulblade_coverLEFT.maptext = "[blood]"


/obj/item/melee/cultblade/soulblade/pickup(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>An overwhelming feeling of dread comes over you as you pick up \the [src]. It would be wise to rid yourself of this, quickly.</span>")
		user.Dizzy(120)

/obj/item/melee/cultblade/soulblade/dropped(mob/user)
	..()
	update_icon()

/obj/item/melee/cultblade/soulblade/update_icon()
	overlays.len = 0
	animate(src, pixel_y = -16 * PIXEL_MULTIPLIER, time = 3, easing = SINE_EASING)
	shade = locate() in src
	if(shade)
		plane = HUD_PLANE//let's keep going and see where this takes us
		layer = ABOVE_HUD_LAYER
		item_state = "soulblade-full"
		icon_state = "soulblade-full"
		animate(src, pixel_y = -8 * PIXEL_MULTIPLIER , time = 7, loop = -1, easing = SINE_EASING)
		animate(pixel_y = -12 * PIXEL_MULTIPLIER, time = 7, loop = -1, easing = SINE_EASING)
	else
		if(!ismob(loc))
			plane = initial(plane)
			layer = initial(layer)
		item_state = "soulblade"
		icon_state = "soulblade"

	if(istype(loc,/mob/living/carbon))
		var/mob/living/carbon/C = loc
		C.update_inv_hands()


/obj/item/melee/cultblade/soulblade/throw_at(atom/targ, range, speed, mob/thrower, spin=TRUE, diagonals_first = FALSE, datum/callback/callback)
	var/turf/starting = get_turf(src)
	var/turf/target = get_turf(targ)
	var/turf/second_target = target
	var/obj/item/projectile/soulbullet/SB = new (starting)
	SB.original = target
	SB.target = target
	SB.current = starting
	SB.starting = starting
	SB.secondary_target = second_target
	SB.yo = target.y - starting.y
	SB.xo = target.x - starting.x
	SB.shade = shade
	SB.blade = src
	src.forceMove(SB)
	SB.OnFired()
	SB.process()
/*
/obj/item/melee/cultblade/soulblade/proc/takeDamage(damage)
	if(!damage)
		return
	health -= damage
	if(shade && shade.hud_used)
		shade.regular_hud_updates()
	if(health <= 0)
		playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
		qdel(src)
	else
		playsound(loc, 'sound/items/trayhit1.ogg', 70, TRUE)
*/
/obj/item/melee/cultblade/soulblade/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(istype(mover, /obj/item/projectile))
		if(prob(60))
			return FALSE
	return ..()

/obj/item/melee/cultblade/soulblade/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/paper))
		fire_act(I)
		return TRUE
	user.delayNextAttack(8)
	if(user.is_pacified(VIOLENCE_DEFAULT, src))
		return
	if(I.force)
		var/damage = I.force
		if(I.damtype == HALLOSS)
			damage = 0
		takeDamage(damage)
		user.visible_message("<span class='danger'>\The [src] has been attacked with \the [I] by \the [user]. </span>")

/obj/item/melee/cultblade/soulblade/hitby(atom/movable/AM, hitpush, throwingdatum)
	. = ..()
	if(.)
		return

	visible_message("<span class='warning'>\The [src] was hit by \the [AM].</span>", 1)
	if(isobj(AM))
		var/obj/O = AM
		takeDamage(O.throwforce)

/obj/item/melee/cultblade/soulblade/bullet_act(obj/item/projectile/P)
	..()
	takeDamage(P.damage)

/obj/item/soulstone/gem
	name = "Soul Gem"
	desc = "A freshly cut stone which appears to hold the same soul catching properties as shards of the Soul Stone. This one however is cut to perfection."
	icon = 'icons/obj/cult.dmi'
	icon_state = "soulstone"
	item_state = "shard-soulstone"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'

/obj/item/soulstone/gem/throw_impact(atom/hit_atom, speed, mob/user)
	..()
	var/obj/item/soulstone/S = new(loc)
	for(var/mob/living/simple_animal/shade/A in src)
		A.forceMove(S)
		S.icon_state = "soulstone2"
		S.item_state = "shard-soulstone2"
	playsound(S, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
	qdel(src)

/obj/item/melee/cultblade/ghost
	name = "eldritch sword"
	force = 19 //can't break normal airlocks
	item_flags = NEEDS_PERMIT | DROPDEL
	flags_1 = NONE

/obj/item/melee/cultblade/ghost/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)


/obj/item/melee/cultblade/pickup(mob/living/user)
	..()
	if(!iscultist(user))
		if(!is_servant_of_ratvar(user))
			to_chat(user, "<span class='cultlarge'>\"I wouldn't advise that.\"</span>")
		else
			to_chat(user, "<span class='cultlarge'>\"One of Ratvar's toys is trying to play with things [user.p_they()] shouldn't. Cute.\"</span>")
			to_chat(user, "<span class='userdanger'>A horrible force yanks at your arm!</span>")
			user.emote("scream")
			user.apply_damage(30, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
			user.dropItemToGround(src)
*/
/obj/item/twohanded/required/cult_bastard
	name = "bloody bastard sword"
	desc = "An enormous sword used by Nar'Sien cultists to rapidly harvest the souls of non-believers."
	w_class = WEIGHT_CLASS_HUGE
	block_chance = 50
	throwforce = 20
	force = 35
	armour_penetration = 45
	throw_speed = 1
	throw_range = 3
	sharpness = IS_SHARP
	light_color = "#ff0000"
	attack_verb = list("cleaved", "slashed", "torn", "hacked", "ripped", "diced", "carved")
	icon_state = "cultbastard"
	item_state = "cultbastard"
	hitsound = 'sound/weapons/bladeslice.ogg'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	actions_types = list()
	var/datum/action/innate/dash/cult/jaunt
	var/datum/action/innate/cult/spin2win/linked_action
	var/spinning = FALSE
	var/spin_cooldown = 250
	var/dash_toggled = TRUE

/obj/item/twohanded/required/cult_bastard/Initialize()
	. = ..()
	set_light(4)
	jaunt = new(src)
	linked_action = new(src)
	AddComponent(/datum/component/butchering, 50, 80)

/obj/item/twohanded/required/cult_bastard/examine(mob/user)
	. = ..()
	if(contents.len)
		. += "<br><b>There are [contents.len] souls trapped within the sword's core.</b>"
	else
		. += "<br>The sword appears to be quite lifeless."

/obj/item/twohanded/required/cult_bastard/can_be_pulled(user)
	return FALSE

/obj/item/twohanded/required/cult_bastard/attack_self(mob/user)
	dash_toggled = !dash_toggled
	if(dash_toggled)
		to_chat(loc, "<span class='notice'>You raise [src] and prepare to jaunt with it.</span>")
	else
		to_chat(loc, "<span class='notice'>You lower [src] and prepare to swing it normally.</span>")

/obj/item/twohanded/required/cult_bastard/pickup(mob/living/user)
	. = ..()
	if(!iscultist(user))
		if(!is_servant_of_ratvar(user))
			to_chat(user, "<span class='cultlarge'>\"I wouldn't advise that.\"</span>")
			force = 5
			return
		else
			to_chat(user, "<span class='cultlarge'>\"One of Ratvar's toys is trying to play with things [user.p_they()] shouldn't. Cute.\"</span>")
			to_chat(user, "<span class='userdanger'>A horrible force yanks at your arm!</span>")
			user.emote("scream")
			user.apply_damage(30, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
			user.dropItemToGround(src, TRUE)
			user.DefaultCombatKnockdown(50)
			return
	force = initial(force)
	jaunt.Grant(user, src)
	linked_action.Grant(user, src)
	user.update_icons()

/obj/item/twohanded/required/cult_bastard/dropped(mob/user)
	. = ..()
	linked_action.Remove(user)
	jaunt.Remove(user)
	user.update_icons()

/obj/item/twohanded/required/cult_bastard/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(spinning && is_energy_reflectable_projectile(object) && (attack_type & ATTACK_TYPE_PROJECTILE))
		playsound(src, pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg'), 100, 1)
		return BLOCK_SUCCESS | BLOCK_PHYSICAL_EXTERNAL | BLOCK_REDIRECTED | BLOCK_SHOULD_REDIRECT
	if(prob(final_block_chance))
		if(attack_type & ATTACK_TYPE_PROJECTILE)
			owner.visible_message("<span class='danger'>[owner] deflects [attack_text] with [src]!</span>")
			playsound(src, pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg'), 100, 1)
			return BLOCK_SUCCESS | BLOCK_PHYSICAL_EXTERNAL | BLOCK_REDIRECTED | BLOCK_SHOULD_REDIRECT
		else
			playsound(src, 'sound/weapons/parry.ogg', 75, 1)
			owner.visible_message("<span class='danger'>[owner] parries [attack_text] with [src]!</span>")
			return BLOCK_SUCCESS | BLOCK_PHYSICAL_EXTERNAL
	return BLOCK_NONE

/obj/item/twohanded/required/cult_bastard/afterattack(atom/target, mob/user, proximity, click_parameters)
	. = ..()
	if(dash_toggled && !proximity)
		jaunt.Teleport(user, target)
		return
	if(proximity)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.stat != CONSCIOUS)
				var/obj/item/soulstone/SS = new /obj/item/soulstone(src)
				SS.attack(H, user)
				if(!LAZYLEN(SS.contents))
					qdel(SS)
		if(istype(target, /obj/structure/constructshell) && contents.len)
			var/obj/item/soulstone/SS = contents[1]
			if(istype(SS))
				SS.transfer_soul("CONSTRUCT",target,user)
				qdel(SS)

/datum/action/innate/dash/cult
	name = "Rend the Veil"
	desc = "Use the sword to shear open the flimsy fabric of this reality and teleport to your target."
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "phaseshift"
	dash_sound = 'sound/magic/enter_blood.ogg'
	recharge_sound = 'sound/magic/exit_blood.ogg'
	beam_effect = "sendbeam"
	phasein = /obj/effect/temp_visual/dir_setting/cult/phase
	phaseout = /obj/effect/temp_visual/dir_setting/cult/phase/out

/datum/action/innate/dash/cult/IsAvailable(silent = FALSE)
	if(iscultist(holder) && current_charges)
		return TRUE
	else
		return FALSE

/datum/action/innate/cult/spin2win
	name = "Geometer's Fury"
	desc = "You draw on the power of the sword's ancient runes, spinning it wildly around you as you become immune to most attacks."
	background_icon_state = "bg_demon"
	button_icon_state = "sintouch"
	var/cooldown = 0
	var/mob/living/carbon/human/holder
	var/obj/item/twohanded/required/cult_bastard/sword

/datum/action/innate/cult/spin2win/Grant(mob/user, obj/bastard)
	. = ..()
	sword = bastard
	holder = user

/datum/action/innate/cult/spin2win/IsAvailable(silent = FALSE)
	if(iscultist(holder) && cooldown <= world.time)
		return TRUE
	else
		return FALSE

/datum/action/innate/cult/spin2win/Activate()
	cooldown = world.time + sword.spin_cooldown
	holder.changeNext_move(50)
	holder.apply_status_effect(/datum/status_effect/sword_spin)
	sword.spinning = TRUE
	sword.block_chance = 100
	sword.slowdown += 1.5
	addtimer(CALLBACK(src, .proc/stop_spinning), 50)
	holder.update_action_buttons_icon()

/datum/action/innate/cult/spin2win/proc/stop_spinning()
	sword.spinning = FALSE
	sword.block_chance = 50
	sword.slowdown -= 1.5
	sleep(sword.spin_cooldown)
	holder.update_action_buttons_icon()

/obj/item/restraints/legcuffs/bola/cult
	name = "\improper Nar'Sien bola"
	desc = "A strong bola, bound with dark magic that allows it to pass harmlessly through Nar'Sien cultists. Throw it to trip and slow your victim."
	icon_state = "bola_cult"
	breakouttime = 60
	knockdown = 20

/obj/item/restraints/legcuffs/bola/cult/pickup(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>The bola seems to take on a life of its own!</span>")
		ensnare(user)

/obj/item/restraints/legcuffs/bola/cult/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(iscultist(hit_atom))
		return
	. = ..()

/obj/item/clothing/head/culthood
	name = "ancient cultist hood"
	icon_state = "culthood"
	desc = "A torn, dust-caked hood. Strange letters line the inside."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEEARS
	flags_cover = HEADCOVERSEYES
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40,"energy" = 20, "bomb" = 65, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT

/obj/item/clothing/suit/cultrobes
	name = "ancient cultist robes"
	desc = "A ragged, dusty set of robes. Strange letters line the inside."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40,"energy" = 20, "bomb" = 65, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT

/obj/item/clothing/head/culthood/alt
	name = "cultist hood"
	desc = "An armored hood worn by the followers of Nar'Sie."
	icon_state = "cult_hoodalt"
	item_state = "cult_hoodalt"

/obj/item/clothing/head/culthood/alt/ghost
	item_flags = DROPDEL

/obj/item/clothing/head/culthood/alt/ghost/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)


/obj/item/clothing/suit/cultrobes/alt
	name = "cultist robes"
	desc = "An armored set of robes worn by the followers of Nar'Sie."
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"

/obj/item/clothing/suit/cultrobes/alt/ghost
	item_flags = DROPDEL

/obj/item/clothing/suit/cultrobes/alt/ghost/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/head/magus
	name = "magus helm"
	icon_state = "magus"
	item_state = "magus"
	desc = "A helm worn by the followers of Nar'Sie."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEARS|HIDEEYES|HIDESNOUT
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30,"energy" = 20, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	mutantrace_variation = STYLE_MUZZLE

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar'Sie."
	icon_state = "magusred"
	item_state = "magusred"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list("melee" = 50, "bullet" = 30, "laser" = 50,"energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/head/helmet/space/hardsuit/cult
	name = "\improper Nar'Sien hardened helmet"
	desc = "A heavily-armored helmet worn by warriors of the Nar'Sien cult. It can withstand hard vacuum."
	icon_state = "cult_helmet"
	item_state = "cult_helmet"
	armor = list("melee" = 60, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 40, "acid" = 75)
	brightness_on = 0
	actions_types = list()


/obj/item/clothing/head/helmet/space/hardsuit/cult/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/spellcasting, SPELL_CULT_HELMET, ITEM_SLOT_HEAD)

/obj/item/clothing/suit/space/hardsuit/cult
	name = "\improper Nar'Sien hardened armor"
	icon_state = "cult_armor"
	item_state = "cult_armor"
	desc = "A heavily-armored exosuit worn by warriors of the Nar'Sien cult. It can withstand hard vacuum."
	w_class = WEIGHT_CLASS_BULKY
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade, /obj/item/tank/internals/)
	armor = list("melee" = 70, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 40, "acid" = 75)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/cult

/obj/item/clothing/suit/space/hardsuit/cult/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/spellcasting, SPELL_CULT_ARMOR, ITEM_SLOT_OCLOTHING)

/obj/item/sharpener/cult
	name = "eldritch whetstone"
	desc = "A block, empowered by dark magic. Sharp weapons will be enhanced when used on the stone."
	icon_state = "cult_sharpener"
	used = 0
	increment = 5
	max = 40
	prefix = "darkened"

/obj/item/sharpener/cult/update_icon_state()
	var/old_state = icon_state
	icon_state = "cult_sharpener[used ? "_used" : ""]"
	if(old_state != icon_state)
		playsound(get_turf(src), 'sound/items/unsheath.ogg', 25, 1)

/obj/item/clothing/suit/hooded/cultrobes/cult_shield
	name = "empowered cultist armor"
	desc = "Empowered garb which creates a powerful shield around the user."
	icon_state = "cult_armor"
	item_state = "cult_armor"
	w_class = WEIGHT_CLASS_BULKY
	armor = list("melee" = 50, "bullet" = 40, "laser" = 50,"energy" = 30, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 50, "acid" = 60)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	var/current_charges = 3
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie

/obj/item/clothing/head/hooded/cult_hoodie
	name = "empowered cultist armor"
	desc = "Empowered garb which creates a powerful shield around the user."
	icon_state = "cult_hoodalt"
	armor = list("melee" = 50, "bullet" = 40, "laser" = 50,"energy" = 30, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 50, "acid" = 50)
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/equipped(mob/living/user, slot)
	..()
	if(!iscultist(user))
		if(!is_servant_of_ratvar(user))
			to_chat(user, "<span class='cultlarge'>\"I wouldn't advise that.\"</span>")
			to_chat(user, "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>")
			user.dropItemToGround(src, TRUE)
			user.Dizzy(30)
			user.DefaultCombatKnockdown(100)
		else
			to_chat(user, "<span class='cultlarge'>\"Trying to use things you don't own is bad, you know.\"</span>")
			to_chat(user, "<span class='userdanger'>The armor squeezes at your body!</span>")
			user.emote("scream")
			user.adjustBruteLoss(25)
			user.dropItemToGround(src, TRUE)

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/check_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(current_charges)
		block_return[BLOCK_RETURN_NORMAL_BLOCK_CHANCE] = 100
		block_return[BLOCK_RETURN_BLOCK_CAPACITY] = (block_return[BLOCK_RETURN_BLOCK_CAPACITY] || 0) + current_charges
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(current_charges)
		owner.visible_message("<span class='danger'>\The [attack_text] is deflected in a burst of blood-red sparks!</span>")
		current_charges--
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		if(!current_charges)
			owner.visible_message("<span class='danger'>The runed shield around [owner] suddenly disappears!</span>")
			owner.update_inv_wear_suit()
		return BLOCK_SUCCESS | BLOCK_PHYSICAL_EXTERNAL
	return BLOCK_NONE

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/worn_overlays(isinhands, icon_file, used_state, style_flags = NONE)
	. = ..()
	if(!isinhands && current_charges)
		. += mutable_appearance('icons/effects/cult_effects.dmi', "shield-cult", MOB_LAYER + 0.01)

/obj/item/clothing/suit/hooded/cultrobes/berserker
	name = "flagellant's robes"
	desc = "Blood-soaked robes infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor = list("melee" = -50, "bullet" = -50, "laser" = -50,"energy" = -50, "bomb" = -50, "bio" = -50, "rad" = -50, "fire" = 0, "acid" = 0)
	slowdown = -1
	hoodtype = /obj/item/clothing/head/hooded/berserkerhood

/obj/item/clothing/head/hooded/berserkerhood
	name = "flagellant's robes"
	desc = "Blood-soaked garb infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage."
	icon_state = "culthood"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	armor = list("melee" = -50, "bullet" = -50, "laser" = -50, "energy" = -50, "bomb" = -50, "bio" = -50, "rad" = -50, "fire" = 0, "acid" = 0)

/obj/item/clothing/suit/hooded/cultrobes/berserker/equipped(mob/living/user, slot)
	..()
	if(!iscultist(user))
		if(!is_servant_of_ratvar(user))
			to_chat(user, "<span class='cultlarge'>\"I wouldn't advise that.\"</span>")
			to_chat(user, "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>")
			user.dropItemToGround(src, TRUE)
			user.Dizzy(30)
			user.DefaultCombatKnockdown(100)
		else
			to_chat(user, "<span class='cultlarge'>\"Trying to use things you don't own is bad, you know.\"</span>")
			to_chat(user, "<span class='userdanger'>The robes squeeze at your body!</span>")
			user.emote("scream")
			user.adjustBruteLoss(25)
			user.dropItemToGround(src, TRUE)

/obj/item/clothing/glasses/hud/health/night/cultblind
	desc = "may Nar'Sie guide you through the darkness and shield you from the light."
	name = "zealot's blindfold"
	icon_state = "blindfold"
	item_state = "blindfold"
	flash_protect = 1

/obj/item/clothing/glasses/hud/health/night/cultblind/equipped(mob/living/user, slot)
	..()
	if(!iscultist(user))
		to_chat(user, "<span class='cultlarge'>\"You want to be blind, do you?\"</span>")
		user.dropItemToGround(src, TRUE)
		user.Dizzy(30)
		user.DefaultCombatKnockdown(100)
		user.blind_eyes(30)

/obj/item/reagent_containers/glass/beaker/unholywater
	name = "flask of unholy water"
	desc = "Toxic to nonbelievers; reinvigorating to the faithful - this flask may be sipped or thrown."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	color = "#333333"
	list_reagents = list(/datum/reagent/fuel/unholywater = 50)

/obj/item/shuttle_curse
	name = "cursed orb"
	desc = "You peer within this smokey orb and glimpse terrible fates befalling the escape shuttle."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shuttlecurse"
	var/static/curselimit = 0

/obj/item/shuttle_curse/attack_self(mob/living/user)
	if(!iscultist(user, TRUE))
		user.dropItemToGround(src, TRUE)
		user.DefaultCombatKnockdown(100)
		to_chat(user, "<span class='warning'>A powerful force shoves you away from [src]!</span>")
		return
	if(curselimit > 1)
		to_chat(user, "<span class='notice'>We have exhausted our ability to curse the shuttle.</span>")
		return
	if(locate(/obj/singularity/narsie) in GLOB.poi_list)
		to_chat(user, "<span class='warning'>Nar'Sie is already on this plane, there is no delaying the end of all things.</span>")
		return

	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/cursetime = 1800
		var/timer = SSshuttle.emergency.timeLeft(1) + cursetime
		var/security_num = SECLEVEL2NUM(NUM2SECLEVEL(GLOB.security_level))
		var/set_coefficient = 1
		switch(security_num)
			if(SEC_LEVEL_GREEN)
				set_coefficient = 2
			if(SEC_LEVEL_BLUE)
				set_coefficient = 1.2
			if(SEC_LEVEL_AMBER)
				set_coefficient = 0.8
			else
				set_coefficient = 0.5
		var/surplus = timer - (SSshuttle.emergencyCallTime * set_coefficient)
		SSshuttle.emergency.setTimer(timer)
		if(surplus > 0)
			SSshuttle.block_recall(surplus)
		to_chat(user, "<span class='danger'>You shatter the orb! A dark essence spirals into the air, then disappears.</span>")
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 50, 1)
		qdel(src)
		sleep(20)
		var/static/list/curses
		if(!curses)
			curses = list("A fuel technician just slit his own throat and begged for death.",
			"The shuttle's navigation programming was replaced by a file containing just two words: IT COMES.",
			"The shuttle's custodian was found washing the windows with their own blood.",
			"A shuttle engineer began screaming 'DEATH IS NOT THE END' and ripped out wires until an arc flash seared off her flesh.",
			"A shuttle inspector started laughing madly over the radio and then threw herself into an engine turbine.",
			"An assistant was found on the shuttle.",
			"A medical officer was found pouring out several blood bags onto the shuttle's instrument panels, before slitting both wrists open and screaming 'DEATH IS NOT THE END'.",
			"A fuel technician was found replacing the fuel with his blood.",
			"All the lights aboard the shuttle turned a crimson red before blowing out..",
			"The shuttle dispatcher was found dead with bloody symbols carved into their flesh.",
			"An engine turbine began leaking blood when it was powered on.",
			"The shuttle's transponder is emitting the encoded message 'FEAR THE OLD BLOOD' in lieu of its assigned identification signal.")
		var/message = pick_n_take(curses)
		message += " The shuttle will be delayed by three minutes."
		priority_announce("[message]", "System Failure", 'sound/misc/notice1.ogg')
		curselimit++

/obj/item/cult_shift
	name = "veil shifter"
	desc = "This relic instantly teleports you, and anything you're pulling, forward by a moderate distance."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shifter"
	var/uses = 4

/obj/item/cult_shift/examine(mob/user)
	. = ..()
	if(uses)
		. += "<span class='cult'>It has [uses] use\s remaining.</span>"
	else
		. += "<span class='cult'>It seems drained.</span>"

/obj/item/cult_shift/proc/handle_teleport_grab(turf/T, mob/user)
	var/mob/living/carbon/C = user
	if(C.pulling)
		var/atom/movable/pulled = C.pulling
		do_teleport(pulled, T, channel = TELEPORT_CHANNEL_CULT)
		. = pulled

/obj/item/cult_shift/attack_self(mob/user)
	if(!uses || !iscarbon(user))
		to_chat(user, "<span class='warning'>\The [src] is dull and unmoving in your hands.</span>")
		return
	if(!iscultist(user))
		user.dropItemToGround(src, TRUE)
		step(src, pick(GLOB.alldirs))
		to_chat(user, "<span class='warning'>\The [src] flickers out of your hands, your connection to this dimension is too strong!</span>")
		return

	var/mob/living/carbon/C = user
	var/turf/mobloc = get_turf(C)
	var/turf/destination = get_teleport_loc(mobloc,C,9,1,3,1,0,1)

	if(destination)
		uses--
		if(uses <= 0)
			icon_state ="shifter_drained"
		playsound(mobloc, "sparks", 50, 1)
		new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, C.dir)

		var/atom/movable/pulled = handle_teleport_grab(destination, C)
		if(do_teleport(C, destination, channel = TELEPORT_CHANNEL_CULT))
			if(pulled)
				C.start_pulling(pulled) //forcemove resets pulls, so we need to re-pull
			new /obj/effect/temp_visual/dir_setting/cult/phase(destination, C.dir)
			playsound(destination, 'sound/effects/phasein.ogg', 25, 1)
			playsound(destination, "sparks", 50, 1)

	else
		to_chat(C, "<span class='danger'>The veil cannot be torn here!</span>")

/obj/item/flashlight/flare/culttorch
	name = "void torch"
	desc = "Used by veteran cultists to instantly transport items to their needful brethren."
	w_class = WEIGHT_CLASS_SMALL
	brightness_on = 1
	icon_state = "torch"
	item_state = "torch"
	color = "#ff0000"
	on_damage = 15
	slot_flags = null
	on = TRUE
	var/charges = 5

/obj/item/flashlight/flare/culttorch/afterattack(atom/movable/A, mob/user, proximity)
	if(!proximity)
		return
	if(!iscultist(user))
		to_chat(user, "That doesn't seem to do anything useful.")
		return

	if(istype(A, /obj/item))

		var/list/cultists = list()
		for(var/datum/mind/M in SSticker.mode.cult)
			if(M.current && M.current.stat != DEAD)
				cultists |= M.current
		var/mob/living/cultist_to_receive = input(user, "Who do you wish to call to [src]?", "Followers of the Geometer") as null|anything in (cultists - user)
		if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
			return
		if(!cultist_to_receive)
			to_chat(user, "<span class='cult italic'>You require a destination!</span>")
			log_game("Void torch failed - no target")
			return
		if(cultist_to_receive.stat == DEAD)
			to_chat(user, "<span class='cult italic'>[cultist_to_receive] has died!</span>")
			log_game("Void torch failed  - target died")
			return
		if(!iscultist(cultist_to_receive))
			to_chat(user, "<span class='cult italic'>[cultist_to_receive] is not a follower of the Geometer!</span>")
			log_game("Void torch failed - target was deconverted")
			return
		if(A in user.GetAllContents())
			to_chat(user, "<span class='cult italic'>[A] must be on a surface in order to teleport it!</span>")
			return
		to_chat(user, "<span class='cult italic'>You ignite [A] with \the [src], turning it to ash, but through the torch's flames you see that [A] has reached [cultist_to_receive]!")
		cultist_to_receive.put_in_hands(A)
		charges--
		to_chat(user, "\The [src] now has [charges] charge\s.")
		if(charges == 0)
			qdel(src)

	else
		..()
		to_chat(user, "<span class='warning'>\The [src] can only transport items!</span>")


/obj/item/twohanded/cult_spear
	name = "blood halberd"
	desc = "A sickening spear composed entirely of crystallized blood."
	icon_state = "bloodspear0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	slot_flags = 0
	force = 17
	force_unwielded = 17
	force_wielded = 24
	throwforce = 40
	throw_speed = 2
	armour_penetration = 30
	block_chance = 30
	attack_verb = list("attacked", "impaled", "stabbed", "torn", "gored")
	sharpness = IS_SHARP
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/datum/action/innate/cult/spear/spear_act

/obj/item/twohanded/cult_spear/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 100, 90)

/obj/item/twohanded/cult_spear/Destroy()
	if(spear_act)
		qdel(spear_act)
	..()

/obj/item/twohanded/cult_spear/update_icon_state()
	icon_state = "bloodspear[wielded]"

/obj/item/twohanded/cult_spear/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(iscultist(L))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			if(L.put_in_active_hand(src))
				L.visible_message("<span class='warning'>[L] catches [src] out of the air!</span>")
			else
				L.visible_message("<span class='warning'>[src] bounces off of [L], as if repelled by an unseen force!</span>")
		else if(!..())
			if(!L.anti_magic_check())
				if(is_servant_of_ratvar(L))
					to_chat(L, "<span class='cultlarge'>\"Kneel for me, scum\"</span>")
					L.confused += clamp(10 - L.confused, 0, 5) //confuses and lightly knockdowns + damages hostile cultists instead of hardstunning like before
					L.DefaultCombatKnockdown(15)
					L.adjustBruteLoss(10)
				else
					L.DefaultCombatKnockdown(50)
			break_spear(T)
	else
		..()

/obj/item/twohanded/cult_spear/proc/break_spear(turf/T)
	if(src)
		if(!T)
			T = get_turf(src)
		if(T)
			T.visible_message("<span class='warning'>[src] shatters and melts back into blood!</span>")
			new /obj/effect/temp_visual/cult/sparks(T)
			new /obj/effect/decal/cleanable/blood/splatter(T)
			playsound(T, 'sound/effects/glassbr3.ogg', 100)
	qdel(src)

/obj/item/twohanded/cult_spear/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(wielded)
		final_block_chance *= 2
	if(prob(final_block_chance))
		if(attack_type & ATTACK_TYPE_PROJECTILE)
			owner.visible_message("<span class='danger'>[owner] deflects [attack_text] with [src]!</span>")
			playsound(src, pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg'), 100, 1)
			return BLOCK_SUCCESS | BLOCK_SHOULD_REDIRECT | BLOCK_REDIRECTED | BLOCK_PHYSICAL_EXTERNAL
		else
			playsound(src, 'sound/weapons/parry.ogg', 100, 1)
			owner.visible_message("<span class='danger'>[owner] parries [attack_text] with [src]!</span>")
			return BLOCK_SUCCESS | BLOCK_PHYSICAL_EXTERNAL
	return BLOCK_NONE

/datum/action/innate/cult/spear
	name = "Bloody Bond"
	desc = "Call the blood spear back to your hand!"
	background_icon_state = "bg_demon"
	button_icon_state = "bloodspear"
	var/obj/item/twohanded/cult_spear/spear
	var/cooldown = 0

/datum/action/innate/cult/spear/Grant(mob/user, obj/blood_spear)
	. = ..()
	spear = blood_spear
	button.screen_loc = "6:157,4:-2"
	button.moved = "6:157,4:-2"

/datum/action/innate/cult/spear/Activate()
	if(owner == spear.loc || cooldown > world.time)
		return
	var/ST = get_turf(spear)
	var/OT = get_turf(owner)
	if(get_dist(OT, ST) > 10)
		to_chat(owner,"<span class='cult'>The spear is too far away!</span>")
	else
		cooldown = world.time + 20
		if(isliving(spear.loc))
			var/mob/living/L = spear.loc
			L.dropItemToGround(spear)
			L.visible_message("<span class='warning'>An unseen force pulls the blood spear from [L]'s hands!</span>")
		spear.throw_at(owner, 10, 2, owner)


/obj/item/gun/ballistic/shotgun/boltaction/enchanted/arcane_barrage/blood
	name = "blood bolt barrage"
	desc = "Blood for blood."
	color = "#ff0000"
	guns_left = 24
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	fire_sound = 'sound/magic/wand_teleport.ogg'
	item_flags = NEEDS_PERMIT | NOBLUDGEON | DROPDEL


/obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage/blood

/obj/item/ammo_casing/magic/arcane_barrage/blood
	projectile_type = /obj/item/projectile/magic/arcane_barrage/blood

/obj/item/projectile/magic/arcane_barrage/blood
	name = "blood bolt"
	icon_state = "mini_leaper"
	damage_type = BRUTE
	impact_effect_type = /obj/effect/temp_visual/dir_setting/bloodsplatter

/obj/item/projectile/magic/arcane_barrage/blood/Bump(atom/target)
	var/turf/T = get_turf(target)
	playsound(T, 'sound/effects/splat.ogg', 50, TRUE)
	if(iscultist(target))
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.stat != DEAD)
				H.reagents.add_reagent(/datum/reagent/fuel/unholywater, 4)
		if(isshade(target) || isconstruct(target))
			var/mob/living/simple_animal/M = target
			if(M.health+5 < M.maxHealth)
				M.adjustHealth(-5)
		new /obj/effect/temp_visual/cult/sparks(T)
		qdel(src)
	else
		..()

/obj/item/blood_beam
	name = "\improper magical aura"
	desc = "Sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "disintegrate"
	item_state = null
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/charging = FALSE
	var/firing = FALSE
	var/angle

/obj/item/blood_beam/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/blood_beam/afterattack(atom/A, mob/living/user, flag, params)
	. = ..()
	if(firing || charging)
		return
	var/C = user.client
	if(ishuman(user) && C)
		angle = mouse_angle_from_client(C)
	else
		qdel(src)
		return
	charging = TRUE
	INVOKE_ASYNC(src, .proc/charge, user)
	if(do_after(user, 90, target = user))
		firing = TRUE
		INVOKE_ASYNC(src, .proc/pewpew, user, params)
		var/obj/structure/emergency_shield/invoker/N = new(user.loc)
		if(do_after(user, 90, target = user))
			user.DefaultCombatKnockdown(40)
			to_chat(user, "<span class='cult italic'>You have exhausted the power of this spell!</span>")
		firing = FALSE
		if(N)
			qdel(N)
		qdel(src)
	charging = FALSE

/obj/item/blood_beam/proc/charge(mob/user)
	var/obj/O
	playsound(src, 'sound/magic/lightning_chargeup.ogg', 100, 1)
	for(var/i in 1 to 12)
		if(!charging)
			break
		if(i > 1)
			sleep(15)
		if(i < 4)
			O = new /obj/effect/temp_visual/cult/rune_spawn/rune1/inner(user.loc, 30, "#ff0000")
		else
			O = new /obj/effect/temp_visual/cult/rune_spawn/rune5(user.loc, 30, "#ff0000")
			new /obj/effect/temp_visual/dir_setting/cult/phase/out(user.loc, user.dir)
	if(O)
		qdel(O)

/obj/item/blood_beam/proc/pewpew(mob/user, params)
	var/turf/targets_from = get_turf(src)
	var/spread = 40
	var/second = FALSE
	var/set_angle = angle
	for(var/i in 1 to 12)
		if(second)
			set_angle = angle - spread
			spread -= 8
		else
			sleep(15)
			set_angle = angle + spread
		second = !second //Handles beam firing in pairs
		if(!firing)
			break
		playsound(src, 'sound/magic/exit_blood.ogg', 75, 1)
		new /obj/effect/temp_visual/dir_setting/cult/phase(user.loc, user.dir)
		var/turf/temp_target = get_turf_in_angle(set_angle, targets_from, 40)
		for(var/turf/T in getline(targets_from,temp_target))
			if (locate(/obj/effect/blessing, T))
				temp_target = T
				playsound(T, 'sound/machines/clockcult/ark_damage.ogg', 50, 1)
				new /obj/effect/temp_visual/at_shield(T, T)
				break
			T.narsie_act(TRUE, TRUE)
			for(var/mob/living/target in T.contents)
				if(iscultist(target))
					new /obj/effect/temp_visual/cult/sparks(T)
					if(ishuman(target))
						var/mob/living/carbon/human/H = target
						if(H.stat != DEAD)
							H.reagents.add_reagent(/datum/reagent/fuel/unholywater, 7)
					if(isshade(target) || isconstruct(target))
						var/mob/living/simple_animal/M = target
						if(M.health+15 < M.maxHealth)
							M.adjustHealth(-15)
						else
							M.health = M.maxHealth
				else
					var/mob/living/L = target
					if(L.density)
						L.DefaultCombatKnockdown(20)
						L.adjustBruteLoss(45)
						playsound(L, 'sound/hallucinations/wail.ogg', 50, 1)
						L.emote("scream")
		var/datum/beam/current_beam = new(user,temp_target,time=7,beam_icon_state="blood_beam",btype=/obj/effect/ebeam/blood)
		INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)


/obj/effect/ebeam/blood
	name = "blood beam"

/obj/item/shield/mirror
	name = "mirror shield"
	desc = "An infamous shield used by Nar'Sien sects to confuse and disorient their enemies. Its edges are weighted for use as a throwing weapon - capable of disabling multiple foes with preternatural accuracy."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "mirror_shield" // eshield1 for expanded
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	force = 5
	throwforce = 15
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("bumped", "prodded")
	hitsound = 'sound/weapons/smash.ogg'
	var/illusions = 2

/obj/item/shield/mirror/check_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	block_return[BLOCK_RETURN_REFLECT_PROJECTILE_CHANCE] = max(block_return[BLOCK_RETURN_REFLECT_PROJECTILE_CHANCE] || null, final_block_chance)
	return ..()

/obj/item/shield/mirror/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(iscultist(owner))
		if(istype(object, /obj/item/projectile) && (attack_type == ATTACK_TYPE_PROJECTILE))
			if(is_energy_reflectable_projectile(object))
				if(prob(final_block_chance))
					return BLOCK_SUCCESS | BLOCK_SHOULD_REDIRECT | BLOCK_PHYSICAL_EXTERNAL | BLOCK_REDIRECTED
				return BLOCK_NONE	//To avoid reflection chance double-dipping with block chance
			var/obj/item/projectile/P = object
			if(P.damage >= 30)
				var/turf/T = get_turf(owner)
				T.visible_message("<span class='warning'>The sheer force from [P] shatters the mirror shield!</span>")
				new /obj/effect/temp_visual/cult/sparks(T)
				playsound(T, 'sound/effects/glassbr3.ogg', 100)
				owner.DefaultCombatKnockdown(25)
				qdel(src)
				return BLOCK_NONE
		. = ..()
		if(. & BLOCK_SUCCESS)
			playsound(src, 'sound/weapons/parry.ogg', 100, 1)
			if(illusions > 0)
				illusions--
				addtimer(CALLBACK(src, /obj/item/shield/mirror.proc/readd), 450)
				if(prob(60))
					var/mob/living/simple_animal/hostile/illusion/M = new(owner.loc)
					M.faction = list("cult")
					M.Copy_Parent(owner, 70, 10, 5)
					M.move_to_delay = owner.movement_delay()
				else
					var/mob/living/simple_animal/hostile/illusion/escape/E = new(owner.loc)
					E.Copy_Parent(owner, 70, 10)
					E.GiveTarget(owner)
					E.Goto(owner, owner.movement_delay(), E.minimum_distance)
			return
	else
		if(prob(50))
			var/mob/living/simple_animal/hostile/illusion/H = new(owner.loc)
			H.Copy_Parent(owner, 100, 20, 5)
			H.faction = list("cult")
			H.GiveTarget(owner)
			H.move_to_delay = owner.movement_delay()
			to_chat(owner, "<span class='danger'><b>[src] betrays you!</b></span>")
		return BLOCK_NONE

/obj/item/shield/mirror/proc/readd()
	illusions++
	if(illusions == initial(illusions) && isliving(loc))
		var/mob/living/holder = loc
		to_chat(holder, "<span class='cult italic'>The shield's illusions are back at full strength!</span>")

/obj/item/shield/mirror/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	var/datum/thrownthing/D = throwingdatum
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(iscultist(L))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			if(L.put_in_active_hand(src))
				L.visible_message("<span class='warning'>[L] catches [src] out of the air!</span>")
			else
				L.visible_message("<span class='warning'>[src] bounces off of [L], as if repelled by an unseen force!</span>")
		else if(!..())
			if(!L.anti_magic_check())
				if(is_servant_of_ratvar(L))
					L.DefaultCombatKnockdown(60)
				else
					L.DefaultCombatKnockdown(30)
				if(D.thrower)
					for(var/mob/living/Next in orange(2, T))
						if(!Next.density || iscultist(Next))
							continue
						throw_at(Next, 3, 1, D.thrower)
						return
					throw_at(D.thrower, 7, 1, null)
	else
		..()
