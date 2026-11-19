// Weighted loot tables for TauCeti-style scrap piles.
// Ratios mirror the original TauCeti loot lists:
// base piles are mostly materials, industrial piles mostly tech supplies,
// science piles only science supplies, and so on.

// Old tech_supply equivalent: mostly tools, with some power cells, cable and toolboxes.
GLOBAL_LIST_INIT(scrap_tech_supply, list(
	/obj/effect/spawner/random/engineering/tool = 5,
	/obj/item/stock_parts/power_store/cell = 3,
	/obj/item/stack/cable_coil = 3,
	/obj/effect/spawner/random/engineering/toolbox = 2,
	/obj/item/storage/belt/utility = 2,
	/obj/effect/spawner/random/engineering/flashlight = 1,
	/obj/effect/spawner/random/engineering/material_cheap = 1,
))

// Old medical_supply equivalent: single items, pills, autoinjectors, medkits and tools.
GLOBAL_LIST_INIT(scrap_medical_supply, list(
	/obj/effect/spawner/random/medical/minor_healing = 40,
	/obj/effect/spawner/random/medical/supplies = 20,
	/obj/effect/spawner/random/medical/injector = 20,
	/obj/effect/spawner/random/medical/medkit = 10,
	/obj/effect/spawner/random/medical/surgery_tool = 9,
	/obj/effect/spawner/random/medical/organs = 1,
))

// Modern equivalents of TauCeti science supply spawners.
/obj/effect/spawner/random/engineering/scrap_stock_part
	name = "scrap stock part spawner"
	icon_state = "wrench"
	loot = list(
		/obj/item/stock_parts/capacitor = 75,
		/obj/item/stock_parts/capacitor/adv = 25,
		/obj/item/stock_parts/capacitor/super = 4,
		/obj/item/stock_parts/capacitor/quadratic = 1,
		/obj/item/stock_parts/scanning_module = 75,
		/obj/item/stock_parts/scanning_module/adv = 25,
		/obj/item/stock_parts/scanning_module/phasic = 4,
		/obj/item/stock_parts/scanning_module/triphasic = 1,
		/obj/item/stock_parts/servo = 75,
		/obj/item/stock_parts/servo/nano = 25,
		/obj/item/stock_parts/servo/pico = 4,
		/obj/item/stock_parts/servo/femto = 1,
		/obj/item/stock_parts/micro_laser = 75,
		/obj/item/stock_parts/micro_laser/high = 25,
		/obj/item/stock_parts/micro_laser/ultra = 4,
		/obj/item/stock_parts/micro_laser/quadultra = 1,
		/obj/item/stock_parts/matter_bin = 75,
		/obj/item/stock_parts/matter_bin/adv = 25,
		/obj/item/stock_parts/matter_bin/super = 4,
		/obj/item/stock_parts/matter_bin/bluespace = 1,
		/obj/item/stock_parts/power_store/cell = 105,
	)

/obj/effect/spawner/random/engineering/scrap_bomb_supply
	name = "scrap bomb supply spawner"
	icon_state = "signaller"
	loot = list(
		/obj/item/assembly/mousetrap = 20,
		/obj/item/assembly/igniter = 20,
		/obj/item/assembly/signaler = 20,
		/obj/item/assembly/prox_sensor = 20,
		/obj/item/assembly/timer = 20,
		/obj/item/tank/internals/plasma = 10,
		/obj/item/tank/internals/oxygen = 10,
		/obj/item/transfer_valve = 10,
	)

/obj/effect/spawner/random/engineering/scrap_circuit
	name = "scrap circuit spawner"
	icon_state = "id_mod"
	loot = list(
		/obj/item/electronics/airlock = 1,
		/obj/item/electronics/airalarm = 1,
		/obj/item/electronics/firealarm = 1,
	)

GLOBAL_LIST_INIT(scrap_science_supply, list(
	/obj/effect/spawner/random/engineering/scrap_stock_part = 50,
	/obj/effect/spawner/random/engineering/scrap_bomb_supply = 20,
	/obj/effect/spawner/random/engineering/scrap_circuit = 10,
	GLOB.slime_extract_random = 5,
	/obj/item/extinguisher = 2,
))

GLOBAL_LIST_INIT(scrap_material, list(
	/obj/item/stack/rods = 1,
	/obj/item/stack/sheet/plastic = 1,
	/obj/item/stack/sheet/iron = 1,
	/obj/item/stack/sheet/glass = 1,
	/obj/item/stack/sheet/plasteel = 1,
	/obj/item/stack/sheet/mineral/wood = 1,
	/obj/item/shard = 1,
))

GLOBAL_LIST_INIT(scrap_medical, list(
	GLOB.scrap_medical_supply = 4,
	/obj/item/stack/rods = 1,
	/obj/item/shard = 1,
))

GLOBAL_LIST_INIT(scrap_food, list(
	/obj/effect/spawner/random/food_or_drink = 5,
	/obj/item/shard = 1,
	/obj/item/stack/rods = 1,
))

