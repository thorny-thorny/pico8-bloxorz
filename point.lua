function make_xy_point(x, y)
  return {
    x = x,
    y = y,
    add = xy_point_add,
    add_point = xy_point_add_point,
  }
end

function xy_point_add(self, x, y)
  self.x += x
  self.y += y
end

function xy_point_add_point(self, point)
  self.x += point.x
  self.y += point.y
end

function make_uv_point(u, v)
  return {
    u = u,
    v = v,
    equals = uv_point_equals,
    in_bounds = uv_point_in_bounds,
    by_adding_u = uv_point_by_adding_u,
    by_adding_v = uv_point_by_adding_v,
    by_adding_point = uv_point_by_adding_point,
    is_zero = uv_point_is_zero,
    touches_point_by_u = uv_point_touches_point_by_u,
    touches_point_by_v = uv_point_touches_point_by_v,
  }
end

function uv_point_equals(self, point)
  return self.u == point.u and self.v == point.v
end

function uv_point_in_bounds(self, umin, vmin, umax, vmax)
  return
    self.u >= umin and
    self.u <= umax and
    self.v >= vmin and
    self.v <= vmax
end

function uv_point_by_adding_u(self, du)
  return make_uv_point(self.u + du, self.v)
end

function uv_point_by_adding_v(self, dv)
  return make_uv_point(self.u, self.v + dv)
end

function uv_point_by_adding_point(self, point)
  return make_uv_point(self.u + point.u, self.v + point.v)
end

function uv_point_is_zero(self)
  return self.u == 0 and self.v == 0
end

function uv_point_touches_point_by_u(self, point)
  return abs(self.u - point.u) == 1 and self.v == point.v
end

function uv_point_touches_point_by_v(self, point)
  return abs(self.v - point.v) == 1 and self.u == point.u
end
