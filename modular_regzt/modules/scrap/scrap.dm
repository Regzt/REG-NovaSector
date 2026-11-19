// TauCeti-style scrap piles. Adapted to the modern /tg/ codebase.
// Dig through piles with a shovel or rods, pull out unrefined scrap lumps,
// then feed those lumps into the recycler to get refined scrap.

/obj/structure/scrap
	name = "scrap pile"
	desc = "Pile of industrial debris. It could use a shovel and pair of hands in gloves."
	icon = 'modular_regzt/icons/obj/structures/scrap/base.dmi'
	icon_state = "small"
	appearance_flags = TILE_BOUND
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	max_integrity = 100

	/// Have we generated the hidden loot yet?
	var/loot_generated = FALSE
	/// Icon type key for the generated base image cache.
	var/icontype = "general"
	/// Weighted loot list used to fill the pile.
	var/list/weighted_loot_list = null
	/// Min / max amount of generated loot.
	var/loot_min = 3
	var/loot_max = 5
	/// How many digs are left before the pile disappears.
	var/dig_amount = 7
	/// Icon used for random pieces of debris in the base image.
	var/parts_icon = 'modular_regzt/icons/obj/structures/scrap/trash.dmi'
	/// Min / max number of random pieces of the base icon.
	var/base_min = 5
	var/base_max = 8
	/// Limits on pixel offsets of base pieces.
	var/base_spread = 12
	/// Chance that a larger item is hidden inside the pile.
	var/big_item_chance = 0
	/// The hidden large item, if any.
	var/obj/big_item
	/// Flavor verbs used while digging.
	var/list/ways = list("pokes around", "digs through", "rummages through", "goes through", "picks through")
	/// Internal storage holder for the accessible loot.
	var/atom/movable/loot_holder
	/// Cached base appearance built from random debris.
	var/mutable_appearance/base_image

	var/static/list/scrap_base_cache = list()
	var/static/list/scrap_big_items = list(
		/obj/structure/closet/crate = 5,
		/obj/structure/closet/crate/trashcart = 2,
		/obj/structure/reagent_dispensers/fueltank = 2,
		/obj/structure/reagent_dispensers/watertank = 2,
		/obj/machinery/vending/cola = 1,
		/obj/machinery/vending/snack = 1,
	)

/obj/structure/scrap/Initialize(mapload)
	if(isnull(weighted_loot_list))
		weighted_loot_list = GLOB.scrap_material
	. = ..()
	create_storage(max_slots = 7, max_specific_storage = WEIGHT_CLASS_BULKY, max_total_storage = 30)
	if(atom_storage)
		atom_storage.set_holdable(list(/obj/item))
		loot_holder = new /atom/movable(src)
		loot_holder.name = "hidden loot"
		atom_storage.set_real_location(loot_holder)
		RegisterSignal(loot_holder, COMSIG_ATOM_EXITED, PROC_REF(on_loot_taken))
	update_appearance()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/scrap/LateInitialize()
	. = ..()
	if(weighted_loot_list)
		try_make_loot()

/obj/structure/scrap/Destroy()
	if(big_item)
		QDEL_NULL(big_item)
	if(loot_holder)
		for(var/atom/movable/stored in loot_holder.contents)
			qdel(stored)
		QDEL_NULL(loot_holder)
	return ..()

/obj/structure/scrap/proc/on_loot_taken(datum/source, atom/movable/moved)
	SIGNAL_HANDLER
	update_appearance()

/obj/structure/scrap/proc/make_cube()
	var/obj/container = new /obj/structure/scrap_cube(loc, loot_max)
	forceMove(container)

/obj/structure/scrap/proc/get_loot_path()
	if(!weighted_loot_list)
		return null
	return pick_weight_recursive(weighted_loot_list)

/obj/structure/scrap/proc/amount_in_stack(path)
	if(ispath(path, /obj/item/stack/rods))
		return rand(3, 8)
	if(ispath(path, /obj/item/stack/sheet/plastic))
		return rand(5, 10)
	if(ispath(path, /obj/item/stack/sheet/iron))
		return rand(8, 12)
	if(ispath(path, /obj/item/stack/sheet/glass))
		return rand(5, 10)
	if(ispath(path, /obj/item/stack/sheet/plasteel))
		return rand(1, 3)
	if(ispath(path, /obj/item/stack/sheet/mineral/wood))
		return rand(3, 8)
	if(ispath(path, /obj/item/stack/cable_coil))
		return rand(10, 20)
	return rand(20, 40)

