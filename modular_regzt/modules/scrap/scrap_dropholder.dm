// Helper used by the scrap beacon: holds a freshly spawned pile for a moment,
// then drops it from the sky onto the target turf with a camera shake.
/obj/effect/falling_effect
	name = "you should not see this"
	desc = "no data"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	density = FALSE

/obj/effect/falling_effect/Initialize(mapload, atom/movable/object, spawn_type)
	. = ..()
	if(object)
		object.forceMove(src)
	else
		if(!spawn_type)
			spawn_type = pick_weight(GLOB.scrap_sparse_weighted)
		if(spawn_type)
			new spawn_type(src)

	return INITIALIZE_HINT_LATELOAD

/obj/effect/falling_effect/LateInitialize()
	. = ..()
	if(!length(contents))
		qdel(src)
		return
	// Pick one spawned atom back out so we can animate the actual result.
	var/atom/movable/dropped = pick(contents)
	dropped.forceMove(get_turf(src))
	if(dropped.pixel_z)
		dropped.pixel_z = 0
	var/initial_x = dropped.pixel_x
	var/initial_y = dropped.pixel_y
	dropped.plane = ABOVE_GAME_PLANE
	dropped.pixel_x = rand(-150, 150)
	dropped.pixel_y = 0
	dropped.pixel_z = 500
	dropped.density = FALSE
	dropped.opacity = FALSE
	animate(dropped, pixel_z = 0, pixel_x = initial_x, pixel_y = initial_y, time = 7)
	addtimer(CALLBACK(dropped, TYPE_PROC_REF(/atom/movable, end_fall)), 7)
	qdel(src)

/atom/movable/proc/end_fall()
	for(var/atom/movable/AM in loc)
		if(AM != src)
			AM.ex_act(EXPLODE_DEVASTATE)
	for(var/mob/living/M in viewers(6, src))
		shake_camera(M, 2, 2)
	if(istype(src, /obj/structure/scrap))
		playsound(src, 'modular_regzt/sound/effects/scrap_fall.ogg', 100)
	else
		playsound(src, 'sound/effects/meteorimpact.ogg', 100)
	density = initial(density)
	opacity = initial(opacity)
	plane = initial(plane)

/obj/effect/falling_effect/ex_act(severity, target)
	return
