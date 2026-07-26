/*
/obj/item/card/id
	var/wildcard_expanded = null
/obj/item/card/id/Initialize(mapload)
	. = ..()
	if(CONFIG_GET(flag/infinite_access_slots) && wildcard_expanded)
		wildcard_slots = wildcard_expanded
	wildcard_expanded = null

/obj/item/card/id/advanced
	wildcard_expanded = WILDCARD_LIMIT_GOLD

/obj/item/card/id/advanced/prisoner
	wildcard_expanded = null

/obj/item/card/id/advanced/centcom
	wildcard_expanded = null

/obj/item/card/id/advanced/centcom/station
	wildcard_expanded = WILDCARD_LIMIT_GOLD

/obj/item/card/id/advanced/debug
	wildcard_expanded = null

/obj/item/card/id/advanced/highlander
	wildcard_expanded = null

/obj/item/card/id/advanced/factory
	wildcard_expanded = null

/obj/item/card/id/advanced/solfed
	wildcard_expanded = null

/obj/item/card/id/advanced/armadyne
	wildcard_expanded = null

/obj/item/card/id/advanced/tarkon
	wildcard_expanded = null

/obj/item/card/id/advanced/black
	wildcard_expanded = null

/obj/item/card/id/advanced/visitor
	wildcard_expanded = null

/obj/item/card/id/advanced/simple_bot
	wildcard_expanded = null

/obj/item/card/id/advanced/chameleon
	wildcard_expanded = WILDCARD_LIMIT_CHAMELEON_ID_EXPANDED

/obj/item/card/id/advanced/chameleon/ghost_cafe
	wildcard_expanded = null\

/obj/item/card/id/advanced/chameleon/attack_self(mob/user)
	if(!user.can_perform_action(user, NEED_DEXTERITY | FORBID_TELEKINESIS_REACH))
		return ..()
	var/popup_input = tgui_input_list(user, "Choose Action", "Agent ID", list("Show", "Forge/Reset", "Change Account ID"))
	if(!popup_input || !after_input_check(user))
		return TRUE
	switch(popup_input)
		if("Change Account ID")
			set_new_account(user)
			return
		if("Show")
			return ..()
*/
