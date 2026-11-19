// Scrapman generator: a PACMAN variant that burns refined scrap for power.
/obj/item/circuitboard/machine/pacman/scrap
	name = "Scrapman Board"
	build_path = /obj/machinery/power/port_gen/pacman/scrap
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/iron = 5,
	)

/obj/machinery/power/port_gen/pacman/scrap
	name = "Scrapman Portable Generator"
	icon = 'modular_regzt/icons/obj/structures/scrap/scrapman.dmi'
	icon_state = "gen_scrap-off"
	base_icon_state = "gen_scrap"
	circuit = /obj/item/circuitboard/machine/pacman/scrap
	sheet_path = /obj/item/stack/sheet/refined_scrap
	power_gen = 5 KILO JOULES
	time_per_sheet = 160
	max_sheets = 50

/obj/machinery/power/port_gen/pacman/scrap/update_icon_state()
	icon_state = active ? "gen_scrap-on" : "gen_scrap-off"
	return ..()

/obj/machinery/power/port_gen/pacman/scrap/overheat()
	explosion(src, devastation_range = 1, heavy_impact_range = 5, light_impact_range = 2, flash_range = -1)
