block_side = {
	z = 0, -- location: [(u, v)]
	u = 1, -- location: [(u, v), (u + 1, v)]
	v = 2, -- location: [(u, v), (u, v + 1)]
}

-- falling_animation_delay = 3

function block_transition(from_point, from_side, to_point, to_side)
  local sprite = nil
  local d = make_xy_point(0, 0)

  local z_to_u = to_side == block_side.u and from_side == block_side.z
  local z_to_v = to_side == block_side.v and from_side == block_side.z
  local u_to_z = to_side == block_side.z and from_side == block_side.u
  local v_to_z = to_side == block_side.z and from_side == block_side.v
  local v_to_v = to_side == block_side.v and from_side == block_side.v
  local u_to_u = to_side == block_side.u and from_side == block_side.u
  local z_to_z = to_side == block_side.z and from_side == block_side.z

  local u_greater = to_point.u > from_point.u
  local v_greater = to_point.v > from_point.v

  if z_to_u and u_greater then
    sprite = 70
    d:add(-3, -8)
  elseif z_to_u and not u_greater then
    sprite = 72
    d:add(3, -13)
  elseif u_to_z and not u_greater then
    sprite = 70
    d:add(4, -10)
  elseif u_to_z and u_greater then
    sprite = 72
    d:add(-11, -9)
  elseif z_to_v and v_greater then
    sprite = 74
    d:add(0, -10)
  elseif z_to_v and not v_greater then
    sprite = 76
    d:add(-4, -2)
  elseif v_to_z and not v_greater then
    sprite = 74
    d:add(2, -4)
  elseif v_to_z and v_greater then
    sprite = 76
    d:add(-7, -13)
  elseif v_to_v and u_greater then
    sprite = 78
    d:add(-5, -3)
  elseif v_to_v and not u_greater then
    sprite = 78
    d:add(2, -5)
  elseif u_to_u and v_greater then
    sprite = 96
    d:add(0, -14)
  elseif u_to_u and not v_greater then
    sprite = 96
    d:add(0, -10)
  end

  return {
    d = d,
    sprite = sprite,
  }
end

function make_block_transition_animation(from_point, from_side, to_point, to_side)
  local animation = {
    from_point = from_point,
    from_side = from_side,
    to_point = to_point,
    to_side = to_side,
    frames_left = 1,
    update = block_transition_animation_update,
    get_state = block_transition_animation_get_state,
  }

  return animation
end

function block_transition_animation_update(self)
  if self.frames_left == 0 then
    return false
  else
    self.frames_left -= 1
    return true
  end
end

function block_transition_animation_get_state(self)
  return block_transition(self.from_point, self.from_side, self.to_point, self.to_side)
end

function make_block_fall_animation(from_point, from_side, to_point, to_side)
  local animation = {
    from_point = from_point,
    from_side = from_side,
    to_point = to_point,
    to_side = to_side,
    frames_left = 1,
    frame = 0,
    update = block_fall_animation_update,
    get_state = block_fall_animation_get_state,
  }

  return animation
end

function block_fall_animation_update(self)
  -- if self.frames_left == 0 then
  --   return false
  -- else
  --   self.frames_left -= 1
  --   return true
  -- end
  self.frame += 1
  return true
end

function block_fall_animation_get_state(self)
  local step = flr(self.frame / 15) % 4
  local zero = tile_point_to_xy(make_uv_point(0, 0))
  local du_xy = tile_point_to_xy(make_uv_point(1, 0))
  local dv_xy = tile_point_to_xy(make_uv_point(0, 1))
  local dup = make_xy_point(du_xy.x - zero.x, du_xy.y - zero.y)
  local dvp = make_xy_point(dv_xy.x - zero.x, dv_xy.y - zero.y)
    -- local d = make_uv_point(self.u - self.animation.from_u, self.v - self.animation.from_v)
  local d = make_xy_point(0, 0)

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

  if step == 0 then
    return block_transition(self.from_point, self.from_side, self.to_point, self.to_side)
  elseif step == 1 then
    d:add(-dup.x / 2, 0)
    return {
      d = d,
    }
  elseif step == 2 then
    return block_transition(self.from_point, self.to_side, self.to_point, self.from_side)
  elseif step == 3 then
    return {
      side = self.from_side,
    }
  end
end