/obj/structure/scrap/proc/spawn_loot(loot_path)
	if(ispath(loot_path, /obj/effect/spawner))
		var/obj/effect/spawner/spawner = new loot_path(src)
		if(spawner && !QDELETED(spawner))
			qdel(spawner)
		return null
	if(ispath(loot_path, /obj/item/stack))
		var/stack_amount = amount_in_stack(loot_path)
		if(stack_amount <= 0)
			return null
		return new loot_path(src, stack_amount)
	if(ispath(loot_path, /obj/item))
		return new loot_path(src)
	return null

/obj/structure/scrap/proc/make_big_loot()
	if(!big_item_chance || !prob(big_item_chance))
		return
	var/big_type = pick_weight(scrap_big_items)
	if(!big_type)
		return
	big_item = new big_type(src)
	if(big_item)
		big_item.forceMove(src)
		if(prob(66))
			big_item.make_old()

/obj/structure/scrap/proc/try_make_loot()
	if(loot_generated)
		return
	loot_generated = TRUE
	if(!big_item)
		make_big_loot()
	var/amt = rand(loot_min, loot_max)
	for(var/i in 1 to amt)
		var/loot_path = get_loot_path()
		if(!loot_path)
			continue
		spawn_loot(loot_path)
	for(var/obj/item/piece in contents)
		if(prob(66))
			piece.make_old()
	distribute_loot()

/// Moves a random part of the hidden loot into the accessible internal storage.
/obj/structure/scrap/proc/distribute_loot()
	if(!loot_holder)
		return
	for(var/atom/movable/stored in loot_holder.contents)
		stored.forceMove(src)
	var/num = rand(1, loot_min)
	var/list/candidates = list()
	for(var/obj/item/piece in contents)
		if(piece == big_item)
			continue
		candidates += piece
	candidates = shuffle(candidates)
	for(var/obj/item/piece in candidates)
		if(num <= 0)
			break
		piece.forceMove(loot_holder)
		num--
	update_appearance()

/obj/structure/scrap/proc/shuffle_loot()
	if(!loot_generated)
		try_make_loot()
	else
		distribute_loot()

/obj/structure/scrap/proc/randomize_image(image/I)
	I.pixel_x = rand(-base_spread, base_spread)
	I.pixel_y = rand(-base_spread, base_spread)
	var/matrix/M = matrix()
	M.Turn(pick(0, 90, 180, 270))
	I.transform = M
	return I

/obj/structure/scrap/proc/build_base_image()
	if(base_image)
		return
	var/cache_key = "[icontype][icon_state][rand(40)]"
	if(!scrap_base_cache[cache_key])
		var/num = rand(base_min, base_max)
		var/mutable_appearance/assembled = mutable_appearance(icon, icon_state)
		var/list/possible_parts = icon_states(parts_icon)
		for(var/i in 1 to num)
			if(!length(possible_parts))
				break
			var/part_state = pick(possible_parts)
			if(!part_state)
				continue
			var/mutable_appearance/part = mutable_appearance(parts_icon, part_state)
			part.color = pick("#996633", "#663300", "#666666", null)
			randomize_image(part)
			assembled.add_overlay(part)
		scrap_base_cache[cache_key] = assembled
	base_image = scrap_base_cache[cache_key]

/obj/structure/scrap/update_overlays()
	. = ..()
	build_base_image()
	if(base_image)
		. += base_image
	if(loot_generated && loot_holder)
		for(var/obj/O in loot_holder.contents)
			var/mutable_appearance/loot_image = mutable_appearance(O.icon, O.icon_state)
			loot_image.color = O.color
			randomize_image(loot_image)
			. += loot_image
	if(big_item)
		var/mutable_appearance/big_image = mutable_appearance(big_item.icon, big_item.icon_state)
		big_image.color = big_item.color
		. += big_image

