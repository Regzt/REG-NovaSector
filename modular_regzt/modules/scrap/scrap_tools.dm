// Industrial trash bag that only accepts unrefined scrap lumps.
/datum/storage/bag/trash/miners
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_total_storage = 30
	max_slots = 30

/datum/storage/bag/trash/miners/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(/obj/item/scrap_lump))

/obj/item/storage/bag/trash/miners
	name = "industrial trash bag"
	desc = "Instead of a usual trash bag, this one comes with a self-compressing mechanism, which allows it to hold a huge amount of trash inside. It has a smart vacuum pull system which takes in only trash. Very expensive for a trash bag!"
	icon = 'icons/obj/service/janitor.dmi'
	icon_state = "trashbag"
	inhand_icon_state = "trashbag"
	color = COLOR_RED
	storage_type = /datum/storage/bag/trash/miners

/obj/item/paper/crumpled/bloody/dickbutt
	default_raw_text = "<p><img src=paper_dickbutt.png></p>"
	layer = 2.9
