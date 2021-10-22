function block_create(u, v)
	local block = {
		point = make_uv_point(u, v),
		side = block_side.z,
		prev_point = nil,
		prev_side = nil,
		split_point = nil,
		split_active = false,
		did_animated_fall = false,
		animate_start = block_animate_start,
		animate_falling = block_animate_falling,
		animate_finish = block_animate_finish,
		update = block_update,
		draw = block_draw,
		subdraw = block_subdraw,
		stands_on = block_stands_on,
		get_points = block_get_points,
		split = block_split,
		try_join = block_try_join,
	}

	return block
end

function block_animate_start(self)
	self.animation = make_block_fall_animation(self.point, self.side, true)
end

function block_animate_finish(self)
	self.animation = make_block_fall_animation(self.point, self.side, false, true)
end

function block_animate_falling(self, hole, hole_side)
	local d = make_uv_point(0, 0)

	if self.side ~= block_side.z and hole_side == block_side.z then
		if hole.u > self.point.u then
			d.u = 1
		elseif hole.v > self.point.v then
			d.v = 1
		else
			if self.side == block_side.u then
				self.point.u += 1
				d.u = -1
			else
				self.point.v += 1
				d.v = -1
			end
		end

		local new_point = self.point:by_adding_point(d)
		local new_side = block_side.z

		self.animation = make_block_spin_fall_animation(self.point, self.side, new_point, new_side)

		self.point = new_point
		self.side = new_side
	else
		self.animation = make_block_fall_animation(self.point, self.side, false)
	end
end

function block_get_points(self)
	local points = {}
	points[1] = make_uv_point(self.point.u, self.point.v)

	if self.split_point ~= nil then
		points[2] = self.split_point
	elseif self.side == block_side.u then
		points[2] = self.point:by_adding_u(1)
	elseif self.side == block_side.v then
		points[2] = self.point:by_adding_v(1)
	end

	return points
end

function block_stands_on(self, point, whole)
	local points = self:get_points()
	if whole and #points ~= 1 then
		return false
	end

	for i = 1, #points do
		if points[i]:equals(point) then
			return true
		end
	end

	return false
end

function block_split(self, u1, v1, u2, v2)
	-- self.split = true
	-- self.split_index = 0
	-- self.side = block_side.z
	-- self.u = u1
	-- self.v = v1
	-- self.u2 = u2
	-- self.v2 = v2
end

function block_try_join(self)
	if self.split_point ~= nil then
		local touches_u = self.point:touches_point_by_u(self.split_point)
		local touches_v = self.point:touches_point_by_v(self.split_point)

		if touches_u or touches_v then
			if touches_u then
				self.side = block_side.u
				self.point = make_uv_point(min(self.point.u, self.split_point.u), self.point.v)
			else
				self.side = block_side.v
				self.point = make_uv_point(self.point.u, min(self.point.v, self.split_point.v))
			end

			self.split_active = false
			self.split_point = nil
			return true
		end
	end

	return false
end

function block_update(self)
	if self.animation ~= nil then
		local animating = self.animation:update()
		if animating then
			return false
		else
			self.animation = nil
			return true
		end
	end

	local d = make_uv_point(0, 0)
	local new_side = self.side

	if btnp(⬅️) then
		d.u = -1
	elseif btnp(➡️) then
		d.u = 1
	elseif btnp(⬆️) then
		d.v = -1
	elseif btnp(⬇️) then
		d.v = 1
	elseif btnp(🅾️) then
		self.split_active = not self.split_active
	end

	if d.u ~= 0 then
		if self.split_point ~= nil then
			new_side = block_side.z
		elseif self.side == block_side.z then
			if d.u < 0 then
					d.u = -2
			end
			new_side = block_side.u
		elseif self.side == block_side.u then
			if d.u > 0 then
				d.u = 2
			end
			new_side = block_side.z
		end
	elseif d.v ~= 0 then
		if self.split_point ~= nil then
			new_side = block_side.z
		elseif self.side == block_side.z then
			if d.v < 0 then
				d.v = -2
			end
			new_side = block_side.v
		elseif self.side == block_side.v then
			if d.v > 0 then
				d.v = 2
			end
			new_side = block_side.z
		end
	end

	if not d:is_zero() then
		local point = self.point
		if self.split_point ~= nil and self.split_active then
			point = self.split_point
		end

		self.prev_point = point
		self.prev_side = self.side

		local new_point = point:by_adding_point(d)
		self.side = new_side
		if self.split_point ~= nil and self.split_active then
			self.split_point = new_point
		else
			self.point = new_point
		end

		self.animation = make_block_transition_animation(self.prev_point, self.prev_side, new_point, self.side)
	end

	return false
end

function block_subdraw(self, draw_split)
	local point = self.point
	if draw_split then
		point = self.split_point
	end

	local p = tile_point_to_xy(point)
	local side = self.side
	local sprite = nil
	local thin = false

	if self.animation ~= nil and draw_split == self.split_active then
		local state = self.animation:get_state()
		if state.side ~= nil then
			side = state.side
		end

		if state.sprite ~= nil then
			sprite = state.sprite
		end

		if state.d ~= nil then
			p:add_point(state.d)
		end
	end

	if sprite == nil then
		if self.split_point ~= nil then
			sprite = 69
			p:add(0, -10)
			thin = true
		elseif side == block_side.u then
			sprite = 64
			p:add(0, -10)
		elseif side == block_side.z then
			sprite = 66
			p:add(0, -10)
			thin = true
		elseif side == block_side.v then
			sprite = 67
			p:add(-6, -4)
		end
	end

	spr(sprite, p.x, p.y)
	spr(sprite + 16, p.x, p.y + 8)
	if not thin then
  	spr(sprite + 1, p.x + 8, p.y)
		spr(sprite + 17, p.x + 8, p.y + 8)
	end
end

function block_draw(self)
	if self.split_point ~= nil then
		local draw_split_first = false
		if self.split_point.u > self.point.u or self.split_point.v < self.point.v then
			draw_split_first = true
		end

		self:subdraw(draw_split_first)
		self:subdraw(not draw_split_first)
	else
		self:subdraw(false)
	end
end
