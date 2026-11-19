// TauCeti-style "oldification" of loot. Adapted to the modern /tg/ codebase.
/obj
	var/oldificated = FALSE

/obj/proc/make_old(change_looks = TRUE)
	color = pick("#996633", "#663300", "#666666")
	light_color = color
	if(change_looks)
		name = pick("old ", "expired ", "dirty ") + initial(name)
		desc += pick(" Warranty has expired.", " The inscriptions on this thing were erased by time.", " Looks completely wasted.")
	if(prob(40))
		if(prob(70))
			light_power = light_power / pick(1.5, 2, 2.5)
		if(prob(70))
			light_range = light_range / pick(1.5, 2, 2.5)
		if(prob(15))
			light_range = 0
			light_power = 0
	for(var/obj/item/sub_item in contents)
		sub_item.make_old()
	update_appearance()
	oldificated = TRUE

/obj/item/make_old()
	..()
	siemens_coefficient += 0.3

/obj/item/storage/make_old()
	var/del_count = rand(0, contents.len)
	for(var/i in 1 to del_count)
		var/obj/item/removed_item = pick(contents)
		qdel(removed_item)
	if(atom_storage)
		if(prob(75))
			atom_storage.max_slots = max(contents.len, max(1, atom_storage.max_slots - pick(2, 2, 2, 3, 3, 4)))
		if(prob(75))
			atom_storage.max_total_storage = max(1, atom_storage.max_total_storage / 2)
	..()

/obj/item/reagent_containers/make_old()
	for(var/datum/reagent/contained in reagents?.reagent_list)
		contained.volume = rand(0, contained.volume)
	reagents?.add_reagent(/datum/reagent/toxin, rand(0, 10))
	..()

/obj/item/ammo_box/make_old()
	var/del_count = rand(0, LAZYLEN(stored_ammo))
	for(var/i in 1 to del_count)
		pick_n_take(stored_ammo)
	..()

/obj/item/stock_parts/power_store/cell/make_old()
	charge = max(0, rand(0, maxcharge * 2) - maxcharge)
	..()

/obj/item/stack/sheet/make_old()
	return

/obj/item/stack/rods/make_old()
	return

/obj/item/shard/make_old()
	return

/obj/item/circuitboard/make_old()
	..()

/obj/item/clothing/make_old()
	if(prob(50))
		slowdown += pick(0.5, 0.5, 1, 1.5)
	..()

/obj/item/clothing/glasses/make_old()
	..()

/obj/item/flashlight/make_old()
	..()
	if(prob(75))
		light_range = max(1, light_range / 2)
		light_power = max(0.1, light_power / 2)

/obj/machinery/floodlight/make_old()
	..()
	if(prob(75))
		light_range = max(1, light_range / 2)

/obj/machinery/make_old()
	..()
	if(prob(60))
		machine_stat |= BROKEN
	if(prob(60))
		obj_flags |= EMAGGED

/obj/machinery/vending/make_old()
	..()
	if(prob(75))
		var/del_count = rand(0, LAZYLEN(product_records))
		for(var/i in 1 to del_count)
			if(!LAZYLEN(product_records))
				break
			product_records -= pick(product_records)
