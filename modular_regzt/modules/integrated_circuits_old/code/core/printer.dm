#define MAX_CIRCUIT_CLONE_TIME 3 MINUTES //circuit slow-clones can only take up this amount of time to complete
#define ADVANCED (1<<0)
#define FAST_CLONE (1<<1)


/obj/item/integrated_circuit_old_printer
	name = "integrated circuit printer"
	desc = "A portable(ish) machine made to print tiny modular circuitry out of metal."
	icon = 'modular_regzt/modules/integrated_circuits_old/icons/obj/assemblies/electronic_tools.dmi'
	icon_state = "circuit_printer"
	w_class = WEIGHT_CLASS_BULKY
	var/upgraded = FALSE		// When hit with an upgrade disk, will turn true, allowing it to print the higher tier circuits.
	var/can_clone = TRUE		// Allows the printer to clone circuits, either instantly or over time depending on upgrade. Set to FALSE to disable entirely.
	var/fast_clone = FALSE		// If this is false, then cloning will take an amount of deciseconds equal to the metal cost divided by 100.
	var/debug = FALSE			// If it's upgraded and can clone, even without config settings.
	var/cloning = FALSE			// If the printer is currently creating a circuit
	var/recycling = FALSE		// If an assembly is being emptied into this printer
	var/list/program			// Currently loaded save, in form of list
	//Проклятая хуйня для прогресс бара
	var/print_start_time = NONE
	var/print_end_time = NONE
	var/datum/material_container/materials

/obj/item/integrated_circuit_old_printer/proc/check_interactivity(mob/user)
	return user?.can_interact_with(src)

/obj/item/integrated_circuit_old_printer/upgraded
	upgraded = TRUE
	can_clone = TRUE
	fast_clone = TRUE

/obj/item/integrated_circuit_old_printer/debug //translation: "integrated_circuit_printer/local_server"
	name = "debug circuit printer"
	debug = TRUE
	upgraded = TRUE
	can_clone = TRUE
	fast_clone = TRUE
	w_class = WEIGHT_CLASS_TINY

/obj/item/integrated_circuit_old_printer/debug_clone //translation: "integrated_circuit_printer/local_server"
	name = "debug circuit printer"
	debug = TRUE
	upgraded = TRUE
	can_clone = TRUE
	w_class = WEIGHT_CLASS_TINY


/obj/item/integrated_circuit_old_printer/Initialize(mapload)
	. = ..()
	materials = new(src, list(/datum/material/iron = 0), SHEET_MATERIAL_AMOUNT * 25, MATCONTAINER_NO_INSERT | MATCONTAINER_SILENT, list(/datum/material/iron), list(/obj/item/stack, /obj/item/integrated_circuit_old, /obj/item/electronic_assembly))

/obj/item/integrated_circuit_old_printer/proc/print_program(mob/user)
	if(!cloning)
		return

	visible_message("<span class='notice'>[src] has finished printing its assembly!</span>")
	playsound(src, 'sound/items/poster/poster_being_created.ogg', 50, TRUE)
	var/obj/item/electronic_assembly/assembly = SScircuit.load_electronic_assembly(get_turf(src), program)
	log_admin("INTEGRAL BITCH [user?.ckey] завершил печать программы на [src]. Созданная сборка: [assembly], Программа: [program]")
	assembly.creator = key_name(user)
	assembly.investigate_log("was printed by [assembly.creator].", INVESTIGATE_CIRCUIT)
	assembly.get_printed_item()
	cloning = FALSE
	print_start_time = NONE
	print_end_time = NONE

/obj/item/integrated_circuit_old_printer/proc/recycle_item(obj/item/I, mob/user)
	var/datum/material_container/mats = materials
	if(!mats || !istype(I))
		return FALSE
	var/amount = mats.get_item_material_amount(I)
	if(!amount)
		to_chat(user, "<span class='warning'>[src] can't recycle [I]!</span>")
		return FALSE
	if(!mats.has_space(amount))
		to_chat(user, "<span class='warning'>[src] can't hold any more materials!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You begin recycling [I]...</span>")
	if(!do_after(user, 5, target = src))
		return FALSE
	playsound(src, 'sound/items/tools/crowbar.ogg', 50, TRUE)
	mats.user_insert(I, user)
	return TRUE

