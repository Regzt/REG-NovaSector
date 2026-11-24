/// Полиномиальный хеш с малыми константами (без больших литералов — dreamchecker / float32).
/proc/ic_tgui_hash_string(t)
	var/hash = 0
	if(!istext(t) || !length(t))
		return 0
	for(var/i = 1, i <= length(t), i++)
		hash = ((hash * 131) + text2ascii(t, i)) & 0x7FFFFFFF
	return hash

/// Stable per-instance accent for IntegratedCircuit TGUI (IE chips + wiremod components).
/proc/ic_tgui_chip_accent_hex(datum/D)
	if(!D)
		return "#4269a3"
	var/mix = "[D.type][REF(D)]"
	if(ismovable(D))
		var/atom/movable/M = D
		mix += "[M.name]"
	var/hi = ic_tgui_hash_string(mix)
	/// Золотой угол — равномернее, чем hi % 360 при похожих ref.
	var/angle = hi % 360
	var/golden = round((hi * 0.618033988749895) % 360, 1)
	var/angle2 = round((angle + golden) % 360, 1)
	return ic_hsv255_to_rgb(angle2, 188, 232)

GLOBAL_LIST_INIT(ie_ic_tgui_accent_by_type, list(
	/obj/item/integrated_circuit_old/input/button = "#2daa4e",
	/obj/item/integrated_circuit_old/input/toggle_button = "#38c96a",
	/obj/item/integrated_circuit_old/input/textpad = "#ff5cab",
	/obj/item/integrated_circuit_old/input = "#e0a62e",
	/obj/item/integrated_circuit_old/output = "#5c7cfa",
	/obj/item/integrated_circuit_old/output/screen = "#7b9cff",
	/obj/item/integrated_circuit_old/output/light = "#ffd54a",
	/obj/item/integrated_circuit_old/output/sound = "#9b7ed9",
	/obj/item/integrated_circuit_old/output/text_to_speech = "#ff6eb4",
	/obj/item/integrated_circuit_old/logic = "#c06bff",
	/obj/item/integrated_circuit_old/logic/binary = "#d080ff",
	/obj/item/integrated_circuit_old/logic/unary = "#a85fd9",
	/obj/item/integrated_circuit_old/memory = "#ff8f42",
	/obj/item/integrated_circuit_old/arithmetic = "#3ec9c1",
	/obj/item/integrated_circuit_old/converter = "#6ecf7a",
	/obj/item/integrated_circuit_old/time = "#5fd4a0",
	/obj/item/integrated_circuit_old/passive = "#8899aa",
	/obj/item/integrated_circuit_old/manipulation = "#ff7b6b",
	/obj/item/integrated_circuit_old/smart = "#b8e034",
))

/// IE: сначала цвет по иерархии типа, иначе хеш по экземпляру.
/proc/ic_tgui_ie_chip_accent_hex(obj/item/integrated_circuit_old/chip)
	if(!istype(chip))
		return ic_tgui_chip_accent_hex(chip)
	var/t = chip.type
	while(t)
		if(GLOB.ie_ic_tgui_accent_by_type[t])
			return GLOB.ie_ic_tgui_accent_by_type[t]
		t = type2parent(t)
	return ic_tgui_chip_accent_hex(chip)

/// Converts a hue in degrees and 0-255 saturation/value into a hex colour.
/proc/ic_hsv255_to_rgb(hue, saturation, value, alpha)
	var/h = ((hue % 360) + 360) % 360
	var/s = clamp(saturation, 0, 255) * (100 / 255)
	var/v = clamp(value, 0, 255) * (100 / 255)
	if(isnull(alpha))
		return hsv2rgb(list(h, s, v))
	return hsv2rgb(list(h, s, v, clamp(alpha, 0, 255) * (100 / 255)))

/proc/type2parent(child)
	var/string_type = "[child]"
	var/last_slash = findlasttext(string_type, "/")
	if(last_slash == 1)
		switch(child)
			if(/datum)
				return null
			if(/obj, /mob)
				return /atom/movable
			if(/area, /turf)
				return /atom
			else
				return /datum
	return text2path(copytext(string_type, 1, last_slash))
