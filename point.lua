function make_xy_point(x, y)
  return {
    x = x,
    y = y,
    add = xy_point_add,
  }
end

function xy_point_add(self, x, y)
  self.x += x
  self.y += y
end

function make_uv_point(u, v)
  return {
    u = u,
    v = v,
    in_bounds = uv_point_in_bounds,
  }
end

function uv_point_in_bounds(self, umin, vmin, umax, vmax)
  return
    self.u >= umin and
    self.u <= umax and
    self.v >= vmin and
    self.v <= vmax
end