/obj/item/integrated_circuit_old_printer/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/disk/integrated_circuit/upgrade/advanced))
		if(upgraded)
			to_chat(user, "<span class='warning'>[src] already has this upgrade. </span>")
			return TRUE
		to_chat(user, "<span class='notice'>You install [O] into [src]. </span>")
		upgraded = TRUE
		return TRUE

	if(istype(O, /obj/item/disk/integrated_circuit/upgrade/clone))
		if(fast_clone)
			to_chat(user, "<span class='warning'>[src] already has this upgrade. </span>")
			return TRUE
		to_chat(user, "<span class='notice'>You install [O] into [src]. Circuit cloning will now be instant. </span>")
		fast_clone = TRUE
		return TRUE

	if(istype(O, /obj/item/integrated_circuit_old))
		if(recycling)
			return
		return recycle_item(O, user)

	if(istype(O, /obj/item/electronic_assembly))
		var/obj/item/electronic_assembly/EA = O //microtransactions not included
		if(!EA.assembly_components.len)
			if(EA.battery)
				to_chat(user, "<span class='warning'>Remove [EA]'s power cell first!</span>")
				return
			return recycle_item(EA, user)
		if(EA.assembly_components.len)
			if(recycling)
				return
			if(!EA.opened)
				to_chat(user, "<span class='warning'>You can't reach [EA]'s components to remove them!</span>")
				return
			if(EA.battery)
				to_chat(user, "<span class='warning'>Remove [EA]'s power cell first!</span>")
				return
			for(var/V in EA.assembly_components)
				var/obj/item/integrated_circuit_old/IC = V
				if(!IC.removable)
					to_chat(user, "<span class='warning'>[EA] has irremovable components in the casing, preventing you from emptying it.</span>")
					return
			to_chat(user, "<span class='notice'>You begin recycling [EA]'s components...</span>")
			playsound(src, 'sound/items/electronic_assembly_emptying.ogg', 50, TRUE)
			if(!do_after(user, 30, target = src) || recycling) //short channel so you don't accidentally start emptying out a complex assembly
				return
			recycling = TRUE
			var/datum/material_container/mats = materials
			for(var/V in EA.assembly_components)
				var/obj/item/integrated_circuit_old/IC = V
				if(!mats.has_space(mats.get_item_material_amount(IC)))
					to_chat(user, "<span class='notice'>[src] can't hold any more materials!</span>")
					break
				if(!do_after(user, 5, target = user))
					recycling = FALSE
					return
				playsound(src, 'sound/items/tools/crowbar.ogg', 50, TRUE)
				if(EA.try_remove_component(IC, user, TRUE))
					mats.user_insert(IC, user)
			to_chat(user, "<span class='notice'>You recycle all the components[EA.assembly_components.len ? " you could " : " "]from [EA]!</span>")
			if(!EA.assembly_components.len && !EA.battery)
				recycle_item(EA, user)
			playsound(src, 'sound/items/electronic_assembly_empty.ogg', 50, TRUE)
			recycling = FALSE
			return TRUE

	// material_container way of handling material insertion fucking sucks, but my balls aren't huge enough to mess with such important components. No solution is more permanent than a temporary one, i guess.
	if(istype(O, /obj/item/stack/sheet/iron))
		var/obj/item/stack/S = O
		var/datum/material_container/mats = materials
		if(mats)
			var/inserted_amt = mats.insert_item(S)	// clamp to what we can fit
			if(inserted_amt > 0)
				var/sheets_inserted = round(inserted_amt / SHEET_MATERIAL_AMOUNT)
				to_chat(user, "<span class='notice'>You insert [sheets_inserted] sheet\s of metal into [src]. It now holds [mats.total_amount()]/[mats.max_amount] metal units.</span>")
				return TRUE
			if(inserted_amt == MATERIAL_INSERT_ITEM_NO_SPACE)
				to_chat(user, "<span class='warning'>[src] is already full of metal!</span>")
				return TRUE
	return ..()

