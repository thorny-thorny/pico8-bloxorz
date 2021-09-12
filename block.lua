block_side = {
	z = 0, -- location: [(u, v)]
	u = 1, -- location: [(u, v), (u+1, v)]
	v = 2, -- location: [(u, v), (u, v+1)]
}

falling_animation_delay = 3

function block_create(u, v)
	local block = {
		point = make_uv_point(u, v),
		side = block_side.z,
		split_point = nil,
		split_active = false,
		updated = false,
		did_animated_fall = false,
		animate_falling = block_animate_falling,
		draw = block_draw,
		subdraw = block_subdraw,
	}
	block.animation = {
		cycles_left = 10,
		frame = 0,
		from_side = block.side,
		from_u = block.u,
		from_v = block.v,
	}
	return block
end

function block_animate_falling(self, hole)
	local du = 0
	local dv = 0
	local same = self.side == self.prev_side

	if not same then
		if hole.u > self.u then
			du = 1
		elseif hole.v > self.v then
			dv = 1
		elseif
			hole.u == self.u or
			hole.v == self.v
		then
			if self.u == self.prev_u then
				self.v += 1
				dv = -1
			else
				self.u += 1
				du = -1
			end
		end
	end

	self.animation = {
		cycles_left = falling_animation_delay,
		delay_left = falling_animation_delay,
		frame = 0,
		from_side = self.side,
		from_u = self.u,
		from_v = self.v,
		falling = true,
	}
	self.side = block_side.z
	self.point.u += du
	self.point.v += dv

	if same then
		self.animation.cycles_left = 100
	end
end

function block_get_points(block)
	local points = {}
	points[1] = make_uv_point(block.u, block.v)

	if block.split then
		points[2] = make_uv_point(block.u2, block.v2)
	elseif block.side == block_side.u then
		points[2] = make_uv_point(block.u + 1, block.v)
	elseif block.side == block_side.v then
		points[2] = make_uv_point(block.u + 1, block.v + 1)
	end

	return points
end

function block_stands_on(block, u, v, whole)
	local points = block_get_points(block)
	if whole then
		if #points != 1 then
			return false
		else	
			return points[1].u == u and points[1].v == v
		end	
	end
end

function block_split(block, u1, v1, u2, v2)
	block.split = true
	block.split_index = 0
	block.side = block_side.z
	block.u = u1
	block.v = v1
	block.u2 = u2
	block.v2 = v2
end

function block_update(block)
	if block.animation != nil then
		if block.animation.frame > 30 then
			block.did_animated_fall = true
			block.animation = nil
			return
		elseif block.animation.cycles_left > 0 then
			block.animation.cycles_left -= 1
			block.animation.frame += 1
			return
		elseif block.animation.delay_left != nil then
			if block.animation.delay_left > 0 then
				block.animation.delay_left -= 1
				block.animation.frame +=1
				return
			end

			local prev_side = block.animation.from_side
			local du = block.u - block.animation.from_u
			local dv = block.v - block.animation.from_v
			block.animation = {
				cycles_left = falling_animation_delay,
				delay_left = falling_animation_delay,
				frame = block.animation.frame,
				from_side = block.side,
				from_u = block.u-du,
				from_v = block.v-dv,
				falling = true,
			}
			block.side = prev_side
			return
		elseif block.animation.falling == nil then
			block.animation = nil
			return
		end
	end

	local du = 0
	local dv = 0
	block.updated = false

 if btnp(⬅️) then
 	du = -1 
 elseif btnp(➡️) then
 	du = 1
 elseif btnp(⬆️) then
 	dv = -1
 elseif btnp(⬇️) then
 	dv = 1
 elseif btnp(🅾️) then
  block.split_index = 1 - block.split_index
 end

 if du != 0 or dv != 0 then
 	block.animation = {
 		cycles_left = 1,
 		frame = 0,
 		from_side = block.side,
 		from_u = block.u,
 		from_v = block.v,
 	}
 	block.prev_u = block.u
 	block.prev_v = block.v
 	block.prev_side = block.side
 end

	if du != 0 then
	 if block.split then
	 	block.side = block_side.z
		elseif block.side == block_side.z then
			if du < 0 then du = -2 end
			block.side = block_side.u
		elseif block.side == block_side.u then
			if du > 0 then du = 2 end
			block.side = block_side.z
		end

		if
			block.split and
			block.split_index == 1
		then
			block.u2 += du
		else
			block.u += du
		end
		block.updated = true
	elseif dv != 0 then
	 if block.split then
	  block.side = block_side.z
		elseif block.side == block_side.z then
			if dv < 0 then dv = -2 end
			block.side = block_side.v
		elseif block.side == block_side.v then
			if dv > 0 then dv = 2 end 
			block.side = block_side.z
		end

		if
			block.split and
			block.split_index == 1
		then
			block.v2 += dv
		else
			block.v += dv
		end
		block.updated = true
	end

	if block.split then
		local touch_u =
			abs(block.u-block.u2) == 1 and
			block.v == block.v2
		local touch_v =
			abs(block.v-block.v2) == 1 and
			block.u == block.u2
		if touch_u or touch_v then
			block.split = false
			if touch_u then
				block.side = block_side.u
				block.u = min(block.u, block.u2)
			else
				block.side = block_side.v
				block.v = min(block.v, block.v2)
			end
		end
	end
