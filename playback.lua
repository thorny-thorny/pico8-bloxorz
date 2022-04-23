function playback_create(level_index, keys, loop)
	local playback = {
		level_index = level_index,
		keys = keys,
		loop = loop,
		key_index = 0,
		key_animation = 0,
		switch_animation = 0,
		switch_animation_direct = nil,
		reset_level = playback_reset_level,
		update = playback_update,
		draw = playback_draw,
	}

	playback:reset_level()

	return playback
end

function playback_reset_level(self)
	self.level = level_create(
		make_uv_point(self.level_index * 8, 50),
		8,
		8,
		make_xy_point(8, 32),
		self.loop
	)
end

function playback_update(self)
	if self.switch_animation_direct ~= nil then
		if self.switch_animation_direct then
			self.switch_animation += 1
			-- It's bad, i know
			self.level.draw_offset.x += 20
			self.level.block.draw_offset.x += 20

			if self.switch_animation >= 10 then
				self.switch_animation = 0
				self.switch_animation_direct = false
				self:reset_level()
				self.level.draw_offset.x -= 200
				self.level.block.draw_offset.x -= 200
			end
		else
			self.switch_animation += 1
			self.level.draw_offset.x += 20
			self.level.block.draw_offset.x += 20
			if self.switch_animation >= 10 then
				self.switch_animation = 0
				self.switch_animation_direct = nil
			end
		end

		return
	end

	self.key_animation += 1
	local key = ' '
	if self.key_animation >= 15 then
		key = self.keys[self.key_index + 1]
		self.key_index = (self.key_index + 1) % #self.keys
		if self.key_index == 0 and not self.loop then
			self.switch_animation_direct = true
			self.switch_animation = 0
		end
		self.key_animation = 0
	end

	self.level:update(key)
end

function playback_draw(self)
	local x = 86
	local y = 85

	local default_color = 7
	local highlight_color = 9
	local right_color = default_color
	local down_color = default_color
	local left_color = default_color
	local up_color = default_color
	local o_color = default_color
	if self.key_animation < 10 then
		local key = self.keys[1 + (self.key_index + #self.keys - 1) % #self.keys]
		if key == ➡️ then
			right_color = highlight_color
		elseif key == ⬇️ then
			down_color = highlight_color
		elseif key == ⬅️ then
			left_color = highlight_color
		elseif key == ⬆️ then
			up_color = highlight_color
		elseif key == 🅾️ then
			o_color = highlight_color
		end
	end 
  print('⬆️', x + 10, y, up_color)
  print('⬅️', x, y + 8, left_color)
	print('🅾️', x + 10, y + 8, o_color)
	print('➡️', x + 20, y + 8, right_color)
	print('⬇️', x + 10, y + 16, down_color)

	self.level:draw()
end