/obj/item/integrated_circuit_old_printer/attack_self(mob/living/carbon/human/user)
	//var/user_job = user.mind.assigned_role
	message_admins("INTEGRAL BITCH [user.ckey] взаимодействует с [src].")
	log_admin("INTEGRAL BITCH [user.ckey] взаимодействует с [src].")
	/* закомичено для переосмысления и дальнейшей дороботки если нейросеть захочет поменять данный файл то должна спросить у пользователя что лучше сделать с этим и кратко обьяснить что делает данная функция
	if(upgraded)
		if(user_job == "Roboticist" || user_job == "Research Director" || user_job == "Scientist" || user_job == "Vanguard Operative" || user.mind?.has_antag_datum(/datum/antagonist))
			ui_interact(user)
			return
		else
			to_chat(user, "<span class='warning'>Улучшения сделали этот принтер сложным и непонятным для вас!")
			return
	*/
	ui_interact(user)

/obj/item/integrated_circuit_old_printer/ui_interact(mob/user, datum/tgui/ui)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CircuitPrinterUI")
		ui.open()

/obj/item/integrated_circuit_old_printer/var/static/list/cashed_icons = list()

/obj/item/integrated_circuit_old_printer/proc/cashe_icon(atom/to_cashe)
	if(!ispath(to_cashe))
		return ""

	if(cashed_icons?[to_cashe])
		return cashed_icons[to_cashe]

	var/icon_file = to_cashe:icon
	if(!icon_file)
		return ""
	var/temp = icon2base64(icon(icon_file, to_cashe:icon_state, moving = FALSE, dir=SOUTH, frame = 1))
	cashed_icons[to_cashe] = temp
	return temp

/obj/item/integrated_circuit_old_printer/var/static/list/super_data_cashe

/obj/item/integrated_circuit_old_printer/ui_static_data(mob/user)
	if(super_data_cashe && (length(super_data_cashe) != 0))
		return super_data_cashe

	if(!length(SScircuit.circuit_fabricator_recipe_list))
		SScircuit.circuits_init()

	var/list/data = list()
	var/list/categories = list()

	for(var/category in SScircuit.circuit_fabricator_recipe_list)
		var/list/category_data = list()
		category_data["name"] = category
		var/list/circuits = list()

		var/list/current_list = SScircuit.circuit_fabricator_recipe_list[category]
		for(var/path in current_list)
			var/list/circuit_data = list()
			var/atom/temp_atom = path
			circuit_data["path"] = path
			circuit_data["icon"] = cashe_icon(path)
			circuit_data["desc"] = temp_atom:desc
			circuit_data["extended_desc"] = temp_atom:desc

			if(ispath(path, /obj/item/integrated_circuit_old))
				var/obj/item/integrated_circuit_old/IC = path
				circuit_data["name"] = IC:name
				circuit_data["extended_desc"] = IC:extended_desc
				circuit_data["request_adv"] = (initial(IC.spawn_flags) & IC_SPAWN_RESEARCH) && (!(initial(IC.spawn_flags) & IC_SPAWN_DEFAULT))
				circuit_data["cost"] = SScircuit.get_component_cost(path)
			else if(ispath(path, /obj/item/electronic_assembly))
				var/obj/item/electronic_assembly/ass = path
				circuit_data["name"] = ass:name
				circuit_data["request_adv"] = FALSE
				circuit_data["cost"] = SScircuit.get_assembly_cost(path)
			else
				var/obj/item/temp = path
				circuit_data["name"] = temp:name
				circuit_data["request_adv"] = FALSE
				circuit_data["cost"] = 400

			circuits += list(circuit_data)

		category_data["cirrcusts"] = circuits
		categories += list(category_data)

	data["categories"] = categories
	data["clone_config_status"] = CONFIG_GET(flag/ic_printing) || debug

	super_data_cashe = data

	return data