end

function block_subdraw(self, draw_split)
	local point = self.point
	if draw_split then
		point = self.split_point
	end

	local p = make_xy_point(
		uvtox(point.u, point.v),
		uvtoy(point.u, point.v)
	)

	local sprite = 0
	local thin = false

	if
		self.animation ~= nil and
		self.animation.cycles_left > 0
	then
		local z_to_u = self.side == block_side.u and self.animation.from_side == block_side.z
		local z_to_v = self.side == block_side.v and self.animation.from_side == block_side.z
		local u_to_z = self.side == block_side.z and self.animation.from_side == block_side.u
		local v_to_z = self.side == block_side.z and self.animation.from_side == block_side.v
		local v_to_v = self.side == block_side.v and self.animation.from_side == block_side.v
		local u_to_u = self.side == block_side.u and self.animation.from_side == block_side.u
		local z_to_z = self.side == block_side.z and self.animation.from_side == block_side.z

		local u_greater = self.u > self.animation.from_u
		local v_greater = self.v > self.animation.from_v

		if z_to_u and u_greater then
			sprite = 70
			p:add(-3, -8)
		elseif z_to_u and not u_greater then
			sprite = 72
			p:add(3, -13)
		elseif u_to_z and not u_greater then
			sprite = 70
			p:add(4, -10)
		elseif u_to_z and u_greater then
			sprite = 72
			p:add(-11, -9)
		elseif z_to_v and v_greater then
			sprite = 74
			p:add(0, -10)
		elseif z_to_v and not v_greater then
			sprite = 76
			p:add(-4, -2)
		elseif v_to_z and not v_greater then
			sprite = 74
			p:add(2, -4)
		elseif v_to_z and v_greater then
			sprite = 76
			p:add(-7, -13)
		elseif v_to_v and u_greater then
			sprite = 78
			p:add(-5, -3)
		elseif v_to_v and not u_greater then
			sprite = 78
			p:add(2, -5)
		elseif u_to_u and v_greater then
			sprite = 96
			p:add(0, -14)
		elseif u_to_u and not v_greater then
			sprite = 96
			p:add(0, -10)
		elseif z_to_z then
			p:add(0, -self.animation.cycles_left * 10)
		end
	end

	if
		self.animation ~= nil and
		self.animation.falling ~= nil and
 		self.animation.from_side ~= self.side
	then
		local dup = make_xy_point(uvtox(1, 0) - uvtox(0, 0), uvtoy(1, 0) - uvtoy(0, 0))
		local dvp = make_xy_point(uvtox(0, 1) - uvtox(0, 0), uvtoy(0, 1) - uvtoy(0, 0))
		local d = make_uv_point(self.u - self.animation.from_u, self.v - self.animation.from_v)

		if self.animation.cycles_left == 0 then
			if self.side == block_side.u then
				p:add(-dup.x / 2, 0)
			elseif self.side == block_side.v then
				p:add(0, -dvp.y/2)
			end
		end

		if self.animation.cycles_left > 0 then
			if self.side == block_side.z then
				p:add(dup.x * d.u + dvp.x * d.v, dup.y * d.u + dvp.y * d.v)
			end
			if self.side == block_side.u and d.u < 0 then
				p:add(-dup.x, 0)
			end
			if self.side == block_side.v and d.v < 0 then
 				p:add(0, -dvp.y)
			end
		end

		p:add(0, self.animation.frame * 4)
	end

	if sprite == 0 then
		if self.split_point ~= nil then
			sprite = 69
			p:add(0, -10)
			thin = true
		elseif self.side == block_side.u then
			sprite = 64
			p:add(0, -10)
		elseif self.side == block_side.z then
			sprite = 66
			p:add(0, -10)
			thin = true
		elseif self.side == block_side.v then
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
