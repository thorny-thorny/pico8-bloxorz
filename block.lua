function block_create(u, v)
	local block = {
		point = make_uv_point(u, v),
		side = block_side.z,
		prev_point = nil,
		prev_side = nil,
		split_point = nil,
		split_active = false,
		updated = false,
		did_animated_fall = false,
		animate_falling = block_animate_falling,
		update = block_update,
		draw = block_draw,
		subdraw = block_subdraw,
		stands_on = block_stands_on,
		get_points = block_get_points,
		split = block_split,
	}

	return block
end

function block_animate_falling(self, hole)
	-- local du = 0
	-- local dv = 0
	-- local same = self.side == self.prev_side

	-- if not same then
	-- 	if hole.u > self.u then
	-- 		du = 1
	-- 	elseif hole.v > self.v then
	-- 		dv = 1
	-- 	elseif
	-- 		hole.u == self.u or
	-- 		hole.v == self.v
	-- 	then
	-- 		if self.u == self.prev_u then
	-- 			self.v += 1
	-- 			dv = -1
	-- 		else
	-- 			self.u += 1
	-- 			du = -1
	-- 		end
	-- 	end
	-- end

	-- self.animation = {
	-- 	cycles_left = falling_animation_delay,
	-- 	delay_left = falling_animation_delay,
	-- 	frame = 0,
	-- 	from_side = self.side,
	-- 	from_u = self.u,
	-- 	from_v = self.v,
	-- 	falling = true,
	-- }
	-- self.side = block_side.z
	-- self.point.u += du
	-- self.point.v += dv

	-- if same then
	-- 	self.animation.cycles_left = 100
	-- end
end

function block_get_points(self)
	local points = {}
	points[1] = self.point

	if self.split_point ~= nil then
		points[2] = split_point
	elseif self.side == block_side.u then
		points[2] = self.point:by_adding_u(1)
	elseif self.side == block_side.v then
		points[2] = self.point:by_adding_v(1)
	end

	return points
end

function block_stands_on(self, point, whole)
	local points = self:get_points()
	if whole and #points != 1 then
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

function block_update(self)
	if self.animation ~= nil then
		local animating = self.animation:update()
		if animating then
			return
		else
			self.animation = nil
			self.updated = true
			return
		end
	end


	-- if self.animation != nil then
	-- 	if self.animation.frame > 30 then
	-- 		self.did_animated_fall = true
	-- 		self.animation = nil
	-- 		return
	-- 	elseif self.animation.cycles_left > 0 then
	-- 		self.animation.cycles_left -= 1
	-- 		self.animation.frame += 1
	-- 		return
	-- 	elseif self.animation.delay_left != nil then
	-- 		if self.animation.delay_left > 0 then
	-- 			self.animation.delay_left -= 1
	-- 			self.animation.frame +=1
	-- 			return
	-- 		end

	-- 		local prev_side = self.animation.from_side
	-- 		local du = self.u - self.animation.from_u
	-- 		local dv = self.v - self.animation.from_v
	-- 		self.animation = {
	-- 			cycles_left = falling_animation_delay,
	-- 			delay_left = falling_animation_delay,
	-- 			frame = block.animation.frame,
	-- 			from_side = block.side,
	-- 			from_u = block.u-du,
	-- 			from_v = block.v-dv,
	-- 			falling = true,
	-- 		}
	-- 		self.side = prev_side
	-- 		return
	-- 	elseif self.animation.falling == nil then
	-- 		self.animation = nil
	-- 		return
	-- 	end
	-- end

	local d = make_uv_point(0, 0)
	local new_side = self.side
	self.updated = false

	if btnp(⬅️) then
		d.u = -1 
	elseif btnp(➡️) then
		d.u = 1
	elseif btnp(⬆️) then
		d.v = -1
	elseif btnp(⬇️) then
		d.v = 1
	elseif btnp(🅾️) then
	-- self.split_active = ~self.split_active
	end

	if d.u != 0 then
		if self.split_point != nil then
			-- self.side = block_side.z
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
	elseif d.v != 0 then
		if self.split_point != nil then
			-- self.side = block_side.z
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
		if self.split_point != nil and self.split_active == 1 then
			-- point = self.split_point
		end

		self.prev_point = self.point
		self.prev_side = self.side

		self.point = point:by_adding_point(d)
		self.side = new_side

		-- self.animation = make_block_transition_animation(self.prev_point, self.prev_side, self.point, self.side)
		self.animation = make_block_fall_animation(self.prev_point, self.prev_side, self.point, self.side)
	end

	-- if self.split_point != nil then
	-- 	local touches_u = self.point:touches_point_by_u(self.split_point)
	-- 	local touches_v = self.point:touches_point_by_v(self.split_point)

	-- 	if touches_u or touches_v then
	-- 		self.split = false
	-- 		self.updated = true

	-- 		if touches_u then
	-- 			self.side = block_side.u
	-- 			self.point.u = min(self.point.u, self.split_point.u)
	-- 		else
	-- 			self.side = block_side.v
	-- 			self.point.v = min(self.point.v, self.split_point.v)
	-- 		end
	-- 	end
	-- end
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

	if self.animation ~= nil then
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

	-- if
	-- 	self.animation ~= nil and
	-- 	self.animation.falling ~= nil and
 	-- 	self.animation.from_side ~= self.side
	-- then
	-- 	local dup = make_xy_point(uvtox(1, 0) - uvtox(0, 0), uvtoy(1, 0) - uvtoy(0, 0))
	-- 	local dvp = make_xy_point(uvtox(0, 1) - uvtox(0, 0), uvtoy(0, 1) - uvtoy(0, 0))
	-- 	local d = make_uv_point(self.u - self.animation.from_u, self.v - self.animation.from_v)

	-- 	if self.animation.cycles_left == 0 then
	-- 		if self.side == block_side.u then
	-- 			p:add(-dup.x / 2, 0)
	-- 		elseif self.side == block_side.v then
	-- 			p:add(0, -dvp.y/2)
	-- 		end
	-- 	end

	-- 	if self.animation.cycles_left > 0 then
	-- 		if self.side == block_side.z then
	-- 			p:add(dup.x * d.u + dvp.x * d.v, dup.y * d.u + dvp.y * d.v)
	-- 		end
	-- 		if self.side == block_side.u and d.u < 0 then
	-- 			p:add(-dup.x, 0)
	-- 		end
	-- 		if self.side == block_side.v and d.v < 0 then
 	-- 			p:add(0, -dvp.y)
	-- 		end
	-- 	end

	-- 	p:add(0, self.animation.frame * 4)
	-- end

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
	self:subdraw(false)
	if self.split_point ~= nil then
		self:subdraw(true)
	end
end
