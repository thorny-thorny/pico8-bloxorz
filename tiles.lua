map_width_tiles = 16
map_height_tiles = 10

function tile_point_to_xy(point)
  return make_xy_point(
    -2 + 7 * point.u + 2 * point.v,
    15 + 2 * (16 - point.u) + 6 * point.v
  )
end
