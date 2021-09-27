function game_create()
	local game = {
		level_number = 1,
		levels_total = 7,
		update = game_update,
		draw = game_draw,
	}

	game.level = level_create(game.level_number)

	return game
end

function game_update(self)
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

function game_draw(self)
	cls()
	map(0, 48, 0, 0, 16, 16)
	self.level:draw()
end
