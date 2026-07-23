// =====
// КАРГО
// =====

/obj/item/mecha_parts/mecha_equipment/ejector/lockermech
	cargo_capacity = 4

// =====
// БРОНЯ
// =====

/datum/armor/mecha_lockermech
	melee = 20
	bullet = 10
	laser = 10
	energy = 0
	bomb = 10
	fire = 70
	acid = 60

/obj/vehicle/sealed/mecha/lockermech
	name = "Locker Mech"
	desc = "A locker with stolen wires, struts, electronics and airlock servos crudely assembled into something that resembles the functions of a mech."
	icon = 'modular_regzt/icons/mob/lockermech.dmi'
	icon_state = "lockermech"
	base_icon_state = "lockermech"
	silicon_icon_state = "lockermech"
	max_integrity = 100
	lights_power = 5
	movedelay = 4
	armor_type = /datum/armor/mecha_lockermech
	wreckage = /obj/structure/mecha_wreckage/lockermech
	accesses = list(ACCESS_MECH_MAKESHIFT)
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 1,
		MECHA_POWER = 0,
		MECHA_ARMOR = 0,
	)
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector/lockermech),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

	mecha_flags = CAN_STRAFE | HAS_LIGHTS
	force = 10
	var/obj/item/mecha_parts/mecha_equipment/ejector/lockermech/cargo_hold
	var/melee_cooldown_delay = 20
	var/next_melee_attack = 0

/obj/vehicle/sealed/mecha/lockermech/proc/mecha_melee_attack(atom/target, mob/living/user)
	if(world.time < next_melee_attack)
		to_chat(user, "[src]'s makeshift servos are still recovering from the last swing!")
		return FALSE
	next_melee_attack = world.time + melee_cooldown_delay
	return TRUE

/obj/vehicle/sealed/mecha/lockermech/Destroy()
	return ..()

// ======
// МОДУЛИ
// ======

// дрель
/obj/item/mecha_parts/mecha_equipment/drill/lockermech
	name = "Makeshift exosuit drill"
	desc = "Cobbled together from likely stolen parts, this drill is nowhere near as effective as the real deal."
	mech_flags = list(ACCESS_MECH_MAKESHIFT)
	equip_cooldown = 60
	force = 10
	drill_delay = 15

// клешня
/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/lockermech
	name = "makeshift clamp"
	desc = "Loose arrangement of cobbled together bits resembling a clamp."
	mech_flags = list(ACCESS_MECH_MAKESHIFT)
	equip_cooldown = 25

// =====
// КРАФТ
// =====

/datum/crafting_recipe/lockermech
	name = "Locker Mech"
	result = /obj/vehicle/sealed/mecha/lockermech
	reqs = list(
		/obj/item/stack/cable_coil = 20,
		/obj/item/stack/sheet/iron = 10,
		/obj/item/storage/toolbox = 2,
		/obj/item/tank/internals/oxygen = 1,
		/obj/item/electronics/airlock = 1,
		/obj/item/extinguisher = 1,
		/obj/item/stack/medical/wrap/sticky_tape = 5,
		/obj/item/flashlight = 1,
		/obj/item/stack/rods = 4,
		/obj/item/pipe = 2
	)
	tool_paths = list(/obj/item/weldingtool, /obj/item/screwdriver, /obj/item/wirecutters)
	time = 200
	category = CAT_ROBOT

/datum/crafting_recipe/lockermechdrill
	name = "Makeshift exosuit drill"
	result = /obj/item/mecha_parts/mecha_equipment/drill/lockermech
	reqs = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/iron = 2,
		/obj/item/surgicaldrill = 1
	)
	tool_paths = list(/obj/item/screwdriver)
	time = 50
	category = CAT_ROBOT

/datum/crafting_recipe/lockermechclamp
	name = "Makeshift exosuit clamp"
	result = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/lockermech
	reqs = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/iron = 2,
		/obj/item/wirecutters = 1
	)
	tool_paths = list(/obj/item/screwdriver)
	time = 50
	category = CAT_ROBOT

/obj/structure/mecha_wreckage/lockermech
	name = "\improper lockermech wreckage"
	icon = 'modular_regzt/icons/mob/lockermech.dmi'
	icon_state = "lockermech-broken"
	welder_salvage = list(/obj/item/stack/sheet/iron, /obj/item/stack/rods)
	parts = list(
		/obj/item/stack/cable_coil = 20,
		/obj/item/storage/toolbox = 2,
		/obj/item/tank/internals/oxygen = 1,
		/obj/item/electronics/airlock = 1,
		/obj/item/extinguisher = 1,
		/obj/item/stack/medical/wrap/sticky_tape = 5,
		/obj/item/flashlight = 1,
		/obj/item/pipe = 2)
