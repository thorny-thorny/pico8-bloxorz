block_side = {
	z = 0, -- location: [(u, v)]
	u = 1, -- location: [(u, v), (u + 1, v)]
	v = 2, -- location: [(u, v), (u, v + 1)]
}

function block_transition(from_point, from_side, to_point, to_side)
  local sprite = nil
  local d = make_xy_point(0, 0)

  local z_to_u = to_side == block_side.u and from_side == block_side.z
  local z_to_v = to_side == block_side.v and from_side == block_side.z
  local u_to_z = to_side == block_side.z and from_side == block_side.u
  local v_to_z = to_side == block_side.z and from_side == block_side.v
  local v_to_v = to_side == block_side.v and from_side == block_side.v
  local u_to_u = to_side == block_side.u and from_side == block_side.u
  local z_to_z = to_side == block_side.z and from_side == block_side.z -- splits

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
  elseif z_to_z and u_greater then
    sprite = 98
    d:add(-2, -8)
  elseif z_to_z and not u_greater and to_point.u ~= from_point.u then
    sprite = 100
    d:add(-5, -11)
  elseif z_to_z and v_greater then
    sprite = 102
    d:add(-1, -10)
  elseif z_to_z and not v_greater and to_point.v ~= from_point.v then
    sprite = 104
    d:add(-4, -1)
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
    frames_left = 2,
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
  if self.frames_left == 0 then
    return {}
  else
    return block_transition(self.from_point, self.from_side, self.to_point, self.to_side)
  end
end

function make_block_fall_animation(point, side, initial_offset, short)
  local frames_total = 30
  if initial_offset then
    frames_total = 10
  elseif short then
    frames_total = 30
  end

  local animation = {
    point = point,
    side = side,
    initial_offset = initial_offset,
    frames_total = frames_total,
    short = short,
    frame = 0,
    update = block_fall_animation_update,
    get_state = block_fall_animation_get_state,
  }

  return animation
end

function block_fall_animation_update(self)
  self.frame += 1
  if self.frame >= self.frames_total then
    return false
  else
    return true
  end
end

function block_fall_animation_get_state(self)
  local d = make_xy_point(0, 0)
  if self.initial_offset then
    d:add(0, -(self.frames_total - self.frame) * 8)
  else
    if self.short then
      if self.frame >= 5 then
        d:add(0, 100)
      else
        d:add(0, self.frame * 2)
      end
    else
      d:add(0, self.frame * 4)
    end
  end

  return {
    d = d,
  }
end

function make_block_spin_fall_animation(from_point, from_side, to_point, to_side)
  local animation = {
    from_point = from_point,
    from_side = from_side,
    to_point = to_point,
    to_side = to_side,
    frames_left = 30,
    frame = 0,
    update = block_spin_fall_animation_update,
    get_state = block_spin_fall_animation_get_state,
  }

  return animation
end

function block_spin_fall_animation_update(self)
  if self.frames_left == 0 then
    return false
  else
    self.frames_left -= 1
    self.frame += 1
    return true
  end
end

function block_spin_fall_animation_get_state(self)
  local step = flr(self.frame / 2) % 4
  local zero = tile_point_to_xy(make_uv_point(0, 0))
  local du_xy = tile_point_to_xy(make_uv_point(1, 0))
  local dv_xy = tile_point_to_xy(make_uv_point(0, 1))
  local dup = make_xy_point(du_xy.x - zero.x, du_xy.y - zero.y)
  local dvp = make_xy_point(dv_xy.x - zero.x, dv_xy.y - zero.y)
  local dd = make_uv_point(self.to_point.u - self.from_point.u, self.to_point.v - self.from_point.v)
  local d = make_xy_point(0, 0)

  local state
  -- TODO: remove math, harcode offset
  if step == 0 then
    state = block_transition(self.from_point, self.from_side, self.to_point, self.to_side)
    state.d:add(dup.x * dd.u + dvp.x * dd.v, dup.y * dd.u + dvp.y * dd.v)
  elseif step == 1 then
    state = {
      d = d,
    }
  elseif step == 2 then
    state = block_transition(self.from_point, self.to_side, self.to_point, self.from_side)
    if self.from_side == block_side.u and dd.u < 0 then
      state.d:add(-dup.x, 0)
    end
    if self.from_side == block_side.v and dd.v < 0 then
      state.d:add(0, -dvp.y)
    end
  elseif step == 3 then
    if self.from_side == block_side.u then
      d:add(-dup.x / 2, 0)
    elseif self.side == block_side.v then
      d:add(0, -dvp.y / 2)
    end
    state = {
      d = d,
      side = self.from_side,
    }
  end

  state.d:add(0, self.frame * 4)

  return state
end

function make_block_teleport_animation(point)
  local animation = {
    point = point,
    frames_left = 6,
    dy = -4,
    update = block_teleport_animation_update,
    get_state = block_teleport_animation_get_state,
    draw = block_teleport_animation_draw,
  }

  return animation
end

function block_teleport_animation_update(self)
  if self.frames_left == 0 then
    return false
  else
    self.frames_left -= 1
    self.dy = min(0, self.dy + 2)
    return true
  end
end

function block_teleport_animation_get_state(self)
  return {
    d = make_xy_point(0, self.dy),
    split = true,
  }
end

function block_teleport_animation_draw(self)
  draw_split_selection(self.point, make_xy_point(0, self.dy))
end

function draw_split_selection(point_uv, d)
  local point = tile_point_to_xy(point_uv)
  if d ~= nil then
    point:add_point(d)
  end

  spr(50, point.x - 7, point.y - 3)
  spr(51, point.x + 7, point.y - 3)
end

function make_block_switch_animation(point)
  local animation = {
    point = point,
    frames_left = 6,
    update = block_switch_animation_update,
    get_state = block_switch_animation_get_state,
    draw = block_switch_animation_draw,
  }

  return animation
end

function block_switch_animation_update(self)
  if self.frames_left == 0 then
    return nil
  else
    self.frames_left -= 1
    return true
  end
end

function block_switch_animation_get_state(self)
  return {}
end

function block_switch_animation_draw(self)
  draw_split_selection(self.point)
end
