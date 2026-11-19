#define ONE_LOG_BURN_TIME 1200

// Rags are a one-use stack used to turn wood into torches.
/obj/item/stack/medical/bruise_pack/rags
	name = "rags"
	singular_name = "rag"
	desc = "Some rags."
	amount = 1
	max_amount = 1
	icon_state = "gauze"
	merge_type = /obj/item/stack/medical/bruise_pack/rags

/obj/item/stack/medical/bruise_pack/rags/Initialize(mapload, new_amount = 1, merge = FALSE, force_old = FALSE, old_chance = 33)
	. = ..(mapload, new_amount, merge)
	if(. == INITIALIZE_HINT_QDEL)
		return .
	if(force_old || prob(old_chance))
		make_old()

/obj/item/stack/medical/bruise_pack/rags/old/Initialize(mapload, new_amount = 1, merge = FALSE)
	. = ..(mapload, new_amount, merge, TRUE)

/obj/item/stack/medical/bruise_pack/rags/not_old/Initialize(mapload, new_amount = 1, merge = FALSE)
	. = ..(mapload, new_amount, merge, FALSE, 0)

/obj/item/stack/medical/bruise_pack/rags/make_old()
	. = ..()
	desc += " May infect your wounds."

/obj/item/stack/sheet/mineral/wood/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stack/medical/bruise_pack/rags))
		var/obj/item/stack/medical/bruise_pack/rags/rags = tool
		if(!use(1))
			return ITEM_INTERACT_BLOCKING
		new /obj/item/flashlight/flare/torch(drop_location())
		qdel(rags)
		return ITEM_INTERACT_SUCCESS
	return ..()

// A bonfire made from scavenged wood that slowly burns down.
/obj/structure/bonfire/dynamic
	icon = 'modular_regzt/icons/obj/structures/scrap/bonfire.dmi'
	burn_icon = "bonfire_on_fire"

	var/logs = 10
	var/time_log_burned_out = 0

/obj/structure/bonfire/dynamic/Initialize(mapload)
	. = ..()
	time_log_burned_out = world.time + ONE_LOG_BURN_TIME

/obj/structure/bonfire/dynamic/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stack/sheet/mineral/wood))
		var/obj/item/stack/sheet/mineral/wood/wood = tool
		if(wood.amount < 1)
			return NONE
		wood.use(1)
		logs++
		to_chat(user, span_notice("You add a log to \the [src]. It now has [logs] logs."))
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/structure/bonfire/dynamic/process(seconds_per_tick)
	. = ..()
	if(!burning)
		return
	if(world.time > time_log_burned_out)
		if(logs > 0)
			logs--
			if(prob(40))
				new /obj/effect/decal/cleanable/ash(drop_location())
			time_log_burned_out = world.time + ONE_LOG_BURN_TIME
		else
			extinguish()
	if(logs <= 0 && icon_state != "bonfire_warm")
		icon_state = "bonfire_warm"

/obj/structure/bonfire/dynamic/extinguish()
	. = ..()
	if(logs <= 0)
		new /obj/effect/decal/cleanable/ash(drop_location())
		qdel(src)

/obj/structure/bonfire/dynamic/attack_hand(mob/user, list/modifiers)
	if(burning)
		to_chat(user, span_warning("You need to extinguish [src] before removing it!"))
		return
	if(!has_buckled_mobs() && do_after(user, 5 SECONDS, target = src))
		if(logs > 0)
			new /obj/item/stack/sheet/mineral/wood(drop_location(), logs)
		qdel(src)

/obj/structure/bonfire/dynamic/examine(mob/user)
	. = ..()
	if(get_dist(src, user) <= 2)
		. += span_notice("There [logs == 1 ? "is" : "are"] [logs] log[logs == 1 ? "" : "s"] in [src].")

#undef ONE_LOG_BURN_TIME
