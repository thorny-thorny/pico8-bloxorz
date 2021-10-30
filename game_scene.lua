function game_scene_create()
	local scene = {
		level_number = 1,
		levels_total = 11,
		update = game_scene_update,
		draw = game_scene_draw,
	}

	scene.level = level_create(scene.level_number)

	return scene
end

function game_scene_update(self)
	local finished = self.level:update()
	if finished then
		local new_level_number = self.level_number + 1
		if new_level_number > self.levels_total then
			new_level_number = 1
		end
		self.level_number = new_level_number
		self.level = level_create(self.level_number)
	end
end

function game_scene_draw(self)
	map(0, 48, 0, 0, 16, 16)
	self.level:draw()
	dbg:draw()
	print('stage '..self.level_number..'/'..self.levels_total, 0, 0, 7)
end