/obj/structure/scrap/proc/hurt_hand(mob/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/victim = user
	if(victim.gloves || HAS_TRAIT(victim, TRAIT_LIGHT_STEP))
		return FALSE
	if(prob(50))
		to_chat(user, span_danger("Ouch! You cut yourself while picking through \the [src]."))
		var/obj/item/bodypart/affecting = victim.get_bodypart(pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		if(affecting)
			affecting.receive_damage(5)
		victim.reagents?.add_reagent(/datum/reagent/toxin, pick(0, 0, 5, 10, 25))
		return TRUE
	return FALSE

/obj/structure/scrap/attack_hand(mob/user, list/modifiers)
	if(hurt_hand(user))
		return
	try_make_loot()
	if(atom_storage)
		atom_storage.open_storage(user)
	return ..()

/obj/structure/scrap/attack_paw(mob/user, list/modifiers)
	try_make_loot()
	if(atom_storage)
		atom_storage.open_storage(user)
	return ..()

/obj/structure/scrap/proc/dig_out_lump(newloc = loc, hard_dig = FALSE)
	dig_amount--
	if(dig_amount <= 0)
		visible_message(span_notice("\The [src] is cleared out!"))
		if(!hard_dig && big_item)
			big_item.forceMove(get_turf(src))
			big_item = null
		qdel(src)
		return FALSE
	new /obj/item/scrap_lump(newloc)
	return TRUE

/obj/structure/scrap/proc/dig_act(obj/item/tool, mob/living/user, delay = 3 SECONDS)
	if(!tool || !user)
		return
	user.do_attack_animation(src)
	if(!tool.use_tool(src, user, delay, volume = 50))
		return
	if(QDELETED(src))
		return
	visible_message(span_notice("\The [user] [pick(ways)] \the [src]."))
	shuffle_loot()
	dig_out_lump(user.loc, FALSE)

/obj/structure/scrap/shovel_act(mob/living/user, obj/item/tool)
	dig_act(tool, user, 3 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/structure/scrap/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool.tool_behaviour == TOOL_SHOVEL)
		dig_act(tool, user, 3 SECONDS)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/stack/rods))
		dig_act(tool, user, 5 SECONDS)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/structure/scrap/Crossed(atom/movable/crosser, old_loc)
	if(ismob(crosser) && !HAS_TRAIT(crosser, TRAIT_LIGHT_STEP))
		playsound(src, 'sound/effects/footstep/glass_step.ogg', 50)
		if(ishuman(crosser))
			var/mob/living/carbon/human/walker = crosser
			if(walker.buckled || walker.shoes)
				return ..()
			if(walker.wear_suit && (walker.wear_suit.body_parts_covered & LEGS))
				return ..()
			to_chat(walker, span_danger("You step on the sharp debris!"))
			walker.Paralyze(2 SECONDS)
			walker.adjust_brute_loss(5)
			walker.reagents?.add_reagent(/datum/reagent/toxin, pick(0, 0, 5, 10, 25))
	. = ..()

/obj/structure/scrap/ex_act(severity, target)
	if(prob(25))
		new /obj/effect/particle_effect/fluid/smoke(loc)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			new /obj/effect/scrapshot(loc, 1)
			dig_amount = 0
		if(EXPLODE_HEAVY)
			new /obj/effect/scrapshot(loc, 2)
			dig_amount = round(dig_amount / 3)
		if(EXPLODE_LIGHT)
			dig_amount = round(dig_amount / 2)
	if(dig_amount < 4)
		qdel(src)
	else
		update_appearance()

// Scatters scrap everywhere when the pile is blown up.
/obj/effect/scrapshot
	name = "this thing shoots scrap everywhere with a delay"
	desc = "no data"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	density = FALSE

/obj/effect/scrapshot/Initialize(mapload, severity = 1)
	. = ..()
	switch(severity)
		if(1)
			for(var/i in 1 to 12)
				var/projtype = pick(/obj/item/stack/rods, /obj/item/shard)
				var/obj/item/projectile = new projtype(loc)
				projectile.throw_at(locate(loc.x + rand(40) - 20, loc.y + rand(40) - 20, loc.z), 81, pick(1, 3, 80, 80))
		if(2)
			for(var/i in 1 to 4)
				var/projtype = pick(subtypesof(/obj/item/trash))
				var/obj/item/projectile = new projtype(loc)
				projectile.throw_at(locate(loc.x + rand(10) - 5, loc.y + rand(10) - 5, loc.z), 3, 1)
	return INITIALIZE_HINT_QDEL

// --- PILE TYPES ---

/obj/structure/scrap/large
	name = "large scrap pile"
	opacity = TRUE
	density = TRUE
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16

/obj/structure/scrap/newyear
	weighted_loot_list = null
	loot_min = 3
	loot_max = 5

/obj/structure/scrap/newyear/Initialize(mapload)
	weighted_loot_list = GLOB.scrap_newyear
	return ..()

/obj/structure/scrap/medical
	icontype = "medical"
	name = "medical refuse pile"
	desc = "Pile of medical refuse. They sure don't cut expenses on these."
	parts_icon = 'modular_regzt/icons/obj/structures/scrap/medical_trash.dmi'

/obj/structure/scrap/medical/Initialize(mapload)
	weighted_loot_list = GLOB.scrap_medical
	return ..()

/obj/structure/scrap/vehicle
	icontype = "vehicle"
	name = "industrial debris pile"
	desc = "Pile of used machinery. You could use tools from this to build something."
	parts_icon = 'modular_regzt/icons/obj/structures/scrap/vehicle.dmi'

/obj/structure/scrap/vehicle/Initialize(mapload)
	weighted_loot_list = GLOB.scrap_industrial
	return ..()

/obj/structure/scrap/food
	icontype = "food"
	name = "food trash pile"
	desc = "Pile of thrown away food. Someone sure has lots of spare food while children on Mars are starving."
	parts_icon = 'modular_regzt/icons/obj/structures/scrap/food_trash.dmi'

