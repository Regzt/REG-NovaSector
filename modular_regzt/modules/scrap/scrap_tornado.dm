// A roaming tornado of scrap, built on top of the singularity machinery.
/obj/singularity/scrap_ball
	name = "tornado"
	desc = "Holy shit, run!"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "tornado"
	color = "#666666"
	alpha = 200
	current_size = STAGE_TWO
	maximum_stage = STAGE_TWO
	pixel_x = -64
	pixel_y = -64
	move_self = FALSE
	event_chance = 5
	layer = 8
	density = TRUE
	anchored = FALSE
	dissipate = FALSE

/obj/singularity/scrap_ball/check_energy()
	return

/obj/singularity/scrap_ball/process(seconds_per_tick)
	if(!loc)
		return
	step(src, pick(GLOB.alldirs))
	var/datum/component/orbiter/orbit_holder = GetComponent(/datum/component/orbiter)
	if(orbit_holder)
		for(var/atom/movable/orbiter as anything in orbit_holder.orbiter_list)
			if(!isliving(orbiter))
				continue
			var/mob/living/victim = orbiter
			victim.adjust_brute_loss(10)
			victim.Paralyze(2 SECONDS)
	if(prob(event_chance))
		event()

/obj/singularity/scrap_ball/event()
	for(var/mob/living/carbon/victim in viewers(8, src))
		if(isbrain(victim))
			continue
		to_chat(victim, span_danger("You [pick("look in awe at", "can't withstand")] \the [src.name]."))
		victim.Paralyze(3 SECONDS)
	return TRUE

/obj/singularity/scrap_ball/consume(atom/thing)
	if(!loc)
		return
	if(!istype(thing, /obj) && !istype(thing, /mob))
		return
	var/atom/movable/to_add = thing
	if(to_add.anchored || to_add.orbiting)
		return
	if(get_area(to_add) != get_area(src))
		return
	if(isliving(to_add))
		var/mob/living/victim = to_add
		victim.Paralyze(5 SECONDS)
	var/icon/scrap_icon = icon(icon, icon_state, dir)
	var/orbitsize = (scrap_icon.Width() + scrap_icon.Height()) * pick(0.3, 0.2, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9)
	orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)
	to_add.orbit(src, orbitsize, TRUE, rand(8, 30), 36)

/obj/singularity/scrap_ball/Bump(atom/bumped)
	consume(bumped)
	return

/obj/singularity/scrap_ball/Bumped(atom/bumped)
	consume(bumped)

/obj/singularity/scrap_ball/update_icon_state()
	return

/obj/singularity/scrap_ball/update_overlays()
	return list()
