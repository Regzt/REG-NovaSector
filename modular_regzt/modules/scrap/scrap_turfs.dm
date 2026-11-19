// Turf helpers and generation for the junkyard.

/obj/effect/scrap_pile_generator
	name = "Generates Scrap Pile"
	icon_state = "rock"
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/scrap_pile_generator/Initialize(mapload, heap_size = 1)
	. = ..()
	var/size
	var/maintype = /obj/structure/scrap
	switch(heap_size)
		if(1)
			size = pick(5, 5, 7, 7, 12)
			maintype = /obj/structure/scrap
		if(2)
			size = pick(7, 12, 20)
			maintype = /obj/structure/scrap/large
		if(3)
			size = pick(20, 20, 30)
			maintype = /obj/structure/scrap/large

	var/list/makescrap = list()
	var/list/makesparse = list()
	var/turf/origin = get_turf(src)
	if(!origin)
		return
	makescrap += origin

	for(var/i = 0 to size)
		var/turf/to_add = get_step(pick(makescrap), pick(GLOB.alldirs))
		if(to_add && !to_add.density)
			makescrap |= to_add
	for(var/turf/T in makescrap)
		for(var/todir in GLOB.cardinals)
			var/turf/neighbor = get_step(T, todir)
			if(neighbor)
				makesparse |= neighbor
	makesparse -= makescrap
	for(var/turf/T in makescrap)
		if(!(locate(/obj/structure/scrap) in T.contents))
			new maintype(T)
	for(var/turf/T in makesparse)
		if(!(locate(/obj/structure/scrap) in T.contents))
			new /obj/structure/scrap(T)

/turf/proc/surround_by_scrap()
	return FALSE

// Don't let the junk piles spawn inside solid rock.
/turf/open/misc/ironsand/junkyard
	var/dug = FALSE

/turf/open/misc/ironsand/junkyard/surround_by_scrap()
	if(prob(1))
		new /obj/item/blueprints/junkyard(src)
	if(prob(2))
		new /obj/structure/scrap/poor/structure(src)
	if(prob(4))
		new /obj/effect/spawner/random/trash/garbage(src)
	if(prob(4))
		new /obj/structure/scrap(src)
	if(prob(6))
		var/decals_spawn = pick(
			/obj/effect/decal/cleanable/generic,
			/obj/effect/decal/cleanable/ash,
			/obj/effect/decal/cleanable/molten_object,
			/obj/effect/decal/cleanable/vomit,
			/obj/effect/decal/cleanable/blood/oil,
		)
		new decals_spawn(src)
	if(prob(6))
		new /obj/effect/spawner/random/food_or_drink(src)
	return TRUE

/turf/open/misc/ironsand/junkyard/safe
	icon_state = "ironsand2"

/turf/open/misc/ironsand/junkyard/safe/surround_by_scrap()
	if(..())
		if(prob(1))
			new /obj/effect/scrap_pile_generator(src, 1)
			return TRUE
		if(prob(1))
			new /obj/effect/landmark/junkyard_bum(src)
			return TRUE

/turf/open/misc/ironsand/junkyard/challenging
	icon_state = "ironsand3"

/turf/open/misc/ironsand/junkyard/challenging/surround_by_scrap()
	if(..())
		if(prob(1))
			new /obj/effect/scrap_pile_generator(src, 2)
			return TRUE

/turf/open/misc/ironsand/junkyard/dangerous
	icon_state = "ironsand4"

/turf/open/misc/ironsand/junkyard/dangerous/surround_by_scrap()
	if(..())
		if(prob(1))
			new /obj/effect/scrap_pile_generator(src, 3)
			return TRUE

/obj/item/blueprints/junkyard
	name = "junkyard blueprints"
	desc = "A faded set of plans for a junkyard. Mostly just doodles of trash."

/obj/effect/landmark/junkyard_bum
	name = "Junkyard Bum"
	icon_state = "x"