GLOBAL_LIST_INIT(scrap_science, list(
	GLOB.scrap_science_supply = 1,
))

GLOBAL_LIST_INIT(scrap_cloth, list(
	/obj/effect/spawner/random/clothing/costume = 1,
	/obj/effect/spawner/random/clothing/beret_or_rabbitears = 1,
	/obj/effect/spawner/random/clothing/bowler_or_that = 1,
	/obj/effect/spawner/random/clothing/kittyears_or_rabbitears = 1,
	/obj/effect/spawner/random/clothing/pirate_or_bandana = 1,
	/obj/effect/spawner/random/clothing/twentyfive_percent_cyborg_mask = 1,
	/obj/effect/spawner/random/clothing/mafia_outfit = 1,
	/obj/effect/spawner/random/clothing/syndie = 1,
	/obj/effect/spawner/random/clothing/gloves = 1,
	/obj/effect/spawner/random/clothing/lizardboots = 1,
	/obj/effect/spawner/random/clothing/backpack = 1,
	/obj/effect/spawner/random/clothing/funny_hats = 1,
))

GLOBAL_LIST_INIT(scrap_industrial, list(
	GLOB.scrap_tech_supply = 5,
	/obj/item/stack/rods = 1,
	/obj/item/stack/sheet/iron = 1,
	/obj/item/shard = 1,
))

GLOBAL_LIST_INIT(scrap_poor, list(
	GLOB.maintenance_loot = 2,
	GLOB.trash_loot = 2,
	/obj/item/shard = 1,
	/obj/item/stack/rods = 1,
))

/obj/effect/spawner/random/armory/scrap_energy_weapon
	name = "scrap energy weapon spawner"
	icon_state = "laser_gun"
	spawn_loot_count = 1
	loot = list(
		/obj/item/gun/energy/laser = 30,
		/obj/item/gun/energy/laser/carbine = 30,
		/obj/item/gun/energy/laser/pistol = 10,
	)

GLOBAL_LIST_INIT(scrap_guns, list(
	/obj/effect/spawner/random/armory/buckshot/sketchy = 1,
	/obj/effect/spawner/random/armory/slug = 1,
	/obj/item/stock_parts/power_store/cell = 1,
	/obj/effect/spawner/random/armory/scrap_energy_weapon = 1,
	/obj/item/toy/gun = 1,
	/obj/item/toy/eightball = 1,
	/obj/item/shard = 1,
	/obj/item/stack/sheet/iron = 1,
	/obj/item/stack/rods = 1,
))

GLOBAL_LIST_INIT(scrap_syndie, list(
	/obj/effect/spawner/random/contraband/armory = 1,
	/obj/effect/spawner/random/contraband/plus = 1,
	/obj/effect/spawner/random/contraband = 1,
	/obj/item/food/meat/slab = 1,
	/obj/item/food/meat/slab/corgi = 1,
	/obj/item/organ/brain = 1,
	/obj/item/tank/internals/plasma = 1,
))

GLOBAL_LIST_INIT(scrap_newyear, list(
	/obj/effect/spawner/random/entertainment/plushie = 2,
	/obj/effect/spawner/random/entertainment/toy_figure = 3,
	/obj/effect/spawner/random/entertainment/toy = 3,
	/obj/effect/spawner/random/clothing/costume = 2,
))

// Mirrors TauCeti's sparse_weighted / dense_weighted spawn tables.
GLOBAL_LIST_INIT(scrap_sparse_weighted, list(
	/obj/structure/scrap/poor = 105,
	/obj/structure/scrap = 18,
	/obj/structure/scrap/medical = 12,
	/obj/structure/scrap/science = 12,
	/obj/structure/scrap/vehicle = 18,
	/obj/structure/scrap/cloth = 24,
	/obj/structure/scrap/food = 36,
	/obj/structure/scrap/syndie = 1,
	/obj/structure/scrap/guns = 3,
))

GLOBAL_LIST_INIT(scrap_dense_weighted, list(
	/obj/structure/scrap/poor/large = 70,
	/obj/structure/scrap/poor/structure = 70,
	/obj/structure/scrap/large = 20,
	/obj/structure/scrap/medical/large = 14,
	/obj/structure/scrap/science/large = 14,
	/obj/structure/scrap/vehicle/large = 20,
	/obj/structure/scrap/cloth/large = 26,
	/obj/structure/scrap/food/large = 40,
	/obj/structure/scrap/syndie/large = 1,
	/obj/structure/scrap/guns/large = 3,
))

/// Picks a scrap pile type using TauCeti's moderate_weighted 2:1 sparse/dense split.
/proc/pick_random_scrap_type()
	if(prob(66))
		return pick_weight(GLOB.scrap_sparse_weighted)
	return pick_weight(GLOB.scrap_dense_weighted)

/// Spawns a random scrap pile on the given turf.
/proc/spawn_random_scrap(turf/target)
	var/scrap_type = pick_random_scrap_type()
	if(!scrap_type)
		return null
	return new scrap_type(target)