/obj/structure/scrap/food/Initialize(mapload)
	weighted_loot_list = GLOB.scrap_food
	return ..()

/obj/structure/scrap/guns
	icontype = "guns"
	name = "gun refuse pile"
	desc = "Pile of military supply refuse. Who thought it was a clever idea to throw that out?"
	parts_icon = 'modular_regzt/icons/obj/structures/scrap/guns_trash.dmi'

/obj/structure/scrap/guns/Initialize(mapload)
	weighted_loot_list = GLOB.scrap_guns
	return ..()

/obj/structure/scrap/science
	icontype = "science"
	name = "scientific trash pile"
	desc = "Pile of refuse from research department."
	parts_icon = 'modular_regzt/icons/obj/structures/scrap/science.dmi'

/obj/structure/scrap/science/Initialize(mapload)
	weighted_loot_list = GLOB.scrap_science
	return ..()

/obj/structure/scrap/science_safe
	icontype = "science"
	name = "scientific trash pile"
	desc = "Pile of refuse from research department."
	parts_icon = 'modular_regzt/icons/obj/structures/scrap/science.dmi'

/obj/structure/scrap/science_safe/Initialize(mapload)
	weighted_loot_list = GLOB.scrap_science
	return ..()

/obj/structure/scrap/cloth
	icontype = "cloth"
	name = "cloth pile"
	desc = "Pile of second hand clothing for charity."
	parts_icon = 'modular_regzt/icons/obj/structures/scrap/cloth.dmi'

/obj/structure/scrap/cloth/Initialize(mapload)
	weighted_loot_list = GLOB.scrap_cloth
	return ..()

/obj/structure/scrap/cloth_safe
	icontype = "cloth"
	name = "cloth pile"
	desc = "Pile of second hand clothing for charity."
	parts_icon = 'modular_regzt/icons/obj/structures/scrap/cloth.dmi'

/obj/structure/scrap/cloth_safe/Initialize(mapload)
	weighted_loot_list = GLOB.scrap_cloth
	return ..()

/obj/structure/scrap/syndie
	icontype = "syndie"
	name = "strange pile"
	desc = "Pile of left magbots, broken teleports and phoron tanks, jetpacks, random station blueprints, soap, burned RCDs, and meat with orange fur?"
	parts_icon = 'modular_regzt/icons/obj/structures/scrap/syndie.dmi'
	loot_min = 2
	loot_max = 4

/obj/structure/scrap/syndie/Initialize(mapload)
	weighted_loot_list = GLOB.scrap_syndie
	return ..()

/obj/structure/scrap/poor
	icontype = "poor"
	name = "mixed rubbish"
	desc = "Pile of mixed rubbish. Useless and rotten, mostly."
	parts_icon = 'modular_regzt/icons/obj/structures/scrap/all_mixed.dmi'

/obj/structure/scrap/poor/Initialize(mapload)
	weighted_loot_list = GLOB.scrap_poor
	return ..()

// --- LARGE PILES ---

/obj/structure/scrap/poor/large
	name = "large mixed rubbish"
	opacity = TRUE
	density = TRUE
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	big_item_chance = 40

/obj/structure/scrap/vehicle/large
	name = "large industrial debris pile"
	opacity = TRUE
	density = TRUE
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/food/large
	name = "large food trash pile"
	opacity = TRUE
	density = TRUE
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/medical/large
	name = "large medical refuse pile"
	opacity = TRUE
	density = TRUE
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/guns/large
	name = "large gun refuse pile"
	opacity = TRUE
	density = TRUE
	icon_state = "big"
	loot_min = 10
	loot_max = 15
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/science/large
	name = "large scientific trash pile"
	opacity = TRUE
	density = TRUE
	icon_state = "big"
	loot_min = 10
	loot_max = 20
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/cloth/large
	name = "large cloth pile"
	opacity = TRUE
	density = TRUE
	icon_state = "big"
	loot_min = 8
	loot_max = 14
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/syndie/large
	name = "large strange pile"
	opacity = TRUE
	density = TRUE
	icon_state = "big"
	loot_min = 4
	loot_max = 12
	dig_amount = 15
	base_min = 9
	base_max = 14
	base_spread = 16
	big_item_chance = 33

/obj/structure/scrap/poor/structure
	name = "large mixed rubbish"
	opacity = TRUE
	density = TRUE
	icon_state = "med"
	loot_min = 3
	loot_max = 6
	dig_amount = 3
	base_min = 3
	base_max = 6
	big_item_chance = 100

/obj/structure/scrap/poor/structure/make_big_loot()
	..()
	if(big_item)
		visible_message(span_notice("\The [src] reveals [big_item] underneath the trash!"))
