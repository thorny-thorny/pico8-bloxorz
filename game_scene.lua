function game_scene_create()
	local scene = {
		level_number = 1,
		levels_total = 11,
		background = background_create(),
		reset_level = game_scene_reset_level,
		update = game_scene_update,
		draw = game_scene_draw,
	}

	scene:reset_level()

	return scene
end

function game_scene_reset_level(self)
	self.level = level_create(
		make_uv_point(
			(self.level_number % 8) * map_width_tiles,
			flr(self.level_number / 8) * map_height_tiles
		),
		map_width_tiles,
		map_height_tiles
	)
end

function game_scene_update(self)
	local finished = self.level:update()
	if finished then
		local new_level_number = self.level_number + 1
		if new_level_number > self.levels_total then
			new_level_number = 1
		end
		self.level_number = new_level_number
		self:reset_level()
	end
end

function game_scene_draw(self)
	self.background:draw()
	self.level:draw()
	dbg:draw()
	map(80, 34, 0, 0, 16, 16)
	print('stage '..self.level_number..'/'..self.levels_total, 7, 3, 7)
	print('123456', 100, 3, 7)
end
