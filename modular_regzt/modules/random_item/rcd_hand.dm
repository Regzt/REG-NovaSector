/*/obj/item/melee/arm_blade

/obj/item/goliath_infuser_hammer

/obj/item/bodypart/arm/right/robot/rcd
	name = "rcd right arm"
	desc = "robotic limb with a built-in battery-powered RCD"
	attack_verb_simple = list("slapped", "punched")
	inhand_icon_state = "buildpipe"
	icon_static = 'icons/mob/augmentation/augments.dmi'
	icon = 'icons/mob/augmentation/augments.dmi'
	limb_id = BODYPART_ID_ROBOTIC
	obj_flags = CONDUCTS_ELECTRICITY
	icon_state = "borg_r_arm"
	*/

/obj/item/organ/cyberimp/arm/toolkit/rcd
	name = "integrated RCD implant"
	desc = "integrated RCD"
	icon_state = "toolkit_generic"
	actions_types = list(/datum/action/item_action/organ_action/toggle/toolkit)
	items_to_create = list(
		/obj/item/construction/rcd/borg/hand,
	)

/obj/item/construction/rcd/borg/hand
	name = "handheld RCD"
	desc = "A modified rapid construction device. The cell compartment can be opened with a screwdriver."
	banned_upgrades = RCD_UPGRADE_SILO_LINK

	var/obj/item/stock_parts/power_store/inserted_cell = null

/obj/item/construction/rcd/borg/hand/New()
	..()
	energyfactor = 0.072 * STANDARD_CELL_CHARGE

/obj/item/construction/rcd/borg/hand/Destroy()
	QDEL_NULL(inserted_cell)
	return ..()

/obj/item/construction/rcd/borg/hand/get_matter(mob/user)
	if(!inserted_cell)
		return 0

	max_matter = inserted_cell.maxcharge
	return inserted_cell.charge

/obj/item/construction/rcd/borg/hand/useResource(amount, mob/user, dry_run)
	if(!inserted_cell)
		balloon_alert(user, "no cell installed!")
		return FALSE

	if(inserted_cell.charge < (amount * energyfactor))
		balloon_alert(user, "insufficient charge!")
		return FALSE

	if(!dry_run)
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		return inserted_cell.use(amount * energyfactor)

	return TRUE

/obj/item/construction/rcd/borg/hand/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/power_store))
		if(inserted_cell)
			to_chat(user, span_warning("There is already a power cell installed in [src]!"))
			return

		if(user.temporarilyRemoveItemFromInventory(I))
			I.forceMove(src)
			inserted_cell = I
			to_chat(user, span_notice("You insert [I] into [src]."))
			return

	return ..()

/obj/item/construction/rcd/borg/hand/screwdriver_act(mob/living/user, obj/item/tool)
	if(!inserted_cell)
		to_chat(user, span_warning("There is no power cell inside [src]."))
		return FALSE

	tool.play_tool_sound(src)
	to_chat(user, span_notice("You pop the latch with [tool] and remove [inserted_cell] from [src]."))

	user.put_in_hands(inserted_cell)
	inserted_cell = null

	return TRUE
