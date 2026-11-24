// Compatibility helpers carried over from Bay12/BlueMoon for legacy integrated electronics.

/// Returns a copy of the list without duplicate entries.
/proc/uniqueList(list/L)
	. = list()
	for(var/i in L)
		. |= i

/// Encodes a string as a hexadecimal byte string.
/proc/strtohex(str)
	if(!istext(str) || !str)
		return
	var/r
	for(var/i = 1 to length(str))
		r += num2hex(text2ascii(str, i), 2)
	return r

/// Decodes a hexadecimal byte string back into a raw string.
/proc/hextostr(str, safe = FALSE)
	if(!istext(str) || !str)
		return
	var/r
	for(var/i = 1 to length(str) / 2)
		var/c = text2num(copytext(str, i * 2 - 1, i * 2 + 1), 16)
		if(isnull(c))
			if(safe)
				return null
			CRASH("Invalid hex string passed to hextostr: [str]")
		r += ascii2text(c)
	return r

/// Like get_step_towards, but steps around simple blocked turfs.
/proc/get_step_towards2(atom/ref, atom/trg)
	var/base_dir = get_dir(ref, get_step_towards(ref, trg))
	var/turf/temp = get_step_towards(ref, trg)

	if(temp.is_blocked_turf())
		var/dir_alt1 = turn(base_dir, 90)
		var/dir_alt2 = turn(base_dir, -90)
		var/turf/turf_last1 = temp
		var/turf/turf_last2 = temp
		var/free_tile = null
		var/breakpoint = 0

		while(!free_tile && breakpoint < 10)
			if(!turf_last1.is_blocked_turf())
				free_tile = turf_last1
				break
			if(!turf_last2.is_blocked_turf())
				free_tile = turf_last2
				break
			turf_last1 = get_step(turf_last1, dir_alt1)
			turf_last2 = get_step(turf_last2, dir_alt2)
			breakpoint++

		if(!free_tile)
			return get_step(ref, base_dir)
		return get_step_towards(ref, free_tile)

	return get_step(ref, base_dir)

/// Like do_mob, but works with any movable user/target and does not draw a progress bar.
/proc/do_atom(atom/movable/user, atom/movable/target, time = 3 SECONDS, timed_action_flags = NONE, datum/callback/extra_checks)
	if(!user || !target)
		return TRUE

	var/user_loc = user.loc
	var/target_loc = target.loc
	var/endtime = world.time + time
	. = TRUE
	while(world.time < endtime)
		stoplag(1)

		if(QDELETED(user) || QDELETED(target))
			. = FALSE
			break

		if(!(timed_action_flags & IGNORE_USER_LOC_CHANGE) && user.loc != user_loc)
			. = FALSE
			break

		if(!(timed_action_flags & IGNORE_TARGET_LOC_CHANGE) && target.loc != target_loc)
			. = FALSE
			break

		if(extra_checks && !extra_checks.Invoke())
			. = FALSE
			break
