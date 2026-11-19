/datum/design/board/pile_ripper
	name = "Pile Ripper Board"
	desc = "Used to build a pile ripper. Grinds scrap piles in front of it into loose scrap lumps."
	build_path = /obj/item/circuitboard/machine/pile_ripper
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_CARGO

/datum/design/board/scrapman
	name = "Scrapman Board"
	desc = "Used to build a Scrapman-type portable generator. Consumes refined scrap to generate power."
	build_path = /obj/item/circuitboard/machine/pacman/scrap
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING
