function make_platform_animation(index)
  local animation = {
    index = index,
    frames_left = 5,
    update = platform_animation_update,
    override_sprite = platform_override_sprite,
  }

  return animation
end

function platform_animation_update(self)
  if self.frames_left == 0 then
    return false
  else
    self.frames_left -= 1
    return true
  end
end

function platform_override_sprite(self, sprite, state)
  if sprite_index_bit(sprite) == self.index then
    if state == 1 then
      return 48
    else
      return 49
    end
  end

  return nil
end
