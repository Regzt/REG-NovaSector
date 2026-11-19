// Refined scrap chain: unrefined lumps are produced by piles, fed into a
// recycler to become cubes, and cubes are smashed open into refined scrap.
/obj/structure/scrap_cube
	name = "compressed scrap"
	desc = "A cube made of scrap compressed with hydraulic clamp."
	density = TRUE
	anchored = FALSE
	icon_state = "trash_cube"
	icon = 'modular_regzt/icons/obj/structures/scrap/refine.dmi'

/obj/structure/scrap_cube/Initialize(mapload, size = -1)
	if(size < 0)
		var/scrap_type = pick_weight(GLOB.scrap_sparse_weighted)
		if(scrap_type)
			new scrap_type(src)
	. = ..()
	AddElement(/datum/element/beauty, -150)

/obj/structure/scrap_cube/proc/make_pile()
	for(var/obj/item/stored in contents)
		stored.forceMove(loc)
	qdel(src)

/obj/structure/scrap_cube/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool))
		return ..()
	user.do_attack_animation(src)
	if(tool.force >= 8)
		visible_message(span_notice("\The [user] smashes \the [src], restoring its original form."))
		make_pile()
	else
		visible_message(span_notice("\The [user] smashes \the [src], but [tool] is too weak to break it!"))
	return ITEM_INTERACT_SUCCESS

/obj/item/scrap_lump
	name = "unrefined scrap"
	desc = "This thing is messed up beyond any recognition. Into the grinder it goes!"
	icon = 'modular_regzt/icons/obj/structures/scrap/refine.dmi'
	icon_state = "unrefined"
	w_class = WEIGHT_CLASS_TINY

/obj/item/scrap_lump/Initialize(mapload)
	. = ..()
	pixel_x = rand(0, 16) - 8
	pixel_y = rand(0, 8) - 8
	AddElement(/datum/element/beauty, -20)

GLOBAL_LIST_INIT(scrap_recipes, list(
	new /datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/costume/cardborg, 3, crafting_flags = NONE, category = CAT_CLOTHING),
	new /datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/costume/cardborg, crafting_flags = NONE, category = CAT_CLOTHING),
))

/obj/item/stack/sheet/refined_scrap
	name = "refined scrap"
	desc = "This is ghetto gold! It could be used as fuel or building material. Even Central Command would give credits for this."
	icon = 'modular_regzt/icons/obj/structures/scrap/refine.dmi'
	icon_state = "refined"
	singular_name = "refined scrap sheet"
	max_amount = 20
	amount = 1
	merge_type = /obj/item/stack/sheet/refined_scrap

/obj/item/stack/sheet/refined_scrap/Initialize(mapload, new_amount = 1, merge = TRUE)
	. = ..()
	AddElement(/datum/element/beauty, -15)

/obj/item/stack/sheet/refined_scrap/get_main_recipes()
	. = ..()
	. += GLOB.scrap_recipes
