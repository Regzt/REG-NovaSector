/obj/machinery/power/dynamo
	name = "dynamo"
	desc = "A power generating mechanism."
	var/power_produced = 10000
	var/raw_power = 0
	var/obj/structure/chair/pedalgen/Pedals = null
	invisibility = INVISIBILITY_ABSTRACT
	use_power = NO_POWER_USE

/obj/machinery/power/dynamo/process()
	if (raw_power > 0)
		if (raw_power > 10)
			raw_power -= 3
			give_power(TRUE)
		else
			raw_power--
			give_power(FALSE)
	if(Pedals)
		Pedals.update_icon()

/obj/machinery/power/dynamo/proc/give_power(excessive_charge = FALSE)
	var/power_to_give = power_produced
	if(excessive_charge)
		power_to_give *= 2

	// 1. APC < 90%
	var/area/A = get_area(Pedals ? Pedals : src)
	if(A && A.apc && A.apc.cell)
		var/obj/machinery/power/apc/APC = A.apc
		if(APC.cell.charge < (APC.cell.maxcharge * 0.9))
			var/charge_amount = power_to_give
			APC.cell.charge = min(APC.cell.charge + charge_amount, APC.cell.maxcharge)
			APC.update_icon()
			return

	// 2. POWERNET
	if(powernet)
		add_avail(power_to_give)

/obj/machinery/power/dynamo/proc/Rotated()
	raw_power += 2


/obj/structure/chair/pedalgen
	name = "pedal generator"
	desc = "Push it to the limit! Generate power from raw human force! Or just let a monkey handle it."
	icon = 'modular_regzt/icons/obj/structures/pedalgen.dmi'
	icon_state = "pedalgen"
	anchored = TRUE
	density = FALSE
	custom_materials = list(/datum/material/iron = 20000)
	var/obj/machinery/power/dynamo/Generator = null
	var/next_pedal = 0
	item_chair = null

/obj/structure/chair/pedalgen/Initialize(mapload)
	. = ..()
	handle_rotation()
	Generator = new /obj/machinery/power/dynamo(src)
	Generator.Pedals = src
	if(anchored)
		Generator.loc = loc
		Generator.connect_to_network()

/obj/structure/chair/pedalgen/Destroy()
	if(Generator)
		qdel(Generator)
		Generator = null
	return ..()

/obj/structure/chair/pedalgen/examine(mob/user)
	. = ..()
	. += span_notice("[src] <b>[anchored ? "" : "не "]</b>прикручен к полу.")
	if(!Generator || !Generator.powernet)
		. += span_danger("[src] не подключен к проводке станции.")
	if(Generator && Generator.raw_power > 0)
		. += "<b>[Generator.raw_power]</b> мощи накоплено, и генератор вырабатывает <b>[Generator.raw_power > 10 ? "[2 * Generator.power_produced / 1000]" : "[Generator.power_produced / 1000]"]k</b> электроэнергии!"
	else
		. += "Генератор затих. Кто-то должен крутить педали!"
	. += span_notice("Используй клавиши передвижения или кликай по [src] для выработки энергии.")

/obj/structure/chair/pedalgen/update_icon_state()
	if(!Generator)
		return
	switch(Generator.raw_power)
		if(0)
			icon_state = initial(icon_state)
		if(1 to 10)
			icon_state = "[initial(icon_state)]_low"
		if(11 to INFINITY)
			icon_state = "[initial(icon_state)]_high"

/obj/structure/chair/pedalgen/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	return NONE

/obj/structure/chair/pedalgen/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	default_unfasten_wrench(user, I)
	if(anchored)
		Generator.loc = src.loc
		Generator.connect_to_network()
	else
		Generator.disconnect_from_network()
		Generator.loc = null
	return TRUE

/obj/structure/chair/pedalgen/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(loc, 10)
	new /obj/item/stack/cable_coil(loc, 5)
	new /obj/item/stack/rods(loc, 1)

/obj/structure/chair/pedalgen/wrench_act_secondary(mob/living/user, obj/item/weapon)
	if(has_buckled_mobs())
		to_chat(user, span_warning("Сначала нужно снять того, кто сидит на генераторе!"))
		return TRUE

	weapon.play_tool_sound(src)
	user.visible_message(
		span_notice("[user] разбирает [src] на составляющие."),
		span_notice("Вы разбираете [src].")
	)
	deconstruct(disassembled = TRUE)
	return TRUE

