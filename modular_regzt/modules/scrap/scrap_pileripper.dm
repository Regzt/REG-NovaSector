// The pile ripper eats the turf in front of it, grinding piles into lumps.
/obj/machinery/pile_ripper
	parent_type = /obj/machinery/recycler
	name = "pile ripper"
	desc = "This machine rips everything in front of it apart."
	icon = 'modular_regzt/icons/obj/structures/scrap/recycling.dmi'
	icon_state = "grinder-b0"
	base_icon_state = "grinder-b"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 300
	circuit = /obj/item/circuitboard/machine/pile_ripper

	var/rating = 1
	var/last_ripped = 0

/obj/machinery/pile_ripper/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSmachines, src)

/obj/machinery/pile_ripper/Destroy()
	STOP_PROCESSING(SSmachines, src)
	return ..()

/obj/machinery/pile_ripper/RefreshParts()
	. = ..()
	for(var/datum/stock_part/servo/servo in component_parts)
		rating = servo.tier

/obj/machinery/pile_ripper/process()
	if(machine_stat & (BROKEN|NOPOWER))
		return
	if(last_ripped > world.time)
		return
	last_ripped = world.time + 1 SECONDS
	if(safety_mode)
		playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
		safety_mode = FALSE
		update_appearance()
	var/turf/ripped_turf = get_step(src, dir)
	if(!ripped_turf)
		return
	for(var/mob/living/poor_soul in ripped_turf)
		if((obj_flags & EMAGGED) || prob(25))
			devour(poor_soul)
		else
			stop(poor_soul)
	var/count = 0
	for(var/obj/ripped_item in ripped_turf)
		if(count >= rating)
			break
		if(istype(ripped_item, /obj/structure/scrap))
			var/obj/structure/scrap/pile = ripped_item
			while(pile.dig_out_lump(loc, TRUE))
				if(prob(20))
					break
			count++
		else if(istype(ripped_item, /obj/structure/scrap_cube))
			var/obj/structure/scrap_cube/cube = ripped_item
			cube.make_pile()
			count++
		else if(isitem(ripped_item))
			ripped_item.forceMove(loc)
			if(prob(20))
				qdel(ripped_item)
			count++

/obj/machinery/pile_ripper/proc/stop(mob/living/victim)
	playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 50, FALSE)
	safety_mode = TRUE
	update_appearance()
	victim.forceMove(loc)
	addtimer(CALLBACK(src, PROC_REF(restart_after_safety)), 10 SECONDS)

/obj/machinery/pile_ripper/proc/restart_after_safety()
	if(machine_stat & (BROKEN|NOPOWER))
		return
	safety_mode = FALSE
	update_appearance()

/obj/machinery/pile_ripper/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	if(safety_mode)
		safety_mode = FALSE
		update_appearance()
	playsound(src, /datum/sound_effect/sparks, 75, TRUE, SILENCED_SOUND_EXTRARANGE)
	balloon_alert(user, "safeties disabled")
	return FALSE

/obj/machinery/pile_ripper/proc/devour(mob/living/victim)
	if(issilicon(victim))
		playsound(src, 'sound/items/tools/welder.ogg', 50, TRUE)
	else
		playsound(src, 'sound/effects/splat.ogg', 50, TRUE)

	if(iscarbon(victim))
		if(!IS_UNCONSCIOUS_OR_CRIT(victim))
			victim.emote("scream")
		add_mob_blood(victim)
		bloody = TRUE
	else
		victim.gib()

	victim.Unconscious(100)
	victim.adjust_brute_loss(crush_damage)
	for(var/obj/item/equipped in victim.get_equipped_items())
		victim.dropItemToGround(equipped)
	update_appearance()

/obj/item/circuitboard/machine/pile_ripper
	name = "Pile Ripper"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/pile_ripper
	req_components = list(
		/datum/stock_part/servo = 1)
