function level_create(level_number)
	local map_offset = make_uv_point(
		(level_number % 8) * map_width_tiles,
		flr(level_number / 8) * map_height_tiles
	)

	local start = make_uv_point(0, 0)
	local finish = make_uv_point(0, 0)

	for u = 0, map_width_tiles - 1 do
		for v = 0, map_height_tiles - 1 do
			local sprite = mget(map_offset.u + u, map_offset.v + v)
			if sprite_is_start(sprite) then
				start = make_uv_point(u, v)
			elseif sprite_is_finish(sprite) then
				finish = make_uv_point(u, v)
			end
		end
	end

	local level = {
		map_offset = map_offset,
		start = start,
		finish = finish,
		finished = false,
		reset = level_reset,
		press_button = level_press_button,
		enter_portal = level_enter_portal,
		platform_state = level_platform_state,
		update = level_update,
		draw = level_draw,
		draw_tile = level_draw_tile,
	}

	level:reset()

	return level
end

function level_reset(self)
	self.hole = nil
	self.waiting_for_animaiton = false
	self.platforms = { 0, 0, 0, 0 }
	self.block = block_create(
		self.start.u,
		self.start.v
	)
	self.block:animate_start()
end

function level_press_button(self, sprite)
	local index = sprite_index_bit(sprite)
	local state = self.platforms[index]
	local stype = get_sprite_type(sprite)
	if
		stype == sprite_type.circle_button_on or
		stype == sprite_type.cross_button_on
	then
		state = 1
	elseif
		stype == sprite_type.circle_button_off or
		stype == sprite_type.cross_button_off
	then
		state = -1
	else
		if state == 0 then
			state = 2
		elseif state == 2 then
			state = 0
		else
			state = -state
		end
	end

	self.platforms[index] = state
end

function level_enter_portal(self, sprite)
	local index = sprite_index_bit(sprite)
	local point1 = make_uv_point(-1, -1)
	local point2 = make_uv_point(-1, -1)

	for u = 0, map_width_tiles - 1 do
		for v = 0, map_height_tiles - 1 do
			local sprite = mget(self.map_offset.u + u, self.map_offset.v + v)
			if
				sprite_is_portal_half(sprite) or
				(
					sprite_is_portal_target(sprite) and
					sprite_index_bit(sprite) == index
				) or
				(
					sprite_is_start(sprite) and
					sprite_index_bit(sprite) == index
				)
			then
				if point1.u == -1 then
					point1 = make_uv_point(u, v)
				else
					point2 = make_uv_point(u, v)
				end
			end
		end
	end

	self.block:split(self.block, point1.u, point1.v, point2.u, point2.v)
end

function level_platform_state(self, sprite)
	local index = sprite_index_bit(sprite)
 	local state = self.platforms[index]
	if state == 1 then
		return 1
	elseif state == -1 then
		return -1
	else
		local pstate = sprite_platform_state(sprite)
		if state == 0 then
			return pstate
		else
			return -pstate
		end
	end
end

function level_update(self)
	local updated = self.block:update()
	if not updated then
		return false
	end

	local points = self.block:get_points()
	local died = false
	local finished = false
	local hole_points = {}
	for i = 1, #points do
		local sprite = mget(self.map_offset.u + points[i].u, self.map_offset.v + points[i].v)
		local empty_tile = sprite == 0
		local out_of_bounds = not points[i]:in_bounds(0, 0, map_width_tiles - 1, map_height_tiles - 1)
		local fragile_tile = #points == 1 and sprite_is_fragile(sprite)
		local off_platform = sprite_is_platform(sprite) and self:platform_state(sprite) < 0

		if empty_tile or out_of_bounds or fragile_tile or off_platform then
			died = true
			hole_points[#hole_points + 1] = points[i]
		elseif #points == 1 and self.finish:equals(points[i]) then
			finished = true
		-- elseif #points == 1 and sprite_is_portal(sprite) then
			-- if self.block.updated then
			-- 	self:enter_portal(sprite)
			-- end
		elseif
			sprite_is_circle_button(sprite) or
			(
				sprite_is_cross_button(sprite) and
				#points == 1
			)
		then
				self:press_button(sprite)
		end
	end

	if finished then
		if not self.waiting_for_animaiton then
			self.waiting_for_animaiton = true
			self.hole = self.block.point
			self.block:animate_finish()
		else
			return true
		end
	elseif died then
		if not self.waiting_for_animaiton then
			local hole_side = block_side.z
			if #hole_points > 1 then
				if hole_points[1].u == hole_points[2].u then
					hole_side = block_side.v
				else
					hole_side = block_side.u
				end
			end

			self.hole = hole_points[1]
			self.waiting_for_animaiton = true
			self.block:animate_falling(hole_points[1], hole_side)
		else
			self:reset()
		end
	end

	return false
end

function level_draw(self)
	local hole = make_uv_point(map_width_tiles, map_height_tiles)
	if self.hole ~= nil then
		hole = self.hole
	end

 for u = map_width_tiles - 1, 0, -1 do
  for v = 0, map_height_tiles - 1 do
  	if (u > hole.u and v <= hole.v) or (u <= hole.u and v < hole.v) or (u == hole.u and v == hole.v) then
  		self:draw_tile(u, v)
  	end
 	end
 end

 self.block:draw()

 for u = map_width_tiles - 1, 0, -1 do
  for v = 0, map_height_tiles - 1 do
  	if ((u > hole.u and v > hole.v) or (u <= hole.u and v >= hole.v)) and not (u == hole.u and v == hole.v) then
  		self:draw_tile(u, v)
  	end
 	end
 end
end

function level_draw_tile(self, u, v)
	local sprite = mget(self.map_offset.u + u, self.map_offset.v + v)
	if sprite > 0 then
		if sprite_is_start(sprite) then
			sprite = 1
		elseif sprite_is_circle_button(sprite) then
			sprite = 2
		elseif sprite_is_cross_button(sprite) then
			sprite = 3
		elseif sprite_is_platform(sprite) then
			if self:platform_state(sprite) > 0 then
				sprite = 4
			else
				sprite = 0
			end
		elseif sprite_is_portal(sprite) then
			sprite = 7
		elseif sprite_is_portal_target(sprite) then
			sprite = 1
		end

		if sprite > 0 then
			local point = tile_point_to_xy(make_uv_point(u, v))
		 	spr(sprite, point.x, point.y)
		end
	end
end
