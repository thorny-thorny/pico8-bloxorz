function menu_scene_create()
  local title = 'ploxorz'

  local scene = {
    title = title,
    letters_left = #title,
    frame = 0,
    update = menu_scene_update,
    draw = menu_scene_draw,
    block = block_create(12, 5, true),
    wait_for_block_fall = true,
  }

  scene.block:animate_start()

  return scene
end

function menu_scene_update(self)
  if self.letters_left > 0 then
    self.frame += 1
  end

  if self.letters_left > 0 then
    if (self.frame - 1) % 10 == 0 then
      self.letters_left -= 1
    end
  else
    local did_update = self.block:update()
    if self.wait_for_block_fall and did_update then
      self.wait_for_block_fall = false
      self.block:animate_falling()
    else
      if btnp(🅾️) then
        show_game()
      end
    end
  end
end

function menu_scene_draw(self)
  print('\^p'..sub(self.title, 1, #self.title - self.letters_left), 30, 48, 9)
  self.block:draw()

  if not self.wait_for_block_fall then
    print('demake of bloxorz', 32, 66, 7)
    print('🅾️ to start', 44, 76, 7)
    print('❎ to switch (in game)', 22, 82, 7)
    print('demo version 0.1.0', 30, 120, 7)
  end
end