/obj/structure/chair/pedalgen/attack_hand(mob/user)
	pedal(user)
	return FALSE

/obj/structure/chair/pedalgen/proc/pedal(mob/user)
	if(!has_buckled_mobs())
		return FALSE
	var/mob/living/L = buckled_mobs[1]
	if(L != user)
		visible_message(
			span_notice("[L.name] was unbuckled by [user.name]!"),
			span_notice("You were unbuckled from [src] by [user.name].")
		)
		unbuckle_mob(L)
		add_fingerprint(user)
		return FALSE

	var/mob/living/carbon/C = L
	if(!istype(C))
		return FALSE
	if(next_pedal >= world.time)
		return FALSE

	// Проверка состояния
	if(C.incapacitated || IS_UNCONSCIOUS_OR_CRIT(C))
		return FALSE

	if(ismonkey(C))
		if(!C.handcuffed)
			unbuckle_mob(C)
			visible_message(span_warning("[C] спрыгивает с [src]!"))
			return FALSE

	next_pedal = world.time + 4

	playsound(src, 'sound/items/tools/ratchet.ogg', 10, TRUE, ignore_walls = TRUE)

	if(Generator)
		Generator.Rotated()

	// 1. УТОМЛЕНИЕ (6 урона выносливости)
	C.apply_damage(6, STAMINA)

	// 2. ИСТОЩЕНИЕ ПО ГОЛОДУ
	if(C.nutrition <= NUTRITION_LEVEL_STARVING)
		if(ismonkey(C))
			C.visible_message(span_warning("[C] теряет сознание из-за голода."))
			C.Unconscious(300)
		else
			to_chat(user, span_danger("Вы слишком истощены. Необходимо поесть."))
			C.Knockdown(100)
		return FALSE

	// 3. СЖИГАНИЕ КАЛОРИЙ
	if(!HAS_TRAIT(C, TRAIT_NOHUNGER))
		if(ismonkey(C))
			C.adjust_nutrition(-HUNGER_FACTOR)
		else
			C.adjust_nutrition(-10 * HUNGER_FACTOR)

	return TRUE

/obj/structure/chair/pedalgen/relaymove(mob/user, direction)
	pedal(user)

/obj/structure/chair/pedalgen/handle_layer()
	if(has_buckled_mobs() && dir == SOUTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER
	if(has_buckled_mobs())
		var/mob/living/M = buckled_mobs[1]
		M.setDir(dir)
		var/new_pixel_x = 0
		var/new_pixel_y = 0
		switch(dir)
			if(SOUTH)
				new_pixel_x = 0
				new_pixel_y = 7
			if(WEST)
				new_pixel_x = 13
				new_pixel_y = 7
			if(NORTH)
				new_pixel_x = 0
				new_pixel_y = 4
			if(EAST)
				new_pixel_x = -13
				new_pixel_y = 7
		M.pixel_x = new_pixel_x
		M.pixel_y = new_pixel_y

/obj/structure/chair/pedalgen/post_buckle_mob(mob/living/M)
	. = ..()
	if(ismonkey(M) && !M.client)
		START_PROCESSING(SSobj, src)

/obj/structure/chair/pedalgen/post_unbuckle_mob(mob/living/M)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	M.pixel_x = initial(M.pixel_x)
	M.pixel_y = initial(M.pixel_y)

/obj/structure/chair/pedalgen/process(delta_time)
	if(!has_buckled_mobs() || !ismonkey(buckled_mobs[1]))
		STOP_PROCESSING(SSobj, src)
		return
	if(next_pedal < world.time)
		pedal(buckled_mobs[1])

/obj/structure/chair/pedalgen/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(has_buckled_mobs() && !moving_diagonally)
		if(buckled_mobs[1].buckled == src)
			buckled_mobs[1].forceMove(loc)
			handle_layer()

/obj/structure/chair/pedalgen/verb/release()
	set name = "Release Pedalgen"
	set category = "Object"
	set src in view(1)
	if(!iscarbon(usr))
		return
	if(!has_buckled_mobs())
		return
	var/mob/living/carbon/C = usr
	if(C.handcuffed || C.incapacitated)
		to_chat(usr, span_warning("Вы не можете сделать это в вашем текущем состоянии!"))
		return
	unbuckle_mob(buckled_mobs[1])