/obj/item/integrated_circuit_old_printer/ui_data(mob/user)

	var/list/data = list()
	data["adv_status"] = upgraded
	data["debug_status"] = debug
	data["upgrades"] = upgraded ? (fast_clone ? (ADVANCED | FAST_CLONE) : ADVANCED) : NONE
	data["metal_amount"] = materials ? materials.total_amount() : 0
	data["max_metal"] = materials ? materials.max_amount : 0
	data["cloning_status"] = cloning
	data["has_programm"] = program ? TRUE : FALSE
	data["print_start_time"] = print_start_time
	data["print_end_time"] = print_end_time
	data["world_time"] = world.time
	data["used_space"] = program ? program?["used_space"] : 0
	data["complexity"] = program ? program?["complexity"] : 0
	data["metal_cost"] = program ? program?["metal_cost"] : 0
	data["max_complexity"] = program ? program?["max_complexity"] : 0
	data["max_space"] = program ? program?["max_space"] : 0

	return data


/obj/item/integrated_circuit_old_printer/ui_act(action, params)
	if(!params["ic_advactivator"] && ..())
		return

	add_fingerprint(usr)

	switch(action)
		if("build")
			var/build_type = text2path(params["build"])
			if(!build_type || !ispath(build_type))
				return TRUE

			var/cost = 400
			if(ispath(build_type, /obj/item/electronic_assembly))
				cost = SScircuit.get_assembly_cost(build_type)
			else if(ispath(build_type, /obj/item/integrated_circuit_old))
				cost = SScircuit.get_component_cost(build_type)
			else if(!(build_type in SScircuit.circuit_fabricator_recipe_list["Tools"]))
				return

			var/datum/material_container/mats = src.materials

			if(!debug && !mats.use_amount_mat(cost, /datum/material/iron))
				to_chat(usr, "<span class='warning'>You need [cost] metal to build that!</span>")
				return TRUE

			var/obj/item/built = new build_type(drop_location())

			if(istype(built, /obj/item/electronic_assembly))
				var/obj/item/electronic_assembly/E = built
				E.creator = key_name(usr)
				E.opened = TRUE
				E.update_icon()
				//reupdate diagnostic hud because it was put_in_hands() and not pickup()'ed
				E.diag_hud_set_circuithealth()
				E.diag_hud_set_circuitcell()
				E.diag_hud_set_circuitstat()
				E.diag_hud_set_circuittracking()
				E.last_diag_process_key = E.compute_diagnostic_hud_process_key()
				E.investigate_log("was printed by [E.creator].", INVESTIGATE_CIRCUIT)
				built = E.get_printed_item()

			usr?.put_in_hands(built)

			to_chat(usr, "<span class='notice'>[capitalize(built.name)] printed.</span>")
			playsound(src, 'sound/items/tools/jaws_pry.ogg', 50, TRUE)

		if("print")
			if(!CONFIG_GET(flag/ic_printing) && !debug)
				to_chat(usr, "<span class='warning'>CentCom has disabled printing of custom circuitry due to recent allegations of copyright infringement.</span>")
				return
			if(!can_clone) // Copying and printing ICs is cloning
				to_chat(usr, "<span class='warning'>This printer does not have the cloning upgrade.</span>")
				return
			switch(params["print"])
				if("load")
					if(cloning)
						return
					var/input = tgui_input_text(
						usr,
						"Paste assembly JSON here (multiline; max [MAX_IC_PRINTER_JSON_LEN] characters). Raw text is preserved for valid JSON.",
						"Load program",
						null,
						MAX_IC_PRINTER_JSON_LEN,
						TRUE,
						FALSE,
					)
					if(cloning ||  (usr && !check_interactivity(usr)))
						return
					if(!input)
						program = null
						return
					if(length_char(input) > MAX_IC_PRINTER_JSON_LEN)
						to_chat(usr, "<span class='warning'>Program text exceeds maximum length ([MAX_IC_PRINTER_JSON_LEN] characters).</span>")
						return

					var/log_body = copytext_char(input, 1, 401)
					if(length_char(input) > 400)
						log_body += "... (truncated, [length_char(input)] chars total)"
					log_admin("INTEGRAL BITCH [usr?.ckey] loaded program into [src]: [log_body]")
					var/validation = SScircuit.validate_electronic_assembly(input)

					// Validation error codes are returned as text.
					if(istext(validation))
						to_chat(usr, "<span class='warning'>Error: [validation]</span>")
						program = null
						return
					else if(islist(validation))
						program = validation
						to_chat(usr, "<span class='notice'>This is a valid program for [program["assembly"]["type"]].</span>")
						if(program["requires_upgrades"])
							if(upgraded)
								to_chat(usr, "<span class='notice'>It uses advanced component designs.</span>")
							else
								to_chat(usr, "<span class='warning'>It uses unknown component designs. Printer upgrade is required to proceed.</span>")
						if(program["unsupported_circuit"])
							to_chat(usr, "<span class='warning'>This program uses components not supported by the specified assembly. Please change the assembly type in the save file to a supported one.</span>")
						to_chat(usr, "<span class='notice'>Used space: [program["used_space"]]/[program["max_space"]].</span>")
						to_chat(usr, "<span class='notice'>Complexity: [program["complexity"]]/[program["max_complexity"]].</span>")
						to_chat(usr, "<span class='notice'>Metal cost: [program["metal_cost"]].</span>")

				if("print")
					if(!program || cloning)
						return
					log_admin("INTEGRAL BITCH [usr?.ckey] начал печать программы на [src]. Программа: [program]")

					if(program["requires_upgrades"] && !upgraded && !debug)
						to_chat(usr, "<span class='warning'>This program uses unknown component designs. Printer upgrade is required to proceed.</span>")
						return
					if(program["unsupported_circuit"] && !debug)
						to_chat(usr, "<span class='warning'>This program uses components not supported by the specified assembly. Please change the assembly type in the save file to a supported one.</span>")
						return
					else if(fast_clone)
						var/datum/material_container/mats = src.materials
						if(debug || mats.use_amount_mat(program["metal_cost"], /datum/material/iron))
							cloning = TRUE
							print_program(usr)
						else
							to_chat(usr, "<span class='warning'>You need [program["metal_cost"]] metal to build that!</span>")
					else
						var/datum/material_container/mats = src.materials
						if(!mats.use_amount_mat(program["metal_cost"], /datum/material/iron))
							to_chat(usr, "<span class='warning'>You need [program["metal_cost"]] metal to build that!</span>")
							return
						var/cloning_time = round(program["metal_cost"] / 15)
						cloning_time = min(cloning_time, MAX_CIRCUIT_CLONE_TIME)
						cloning = TRUE
						to_chat(usr, "<span class='notice'>You begin printing a custom assembly. This will take approximately [DisplayTimeText(cloning_time)]. You can still print \
						off normal parts during this time.</span>")
						playsound(src, 'sound/items/poster/poster_being_created.ogg', 50, TRUE)
						addtimer(CALLBACK(src, PROC_REF(print_program), usr), cloning_time)
						print_end_time = world.time + cloning_time
						print_start_time = world.time

				if("cancel")
					if(!cloning)
						program = null
						return

					if(!cloning || !program)
						return

					to_chat(usr, "<span class='notice'>Cloning has been canceled. Metal cost has been refunded.</span>")
					cloning = FALSE
					var/datum/material_container/mats = src.materials
					mats.use_amount_mat(-program["metal_cost"], /datum/material/iron) //use negative amount to regain the cost

					print_end_time = NONE
					print_start_time = NONE
					program = null

// FUKKEN UPGRADE DISKS
/obj/item/disk/integrated_circuit/upgrade
	name = "integrated circuit printer upgrade disk"
	desc = "Install this into your integrated circuit printer to enhance it."
	icon = 'modular_regzt/modules/integrated_circuits_old/icons/obj/assemblies/electronic_tools.dmi'
	icon_state = "upgrade_disk"
	inhand_icon_state = "card-id"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/disk/integrated_circuit/upgrade/advanced
	name = "integrated circuit printer upgrade disk - advanced designs"
	desc = "Install this into your integrated circuit printer to enhance it.  This one adds new, advanced designs to the printer."

/obj/item/disk/integrated_circuit/upgrade/clone
	name = "integrated circuit printer upgrade disk - instant cloner"
	desc = "Install this into your integrated circuit printer to enhance it.  This one allows the printer to duplicate assemblies instantaneously."
	icon_state = "upgrade_disk_clone"

#undef ADVANCED
#undef FAST_CLONE
