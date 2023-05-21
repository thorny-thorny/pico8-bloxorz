function menu_scene_create()
  local title = 'ploxorz'

  local scene = {
    background = background_create(),
    title = title,
    letters_left = #title,
    frame = 0,
    selection = 0,
    selection_frame = 0,
    selection_offset = 0,
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
      sfx(sounds.press)
      self.letters_left -= 1
    end
  else
    local did_update = self.block:update()
    if self.wait_for_block_fall and did_update then
      sfx(sounds.hit)
      self.wait_for_block_fall = false
      self.block:animate_falling()
    else
      local d_selection = 0
      if btnp(⬇️) then
        d_selection = 1
      elseif btnp(⬆️) then
        d_selection = -1
      end
      
      self.selection = (self.selection + 2 + d_selection) % 2

      if btnp(🅾️) or btnp(❎) then
        if self.selection == 0 then
          show_instructions()
        elseif self.selection == 1 then
          show_code()
        end
      end
    end
  end

  self.selection_frame += 1
  if self.selection_frame >= 3 then
    self.selection_frame = 0
    self.selection_offset += 1
    if self.selection_offset > 4 then
      self.selection_offset = 0
    end
  end
end

function menu_scene_draw(self)
  if not self.wait_for_block_fall then
    self.background:draw()
    pal(5, 0)
    map(64, 34, 0, 0, 16, 16)
    pal()
  end

  print('\^p'..sub(self.title, 1, #self.title - self.letters_left), 30, 48, 9)
  self.block:draw()

  if not self.wait_for_block_fall then
    print('start', 44, 66, 7)
    print('enter passcode', 44, 74, 7)
    print('bloxorz demake by thorny', 16, 102, 6)
    print('original game by dxinteractive', 4, 110, 6)

    print('▶', 34 + self.selection_offset, 66 + 8 * self.selection, 7)
  end
end
