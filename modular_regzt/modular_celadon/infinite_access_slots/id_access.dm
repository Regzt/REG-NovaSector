/*
/datum/controller/subsystem/id_access/Initialize()
	. = ..()
	if(!fexists(PATH_TO_WILDCARD_SETTING_CACHE))
		return .

	var/raw_file = file(PATH_TO_WILDCARD_SETTING_CACHE)
	if(!raw_file)
		return .

	var/json_text = file2text(raw_file)

	fdel(PATH_TO_WILDCARD_SETTING_CACHE)

	if(!json_text)
		return .

	var/json
	try
		json = json_decode(json_text)
	catch(var/exception/e)
		log_world("Failed to decode [PATH_TO_WILDCARD_SETTING_CACHE]: [e]")
		return .

	if(!json)
		return .

	if (json["disable_infinity_wildcard"])
		CONFIG_SET(flag/infinite_access_slots, FALSE)
		log_world("flag infinite_access_slots set to FALSE by cached [PATH_TO_WILDCARD_SETTING_CACHE] file")
		var/msg_constructed = "infinity wildcard access slots was disabled for this round (by admin at last round)"
		message_admins(msg_constructed)
		log_admin(msg_constructed)

	return .
*/
