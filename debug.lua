function debug_set(self, val)
  self.val = val
end

function debug_draw(self)
  print(self.val, 0, 0)
end

local dbg = {
  val = "",
  set = debug_set,
  draw = debug_draw,
}
