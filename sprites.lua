sprite_type = {
	start = 0b0001,
	finish = 0b0010,
	circle_button_on = 0b0011,
	circle_button_off = 0b0100,
	circle_button_toggle = 0b0101,
	cross_button_on = 0b0110,
	cross_button_off = 0b0111,
	cross_button_toggle = 0b1000,
	platform_on = 0b1001,
	platform_off = 0b1010,
	fragile = 0b1011,
	portal = 0b1100,
	portal_half = 0b1101,
	portal_target=0b1110,
}

function get_sprite_type(sprite)
	return fget(sprite) & 0b1111
end

function sprite_is_start(sprite)
	return get_sprite_type(sprite) == sprite_type.start
end

function sprite_is_finish(sprite)
	return get_sprite_type(sprite) == sprite_type.finish
end

function sprite_is_circle_button(sprite)
 local stype = get_sprite_type(sprite)
	return
		stype == sprite_type.circle_button_on or
		stype == sprite_type.circle_button_off or
		stype == sprite_type.circle_button_toggle
end

function sprite_is_cross_button(sprite)
	local stype = get_sprite_type(sprite)
	return
		stype == sprite_type.cross_button_on or
		stype == sprite_type.cross_button_off or
		stype == sprite_type.cross_button_toggle
end

function sprite_is_platform(sprite)
	local stype = get_sprite_type(sprite)
	return
		stype == sprite_type.platform_on or
		stype == sprite_type.platform_off
end

function sprite_platform_state(sprite)
	if get_sprite_type(sprite) == sprite_type.platform_on then
		return 1
	else
		return -1
	end
end

function sprite_is_fragile(sprite)
	return get_sprite_type(sprite) == sprite_type.fragile
end

function sprite_is_portal(sprite)
 local stype = get_sprite_type(sprite)
 return
 	stype == sprite_type.portal or
 	stype == sprite_type.portal_half
end

function sprite_is_portal_half(sprite)
	return get_sprite_type(sprite) == sprite_type.portal_half
end

function sprite_is_portal_target(sprite)
 return get_sprite_type(sprite) == sprite_type.portal_target
end

function sprite_index_bit(sprite)
	local index_bits = (fget(sprite) >> 4) & 0b1111
	
	for i = 1,4 do
		if ((index_bits >> (i - 1)) & 0b1) > 0 then
			return i
		end
	end
	
	return 0
end
