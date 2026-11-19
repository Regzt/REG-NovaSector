// Junkyard bum: a randomly-equipped scavenger spawned by the junkyard.
/mob/living/carbon/human/bum/Initialize(mapload, datum/species/species)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/mob/living/carbon/human/bum/LateInitialize()
	. = ..()
	generate_random_bum()

/mob/living/carbon/human/proc/generate_random_bum()
	if(prob(80))
		equip_to_slot_or_del(new /obj/item/clothing/under/color/random(src), ITEM_SLOT_ICLOTHING)
	if(prob(60))
		equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/random(src), ITEM_SLOT_FEET)
	if(prob(30))
		equip_to_slot_or_del(new /obj/item/storage/backpack(src), ITEM_SLOT_BACK)
	if(prob(80))
		var/gloves_path = pick(
			/obj/item/clothing/gloves/color/black,
			/obj/item/clothing/gloves/color/grey,
			/obj/item/clothing/gloves/color/brown,
		)
		equip_to_slot_or_del(new gloves_path(src), ITEM_SLOT_GLOVES)
	if(prob(80))
		var/light_path = pick(
			/obj/item/flashlight,
			/obj/item/flashlight/flare/torch,
		)
		put_in_hands(new light_path(src))
	if(prob(25))
		var/head_path = pick(
			/obj/item/clothing/head/beanie,
			/obj/item/clothing/head/soft,
		)
		equip_to_slot_or_del(new head_path(src), ITEM_SLOT_HEAD)
	put_in_hands(new /obj/item/shovel(src))
	for(var/obj/item/loot in contents)
		loot.make_old()
	sight |= SEE_BLACKNESS

/mob/proc/make_bum()
	var/obj/effect/landmark/junkyard_bum/bum_landmark
	var/list/candidates = list()
	for(var/obj/effect/landmark/junkyard_bum/landmark as anything in GLOB.landmarks_list)
		candidates += landmark
	if(length(candidates))
		bum_landmark = pick(candidates)
	if(!bum_landmark)
		to_chat(src, span_warning("There is no junkyard bum spawn point on this map."))
		return
	var/mob/living/carbon/human/bum/host = new /mob/living/carbon/human/bum(get_turf(bum_landmark))
	host.ckey = ckey
	to_chat(host, span_warning("You are space bum now. Try to survive. Try to cooperate. Try to be friendly. Only remember: there are no rules!"))
	return host
